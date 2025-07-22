(* 数据加载器JSON解析模块
   
   专门用于解析项目数据格式的简化JSON解析器。
   针对特定数据结构优化，避免重量级JSON库的开销。 *)

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

(** 提取数组内容的公共函数 - 消除重复代码 *)
let extract_array_content content =
  let trimmed = trim_whitespace content in
  let trimmed_len = String.length trimmed in
  if trimmed_len < 2 then None
  else if trimmed.[0] <> '[' || trimmed.[trimmed_len - 1] <> ']' then None
  else Some (String.sub trimmed 1 (trimmed_len - 2))

(** 通用数组处理函数，消除重复的数组内容提取和处理模式 *)
let extract_and_parse_array content processor =
  match extract_array_content content with
  | None -> []
  | Some inner -> processor inner

(** 解析字符串数组 - 简化版本 *)
let parse_string_array content =
  try
    (* 使用公共函数处理数组内容，消除重复的匹配模式 *)
    extract_and_parse_array content (fun inner ->
        let items = String.split_on_char ',' inner in
        List.map
          (fun item ->
            let cleaned = trim_whitespace item in
            let cleaned_len = String.length cleaned in
            (* 移除引号 *)
            if cleaned_len >= 2 && cleaned.[0] = '"' && cleaned.[cleaned_len - 1] = '"' then
              String.sub cleaned 1 (cleaned_len - 2)
            else cleaned)
          items
        |> List.filter (fun s -> String.length s > 0))
  with _ -> []

(** 解析键值对数组 - 用于词性数据 *)
let parse_word_class_pairs content =
  try
    (* 这个函数解析形如 [{"word": "山", "class": "Noun"}, ...] 的JSON *)
    (* 使用公共函数处理数组内容，消除重复的匹配模式 *)
    extract_and_parse_array content (fun inner ->
        (* 简化的对象解析 - 这里我们使用正则表达式的简化版本 *)
        let items = String.split_on_char '}' inner in
        List.fold_left
          (fun acc item ->
            if String.contains item '"' then
              try
                (* 提取word和class字段 - 简化处理 *)
                let parts = String.split_on_char '"' item in
                let rec extract_pair parts =
                  match parts with
                  | _ :: "word" :: _ :: word :: _ :: "class" :: _ :: class_name :: _ ->
                      Some (word, class_name)
                  | _ :: "class" :: _ :: class_name :: _ :: "word" :: _ :: word :: _ ->
                      Some (word, class_name)
                  | _ :: rest -> extract_pair rest
                  | [] -> None
                in
                match extract_pair parts with
                | Some (word, class_name) -> (word, class_name) :: acc
                | None -> acc
              with _ -> acc
            else acc)
          [] items
        |> List.rev)
  with _ -> []

(** 解析简单的键值对 JSON 对象 *)
let parse_simple_object content =
  try
    let trimmed = trim_whitespace content in
    let trimmed_len = String.length trimmed in
    if trimmed_len < 2 then []
    else if trimmed.[0] <> '{' || trimmed.[trimmed_len - 1] <> '}' then []
    else
      let inner = String.sub trimmed 1 (trimmed_len - 2) in
      let items = String.split_on_char ',' inner in
      List.fold_left
        (fun acc item ->
          match String.split_on_char ':' item with
          | key :: value :: _ ->
              let clean_key =
                trim_whitespace key |> fun s ->
                let len = String.length s in
                if len >= 2 && s.[0] = '"' && s.[len - 1] = '"' then String.sub s 1 (len - 2) else s
              in
              let clean_value =
                trim_whitespace value |> fun s ->
                let len = String.length s in
                if len >= 2 && s.[0] = '"' && s.[len - 1] = '"' then String.sub s 1 (len - 2) else s
              in
              (clean_key, clean_value) :: acc
          | _ -> acc)
        [] items
      |> List.rev
  with _ -> []
