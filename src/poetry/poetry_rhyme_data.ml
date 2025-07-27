(** 骆言诗词韵律数据管理模块 - 整合版本（简化实现）

    此模块整合了原有30+个数据加载和管理模块的功能， 提供统一的韵律数据访问、缓存和管理接口。

    @author 骆言诗词编程团队
    @version 2.0 - 整合版本
    @since 2025-07-24 *)

open Poetry_types_consolidated

(** {1 内部数据结构} *)

(** 韵律数据结构化定义 - 提高可维护性 *)

(** 韵组数据构建辅助函数 *)
let make_rhyme_group_data group category chars =
  List.map (fun char -> (char, category, group)) chars

(** 安韵组数据 *)
let an_rhyme_data = 
  make_rhyme_group_data AnRhyme PingSheng
    ["山"; "间"; "闲"; "关"; "还"; "班"; "颜"; "安"; "删"; "蛮"; "环"; "弯"]

(** 天韵组数据 *)
let tian_rhyme_data = 
  make_rhyme_group_data TianRhyme PingSheng
    ["天"; "年"; "先"; "田"; "边"; "前"; "连"; "千"; "线"]

(** 思韵组数据 *)
let si_rhyme_data = 
  make_rhyme_group_data SiRhyme PingSheng
    ["诗"; "时"; "知"; "思"; "才"; "材"; "灾"]

(** 鱼韵组数据 *)
let yu_rhyme_data = 
  make_rhyme_group_data YuRhyme PingSheng
    ["鱼"; "书"; "居"; "虚"; "余"; "舒"; "初"; "疏"]

(** 花韵组数据 *)
let hua_rhyme_data = 
  make_rhyme_group_data HuaRhyme PingSheng
    ["花"; "霞"; "家"; "茶"; "沙"; "华"; "瓜"; "夸"]

(** 风韵组数据 *)
let feng_rhyme_data = 
  make_rhyme_group_data FengRhyme PingSheng
    ["风"; "中"; "东"; "终"; "钟"; "空"; "红"; "虹"]

(** 江韵组数据 *)
let jiang_rhyme_data = 
  make_rhyme_group_data JiangRhyme PingSheng
    ["江"; "窗"; "双"; "庄"; "霜"; "强"; "长"; "墙"]

(** 灰韵组数据 *)
let hui_rhyme_data = 
  make_rhyme_group_data HuiRhyme PingSheng
    ["灰"; "回"; "推"; "杯"; "开"; "来"; "台"; "栽"]

(** 仄声韵组数据 *)
let wang_rhyme_data = [
  ("望", ZeSheng, WangRhyme);
  ("放", ZeSheng, WangRhyme);
  ("向", ZeSheng, WangRhyme);
  ("上", ShangSheng, WangRhyme);
  ("响", ZeSheng, WangRhyme);
]

let qu_rhyme_data = 
  make_rhyme_group_data QuRhyme QuSheng
    ["去"; "路"; "度"; "步"; "暮"; "树"]

(** 月韵组数据（入声） *)
let yue_rhyme_data = 
  make_rhyme_group_data YueRhyme RuSheng
    ["月"; "雪"; "节"; "别"; "切"; "热"; "列"; "设"]

(** 组合所有韵组数据 *)
let rhyme_data_strings =
  List.concat [
    an_rhyme_data;
    tian_rhyme_data;
    si_rhyme_data;
    yu_rhyme_data;
    hua_rhyme_data;
    feng_rhyme_data;
    jiang_rhyme_data;
    hui_rhyme_data;
    wang_rhyme_data;
    qu_rhyme_data;
    yue_rhyme_data;
  ]

(** 从字符串数据转换为字符数据 *)
let string_to_char_data data =
  List.fold_left
    (fun acc (str, category, group) ->
      if String.length str > 0 then (str, category, group) :: acc else acc)
    [] data
  |> List.rev

(** 转换后的字符数据 *)
let extended_rhyme_database = ref (string_to_char_data rhyme_data_strings)

(** 数据是否已初始化的标志 *)
let data_initialized = ref false

(** 韵律查询哈希表 *)
let rhyme_lookup_table = Hashtbl.create 512

(** {1 核心数据访问接口} *)

let initialize_data () =
  if not !data_initialized then (
    Hashtbl.clear rhyme_lookup_table;
    List.iter
      (fun (str, category, group) ->
        if String.length str > 0 then Hashtbl.add rhyme_lookup_table str.[0] (category, group))
      !extended_rhyme_database;
    data_initialized := true)

let get_all_rhyme_data () =
  initialize_data ();
  !extended_rhyme_database

let get_rhyme_by_category category =
  initialize_data ();
  List.fold_left
    (fun acc (str, cat, group) ->
      if rhyme_category_equal cat category then (str, group) :: acc else acc)
    [] !extended_rhyme_database

let get_rhyme_by_group group =
  initialize_data ();
  List.fold_left
    (fun acc (str, category, grp) ->
      if rhyme_group_equal grp group then (str, category) :: acc else acc)
    [] !extended_rhyme_database

let lookup_char_info char =
  initialize_data ();
  try Some (Hashtbl.find rhyme_lookup_table char) with Not_found -> None

let batch_lookup chars =
  initialize_data ();
  List.fold_left
    (fun acc char ->
      match lookup_char_info char with
      | Some (category, group) -> (char, category, group) :: acc
      | None -> acc)
    [] chars
  |> List.rev

(** {1 韵组数据管理} *)

let get_rhyme_group_chars group = get_rhyme_by_group group |> List.map fst
let get_rhyme_group_size group = List.length (get_rhyme_group_chars group)

let list_all_rhyme_groups () =
  [
    AnRhyme;
    SiRhyme;
    TianRhyme;
    WangRhyme;
    QuRhyme;
    YuRhyme;
    HuaRhyme;
    FengRhyme;
    YueRhyme;
    JiangRhyme;
    HuiRhyme;
    UnknownRhyme;
  ]

let is_rhyme_group_empty group = get_rhyme_group_size group = 0

(** {1 声调数据管理} *)

let get_ping_sheng_chars () = get_rhyme_by_category PingSheng |> List.map fst

let get_ze_sheng_chars () =
  List.concat
    [
      get_rhyme_by_category ZeSheng |> List.map fst;
      get_rhyme_by_category ShangSheng |> List.map fst;
      get_rhyme_by_category QuSheng |> List.map fst;
      get_rhyme_by_category RuSheng |> List.map fst;
    ]

let get_category_distribution () =
  let categories = [ PingSheng; ZeSheng; ShangSheng; QuSheng; RuSheng ] in
  List.map
    (fun cat ->
      let count = List.length (get_rhyme_by_category cat) in
      (cat, count))
    categories

(** {1 数据加载和初始化} *)

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
      let category = parse_rhyme_category_str category_str in
      let group = parse_rhyme_group_str group_str in
      (char_str, category, group)
    else ("x", PingSheng, UnknownRhyme)

  let parse_rhyme_data json_content =
    (* 简化实现 - 按行分割并解析 *)
    let lines = String.split_on_char '\n' json_content in
    List.fold_left
      (fun acc line ->
        try
          let entry = parse_single_entry line in
          entry :: acc
        with _ -> acc)
      [] lines
    |> List.rev

  let export_to_json data =
    let entries =
      List.map
        (fun (str, category, group) ->
          Printf.sprintf "\"%s\", \"%s\", \"%s\"" str
            (rhyme_category_to_string category)
            (rhyme_group_to_string group))
        data
    in
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
  let char_strings = List.map (fun (str, _, _) -> str) data in
  let char_set = Hashtbl.create (List.length data) in
  try
    List.iter
      (fun str ->
        if Hashtbl.mem char_set str then raise (Failure ("重复字符: " ^ str))
        else Hashtbl.add char_set str true)
      char_strings;
    true
  with
  | Failure msg ->
      Printf.eprintf "数据完整性检查失败: %s\n" msg;
      false
  | _ ->
      Printf.eprintf "数据完整性检查失败: 未知错误\n";
      false

let get_data_statistics () =
  initialize_data ();
  let total_chars = List.length !extended_rhyme_database in
  let group_count = List.length (list_all_rhyme_groups ()) - 1 in
  (* 排除UnknownRhyme *)
  let category_dist = get_category_distribution () in
  let ping_count = List.assoc PingSheng category_dist in
  let ze_count = total_chars - ping_count in
  [ ("总字符数", total_chars); ("韵组数", group_count); ("平声字符数", ping_count); ("仄声字符数", ze_count) ]

let find_data_conflicts () =
  initialize_data ();
  (* 简化实现 - 检查是否有未知韵组的字符 *)
  List.fold_left
    (fun acc (str, _, group) -> if group = UnknownRhyme then (str, "未知韵组") :: acc else acc)
    [] !extended_rhyme_database

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
  | Sys_error msg -> raise (Failure ("文件加载失败: " ^ msg))
  | _ -> raise (Failure "数据解析失败")

let save_to_file filepath =
  initialize_data ();
  try
    let content = JsonParser.export_to_json !extended_rhyme_database in
    let oc = open_out filepath in
    output_string oc content;
    close_out oc
  with Sys_error msg -> raise (Failure ("文件保存失败: " ^ msg))

let merge_external_data external_data =
  initialize_data ();
  let merged_data = !extended_rhyme_database @ external_data in
  (* 简单去重 - 保留第一次出现的字符 *)
  let char_set = Hashtbl.create (List.length merged_data) in
  let unique_data =
    List.fold_left
      (fun acc (str, category, group) ->
        if Hashtbl.mem char_set str then acc
        else (
          Hashtbl.add char_set str true;
          (str, category, group) :: acc))
      [] merged_data
    |> List.rev
  in
  extended_rhyme_database := unique_data;
  reload_data ()
