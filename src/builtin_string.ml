(** 骆言内置字符串处理函数模块 - Chinese Programming Language Builtin String Functions *)

open Builtin_common

(** 通用柯里化函数辅助工具 - 避免代码重复 *)
let make_curried_binary_function f error_msg =
  function
  | [arg1] -> BuiltinFunctionValue (function
      | [arg2] -> f arg1 arg2
      | _ -> failwith (error_msg ^ "的第二个参数类型错误"))
  | [arg1; arg2] -> f arg1 arg2  (* 支持直接两参数调用 *)
  | _ -> failwith (error_msg ^ "需要一个或两个参数")

(** 字符串连接核心逻辑 *)
let string_concat_core s1 s2 =
  match (s1, s2) with
  | (StringValue s1, StringValue s2) -> StringValue (s1 ^ s2)
  | _ -> failwith "字符串连接函数的参数必须都是字符串"

(** 字符串包含核心逻辑 *)
let string_contains_core haystack needle =
  match (haystack, needle) with
  | (StringValue haystack, StringValue needle) ->
    if String.length needle = 0 then BoolValue true
    else
      (try
         let _ = Str.search_forward (Str.regexp_string needle) haystack 0 in
         BoolValue true
       with Not_found -> BoolValue false)
  | _ -> failwith "字符串包含函数的参数必须都是字符串"

(** 字符串分割核心逻辑 - 修复边界检查问题 *)
let string_split_core str sep =
  match (str, sep) with
  | (StringValue str, StringValue sep) ->
    if String.length sep = 0 then 
      ListValue [StringValue str]
    else if String.length sep = 1 then
      let split_result = String.split_on_char (String.get sep 0) str in
      ListValue (List.map (fun s -> StringValue s) split_result)
    else
      failwith "字符串分割目前仅支持单字符分隔符"
  | _ -> failwith "字符串分割函数的参数必须都是字符串"

(** 字符串匹配核心逻辑 - 修复过度广泛的异常处理 *)
let string_match_core str pattern =
  match (str, pattern) with
  | (StringValue str, StringValue pattern) ->
    (try
       let regex = Str.regexp pattern in
       BoolValue (Str.string_match regex str 0)
     with 
     | Invalid_argument msg -> failwith ("无效的正则表达式模式: " ^ pattern ^ " - " ^ msg)
     | _ -> BoolValue false)  (* 其他未预期错误返回false *)
  | _ -> failwith "字符串匹配函数的参数必须都是字符串"

(** 字符串查找位置核心逻辑 *)
let string_find_position_core needle haystack =
  match (needle, haystack) with
  | (StringValue needle, StringValue haystack) ->
    (try
       let pos = Str.search_forward (Str.regexp_string needle) haystack 0 in
       IntValue pos
     with Not_found -> IntValue (-1))
  | _ -> failwith "字符串查找位置函数的参数必须都是字符串"

(** 字符串开头匹配核心逻辑 *)
let string_starts_with_core prefix str =
  match (prefix, str) with
  | (StringValue prefix, StringValue str) ->
    let prefix_len = String.length prefix in
    let str_len = String.length str in
    if prefix_len > str_len then BoolValue false
    else BoolValue (String.sub str 0 prefix_len = prefix)
  | _ -> failwith "字符串开头匹配函数的参数必须都是字符串"

(** 字符串结尾匹配核心逻辑 *)
let string_ends_with_core suffix str =
  match (suffix, str) with
  | (StringValue suffix, StringValue str) ->
    let suffix_len = String.length suffix in
    let str_len = String.length str in
    if suffix_len > str_len then BoolValue false
    else BoolValue (String.sub str (str_len - suffix_len) suffix_len = suffix)
  | _ -> failwith "字符串结尾匹配函数的参数必须都是字符串"

(** 字符串连接函数 - 柯里化实现 *)
let string_concat_function = make_curried_binary_function string_concat_core "字符串连接函数"

(** 字符串包含函数 - 柯里化实现 *)
let string_contains_function = make_curried_binary_function string_contains_core "字符串包含函数"

(** 字符串分割函数 - 柯里化实现 *)
let string_split_function = make_curried_binary_function string_split_core "字符串分割函数"

(** 字符串匹配函数 - 柯里化实现 *)
let string_match_function = make_curried_binary_function string_match_core "字符串匹配函数"

(** 字符串长度函数 - 使用公共工具函数 *)
let string_length_function args =
  let s = Builtin_shared_utils.validate_single_param expect_string args "字符串长度" in
  IntValue (String.length s)

(** 字符串反转函数 - 使用公共工具函数 *)
let string_reverse_function args =
  let s = Builtin_shared_utils.validate_single_param expect_string args "字符串反转" in
  StringValue (Builtin_shared_utils.reverse_string s)

(** 字符串为空检测函数 *)
let string_is_empty_function args =
  let s = Builtin_shared_utils.validate_single_param expect_string args "字符串为空" in
  BoolValue (String.length s = 0)

(** 字符串重复函数 - 修复性能问题，从O(n²)改为O(n) *)
let string_repeat_function args =
  match args with
  | [IntValue n; StringValue s] ->
    if n <= 0 then StringValue ""
    else if n = 1 then StringValue s
    else
      (* 使用 Buffer 避免 O(n²) 字符串连接复杂度 *)
      let buffer = Buffer.create (n * String.length s) in
      for _ = 1 to n do
        Buffer.add_string buffer s
      done;
      StringValue (Buffer.contents buffer)
  | _ -> failwith "字符串重复需要整数和字符串参数"

(** 字符串查找位置函数 - 柯里化实现 *)
let string_find_position_function = make_curried_binary_function string_find_position_core "字符串查找位置函数"

(** 字符串开头匹配函数 - 柯里化实现 *)
let string_starts_with_function = make_curried_binary_function string_starts_with_core "字符串开头匹配函数"

(** 字符串结尾匹配函数 - 柯里化实现 *)
let string_ends_with_function = make_curried_binary_function string_ends_with_core "字符串结尾匹配函数"

(** 字符串截取函数 *)
let string_substring_function args =
  match args with
  | [IntValue start; IntValue len; StringValue str] ->
    let str_len = String.length str in
    if start < 0 || start >= str_len || len <= 0 then
      StringValue ""
    else
      let actual_len = min len (str_len - start) in
      StringValue (String.sub str start actual_len)
  | _ -> failwith "字符串截取需要两个整数和一个字符串参数"

(** 字符串左截取函数 *)
let string_left_function args =
  match args with
  | [IntValue len; StringValue str] ->
    let str_len = String.length str in
    if len <= 0 then StringValue ""
    else
      let actual_len = min len str_len in
      StringValue (String.sub str 0 actual_len)
  | _ -> failwith "字符串左截取需要整数和字符串参数"

(** 字符串右截取函数 *)
let string_right_function args =
  match args with
  | [IntValue len; StringValue str] ->
    let str_len = String.length str in
    if len <= 0 then StringValue ""
    else
      let actual_len = min len str_len in
      let start = str_len - actual_len in
      StringValue (String.sub str start actual_len)
  | _ -> failwith "字符串右截取需要整数和字符串参数"

(** 字符串去除空格函数 *)
let string_trim_function args =
  let s = Builtin_shared_utils.validate_single_param expect_string args "字符串去除空格" in
  StringValue (String.trim s)

(** 字符串去除左空格函数 *)
let string_trim_left_function args =
  let s = Builtin_shared_utils.validate_single_param expect_string args "字符串去除左空格" in
  let len = String.length s in
  let rec find_start i =
    if i >= len then i
    else if s.[i] = ' ' || s.[i] = '\t' || s.[i] = '\n' || s.[i] = '\r' then
      find_start (i + 1)
    else i
  in
  let start = find_start 0 in
  if start >= len then StringValue ""
  else StringValue (String.sub s start (len - start))

(** 字符串去除右空格函数 *)
let string_trim_right_function args =
  let s = Builtin_shared_utils.validate_single_param expect_string args "字符串去除右空格" in
  let len = String.length s in
  let rec find_end i =
    if i < 0 then i
    else if s.[i] = ' ' || s.[i] = '\t' || s.[i] = '\n' || s.[i] = '\r' then
      find_end (i - 1)
    else i
  in
  let end_pos = find_end (len - 1) in
  if end_pos < 0 then StringValue ""
  else StringValue (String.sub s 0 (end_pos + 1))

(** 字符串转大写函数 *)
let string_uppercase_function args =
  let s = Builtin_shared_utils.validate_single_param expect_string args "字符串转大写" in
  StringValue (String.uppercase_ascii s)

(** 字符串转小写函数 *)
let string_lowercase_function args =
  let s = Builtin_shared_utils.validate_single_param expect_string args "字符串转小写" in
  StringValue (String.lowercase_ascii s)

(** 取字符函数 *)
let string_get_char_function args =
  match args with
  | [IntValue index; StringValue str] ->
    let len = String.length str in
    if index < 0 || index >= len then
      failwith "字符索引超出范围"
    else
      StringValue (String.make 1 str.[index])
  | _ -> failwith "取字符需要整数和字符串参数"

(** 字符串函数表 *)
let string_functions =
  [
    ("字符串连接", BuiltinFunctionValue string_concat_function);
    ("字符串包含", BuiltinFunctionValue string_contains_function);
    ("字符串分割", BuiltinFunctionValue string_split_function);
    ("字符串匹配", BuiltinFunctionValue string_match_function);
    ("字符串长度", BuiltinFunctionValue string_length_function);
    ("字符串反转", BuiltinFunctionValue string_reverse_function);
    ("字符串为空", BuiltinFunctionValue string_is_empty_function);
    ("字符串重复", BuiltinFunctionValue string_repeat_function);
    ("字符串查找位置", BuiltinFunctionValue string_find_position_function);
    ("字符串开头匹配", BuiltinFunctionValue string_starts_with_function);
    ("字符串结尾匹配", BuiltinFunctionValue string_ends_with_function);
    ("字符串截取", BuiltinFunctionValue string_substring_function);
    ("字符串左截取", BuiltinFunctionValue string_left_function);
    ("字符串右截取", BuiltinFunctionValue string_right_function);
    ("字符串去除空格", BuiltinFunctionValue string_trim_function);
    ("字符串去除左空格", BuiltinFunctionValue string_trim_left_function);
    ("字符串去除右空格", BuiltinFunctionValue string_trim_right_function);
    ("字符串转大写", BuiltinFunctionValue string_uppercase_function);
    ("字符串转小写", BuiltinFunctionValue string_lowercase_function);
    ("取字符", BuiltinFunctionValue string_get_char_function);
  ]
