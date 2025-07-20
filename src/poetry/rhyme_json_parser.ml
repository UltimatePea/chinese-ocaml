(** 韵律JSON解析器
    
    专门处理韵律数据JSON格式的解析，提供安全的错误处理和数据验证。
    
    @author 骆言诗词编程团队 
    @version 1.0
    @since 2025-07-20 - Phase 29 rhyme_json_loader重构 *)

open Rhyme_json_types

(** {1 字符串处理工具} *)

(** 清理JSON字符串 *)
let clean_json_string s =
  let s = String.trim s in
  let len = String.length s in
  if len = 0 then ""
  else
    let s = 
      if s.[0] = '"' && len > 1 then String.sub s 1 (len - 1)
      else s
    in
    let s_len = String.length s in
    let s = if s_len > 0 && s.[s_len - 1] = ',' then
      String.sub s 0 (s_len - 1)
    else s
    in
    if String.length s > 0 && s.[String.length s - 1] = '"' then
      String.sub s 0 (String.length s - 1)
    else s

(** {1 解析状态管理} *)

(** 解析状态类型 *)
type parse_state = {
  mutable current_group: string option;
  mutable current_category: string;  
  mutable current_chars: string list;
  mutable result_groups: (string * rhyme_group_data) list;
  mutable in_rhyme_group: bool;
  mutable in_characters_array: bool;
  mutable brace_depth: int;
  mutable bracket_depth: int;
}

(** 创建初始解析状态 *)
let create_parse_state () = {
  current_group = None;
  current_category = "";
  current_chars = [];
  result_groups = [];
  in_rhyme_group = false;
  in_characters_array = false;
  brace_depth = 0;
  bracket_depth = 0;
}

(** {1 解析状态处理函数} *)

(** 完成当前韵组的解析 *)
let finalize_current_group state =
  match state.current_group with
  | Some group_name ->
    let group_data = { category = state.current_category; characters = List.rev state.current_chars } in
    state.result_groups <- (group_name, group_data) :: state.result_groups;
    state.current_group <- None;
    state.current_chars <- []
  | None -> ()

(** 处理韵组头部信息 *)
let process_rhyme_group_header state trimmed =
  finalize_current_group state;
  let parts = String.split_on_char ':' trimmed in
  if List.length parts >= 1 then
    let key = List.hd parts in
    let cleaned_key = clean_json_string key in
    if cleaned_key <> "" then (
      state.current_group <- Some cleaned_key;
      state.in_rhyme_group <- true;
      state.current_category <- "";
      state.current_chars <- []
    )

(** 处理韵类字段 *)
let process_category_field state trimmed =
  let parts = String.split_on_char ':' trimmed in
  if List.length parts >= 2 then
    let value = List.nth parts 1 in
    state.current_category <- clean_json_string value

(** 处理字符元素 *)
let process_character_element state trimmed =
  if state.in_characters_array then
    let char = clean_json_string trimmed in
    if char <> "" then
      state.current_chars <- char :: state.current_chars

(** {1 行内容处理} *)

(** 处理单行内容 *)
let process_line_content state line =
  let trimmed = String.trim line in
  
  (* 更新括号深度 *)
  String.iter (function
    | '{' -> state.brace_depth <- state.brace_depth + 1
    | '}' -> state.brace_depth <- state.brace_depth - 1  
    | '[' -> state.bracket_depth <- state.bracket_depth + 1
    | ']' -> state.bracket_depth <- state.bracket_depth - 1
    | _ -> ()) trimmed;
  
  (* 检测是否进入characters数组 *)
  let contains_characters = try
    ignore (Str.search_forward (Str.regexp "characters") line 0); true
  with Not_found -> false in
  if String.contains trimmed '[' && contains_characters then
    state.in_characters_array <- true;
  
  if String.contains trimmed ']' && state.in_characters_array then
    state.in_characters_array <- false;
  
  (* 处理不同类型的行 *)
  if String.contains trimmed ':' && not state.in_characters_array then (
    let contains_category = try
      ignore (Str.search_forward (Str.regexp "category") line 0); true
    with Not_found -> false in
    if contains_category then
      process_category_field state trimmed
    else if state.brace_depth > 0 then
      process_rhyme_group_header state trimmed
  ) else if state.in_characters_array then
    process_character_element state trimmed

(** {1 主解析函数} *)

(** 解析嵌套JSON内容 *)
let parse_nested_json content =
  let lines = String.split_on_char '\n' content in
  let state = create_parse_state () in
  
  List.iter (process_line_content state) lines;
  finalize_current_group state;
  
  List.rev state.result_groups