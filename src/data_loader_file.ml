(* 数据加载器文件读取模块
   
   负责文件系统操作，包括路径处理和文件内容读取。
   提供统一的文件访问接口。 *)

open Data_loader_types

(** 读取文件内容 *)
let read_file_content filename =
  try
    let ic = open_in filename in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    Success content
  with
  | Sys_error _ -> Error (FileNotFound filename)
  | e -> Error (ParseError (filename, Printexc.to_string e))

(** 获取数据文件路径 *)
let get_data_path relative_path =
  (* 数据文件位于项目根目录的 data/ 文件夹中 *)
  let project_root = Sys.getcwd () in
  Filename.concat (Filename.concat project_root "data") relative_path

(** 检查文件是否存在 *)
let file_exists path =
  try
    ignore (Unix.stat path);
    true
  with Unix.Unix_error (Unix.ENOENT, _, _) -> false

(** 获取文件修改时间 *)
let get_file_mtime path =
  try
    let stat = Unix.stat path in
    Some stat.st_mtime
  with Unix.Unix_error _ -> None
