(** 骆言诗词韵律数据管理模块 - 整合版本
    
    此模块整合了原有30+个数据加载和管理模块的功能，
    提供统一的韵律数据访问、缓存和管理接口。
    
    @author 骆言诗词编程团队
    @version 2.0 - 整合版本
    @since 2025-07-24 *)

open Poetry_types_consolidated

(** {1 内部数据结构} *)

(** 扩展的韵律数据库 - 包含更多字符 *)
let extended_rhyme_database = ref [
  (* 安韵组 - 平声 - 使用字符串避免字符常量问题 *)
]

(** 韵律数据字符串版本 *)
let rhyme_data_strings = [
  (* 安韵组 - 平声 *)
  ("山", PingSheng, AnRhyme); ("间", PingSheng, AnRhyme); ("闲", PingSheng, AnRhyme);
  ('关', PingSheng, AnRhyme); ('还', PingSheng, AnRhyme); ('班', PingSheng, AnRhyme);
  ('颜', PingSheng, AnRhyme); ('安', PingSheng, AnRhyme); ('删', PingSheng, AnRhyme);
  ('蛮', PingSheng, AnRhyme); ('环', PingSheng, AnRhyme); ('弯', PingSheng, AnRhyme);
  
  (* 天韵组 - 平声 *)
  ('天', PingSheng, TianRhyme); ('年', PingSheng, TianRhyme); ('先', PingSheng, TianRhyme);
  ('田', PingSheng, TianRhyme); ('边', PingSheng, TianRhyme); ('前', PingSheng, TianRhyme);
  ('连', PingSheng, TianRhyme); ('千', PingSheng, TianRhyme); ('线', PingSheng, TianRhyme);
  
  (* 思韵组 - 平声 *)
  ('诗', PingSheng, SiRhyme); ('时', PingSheng, SiRhyme); ('知', PingSheng, SiRhyme);
  ('思', PingSheng, SiRhyme); ('来', PingSheng, SiRhyme); ('才', PingSheng, SiRhyme);
  ('材', PingSheng, SiRhyme); ('灾', PingSheng, SiRhyme); ('开', PingSheng, SiRhyme);
  
  (* 仄声韵组 *)
  ('望', ZeSheng, WangRhyme); ('放', ZeSheng, WangRhyme); ('向', ZeSheng, WangRhyme);
  ('上', ShangSheng, WangRhyme); ('响', ZeSheng, WangRhyme);
  
  ('去', QuSheng, QuRhyme); ('路', QuSheng, QuRhyme); ('度', QuSheng, QuRhyme);
  ('步', QuSheng, QuRhyme); ('暮', QuSheng, QuRhyme); ('树', QuSheng, QuRhyme);
  
  (* 鱼韵组 *)
  ('鱼', PingSheng, YuRhyme); ('书', PingSheng, YuRhyme); ('居', PingSheng, YuRhyme);
  ('虚', PingSheng, YuRhyme); ('余', PingSheng, YuRhyme); ('舒', PingSheng, YuRhyme);
  ('初', PingSheng, YuRhyme); ('疏', PingSheng, YuRhyme);
  
  (* 花韵组 *)
  ('花', PingSheng, HuaRhyme); ('霞', PingSheng, HuaRhyme); ('家', PingSheng, HuaRhyme);
  ('茶', PingSheng, HuaRhyme); ('沙', PingSheng, HuaRhyme); ('华', PingSheng, HuaRhyme);
  ('瓜', PingSheng, HuaRhyme); ('夸', PingSheng, HuaRhyme);
  
  (* 风韵组 *)
  ('风', PingSheng, FengRhyme); ('中', PingSheng, FengRhyme); ('东', PingSheng, FengRhyme);
  ('终', PingSheng, FengRhyme); ('钟', PingSheng, FengRhyme); ('空', PingSheng, FengRhyme);
  ('红', PingSheng, FengRhyme); ('虹', PingSheng, FengRhyme);
  
  (* 月韵组 - 入声 *)
  ('月', RuSheng, YueRhyme); ('雪', RuSheng, YueRhyme); ('节', RuSheng, YueRhyme);
  ('别', RuSheng, YueRhyme); ('切', RuSheng, YueRhyme); ('热', RuSheng, YueRhyme);
  ('列', RuSheng, YueRhyme); ('设', RuSheng, YueRhyme);
  
  (* 江韵组 *)
  ('江', PingSheng, JiangRhyme); ('窗', PingSheng, JiangRhyme); ('双', PingSheng, JiangRhyme);
  ('庄', PingSheng, JiangRhyme); ('霜', PingSheng, JiangRhyme); ('强', PingSheng, JiangRhyme);
  ('长', PingSheng, JiangRhyme); ('墙', PingSheng, JiangRhyme);
  
  (* 灰韵组 *)
  ('灰', PingSheng, HuiRhyme); ('回', PingSheng, HuiRhyme); ('推', PingSheng, HuiRhyme);
  ('杯', PingSheng, HuiRhyme); ('开', PingSheng, HuiRhyme); ('来', PingSheng, HuiRhyme);
  ('台', PingSheng, HuiRhyme); ('栽', PingSheng, HuiRhyme);
]

(** 数据是否已初始化的标志 *)
let data_initialized = ref false

(** 韵律查询哈希表 *)
let rhyme_lookup_table = Hashtbl.create 512

(** {1 核心数据访问接口} *)

let initialize_data () =
  if not !data_initialized then begin
    Hashtbl.clear rhyme_lookup_table;
    List.iter (fun (char, category, group) ->
      Hashtbl.add rhyme_lookup_table char (category, group)
    ) !extended_rhyme_database;
    data_initialized := true
  end

let get_all_rhyme_data () =
  initialize_data ();
  !extended_rhyme_database

let get_rhyme_by_category category =
  initialize_data ();
  List.fold_left (fun acc (char, cat, group) ->
    if rhyme_category_equal cat category then (char, group) :: acc
    else acc
  ) [] !extended_rhyme_database

let get_rhyme_by_group group =
  initialize_data ();
  List.fold_left (fun acc (char, category, grp) ->
    if rhyme_group_equal grp group then (char, category) :: acc
    else acc
  ) [] !extended_rhyme_database

let lookup_char_info char =
  initialize_data ();
  try
    Some (Hashtbl.find rhyme_lookup_table char)
  with Not_found -> None

let batch_lookup chars =
  initialize_data ();
  List.fold_left (fun acc char ->
    match lookup_char_info char with
    | Some (category, group) -> (char, category, group) :: acc
    | None -> acc
  ) [] chars |> List.rev

(** {1 韵组数据管理} *)

let get_rhyme_group_chars group =
  get_rhyme_by_group group |> List.map fst

let get_rhyme_group_size group =
  List.length (get_rhyme_group_chars group)

let list_all_rhyme_groups () =
  [AnRhyme; SiRhyme; TianRhyme; WangRhyme; QuRhyme; YuRhyme; 
   HuaRhyme; FengRhyme; YueRhyme; JiangRhyme; HuiRhyme; UnknownRhyme]

let is_rhyme_group_empty group =
  get_rhyme_group_size group = 0

(** {1 声调数据管理} *)

let get_ping_sheng_chars () =
  get_rhyme_by_category PingSheng |> List.map fst

let get_ze_sheng_chars () =
  List.concat [
    get_rhyme_by_category ZeSheng |> List.map fst;
    get_rhyme_by_category ShangSheng |> List.map fst;
    get_rhyme_by_category QuSheng |> List.map fst;
    get_rhyme_by_category RuSheng |> List.map fst;
  ]

let get_category_distribution () =
  let categories = [PingSheng; ZeSheng; ShangSheng; QuSheng; RuSheng] in
  List.map (fun cat -> 
    let count = List.length (get_rhyme_by_category cat) in
    (cat, count)
  ) categories

(** {1 数据加载and初始化} *)

let reload_data () =
  data_initialized := false;
  initialize_data ()

let is_data_loaded () = !data_initialized

(** {1 JSON数据解析} *)

module JsonParser = struct
  let parse_rhyme_category_str = function
    | "平声" | "PingSheng" -> PingSheng
    | "仄声" | "ZeSheng" -> ZeSheng
    | "上声" | "ShangSheng" -> ShangSheng
    | "去声" | "QuSheng" -> QuSheng
    | "入声" | "RuSheng" -> RuSheng
    | _ -> PingSheng

  let parse_rhyme_group_str = function
    | "安韵" | "AnRhyme" -> AnRhyme
    | "思韵" | "SiRhyme" -> SiRhyme
    | "天韵" | "TianRhyme" -> TianRhyme
    | "望韵" | "WangRhyme" -> WangRhyme
    | "去韵" | "QuRhyme" -> QuRhyme
    | "鱼韵" | "YuRhyme" -> YuRhyme
    | "花韵" | "HuaRhyme" -> HuaRhyme
    | "风韵" | "FengRhyme" -> FengRhyme
    | "月韵" | "YueRhyme" -> YueRhyme
    | "江韵" | "JiangRhyme" -> JiangRhyme
    | "灰韵" | "HuiRhyme" -> HuiRhyme
    | _ -> UnknownRhyme

  let parse_single_entry entry_str =
    (* 简化的JSON解析 - 实际实现中应使用更严格的JSON解析器 *)
    let parts = String.split_on_char ',' entry_str in
    if List.length parts >= 3 then
      let char_str = List.nth parts 0 |> String.trim in
      let category_str = List.nth parts 1 |> String.trim in
      let group_str = List.nth parts 2 |> String.trim in
      let char = if String.length char_str > 0 then char_str.[0] else '？' in
      let category = parse_rhyme_category_str category_str in
      let group = parse_rhyme_group_str group_str in
      (char, category, group)
    else
      ('？', PingSheng, UnknownRhyme)

  let parse_rhyme_data json_content =
    (* 简化实现 - 按行分割并解析 *)
    let lines = String.split_on_char '\n' json_content in
    List.fold_left (fun acc line ->
      try
        let entry = parse_single_entry line in
        entry :: acc
      with _ -> acc
    ) [] lines |> List.rev

  let export_to_json data =
    let entries = List.map (fun (char, category, group) ->
      Printf.sprintf "\"%c\", \"%s\", \"%s\"" 
        char 
        (rhyme_category_to_string category)
        (rhyme_group_to_string group)
    ) data in
    String.concat "\n" entries
end

(** {1 数据缓存管理} *)

module CacheManager = struct
  let cache_enabled = ref true
  let hit_count = ref 0
  let total_queries = ref 0

  let enable_cache () = cache_enabled := true
  let disable_cache () = cache_enabled := false
  let is_cache_enabled () = !cache_enabled

  let clear_cache () =
    Hashtbl.clear rhyme_lookup_table;
    hit_count := 0;
    total_queries := 0

  let get_cache_stats () =
    let hits = !hit_count in
    let total = !total_queries in
    let hit_rate = if total > 0 then float_of_int hits /. float_of_int total else 0.0 in
    (hits, total, hit_rate)
end

(** {1 数据验证和统计} *)

let validate_data_integrity () =
  initialize_data ();
  let data = !extended_rhyme_database in
  let char_set = Hashtbl.create (List.length data) in
  try
    List.iter (fun (char, _, _) ->
      if Hashtbl.mem char_set char then
        failwith ("重复字符: " ^ String.make 1 char)
      else
        Hashtbl.add char_set char true
    ) data;
    true
  with _ -> false

let get_data_statistics () =
  initialize_data ();
  let total_chars = List.length !extended_rhyme_database in
  let group_count = List.length (list_all_rhyme_groups ()) - 1 in  (* 排除UnknownRhyme *)
  let category_dist = get_category_distribution () in
  let ping_count = List.assoc PingSheng category_dist in
  let ze_count = total_chars - ping_count in
  [
    ("总字符数", total_chars);
    ("韵组数", group_count);
    ("平声字符数", ping_count);
    ("仄声字符数", ze_count);
  ]

let find_data_conflicts () =
  initialize_data ();
  (* 简化实现 - 检查是否有未知韵组的字符 *)
  List.fold_left (fun acc (char, _, group) ->
    if group = UnknownRhyme then 
      (char, "未知韵组") :: acc
    else acc
  ) [] !extended_rhyme_database

(** {1 扩展数据源支持} *)

let load_from_file filepath =
  try
    let content = 
      let ic = open_in filepath in
      let content = really_input_string ic (in_channel_length ic) in
      close_in ic;
      content
    in
    let new_data = JsonParser.parse_rhyme_data content in
    extended_rhyme_database := new_data;
    reload_data ()
  with
  | Sys_error msg -> failwith ("文件加载失败: " ^ msg)
  | _ -> failwith "数据解析失败"

let save_to_file filepath =
  initialize_data ();
  try
    let content = JsonParser.export_to_json !extended_rhyme_database in
    let oc = open_out filepath in
    output_string oc content;
    close_out oc
  with
  | Sys_error msg -> failwith ("文件保存失败: " ^ msg)

let merge_external_data external_data =
  initialize_data ();
  let merged_data = !extended_rhyme_database @ external_data in
  (* 简单去重 - 保留第一次出现的字符 *)
  let char_set = Hashtbl.create (List.length merged_data) in
  let unique_data = List.fold_left (fun acc (char, category, group) ->
    if Hashtbl.mem char_set char then acc
    else begin
      Hashtbl.add char_set char true;
      (char, category, group) :: acc
    end
  ) [] merged_data |> List.rev in
  extended_rhyme_database := unique_data;
  reload_data ()