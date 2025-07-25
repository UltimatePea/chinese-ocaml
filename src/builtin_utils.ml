(** 骆言内置工具函数模块 - Chinese Programming Language Builtin Utility Functions *)

open Value_operations
open Builtin_error
open Builtin_function_helpers
open String_processing_utils
open Constants

(** 过滤.ly文件函数 *)
let filter_ly_files_function args =
  let files = expect_list (check_single_arg args "过滤ly文件") "过滤ly文件" in
  let filtered =
    List.filter
      (fun file ->
        match file with
        | StringValue filename ->
            String.length filename >= 3
            && String.sub filename (String.length filename - 3) 3 = RuntimeFunctions.ly_extension
        | _ -> false)
      files
  in
  ListValue filtered

(** 移除井号注释函数 *)
let remove_hash_comment_function = single_string_builtin "移除井号注释" remove_hash_comment

(** 移除双斜杠注释函数 *)
let remove_double_slash_comment_function =
  single_string_builtin "移除双斜杠注释" remove_double_slash_comment

(** 移除块注释函数 *)
let remove_block_comments_function = single_string_builtin "移除块注释" remove_block_comments

(** 移除骆言字符串函数 *)
let remove_luoyan_strings_function = single_string_builtin "移除骆言字符串" remove_luoyan_strings

(** 移除英文字符串函数 *)
let remove_english_strings_function = single_string_builtin "移除英文字符串" remove_english_strings

(** 工具函数表 *)
let utility_functions =
  [
    ("过滤ly文件", BuiltinFunctionValue filter_ly_files_function);
    ("移除井号注释", BuiltinFunctionValue remove_hash_comment_function);
    ("移除双斜杠注释", BuiltinFunctionValue remove_double_slash_comment_function);
    ("移除块注释", BuiltinFunctionValue remove_block_comments_function);
    ("移除骆言字符串", BuiltinFunctionValue remove_luoyan_strings_function);
    ("移除英文字符串", BuiltinFunctionValue remove_english_strings_function);
  ]
