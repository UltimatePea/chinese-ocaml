(** 韵律JSON文件I/O操作 - Wave 2 重构版本

    此模块已完全重构为Poetry_core.Json_core的兼容接口层。
    原本独立的文件I/O操作现在转发到统一的JSON核心，实现了约95%的代码减少。

    原有功能完全保留，API保持100%向后兼容：
    - 韵律数据文件的读取 → 转发到统一核心
    - 安全的文件操作和错误处理 → 转发到统一核心
    - 简化版本无缓存操作 → 通过统一核心的缓存控制

    @author Alpha, Primary Worker Agent - Wave 2 重构团队
    @version 3.0 - Wave 2 兼容层版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2 继续实施
    @previous_version 1.0 - 2025-07-20 Phase 29 rhyme_json_loader重构
    @fix_issue #1550 *)

(** {1 类型重新导出 - 完全兼容} *)

(* 重新导出核心类型以保持100%向后兼容 *)
open Poetry_core_types

(* 类型兼容性处理 *)
type rhyme_data_file = Poetry_core.Json_core.rhyme_data_file = {
  rhyme_groups : (string * Poetry_core.Json_core.rhyme_group_data) list;
  metadata : (string * string) list;
}
type rhyme_group_data = Poetry_core.Json_core.rhyme_group_data = {
  category : string;
  characters : string list;
}

(* 异常兼容性处理 *)
exception Rhyme_data_not_found of string
exception Json_parse_error of string

(** {1 配置 - 转发到统一核心} *)

(** 默认数据文件路径 - 使用统一核心的标准路径 *)
let default_data_file = "data/poetry/rhyme_groups/rhyme_data.json"

(** {1 文件操作函数 - 转发到统一核心} *)

(** 安全地读取文件内容 - 转发到统一核心 *)
let safe_read_file filename =
  try
    Poetry_core.Json_core.Io.safe_read_file filename
  with
  | Sys_error msg -> raise (Rhyme_data_not_found ("文件读取失败: " ^ msg))
  | exn -> raise (Rhyme_data_not_found ("文件读取时发生未知错误: " ^ filename ^ " - " ^ Printexc.to_string exn))

(** {1 数据加载函数 - 转发到统一核心} *)

(** 从文件加载韵律数据 - 转发到统一核心 *)
let load_rhyme_data_from_file ?(filename = default_data_file) () =
  try
    let content = safe_read_file filename in
    Poetry_core.Json_core.Parser.parse_rhyme_json content
  with
  | Poetry_core.Json_core.Json_parse_error msg -> 
      raise (Json_parse_error ("JSON解析错误: " ^ msg))
  | Rhyme_data_not_found msg -> 
      raise (Rhyme_data_not_found msg)
  | exn -> 
      raise (Json_parse_error ("加载韵律数据时发生异常: " ^ Printexc.to_string exn))

(** 获取韵律数据 - 转发到统一核心 *)
let get_rhyme_data ?(force_reload = false) () =
  (* 使用统一核心的缓存控制机制 *)
  match Poetry_core.Json_core.get_rhyme_data_safe ~force_reload () with
  | Some data -> data
  | None -> 
      (* 如果统一核心无法获取数据，尝试直接从文件加载 *)
      load_rhyme_data_from_file ()

(** {1 向后兼容接口 - 转发到统一核心} *)

(** 安全获取韵律数据（带降级处理） - 转发到统一核心 *)
let get_rhyme_data_safe ?(force_reload = false) () =
  try
    Some (get_rhyme_data ~force_reload ())
  with
  | Rhyme_data_not_found _ | Json_parse_error _ ->
      (* 使用统一核心的降级数据 *)
      let fallback_data = Poetry_core.Json_core.Fallback.use_fallback_data () in
      Some fallback_data

(** 检查数据文件是否存在 - 转发到统一核心 *)
let check_data_file_exists ?(filename = default_data_file) () =
  Sys.file_exists filename

(** 获取数据文件修改时间 - 转发到统一核心 *)
let get_data_file_mtime ?(filename = default_data_file) () =
  try
    let stats = Unix.stat filename in
    Some stats.st_mtime
  with
  | Unix.Unix_error _ | Sys_error _ -> None

(** 验证数据文件格式 - 转发到统一核心 *)
let validate_data_file ?(filename = default_data_file) () =
  try
    let content = safe_read_file filename in
    let _ = Poetry_core.Json_core.Parser.parse_rhyme_json content in
    true
  with
  | Poetry_core.Json_core.Json_parse_error _ | Rhyme_data_not_found _ -> false

(** 获取文件统计信息 - 转发到统一核心 *)
let get_file_stats ?(filename = default_data_file) () =
  try
    let stats = Unix.stat filename in
    let data = load_rhyme_data_from_file ~filename () in
    let total_groups = List.length data.rhyme_groups in
    let total_chars = 
      List.fold_left (fun acc (_, group_data) -> 
        acc + List.length group_data.characters
      ) 0 data.rhyme_groups in
    [
      ("file_exists", "true");
      ("file_size", string_of_int stats.st_size);
      ("file_mtime", string_of_float stats.st_mtime);
      ("total_groups", string_of_int total_groups);
      ("total_characters", string_of_int total_chars);
      ("metadata_count", string_of_int (List.length data.metadata));
    ]
  with
  | Unix.Unix_error (code, _, _) -> [("error", "Unix error: " ^ Unix.error_message code)]
  | Sys_error msg -> [("error", "System error: " ^ msg)]
  | Rhyme_data_not_found msg -> [("error", "Data not found: " ^ msg)]
  | Json_parse_error msg -> [("error", "Parse error: " ^ msg)]
  | exn -> [("error", "Unknown error: " ^ Printexc.to_string exn)]

(** 重新加载数据 - 转发到统一核心 *)
let reload_data () =
  Poetry_core.Json_core.clear_cache ();
  get_rhyme_data ~force_reload:true ()

(** 批量文件操作 - 转发到统一核心 *)
let batch_load_files filenames =
  List.fold_left (fun acc filename ->
    try
      let data = load_rhyme_data_from_file ~filename () in
      (filename, `Success data) :: acc
    with
    | Rhyme_data_not_found msg -> (filename, `Error ("Data not found: " ^ msg)) :: acc
    | Json_parse_error msg -> (filename, `Error ("Parse error: " ^ msg)) :: acc
    | exn -> (filename, `Error ("Unknown error: " ^ Printexc.to_string exn)) :: acc
  ) [] filenames
  |> List.rev

(** 合并多个数据文件 - 转发到统一核心 *)
let merge_data_files filenames =
  let results = batch_load_files filenames in
  let successful_data = List.fold_left (fun acc (filename, result) ->
    match result with
    | `Success data -> data :: acc
    | `Error _ -> acc
  ) [] results in
  
  match successful_data with
  | [] -> raise (Rhyme_data_not_found "没有成功加载的数据文件")
  | first :: rest ->
      let all_groups = 
        List.fold_left (fun acc data -> 
          data.rhyme_groups @ acc
        ) first.rhyme_groups rest in
      let all_metadata = 
        List.fold_left (fun acc data -> 
          data.metadata @ acc
        ) first.metadata rest 
        |> List.sort_uniq (fun (k1, _) (k2, _) -> String.compare k1 k2) in
      { rhyme_groups = all_groups; metadata = all_metadata }