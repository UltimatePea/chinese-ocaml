(* 诗词JSON处理统一模块 - 整合所有JSON处理功能
   整合原有的14个rhyme_json_*模块，使用统一的poetry_core_types
   
   整合前：14个独立模块，类型重复定义，功能分散
   整合后：1个统一模块，类型复用，功能集中
   
   古云：合则强，分则弱。功能分散，反增复杂。
   统一处理，方显简明。
*)

open Poetry_core_types

(* 缓存管理模块 *)
module Cache = struct
  (* 缓存有效期：5分钟 *)
  let cache_ttl = 300.0
  
  (* 缓存状态 *)
  let cached_data = ref None
  let cache_timestamp = ref 0.0
  
  let is_valid () =
    match !cached_data with
    | None -> false
    | Some _ ->
        let current_time = Unix.time () in
        current_time -. !cache_timestamp < cache_ttl
  
  let get () =
    match !cached_data with 
    | Some data -> data 
    | None -> raise (Rhyme_data_not_found "缓存中无数据")
  
  let set data =
    cached_data := Some data;
    cache_timestamp := Unix.time ()
  
  let clear () =
    cached_data := None;
    cache_timestamp := 0.0
  
  let refresh data =
    clear ();
    set data
end

(* JSON解析模块 *)
module Parser = struct
  (* 清理JSON字符串 *)
  let clean_string s =
    let s = String.trim s in
    let len = String.length s in
    if len = 0 then ""
    else
      let s = if s.[0] = '"' && len > 1 then String.sub s 1 (len - 1) else s in
      let s_len = String.length s in
      let s = if s_len > 0 && s.[s_len - 1] = ',' then String.sub s 0 (s_len - 1) else s in
      if String.length s > 0 && s.[String.length s - 1] = '"' then String.sub s 0 (String.length s - 1)
      else s

  (* 解析状态类型 *)
  type parse_state = {
    mutable current_group : string option;
    mutable current_category : string;
    mutable current_chars : string list;
    mutable result_groups : (string * rhyme_group_data) list;
    mutable in_rhyme_group : bool;
    mutable in_characters_array : bool;
    mutable brace_depth : int;
    mutable bracket_depth : int;
  }

  let create_state () = {
    current_group = None;
    current_category = "";
    current_chars = [];
    result_groups = [];
    in_rhyme_group = false;
    in_characters_array = false;
    brace_depth = 0;
    bracket_depth = 0;
  }

  let finalize_group state =
    match state.current_group with
    | Some group_name ->
        let group_data = { 
          category = state.current_category; 
          characters = List.rev state.current_chars 
        } in
        state.result_groups <- (group_name, group_data) :: state.result_groups;
        state.current_group <- None;
        state.current_chars <- []
    | None -> ()

  let process_group_header state trimmed =
    finalize_group state;
    let parts = String.split_on_char ':' trimmed in
    if List.length parts >= 1 then
      let key = List.hd parts in
      let cleaned_key = clean_string key in
      if cleaned_key <> "" then (
        state.current_group <- Some cleaned_key;
        state.in_rhyme_group <- true;
        state.current_category <- "";
        state.current_chars <- [])

  let process_category_field state trimmed =
    let parts = String.split_on_char ':' trimmed in
    if List.length parts >= 2 then
      let value = List.nth parts 1 in
      state.current_category <- clean_string value

  let process_character state trimmed =
    if state.in_characters_array then
      let char = clean_string trimmed in
      if char <> "" then state.current_chars <- char :: state.current_chars

  let process_line state line =
    let trimmed = String.trim line in
    
    (* 更新括号深度 *)
    String.iter (function
      | '{' -> state.brace_depth <- state.brace_depth + 1
      | '}' -> state.brace_depth <- state.brace_depth - 1
      | '[' -> state.bracket_depth <- state.bracket_depth + 1
      | ']' -> state.bracket_depth <- state.bracket_depth - 1
      | _ -> ()) trimmed;

    (* 检测字符数组 *)
    let contains_characters =
      try ignore (Str.search_forward (Str.regexp "characters") line 0); true
      with Not_found -> false in
    
    if String.contains trimmed '[' && contains_characters then 
      state.in_characters_array <- true;
    if String.contains trimmed ']' && state.in_characters_array then
      state.in_characters_array <- false;

    (* 处理不同类型的行 *)
    if String.contains trimmed ':' && not state.in_characters_array then (
      let contains_category =
        try ignore (Str.search_forward (Str.regexp "category") line 0); true
        with Not_found -> false in
      
      if contains_category then process_category_field state trimmed
      else if state.brace_depth > 0 then process_group_header state trimmed
    ) else if state.in_characters_array then process_character state trimmed

  let parse_json content =
    let lines = String.split_on_char '\n' content in
    let state = create_state () in
    List.iter (process_line state) lines;
    finalize_group state;
    List.rev state.result_groups
end

(* 文件I/O模块 *)
module FileIO = struct
  let default_data_file = "data/poetry/rhyme_groups/rhyme_data.json"

  let safe_read_file filename =
    try
      let ic = open_in filename in
      let content = really_input_string ic (in_channel_length ic) in
      close_in ic;
      content
    with
    | Sys_error msg -> raise (Rhyme_data_not_found ("文件读取失败: " ^ msg))
    | _ -> raise (Rhyme_data_not_found ("文件读取时发生未知错误: " ^ filename))

  let load_from_file ?(filename = default_data_file) () =
    try
      let content = safe_read_file filename in
      let rhyme_groups = Parser.parse_json content in
      let data = { rhyme_groups; metadata = [] } in
      Cache.set data;
      data
    with
    | Json_parse_error msg -> raise (Json_parse_error ("JSON解析错误: " ^ msg))
    | Rhyme_data_not_found msg -> raise (Rhyme_data_not_found msg)
    | exn -> raise (Json_parse_error ("加载韵律数据时发生异常: " ^ Printexc.to_string exn))
end

(* 降级数据模块 *)
module Fallback = struct
  let fallback_data = [
    ("安韵", { category = "平声"; characters = ["安"; "看"; "山"] });
    ("思韵", { category = "仄声"; characters = ["思"; "之"; "子"] });
    ("天韵", { category = "平声"; characters = ["天"; "年"; "先"] });
    ("望韵", { category = "去声"; characters = ["望"; "放"; "向"] });
  ]

  let use_fallback () =
    Printf.eprintf "警告: 使用降级韵律数据\n%!";
    let data = { rhyme_groups = fallback_data; metadata = [] } in
    Cache.set data;
    data
end

(* 主要API接口 *)

(* 获取韵律数据（支持缓存） *)
let get_data ?(force_reload = false) () =
  if force_reload then (
    Cache.clear ();
    FileIO.load_from_file ()
  ) else if Cache.is_valid () then 
    Cache.get ()
  else 
    FileIO.load_from_file ()

(* 安全获取韵律数据（带降级处理） *)
let get_data_safe ?(force_reload = false) () =
  try get_data ~force_reload ()
  with 
  | Rhyme_data_not_found _ | Json_parse_error _ -> Fallback.use_fallback ()

(* 获取所有韵组 *)
let get_all_groups () =
  let data = get_data_safe () in
  data.rhyme_groups

(* 获取指定韵组的字符列表 *)
let get_group_characters group_name =
  let groups = get_all_groups () in
  try
    let _, group_data = List.find (fun (name, _) -> name = group_name) groups in
    group_data.characters
  with Not_found -> []

(* 获取指定韵组的韵类 *)
let get_group_category group_name =
  let groups = get_all_groups () in
  try
    let _, group_data = List.find (fun (name, _) -> name = group_name) groups in
    string_to_rhyme_category group_data.category
  with Not_found -> PingSheng

(* 获取字符到韵律的映射关系 *)
let get_char_mappings () =
  let groups = get_all_groups () in
  let mappings = ref [] in
  List.iter (fun (group_name, group_data) ->
    let rhyme_category = string_to_rhyme_category group_data.category in
    let rhyme_group = string_to_rhyme_group group_name in
    List.iter (fun char -> 
      mappings := (char, (rhyme_category, rhyme_group)) :: !mappings
    ) group_data.characters
  ) groups;
  List.rev !mappings

(* 查找字符的韵律信息 *)
let lookup_char char =
  let mappings = get_char_mappings () in
  try
    let (category, group) = List.assoc char mappings in
    Some (category, group)
  with Not_found -> None

(* 获取统计信息 *)
let get_statistics () =
  try
    let data = get_data_safe () in
    let total_groups = List.length data.rhyme_groups in
    let total_chars = 
      List.fold_left (fun acc (_, group_data) -> 
        acc + List.length group_data.characters
      ) 0 data.rhyme_groups in
    (total_groups, total_chars)
  with _ -> (0, 0)

(* 打印统计信息 *)
let print_statistics () =
  let (total_groups, total_chars) = get_statistics () in
  Printf.printf "韵律数据统计:\n";
  Printf.printf "  韵组总数: %d\n" total_groups;
  Printf.printf "  字符总数: %d\n" total_chars;
  if total_groups > 0 then
    Printf.printf "  平均每组字符数: %.1f\n" 
      (float_of_int total_chars /. float_of_int total_groups)

(* 缓存管理接口 *)
let clear_cache = Cache.clear
let refresh_cache data = Cache.refresh data