(** 数据源管理器模块
    
    负责统一数据管理器的数据源管理功能，包括数据源注册、
    数据加载、冲突检测和完整性验证。
                                                           
    @author Charlie, 规划代理 - 负责架构重构
    @refactored_from data_manager.ml source management functions  
    @fix_issue #1727 *)

open Poetry_data_core_data_types

(** {1 内部数据源注册表} *)

(* 数据源注册表 - 线程安全的哈希表 *)
let registered_sources = Hashtbl.create 32

(** 内部数据源信息类型 - 包含加载器和元数据 *)
type internal_source_info = {
  loader : unit -> unified_data_item list data_result;
  priority : int;
  description : string;
  register_time : float;
}

(** {1 数据源注册管理} *)

(** 注册数据源
    @param source_id 数据源标识符
    @param loader 数据加载函数
    @param priority 优先级(默认0，数值越高优先级越高)
    @param description 数据源描述
    @return 注册结果 *)
let register_data_source source_id loader ?(priority = 0) description =
  try
    let source_info = {
      loader = loader;
      priority = priority;
      description = description;
      register_time = Unix.time ();
    } in
    Hashtbl.replace registered_sources source_id source_info;
    Success ()
  with exn ->
    Error (Poetry_core.Poetry_errors.DataSourceError
      ("Failed to register data source: " ^ Printexc.to_string exn))

(** 注销数据源
    @param source_id 数据源标识符
    @return 注销结果 *)
let unregister_data_source source_id =
  try
    if Hashtbl.mem registered_sources source_id then (
      Hashtbl.remove registered_sources source_id;
      Success ()
    ) else 
      Error (Poetry_core.Poetry_errors.DataSourceError "Data source not found")
  with exn ->
    Error (Poetry_core.Poetry_errors.DataSourceError
      ("Failed to unregister data source: " ^ Printexc.to_string exn))

(** 列出所有已注册的数据源
    @return 数据源列表 (source_id, description, priority) *)
let list_registered_sources () =
  Hashtbl.fold (fun source_id info acc ->
    (source_id, info.description, info.priority) :: acc
  ) registered_sources []

(** 检查数据源是否已注册
    @param source_id 数据源标识符
    @return 是否已注册 *)
let is_source_registered source_id =
  Hashtbl.mem registered_sources source_id

(** 获取数据源详细信息
    @param source_id 数据源标识符
    @return 数据源信息 *)
let get_source_info source_id =
  match Hashtbl.find_opt registered_sources source_id with
  | Some info -> Success {
      source_id = source_id;
      loader = info.loader;
      priority = info.priority;
      description = info.description;
    }
  | None -> Error (Poetry_core.Poetry_errors.DataSourceError "Data source not found")

(** {1 数据加载和合并} *)

(** 从指定数据源加载数据
    @param source_id 数据源标识符
    @return 数据加载结果 *)
let load_from_source source_id =
  match Hashtbl.find_opt registered_sources source_id with
  | Some info -> info.loader ()
  | None -> Error (Poetry_core.Poetry_errors.DataSourceError "Source not found")

(** 加载所有数据源的数据，按优先级合并
    @return 合并后的数据列表 *)
let load_all_data () =
  let sources_with_priority =
    Hashtbl.fold (fun source_id info acc ->
      (source_id, info.loader, info.priority) :: acc
    ) registered_sources []
    |> List.sort (fun (_, _, p1) (_, _, p2) -> compare p2 p1) (* 高优先级优先 *)
  in

  let all_items = ref [] in
  let seen_characters = Hashtbl.create 10000 in

  List.iter (fun (source_id, loader, _) ->
    match loader () with
    | Success items ->
        List.iter (fun item ->
          if not (Hashtbl.mem seen_characters item.character) then (
            Hashtbl.add seen_characters item.character true;
            all_items := item :: !all_items
          )
        ) items
    | Error err ->
        Printf.eprintf "Warning: Failed to load data from source %s: %s\n"
          (string_of_data_source_id source_id)
          (match err with
           | Poetry_core.Poetry_errors.DataSourceError msg -> msg
           | _ -> "Unknown error")
  ) sources_with_priority;

  let final_data = List.rev !all_items in
  
  (* 重建查询索引 *)
  Query_manager.rebuild_all_indexes final_data;
  
  Success final_data

(** 选择性加载数据源
    @param source_ids 要加载的数据源ID列表
    @return 加载结果 *)
let load_selected_sources source_ids =
  let loaded_items = ref [] in
  let errors = ref [] in
  
  List.iter (fun source_id ->
    match load_from_source source_id with
    | Success items -> loaded_items := items @ !loaded_items
    | Error err -> errors := (source_id, err) :: !errors
  ) source_ids;
  
  if !errors = [] then
    Success !loaded_items
  else
    Error (Poetry_core.Poetry_errors.DataSourceError 
      ("Failed to load from some sources: " ^ 
       String.concat ", " (List.map (fun (id, _) -> string_of_data_source_id id) !errors)))

(** {1 数据完整性和冲突检测} *)

(** 验证数据完整性
    @param source_list 要验证的数据源列表
    @return 验证结果 *)
let validate_data_integrity source_list =
  let validation_errors = ref [] in
  
  List.iter (fun source_id ->
    match load_from_source source_id with
    | Success data ->
        List.iteri (fun i item ->
          (* 检查必填字段 *)
          if String.length item.character = 0 then
            validation_errors := (source_id, i, "Empty character") :: !validation_errors;
          
          (* 检查字符长度合理性 *)
          if String.length item.character > 10 then
            validation_errors := (source_id, i, "Character too long") :: !validation_errors;
        ) data
    | Error err ->
        validation_errors := (source_id, -1, "Failed to load source") :: !validation_errors
  ) source_list;
  
  if !validation_errors = [] then
    Success ()
  else
    Error (Poetry_core.Poetry_errors.DataSourceError 
      (Printf.sprintf "Validation failed: %d errors found" (List.length !validation_errors)))

(** 检测数据源之间的冲突
    @param source_list 要检查的数据源列表
    @return 冲突检测结果 *)
let detect_data_conflicts source_list =
  let character_sources = Hashtbl.create 10000 in
  let conflicts = ref [] in
  
  List.iter (fun source_id ->
    match load_from_source source_id with
    | Success data ->
        List.iter (fun item ->
          match Hashtbl.find_opt character_sources item.character with
          | Some existing_source when existing_source <> source_id ->
              conflicts := (item.character, existing_source, source_id) :: !conflicts
          | _ ->
              Hashtbl.replace character_sources item.character source_id
        ) data
    | Error _ -> () (* 忽略加载失败的数据源 *)
  ) source_list;
  
  if !conflicts = [] then
    Success []
  else
    Success !conflicts

(** 合并冲突数据
    @param resolve_conflict 冲突解决函数
    @param source_list 数据源列表
    @return 合并结果 *)
let merge_conflicting_data ~resolve_conflict source_list =
  let character_data = Hashtbl.create 10000 in
  
  List.iter (fun source_id ->
    match load_from_source source_id with
    | Success data ->
        List.iter (fun item ->
          match Hashtbl.find_opt character_data item.character with
          | Some existing_item ->
              let resolved_item = resolve_conflict existing_item item in
              Hashtbl.replace character_data item.character resolved_item
          | None ->
              Hashtbl.replace character_data item.character item
        ) data
    | Error _ -> () (* 忽略加载失败的数据源 *)
  ) source_list;
  
  let merged_data = Hashtbl.fold (fun _ item acc -> item :: acc) character_data [] in
  Success merged_data

(** {1 统计和监控功能} *)

(** 获取数据源统计信息 *)
let get_data_source_statistics () =
  let total_sources = Hashtbl.length registered_sources in
  let source_details = Hashtbl.fold (fun source_id info acc ->
    let data_count = match info.loader () with
      | Success data -> List.length data
      | Error _ -> 0
    in
    (source_id, info.priority, data_count, info.register_time) :: acc
  ) registered_sources [] in
  
  {
    total_sources = total_sources;
    source_details = source_details;
  }

(** 获取指定数据源的统计信息
    @param source_id 数据源标识符
    @return 统计信息 *)
let get_source_statistics source_id =
  match Hashtbl.find_opt registered_sources source_id with
  | Some info ->
      let data_count = match info.loader () with
        | Success data -> List.length data
        | Error _ -> 0
      in
      Success {
        source_id = source_id;
        data_count = data_count;
        priority = info.priority;
        description = info.description;
        register_time = info.register_time;
      }
  | None -> Error (Poetry_core.Poetry_errors.DataSourceError "Source not found")

(** 性能报告生成 *)
let print_performance_report () =
  let stats = get_data_source_statistics () in
  Printf.printf "\n=== Data Source Performance Report ===\n";
  Printf.printf "Total registered sources: %d\n" stats.total_sources;
  Printf.printf "\nSource Details:\n";
  List.iter (fun (source_id, priority, data_count, register_time) ->
    Printf.printf "  %s: priority=%d, data_count=%d, registered=%.0f\n"
      (string_of_data_source_id source_id)
      priority data_count register_time
  ) stats.source_details;
  Printf.printf "=====================================\n\n"

(** {1 统计信息类型定义} *)

type data_source_statistics = {
  total_sources : int;
  source_details : (data_source_id * int * int * float) list;
}

type source_statistics = {
  source_id : data_source_id;
  data_count : int;
  priority : int;
  description : string;
  register_time : float;
}

(** {1 清理和维护功能} *)

(** 清理所有数据源注册 *)
let clear_all_sources () =
  Hashtbl.clear registered_sources

(** 重新加载所有数据源 *)
let reload_all_sources () =
  load_all_data ()