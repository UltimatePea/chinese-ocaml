(** 查询管理器模块
    
    负责统一数据管理器的查询功能，包括索引构建、
    数据查询、流式查询和高性能查找。
                                                           
    @author Charlie, 规划代理 - 负责架构重构
    @refactored_from data_manager.ml query functions
    @fix_issue #1727 *)

open Poetry_data_core_data_types

(** {1 内部索引状态} *)

(* 字符索引 - O(1)字符查找优化 *)
let character_index = Hashtbl.create 10000

(* 韵组索引 - O(1)韵组查找优化 *)
let group_index = Hashtbl.create 100

(* 韵类索引 - O(1)韵类查找优化 *)
let category_index = Hashtbl.create 20

(** {1 索引构建功能} *)

(** 重建字符索引
    @param data_list 数据项列表 *)
let rebuild_character_index data_list =
  Hashtbl.clear character_index;
  List.iter (fun item ->
    Hashtbl.replace character_index item.character item
  ) data_list

(** 重建韵组索引
    @param data_list 数据项列表 *)
let rebuild_group_index data_list =
  Hashtbl.clear group_index;
  List.iter (fun item ->
    let chars = 
      match Hashtbl.find_opt group_index item.group with
      | Some existing -> existing
      | None -> []
    in
    Hashtbl.replace group_index item.group (item.character :: chars)
  ) data_list

(** 重建韵类索引
    @param data_list 数据项列表 *)
let rebuild_category_index data_list =
  Hashtbl.clear category_index;
  List.iter (fun item ->
    let chars = 
      match Hashtbl.find_opt category_index item.category with
      | Some existing -> existing
      | None -> []
    in
    Hashtbl.replace category_index item.category (item.character :: chars)
  ) data_list

(** 重建所有索引
    @param data_list 数据项列表 *)
let rebuild_all_indexes data_list =
  rebuild_character_index data_list;
  rebuild_group_index data_list;
  rebuild_category_index data_list

(** {1 核心查询功能} *)

(** 递归查询数据实现 - 支持复合查询
    @param criteria 查询条件
    @param get_from_source 从数据源获取数据的函数
    @return 查询结果 *)
let rec query_data_impl criteria get_from_source =
  (* 首先尝试从缓存获取 *)
  match Cache_manager.get criteria with
  | Some cached_result -> Success cached_result
  | None ->
      let result =
        match criteria with
        | ByCharacter char -> (
            match Hashtbl.find_opt character_index char with
            | Some item -> Success [ item ]
            | None -> Success [])
        | ByGroup group -> (
            match Hashtbl.find_opt group_index group with
            | Some char_list ->
                let items =
                  List.filter_map (fun char -> 
                    Hashtbl.find_opt character_index char
                  ) char_list
                in
                Success items
            | None -> Success [])
        | ByCategory category -> (
            match Hashtbl.find_opt category_index category with
            | Some char_list ->
                let items =
                  List.filter_map (fun char -> 
                    Hashtbl.find_opt character_index char
                  ) char_list
                in
                Success items
            | None -> Success [])
        | BySource source_id -> (
            get_from_source source_id)
        | CompositeQuery criteria_list ->
            let results = List.map (fun c -> query_data_impl c get_from_source) criteria_list in
            let rec merge_results acc = function
              | [] -> Success acc
              | Success items :: rest -> merge_results (acc @ items) rest
              | Error err :: _ -> Error err
            in
            merge_results [] results
      in

      (* 缓存查询结果 *)
      (match result with 
       | Success data -> Cache_manager.put criteria data 
       | _ -> ());

      result

(** 查询数据 - 公共接口
    @param criteria 查询条件
    @param get_from_source 从数据源获取数据的函数
    @return 查询结果 *)
let query_data criteria get_from_source = 
  query_data_impl criteria get_from_source

(** 流式查询数据 - 适用于大量数据的处理
    @param criteria 查询条件
    @param callback 处理每个数据项的回调函数
    @param get_from_source 从数据源获取数据的函数
    @return 查询结果 *)
let query_data_streaming criteria callback get_from_source =
  match query_data criteria get_from_source with
  | Success items ->
      List.iter callback items;
      Success ()
  | Error err -> Error err

(** 计算符合条件的数据数量
    @param criteria 查询条件
    @param get_from_source 从数据源获取数据的函数
    @return 数据数量 *)
let count_data criteria get_from_source =
  match query_data criteria get_from_source with
  | Success items -> Success (List.length items)
  | Error err -> Error err

(** {1 高性能查询模块} *)

module FastLookup = struct
  (** 索引状态跟踪 *)
  let index_status = Hashtbl.create 10

  (** 构建高性能索引
      @param source_list 数据源列表
      @param load_all_data 加载所有数据的函数
      @return 构建结果 *)
  let build_index source_list load_all_data =
    try
      let all_data = load_all_data () in
      (match all_data with
       | Success data ->
           rebuild_all_indexes data;
           List.iter (fun source_id -> 
             Hashtbl.replace index_status source_id true
           ) source_list;
           Success ()
       | Error err -> Error err)
    with exn ->
      Error (Poetry_core.Poetry_errors.DataSourceError 
        ("Index build failed: " ^ Printexc.to_string exn))

  (** 快速字符查找
      @param char 要查找的字符
      @return 查找结果 *)
  let lookup_character char =
    match Hashtbl.find_opt character_index char with
    | Some item -> Success (Some item)
    | None -> Success None

  (** 快速韵组查找
      @param group 要查找的韵组
      @return 查找结果 *)
  let lookup_group group =
    match Hashtbl.find_opt group_index group with
    | Some char_list ->
        let items = List.filter_map (fun char ->
          Hashtbl.find_opt character_index char
        ) char_list in
        Success items
    | None -> Success []

  (** 快速韵类查找
      @param category 要查找的韵类
      @return 查找结果 *)
  let lookup_category category =
    match Hashtbl.find_opt category_index category with
    | Some char_list ->
        let items = List.filter_map (fun char ->
          Hashtbl.find_opt character_index char
        ) char_list in
        Success items
    | None -> Success []

  (** 检查索引状态
      @param source_id 数据源ID
      @return 索引是否已构建 *)
  let is_indexed source_id =
    match Hashtbl.find_opt index_status source_id with
    | Some status -> status
    | None -> false

  (** 获取索引统计信息 *)
  let get_index_statistics () =
    let char_count = Hashtbl.length character_index in
    let group_count = Hashtbl.length group_index in
    let category_count = Hashtbl.length category_index in
    let indexed_sources = 
      Hashtbl.fold (fun source_id status acc ->
        if status then source_id :: acc else acc
      ) index_status []
    in
    {
      character_index_size = char_count;
      group_index_size = group_count;
      category_index_size = category_count;
      indexed_sources = indexed_sources;
    }
end

(** {1 批量查询功能} *)

(** 批量查询多个条件
    @param criteria_list 查询条件列表
    @param get_from_source 从数据源获取数据的函数
    @return 查询结果列表 *)
let batch_query criteria_list get_from_source =
  List.map (fun criteria -> 
    (criteria, query_data criteria get_from_source)
  ) criteria_list

(** 并行批量查询(如果支持的话)
    @param criteria_list 查询条件列表
    @param get_from_source 从数据源获取数据的函数
    @return 查询结果列表 *)
let parallel_batch_query criteria_list get_from_source =
  (* 暂时使用顺序执行，未来可以考虑真正的并行实现 *)
  batch_query criteria_list get_from_source

(** {1 索引统计类型} *)
type index_statistics = {
  character_index_size : int;
  group_index_size : int;
  category_index_size : int;
  indexed_sources : data_source_id list;
}

(** 获取查询管理器统计信息 *)
let get_query_statistics () =
  FastLookup.get_index_statistics ()

(** 清理所有索引 *)
let clear_all_indexes () =
  Hashtbl.clear character_index;
  Hashtbl.clear group_index;
  Hashtbl.clear category_index;
  Hashtbl.clear FastLookup.index_status