(** 骆言内置工具函数模块 - Chinese Programming Language Builtin Utility Functions *)

open Value_operations
open Builtin_error
open String_processing_utils

(** 过滤.ly文件函数 *)
let filter_ly_files_function args =
  let files = expect_list (check_single_arg args "过滤ly文件") "过滤ly文件" in
  let filtered = List.filter (fun file ->
    match file with
    | StringValue filename ->
        String.length filename >= 3 &&
        String.sub filename (String.length filename - 3) 3 = ".ly"
    | _ -> false
  ) files in
  ListValue filtered

(** 移除井号注释函数 *)
let remove_hash_comment_function args =
  let line = expect_string (check_single_arg args "移除井号注释") "移除井号注释" in
  StringValue (remove_hash_comment line)

(** 移除双斜杠注释函数 *)
let remove_double_slash_comment_function args =
  let line = expect_string (check_single_arg args "移除双斜杠注释") "移除双斜杠注释" in
  StringValue (remove_double_slash_comment line)

(** 移除块注释函数 *)
let remove_block_comments_function args =
  let line = expect_string (check_single_arg args "移除块注释") "移除块注释" in
  StringValue (remove_block_comments line)

(** 移除骆言字符串函数 *)
let remove_luoyan_strings_function args =
  let line = expect_string (check_single_arg args "移除骆言字符串") "移除骆言字符串" in
  StringValue (remove_luoyan_strings line)

(** 移除英文字符串函数 *)
let remove_english_strings_function args =
  let line = expect_string (check_single_arg args "移除英文字符串") "移除英文字符串" in
  StringValue (remove_english_strings line)

(** 工具函数表 *)
let utility_functions = [
  ("过滤ly文件", BuiltinFunctionValue filter_ly_files_function);
  ("移除井号注释", BuiltinFunctionValue remove_hash_comment_function);
  ("移除双斜杠注释", BuiltinFunctionValue remove_double_slash_comment_function);
  ("移除块注释", BuiltinFunctionValue remove_block_comments_function);
  ("移除骆言字符串", BuiltinFunctionValue remove_luoyan_strings_function);
  ("移除英文字符串", BuiltinFunctionValue remove_english_strings_function);
]