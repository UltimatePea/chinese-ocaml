(** 骆言诗词统一数据辅助模块 - 韵律工具和辅助模块整合
 *
 * Issue #2015: 韵律工具和辅助模块整合
 * 将10个工具模块整合为3个高效模块的第二个：统一数据辅助模块
 *
 * 整合的模块：
 * - rhyme_helpers.ml (韵组构造)
 * - core/rhyme_helpers.ml (核心韵律辅助) 
 * - rhyme_group_helpers.ml (韵律数据组辅助)
 * - data/file_helper.ml (文件操作)
 *
 * Author: Whisky, PR Worker
 * @since 2025-08-01
 * @version 1.0 - 初始整合版本
 *)

open Poetry_core.Poetry_types

(** {1 韵律数据构造辅助函数} *)

(** === 基础韵字符组构造器 === *)

(** 创建平声韵字符组
    @param rhyme_type 韵部类型
    @param chars 字符列表
    @return (字符, PingSheng, 韵部) 元组列表 *)
let make_ping_sheng_group rhyme_type chars =
  List.map (fun char -> (char, PingSheng, rhyme_type)) chars

(** 创建上声韵字符组 *)
let make_shang_sheng_group rhyme_type chars =
  List.map (fun char -> (char, ShangSheng, rhyme_type)) chars

(** 创建去声韵字符组 *)
let make_qu_sheng_group rhyme_type chars = List.map (fun char -> (char, QuSheng, rhyme_type)) chars

(** 创建入声韵字符组 *)
let make_ru_sheng_group rhyme_type chars = List.map (fun char -> (char, RuSheng, rhyme_type)) chars

(** 创建仄声韵字符组 - 通用仄声（包含上声、去声、入声） *)
let make_ze_sheng_group rhyme_type chars = List.map (fun char -> (char, ZeSheng, rhyme_type)) chars

(** 创建混合声调韵字符组 - 当同一韵组包含多种声调时使用
    @param rhyme_type 韵部类型
    @param char_tone_pairs (字符, 声调) 元组列表
    @return (字符, 声调, 韵部) 元组列表 *)
let make_mixed_tone_group rhyme_type char_tone_pairs =
  List.map (fun (char, tone) -> (char, tone, rhyme_type)) char_tone_pairs

(** === 批量韵组构造器 === *)

(** 创建多个平声韵组 - 用于批量处理同一韵部的不同字符组 *)
let make_multiple_ping_sheng_groups rhyme_type char_groups =
  List.flatten (List.map (make_ping_sheng_group rhyme_type) char_groups)

(** === 常用韵组预设 === *)

(** 诗词常用韵组构造器 - 专门针对诗词编程中的常见韵脚 *)
module Poetry_group_builder = struct
  (** 创建诗词核心韵组 - 诗时知思类常用字 *)
  let make_poetry_core rhyme_type core_chars = make_ping_sheng_group rhyme_type core_chars

  (** 创建方位韵组 - 东西南北中类 *)
  let make_direction_group rhyme_type direction_chars =
    make_ping_sheng_group rhyme_type direction_chars

  (** 创建自然韵组 - 山水云月类 *)
  let make_nature_group rhyme_type nature_chars = make_ping_sheng_group rhyme_type nature_chars

  (** 创建情感韵组 - 喜怒哀乐类 *)
  let make_emotion_group rhyme_type emotion_chars = make_ping_sheng_group rhyme_type emotion_chars
end

(** === 韵组合并工具 === *)

(** 合并多个韵组为单一列表 *)
let merge_rhyme_groups groups = List.flatten groups

(** 按韵部分组韵字 *)
let group_by_rhyme rhyme_data =
  let rec group_helper acc = function
    | [] -> acc
    | (char, tone, rhyme) :: rest ->
        let existing = try List.assoc rhyme acc with Not_found -> [] in
        let updated = (char, tone) :: existing in
        let new_acc = (rhyme, updated) :: List.remove_assoc rhyme acc in
        group_helper new_acc rest
  in
  group_helper [] rhyme_data

(** === 韵律验证工具 === *)

(** 验证韵组一致性 - 检查同一组内韵部是否一致 *)
let validate_rhyme_group group =
  match group with
  | [] -> true
  | (_, _, first_rhyme) :: rest -> List.for_all (fun (_, _, rhyme) -> rhyme = first_rhyme) rest

(** 检查重复字符 *)
let check_duplicate_chars rhyme_data =
  let chars = List.map (fun (char, _, _) -> char) rhyme_data in
  let rec has_dup seen = function
    | [] -> []
    | x :: xs when List.mem x seen -> x :: has_dup seen xs
    | x :: xs -> has_dup (x :: seen) xs
  in
  has_dup [] chars

(** {1 核心韵律数据辅助函数} *)

(** === 来自core/rhyme_helpers.ml的简化函数 === *)

(** 创建韵律数据条目的辅助函数 *)
let make_entry char category group ?(variants = []) ?(frequency = 1.0) () =
  { character = char; category; group; variants; usage_frequency = frequency }

(** 创建某个韵组字符列表的辅助函数 *)
let make_group_entries category group chars =
  List.map (fun char -> make_entry char category group ()) chars

(** {1 文件系统辅助工具} *)

(** === 路径处理 === *)

(** 构建文件路径
    如果提供的是相对路径，则在默认诗词数据目录下构建完整路径。
    @param filename 文件名或路径
    @return 完整的文件路径 *)
let build_filepath filename =
  if Filename.is_relative filename then Filename.concat "data/poetry" filename else filename

(** === 文件内容读取 === *)

(** 读取文件内容
    安全地读取文件全部内容，自动处理文件关闭。
    @param filepath 文件路径
    @return 文件内容字符串
    @raise Sys_error 如果文件不存在或读取失败 *)
let read_file_content filepath =
  let ic = open_in filepath in
  let content = really_input_string ic (in_channel_length ic) in
  close_in ic;
  content

(** === 文件存在性检查 === *)

(** 检查文件是否存在，如果不存在则发出警告
    @param filepath 文件路径
    @return 如果文件存在返回true，否则返回false并输出警告 *)
let file_exists_or_warn filepath =
  if not (Sys.file_exists filepath) then (
    Printf.eprintf "警告: 韵律数据文件不存在: %s，返回空数据\n" filepath;
    flush stderr;
    false)
  else true

(** === 安全文件操作 === *)

(** 安全读取文件内容，包含错误处理
    如果文件不存在或读取失败，返回None而不是抛出异常。
    @param filepath 文件路径
    @return 成功时返回Some content，失败时返回None *)
let safe_read_file filepath =
  try if file_exists_or_warn filepath then Some (read_file_content filepath) else None with
  | Sys_error err ->
      Printf.eprintf "文件系统错误: %s\n" err;
      flush stderr;
      None
  | e ->
      Printf.eprintf "读取文件 %s 时发生未知错误: %s\n" filepath (Printexc.to_string e);
      flush stderr;
      None

(** === 文件信息 === *)

(** 获取文件大小
    @param filepath 文件路径
    @return 文件大小（字节数），如果文件不存在返回0 *)
let get_file_size filepath =
  try
    let stats = Unix.stat filepath in
    stats.st_size
  with Unix.Unix_error _ | Sys_error _ -> 0

(** 检查文件是否为普通文件
    @param filepath 文件路径
    @return 如果是普通文件返回true，否则返回false *)
let is_regular_file filepath =
  try
    let stats = Unix.stat filepath in
    stats.st_kind = Unix.S_REG
  with Unix.Unix_error _ | Sys_error _ -> false

(** {1 数据加载辅助工具} *)

(** === 数据解析辅助 === *)

(** 安全解析JSON内容 *)
let safe_parse_json content =
  try Some (Yojson.Safe.from_string content)
  with Yojson.Json_error _ -> None

(** 从JSON中提取字符串列表 *)
let extract_string_list_from_json json key =
  try
    match Yojson.Safe.Util.member key json with
    | `List items -> List.map (fun item -> Yojson.Safe.Util.to_string item) items
    | _ -> []
  with _ -> []

(** 从JSON中提取韵组数据 *)
let extract_rhyme_group_from_json json =
  try
    let chars = extract_string_list_from_json json "chars" in
    let category_str = Yojson.Safe.Util.(json |> member "category" |> to_string) in
    let group_str = Yojson.Safe.Util.(json |> member "group" |> to_string) in
    (* 这里需要根据实际的类型定义来转换字符串 *)
    Some (chars, category_str, group_str)
  with _ -> None

(** === 批量数据处理 === *)

(** 批量读取多个数据文件 *)
let batch_read_files filepaths =
  List.fold_left (fun acc filepath ->
    match safe_read_file filepath with
    | Some content -> (filepath, content) :: acc
    | None -> acc
  ) [] filepaths

(** 批量验证数据文件 *)
let validate_data_files filepaths =
  let results = List.map (fun filepath -> 
    (filepath, file_exists_or_warn filepath && is_regular_file filepath)
  ) filepaths in
  let (valid, invalid) = List.partition snd results in
  (List.map fst valid, List.map fst invalid)

(** {1 韵律数据特定工具} *)

(** === 韵律数据标准化 === *)

(** 标准化韵字符格式 *)
let normalize_rhyme_char char =
  String.trim (Yyocamlc_lib.Utf8_utils.filter_chinese_chars char)

(** 标准化韵组数据 *)
let normalize_rhyme_group_data rhyme_data =
  List.map (fun (char, tone, group) -> 
    (normalize_rhyme_char char, tone, group)
  ) rhyme_data

(** === 韵律数据统计工具 === *)

(** 统计韵组分布 *)
let count_rhyme_groups rhyme_data =
  let groups = Hashtbl.create 16 in
  List.iter (fun (_, _, group) ->
    let count = match Hashtbl.find_opt groups group with
      | Some c -> c + 1
      | None -> 1
    in
    Hashtbl.replace groups group count
  ) rhyme_data;
  Hashtbl.fold (fun group count acc -> (group, count) :: acc) groups []

(** 统计声调分布 *)
let count_tone_distribution rhyme_data =
  let tones = Hashtbl.create 8 in
  List.iter (fun (_, tone, _) ->
    let count = match Hashtbl.find_opt tones tone with
      | Some c -> c + 1
      | None -> 1
    in
    Hashtbl.replace tones tone count
  ) rhyme_data;
  Hashtbl.fold (fun tone count acc -> (tone, count) :: acc) tones []

(** {1 数据完整性验证} *)

(** === 数据一致性检查 === *)

(** 检查韵律数据完整性 *)
let validate_rhyme_data_integrity rhyme_data =
  let errors = ref [] in
  
  (* 检查空字符 *)
  List.iter (fun (char, _, _) ->
    if String.trim char = "" then
      errors := "发现空字符" :: !errors
  ) rhyme_data;
  
  (* 检查重复字符 *)
  let duplicates = check_duplicate_chars rhyme_data in
  if duplicates <> [] then
    errors := ("重复字符: " ^ String.concat ", " duplicates) :: !errors;
  
  List.rev !errors

(** 验证文件路径安全性 *)
let validate_file_path filepath =
  (* 检查路径遍历攻击 *)
  if String.contains filepath '.' && String.contains filepath '/' then
    if Str.string_match (Str.regexp ".*\\.\\.") filepath 0 then
      false
    else true
  else true

(** {1 缓存友好的数据操作} *)

(** === 高效数据查找 === *)

(** 构建韵字符查找表 *)
let build_char_lookup_table rhyme_data =
  let table = Hashtbl.create (List.length rhyme_data) in
  List.iter (fun (char, tone, group) ->
    Hashtbl.replace table char (tone, group)
  ) rhyme_data;
  table

(** 构建韵组字符表 *)
let build_group_char_table rhyme_data =
  let table = Hashtbl.create 20 in
  List.iter (fun (char, _, group) ->
    let chars = match Hashtbl.find_opt table group with
      | Some existing -> char :: existing
      | None -> [char]
    in
    Hashtbl.replace table group chars
  ) rhyme_data;
  (* 反转列表以保持插入顺序 *)
  Hashtbl.iter (fun group chars ->
    Hashtbl.replace table group (List.rev chars)
  ) table;
  table