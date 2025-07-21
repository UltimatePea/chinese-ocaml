(* 数据加载器文件读取模块接口 *)

open Data_loader_types

val read_file_content : string -> string data_result
(** 读取文件内容 *)

val get_data_path : string -> string
(** 获取数据文件路径 *)

val file_exists : string -> bool
(** 检查文件是否存在 *)

val get_file_mtime : string -> float option
(** 获取文件修改时间 *)
