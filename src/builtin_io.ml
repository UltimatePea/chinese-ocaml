(** 骆言内置I/O函数模块 - Chinese Programming Language Builtin I/O Functions *)

open Value_operations
open Builtin_error

(** 打印函数 *)
let print_function args =
  match args with
  | [StringValue s] ->
      Logger.print_user_output s;
      UnitValue
  | [value] ->
      Logger.print_user_output (value_to_string value);
      UnitValue
  | _ -> runtime_error "打印函数期望一个参数"

(** 读取函数 *)
let read_function args =
  match args with
  | [UnitValue] | [] -> StringValue (read_line ())
  | _ -> runtime_error "读取函数不需要参数"

(** 读取文件函数 *)
let read_file_function args =
  let filename = expect_string (check_single_arg args "读取文件") "读取文件" in
  handle_file_error "读取" filename (fun () ->
    let ic = open_in filename in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    StringValue content)

(** 写入文件函数 *)
let write_file_function args =
  let filename = expect_string (check_single_arg args "写入文件") "写入文件" in
  BuiltinFunctionValue (fun content_args ->
    let content = expect_string (check_single_arg content_args "写入文件内容") "写入文件内容" in
    handle_file_error "写入" filename (fun () ->
      let oc = open_out filename in
      output_string oc content;
      close_out oc;
      UnitValue))

(** 文件存在检查函数 *)
let file_exists_function args =
  let filename = expect_string (check_single_arg args "文件存在") "文件存在" in
  BoolValue (Sys.file_exists filename)

(** 列出目录函数 *)
let list_directory_function args =
  let dirname = expect_string (check_single_arg args "列出目录") "列出目录" in
  handle_file_error "列出" dirname (fun () ->
    let files = Sys.readdir dirname in
    let file_list = Array.to_list files |> List.map (fun f -> StringValue f) in
    ListValue file_list)

(** I/O函数表 *)
let io_functions = [
  ("打印", BuiltinFunctionValue print_function);
  ("读取", BuiltinFunctionValue read_function);
  ("读取文件", BuiltinFunctionValue read_file_function);
  ("写入文件", BuiltinFunctionValue write_file_function);
  ("文件存在", BuiltinFunctionValue file_exists_function);
  ("列出目录", BuiltinFunctionValue list_directory_function);
]