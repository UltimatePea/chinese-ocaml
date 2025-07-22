(** 文件系统辅助工具模块接口 - 诗词数据文件操作

    @author 骆言诗词编程团队 - Phase 15 超长文件重构
    @version 1.0
    @since 2025-07-21 *)

(** {1 路径处理} *)

val build_filepath : string -> string
(** 构建文件路径

    如果提供的是相对路径，则在默认诗词数据目录下构建完整路径。

    @param filename 文件名或路径
    @return 完整的文件路径 *)

(** {1 文件内容读取} *)

val read_file_content : string -> string
(** 读取文件内容

    安全地读取文件全部内容，自动处理文件关闭。

    @param filepath 文件路径
    @return 文件内容字符串
    @raise Sys_error 如果文件不存在或读取失败 *)

(** {1 文件存在性检查} *)

val file_exists_or_warn : string -> bool
(** 检查文件是否存在，如果不存在则发出警告

    @param filepath 文件路径
    @return 如果文件存在返回true，否则返回false并输出警告 *)

(** {1 安全文件操作} *)

val safe_read_file : string -> string option
(** 安全读取文件内容，包含错误处理

    如果文件不存在或读取失败，返回None而不是抛出异常。

    @param filepath 文件路径
    @return 成功时返回Some content，失败时返回None *)

(** {1 文件信息} *)

val get_file_size : string -> int
(** 获取文件大小

    @param filepath 文件路径
    @return 文件大小（字节数），如果文件不存在返回0 *)

val is_regular_file : string -> bool
(** 检查文件是否为普通文件

    @param filepath 文件路径
    @return 如果是普通文件返回true，否则返回false *)
