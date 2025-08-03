(** 骆言内置字符串处理函数模块 - Chinese Programming Language Builtin String Functions *)

open Builtin_common

(** 字符串连接函数 - 柯里化实现 *)
let string_concat_function args =
  match args with
  | [StringValue s1] -> 
    BuiltinFunctionValue (function
      | [StringValue s2] -> StringValue (s1 ^ s2)
      | _ -> failwith "字符串连接函数的第二个参数必须是字符串")
  | [StringValue s1; StringValue s2] -> StringValue (s1 ^ s2)  (* 支持直接两参数调用 *)
  | _ -> failwith "字符串连接函数需要一个或两个字符串参数"

(** 字符串包含函数 - 柯里化实现 *)
let string_contains_function args =
  match args with
  | [StringValue haystack] ->
    BuiltinFunctionValue (function
      | [StringValue needle] ->
        if String.length needle = 0 then BoolValue true
        else
          (try
             let _ = Str.search_forward (Str.regexp_string needle) haystack 0 in
             BoolValue true
           with Not_found -> BoolValue false)
      | _ -> failwith "字符串包含函数的第二个参数必须是字符串")
  | [StringValue haystack; StringValue needle] ->  (* 支持直接两参数调用 *)
    if String.length needle = 0 then BoolValue true
    else
      (try
         let _ = Str.search_forward (Str.regexp_string needle) haystack 0 in
         BoolValue true
       with Not_found -> BoolValue false)
  | _ -> failwith "字符串包含函数需要一个或两个字符串参数"

(** 字符串分割函数 - 柯里化实现 *)
let string_split_function args =
  match args with
  | [StringValue str] ->
    BuiltinFunctionValue (function
      | [StringValue sep] ->
        if String.length sep = 0 then ListValue [StringValue str]
        else
          let split_result = String.split_on_char (String.get sep 0) str in
          ListValue (List.map (fun s -> StringValue s) split_result)
      | _ -> failwith "字符串分割函数的第二个参数必须是字符串")
  | [StringValue str; StringValue sep] ->  (* 支持直接两参数调用 *)
    if String.length sep = 0 then ListValue [StringValue str]
    else
      let split_result = String.split_on_char (String.get sep 0) str in
      ListValue (List.map (fun s -> StringValue s) split_result)
  | _ -> failwith "字符串分割函数需要一个或两个字符串参数"

(** 字符串匹配函数 - 柯里化实现 *)
let string_match_function args =
  match args with
  | [StringValue str] ->
    BuiltinFunctionValue (function
      | [StringValue pattern] ->
        (try
           let regex = Str.regexp pattern in
           BoolValue (Str.string_match regex str 0)
         with _ -> BoolValue false)
      | _ -> failwith "字符串匹配函数的第二个参数必须是字符串")
  | [StringValue str; StringValue pattern] ->  (* 支持直接两参数调用 *)
    (try
       let regex = Str.regexp pattern in
       BoolValue (Str.string_match regex str 0)
     with _ -> BoolValue false)
  | _ -> failwith "字符串匹配函数需要一个或两个字符串参数"

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

(** 字符串重复函数 *)
let string_repeat_function args =
  match args with
  | [IntValue n; StringValue s] ->
    if n <= 0 then StringValue ""
    else
      let rec repeat_str n acc =
        if n <= 0 then acc
        else repeat_str (n - 1) (acc ^ s)
      in
      StringValue (repeat_str n "")
  | _ -> failwith "字符串重复需要整数和字符串参数"

(** 字符串查找位置函数 - 柯里化实现 *)
let string_find_position_function args =
  match args with
  | [StringValue needle] ->
    BuiltinFunctionValue (function
      | [StringValue haystack] ->
        (try
           let pos = Str.search_forward (Str.regexp_string needle) haystack 0 in
           IntValue pos
         with Not_found -> IntValue (-1))
      | _ -> failwith "字符串查找位置函数的第二个参数必须是字符串")
  | [StringValue needle; StringValue haystack] ->  (* 支持直接两参数调用 *)
    (try
       let pos = Str.search_forward (Str.regexp_string needle) haystack 0 in
       IntValue pos
     with Not_found -> IntValue (-1))
  | _ -> failwith "字符串查找位置函数需要一个或两个字符串参数"

(** 字符串开头匹配函数 - 柯里化实现 *)
let string_starts_with_function args =
  match args with
  | [StringValue prefix] ->
    BuiltinFunctionValue (function
      | [StringValue str] ->
        let prefix_len = String.length prefix in
        let str_len = String.length str in
        if prefix_len > str_len then BoolValue false
        else BoolValue (String.sub str 0 prefix_len = prefix)
      | _ -> failwith "字符串开头匹配函数的第二个参数必须是字符串")
  | [StringValue prefix; StringValue str] ->  (* 支持直接两参数调用 *)
    let prefix_len = String.length prefix in
    let str_len = String.length str in
    if prefix_len > str_len then BoolValue false
    else BoolValue (String.sub str 0 prefix_len = prefix)
  | _ -> failwith "字符串开头匹配函数需要一个或两个字符串参数"

(** 字符串结尾匹配函数 - 柯里化实现 *)
let string_ends_with_function args =
  match args with
  | [StringValue suffix] ->
    BuiltinFunctionValue (function
      | [StringValue str] ->
        let suffix_len = String.length suffix in
        let str_len = String.length str in
        if suffix_len > str_len then BoolValue false
        else BoolValue (String.sub str (str_len - suffix_len) suffix_len = suffix)
      | _ -> failwith "字符串结尾匹配函数的第二个参数必须是字符串")
  | [StringValue suffix; StringValue str] ->  (* 支持直接两参数调用 *)
    let suffix_len = String.length suffix in
    let str_len = String.length str in
    if suffix_len > str_len then BoolValue false
    else BoolValue (String.sub str (str_len - suffix_len) suffix_len = suffix)
  | _ -> failwith "字符串结尾匹配函数需要一个或两个字符串参数"

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
