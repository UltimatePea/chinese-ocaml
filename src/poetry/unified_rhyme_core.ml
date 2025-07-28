(** 统一韵律数据核心模块实现

    作者：Alpha Agent，技术债务专员 日期：2025年7月28日 目标：Fix #1538 - 统一Poetry模块中的韵律数据类型定义和功能 *)

(** {1 核心类型定义} *)

(* 使用中央类型定义，消除重复 *)
open Poetry_core.Rhyme_core_types

(* Re-export central types for backward compatibility *)
type rhyme_category = Poetry_core.Rhyme_core_types.rhyme_category
type rhyme_group = Poetry_core.Rhyme_core_types.rhyme_group

type rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  tone_mark : int option;
  traditional_variant : string option;
  notes : string option;
}

(** {1 异常类型} *)

exception Rhyme_data_error of string
exception Invalid_character of string
exception Rhyme_not_found of string

(** {1 内部状态} *)

(* 韵律数据存储 - 使用Hashtbl提高查询性能 *)
let rhyme_data_table : (string, rhyme_entry) Hashtbl.t = Hashtbl.create 2048

(* 初始化状态标记 *)
let initialized = ref false

(* 缓存状态 *)
let cache_enabled = ref true
let cache_table : (string, rhyme_entry option) Hashtbl.t = Hashtbl.create 256
let cache_hits = ref 0
let cache_queries = ref 0

(** {1 类型转换实现} *)

let string_of_rhyme_category = function
  | PingSheng -> "平声"
  | ZeSheng -> "仄声"
  | ShangSheng -> "上声"
  | QuSheng -> "去声"
  | RuSheng -> "入声"

let string_of_rhyme_group = function
  | AnRhyme -> "安韵"
  | SiRhyme -> "思韵"
  | TianRhyme -> "天韵"
  | WangRhyme -> "王韵"
  | QuRhyme -> "趋韵"
  | YuRhyme -> "语韵"
  | HuaRhyme -> "华韵"
  | FengRhyme -> "风韵"
  | YueRhyme -> "月韵"
  | JiangRhyme -> "江韵"
  | HuiRhyme -> "辉韵"
  | UnknownRhyme -> "未知韵"

let rhyme_category_of_string = function
  | "平声" -> PingSheng
  | "仄声" -> ZeSheng
  | "上声" -> ShangSheng
  | "去声" -> QuSheng
  | "入声" -> RuSheng
  | s -> invalid_arg ("Unknown rhyme category: " ^ s)

let rhyme_group_of_string = function
  | "安韵" -> AnRhyme
  | "思韵" -> SiRhyme
  | "天韵" -> TianRhyme
  | "王韵" -> WangRhyme
  | "趋韵" -> QuRhyme
  | "语韵" -> YuRhyme
  | "华韵" -> HuaRhyme
  | "风韵" -> FengRhyme
  | "月韵" -> YueRhyme
  | "学韵" -> YueRhyme  (* Map old XueRhyme to YueRhyme for compatibility *)
  | "江韵" -> JiangRhyme
  | "辉韵" -> HuiRhyme
  | "未知韵" -> UnknownRhyme
  | s -> invalid_arg ("Unknown rhyme group: " ^ s)

(** {1 内部辅助函数} *)

let is_valid_chinese_char char =
  (* 检查是否为有效的中文字符 - 改进版字节长度检查和简单启发式 *)
  let len = String.length char in
  if len = 0 then false
  else if len >= 3 && len <= 4 then
    (* UTF-8编码的汉字通常是3字节，检查第一个字节的模式 *)
    let first_byte = Char.code char.[0] in
    (* 检查是否在CJK统一汉字的UTF-8编码范围内 *)
    (* 0x4E00-0x9FFF 对应 UTF-8: 0xE4-0xE9 开头 *)
    (first_byte >= 0xE4 && first_byte <= 0xE9)
    (* 其他常见中文字符的UTF-8字节模式 *)
    || first_byte = 0xE3
    ||
    (* 一些标点和符号 *)
    first_byte = 0xEF (* 一些兼容字符 *)
  else false

let load_json_file filename =
  let ic = open_in filename in
  let content = really_input_string ic (in_channel_length ic) in
  close_in ic;
  content

let parse_rhyme_entry json_obj =
  (* 非常简单的JSON解析 - 专门针对我们的格式 *)
  try
    (* 预期格式: {"char": "春", "category": "PingSheng", "group": "AnRhyme"} *)
    let extract_value_between start_str end_str text =
      try
        let start_pos = Str.search_forward (Str.regexp (Str.quote start_str)) text 0 in
        let value_start = start_pos + String.length start_str in
        let end_pos = Str.search_forward (Str.regexp (Str.quote end_str)) text value_start in
        Some (String.sub text value_start (end_pos - value_start))
      with Not_found -> None
    in

    let char_opt = extract_value_between "\"char\": \"" "\"" json_obj in
    let category_opt = extract_value_between "\"category\": \"" "\"" json_obj in
    let group_opt = extract_value_between "\"group\": \"" "\"" json_obj in

    match char_opt with
    | Some char ->
        let category_str = Option.value category_opt ~default:"PingSheng" in
        let group_str = Option.value group_opt ~default:"UnknownRhyme" in
        let category =
          match category_str with
          | "PingSheng" -> PingSheng
          | "ZeSheng" -> ZeSheng
          | "ShangSheng" -> ShangSheng
          | "QuSheng" -> QuSheng
          | "RuSheng" -> RuSheng
          | _ -> PingSheng
        in
        let group =
          match group_str with
          | "AnRhyme" -> AnRhyme
          | "SiRhyme" -> SiRhyme
          | "TianRhyme" -> TianRhyme
          | "WangRhyme" -> WangRhyme
          | "QuRhyme" -> QuRhyme
          | "YuRhyme" -> YuRhyme
          | "HuaRhyme" -> HuaRhyme
          | "FengRhyme" -> FengRhyme
          | "YueRhyme" -> YueRhyme
          | "XueRhyme" -> YueRhyme  (* Map old XueRhyme to YueRhyme for compatibility *)
          | "JiangRhyme" -> JiangRhyme
          | "HuiRhyme" -> HuiRhyme
          | _ -> UnknownRhyme
        in
        Some
          {
            character = char;
            category;
            group;
            tone_mark = None;
            traditional_variant = None;
            notes = None;
          }
    | None -> None
  with _ -> None

let load_data_from_json filename =
  try
    let content = load_json_file filename in
    (* 简单的JSON数组解析 - 先移除外层数组括号，然后分割对象 *)
    let content = String.trim content in
    let content =
      if String.length content > 0 && content.[0] = '[' then
        String.sub content 1 (String.length content - 1)
      else content
    in
    let content =
      if String.length content > 0 && content.[String.length content - 1] = ']' then
        String.sub content 0 (String.length content - 1)
      else content
    in

    (* 分割JSON对象 *)
    let objects = Str.split (Str.regexp "},[ \t\n\r]*{") content in
    let clean_objects =
      List.map
        (fun obj ->
          let obj = String.trim obj in
          let obj = if String.length obj > 0 && obj.[0] <> '{' then "{" ^ obj else obj in
          let obj =
            if String.length obj > 0 && obj.[String.length obj - 1] <> '}' then obj ^ "}" else obj
          in
          obj)
        objects
    in
    List.filter_map parse_rhyme_entry clean_objects
  with
  | Sys_error _ -> []
  | _ -> []

let load_default_data () =
  (* 尝试从真实数据文件加载 *)
  let data_files =
    [
      "/home/zc/chinese-ocaml-worktrees/chinese-ocaml/data/poetry/sample_rhyme_data.json";
      "data/poetry/sample_rhyme_data.json";
      "../data/poetry/sample_rhyme_data.json";
      "../../data/poetry/sample_rhyme_data.json";
    ]
  in
  let rec try_load_files = function
    | [] ->
        (* 如果没有找到数据文件，提供一些基本数据以确保功能可用 *)
        let basic_data =
          [
            {
              character = "天";
              category = PingSheng;
              group = TianRhyme;
              tone_mark = Some 1;
              traditional_variant = None;
              notes = None;
            };
            {
              character = "安";
              category = PingSheng;
              group = AnRhyme;
              tone_mark = Some 1;
              traditional_variant = None;
              notes = None;
            };
            {
              character = "思";
              category = PingSheng;
              group = SiRhyme;
              tone_mark = Some 1;
              traditional_variant = None;
              notes = None;
            };
          ]
        in
        basic_data
    | file :: rest ->
        let data = load_data_from_json file in
        if List.length data > 0 then data else try_load_files rest
  in
  let rhyme_data = try_load_files data_files in
  List.iter (fun entry -> Hashtbl.replace rhyme_data_table entry.character entry) rhyme_data

(** {1 核心查询接口实现} *)

let lookup_rhyme char =
  if not !initialized then raise (Rhyme_data_error "Rhyme data not initialized");

  incr cache_queries;

  (* 检查缓存 *)
  if !cache_enabled then (
    match Hashtbl.find_opt cache_table char with
    | Some result ->
        incr cache_hits;
        result
    | None ->
        let result = Hashtbl.find_opt rhyme_data_table char in
        Hashtbl.replace cache_table char result;
        result)
  else Hashtbl.find_opt rhyme_data_table char

let lookup_batch chars = List.filter_map lookup_rhyme chars

let get_rhyme_group_chars group =
  if not !initialized then raise (Rhyme_data_error "Rhyme data not initialized");

  let results = ref [] in
  Hashtbl.iter
    (fun char entry -> if entry.group = group then results := char :: !results)
    rhyme_data_table;
  !results

let get_category_chars category =
  if not !initialized then raise (Rhyme_data_error "Rhyme data not initialized");

  let results = ref [] in
  Hashtbl.iter
    (fun char entry -> if entry.category = category then results := char :: !results)
    rhyme_data_table;
  !results

(** {1 数据管理实现} *)

let initialize () =
  if not !initialized then (
    Hashtbl.clear rhyme_data_table;
    Hashtbl.clear cache_table;
    load_default_data ();
    initialized := true)

let reload () =
  initialized := false;
  initialize ()

let is_initialized () = !initialized

let get_stats () =
  let total_entries = Hashtbl.length rhyme_data_table in
  let categories = ref [] in
  let groups = ref [] in

  Hashtbl.iter
    (fun _ entry ->
      let cat_str = string_of_rhyme_category entry.category in
      let group_str = string_of_rhyme_group entry.group in
      if not (List.mem cat_str !categories) then categories := cat_str :: !categories;
      if not (List.mem group_str !groups) then groups := group_str :: !groups)
    rhyme_data_table;

  [
    ("total_entries", total_entries);
    ("categories", List.length !categories);
    ("groups", List.length !groups);
    ("cache_hits", !cache_hits);
    ("cache_queries", !cache_queries);
  ]

(** {1 验证和检查实现} *)

let validate_character char = is_valid_chinese_char char

let is_rhyme_match char1 char2 =
  match (lookup_rhyme char1, lookup_rhyme char2) with
  | Some entry1, Some entry2 -> entry1.group = entry2.group
  | _ -> false

let find_rhyme_conflicts () =
  (* 简单实现 - 寻找同一字符在不同韵组的情况 *)
  let conflicts = ref [] in
  let seen = Hashtbl.create 256 in

  Hashtbl.iter
    (fun char entry ->
      match Hashtbl.find_opt seen char with
      | Some existing_group when existing_group <> entry.group ->
          conflicts := (char, "Multiple rhyme groups") :: !conflicts
      | _ -> Hashtbl.replace seen char entry.group)
    rhyme_data_table;

  !conflicts

(** {1 Cache模块实现} *)

module Cache = struct
  let enable () = cache_enabled := true
  let disable () = cache_enabled := false

  let clear () =
    Hashtbl.clear cache_table;
    cache_hits := 0;
    cache_queries := 0

  let stats () =
    let hit_rate =
      if !cache_queries > 0 then float_of_int !cache_hits /. float_of_int !cache_queries else 0.0
    in
    (!cache_hits, !cache_queries, hit_rate)
end

(** {1 Export模块实现} *)

module Export = struct
  let to_json entries =
    (* 简单的JSON序列化实现 *)
    let entry_to_json entry =
      Printf.sprintf {|{"character":"%s","category":"%s","group":"%s","tone_mark":%s}|}
        entry.character
        (string_of_rhyme_category entry.category)
        (string_of_rhyme_group entry.group)
        (match entry.tone_mark with Some t -> string_of_int t | None -> "null")
    in
    let json_entries = String.concat "," (List.map entry_to_json entries) in
    "[" ^ json_entries ^ "]"

  let from_json json_str =
    (* 使用我们已经实现的JSON解析功能 *)
    try
      let objects = Str.split (Str.regexp "},\\s*{") json_str in
      let clean_objects =
        List.map
          (fun obj ->
            let obj = if String.get obj 0 <> '{' then "{" ^ obj else obj in
            let obj = if String.get obj (String.length obj - 1) <> '}' then obj ^ "}" else obj in
            obj)
          objects
      in
      List.filter_map parse_rhyme_entry clean_objects
    with _ -> raise (Rhyme_data_error "Invalid JSON format for rhyme data")

  let to_csv entries =
    let header = "character,category,group,tone_mark\n" in
    let entry_to_csv entry =
      Printf.sprintf "%s,%s,%s,%s\n" entry.character
        (string_of_rhyme_category entry.category)
        (string_of_rhyme_group entry.group)
        (match entry.tone_mark with Some t -> string_of_int t | None -> "")
    in
    header ^ String.concat "" (List.map entry_to_csv entries)
end
