(** 数据源管理模块 - 统一管理各种诗词数据源

    从原 poetry_data_loader.ml 中提取的数据源管理功能，提供数据源注册、加载和管理的完整解决方案。

    @author 骆言诗词编程团队 - Phase 15 超长文件重构
    @version 1.0
    @since 2025-07-21 *)

open Rhyme_groups.Rhyme_group_types

(** {1 数据源类型定义} *)

(** 数据源类型 - 支持多种数据来源 *)
type data_source =
  | ModuleData of (string * rhyme_category * rhyme_group) list
  | FileData of string
  | LazyData of (unit -> (string * rhyme_category * rhyme_group) list)

type data_source_entry = {
  name : string;
  source : data_source;
  priority : int;
  description : string;
}
(** 数据源注册项 *)

(** {1 全局数据注册表} *)

(** 注册的数据源列表 *)
let registered_sources = ref []

(** {1 数据源管理函数} *)

(** 注册数据源

    将新的数据源注册到全局注册表中。高优先级的数据源会覆盖低优先级的重复数据。

    @param name 数据源名称
    @param source 数据源
    @param priority 优先级 (数字越大优先级越高)
    @param description 描述信息 *)
let register_data_source name source ?(priority = 0) description =
  let entry = { name; source; priority; description } in
  registered_sources := entry :: !registered_sources

(** 从JSON文件加载韵律数据 - 重构后的模块化版本 *)
let load_rhyme_data_from_file filename =
  try
    let filepath = File_helper.build_filepath filename in

    if not (File_helper.file_exists_or_warn filepath) then []
    else
      let content = File_helper.read_file_content filepath in
      Json_parser.parse_rhyme_data_json content
  with
  | Sys_error err ->
      Printf.eprintf "文件系统错误: %s\n" err;
      flush stderr;
      []
  | e ->
      Printf.eprintf "加载韵律数据文件 %s 时发生未知错误: %s\n" filename (Printexc.to_string e);
      flush stderr;
      []

(** 从数据源加载数据 *)
let load_from_source = function
  | ModuleData data -> data
  | FileData filename ->
      (* 从JSON文件加载诗词数据 *)
      load_rhyme_data_from_file filename
  | LazyData loader -> loader ()

(** 获取所有注册的数据源名称 *)
let get_registered_source_names () = List.map (fun entry -> entry.name) !registered_sources

(** {1 数据源查询和管理} *)

(** 查找指定名称的数据源

    @param name 数据源名称
    @return 如果找到返回Some entry，否则返回None *)
let find_data_source name = List.find_opt (fun entry -> entry.name = name) !registered_sources

(** 删除指定名称的数据源

    @param name 要删除的数据源名称
    @return 如果删除成功返回true，否则返回false *)
let remove_data_source name =
  let original_length = List.length !registered_sources in
  registered_sources := List.filter (fun entry -> entry.name <> name) !registered_sources;
  List.length !registered_sources < original_length

(** 获取按优先级排序的数据源列表

    @return 按优先级从高到低排序的数据源列表 *)
let get_sorted_sources () = List.sort (fun a b -> compare b.priority a.priority) !registered_sources

(** 清空所有注册的数据源 *)
let clear_all_sources () = registered_sources := []

(** {1 数据源统计} *)

(** 获取注册的数据源总数 *)
let get_source_count () = List.length !registered_sources

(** 获取按优先级分组的数据源数量

    @return (高优先级数量, 中优先级数量, 低优先级数量) *)
let get_priority_distribution () =
  let high_priority = List.length (List.filter (fun e -> e.priority >= 10) !registered_sources) in
  let medium_priority =
    List.length (List.filter (fun e -> e.priority >= 5 && e.priority < 10) !registered_sources)
  in
  let low_priority = List.length (List.filter (fun e -> e.priority < 5) !registered_sources) in
  (high_priority, medium_priority, low_priority)

(** {1 调试和监控} *)

(** 打印数据源注册信息 *)
let print_registered_sources () =
  Printf.printf "=== 已注册的诗词数据源 ===\n";
  List.iter
    (fun entry -> Printf.printf "- %s (优先级: %d): %s\n" entry.name entry.priority entry.description)
    (List.rev !registered_sources);
  Printf.printf "总计: %d 个数据源\n" (List.length !registered_sources)
