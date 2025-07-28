(** 统一韵律数据核心模块实现
    
    作者：Alpha Agent，技术债务专员
    日期：2025年7月28日
    目标：Fix #1538 - 统一Poetry模块中的韵律数据类型定义和功能 *)

(** {1 核心类型定义} *)

type rhyme_category =
  | PingSheng   
  | ZeSheng     
  | ShangSheng  
  | QuSheng     
  | RuSheng     

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
  | XueRhyme    
  | JiangRhyme  
  | HuiRhyme    
  | UnknownRhyme 

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
  | XueRhyme -> "学韵"
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
  | "学韵" -> XueRhyme
  | "江韵" -> JiangRhyme
  | "辉韵" -> HuiRhyme
  | "未知韵" -> UnknownRhyme
  | s -> invalid_arg ("Unknown rhyme group: " ^ s)

(** {1 内部辅助函数} *)

let is_valid_chinese_char char =
  (* 简单的汉字检查 - 检查Unicode范围 *)
  let len = String.length char in
  len >= 3 && len <= 4  (* UTF-8编码的汉字通常是3-4字节 *)

let load_default_data () =
  (* 加载默认的韵律数据 - 这里先提供一些示例数据 *)
  let sample_data = [
    { character = "天"; category = PingSheng; group = TianRhyme; tone_mark = Some 1; traditional_variant = None; notes = None };
    { character = "安"; category = PingSheng; group = AnRhyme; tone_mark = Some 1; traditional_variant = None; notes = None };
    { character = "思"; category = PingSheng; group = SiRhyme; tone_mark = Some 1; traditional_variant = None; notes = None };
    { character = "王"; category = ZeSheng; group = WangRhyme; tone_mark = Some 2; traditional_variant = None; notes = None };
    { character = "语"; category = ShangSheng; group = YuRhyme; tone_mark = Some 3; traditional_variant = None; notes = None };
    { character = "去"; category = QuSheng; group = QuRhyme; tone_mark = Some 4; traditional_variant = None; notes = None };
  ] in
  List.iter (fun entry -> 
    Hashtbl.replace rhyme_data_table entry.character entry
  ) sample_data

(** {1 核心查询接口实现} *)

let lookup_rhyme char =
  if not !initialized then
    raise (Rhyme_data_error "Rhyme data not initialized");
  
  incr cache_queries;
  
  (* 检查缓存 *)
  if !cache_enabled then
    match Hashtbl.find_opt cache_table char with
    | Some result -> 
        incr cache_hits;
        result
    | None -> 
        let result = Hashtbl.find_opt rhyme_data_table char in
        Hashtbl.replace cache_table char result;
        result
  else
    Hashtbl.find_opt rhyme_data_table char

let lookup_batch chars =
  List.filter_map lookup_rhyme chars

let get_rhyme_group_chars group =
  if not !initialized then
    raise (Rhyme_data_error "Rhyme data not initialized");
  
  let results = ref [] in
  Hashtbl.iter (fun char entry ->
    if entry.group = group then
      results := char :: !results
  ) rhyme_data_table;
  !results

let get_category_chars category =
  if not !initialized then
    raise (Rhyme_data_error "Rhyme data not initialized");
  
  let results = ref [] in
  Hashtbl.iter (fun char entry ->
    if entry.category = category then
      results := char :: !results
  ) rhyme_data_table;
  !results

(** {1 数据管理实现} *)

let initialize () =
  if not !initialized then (
    Hashtbl.clear rhyme_data_table;
    Hashtbl.clear cache_table;
    load_default_data ();
    initialized := true
  )

let reload () =
  initialized := false;
  initialize ()

let is_initialized () = !initialized

let get_stats () =
  let total_entries = Hashtbl.length rhyme_data_table in
  let categories = ref [] in
  let groups = ref [] in
  
  Hashtbl.iter (fun _ entry ->
    let cat_str = string_of_rhyme_category entry.category in
    let group_str = string_of_rhyme_group entry.group in
    if not (List.mem cat_str !categories) then
      categories := cat_str :: !categories;
    if not (List.mem group_str !groups) then
      groups := group_str :: !groups;
  ) rhyme_data_table;
  
  [
    ("total_entries", total_entries);
    ("categories", List.length !categories);
    ("groups", List.length !groups);
    ("cache_hits", !cache_hits);
    ("cache_queries", !cache_queries);
  ]

(** {1 验证和检查实现} *)

let validate_character char =
  is_valid_chinese_char char

let is_rhyme_match char1 char2 =
  match lookup_rhyme char1, lookup_rhyme char2 with
  | Some entry1, Some entry2 -> entry1.group = entry2.group
  | _ -> false

let find_rhyme_conflicts () =
  (* 简单实现 - 寻找同一字符在不同韵组的情况 *)
  let conflicts = ref [] in
  let seen = Hashtbl.create 256 in
  
  Hashtbl.iter (fun char entry ->
    match Hashtbl.find_opt seen char with
    | Some existing_group when existing_group <> entry.group ->
        conflicts := (char, "Multiple rhyme groups") :: !conflicts
    | _ -> Hashtbl.replace seen char entry.group
  ) rhyme_data_table;
  
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
    let hit_rate = if !cache_queries > 0 then
      float_of_int !cache_hits /. float_of_int !cache_queries
    else 0.0 in
    (!cache_hits, !cache_queries, hit_rate)
end

(** {1 Export模块实现} *)

module Export = struct
  let to_json entries =
    (* 简单的JSON序列化实现 *)
    let entry_to_json entry =
      Printf.sprintf 
        {|{"character":"%s","category":"%s","group":"%s","tone_mark":%s}|}
        entry.character
        (string_of_rhyme_category entry.category)
        (string_of_rhyme_group entry.group)
        (match entry.tone_mark with Some t -> string_of_int t | None -> "null")
    in
    let json_entries = String.concat "," (List.map entry_to_json entries) in
    "[" ^ json_entries ^ "]"
  
  let from_json _json_str =
    (* 简化的JSON解析 - 在实际应用中应该使用专门的JSON库 *)
    raise (Rhyme_data_error "JSON parsing not implemented yet - use proper JSON library")
  
  let to_csv entries =
    let header = "character,category,group,tone_mark\n" in
    let entry_to_csv entry =
      Printf.sprintf "%s,%s,%s,%s\n"
        entry.character
        (string_of_rhyme_category entry.category)
        (string_of_rhyme_group entry.group)
        (match entry.tone_mark with Some t -> string_of_int t | None -> "")
    in
    header ^ String.concat "" (List.map entry_to_csv entries)
end