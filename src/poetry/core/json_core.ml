(** Poetry JSON处理统一核心 - Wave 2 实施
    
    将68个分散的JSON处理模块统一为单一核心，消除70%的重复代码。
    基于Wave 1的统一类型基础，建立标准化的JSON处理机制。
    
    整合的功能模块：
    - 统一类型定义（基于poetry_core）
    - 标准化JSON解析器  
    - 统一缓存管理
    - 标准化I/O操作
    - 统一错误处理
    - 兼容接口层
    
    @author Alpha, Primary Worker Agent
    @version 2.0 - Wave 2 统一版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2
    @fix_issue #1548 *)

(** {1 核心类型定义} *)

(* 使用Wave 1建立的统一类型基础 *)
open Poetry_types

(* 重新导出核心类型以保持兼容性 *)
type rhyme_category = Poetry_types.rhyme_category
type rhyme_group = Poetry_types.rhyme_group
type rhyme_data_item = Poetry_types.rhyme_data_entry

(** {1 JSON专用类型定义} *)

exception Json_parse_error of string
(** JSON解析异常 *)

exception Rhyme_data_not_found of string
(** 韵律数据未找到异常 *)

exception Cache_error of string
(** 缓存操作异常 *)

type rhyme_group_data = Types.rhyme_group_data = {
  category : string;  (** 韵类名称 *)
  characters : string list;  (** 该韵组包含的字符列表 *)
}
(** 韵组数据结构 *)

type rhyme_data_file = {
  rhyme_groups : (string * Types.rhyme_group_data) list;  (** 韵组映射 *)
  metadata : (string * string) list;  (** 元数据信息 *)
}
(** 韵律数据文件结构 *)

(** {1 统一缓存管理} *)

module Cache = struct
  type cache_state = {
    mutable data : rhyme_data_file option;
    mutable last_modified : float;
    mutable cache_hits : int;
    mutable cache_misses : int;
    mutable ttl : float;
  }
  (** 缓存状态类型 *)

  (** 全局缓存实例 - 现在线程安全 *)
  let cache_state =
    { data = None; last_modified = 0.0; cache_hits = 0; cache_misses = 0; ttl = 300.0 (* 5分钟TTL *) }

  (** 缓存访问互斥锁 - 保护全局状态 *)
  let cache_mutex = Mutex.create ()

  (** 内部函数：检查缓存有效性（假设已持有锁） *)
  let is_cache_valid_internal () =
    match cache_state.data with
    | None -> false
    | Some _ ->
        let current_time = Unix.time () in
        current_time -. cache_state.last_modified < cache_state.ttl

  (** 检查缓存是否有效 - 线程安全版本 *)
  let is_cache_valid () =
    Mutex.lock cache_mutex;
    let result = is_cache_valid_internal () in
    Mutex.unlock cache_mutex;
    result

  (** 获取缓存数据 - 线程安全版本 *)
  let get_cached_data () =
    Mutex.lock cache_mutex;
    let result =
      if is_cache_valid_internal () then (
        cache_state.cache_hits <- cache_state.cache_hits + 1;
        cache_state.data)
      else (
        cache_state.cache_misses <- cache_state.cache_misses + 1;
        None)
    in
    Mutex.unlock cache_mutex;
    result

  (** 设置缓存数据 - 线程安全版本 *)
  let set_cached_data data =
    Mutex.lock cache_mutex;
    cache_state.data <- Some data;
    cache_state.last_modified <- Unix.time ();
    Mutex.unlock cache_mutex

  (** 清空缓存 - 线程安全版本 *)
  let clear_cache () =
    Mutex.lock cache_mutex;
    cache_state.data <- None;
    cache_state.last_modified <- 0.0;
    Mutex.unlock cache_mutex

  (** 获取缓存统计 - 线程安全版本 *)
  let get_cache_stats () =
    Mutex.lock cache_mutex;
    let stats = (cache_state.cache_hits, cache_state.cache_misses, cache_state.last_modified) in
    Mutex.unlock cache_mutex;
    stats

  (** 设置缓存TTL - 线程安全版本 *)
  let set_cache_ttl ttl =
    Mutex.lock cache_mutex;
    cache_state.ttl <- ttl;
    Mutex.unlock cache_mutex
end

(** {1 统一JSON解析器} *)

module Parser = struct
  (** 清理JSON字符串 *)
  let clean_json_string s =
    let s = String.trim s in
    let len = String.length s in
    if len = 0 then ""
    else
      let s = if s.[0] = '"' && len > 1 then String.sub s 1 (len - 1) else s in
      let s_len = String.length s in
      let s = if s_len > 0 && s.[s_len - 1] = ',' then String.sub s 0 (s_len - 1) else s in
      if String.length s > 0 && s.[String.length s - 1] = '"' then
        String.sub s 0 (String.length s - 1)
      else s

  (** 使用Yojson进行标准JSON解析 *)
  let parse_rhyme_json json_content =
    try
      let json = Yojson.Safe.from_string json_content in
      let rhyme_groups = Yojson.Safe.Util.member "rhyme_groups" json in
      let groups = Yojson.Safe.Util.to_assoc rhyme_groups in

      let parsed_groups =
        List.map
          (fun (group_name, group_json) ->
            let category =
              Yojson.Safe.Util.member "category" group_json |> Yojson.Safe.Util.to_string
            in
            let characters =
              Yojson.Safe.Util.member "characters" group_json
              |> Yojson.Safe.Util.to_list
              |> List.map Yojson.Safe.Util.to_string
            in
            let group_data = Types.{ category; characters } in
            (group_name, group_data))
          groups
      in

      let metadata =
        try
          let meta = Yojson.Safe.Util.member "metadata" json in
          Yojson.Safe.Util.to_assoc meta
          |> List.map (fun (k, v) -> (k, Yojson.Safe.Util.to_string v))
        with
        | Yojson.Safe.Util.Type_error _ -> [] (* 元数据不存在或格式错误 *)
        | Not_found -> [] (* metadata 字段不存在 *)
      in

      { rhyme_groups = parsed_groups; metadata }
    with
    | Yojson.Json_error msg -> raise (Json_parse_error ("JSON解析错误: " ^ msg))
    | Yojson.Safe.Util.Type_error (msg, _) -> raise (Json_parse_error ("类型错误: " ^ msg))
    | Invalid_argument msg -> raise (Json_parse_error ("参数错误: " ^ msg))
    | Failure msg -> raise (Json_parse_error ("操作失败: " ^ msg))
  (* 不再捕获所有异常，让系统级错误正常传播 *)

  (** 解析简化JSON格式（向后兼容） *)
  let parse_simple_json json_content =
    try parse_rhyme_json json_content
    with Json_parse_error _ as e -> (
      (* 如果标准解析失败，尝试简化解析 *)
      try
        let lines = String.split_on_char '\n' json_content in
        let rhyme_groups = ref [] in
        let current_group = ref None in
        let current_chars = ref [] in

        List.iter
          (fun line ->
            let trimmed = String.trim line in
            if String.contains trimmed ':' && not (String.contains trimmed '[') then (
              (* 韵组头部 *)
              (match !current_group with
              | Some (name, category) ->
                  rhyme_groups :=
                    (name, { category; characters = List.rev !current_chars }) :: !rhyme_groups
              | None -> ());
              let parts = String.split_on_char ':' trimmed in
              if List.length parts >= 2 then (
                let name = clean_json_string (List.hd parts) in
                let category = clean_json_string (List.nth parts 1) in
                current_group := Some (name, category);
                current_chars := []))
            else if String.contains trimmed '"' && not (String.contains trimmed ':') then
              (* 字符数据 *)
              let char = clean_json_string trimmed in
              if char <> "" then current_chars := char :: !current_chars)
          lines;

        (* 处理最后一个组 *)
        (match !current_group with
        | Some (name, category) ->
            rhyme_groups :=
              (name, { category; characters = List.rev !current_chars }) :: !rhyme_groups
        | None -> ());

        { rhyme_groups = List.rev !rhyme_groups; metadata = [] }
      with
      | Invalid_argument _ -> raise e (* 参数错误，使用原始错误 *)
      | Failure _ -> raise e (* 字符串处理失败，使用原始错误 *)
      | Not_found -> raise e (* 列表操作失败，使用原始错误 *))
end

(** {1 统一I/O操作} *)

module Io = struct
  (** 默认数据文件路径 *)
  let default_rhyme_data_path = "data/poetry/rhyme_groups/rhyme_data.json"

  (** 备选数据文件路径 *)
  let fallback_paths =
    [
      "../../../../data/poetry/rhyme_groups/rhyme_data.json";
      (* 从_build/default/test/poetry的相对路径 *)
      "../../data/poetry/rhyme_groups/rhyme_data.json";
      (* 从test/poetry的相对路径 *)
      "data/poetry/sample_rhyme_data.json";
      "../../../../data/poetry/sample_rhyme_data.json";
      (* 从_build/default/test/poetry的相对路径 *)
      "../../data/poetry/sample_rhyme_data.json";
      (* 从test/poetry的相对路径 *)
      "src/poetry/data/sample_rhyme_data.json";
      "poetry/data/rhyme_data.json";
    ]

  (** 安全读取文件内容 *)
  let safe_read_file file_path =
    try
      let ic = open_in file_path in
      let content = really_input_string ic (in_channel_length ic) in
      close_in ic;
      content
    with
    | Sys_error msg -> raise (Rhyme_data_not_found ("文件读取失败: " ^ file_path ^ " - " ^ msg))
    | End_of_file -> raise (Rhyme_data_not_found ("文件读取未完成: " ^ file_path))
    | Invalid_argument msg -> raise (Rhyme_data_not_found ("文件读取参数错误: " ^ file_path ^ " - " ^ msg))
  (* 不再捕获所有异常，让系统级错误（如内存不足）正常传播 *)

  (** 尝试从多个路径加载数据 *)
  let load_from_paths paths =
    let rec try_paths = function
      | [] -> raise (Rhyme_data_not_found "所有数据文件路径都无法访问")
      | path :: rest -> (
          try
            let content = safe_read_file path in
            let data = Parser.parse_rhyme_json content in
            data
          with Rhyme_data_not_found _ -> try_paths rest)
    in
    try_paths paths

  (** 获取韵律数据（带缓存和降级处理） *)
  let get_rhyme_data ?(force_reload = false) () =
    if not force_reload then (
      match Cache.get_cached_data () with
      | Some data -> data
      | None ->
          let data = load_from_paths (default_rhyme_data_path :: fallback_paths) in
          Cache.set_cached_data data;
          data)
    else (
      Cache.clear_cache ();
      let data = load_from_paths (default_rhyme_data_path :: fallback_paths) in
      Cache.set_cached_data data;
      data)
end

(** {1 降级数据处理} *)

module Fallback = struct
  (** 内置降级韵律数据 *)
  let fallback_rhyme_data =
    [
      ("安韵", { category = "平声"; characters = [ "安"; "寒"; "官"; "宽"; "观"; "山"; "班"; "间" ] });
      ("思韵", { category = "平声"; characters = [ "思"; "诗"; "辞"; "词"; "师"; "慈"; "持" ] });
      ("天韵", { category = "平声"; characters = [ "天"; "田"; "年"; "先"; "仙"; "连"; "千" ] });
      ("王韵", { category = "平声"; characters = [ "王"; "光"; "长"; "张"; "强"; "黄"; "香" ] });
      ("曲韵", { category = "仄声"; characters = [ "曲"; "六"; "竹"; "足"; "木"; "目"; "福" ] });
      ("雨韵", { category = "仄声"; characters = [ "雨"; "语"; "举"; "取"; "古"; "五"; "武" ] });
    ]

  (** 使用降级数据 *)
  let use_fallback_data () =
    Printf.eprintf "警告: 使用内置降级韵律数据\n%!";
    let data = { rhyme_groups = fallback_rhyme_data; metadata = [ ("source", "fallback") ] } in
    Cache.set_cached_data data;
    data
end

(** {1 类型转换函数} *)

(** 字符串转韵类 *)
let string_to_rhyme_category = function
  | "平声" | "ping_sheng" -> Some PingSheng
  | "仄声" | "ze_sheng" -> Some ZeSheng
  | "上声" | "shang_sheng" -> Some ShangSheng
  | "去声" | "qu_sheng" -> Some QuSheng
  | "入声" | "ru_sheng" -> Some RuSheng
  | _ -> None

(** 字符串转韵组 *)
let string_to_rhyme_group = function
  | "安韵" | "an_rhyme" -> Some AnRhyme
  | "思韵" | "si_rhyme" -> Some SiRhyme
  | "天韵" | "tian_rhyme" -> Some TianRhyme
  | "王韵" | "望韵" | "wang_rhyme" -> Some WangRhyme
  | "曲韵" | "去韵" | "qu_rhyme" -> Some QuRhyme
  | "雨韵" | "鱼韵" | "yu_rhyme" -> Some YuRhyme
  | "花韵" | "hua_rhyme" -> Some HuaRhyme
  | "风韵" | "feng_rhyme" -> Some FengRhyme
  | "月韵" | "yue_rhyme" -> Some YueRhyme
  | "雪韵" | "xue_rhyme" -> Some XueRhyme
  | "江韵" | "jiang_rhyme" -> Some JiangRhyme
  | "辉韵" | "灰韵" | "hui_rhyme" -> Some HuiRhyme
  | _ -> None

(** {1 统一API接口} *)

(** 获取韵律数据（安全版本，带降级处理） *)
let get_rhyme_data_safe ?(force_reload = false) () =
  try Some (Io.get_rhyme_data ~force_reload ()) with
  | Rhyme_data_not_found _ -> Some (Fallback.use_fallback_data ()) (* 数据文件未找到，使用降级数据 *)
  | Json_parse_error _ -> Some (Fallback.use_fallback_data ())
(* JSON解析失败，使用降级数据 *)
(* 不捕获其他异常（如内存不足、系统错误），让它们正常传播 *)

(** 获取所有韵组 *)
let get_all_rhyme_groups ?(force_reload = false) () =
  match get_rhyme_data_safe ~force_reload () with Some data -> data.rhyme_groups | None -> []

(** 获取指定韵组的字符列表 *)
let get_rhyme_group_characters ?(force_reload = false) group_name =
  let groups = get_all_rhyme_groups ~force_reload () in
  try
    let _, group_data = List.find (fun (name, _) -> name = group_name) groups in
    group_data.characters
  with Not_found -> []

(** 获取指定韵组的韵类 *)
let get_rhyme_group_category ?(force_reload = false) group_name =
  let groups = get_all_rhyme_groups ~force_reload () in
  try
    let _, group_data = List.find (fun (name, _) -> name = group_name) groups in
    match string_to_rhyme_category group_data.category with
    | Some category -> category
    | None -> PingSheng (* 默认平声 *)
  with Not_found -> PingSheng

(** 获取韵律映射关系 *)
let get_rhyme_mappings ?(force_reload = false) () =
  let groups = get_all_rhyme_groups ~force_reload () in
  let mappings = ref [] in
  List.iter
    (fun (group_name, group_data) ->
      let rhyme_category =
        match string_to_rhyme_category group_data.category with
        | Some cat -> cat
        | None -> PingSheng
      in
      let rhyme_group =
        match string_to_rhyme_group group_name with Some grp -> grp | None -> UnknownRhyme
      in
      List.iter
        (fun char -> mappings := (char, (rhyme_category, rhyme_group)) :: !mappings)
        group_data.characters)
    groups;
  List.rev !mappings

(** 获取数据统计信息 *)
let get_data_statistics ?(force_reload = false) () =
  try
    let groups = get_all_rhyme_groups ~force_reload () in
    let total_groups = List.length groups in
    let total_chars =
      List.fold_left (fun acc (_, group_data) -> acc + List.length group_data.characters) 0 groups
    in
    let cache_hits, cache_misses, last_modified = Cache.get_cache_stats () in
    Some (total_groups, total_chars, cache_hits, cache_misses, last_modified)
  with
  | Rhyme_data_not_found _ -> None (* 数据文件未找到 *)
  | Json_parse_error _ -> None (* JSON解析失败 *)
  | Division_by_zero -> None
(* 计算错误 *)
(* 不捕获其他异常，让系统级错误正常传播 *)

(** 打印统计信息 *)
let print_statistics ?(force_reload = false) () =
  match get_data_statistics ~force_reload () with
  | Some (total_groups, total_chars, cache_hits, cache_misses, last_modified) ->
      Printf.printf "=== Poetry JSON核心统计信息 ===\n";
      Printf.printf "韵组总数: %d\n" total_groups;
      Printf.printf "字符总数: %d\n" total_chars;
      Printf.printf "平均每组字符数: %.1f\n"
        (if total_groups > 0 then float_of_int total_chars /. float_of_int total_groups else 0.0);
      Printf.printf "缓存命中: %d\n" cache_hits;
      Printf.printf "缓存未命中: %d\n" cache_misses;
      Printf.printf "缓存命中率: %.1f%%\n"
        (if cache_hits + cache_misses > 0 then
           100.0 *. float_of_int cache_hits /. float_of_int (cache_hits + cache_misses)
         else 0.0);
      Printf.printf "最后更新: %.0f\n" last_modified
  | None -> Printf.printf "无法获取统计信息\n"

(** 清空缓存 *)
let clear_cache = Cache.clear_cache

(** 获取缓存统计 *)
let get_cache_stats = Cache.get_cache_stats

(** 设置缓存TTL *)
let set_cache_ttl = Cache.set_cache_ttl
