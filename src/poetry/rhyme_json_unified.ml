(** 韵律JSON统一处理模块 - 诗词模块整合优化 Phase 5.2

    整合原有的多个 rhyme_json_* 模块，提供统一的韵律数据JSON处理接口。

    原模块整合：
    - rhyme_json_loader.ml - 主加载器接口
    - rhyme_json_data_loader.ml - 数据加载器
    - rhyme_json_parser.ml - JSON解析逻辑
    - rhyme_json_access.ml - 数据访问接口
    - rhyme_json_cache.ml - 缓存管理
    - rhyme_json_io.ml - I/O操作
    - rhyme_json_fallback.ml - 降级处理
    - rhyme_json_types.ml - 类型定义（保留独立）

    @author 骆言诗词编程团队
    @version 3.0 - 整合版本
    @since 2025-07-24 - Phase 5.2 诗词模块整合优化 *)

open Rhyme_json_types

(** {1 错误类型定义} *)

exception Rhyme_data_not_found of string
exception Json_parse_error of string
exception Cache_error of string

(** {1 缓存管理} *)

module Cache = struct
  type cache_state = {
    mutable data : rhyme_data_file option;
    mutable last_modified : float;
    mutable cache_hits : int;
    mutable cache_misses : int;
  }
  (** 缓存状态 *)

  (** 全局缓存实例 *)
  let cache_state = { data = None; last_modified = 0.0; cache_hits = 0; cache_misses = 0 }

  (** 清空缓存 *)
  let clear_cache () =
    cache_state.data <- None;
    cache_state.last_modified <- 0.0

  (** 获取缓存数据 *)
  let get_cached_data () =
    match cache_state.data with
    | Some data ->
        cache_state.cache_hits <- cache_state.cache_hits + 1;
        Some data
    | None ->
        cache_state.cache_misses <- cache_state.cache_misses + 1;
        None

  (** 设置缓存数据 *)
  let set_cached_data data =
    cache_state.data <- Some data;
    cache_state.last_modified <- Unix.time ()

  (** 获取缓存统计 *)
  let get_cache_stats () =
    (cache_state.cache_hits, cache_state.cache_misses, cache_state.last_modified)
end

(** {1 JSON解析器} *)

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

  type parse_state = {
    mutable current_group : string option;
    mutable current_category : string;
    mutable current_chars : string list;
    mutable result_groups : (string * rhyme_group_data) list;
    mutable in_rhyme_group : bool;
    mutable in_characters_array : bool;
    mutable brace_depth : int;
    mutable bracket_depth : int;
  }
  (** 解析状态管理 *)

  (** 创建初始解析状态 *)
  let create_parse_state () =
    {
      current_group = None;
      current_category = "";
      current_chars = [];
      result_groups = [];
      in_rhyme_group = false;
      in_characters_array = false;
      brace_depth = 0;
      bracket_depth = 0;
    }

  (** 解析韵律数据JSON *)
  let parse_rhyme_json json_content =
    let _state = create_parse_state () in
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
            let group_data = { category; characters } in
            (group_name, group_data))
          groups
      in

      { rhyme_groups = parsed_groups; metadata = [] }
    with
    | Yojson.Json_error msg -> raise (Json_parse_error ("JSON解析错误: " ^ msg))
    | Yojson.Safe.Util.Type_error (msg, _) -> raise (Json_parse_error ("类型错误: " ^ msg))
    | exn -> raise (Json_parse_error ("未知解析错误: " ^ Printexc.to_string exn))
end

(** {1 I/O操作} *)

module Io = struct
  (** 默认数据文件路径 *)
  let default_rhyme_data_path = "data/poetry/sample_rhyme_data.json"

  (** 读取JSON文件 *)
  let read_json_file file_path =
    try
      let ic = open_in file_path in
      let content = really_input_string ic (in_channel_length ic) in
      close_in ic;
      content
    with
    | Sys_error msg -> raise (Rhyme_data_not_found ("文件读取失败: " ^ msg))
    | exn -> raise (Rhyme_data_not_found ("读取异常: " ^ Printexc.to_string exn))

  (** 获取韵律数据（带缓存） *)
  let get_rhyme_data ?(force_reload = false) () =
    if not force_reload then (
      match Cache.get_cached_data () with
      | Some data -> data
      | None ->
          let content = read_json_file default_rhyme_data_path in
          let data = Parser.parse_rhyme_json content in
          Cache.set_cached_data data;
          data)
    else
      let content = read_json_file default_rhyme_data_path in
      let data = Parser.parse_rhyme_json content in
      Cache.set_cached_data data;
      data
end

(** {1 数据访问接口} *)

module Access = struct
  (** 获取所有韵组 *)
  let get_all_rhyme_groups () =
    let data = Io.get_rhyme_data () in
    data.rhyme_groups

  (** 获取指定韵组的字符列表 *)
  let get_rhyme_group_characters group_name =
    let groups = get_all_rhyme_groups () in
    try
      let _, group_data = List.find (fun (name, _) -> name = group_name) groups in
      group_data.characters
    with Not_found -> []

  (** 获取指定韵组的韵类 *)
  let get_rhyme_group_category group_name =
    let groups = get_all_rhyme_groups () in
    try
      let _, group_data = List.find (fun (name, _) -> name = group_name) groups in
      string_to_rhyme_category group_data.category
    with Not_found -> PingSheng

  (** 获取韵律映射关系 *)
  let get_rhyme_mappings () =
    let groups = get_all_rhyme_groups () in
    let mappings = ref [] in
    List.iter
      (fun (group_name, group_data) ->
        let rhyme_category = string_to_rhyme_category group_data.category in
        let rhyme_group = string_to_rhyme_group group_name in
        List.iter
          (fun char -> mappings := (char, (rhyme_category, rhyme_group)) :: !mappings)
          group_data.characters)
      groups;
    List.rev !mappings

  (** 获取数据统计 *)
  let get_data_statistics () =
    let groups = get_all_rhyme_groups () in
    let total_groups = List.length groups in
    let total_chars =
      List.fold_left (fun acc (_, group_data) -> acc + List.length group_data.characters) 0 groups
    in
    let cache_hits, cache_misses, _last_modified = Cache.get_cache_stats () in
    Printf.sprintf "韵组总数: %d, 字符总数: %d, 缓存命中: %d, 缓存未命中: %d" total_groups total_chars cache_hits
      cache_misses

  (** 打印统计信息 *)
  let print_statistics () = print_endline (get_data_statistics ())
end

(** {1 降级处理} *)

module Fallback = struct
  (** 使用内置的降级数据 *)
  let use_fallback_data () =
    let fallback_groups =
      [
        ("安韵", { category = "平声"; characters = [ "安"; "寒"; "官"; "宽"; "观" ] });
        ("思韵", { category = "平声"; characters = [ "思"; "诗"; "辞"; "词"; "师" ] });
      ]
    in
    let fallback_data = { rhyme_groups = fallback_groups; metadata = [] } in
    Cache.set_cached_data fallback_data;
    fallback_data
end

(** {1 主要API - 统一接口} *)

(** 获取韵律数据（兼容原有接口） *)
let get_rhyme_data ?(force_reload = false) () =
  try Some (Io.get_rhyme_data ~force_reload ())
  with Rhyme_data_not_found _ | Json_parse_error _ -> Some (Fallback.use_fallback_data ())

(** 获取所有韵组（兼容原有接口） *)
let get_all_rhyme_groups = Access.get_all_rhyme_groups

(** 获取韵组字符（兼容原有接口） *)
let get_rhyme_group_characters = Access.get_rhyme_group_characters

(** 获取韵组类别（兼容原有接口） *)
let get_rhyme_group_category = Access.get_rhyme_group_category

(** 获取韵律映射（兼容原有接口） *)
let get_rhyme_mappings = Access.get_rhyme_mappings

(** 获取数据统计（兼容原有接口） *)
let get_data_statistics = Access.get_data_statistics

(** 打印统计信息（兼容原有接口） *)
let print_statistics = Access.print_statistics

(** 使用降级数据（兼容原有接口） *)
let use_fallback_data () = ignore (Fallback.use_fallback_data ())

(** 清空缓存（新增接口） *)
let clear_cache = Cache.clear_cache

(** 获取缓存统计（新增接口） *)
let get_cache_stats = Cache.get_cache_stats
