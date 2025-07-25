(** 骆言内置字符串处理函数模块 - Chinese Programming Language Builtin String Functions *)

open Builtin_common
open Builtin_function_helpers

(** 字符串连接函数 *)
let string_concat_function = curried_double_string_builtin "字符串连接" ( ^ )

(** 字符串包含函数 *)
let string_contains_function =
  curried_double_string_to_bool_builtin "字符串包含" (fun haystack needle ->
      String.contains_from haystack 0 (String.get needle 0))

(** 字符串分割函数 *)
let string_split_function =
  curried_string_to_list_builtin "字符串分割" (fun str sep ->
      String.split_on_char (String.get sep 0) str)

(** 字符串匹配函数 *)
let string_match_function =
  curried_double_string_to_bool_builtin "字符串匹配" (fun str pattern ->
      let regex = Str.regexp pattern in
      Str.string_match regex str 0)

(** 字符串长度函数 - 使用公共工具函数 *)
let string_length_function args =
  let s = Builtin_shared_utils.validate_single_param expect_string args "字符串长度" in
  IntValue (String.length s)

(** 字符串反转函数 - 使用公共工具函数 *)
let string_reverse_function args =
  let s = Builtin_shared_utils.validate_single_param expect_string args "字符串反转" in
  StringValue (Builtin_shared_utils.reverse_string s)

(** 字符串函数表 *)
let string_functions =
  [
    ("字符串连接", BuiltinFunctionValue string_concat_function);
    ("字符串包含", BuiltinFunctionValue string_contains_function);
    ("字符串分割", BuiltinFunctionValue string_split_function);
    ("字符串匹配", BuiltinFunctionValue string_match_function);
    ("字符串长度", BuiltinFunctionValue string_length_function);
    ("字符串反转", BuiltinFunctionValue string_reverse_function);
  ]
