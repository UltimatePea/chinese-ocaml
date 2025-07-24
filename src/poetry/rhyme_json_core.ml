(** 韵律JSON处理核心模块 - 整合版本
    
    整合了原本分散在8个模块中的功能，包括类型定义、JSON解析、缓存管理、
    文件I/O操作、数据访问接口和降级处理。
    
    本模块解决了过度模块化导致的维护复杂性问题，提供统一的韵律数据处理接口。
    
    @author 骆言诗词编程团队
    @version 2.0  
    @since 2025-07-24 - Phase 7.1 JSON处理系统整合重构 *)

(** {1 类型定义} *)

(** 韵类定义 *)
type rhyme_category =
  | PingSheng  (** 平声 *)
  | ZeSheng  (** 仄声 *)
  | ShangSheng  (** 上声 *)
  | QuSheng  (** 去声 *)
  | RuSheng  (** 入声 *)

(** 韵组定义 *)
type rhyme_group =
  | AnRhyme  (** 安韵 *)
  | SiRhyme  (** 思韵 *)
  | TianRhyme  (** 天韵 *)
  | WangRhyme  (** 王韵 *)
  | QuRhyme  (** 曲韵 *)
  | YuRhyme  (** 雨韵 *)
  | HuaRhyme  (** 花韵 *)
  | FengRhyme  (** 风韵 *)
  | YueRhyme  (** 月韵 *)
  | XueRhyme  (** 雪韵 *)
  | JiangRhyme  (** 江韵 *)
  | HuiRhyme  (** 辉韵 *)
  | UnknownRhyme  (** 未知韵 *)

(** JSON解析异常 *)
exception Json_parse_error of string

(** 韵律数据未找到异常 *)
exception Rhyme_data_not_found of string

(** 韵组数据类型 *)
type rhyme_group_data = {
  category : string;  (** 韵类名称 *)
  characters : string list;  (** 该韵组包含的字符列表 *)
}

(** 韵律数据文件结构 *)
type rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;  (** 韵组映射 *)
  metadata : (string * string) list;  (** 元数据信息 *)
}

(** {1 类型转换函数} *)

(** 字符串转韵类 *)
let string_to_rhyme_category = function
  | "平声" | "ping_sheng" -> PingSheng
  | "仄声" | "ze_sheng" -> ZeSheng
  | "上声" | "shang_sheng" -> ShangSheng
  | "去声" | "qu_sheng" -> QuSheng
  | "入声" | "ru_sheng" -> RuSheng
  | _ -> PingSheng (* 默认平声 *)

(** 字符串转韵组 *)
let string_to_rhyme_group = function
  | "安韵" | "an_rhyme" -> AnRhyme
  | "思韵" | "si_rhyme" -> SiRhyme
  | "天韵" | "tian_rhyme" -> TianRhyme
  | "王韵" | "wang_rhyme" -> WangRhyme
  | "曲韵" | "qu_rhyme" -> QuRhyme
  | "雨韵" | "yu_rhyme" -> YuRhyme
  | "花韵" | "hua_rhyme" -> HuaRhyme
  | "风韵" | "feng_rhyme" -> FengRhyme
  | "月韵" | "yue_rhyme" -> YueRhyme
  | "雪韵" | "xue_rhyme" -> XueRhyme
  | "江韵" | "jiang_rhyme" -> JiangRhyme
  | "辉韵" | "hui_rhyme" -> HuiRhyme
  | _ -> UnknownRhyme

(** {1 缓存管理} *)

(** 缓存有效期（秒） *)
let cache_ttl = 300.0

(** 缓存的数据 *)
let cached_data = ref None

(** 缓存时间戳 *)
let cache_timestamp = ref 0.0

(** 检查缓存是否有效 *)
let is_cache_valid () =
  match !cached_data with
  | None -> false
  | Some _ ->
      let current_time = Unix.time () in
      current_time -. !cache_timestamp < cache_ttl

(** 获取缓存的数据 *)
let get_cached_data () =
  match !cached_data with 
  | Some data -> data 
  | None -> raise (Rhyme_data_not_found "缓存中无数据")

(** 设置缓存数据 *)
let set_cached_data data =
  cached_data := Some data;
  cache_timestamp := Unix.time ()

(** 清理缓存 *)
let clear_cache () =
  cached_data := None;
  cache_timestamp := 0.0

(** 强制刷新缓存 *)
let refresh_cache data =
  clear_cache ();
  set_cached_data data

(** {1 JSON解析器} *)

(** 清理JSON字符串 *)
let clean_json_string s =
  let s = String.trim s in
  let len = String.length s in
  if len = 0 then ""
  else
    let s = if s.[0] = '"' && len > 1 then String.sub s 1 (len - 1) else s in
    let s_len = String.length s in
    let s = if s_len > 0 && s.[s_len - 1] = ',' then String.sub s 0 (s_len - 1) else s in
    if String.length s > 0 && s.[String.length s - 1] = '"' then String.sub s 0 (String.length s - 1)
    else s

(** 解析状态类型 *)
type parse_state = {
  mutable current_group : string option;
  mutable current_category : string;
  mutable current_chars : string list;
  mutable result_groups : (string * rhyme_group_data) list;
  mutable in_rhyme_group : bool;
  mutable in_characters_array : bool;
  mutable brace_depth : int;
  mutable bracket_depth : int;
}

(** 创建初始解析状态 *)
let create_parse_state () =
  {
    current_group = None;
    current_category = "";
    current_chars = [];
    result_groups = [];
    in_rhyme_group = false;
    in_characters_array = false;
    brace_depth = 0;
    bracket_depth = 0;
  }

(** 完成当前韵组的解析 *)
let finalize_current_group state =
  match state.current_group with
  | Some group_name ->
      let group_data =
        { category = state.current_category; characters = List.rev state.current_chars }
      in
      state.result_groups <- (group_name, group_data) :: state.result_groups;
      state.current_group <- None;
      state.current_chars <- []
  | None -> ()

(** 处理韵组头部信息 *)
let process_rhyme_group_header state trimmed =
  finalize_current_group state;
  let parts = String.split_on_char ':' trimmed in
  if List.length parts >= 1 then
    let key = List.hd parts in
    let cleaned_key = clean_json_string key in
    if cleaned_key <> "" then (
      state.current_group <- Some cleaned_key;
      state.in_rhyme_group <- true;
      state.current_category <- "";
      state.current_chars <- [])

(** 处理韵类字段 *)
let process_category_field state trimmed =
  let parts = String.split_on_char ':' trimmed in
  if List.length parts >= 2 then
    let value = List.nth parts 1 in
    state.current_category <- clean_json_string value

(** 处理字符元素 *)
let process_character_element state trimmed =
  if state.in_characters_array then
    let char = clean_json_string trimmed in
    if char <> "" then state.current_chars <- char :: state.current_chars

(** 处理单行内容 *)
let process_line_content state line =
  let trimmed = String.trim line in

  (* 更新括号深度 *)
  String.iter
    (function
      | '{' -> state.brace_depth <- state.brace_depth + 1
      | '}' -> state.brace_depth <- state.brace_depth - 1
      | '[' -> state.bracket_depth <- state.bracket_depth + 1
      | ']' -> state.bracket_depth <- state.bracket_depth - 1
      | _ -> ())
    trimmed;

  (* 检测是否进入characters数组 *)
  let contains_characters =
    try
      ignore (Str.search_forward (Str.regexp "characters") line 0);
      true
    with Not_found -> false
  in
  if String.contains trimmed '[' && contains_characters then state.in_characters_array <- true;

  if String.contains trimmed ']' && state.in_characters_array then
    state.in_characters_array <- false;

  (* 处理不同类型的行 *)
  if String.contains trimmed ':' && not state.in_characters_array then (
    let contains_category =
      try
        ignore (Str.search_forward (Str.regexp "category") line 0);
        true
      with Not_found -> false
    in
    if contains_category then process_category_field state trimmed
    else if state.brace_depth > 0 then process_rhyme_group_header state trimmed)
  else if state.in_characters_array then process_character_element state trimmed

(** 解析嵌套JSON内容 *)
let parse_nested_json content =
  let lines = String.split_on_char '\n' content in
  let state = create_parse_state () in

  List.iter (process_line_content state) lines;
  finalize_current_group state;

  List.rev state.result_groups

(** {1 文件I/O操作} *)

(** 默认数据文件路径 *)
let default_data_file = "data/poetry/rhyme_groups/rhyme_data.json"

(** 安全地读取文件内容 *)
let safe_read_file filename =
  try
    let ic = open_in filename in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    content
  with
  | Sys_error msg -> raise (Rhyme_data_not_found ("文件读取失败: " ^ msg))
  | _ -> raise (Rhyme_data_not_found ("文件读取时发生未知错误: " ^ filename))

(** 从文件加载韵律数据 *)
let load_rhyme_data_from_file ?(filename = default_data_file) () =
  try
    let content = safe_read_file filename in
    let rhyme_groups = parse_nested_json content in
    let data = { rhyme_groups; metadata = [] } in
    set_cached_data data;
    data
  with
  | Json_parse_error msg -> raise (Json_parse_error ("JSON解析错误: " ^ msg))
  | Rhyme_data_not_found msg -> raise (Rhyme_data_not_found msg)
  | exn -> raise (Json_parse_error ("加载韵律数据时发生异常: " ^ Printexc.to_string exn))

(** {1 降级数据处理} *)

(** 降级韵律数据 *)
let fallback_rhyme_data =
  [
    ("安韵", { category = "平声"; characters = [ "安"; "看"; "山" ] });
    ("思韵", { category = "仄声"; characters = [ "思"; "之"; "子" ] });
  ]

(** 使用降级数据 *)
let use_fallback_data () =
  Printf.eprintf "警告: 使用降级韵律数据\n%!";
  let data = { rhyme_groups = fallback_rhyme_data; metadata = [] } in
  set_cached_data data;
  data

(** {1 主要API函数} *)

(** 获取韵律数据（支持缓存） *)
let get_rhyme_data ?(force_reload = false) () =
  if force_reload then (
    clear_cache ();
    load_rhyme_data_from_file ())
  else if is_cache_valid () then get_cached_data ()
  else load_rhyme_data_from_file ()

(** 获取所有韵组 *)
let get_all_rhyme_groups () =
  let data = get_rhyme_data () in
  data.rhyme_groups

(** 获取指定韵组的字符列表 *)
let get_rhyme_group_characters group_name =
  let groups = get_all_rhyme_groups () in
  try
    let _, group_data = List.find (fun (name, _) -> name = group_name) groups in
    group_data.characters
  with Not_found -> []

(** 获取指定韵组的韵类 *)
let get_rhyme_group_category group_name =
  let groups = get_all_rhyme_groups () in
  try
    let _, group_data = List.find (fun (name, _) -> name = group_name) groups in
    string_to_rhyme_category group_data.category
  with Not_found -> PingSheng (* 默认平声 *)

(** 获取韵律映射关系 *)
let get_rhyme_mappings () =
  let groups = get_all_rhyme_groups () in
  let mappings = ref [] in
  List.iter
    (fun (group_name, group_data) ->
      let rhyme_category = string_to_rhyme_category group_data.category in
      let rhyme_group = string_to_rhyme_group group_name in
      (* 为每个字符创建映射 *)
      List.iter
        (fun char -> mappings := (char, (rhyme_category, rhyme_group)) :: !mappings)
        group_data.characters)
    groups;
  List.rev !mappings

(** 获取数据统计信息 *)
let get_data_statistics () =
  try
    let data_opt = get_rhyme_data () in
    let total_groups = List.length data_opt.rhyme_groups in
    let total_chars =
      List.fold_left
        (fun acc (_, group_data) -> acc + List.length group_data.characters)
        0 data_opt.rhyme_groups
    in
    Some (total_groups, total_chars)
  with _ -> None

(** 打印统计信息 *)
let print_statistics () =
  match get_data_statistics () with
  | Some (total_groups, total_chars) ->
      Printf.printf "韵律数据统计:\n";
      Printf.printf "  韵组总数: %d\n" total_groups;
      Printf.printf "  字符总数: %d\n" total_chars;
      Printf.printf "  平均每组字符数: %.1f\n"
        (if total_groups > 0 then float_of_int total_chars /. float_of_int total_groups else 0.0)
  | None -> Printf.printf "无法获取韵律数据统计信息\n"

(** 安全获取韵律数据（带降级处理） *)
let get_rhyme_data_safe ?(force_reload = false) () =
  try Some (get_rhyme_data ~force_reload ())
  with Rhyme_data_not_found _ | Json_parse_error _ -> Some (use_fallback_data ())