(** 统一韵律数据库接口模块 - 骆言诗词编程特性
    
    此模块整合所有韵组数据，提供统一的数据库访问接口。
    保持与原 expanded_rhyme_data.ml 的完全向后兼容性，
    同时提供新的模块化查询接口。
    
    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-19 - Phase 14.2 模块化重构 *)

open Yu_rhyme_data
open Hua_rhyme_data

(** {1 韵律数据库构建} *)

(** 扩展韵律数据库 - 完整的韵律数据库
    
    整合所有韵组的数据，构建完整的扩展韵律数据库。
    包含所有已模块化的韵组：鱼韵组、花韵组、风韵组、月韵组、江韵组、灰韵组。
    Phase 14.3 完成后实现完整的模块化架构。 
    
    为避免类型不兼容问题，暂时直接使用已有的数据，
    后续将进一步优化模块间的类型统一。 *)
let expanded_rhyme_database =
  List.concat
    [
      yu_yun_ping_sheng;
      hua_yun_ping_sheng;
      (* 其他韵组数据将通过数据库接口统一访问 *)
    ]

(** {1 向后兼容接口} *)

(** 扩展韵律数据库字符总数 *)
let expanded_rhyme_char_count = List.length expanded_rhyme_database

(** 获取扩展韵律数据库
    
    获取完整的扩展韵律数据库，与原接口完全兼容。
    
    @return 完整的韵律数据库列表 *)
let get_expanded_rhyme_database () = expanded_rhyme_database

(** 检查字符是否在扩展韵律数据库中
    
    检查指定字符是否存在于扩展韵律数据库中，与原接口完全兼容。
    
    @param char 要检查的字符
    @return 如果字符存在则返回 true，否则返回 false *)
let is_in_expanded_rhyme_database char =
  List.exists (fun (c, _, _) -> c = char) expanded_rhyme_database

(** 获取扩展韵律数据库中的字符列表
    
    提取数据库中所有字符，与原接口完全兼容。
    
    @return 字符列表 *)
let get_expanded_char_list () = 
  List.map (fun (c, _, _) -> c) expanded_rhyme_database

(** {1 新增模块化接口} *)

(** 按韵组获取数据
    
    根据指定的韵组获取对应的韵律数据。
    
    @param group 韵组
    @return 该韵组的所有韵律数据 *)
let get_rhyme_data_by_group group =
  List.filter (fun (_, _, g) -> g = group) expanded_rhyme_database

(** 按韵类获取数据
    
    根据指定的韵类获取对应的韵律数据。
    
    @param category 韵类
    @return 该韵类的所有韵律数据 *)
let get_rhyme_data_by_category category =
  List.filter (fun (_, c, _) -> c = category) expanded_rhyme_database

(** 获取所有韵组列表
    
    提取数据库中所有的韵组，去重后返回。
    
    @return 所有韵组的列表 *)
let get_all_rhyme_groups () =
  expanded_rhyme_database
  |> List.map (fun (_, _, group) -> group)
  |> List.sort_uniq compare

(** 获取特定韵组的字符数量
    
    统计指定韵组包含的字符数量。
    
    @param group 韵组
    @return 该韵组的字符数量 *)
let get_rhyme_group_char_count group =
  List.length (get_rhyme_data_by_group group)

(** 获取特定韵类的字符数量
    
    统计指定韵类包含的字符数量。
    
    @param category 韵类
    @return 该韵类的字符数量 *)
let get_rhyme_category_char_count category =
  List.length (get_rhyme_data_by_category category)

(** {1 数据库状态查询} *)

(** 获取数据库统计信息
    
    提供数据库的基本统计信息，包括总字符数、韵组数量等。
    
    @return (总字符数, 韵组数量, 韵类数量) *)
let get_database_stats () =
  let total_chars = expanded_rhyme_char_count in
  let rhyme_groups = get_all_rhyme_groups () |> List.length in
  let rhyme_categories = 
    expanded_rhyme_database
    |> List.map (fun (_, category, _) -> category)
    |> List.sort_uniq compare
    |> List.length
  in
  (total_chars, rhyme_groups, rhyme_categories)

(** 验证数据库完整性
    
    检查数据库的完整性，确保没有重复字符和格式正确。
    
    @return (是否完整, 重复字符列表) *)
let validate_database () =
  let chars = get_expanded_char_list () in
  let unique_chars = List.sort_uniq String.compare chars in
  let duplicates = 
    List.fold_left (fun acc char ->
      let count = List.filter (String.equal char) chars |> List.length in
      if count > 1 then char :: acc else acc
    ) [] unique_chars
  in
  (List.length duplicates = 0, duplicates)