(** 诗词艺术数据管理统一模块 - Issue #2000 整合实施
 *
 * 此文件整合了以下源文件的功能：
 * - src/poetry/artistic_data_loader.ml: 数据加载
 * - src/poetry/artistic_data_accessor.ml: 数据访问
 * - src/poetry/artistic_data_parser.ml: 数据解析
 * - src/poetry/artistic_data_registry.ml: 数据注册
 * - src/poetry/artistic_template_manager.ml: 模板管理
 *
 * 整合完成后，上述文件将被删除。
 * @consolidation_issue #2000
 * @author Whisky, PR Worker
 *)

(** {1 核心数据类型} *)

type data_source =
  | FileSource of string
  | DatabaseSource of string
  | MemorySource of (string * string) list

type data_entry = {
  id : string;
  content : string;
  metadata : (string * string) list;
  created_at : float;
  updated_at : float;
}

type data_registry = {
  entries : (string, data_entry) Hashtbl.t;
  mutable sources : data_source list;
  templates : (string, string) Hashtbl.t;
}

(** {1 全局数据注册表} *)

let global_registry = { entries = Hashtbl.create 100; sources = []; templates = Hashtbl.create 50 }

(** {1 数据加载功能} *)

(** 从文件加载数据 *)
let load_from_file filename =
  try
    let ic = open_in filename in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    Some content
  with
  | Sys_error _ -> None
  | _ -> None

(** 解析数据内容 *)
let parse_data_content content =
  let lines = String.split_on_char '\n' content in
  List.filter_map
    (fun line ->
      let trimmed = String.trim line in
      if trimmed = "" || String.get trimmed 0 = '#' then None
      else
        try
          let parts = String.split_on_char ':' trimmed in
          match parts with
          | key :: value_parts ->
              let value = String.concat ":" value_parts |> String.trim in
              Some (String.trim key, value)
          | [] -> None
        with _ -> None)
    lines

(** 加载数据源 *)
let load_data_source source =
  match source with
  | FileSource filename -> (
      match load_from_file filename with Some content -> parse_data_content content | None -> [])
  | DatabaseSource _connection_string ->
      (* 简化的数据库模拟 *)
      [ ("db_status", "connected"); ("entries", "100") ]
  | MemorySource data -> data

(** {1 数据访问功能} *)

(** 获取数据条目 *)
let get_data_entry id = try Some (Hashtbl.find global_registry.entries id) with Not_found -> None

(** 设置数据条目 *)
let set_data_entry id content metadata =
  let entry = { id; content; metadata; created_at = Unix.time (); updated_at = Unix.time () } in
  Hashtbl.replace global_registry.entries id entry

(** 删除数据条目 *)
let remove_data_entry id = Hashtbl.remove global_registry.entries id

(** 列出所有条目ID *)
let list_entry_ids () = Hashtbl.fold (fun key _value acc -> key :: acc) global_registry.entries []

(** 查询数据条目 *)
let query_entries predicate =
  Hashtbl.fold
    (fun _key value acc -> if predicate value then value :: acc else acc)
    global_registry.entries []

(** {1 模板管理功能} *)

(** 注册模板 *)
let register_template template_id template_content =
  Hashtbl.replace global_registry.templates template_id template_content

(** 获取模板 *)
let get_template template_id =
  try Some (Hashtbl.find global_registry.templates template_id) with Not_found -> None

(** 应用模板 *)
let apply_template template_id data =
  match get_template template_id with
  | Some template ->
      List.fold_left
        (fun acc (key, value) ->
          let pattern = "{" ^ key ^ "}" in
          Str.global_replace (Str.regexp pattern) value acc)
        template data
  | None -> "模板未找到: " ^ template_id

(** 列出所有模板 *)
let list_templates () = Hashtbl.fold (fun key _value acc -> key :: acc) global_registry.templates []

(** {1 数据注册表管理} *)

(** 添加数据源 *)
let add_data_source source = global_registry.sources <- source :: global_registry.sources

(** 初始化数据注册表 *)
let initialize_registry () =
  (* 清空现有数据 *)
  Hashtbl.clear global_registry.entries;
  Hashtbl.clear global_registry.templates;

  (* 加载默认模板 *)
  register_template "poem_evaluation" "诗词: {title}\n作者: {author}\n评分: {score}\n建议: {suggestions}";
  register_template "artistic_analysis"
    "艺术分析报告\n评价对象: {subject}\n整体评分: {overall_score}\n详细分析: {analysis}";

  (* 设置默认数据源 *)
  add_data_source
    (MemorySource
       [
         ("default_weights", "韵律:0.2,声调:0.2,对仗:0.15,意象:0.15");
         ("evaluation_criteria", "基础=0.6,良好=0.75,优秀=0.9");
       ])

(** 重新加载所有数据源 *)
let reload_all_sources () =
  List.iter
    (fun source ->
      let data = load_data_source source in
      List.iter (fun (key, value) -> set_data_entry key value [ ("source", "auto_loaded") ]) data)
    global_registry.sources

(** {1 数据导出功能} *)

(** 导出数据到字符串 *)
let export_data_to_string () =
  let entries =
    Hashtbl.fold
      (fun key value acc -> Printf.sprintf "%s:%s" key value.content :: acc)
      global_registry.entries []
  in
  String.concat "\n" entries

(** 导出模板到字符串 *)
let export_templates_to_string () =
  let templates =
    Hashtbl.fold
      (fun key value acc -> Printf.sprintf "模板[%s]:%s" key value :: acc)
      global_registry.templates []
  in
  String.concat "\n" templates

(** {1 统计和诊断功能} *)

(** 获取注册表统计信息 *)
let get_registry_stats () =
  [
    ("总条目数", string_of_int (Hashtbl.length global_registry.entries));
    ("模板数量", string_of_int (Hashtbl.length global_registry.templates));
    ("数据源数量", string_of_int (List.length global_registry.sources));
  ]

(** 验证数据完整性 *)
let validate_data_integrity () =
  let errors = ref [] in

  (* 检查条目有效性 *)
  Hashtbl.iter
    (fun key entry ->
      if entry.content = "" then errors := ("空内容条目: " ^ key) :: !errors;
      if entry.id <> key then errors := ("ID不匹配: " ^ key) :: !errors)
    global_registry.entries;

  (* 检查模板有效性 *)
  Hashtbl.iter
    (fun key template -> if template = "" then errors := ("空模板: " ^ key) :: !errors)
    global_registry.templates;

  !errors

(** {1 高级数据操作} *)

(** 批量设置数据 *)
let batch_set_data data_list =
  List.iter (fun (id, content, metadata) -> set_data_entry id content metadata) data_list

(** 数据搜索 *)
let search_data query =
  let normalized_query = String.lowercase_ascii query in
  query_entries (fun entry ->
      String.contains (String.lowercase_ascii entry.content) (String.get normalized_query 0)
      || List.exists
           (fun (key, value) ->
             String.contains (String.lowercase_ascii (key ^ value)) (String.get normalized_query 0))
           entry.metadata)

(** 数据备份 *)
let backup_data () =
  let timestamp = Unix.time () |> string_of_float in
  let backup_id = "backup_" ^ timestamp in
  let backup_content = export_data_to_string () in
  set_data_entry backup_id backup_content [ ("type", "backup"); ("timestamp", timestamp) ];
  backup_id

(** 恢复数据 *)
let restore_data backup_id =
  match get_data_entry backup_id with
  | Some backup_entry ->
      let data = parse_data_content backup_entry.content in
      Hashtbl.clear global_registry.entries;
      List.iter (fun (key, value) -> set_data_entry key value [ ("source", "restored") ]) data;
      true
  | None -> false

(** {1 初始化} *)

(* 自动初始化 *)
let () = initialize_registry ()
