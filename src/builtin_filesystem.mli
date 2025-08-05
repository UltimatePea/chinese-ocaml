(** 骆言内置文件系统函数模块接口 - Chinese Programming Language Builtin Filesystem Functions Interface *)
(** Author: Whisky, PR Worker *)

open Value_operations

(** 异常处理辅助函数 *)
val handle_filesystem_error : string -> string -> (unit -> 'a) -> 'a

(** 路径处理辅助函数 *)
val normalize_path : string -> string
val join_paths : string -> string -> string

(** 基础文件操作函数 *)
val read_file_function : runtime_value list -> runtime_value
val write_file_function : runtime_value list -> runtime_value
val append_file_function : runtime_value list -> runtime_value
val copy_file_function : runtime_value list -> runtime_value
val move_file_function : runtime_value list -> runtime_value
val delete_file_function : runtime_value list -> runtime_value
val rename_file_function : runtime_value list -> runtime_value

(** 二进制文件操作函数 *)
val read_binary_file_function : runtime_value list -> runtime_value
val write_binary_file_function : runtime_value list -> runtime_value

(** 目录操作函数 *)
val create_directory_function : runtime_value list -> runtime_value
val create_directory_recursive_function : runtime_value list -> runtime_value
val delete_directory_function : runtime_value list -> runtime_value
val delete_directory_recursive_function : runtime_value list -> runtime_value
val list_directory_function : runtime_value list -> runtime_value
val traverse_directory_function : runtime_value list -> runtime_value
val directory_exists_function : runtime_value list -> runtime_value

(** 路径处理函数 *)
val normalize_path_function : runtime_value list -> runtime_value
val join_path_function : runtime_value list -> runtime_value
val split_path_function : runtime_value list -> runtime_value
val path_exists_function : runtime_value list -> runtime_value
val absolute_path_function : runtime_value list -> runtime_value
val relative_path_function : runtime_value list -> runtime_value
val get_extension_function : runtime_value list -> runtime_value
val remove_extension_function : runtime_value list -> runtime_value
val get_filename_function : runtime_value list -> runtime_value
val get_dirname_function : runtime_value list -> runtime_value

(** 文件属性函数 *)
val file_exists_function : runtime_value list -> runtime_value
val file_size_function : runtime_value list -> runtime_value
val file_mtime_function : runtime_value list -> runtime_value
val file_atime_function : runtime_value list -> runtime_value
val file_ctime_function : runtime_value list -> runtime_value
val is_file_function : runtime_value list -> runtime_value
val is_directory_function : runtime_value list -> runtime_value
val is_symlink_function : runtime_value list -> runtime_value

(** 权限管理函数 *)
val check_readable_function : runtime_value list -> runtime_value
val check_writable_function : runtime_value list -> runtime_value
val check_executable_function : runtime_value list -> runtime_value
val set_permissions_function : runtime_value list -> runtime_value
val get_permissions_function : runtime_value list -> runtime_value

(** 哈希计算函数 *)
val compute_md5_function : runtime_value list -> runtime_value
val compute_sha1_function : runtime_value list -> runtime_value
val compute_sha256_function : runtime_value list -> runtime_value

(** 工作目录函数 *)
val get_current_directory_function : runtime_value list -> runtime_value
val change_directory_function : runtime_value list -> runtime_value
val get_home_directory_function : runtime_value list -> runtime_value
val get_temp_directory_function : runtime_value list -> runtime_value

(** 路径常量函数 *)
val get_path_separator_function : runtime_value list -> runtime_value

(** 文件系统函数表 *)
val filesystem_functions : (string * runtime_value) list