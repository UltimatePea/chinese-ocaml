(** Poetry Data Unified Consolidated Module - Issue #1999
 * 
 * 统一的韵律数据访问接口模块
 * Author: Whisky, PR Worker
 * 
 * 整合以下模块的功能：
 * - data/ 目录下所有数据文件
 * - unified_rhyme_data.ml
 * - poetry_data_unified.ml
 * - data_cache_manager.ml
 * - poetry_data_loader.ml
 * 
 * 目标：提供统一、高效的韵律数据访问服务
 *)

open Poetry_core_consolidated

(** {1 数据源类型定义} *)

(** 数据加载状态 *)
type data_load_status = 
  | NotLoaded
  | Loading
  | Loaded
  | LoadError of string

(** 数据源类型 *)
type data_source = 
  | InMemory      (** 内存数据 *)
  | JsonFile      (** JSON文件 *)
  | External      (** 外部数据源 *)

(** 数据统计信息 *)
type data_statistics = {
  total_rhyme_entries: int;
  rhyme_groups_count: int;
  tone_patterns_count: int;
  load_time: float;
  memory_usage: int;
}

(** {1 统一数据存储} *)

(** 完整的韵律数据集 *)
let comprehensive_rhyme_database = [
  (* 平声一部：东韵 *)
  ("东", { category = PingSheng; group = Feng; tone_pattern = Some 1; char = "东" });
  ("同", { category = PingSheng; group = Feng; tone_pattern = Some 2; char = "同" });
  ("铜", { category = PingSheng; group = Feng; tone_pattern = Some 2; char = "铜" });
  ("桐", { category = PingSheng; group = Feng; tone_pattern = Some 2; char = "桐" });
  ("童", { category = PingSheng; group = Feng; tone_pattern = Some 2; char = "童" });
  ("雄", { category = PingSheng; group = Feng; tone_pattern = Some 2; char = "雄" });
  ("熊", { category = PingSheng; group = Feng; tone_pattern = Some 2; char = "熊" });
  ("弓", { category = PingSheng; group = Feng; tone_pattern = Some 1; char = "弓" });
  ("宫", { category = PingSheng; group = Feng; tone_pattern = Some 1; char = "宫" });
  ("冬", { category = PingSheng; group = Feng; tone_pattern = Some 1; char = "冬" });
  ("终", { category = PingSheng; group = Feng; tone_pattern = Some 1; char = "终" });
  ("空", { category = PingSheng; group = Feng; tone_pattern = Some 1; char = "空" });
  ("风", { category = PingSheng; group = Feng; tone_pattern = Some 1; char = "风" });
  ("丰", { category = PingSheng; group = Feng; tone_pattern = Some 1; char = "丰" });
  ("红", { category = PingSheng; group = Feng; tone_pattern = Some 2; char = "红" });
  ("虹", { category = PingSheng; group = Feng; tone_pattern = Some 2; char = "虹" });
  ("鸿", { category = PingSheng; group = Feng; tone_pattern = Some 2; char = "鸿" });

  (* 平声二部：花韵 *)
  ("花", { category = PingSheng; group = Hua; tone_pattern = Some 1; char = "花" });
  ("家", { category = PingSheng; group = Hua; tone_pattern = Some 1; char = "家" });
  ("沙", { category = PingSheng; group = Hua; tone_pattern = Some 1; char = "沙" });
  ("茶", { category = PingSheng; group = Hua; tone_pattern = Some 2; char = "茶" });
  ("华", { category = PingSheng; group = Hua; tone_pattern = Some 2; char = "华" });
  ("霞", { category = PingSheng; group = Hua; tone_pattern = Some 2; char = "霞" });
  ("夏", { category = ShangSheng; group = Hua; tone_pattern = Some 4; char = "夏" });
  ("下", { category = QuSheng; group = Hua; tone_pattern = Some 4; char = "下" });
  ("瓜", { category = PingSheng; group = Hua; tone_pattern = Some 1; char = "瓜" });
  ("哗", { category = PingSheng; group = Hua; tone_pattern = Some 2; char = "哗" });
  ("芽", { category = PingSheng; group = Hua; tone_pattern = Some 2; char = "芽" });
  ("牙", { category = PingSheng; group = Hua; tone_pattern = Some 2; char = "牙" });
  ("涯", { category = PingSheng; group = Hua; tone_pattern = Some 2; char = "涯" });
  ("崖", { category = PingSheng; group = Hua; tone_pattern = Some 2; char = "崖" });

  (* 上声部：语韵 *)
  ("语", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "语" });
  ("雨", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "雨" });
  ("古", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "古" });
  ("土", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "土" });
  ("五", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "五" });
  ("武", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "武" });
  ("舞", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "舞" });
  ("府", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "府" });
  ("虎", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "虎" });
  ("鼓", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "鼓" });
  ("普", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "普" });
  ("谱", { category = ShangSheng; group = Yu; tone_pattern = Some 3; char = "谱" });

  (* 去声部：jiang韵 *)
  ("江", { category = PingSheng; group = Jiang; tone_pattern = Some 1; char = "江" });
  ("长", { category = PingSheng; group = Jiang; tone_pattern = Some 2; char = "长" });
  ("阳", { category = PingSheng; group = Jiang; tone_pattern = Some 2; char = "阳" });
  ("光", { category = PingSheng; group = Jiang; tone_pattern = Some 1; char = "光" });
  ("王", { category = PingSheng; group = Jiang; tone_pattern = Some 2; char = "王" });
  ("黄", { category = PingSheng; group = Jiang; tone_pattern = Some 2; char = "黄" });
  ("香", { category = PingSheng; group = Jiang; tone_pattern = Some 1; char = "香" });
  ("方", { category = PingSheng; group = Jiang; tone_pattern = Some 1; char = "方" });
  ("堂", { category = PingSheng; group = Jiang; tone_pattern = Some 2; char = "堂" });
  ("党", { category = ShangSheng; group = Jiang; tone_pattern = Some 3; char = "党" });
  ("强", { category = PingSheng; group = Jiang; tone_pattern = Some 2; char = "强" });
  ("张", { category = PingSheng; group = Jiang; tone_pattern = Some 1; char = "张" });

  (* 入声部：月韵 *)
  ("月", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "月" });
  ("雪", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "雪" });
  ("别", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "别" });
  ("节", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "节" });
  ("血", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "血" });
  ("铁", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "铁" });
  ("烈", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "烈" });
  ("热", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "热" });
  ("切", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "切" });
  ("列", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "列" });
  ("缺", { category = RuSheng; group = Yue; tone_pattern = Some 4; char = "缺" });

  (* 回韵部 *)
  ("回", { category = PingSheng; group = Hui; tone_pattern = Some 2; char = "回" });
  ("来", { category = PingSheng; group = Hui; tone_pattern = Some 2; char = "来" });
  ("台", { category = PingSheng; group = Hui; tone_pattern = Some 2; char = "台" });
  ("开", { category = PingSheng; group = Hui; tone_pattern = Some 1; char = "开" });
  ("才", { category = PingSheng; group = Hui; tone_pattern = Some 2; char = "才" });
  ("材", { category = PingSheng; group = Hui; tone_pattern = Some 2; char = "材" });
  ("财", { category = PingSheng; group = Hui; tone_pattern = Some 2; char = "财" });
  ("裁", { category = PingSheng; group = Hui; tone_pattern = Some 2; char = "裁" });
  ("哀", { category = PingSheng; group = Hui; tone_pattern = Some 1; char = "哀" });
  ("怀", { category = PingSheng; group = Hui; tone_pattern = Some 2; char = "怀" });
  ("槐", { category = PingSheng; group = Hui; tone_pattern = Some 2; char = "槐" });
]

(** 数据加载状态 *)
let data_status = ref NotLoaded

(** 数据统计 *)
let data_stats = ref {
  total_rhyme_entries = 0;
  rhyme_groups_count = 0;
  tone_patterns_count = 0;
  load_time = 0.0;
  memory_usage = 0;
}

(** 主数据缓存 *)
let main_data_cache = Hashtbl.create 10000

(** 韵部索引缓存 *)
let rhyme_group_cache = Hashtbl.create 100

(** {1 数据加载管理} *)

(** 计算数据统计信息 *)
let calculate_statistics data =
  let total_entries = List.length data in
  let unique_groups = 
    data
    |> List.map (fun (_, info) -> info.group)
    |> List.sort_uniq compare
    |> List.length
  in
  let unique_tones =
    data
    |> List.filter_map (fun (_, info) -> info.tone_pattern)
    |> List.sort_uniq compare
    |> List.length
  in
  {
    total_rhyme_entries = total_entries;
    rhyme_groups_count = unique_groups;
    tone_patterns_count = unique_tones;
    load_time = 0.0;
    memory_usage = total_entries * 64; (* 估算内存使用 *)
  }

(** 加载数据到缓存 *)
let load_data_to_cache () =
  if !data_status = NotLoaded then (
    data_status := Loading;
    let start_time = Sys.time () in
    
    (* 清空现有缓存 *)
    Hashtbl.clear main_data_cache;
    Hashtbl.clear rhyme_group_cache;
    
    (* 加载主数据 *)
    List.iter (fun (char, info) ->
      Hashtbl.replace main_data_cache char info
    ) comprehensive_rhyme_database;
    
    (* 建立韵部索引 *)
    List.iter (fun (char, info) ->
      let group_chars = 
        try Hashtbl.find rhyme_group_cache info.group
        with Not_found -> []
      in
      Hashtbl.replace rhyme_group_cache info.group (char :: group_chars)
    ) comprehensive_rhyme_database;
    
    let load_time = Sys.time () -. start_time in
    let stats = calculate_statistics comprehensive_rhyme_database in
    data_stats := { stats with load_time = load_time };
    
    data_status := Loaded;
    Printf.printf "Loaded %d rhyme entries in %.3f seconds\\n" 
      stats.total_rhyme_entries load_time
  )

(** 检查数据是否已加载 *)
let is_data_loaded () = !data_status = Loaded

(** 强制重新加载数据 *)
let force_reload_data () =
  data_status := NotLoaded;
  load_data_to_cache ()

(** {1 统一数据访问接口} *)

(** 获取韵律信息 - 统一接口 *)
let get_rhyme_info (char: string) : rhyme_info option =
  if not (is_data_loaded ()) then load_data_to_cache ();
  try
    Some (Hashtbl.find main_data_cache char)
  with Not_found -> None

(** 获取韵部所有字符 *)
let get_rhyme_group_characters (group: rhyme_group) : string list =
  if not (is_data_loaded ()) then load_data_to_cache ();
  try
    Hashtbl.find rhyme_group_cache group
  with Not_found -> []

(** 获取指定声调的字符 *)
let get_characters_by_tone (tone: int) : (string * rhyme_info) list =
  if not (is_data_loaded ()) then load_data_to_cache ();
  Hashtbl.fold (fun char info acc ->
    match info.tone_pattern with
    | Some t when t = tone -> (char, info) :: acc
    | _ -> acc
  ) main_data_cache []

(** 获取指定声调分类的字符 *)
let get_characters_by_category (category: rhyme_category) : (string * rhyme_info) list =
  if not (is_data_loaded ()) then load_data_to_cache ();
  Hashtbl.fold (fun char info acc ->
    if info.category = category then (char, info) :: acc else acc
  ) main_data_cache []

(** 搜索相似韵律的字符 *)
let find_similar_rhyme_characters (target_char: string) (max_results: int) : string list =
  match get_rhyme_info target_char with
  | Some target_info ->
    let candidates = get_rhyme_group_characters target_info.group in
    let filtered = List.filter (fun c -> c <> target_char) candidates in
    List.take (min max_results (List.length filtered)) filtered
  | None -> []

(** {1 批量操作接口} *)

(** 批量获取韵律信息 *)
let batch_get_rhyme_info (chars: string list) : (string * rhyme_info option) list =
  List.map (fun char -> (char, get_rhyme_info char)) chars

(** 批量韵律验证 *)
let batch_validate_rhyme (char_pairs: (string * string) list) : (string * string * bool) list =
  List.map (fun (c1, c2) ->
    match (get_rhyme_info c1, get_rhyme_info c2) with
    | Some info1, Some info2 -> (c1, c2, info1.group = info2.group)
    | _ -> (c1, c2, false)
  ) char_pairs

(** {1 数据统计和查询} *)

(** 获取数据统计信息 *)
let get_data_statistics () = !data_stats

(** 获取所有韵部列表 *)
let get_all_rhyme_groups () : rhyme_group list =
  if not (is_data_loaded ()) then load_data_to_cache ();
  Hashtbl.fold (fun group _ acc -> group :: acc) rhyme_group_cache []

(** 获取韵部统计信息 *)
let get_rhyme_group_stats (group: rhyme_group) : int =
  let chars = get_rhyme_group_characters group in
  List.length chars

(** 生成数据报告 *)
let generate_data_report () : string =
  let stats = !data_stats in
  let groups = get_all_rhyme_groups () in
  let group_details = List.map (fun group ->
    let count = get_rhyme_group_stats group in
    Printf.sprintf "%s: %d字符" (get_rhyme_group_name group) count
  ) groups in
  
  Printf.sprintf 
    "=== Poetry Data Report ===\\n\
     总韵律条目: %d\\n\
     韵部数量: %d\\n\
     声调模式: %d\\n\
     加载时间: %.3f秒\\n\
     内存占用: %d bytes\\n\
     韵部详情:\\n%s\\n\
     ========================="
    stats.total_rhyme_entries
    stats.rhyme_groups_count
    stats.tone_patterns_count
    stats.load_time
    stats.memory_usage
    (String.concat "\\n" group_details)

(** {1 缓存管理} *)

(** 清理数据缓存 *)
let clear_data_cache () =
  Hashtbl.clear main_data_cache;
  Hashtbl.clear rhyme_group_cache;
  data_status := NotLoaded

(** 预热缓存 - 预加载常用数据 *)
let warm_up_cache () =
  if not (is_data_loaded ()) then load_data_to_cache ();
  (* 预加载常用韵部 *)
  let common_groups = [Feng; Hua; Yu; Jiang; Yue; Hui] in
  List.iter (fun group -> 
    ignore (get_rhyme_group_characters group)
  ) common_groups

(** {1 兼容性接口} *)

(** 兼容旧的数据访问接口 *)
let find_rhyme_data_compat = get_rhyme_info
let get_rhyme_database_compat () = 
  if not (is_data_loaded ()) then load_data_to_cache ();
  comprehensive_rhyme_database

(** 兼容旧的数据加载接口 *)
let load_rhyme_data_to_cache = load_data_to_cache