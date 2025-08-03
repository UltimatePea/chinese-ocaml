(** 骆言内置字符串处理函数模块 - Chinese Programming Language Builtin String Functions *)

open Builtin_common
open Builtin_function_helpers

(** 字符串连接函数 *)
let string_concat_function = curried_double_string_builtin "字符串连接" ( ^ )

(** 字符串包含函数 - 支持多字符Unicode字符串 *)
let string_contains_function =
  curried_double_string_to_bool_builtin "字符串包含" (fun haystack needle ->
      if String.length needle = 0 then
        true  (* 空字符串包含在任何字符串中 *)
      else if String.length needle = 1 then
        (* 单字符：使用高效的内置函数 *)
        String.contains haystack (String.get needle 0)
      else
        (* 多字符：使用字符串匹配 *)
        try
          let _ = Str.search_forward (Str.regexp_string needle) haystack 0 in
          true
        with Not_found -> false)

(** 字符串分割函数 - 支持多字符Unicode分隔符 *)
let string_split_function =
  curried_string_to_list_builtin "字符串分割" (fun str sep ->
      if String.length sep = 0 then
        failwith "字符串分割函数：分隔符不能为空字符串"
      else if String.length sep = 1 then
        (* 单字符分隔符：使用高效的内置函数 *)
        String.split_on_char (String.get sep 0) str
      else
        (* 多字符分隔符：自定义实现支持Unicode字符 *)
        let str_len = String.length str in
        let sep_len = String.length sep in
        let parts = ref [] in
        let current_start = ref 0 in
        let i = ref 0 in
        
        while !i <= str_len - sep_len do
          if !i + sep_len <= str_len && String.sub str !i sep_len = sep then (
            (* 找到分隔符：添加当前部分 *)
            let part = String.sub str !current_start (!i - !current_start) in
            parts := part :: !parts;
            i := !i + sep_len;
            current_start := !i
          ) else (
            incr i
          )
        done;
        
        (* 添加最后一部分 *)
        if !current_start <= str_len then (
          let final_part = String.sub str !current_start (str_len - !current_start) in
          parts := final_part :: !parts
        );
        
        List.rev !parts)

(** 字符串匹配函数 - 改进的错误处理 *)
let string_match_function =
  curried_double_string_to_bool_builtin "字符串匹配" (fun str pattern ->
      try
        let regex = Str.regexp pattern in
        Str.string_match regex str 0
      with
      | Invalid_argument msg -> failwith ("无效的正则表达式模式: " ^ pattern ^ " - " ^ msg)
      | Failure msg -> failwith ("正则表达式解析错误: " ^ pattern ^ " - " ^ msg)
      | Not_found -> false)

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
