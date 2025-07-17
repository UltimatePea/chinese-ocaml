
(** 通用字符串处理工具函数 *)

(** 字符串处理的通用模板 *)
let process_string_with_skip line skip_logic =
  let result = ref "" in
  let i = ref 0 in
  let len = String.length line in
  while !i < len do
    let should_skip, skip_length = skip_logic !i line len in
    if should_skip then
      i := !i + skip_length
    else (
      result := !result ^ String.make 1 (String.get line !i);
      i := !i + 1)
  done;
  !result

(** 块注释跳过逻辑 *)
let block_comment_skip_logic i line len =
  if i < len - 1 && String.get line i = '(' && String.get line (i + 1) = '*' then
    let rec skip_to_end pos =
      if pos < len - 1 && String.get line pos = '*' && String.get line (pos + 1) = ')' then
        pos + 2
      else if pos < len then
        skip_to_end (pos + 1)
      else
        len
    in
    let end_pos = skip_to_end (i + 2) in
    (true, end_pos - i)
  else
    (false, 0)

(** 骆言字符串跳过逻辑 *)
let luoyan_string_skip_logic i line len =
  if i + 2 < len 
     && String.get line i = '\xe3' 
     && String.get line (i + 1) = '\x80' 
     && String.get line (i + 2) = '\x8e' then
    let rec skip_to_end pos =
      if pos + 2 < len 
         && String.get line pos = '\xe3' 
         && String.get line (pos + 1) = '\x80' 
         && String.get line (pos + 2) = '\x8f' then
        pos + 3
      else if pos < len then
        skip_to_end (pos + 1)
      else
        len
    in
    let end_pos = skip_to_end (i + 3) in
    (true, end_pos - i)
  else
    (false, 0)

(** 英文字符串跳过逻辑 *)
let english_string_skip_logic i line len =
  let c = String.get line i in
  if c = '"' || c = '\'' then
    let quote = c in
    let rec skip_to_end pos =
      if pos < len && String.get line pos = quote then
        pos + 1
      else if pos < len then
        skip_to_end (pos + 1)
      else
        len
    in
    let end_pos = skip_to_end (i + 1) in
    (true, end_pos - i)
  else
    (false, 0)

(** 双斜杠注释处理 *)
let remove_double_slash_comment line =
  let rec find_index i =
    if i >= String.length line - 1 then String.length line
    else if String.get line i = '/' && String.get line (i + 1) = '/' then i
    else find_index (i + 1)
  in
  let index = find_index 0 in
  String.sub line 0 index

(** 井号注释处理 *)
let remove_hash_comment line =
  let index = try String.index line '#' with Not_found -> String.length line in
  String.sub line 0 index

(** 重构后的字符串处理函数 *)
let remove_block_comments line = process_string_with_skip line block_comment_skip_logic
let remove_luoyan_strings line = process_string_with_skip line luoyan_string_skip_logic
let remove_english_strings line = process_string_with_skip line english_string_skip_logic