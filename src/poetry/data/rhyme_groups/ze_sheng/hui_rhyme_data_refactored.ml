(** 灰韵组数据模块 - 重构版本（技术债务修复 Fix #724）
    
    灰回推开，灰飞烟灭韵苍茫。
    
    此模块已重构为使用JSON外部数据，大幅简化代码结构。
    原339行硬编码数据已外化到JSON配置文件，提升可维护性。
    
    @author 骆言诗词编程团队
    @version 2.0 - 技术债务重构版
    @since 2025-07-20 - Fix #724 诗词数据模块重构 *)

(** 导入JSON数据加载器 *)
open Rhyme_json_data_loader

(** 使用统一的韵律类型定义 - 保持向后兼容 *)
type rhyme_category = Rhyme_json_data_loader.rhyme_category =
  | PingSheng 
  | ZeSheng 
  | ShangSheng 
  | QuSheng 
  | RuSheng 

type rhyme_group = Rhyme_json_data_loader.rhyme_group =
  | AnRhyme | SiRhyme | TianRhyme | WangRhyme | QuRhyme
  | YuRhyme | HuaRhyme | FengRhyme | YueRhyme | XueRhyme
  | JiangRhyme | HuiRhyme | UnknownRhyme

(** {1 兼容性接口 - 保持与原模块相同的API} *)

(** 获取灰韵组所有数据 - 从JSON加载 *)
let hui_yun_ze_sheng = 
  lazy (
    let data = get_hui_rhyme_data () in
    List.map (fun char_data -> 
      (char_data.char, char_data.category, char_data.group)
    ) data
  )

(** 获取灰韵组数据 - 兼容原接口 *)
let get_hui_rhyme_data () = Lazy.force hui_yun_ze_sheng

(** 获取灰韵组字符数量 - 兼容原接口 *)
let get_hui_rhyme_count () = Rhyme_json_data_loader.get_hui_rhyme_count ()

(** 检查字符是否属于灰韵组 - 兼容原接口 *)
let is_hui_rhyme_char char = Rhyme_json_data_loader.is_hui_rhyme_char char

(** 获取所有灰韵组字符列表 - 兼容原接口 *)
let get_hui_rhyme_chars () = Rhyme_json_data_loader.get_hui_rhyme_chars ()

(** {1 增强功能 - 利用JSON数据的优势} *)

(** 按系列获取字符数据 *)
let get_hui_rhyme_series () =
  let json_data = load_rhyme_data_from_json "data/poetry/rhyme_groups/ze_sheng/hui_rhyme_data.json" in
  json_data.series

(** 获取韵律元信息 *)
let get_hui_rhyme_metadata () =
  let json_data = load_rhyme_data_from_json "data/poetry/rhyme_groups/ze_sheng/hui_rhyme_data.json" in
  json_data.metadata

(** 获取特定系列的字符 *)
let get_series_characters series_name =
  let series_list = get_hui_rhyme_series () in
  match List.find_opt (fun s -> s.name = series_name) series_list with
  | Some series -> List.map (fun char_data -> char_data.char) series.characters
  | None -> []

(** 搜索包含特定字符的系列 *)
let find_character_series char =
  let series_list = get_hui_rhyme_series () in
  List.filter (fun series ->
    List.exists (fun char_data -> char_data.char = char) series.characters
  ) series_list

(** {1 调试和统计功能} *)

(** 获取数据统计信息 *)
let get_data_statistics () =
  let metadata = get_hui_rhyme_metadata () in
  let series_list = get_hui_rhyme_series () in
  let series_count = List.length series_list in
  Printf.sprintf 
    "灰韵组数据统计:\n- 版本: %s\n- 总字符数: %d\n- 系列数: %d\n- 描述: %s"
    metadata.version
    metadata.total_characters
    series_count
    metadata.description

(** 验证数据完整性 *)
let validate_data_integrity () =
  try
    let metadata = get_hui_rhyme_metadata () in
    let all_chars = get_hui_rhyme_chars () in
    let actual_count = List.length all_chars in
    let expected_count = metadata.total_characters in
    if actual_count = expected_count then
      Printf.sprintf "✅ 数据完整性验证通过: %d个字符" actual_count
    else
      Printf.sprintf "❌ 数据完整性验证失败: 期望%d个字符，实际%d个字符" 
        expected_count actual_count
  with
  | exn -> 
    Printf.sprintf "❌ 数据完整性验证异常: %s" (Printexc.to_string exn)

(** {1 性能优化} *)

(** 字符查找缓存 - 使用哈希表优化查找性能 *)
let char_lookup_table = lazy (
  let chars = get_hui_rhyme_chars () in
  let table = Hashtbl.create (List.length chars) in
  List.iter (fun char -> Hashtbl.add table char true) chars;
  table
)

(** 高性能字符检查 - 使用哈希表 *)
let is_hui_rhyme_char_fast char =
  let table = Lazy.force char_lookup_table in
  Hashtbl.mem table char

(** 重置缓存 - 用于数据更新后的重新加载 *)
let reset_all_caches () =
  Rhyme_json_data_loader.reset_cache ();
  (* 注意：由于lazy值无法直接重置，需要重启程序来重新加载数据 *)
  Printf.printf "提示: 缓存已重置，某些lazy数据需要重启程序来重新加载\n%!"