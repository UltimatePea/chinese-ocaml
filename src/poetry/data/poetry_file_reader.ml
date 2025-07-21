(** 诗词数据文件读取器 - 专门负责文件系统操作

    提供文件读取和路径管理功能，处理IO相关的异常情况。 支持项目内数据文件的标准化访问。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 *)

exception FileReadError of string
(** 文件读取异常类型 *)

(** 读取文件全部内容 *)
let read_file_content filename =
  try
    let ic = open_in filename in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    content
  with
  | Sys_error msg -> raise (FileReadError ("无法读取文件: " ^ msg))
  | _ -> raise (FileReadError ("读取文件时发生未知错误: " ^ filename))

(** 获取数据文件的完整路径 *)
let get_data_path relative_path =
  let project_root = Sys.getcwd () in
  let data_dir = Filename.concat project_root "data" in
  Filename.concat data_dir relative_path
