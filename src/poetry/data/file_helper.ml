(** 文件系统辅助工具模块 (兼容性重定向层)
 *
 * Issue #2015: 韵律工具和辅助模块整合
 * 注意：由于库依赖限制，data子库不能直接引用主库的Poetry_data_helpers
 * 此模块保持基本功能以避免循环依赖
 *
 * @author 骆言诗词编程团队 - Phase 15 超长文件重构
 * @author Whisky, PR Worker - 兼容性重定向层
 * @version 1.0
 * @since 2025-07-21
 * @since 2025-08-01 - 重定向到统一数据辅助模块
 *)

(** 注意：此模块为兼容性保留，主要功能已迁移到主库的Poetry_data_helpers模块 *)

(** {1 路径处理} *)

(** 构建文件路径 *)
let build_filepath filename =
  if Filename.is_relative filename then Filename.concat "data/poetry" filename else filename

(** {1 文件内容读取} *)

(** 读取文件内容 *)
let read_file_content filepath =
  let ic = open_in filepath in
  let content = really_input_string ic (in_channel_length ic) in
  close_in ic;
  content

(** {1 文件存在性检查} *)

(** 检查文件是否存在，如果不存在则发出警告 *)
let file_exists_or_warn filepath =
  if not (Sys.file_exists filepath) then (
    Printf.eprintf "警告: 韵律数据文件不存在: %s，返回空数据\n" filepath;
    flush stderr;
    false)
  else true

(** {1 安全文件操作} *)

(** 安全读取文件内容，包含错误处理 *)
let safe_read_file filepath =
  try if file_exists_or_warn filepath then Some (read_file_content filepath) else None with
  | Sys_error err ->
      Printf.eprintf "文件系统错误: %s\n" err;
      flush stderr;
      None
  | e ->
      Printf.eprintf "读取文件 %s 时发生未知错误: %s\n" filepath (Printexc.to_string e);
      flush stderr;
      None

(** {1 文件信息} *)

(** 获取文件大小 *)
let get_file_size filepath =
  try
    let stats = Unix.stat filepath in
    stats.st_size
  with Unix.Unix_error _ | Sys_error _ -> 0

(** 检查文件是否为普通文件 *)
let is_regular_file filepath =
  try
    let stats = Unix.stat filepath in
    stats.st_kind = Unix.S_REG
  with Unix.Unix_error _ | Sys_error _ -> false