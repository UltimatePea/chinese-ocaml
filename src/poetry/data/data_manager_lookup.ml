(** 快速索引查找模块
    
    提供高性能的字符、韵组、韵类索引查找功能。
    从原data_manager.ml的FastLookup模块和索引管理功能独立出来。
                                                           
    @author Alpha, 主要工作代理 - 基于Delta/Beta反馈的改进重构
    @version 2.1 - 模块化架构版本  
    @since 2025-07-30 - Phase 2A 改进重构
    @fix_issue #1791 *)

open Data_manager_types

(** {1 索引表管理} *)

(* 字符索引 - O(1)查找优化 *)
let character_index = Hashtbl.create 10000

(* 韵组索引 - O(1)韵组查找优化 *)
let group_index = Hashtbl.create 100

(* 韵类索引 - O(1)韵类查找优化 *)
let category_index = Hashtbl.create 20

(* 索引状态跟踪 *)
let index_status = Hashtbl.create 10

(** {1 索引构建和维护} *)

let rebuild_character_index data_list =
  Hashtbl.clear character_index;
  List.iter (fun item -> Hashtbl.replace character_index item.character item) data_list

let rebuild_group_index data_list =
  Hashtbl.clear group_index;
  List.iter
    (fun item ->
      let existing =
        match Hashtbl.find_opt group_index item.group with Some lst -> lst | None -> []
      in
      Hashtbl.replace group_index item.group (item.character :: existing))
    data_list

let rebuild_category_index data_list =
  Hashtbl.clear category_index;
  List.iter
    (fun item ->
      let existing =
        match Hashtbl.find_opt category_index item.category with Some lst -> lst | None -> []
      in
      Hashtbl.replace category_index item.category (item.character :: existing))
    data_list

let rebuild_all_indexes data_list =
  rebuild_character_index data_list;
  rebuild_group_index data_list;
  rebuild_category_index data_list

(** {1 快速查找接口} *)

let lookup_character char =
  match Hashtbl.find_opt character_index char with
  | Some item -> Success (Some item)
  | None -> Success None

let lookup_characters_by_group group =
  match Hashtbl.find_opt group_index group with
  | Some char_list -> Success char_list
  | None -> Success []

let lookup_characters_by_category category =
  match Hashtbl.find_opt category_index category with
  | Some char_list -> Success char_list
  | None -> Success []

(** {1 索引管理接口} *)

let build_index source_list load_all_data_fn =
  try
    let all_data = load_all_data_fn () in
    rebuild_all_indexes all_data;
    List.iter (fun source_id -> Hashtbl.replace index_status source_id true) source_list;
    Success ()
  with exn ->
    Error
      (ValidationError ("index_build", "Index build failed: " ^ Printexc.to_string exn))

let is_index_built source_id =
  match Hashtbl.find_opt index_status source_id with Some status -> status | None -> false

let rebuild_index source_id =
  match Data_manager_storage.get_registered_source source_id with
  | Some (loader, _, _, _) -> (
      match loader () with
      | Success items ->
          List.iter (fun item -> Hashtbl.replace character_index item.character item) items;
          Hashtbl.replace index_status source_id true;
          Success ()
      | Error err -> Error err)
  | None -> Error (FileNotFound "Source not found")

(** {1 索引统计} *)

let get_index_statistics () =
  let char_count = Hashtbl.length character_index in
  let group_count = Hashtbl.length group_index in
  let category_count = Hashtbl.length category_index in
  (char_count, group_count, category_count)