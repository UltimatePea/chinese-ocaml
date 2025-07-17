(** 骆言内置字符串处理函数模块 - Chinese Programming Language Builtin String Functions *)

open Value_operations
open Builtin_error

(** 字符串连接函数 *)
let string_concat_function args =
  let s1 = expect_string (check_single_arg args "字符串连接") "字符串连接" in
  BuiltinFunctionValue (fun s2_args ->
    let s2 = expect_string (check_single_arg s2_args "字符串连接") "字符串连接" in
    StringValue (s1 ^ s2))

(** 字符串包含函数 *)
let string_contains_function args =
  let haystack = expect_string (check_single_arg args "字符串包含") "字符串包含" in
  BuiltinFunctionValue (fun needle_args ->
    let needle = expect_string (check_single_arg needle_args "字符串包含") "字符串包含" in
    BoolValue (String.contains_from haystack 0 (String.get needle 0)))

(** 字符串分割函数 *)
let string_split_function args =
  let str = expect_string (check_single_arg args "字符串分割") "字符串分割" in
  BuiltinFunctionValue (fun sep_args ->
    let sep = expect_string (check_single_arg sep_args "字符串分割") "字符串分割" in
    let parts = String.split_on_char (String.get sep 0) str in
    ListValue (List.map (fun s -> StringValue s) parts))

(** 字符串匹配函数 *)
let string_match_function args =
  let str = expect_string (check_single_arg args "字符串匹配") "字符串匹配" in
  BuiltinFunctionValue (fun pattern_args ->
    let pattern = expect_string (check_single_arg pattern_args "字符串匹配") "字符串匹配" in
    let regex = Str.regexp pattern in
    BoolValue (Str.string_match regex str 0))

(** 字符串长度函数 *)
let string_length_function args =
  let s = expect_string (check_single_arg args "字符串长度") "字符串长度" in
  IntValue (String.length s)

(** 字符串反转函数 *)
let string_reverse_function args =
  let s = expect_string (check_single_arg args "字符串反转") "字符串反转" in
  let chars = List.of_seq (String.to_seq s) in
  let reversed_chars = List.rev chars in
  StringValue (String.of_seq (List.to_seq reversed_chars))

(** 字符串函数表 *)
let string_functions = [
  ("字符串连接", BuiltinFunctionValue string_concat_function);
  ("字符串包含", BuiltinFunctionValue string_contains_function);
  ("字符串分割", BuiltinFunctionValue string_split_function);
  ("字符串匹配", BuiltinFunctionValue string_match_function);
  ("字符串长度", BuiltinFunctionValue string_length_function);
  ("字符串反转", BuiltinFunctionValue string_reverse_function);
]