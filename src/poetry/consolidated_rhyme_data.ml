(** 韵律数据统一重构模块 - Phase 6.1 实施

    按照设计文档 0006-rhyme-data-consolidation-analysis-phase6-1.md 的方案， 统一管理所有韵律数据，消除重复和循环依赖，提供统一的数据访问接口。

    设计原则： 1. 单一数据源：所有韵律数据统一存储 2. 向后兼容：保持现有API接口不变 3. 性能优化：统一缓存和索引机制 4. 错误处理：统一的异常处理策略

    @author 骆言诗词编程团队 - 技术债务重构
    @version 1.0 - Phase 6.1 实施版本
    @since 2025-07-24 *)

open Rhyme_types

(** {1 统一数据模型} *)

(** 数据来源标记 *)
type data_source =
  | RhymeData  (** 来自 rhyme_data.ml *)
  | UnifiedRhyme  (** 来自 unified_rhyme_data.ml *)
  | PoetryRhyme  (** 来自 poetry_rhyme_data.ml *)
  | ExpandedRhyme  (** 来自 expanded_rhyme_data.ml *)
  | DatabaseRhyme  (** 来自 rhyme_database.ml *)

type consolidated_rhyme_entry = {
  character : string;
  category : rhyme_category;
  group : rhyme_group;
  source : data_source;
}
(** 统一韵律数据条目 *)

type database_statistics = {
  total_entries : int;
  ping_sheng_count : int;
  ze_sheng_count : int;
  ru_sheng_count : int;
  group_distribution : (rhyme_group * int) list;
  source_distribution : (data_source * int) list;
}
(** 数据库统计信息 *)

type consolidated_rhyme_database = {
  entries : consolidated_rhyme_entry list;
  index : (string, rhyme_category * rhyme_group) Hashtbl.t;
  stats : database_statistics;
}
(** 统一韵律数据库 *)

(** {2 数据收集和去重} *)

(** 从各个模块收集原始数据 *)
let collect_raw_data () =
  let raw_data = ref [] in

  (* 从 poetry_rhyme_data.ml 收集数据 - 结构化定义提高可维护性 *)
  
  (* 韵组数据构建辅助函数 *)
  let make_rhyme_data group category chars =
    List.map (fun char -> (char, category, group)) chars
  in

  (* 安韵组数据 *)
  let an_rhyme_data = 
    make_rhyme_data AnRhyme PingSheng
      ["山"; "间"; "闲"; "关"; "还"; "班"; "颜"; "安"; "删"; "蛮"; "环"; "弯"]
  in

  (* 天韵组数据 *)
  let tian_rhyme_data = 
    make_rhyme_data TianRhyme PingSheng
      ["天"; "年"; "先"; "田"; "边"; "前"; "连"; "千"; "线"]
  in

  (* 思韵组数据 *)
  let si_rhyme_data = 
    make_rhyme_data SiRhyme PingSheng
      ["诗"; "时"; "知"; "思"; "才"; "材"; "灾"; "来"; "台"]
  in

  (* 望韵组数据 *)
  let wang_rhyme_data = 
    make_rhyme_data WangRhyme ZeSheng
      ["望"; "上"; "向"; "响"; "象"; "像"]
  in

  (* 去韵组数据 *)
  let qu_rhyme_data = 
    make_rhyme_data QuRhyme ZeSheng
      ["去"; "树"; "雾"; "路"; "处"; "住"]
  in

  (* 鱼韵组数据 *)
  let yu_rhyme_data = 
    make_rhyme_data YuRhyme PingSheng
      ["鱼"; "书"; "虚"; "渠"; "居"; "徐"]
  in

  (* 花韵组数据 *)
  let hua_rhyme_data = 
    make_rhyme_data HuaRhyme PingSheng
      ["花"; "家"; "佳"; "霞"; "沙"; "茶"]
  in

  (* 风韵组数据 *)
  let feng_rhyme_data = 
    make_rhyme_data FengRhyme PingSheng
      ["风"; "东"; "空"; "中"; "红"; "公"]
  in

  (* 月韵组数据 *)
  let yue_rhyme_data = 
    make_rhyme_data YueRhyme RuSheng
      ["月"; "别"; "节"; "切"; "设"; "血"]
  in

  (* 江韵组数据 *)
  let jiang_rhyme_data = 
    make_rhyme_data JiangRhyme ZeSheng
      ["江"; "双"; "窗"; "降"; "霜"; "常"]
  in

  (* 会韵组数据 *)
  let hui_rhyme_data = 
    make_rhyme_data HuiRhyme ZeSheng
      ["会"; "对"; "内"; "位"; "外"; "类"]
  in

  let poetry_data =
    try
      (* 组合所有韵组数据 *)
      List.concat [
        an_rhyme_data;
        tian_rhyme_data;
        si_rhyme_data;
        wang_rhyme_data;
        qu_rhyme_data;
        yu_rhyme_data;
        hua_rhyme_data;
        feng_rhyme_data;
        yue_rhyme_data;
        jiang_rhyme_data;
        hui_rhyme_data;
      ]
    with _ -> []
  in

  (* 转换为统一格式 *)
  let convert_to_consolidated (char, category, group) source =
    { character = char; category; group; source }
  in

  (* 收集所有数据 *)
  raw_data := List.map (fun x -> convert_to_consolidated x PoetryRhyme) poetry_data;

  !raw_data

(** 数据去重 - 按字符去重，保留第一个出现的条目 *)
let deduplicate_data raw_data =
  let seen = Hashtbl.create 256 in
  let deduped = ref [] in

  List.iter
    (fun entry ->
      if not (Hashtbl.mem seen entry.character) then (
        Hashtbl.add seen entry.character true;
        deduped := entry :: !deduped))
    raw_data;

  List.rev !deduped

(** {3 索引构建} *)

(** 构建字符查询索引 *)
let build_index entries =
  let index = Hashtbl.create (List.length entries) in
  List.iter (fun entry -> Hashtbl.add index entry.character (entry.category, entry.group)) entries;
  index

(** {3 统计信息计算} *)

(** 计算数据库统计信息 *)
let calculate_statistics entries =
  let total = List.length entries in
  let ping_count = List.length (List.filter (fun e -> e.category = PingSheng) entries) in
  let ze_count = List.length (List.filter (fun e -> e.category = ZeSheng) entries) in
  let ru_count = List.length (List.filter (fun e -> e.category = RuSheng) entries) in

  (* 计算韵组分布 *)
  let group_counts = Hashtbl.create 16 in
  List.iter
    (fun entry ->
      let current = try Hashtbl.find group_counts entry.group with Not_found -> 0 in
      Hashtbl.replace group_counts entry.group (current + 1))
    entries;

  let group_distribution =
    Hashtbl.fold (fun group count acc -> (group, count) :: acc) group_counts []
  in

  (* 计算数据源分布 *)
  let source_counts = Hashtbl.create 8 in
  List.iter
    (fun entry ->
      let current = try Hashtbl.find source_counts entry.source with Not_found -> 0 in
      Hashtbl.replace source_counts entry.source (current + 1))
    entries;

  let source_distribution =
    Hashtbl.fold (fun source count acc -> (source, count) :: acc) source_counts []
  in

  {
    total_entries = total;
    ping_sheng_count = ping_count;
    ze_sheng_count = ze_count;
    ru_sheng_count = ru_count;
    group_distribution;
    source_distribution;
  }

(** {2 数据库构建} *)

(** 构建统一的韵律数据库 *)
let build_consolidated_database () =
  let raw_data = collect_raw_data () in
  let deduped_entries = deduplicate_data raw_data in
  let index = build_index deduped_entries in
  let stats = calculate_statistics deduped_entries in

  { entries = deduped_entries; index; stats }

(** 全局数据库实例 - 延迟初始化 *)
let global_database = lazy (build_consolidated_database ())

(** {2 统一API接口} *)

(** 查找字符的韵律信息 *)
let find_rhyme_info character =
  let db = Lazy.force global_database in
  try Some (Hashtbl.find db.index character) with Not_found -> None

(** 获取所有韵律数据 *)
let get_all_rhyme_data () =
  let db = Lazy.force global_database in
  db.entries

(** 获取数据库统计信息 *)
let get_database_stats () =
  let db = Lazy.force global_database in
  db.stats

(** 按韵组获取数据 *)
let get_entries_by_group group =
  let db = Lazy.force global_database in
  List.filter (fun entry -> entry.group = group) db.entries

(** 按韵类获取数据 *)
let get_entries_by_category category =
  let db = Lazy.force global_database in
  List.filter (fun entry -> entry.category = category) db.entries

(** {2 调试和诊断功能} *)

(** 打印数据库统计信息 *)
let print_database_info () =
  let stats = get_database_stats () in
  Printf.printf "=== 韵律数据库统计信息 ===\n";
  Printf.printf "总条目数: %d\n" stats.total_entries;
  Printf.printf "平声: %d, 仄声: %d, 入声: %d\n" stats.ping_sheng_count stats.ze_sheng_count
    stats.ru_sheng_count;
  Printf.printf "韵组分布:\n";
  List.iter
    (fun (group, count) ->
      let group_name =
        match group with
        | AnRhyme -> "安韵"
        | SiRhyme -> "思韵"
        | TianRhyme -> "天韵"
        | WangRhyme -> "望韵"
        | QuRhyme -> "去韵"
        | YuRhyme -> "鱼韵"
        | HuaRhyme -> "花韵"
        | FengRhyme -> "风韵"
        | YueRhyme -> "月韵"
        | JiangRhyme -> "江韵"
        | HuiRhyme -> "会韵"
        | UnknownRhyme -> "未知韵"
      in
      Printf.printf "  %s: %d\n" group_name count)
    stats.group_distribution;
  Printf.printf "========================\n"
