(** 诗歌数据访问器实现 - Phase 2.3.2 *)

open Unified_data_engine

(** {1 诗歌数据类型定义} *)

type rhyme_group = UnknownRhyme | RhymeGroup of string
type rhyme_category = PingRhyme | ZeRhyme | UnknownCategory
type tone_type = Ping | Shang | Qu | Ru | UnknownTone

type char_info = {
  character : string;
  tone : tone_type;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  pinyin : string option;
}

type rhyme_ending_info = {
  char : string;
  rhyme_group : rhyme_group;
  usage_frequency : int;
  example_poems : string list;
}

type poetry_pattern = {
  name : string;
  tone_pattern : bool list;
  rhyme_positions : int list;
  line_length : int;
}

type 'a query_result = Found of 'a | NotFound | QueryError of string

(** {1 内部状态和配置} *)

(* 初始化状态 *)
let initialized = ref false

(* 数据源名称常量 *)
let rhyme_data_source = "poetry_rhyme_data"
let tone_data_source = "poetry_tone_data"
let pattern_data_source = "poetry_patterns"
let char_info_source = "poetry_char_info"

(** {1 工具函数} *)

(* let string_of_tone = function
  | Ping -> "平声"
  | Shang -> "上声"
  | Qu -> "去声"
  | Ru -> "入声"
  | UnknownTone -> "未知声调" *)

(* let string_of_rhyme_group = function
  | UnknownRhyme -> "未知韵组"
  | RhymeGroup s -> s *)

(* let string_of_rhyme_category = function
  | PingRhyme -> "平韵"
  | ZeRhyme -> "仄韵"
  | UnknownCategory -> "未知韵类" *)

let tone_from_string = function
  | "平声" | "ping" -> Ping
  | "上声" | "shang" -> Shang
  | "去声" | "qu" -> Qu
  | "入声" | "ru" -> Ru
  | _ -> UnknownTone

let rhyme_group_from_string s = if s = "" || s = "unknown" then UnknownRhyme else RhymeGroup s

let rhyme_category_from_string = function
  | "平韵" | "ping" -> PingRhyme
  | "仄韵" | "ze" -> ZeRhyme
  | _ -> UnknownCategory

(** {1 数据解析函数} *)

let parse_char_info_from_json (json : Yojson.Basic.t) : (string * char_info) list =
  let open Yojson.Basic.Util in
  try
    let chars = json |> to_list in
    List.map
      (fun char_json ->
        let char = char_json |> member "char" |> to_string in
        let tone_str = char_json |> member "tone" |> to_string in
        let rhyme_group_str = char_json |> member "rhyme_group" |> to_string in
        let rhyme_category_str = char_json |> member "rhyme_category" |> to_string in
        let pinyin = try Some (char_json |> member "pinyin" |> to_string) with _ -> None in

        let char_info =
          {
            character = char;
            tone = tone_from_string tone_str;
            rhyme_group = rhyme_group_from_string rhyme_group_str;
            rhyme_category = rhyme_category_from_string rhyme_category_str;
            pinyin;
          }
        in
        (char, char_info))
      chars
  with _ -> []

let parse_poetry_patterns_from_json (json : Yojson.Basic.t) : string * poetry_pattern list =
  let open Yojson.Basic.Util in
  try
    let patterns_json = json |> member "patterns" |> to_list in
    let patterns =
      List.map
        (fun pattern_json ->
          let name = pattern_json |> member "name" |> to_string in
          let tone_pattern = pattern_json |> member "tone_pattern" |> to_list |> List.map to_bool in
          let rhyme_positions =
            pattern_json |> member "rhyme_positions" |> to_list |> List.map to_int
          in
          let line_length = pattern_json |> member "line_length" |> to_int in
          { name; tone_pattern; rhyme_positions; line_length })
        patterns_json
    in
    ("patterns", patterns)
  with _ -> ("patterns", [])

(** {1 数据查询辅助函数} *)

let lookup_char_info (char : string) : char_info option =
  match Unified_data_engine.load_json_data char_info_source with
  | Success json -> (
      let char_info_list = parse_char_info_from_json json in
      try Some (List.assoc char char_info_list) with Not_found -> None)
  | Failure _ -> None

let get_chars_by_condition (condition : char_info -> bool) : string list =
  match Unified_data_engine.load_json_data char_info_source with
  | Success json ->
      let char_info_list = parse_char_info_from_json json in
      List.filter_map
        (fun (char, info) -> if condition info then Some char else None)
        char_info_list
  | Failure _ -> []

(** {1 公共接口实现} *)

let initialize () =
  if not (Unified_data_engine.is_initialized ()) then Unified_data_engine.initialize ();

  if not !initialized then (
    (* 注册诗歌相关的数据源 *)
    Unified_data_engine.register_data_source rhyme_data_source Poetry
      (JsonFile "data/poetry/rhyme_data.json") Cached;

    Unified_data_engine.register_data_source tone_data_source Poetry
      (JsonFile "data/poetry/tone_data.json") Cached;

    Unified_data_engine.register_data_source pattern_data_source Poetry
      (JsonFile "data/poetry/poetry_patterns.json") Cached;

    Unified_data_engine.register_data_source char_info_source Poetry
      (JsonFile "data/poetry/char_info.json") Preloaded;

    initialized := true)

let is_initialized () = !initialized

let register_custom_data_source (name : string) (filepath : string) =
  if not !initialized then initialize ();
  Unified_data_engine.register_data_source name Poetry (JsonFile filepath) Cached

let get_char_info (char : string) : char_info query_result =
  if not !initialized then initialize ();
  match lookup_char_info char with Some info -> Found info | None -> NotFound

let get_char_tone (char : string) : tone_type query_result =
  match get_char_info char with
  | Found info -> Found info.tone
  | NotFound -> NotFound
  | QueryError err -> QueryError err

let get_char_rhyme_group (char : string) : rhyme_group query_result =
  match get_char_info char with
  | Found info -> Found info.rhyme_group
  | NotFound -> NotFound
  | QueryError err -> QueryError err

let get_char_rhyme_category (char : string) : rhyme_category query_result =
  match get_char_info char with
  | Found info -> Found info.rhyme_category
  | NotFound -> NotFound
  | QueryError err -> QueryError err

let get_chars_by_rhyme_group (rhyme_group : rhyme_group) : string list query_result =
  if not !initialized then initialize ();
  try
    let chars = get_chars_by_condition (fun info -> info.rhyme_group = rhyme_group) in
    if chars = [] then NotFound else Found chars
  with exn -> QueryError ("查询韵组字符失败: " ^ Printexc.to_string exn)

let get_chars_by_tone (tone : tone_type) : string list query_result =
  if not !initialized then initialize ();
  try
    let chars = get_chars_by_condition (fun info -> info.tone = tone) in
    if chars = [] then NotFound else Found chars
  with exn -> QueryError ("查询声调字符失败: " ^ Printexc.to_string exn)

let get_rhyme_endings (rhyme_group : rhyme_group) : rhyme_ending_info list query_result =
  match get_chars_by_rhyme_group rhyme_group with
  | Found chars ->
      let endings =
        List.map
          (fun char ->
            {
              char;
              rhyme_group;
              usage_frequency = 1;
              (* 简化实现，实际应从统计数据获取 *)
              example_poems = [];
              (* 简化实现 *)
            })
          chars
      in
      Found endings
  | NotFound -> NotFound
  | QueryError err -> QueryError err

let find_rhyming_chars (char : string) : string list query_result =
  match get_char_rhyme_group char with
  | Found rhyme_group -> (
      match get_chars_by_rhyme_group rhyme_group with
      | Found chars ->
          let filtered_chars = List.filter (fun c -> c <> char) chars in
          Found filtered_chars
      | NotFound -> NotFound
      | QueryError err -> QueryError err)
  | NotFound -> NotFound
  | QueryError err -> QueryError err

let analyze_tone_pattern (text : string) : bool list query_result =
  if not !initialized then initialize ();
  try
    let chars = List.init (String.length text) (String.get text) in
    let char_strings = List.map (String.make 1) chars in
    let tones =
      List.map
        (fun char_str ->
          match get_char_tone char_str with
          | Found Ping -> Some true
          | Found (Shang | Qu | Ru) -> Some false
          | _ -> None)
        char_strings
    in

    if List.for_all (function Some _ -> true | None -> false) tones then
      Found (List.map (function Some b -> b | None -> false) tones)
    else QueryError "文本包含无法识别声调的字符"
  with exn -> QueryError ("声调分析失败: " ^ Printexc.to_string exn)

let validate_tone_pattern (text : string) (expected_pattern : bool list) : bool query_result =
  match analyze_tone_pattern text with
  | Found actual_pattern -> Found (actual_pattern = expected_pattern)
  | NotFound -> NotFound
  | QueryError err -> QueryError err

let get_poetry_patterns (poetry_type : string) : poetry_pattern list query_result =
  if not !initialized then initialize ();
  match Unified_data_engine.load_json_data pattern_data_source with
  | Success json ->
      let _, all_patterns = parse_poetry_patterns_from_json json in
      let filtered_patterns =
        List.filter
          (fun pattern -> String.contains pattern.name (String.get poetry_type 0) (* 简化匹配 *))
          all_patterns
      in
      if filtered_patterns = [] then NotFound else Found filtered_patterns
  | Failure err -> QueryError ("加载格律模式失败: " ^ Unified_data_engine.format_error err)

let search_chars_by_criteria ?tone ?rhyme_group ?rhyme_category () : string list query_result =
  if not !initialized then initialize ();
  try
    let condition info =
      let tone_match = match tone with None -> true | Some t -> info.tone = t in
      let rhyme_group_match =
        match rhyme_group with None -> true | Some rg -> info.rhyme_group = rg
      in
      let rhyme_category_match =
        match rhyme_category with None -> true | Some rc -> info.rhyme_category = rc
      in
      tone_match && rhyme_group_match && rhyme_category_match
    in
    let chars = get_chars_by_condition condition in
    if chars = [] then NotFound else Found chars
  with exn -> QueryError ("多条件搜索失败: " ^ Printexc.to_string exn)

let take n lst =
  let rec aux acc n = function
    | [] -> List.rev acc
    | x :: xs when n > 0 -> aux (x :: acc) (n - 1) xs
    | _ -> List.rev acc
  in
  aux [] n lst

let get_popular_rhyme_chars (limit : int) : (string * int) list query_result =
  (* 简化实现：返回每个韵组的前几个字符 *)
  match search_chars_by_criteria () with
  | Found chars ->
      let limited_chars = take (min limit (List.length chars)) chars in
      let char_freq_pairs = List.map (fun char -> (char, 1)) limited_chars in
      Found char_freq_pairs
  | NotFound -> NotFound
  | QueryError err -> QueryError err

let analyze_poem_rhyme_scheme (lines : string list) : (int * rhyme_group) list query_result =
  if not !initialized then initialize ();
  try
    let get_line_ending_char line =
      if String.length line > 0 then String.make 1 (String.get line (String.length line - 1))
      else ""
    in

    let rhyme_info =
      List.mapi
        (fun i line ->
          let ending_char = get_line_ending_char line in
          match get_char_rhyme_group ending_char with
          | Found rhyme_group -> Some (i + 1, rhyme_group)
          | _ -> None)
        lines
    in

    let valid_rhyme_info = List.filter_map (fun x -> x) rhyme_info in
    if valid_rhyme_info = [] then NotFound else Found valid_rhyme_info
  with exn -> QueryError ("分析押韵方案失败: " ^ Printexc.to_string exn)

let get_rhyme_group_statistics () : (rhyme_group * int) list query_result =
  if not !initialized then initialize ();
  match Unified_data_engine.load_json_data char_info_source with
  | Success json ->
      let parsed_char_info : (string * char_info) list = parse_char_info_from_json json in
      let rhyme_groups =
        List.map (fun (_, (info : char_info)) -> info.rhyme_group) parsed_char_info
      in
      let group_counts = Hashtbl.create 32 in
      List.iter
        (fun group ->
          let current_count = try Hashtbl.find group_counts group with Not_found -> 0 in
          Hashtbl.replace group_counts group (current_count + 1))
        rhyme_groups;

      let stats = Hashtbl.fold (fun group count acc -> (group, count) :: acc) group_counts [] in
      Found (List.sort (fun (_, a) (_, b) -> compare b a) stats)
  | Failure err -> QueryError ("获取韵组统计失败: " ^ Unified_data_engine.format_error err)

let get_tone_distribution () : (tone_type * int) list query_result =
  if not !initialized then initialize ();
  match Unified_data_engine.load_json_data char_info_source with
  | Success json ->
      let char_info_list = parse_char_info_from_json json in
      let tones = List.map (fun (_, info) -> info.tone) char_info_list in
      let tone_counts = Hashtbl.create 8 in
      List.iter
        (fun tone ->
          let current_count = try Hashtbl.find tone_counts tone with Not_found -> 0 in
          Hashtbl.replace tone_counts tone (current_count + 1))
        tones;

      let stats = Hashtbl.fold (fun tone count acc -> (tone, count) :: acc) tone_counts [] in
      Found stats
  | Failure err -> QueryError ("获取声调分布失败: " ^ Unified_data_engine.format_error err)

let get_data_source_info () : (string * string * int) list =
  if not !initialized then initialize ();
  let sources = Unified_data_engine.list_registered_sources () in
  List.filter_map
    (fun (name, category, source, _) ->
      if category = Poetry then
        let source_type =
          match source with
          | JsonFile _ -> "JSON文件"
          | TextFile _ -> "文本文件"
          | CsvFile _ -> "CSV文件"
          | Embedded _ -> "内嵌数据"
          | External _ -> "外部服务"
        in
        Some (name, source_type, 0) (* 简化实现，条目数量设为0 *)
      else None)
    sources

(** {1 兼容性接口实现} *)

let load_rhyme_data () : (string * rhyme_category * rhyme_group) list =
  if not !initialized then initialize ();
  match Unified_data_engine.load_json_data char_info_source with
  | Success json ->
      let char_info_list = parse_char_info_from_json json in
      List.map (fun (char, info) -> (char, info.rhyme_category, info.rhyme_group)) char_info_list
  | Failure _ -> []

let load_tone_data () : string list * string list * string list * string list =
  if not !initialized then initialize ();
  let ping_chars = match get_chars_by_tone Ping with Found chars -> chars | _ -> [] in
  let shang_chars = match get_chars_by_tone Shang with Found chars -> chars | _ -> [] in
  let qu_chars = match get_chars_by_tone Qu with Found chars -> chars | _ -> [] in
  let ru_chars = match get_chars_by_tone Ru with Found chars -> chars | _ -> [] in
  (ping_chars, shang_chars, qu_chars, ru_chars)

let is_char_available (char : string) : bool =
  match get_char_info char with Found _ -> true | _ -> false

(** {1 错误处理和诊断} *)

let format_query_error (error_msg : string) : string = "诗歌数据查询错误: " ^ error_msg

let validate_data_integrity () : (string * bool * string option) list =
  if not !initialized then initialize ();
  Unified_data_engine.validate_all_sources ()

let get_cache_status () : (string * bool * int) list =
  if not !initialized then initialize ();
  let cache_info = Unified_data_engine.get_cache_info () in
  List.map (fun (name, size_bytes, _) -> (name, true, size_bytes)) cache_info
