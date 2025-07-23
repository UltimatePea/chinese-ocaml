(** 韵律数据加载器 - 第六阶段优化重构版本

    从318行优化为紧凑结构，消除重复逻辑，提升可维护性 第六阶段技术债务清理：代码重复消除，通用化处理

    @author 骆言技术债务清理团队
    @version 2.0 (第六阶段优化版)
    @since 2025-07-21 Issue #788 超长文件重构优化 *)

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

(** 错误处理 *)
type rhyme_data_load_error =
  | RhymeFileNotFound of string
  | RhymeParseError of string * string
  | RhymeValidationError of string

exception RhymeDataLoadError of rhyme_data_load_error

let format_rhyme_error = function
  | RhymeFileNotFound path -> sprintf "韵律数据文件未找到: %s" path
  | RhymeParseError (context, msg) -> sprintf "JSON解析错误 [%s]: %s" context msg
  | RhymeValidationError msg -> sprintf "数据验证错误: %s" msg

type rhyme_config = { file_name : string; groups : string list; subgroups : string list }
(** 韵律数据配置 *)

let ping_sheng_config =
  {
    file_name = "ping_sheng_rhymes.json";
    groups = [ "YuRhyme"; "HuaRhyme"; "FengRhyme" ];
    subgroups =
      [ "core_chars"; "jia_jia_series"; "qi_qi_series"; "extended_fish_chars"; "basic_chars" ];
  }

let ze_sheng_config =
  {
    file_name = "ze_sheng_rhymes.json";
    groups = [ "YueRhyme"; "JiangRhyme"; "HuiRhyme" ];
    subgroups = [ "core_chars"; "remaining_chars"; "basic_chars" ];
  }

(** 工具模块 *)
module RhymeFileReader = struct
  let get_data_path filename =
    let home = try Sys.getenv "HOME" with Not_found -> "." in
    Filename.concat home (Filename.concat ".yyocamlc_data" filename)

  let read_file_content path =
    try
      let ic = open_in path in
      let len = in_channel_length ic in
      let content = really_input_string ic len in
      close_in ic;
      content
    with Sys_error msg -> raise (RhymeDataLoadError (RhymeFileNotFound msg))
end

module StringUtils = struct
  let trim_and_clean s = String.trim (String.map (function '\n' | '\r' -> ' ' | c -> c) s)
  let is_empty s = String.length (String.trim s) = 0
end

module JsonParser = struct
  let extract_field json field_name =
    try
      let field_pattern = "\"" ^ field_name ^ "\":" in
      let pattern_len = String.length field_pattern in
      let json_len = String.length json in
      let rec search_pattern pos =
        if pos > json_len - pattern_len then raise Not_found
        else if String.sub json pos pattern_len = field_pattern then pos + pattern_len
        else search_pattern (pos + 1)
      in
      let value_start = search_pattern 0 in
      let rec find_value_end pos depth in_string =
        if pos >= json_len then pos
        else
          match json.[pos] with
          | '"' when pos = 0 || json.[pos - 1] <> '\\' ->
              find_value_end (pos + 1) depth (not in_string)
          | '{' when not in_string -> find_value_end (pos + 1) (depth + 1) in_string
          | '}' when (not in_string) && depth > 0 -> find_value_end (pos + 1) (depth - 1) in_string
          | (',' | '}') when (not in_string) && depth = 0 -> pos
          | _ -> find_value_end (pos + 1) depth in_string
      in
      let value_end = find_value_end value_start 0 false in
      String.sub json value_start (value_end - value_start) |> StringUtils.trim_and_clean
    with Not_found -> raise (RhymeDataLoadError (RhymeParseError ("JSON", "缺少字段: " ^ field_name)))

  let parse_string_array array_str =
    let clean_str = StringUtils.trim_and_clean array_str in
    if String.length clean_str < 2 || clean_str.[0] <> '[' then []
    else
      let content = String.sub clean_str 1 (String.length clean_str - 2) in
      if StringUtils.is_empty content then []
      else
        String.split_on_char ',' content
        |> List.map (fun s ->
               let trimmed = StringUtils.trim_and_clean s in
               if
                 String.length trimmed >= 2
                 && trimmed.[0] = '"'
                 && trimmed.[String.length trimmed - 1] = '"'
               then String.sub trimmed 1 (String.length trimmed - 2)
               else trimmed)
        |> List.filter (fun s -> not (StringUtils.is_empty s))
end

(** 韵律类别和韵组解析 *)
let parse_rhyme_category = function
  | "平声" -> PingSheng
  | "仄声" -> ZeSheng
  | "上声" -> ShangSheng
  | "去声" -> QuSheng
  | "入声" -> RuSheng
  | _ -> PingSheng

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

(** 通用韵组加载器 *)
let load_rhyme_group_generic config =
  let file_path = RhymeFileReader.get_data_path config.file_name in
  let content = RhymeFileReader.read_file_content file_path in

  let load_single_group group_name =
    let group_content = JsonParser.extract_field content group_name in
    let category_str = JsonParser.extract_field group_content "category" in
    let category = parse_rhyme_category (String.trim category_str) in
    let group = parse_rhyme_group group_name in

    let subgroups_content = JsonParser.extract_field group_content "subgroups" in
    let load_subgroup subgroup_name =
      try
        let subgroup_content = JsonParser.extract_field subgroups_content subgroup_name in
        let chars_array = JsonParser.extract_field subgroup_content "characters" in
        let chars = JsonParser.parse_string_array chars_array in
        List.map (fun char -> (char, category, group)) chars
      with RhymeDataLoadError _ -> []
    in

    (* 性能优化：使用 :: 操作替代 @ 操作，避免 O(n²) 复杂度 *)
    List.fold_left (fun acc subgroup_name -> load_subgroup subgroup_name :: acc) [] config.subgroups
    |> List.concat |> List.rev
  in

  (* 性能优化：使用 :: 操作替代 @ 操作，避免 O(n²) 复杂度 *)
  List.fold_left (fun acc group_name -> load_single_group group_name :: acc) [] config.groups
  |> List.concat |> List.rev

(** 公共接口函数 *)
let load_ping_sheng_rhymes () = load_rhyme_group_generic ping_sheng_config

let load_ze_sheng_rhymes () = load_rhyme_group_generic ze_sheng_config

(* 性能优化：使用 List.rev_append 替代 @ 操作 *)
let load_complete_rhyme_database () =
  let ping_sheng = load_ping_sheng_rhymes () in
  let ze_sheng = load_ze_sheng_rhymes () in
  List.rev_append ping_sheng ze_sheng

let safe_load_rhyme_database () =
  try load_complete_rhyme_database ()
  with RhymeDataLoadError err ->
    printf "警告: 韵律数据加载失败: %s\n" (format_rhyme_error err);
    []

(** 接口要求的实用函数 *)
let get_rhyme_char_count database = List.length database

let is_char_in_rhyme_database char database = List.exists (fun (c, _, _) -> c = char) database
let get_char_list database = List.map (fun (char, _, _) -> char) database
