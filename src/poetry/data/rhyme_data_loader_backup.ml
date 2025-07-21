(** 韵律数据加载器 - 骆言项目 Phase 16 技术债务清理

    专门负责从外部JSON文件加载韵律数据，替代hardcoded韵律数据。 支持加载平声韵、仄声韵等各类韵律数据，实现数据与代码分离。

    @author 骆言技术债务清理团队 Phase 16
    @version 1.0
    @since 2025-07-19 *)

open Printf

(* 本地类型定义，避免循环依赖 *)
type rhyme_category = PingSheng | ZeSheng | ShangSheng | QuSheng | RuSheng

type rhyme_group =
  | AnRhyme
  | SiRhyme
  | TianRhyme
  | WangRhyme
  | QuRhyme
  | YuRhyme
  | HuaRhyme
  | FengRhyme
  | YueRhyme
  | JiangRhyme
  | HuiRhyme
  | UnknownRhyme

(** ========== 错误处理 ========== *)

type rhyme_data_load_error =
  | RhymeFileNotFound of string
  | RhymeParseError of string * string
  | RhymeValidationError of string

exception RhymeDataLoadError of rhyme_data_load_error

let format_rhyme_error = function
  | RhymeFileNotFound file -> sprintf "韵律数据文件未找到: %s" file
  | RhymeParseError (file, msg) -> sprintf "解析韵律文件 %s 失败: %s" file msg
  | RhymeValidationError msg -> sprintf "韵律数据验证失败: %s" msg

(** ========== 文件读取器 ========== *)

module RhymeFileReader = struct
  let get_data_path filename =
    let data_dir = "data/poetry/expanded" in
    Filename.concat data_dir filename

  let read_file_content filepath =
    try
      let ic = open_in filepath in
      let content = really_input_string ic (in_channel_length ic) in
      close_in ic;
      content
    with Sys_error msg -> raise (RhymeDataLoadError (RhymeFileNotFound msg))
end

(** ========== 简单JSON解析器 (专门用于韵律数据) - 重构为模块化设计 ========== *)

(** 字符串处理工具模块 *)
module StringUtils = struct
  let trim_whitespace s =
    let len = String.length s in
    let rec start i =
      if i >= len then len
      else match s.[i] with ' ' | '\t' | '\n' | '\r' -> start (i + 1) | _ -> i
    in
    let rec finish i =
      if i < 0 then -1 else match s.[i] with ' ' | '\t' | '\n' | '\r' -> finish (i - 1) | _ -> i
    in
    let s_start = start 0 in
    let s_end = finish (len - 1) in
    if s_start > s_end then "" else String.sub s s_start (s_end - s_start + 1)

  let find_substring s pattern =
    let len_s = String.length s in
    let len_p = String.length pattern in
    let rec search i =
      if i + len_p > len_s then None
      else if String.sub s i len_p = pattern then Some i
      else search (i + 1)
    in
    search 0
end

(** JSON字段定位器 *)
module JsonFieldLocator = struct
  let find_field_position json field_name =
    let field_pattern = "\"" ^ field_name ^ "\"" in
    StringUtils.find_substring json field_pattern
  
  let find_colon_after_field json field_name pos =
    let field_pattern = "\"" ^ field_name ^ "\"" in
    let colon_pos = pos + String.length field_pattern in
    let rec find_colon i =
      if i >= String.length json then
        raise (RhymeDataLoadError (RhymeParseError ("JSON", "字段 " ^ field_name ^ " 格式错误")))
      else if json.[i] = ':' then i
      else find_colon (i + 1)
    in
    find_colon colon_pos
    
  let find_value_start json colon_idx =
    let rec find_value_start i =
      if i >= String.length json then i
      else match json.[i] with ' ' | '\t' | '\n' | '\r' -> find_value_start (i + 1) | _ -> i
    in
    find_value_start (colon_idx + 1)
end

(** JSON值提取器 *)
module JsonValueExtractor = struct
  let extract_string json start_pos =
    let rec find_end i escaped =
      if i >= String.length json then
        raise (RhymeDataLoadError (RhymeParseError ("JSON", "字符串未正确结束")))
      else if escaped then find_end (i + 1) false
      else
        match json.[i] with '\\' -> find_end (i + 1) true | '"' -> i | _ -> find_end (i + 1) false
    in
    let end_pos = find_end (start_pos + 1) false in
    String.sub json (start_pos + 1) (end_pos - start_pos - 1)

  let extract_array json start_pos =
    let rec find_matching_bracket i depth =
      if i >= String.length json then
        raise (RhymeDataLoadError (RhymeParseError ("JSON", "数组未正确结束")))
      else
        match json.[i] with
        | '[' -> find_matching_bracket (i + 1) (depth + 1)
        | ']' when depth = 1 -> i
        | ']' -> find_matching_bracket (i + 1) (depth - 1)
        | _ -> find_matching_bracket (i + 1) depth
    in
    let end_pos = find_matching_bracket start_pos 0 in
    String.sub json start_pos (end_pos - start_pos + 1)

  let extract_object json start_pos =
    let rec find_matching_brace i depth =
      if i >= String.length json then
        raise (RhymeDataLoadError (RhymeParseError ("JSON", "对象未正确结束")))
      else
        match json.[i] with
        | '{' -> find_matching_brace (i + 1) (depth + 1)
        | '}' when depth = 1 -> i
        | '}' -> find_matching_brace (i + 1) (depth - 1)
        | _ -> find_matching_brace (i + 1) depth
    in
    let end_pos = find_matching_brace start_pos 0 in
    String.sub json start_pos (end_pos - start_pos + 1)

  let extract_simple_value json start_pos =
    let rec find_end i =
      if i >= String.length json then i
      else match json.[i] with ',' | '}' | ']' | '\n' | '\r' -> i | _ -> find_end (i + 1)
    in
    let end_pos = find_end start_pos in
    StringUtils.trim_whitespace (String.sub json start_pos (end_pos - start_pos))
    
  let extract_value json start_pos =
    if start_pos >= String.length json then ""
    else
      match json.[start_pos] with
      | '"' -> extract_string json start_pos
      | '[' -> extract_array json start_pos
      | '{' -> extract_object json start_pos
      | _ -> extract_simple_value json start_pos
end

(** JSON数组解析器 *)
module JsonArrayParser = struct
  let parse_string_array array_str =
    let content = StringUtils.trim_whitespace array_str in
    if String.length content < 2 || content.[0] != '[' || content.[String.length content - 1] != ']'
    then raise (RhymeDataLoadError (RhymeParseError ("JSON", "数组格式错误")))
    else
      let inner = String.sub content 1 (String.length content - 2) in
      let inner = StringUtils.trim_whitespace inner in
      if inner = "" then []
      else
        let parts = String.split_on_char ',' inner in
        List.map
          (fun part ->
            let trimmed = StringUtils.trim_whitespace part in
            if
              String.length trimmed >= 2
              && trimmed.[0] = '"'
              && trimmed.[String.length trimmed - 1] = '"'
            then String.sub trimmed 1 (String.length trimmed - 2)
            else trimmed)
          parts
end

(** 重构后的统一JSON解析器接口 *)
module RhymeJsonParser = struct
  let extract_field json field_name =
    match JsonFieldLocator.find_field_position json field_name with
    | None -> raise (RhymeDataLoadError (RhymeParseError ("JSON", "字段 " ^ field_name ^ " 未找到")))
    | Some pos ->
        let colon_idx = JsonFieldLocator.find_colon_after_field json field_name pos in
        let value_start = JsonFieldLocator.find_value_start json colon_idx in
        if value_start >= String.length json then "" 
        else JsonValueExtractor.extract_value json value_start
        
  let parse_string_array = JsonArrayParser.parse_string_array
end

(** ========== 韵组映射 ========== *)

let parse_rhyme_group = function
  | "AnRhyme" -> AnRhyme
  | "SiRhyme" -> SiRhyme
  | "TianRhyme" -> TianRhyme
  | "WangRhyme" -> WangRhyme
  | "QuRhyme" -> QuRhyme
  | "YuRhyme" -> YuRhyme
  | "HuaRhyme" -> HuaRhyme
  | "FengRhyme" -> FengRhyme
  | "YueRhyme" -> YueRhyme
  | "JiangRhyme" -> JiangRhyme
  | "HuiRhyme" -> HuiRhyme
  | _ -> UnknownRhyme

let parse_rhyme_category = function
  | "PingSheng" -> PingSheng
  | "ZeSheng" -> ZeSheng
  | "ShangSheng" -> ShangSheng
  | "QuSheng" -> QuSheng
  | "RuSheng" -> RuSheng
  | _ -> PingSheng (* 默认为平声 *)

(** ========== 韵律数据加载器 ========== *)

(** 加载平声韵数据 *)
let load_ping_sheng_rhymes () =
  let file_path = RhymeFileReader.get_data_path "ping_sheng_rhymes.json" in
  let content = RhymeFileReader.read_file_content file_path in

  let rhyme_groups = [ "YuRhyme"; "HuaRhyme"; "FengRhyme" ] in
  let load_rhyme_group group_name =
    let group_content = RhymeJsonParser.extract_field content group_name in
    let category_str = RhymeJsonParser.extract_field group_content "category" in
    let category = parse_rhyme_category (String.trim category_str) in
    let group = parse_rhyme_group group_name in

    let subgroups_content = RhymeJsonParser.extract_field group_content "subgroups" in
    let load_subgroup subgroup_name =
      try
        let subgroup_content = RhymeJsonParser.extract_field subgroups_content subgroup_name in
        let chars_array = RhymeJsonParser.extract_field subgroup_content "characters" in
        let chars = RhymeJsonParser.parse_string_array chars_array in
        List.map (fun char -> (char, category, group)) chars
      with RhymeDataLoadError _ -> []
    in

    let core_chars = load_subgroup "core_chars" in
    let jia_chars = load_subgroup "jia_jia_series" in
    let qi_chars = load_subgroup "qi_qi_series" in
    let extended_chars = load_subgroup "extended_fish_chars" in
    let basic_chars = load_subgroup "basic_chars" in

    core_chars @ jia_chars @ qi_chars @ extended_chars @ basic_chars
  in

  List.fold_left (fun acc group_name -> acc @ load_rhyme_group group_name) [] rhyme_groups

(** 加载仄声韵数据 *)
let load_ze_sheng_rhymes () =
  let file_path = RhymeFileReader.get_data_path "ze_sheng_rhymes.json" in
  let content = RhymeFileReader.read_file_content file_path in

  let rhyme_groups = [ "YueRhyme"; "JiangRhyme"; "HuiRhyme" ] in
  let load_rhyme_group group_name =
    let group_content = RhymeJsonParser.extract_field content group_name in
    let category_str = RhymeJsonParser.extract_field group_content "category" in
    let category = parse_rhyme_category (String.trim category_str) in
    let group = parse_rhyme_group group_name in

    let subgroups_content = RhymeJsonParser.extract_field group_content "subgroups" in
    let load_subgroup subgroup_name =
      try
        let subgroup_content = RhymeJsonParser.extract_field subgroups_content subgroup_name in
        let chars_array = RhymeJsonParser.extract_field subgroup_content "characters" in
        let chars = RhymeJsonParser.parse_string_array chars_array in
        List.map (fun char -> (char, category, group)) chars
      with RhymeDataLoadError _ -> []
    in

    let core_chars = load_subgroup "core_chars" in
    let remaining_chars = load_subgroup "remaining_chars" in
    let basic_chars = load_subgroup "basic_chars" in

    core_chars @ remaining_chars @ basic_chars
  in

  List.fold_left (fun acc group_name -> acc @ load_rhyme_group group_name) [] rhyme_groups

(** 加载完整韵律数据库 *)
let load_complete_rhyme_database () =
  let ping_sheng = load_ping_sheng_rhymes () in
  let ze_sheng = load_ze_sheng_rhymes () in
  ping_sheng @ ze_sheng

(** 安全加载韵律数据 - 带错误处理 *)
let safe_load_rhyme_database () =
  try load_complete_rhyme_database ()
  with RhymeDataLoadError err ->
    Printf.eprintf "警告: %s，使用空韵律数据库\n" (format_rhyme_error err);
    []

(** 获取韵律数据库字符统计 *)
let get_rhyme_char_count database = List.length database

(** 检查字符是否在韵律数据库中 *)
let is_char_in_rhyme_database char database = List.exists (fun (c, _, _) -> c = char) database

(** 获取韵律数据库中的字符列表 *)
let get_char_list database = List.map (fun (c, _, _) -> c) database
