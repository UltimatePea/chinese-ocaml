(** 文件系统辅助工具模块 - 诗词数据文件操作

    从原 poetry_data_loader.ml 中提取的文件系统操作功能，提供统一的文件处理接口。

    @author 骆言诗词编程团队 - Phase 15 超长文件重构
    @version 1.0
    @since 2025-07-21 *)

(** {1 路径处理} *)

(** 构建文件路径

    如果提供的是相对路径，则在默认诗词数据目录下构建完整路径。

    @param filename 文件名或路径
    @return 完整的文件路径 *)
let build_filepath filename =
  if Filename.is_relative filename then Filename.concat "data/poetry" filename else filename

(** {1 文件内容读取} *)

(** 读取文件内容

    安全地读取文件全部内容，自动处理文件关闭。

    @param filepath 文件路径
    @return 文件内容字符串
    @raise Sys_error 如果文件不存在或读取失败 *)
let read_file_content filepath =
  let ic = open_in filepath in
  let content = really_input_string ic (in_channel_length ic) in
  close_in ic;
  content

(** {1 文件存在性检查} *)

(** 检查文件是否存在，如果不存在则发出警告

    @param filepath 文件路径
    @return 如果文件存在返回true，否则返回false并输出警告 *)
let file_exists_or_warn filepath =
  if not (Sys.file_exists filepath) then (
    Printf.eprintf "警告: 韵律数据文件不存在: %s，返回空数据\n" filepath;
    flush stderr;
    false)
  else true

(** {1 安全文件操作} *)

(** 安全读取文件内容，包含错误处理

    如果文件不存在或读取失败，返回None而不是抛出异常。

    @param filepath 文件路径
    @return 成功时返回Some content，失败时返回None *)
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

(** 获取文件大小

    @param filepath 文件路径
    @return 文件大小（字节数），如果文件不存在返回0 *)
let get_file_size filepath =
  try
    let stats = Unix.stat filepath in
    stats.st_size
  with Unix.Unix_error _ | Sys_error _ -> 0

(** 检查文件是否为普通文件

    @param filepath 文件路径
    @return 如果是普通文件返回true，否则返回false *)
let is_regular_file filepath =
  try
    let stats = Unix.stat filepath in
    stats.st_kind = Unix.S_REG
  with Unix.Unix_error _ | Sys_error _ -> false
