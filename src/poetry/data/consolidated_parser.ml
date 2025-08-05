(** 简化的整合解析器 - 临时修复构建问题
    
    Author: Whisky, PR Worker - P0专项整合
    @version 1.0 - Phase 2.1 临时版本
    @since 2025-08-04
    @fix_issue #2174 *)

(** {1 简化的解析错误类型} *)

type parse_error =
  | JsonParseError of string * string
  | FileReadError of string * string
  | ValidationError of string * string
  | FormatError of string * string

exception ParseError of parse_error

let format_parse_error = function
  | JsonParseError (msg, detail) -> Printf.sprintf "JSON解析错误: %s (详细: %s)" msg detail
  | FileReadError (path, error) -> Printf.sprintf "文件读取错误: %s (路径: %s)" error path
  | ValidationError (field, error) -> Printf.sprintf "数据验证错误: 字段'%s' - %s" field error
  | FormatError (expected, actual) -> Printf.sprintf "格式错误: 期望'%s'，实际'%s'" expected actual

(** {1 简化的解析配置} *)

type parse_options = {
  strict_mode : bool;
  ignore_missing_fields : bool;
  enable_caching : bool;
  max_file_size_mb : int;
}

let default_parse_options =
  {
    strict_mode = false;
    ignore_missing_fields = true;
    enable_caching = true;
    max_file_size_mb = 100;
  }

let global_parse_options = ref default_parse_options
let parse_cache : (string, Yojson.Safe.t) Hashtbl.t = Hashtbl.create 64
let cache_hits = ref 0
let set_parse_options options = global_parse_options := options
let get_parse_options () = !global_parse_options

(** {1 文件操作接口} *)

let file_exists path = Sys.file_exists path

let read_file path =
  try
    let ic = open_in path in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    content
  with
  | Sys_error msg -> raise (ParseError (FileReadError (path, msg)))
  | e -> raise (ParseError (FileReadError (path, Printexc.to_string e)))

let read_lines path =
  try
    let ic = open_in path in
    let lines = ref [] in
    (try
       while true do
         lines := input_line ic :: !lines
       done
     with End_of_file -> ());
    close_in ic;
    List.rev !lines
  with
  | Sys_error msg -> raise (ParseError (FileReadError (path, msg)))
  | e -> raise (ParseError (FileReadError (path, Printexc.to_string e)))

let ensure_directory path =
  let rec create_path p =
    if not (Sys.file_exists p) then (
      create_path (Filename.dirname p);
      Unix.mkdir p 0o755)
  in
  if not (Sys.file_exists path) then create_path path

let get_file_extension path =
  try
    let dot_pos = String.rindex path '.' in
    String.sub path (dot_pos + 1) (String.length path - dot_pos - 1)
  with Not_found -> ""

let normalize_path path =
  let parts = String.split_on_char '/' path in
  let normalized_parts = List.filter (function "" | "." -> false | _ -> true) parts in
  "/" ^ String.concat "/" normalized_parts

(** {1 JSON解析接口} *)

let parse_json_string content =
  try Yojson.Safe.from_string content with
  | Yojson.Json_error msg -> raise (ParseError (JsonParseError ("JSON字符串解析失败", msg)))
  | e -> raise (ParseError (JsonParseError ("未知JSON解析错误", Printexc.to_string e)))

let parse_json_file path =
  let options = !global_parse_options in

  if options.enable_caching && Hashtbl.mem parse_cache path then (
    incr cache_hits;
    Hashtbl.find parse_cache path)
  else (
    if not (file_exists path) then raise (ParseError (FileReadError (path, "文件不存在")));

    let file_size = (Unix.stat path).st_size in
    let max_size = options.max_file_size_mb * 1024 * 1024 in
    if file_size > max_size then
      raise
        (ParseError (FileReadError (path, Printf.sprintf "文件过大: %d字节，限制: %d字节" file_size max_size)));

    try
      let json = Yojson.Safe.from_file path in
      if options.enable_caching then Hashtbl.replace parse_cache path json;
      json
    with
    | Yojson.Json_error msg -> raise (ParseError (JsonParseError (path, msg)))
    | e -> raise (ParseError (JsonParseError (path, Printexc.to_string e))))

let validate_json_structure json required_fields =
  let options = !global_parse_options in
  try
    match json with
    | `Assoc fields ->
        let field_names = List.map fst fields in
        List.for_all
          (fun req_field -> List.mem req_field field_names || options.ignore_missing_fields)
          required_fields
    | _ when options.ignore_missing_fields -> true
    | _ -> false
  with _ -> false

let extract_string_field json field_name =
  try
    match Yojson.Safe.Util.member field_name json with
    | `String s -> Some s
    | `Null when !global_parse_options.ignore_missing_fields -> None
    | _ ->
        if !global_parse_options.strict_mode then
          raise (ParseError (ValidationError (field_name, "不是字符串类型")))
        else None
  with Yojson.Safe.Util.Type_error (msg, _) ->
    if !global_parse_options.strict_mode then raise (ParseError (ValidationError (field_name, msg)))
    else None

let extract_string_list json field_name =
  try
    match Yojson.Safe.Util.member field_name json with
    | `List items ->
        List.map
          (function
            | `String s -> s
            | _ ->
                if !global_parse_options.strict_mode then
                  raise (ParseError (ValidationError (field_name, "列表包含非字符串元素")))
                else "")
          items
    | `Null when !global_parse_options.ignore_missing_fields -> []
    | _ ->
        if !global_parse_options.strict_mode then
          raise (ParseError (ValidationError (field_name, "不是数组类型")))
        else []
  with Yojson.Safe.Util.Type_error (msg, _) ->
    if !global_parse_options.strict_mode then raise (ParseError (ValidationError (field_name, msg)))
    else []

let extract_object_field json field_name =
  try
    match Yojson.Safe.Util.member field_name json with
    | `Assoc _ as obj -> Some obj
    | `Null when !global_parse_options.ignore_missing_fields -> None
    | _ ->
        if !global_parse_options.strict_mode then
          raise (ParseError (ValidationError (field_name, "不是对象类型")))
        else None
  with Yojson.Safe.Util.Type_error (msg, _) ->
    if !global_parse_options.strict_mode then raise (ParseError (ValidationError (field_name, msg)))
    else None

(** {1 专用数据结构} *)

type poetry_data = {
  characters : string list;
  rhyme_category : string;
  rhyme_group : string;
  metadata : (string * string) list;
}

type rhyme_data = { char : string; category : string; group : string; tone : string option }
type tone_data = { characters : string list; tone_type : string; description : string option }
type word_class_data = { category : string; words : string list; description : string option }

(** {1 专用解析函数} *)

let parse_poetry_json json_content =
  let json = parse_json_string json_content in
  let characters = extract_string_list json "characters" in
  let rhyme_category =
    match extract_string_field json "rhyme_category" with Some cat -> cat | None -> "未知"
  in
  let rhyme_group =
    match extract_string_field json "rhyme_group" with Some group -> group | None -> "未知"
  in
  let metadata =
    match extract_object_field json "metadata" with
    | Some (`Assoc fields) ->
        List.filter_map (function key, `String value -> Some (key, value) | _ -> None) fields
    | _ -> []
  in
  { characters; rhyme_category; rhyme_group; metadata }

let parse_poetry_json_file path =
  let content = read_file path in
  parse_poetry_json content

(** {1 缓存管理} *)

let clear_parse_cache () =
  Hashtbl.clear parse_cache;
  cache_hits := 0;
  Printf.printf "解析缓存已清理\n"

let get_cache_stats () =
  let cache_size = Hashtbl.length parse_cache in
  (cache_size, !cache_hits)

(** {1 兼容性接口} *)

module JsonParserCompat = struct
  let load_json = parse_json_file
  let parse_string = parse_json_string
  let validate_schema json = validate_json_structure json []
end

module PoetryJsonParserCompat = struct
  let parse_poetry_file = parse_poetry_json_file
  let extract_characters json = extract_string_list json "characters"

  let extract_rhyme_info json =
    let category =
      match extract_string_field json "rhyme_category" with Some cat -> cat | None -> "未知"
    in
    let group =
      match extract_string_field json "rhyme_group" with Some grp -> grp | None -> "未知"
    in
    (category, group)
end

module FileHelperCompat = struct
  let read_text_file = read_file

  let write_text_file path content =
    let oc = open_out path in
    output_string oc content;
    close_out oc

  let list_directory path = Array.to_list (Sys.readdir path)
  let create_directory = ensure_directory
end

module PoetryFileReaderCompat = struct
  let read_poetry_file = read_lines
  let read_rhyme_file _path = [] (* 简化实现 *)
  let read_tone_file _path = { characters = []; tone_type = ""; description = None } (* 简化实现 *)
end

(** {1 调试和工具} *)

let print_parse_stats () =
  let cache_size, hits = get_cache_stats () in
  Printf.printf "\n=== 解析器统计信息 ===\n";
  Printf.printf "缓存项目数: %d\n" cache_size;
  Printf.printf "缓存命中次数: %d\n" hits;
  Printf.printf "严格模式: %s\n" (if !global_parse_options.strict_mode then "启用" else "禁用");
  Printf.printf "缓存: %s\n" (if !global_parse_options.enable_caching then "启用" else "禁用");
  Printf.printf "==================\n\n"

let validate_all_parsers () =
  let errors = ref [] in
  let valid = ref true in

  (try
     let _ = parse_json_string "{\"test\": \"value\"}" in
     Printf.printf "JSON字符串解析: 通过\n"
   with e ->
     errors := ("JSON字符串解析失败: " ^ Printexc.to_string e) :: !errors;
     valid := false);

  (!valid, !errors)

let benchmark_parser path =
  let start_time = Sys.time () in
  try
    let _ = parse_json_file path in
    let end_time = Sys.time () in
    end_time -. start_time
  with _ -> -1.0
