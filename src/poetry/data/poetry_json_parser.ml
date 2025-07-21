(** 诗词数据JSON解析器 - 专门负责JSON数据解析

    提供简单但有效的JSON解析功能，专门用于诗词数据文件的解析。 支持字符串数组解析和字段提取操作。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 *)

(** 去除空白字符 *)
let trim_whitespace s =
  let len = String.length s in
  let rec start i =
    if i >= len then len else match s.[i] with ' ' | '\t' | '\n' | '\r' -> start (i + 1) | _ -> i
  in
  let rec finish i =
    if i < 0 then -1 else match s.[i] with ' ' | '\t' | '\n' | '\r' -> finish (i - 1) | _ -> i
  in
  let s_start = start 0 in
  let s_end = finish (len - 1) in
  if s_start > s_end then "" else String.sub s s_start (s_end - s_start + 1)

(** 解析字符串数组 *)
let parse_string_array content =
  try
    let trimmed = trim_whitespace content in
    if String.length trimmed < 2 then []
    else if trimmed.[0] <> '[' || trimmed.[String.length trimmed - 1] <> ']' then []
    else
      let inner = String.sub trimmed 1 (String.length trimmed - 2) in
      let items = String.split_on_char ',' inner in
      List.map
        (fun item ->
          let cleaned = trim_whitespace item in
          if
            String.length cleaned >= 2
            && cleaned.[0] = '"'
            && cleaned.[String.length cleaned - 1] = '"'
          then String.sub cleaned 1 (String.length cleaned - 2)
          else cleaned)
        items
      |> List.filter (fun s -> String.length s > 0)
  with _ -> []

(** 简单提取字段值 - 用于提取JSON对象中的字段 *)
let extract_field content field_name =
  try
    let field_pattern = "\"" ^ field_name ^ "\"" in
    let field_start =
      let rec search pos =
        if pos + String.length field_pattern > String.length content then raise Not_found
        else if String.sub content pos (String.length field_pattern) = field_pattern then pos
        else search (pos + 1)
      in
      search 0
    in
    let colon_pos = String.index_from content field_start ':' in
    let value_start = colon_pos + 1 in

    (* 寻找值的开始 *)
    let rec find_value_start pos =
      if pos >= String.length content then pos
      else
        match content.[pos] with ' ' | '\t' | '\n' | '\r' -> find_value_start (pos + 1) | _ -> pos
    in
    let actual_start = find_value_start value_start in

    (* 判断值的类型并提取 *)
    if actual_start < String.length content then
      match content.[actual_start] with
      | '"' ->
          (* 字符串值 *)
          let end_quote = String.index_from content (actual_start + 1) '"' in
          String.sub content (actual_start + 1) (end_quote - actual_start - 1)
      | '[' ->
          (* 数组值 *)
          let rec find_array_end pos bracket_count =
            if pos >= String.length content then pos
            else
              match content.[pos] with
              | '[' -> find_array_end (pos + 1) (bracket_count + 1)
              | ']' ->
                  if bracket_count = 1 then pos else find_array_end (pos + 1) (bracket_count - 1)
              | _ -> find_array_end (pos + 1) bracket_count
          in
          let array_end = find_array_end actual_start 0 in
          String.sub content actual_start (array_end - actual_start + 1)
      | _ ->
          (* 其他值类型 *)
          let rec find_value_end pos =
            if pos >= String.length content then pos
            else
              match content.[pos] with
              | ',' | '}' | '\n' | '\r' -> pos
              | _ -> find_value_end (pos + 1)
          in
          let value_end = find_value_end actual_start in
          String.sub content actual_start (value_end - actual_start)
    else ""
  with _ -> ""
