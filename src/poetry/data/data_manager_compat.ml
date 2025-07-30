(** 向后兼容性接口模块
    
    提供与旧版本API的兼容接口，确保现有代码无需修改即可使用新的模块化架构。
    从原data_manager.ml的Compatibility模块独立出来，并扩展兼容功能。
                                                           
    @author Alpha, 主要工作代理 - 基于Delta/Beta反馈的改进重构
    @version 2.1 - 模块化架构版本  
    @since 2025-07-30 - Phase 2A 改进重构
    @fix_issue #1791 *)

open Data_manager_types

(** {1 遗留数据库接口} *)

let get_legacy_rhyme_database load_all_data_fn =
  let all_data = load_all_data_fn () in
  List.map (fun item -> (item.character, item.category, item.group)) all_data

let is_char_in_database char =
  match Data_manager_lookup.lookup_character char with
  | Success (Some _) -> true
  | Success None -> false
  | Error _ -> false

let get_char_rhyme_info char =
  match Data_manager_lookup.lookup_character char with
  | Success (Some item) -> Some (item.character, item.category, item.group)
  | Success None -> None
  | Error _ -> None

(** {1 兼容性数据格式转换} *)

let convert_to_legacy_format items =
  List.map (fun item -> (item.character, item.category, item.group)) items

let convert_from_legacy_format legacy_items =
  List.map 
    (fun (character, category, group) -> 
      { character; category; group; metadata = [] }) 
    legacy_items

(** {1 旧版本查询接口兼容} *)

let legacy_query_by_character char =
  match Data_manager_lookup.lookup_character char with
  | Success (Some item) -> Some [item]
  | Success None -> Some []
  | Error _ -> None

let legacy_query_by_group group =
  match Data_manager_lookup.lookup_characters_by_group group with
  | Success char_list ->
      let items = List.filter_map 
        (fun char -> match Data_manager_lookup.lookup_character char with
         | Success (Some item) -> Some item
         | _ -> None) 
        char_list in
      Some items
  | Error _ -> None

let legacy_query_by_category category =
  match Data_manager_lookup.lookup_characters_by_category category with
  | Success char_list ->
      let items = List.filter_map 
        (fun char -> match Data_manager_lookup.lookup_character char with
         | Success (Some item) -> Some item
         | _ -> None) 
        char_list in
      Some items
  | Error _ -> None

(** {1 旧版本错误处理} *)

let legacy_error_to_string = function
  | Poetry_core.Poetry_errors.DataSourceError msg -> msg
  | _ -> "Unknown error"