(* 数据加载器文件读取模块接口 *)

open Data_loader_types

(** 读取文件内容 *)
val read_file_content : string -> string data_result

(** 获取数据文件路径 *)
val get_data_path : string -> string

(** 检查文件是否存在 *)
val file_exists : string -> bool

(** 获取文件修改时间 *)
val get_file_mtime : string -> float option