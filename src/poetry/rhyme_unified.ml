(** 韵律模块统一接口实现 - 消除重复和简化架构

    @author Alpha代理, 技术债务清理专员
    @version 1.0 - 统一整合版本
    @since 2025-07-29 - 韵律模块整合重构

    参见 issue #1673 *)

(** {1 核心类型重新导出} *)

type rhyme_category = Poetry_core.Json_core.rhyme_category
type rhyme_group = Poetry_core.Json_core.rhyme_group
type rhyme_data_item = Poetry_core.Json_core.rhyme_data_item

(** {1 数据结构类型} *)

type rhyme_group_data = Poetry_core.Json_core.rhyme_group_data = {
  category : string;
  characters : string list;
}

type rhyme_data_file = Poetry_core.Json_core.rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;
  metadata : (string * string) list;
}

(** {1 异常类型} *)

exception Json_parse_error of string
exception Rhyme_data_not_found of string
exception Cache_error of string

(** {1 核心功能模块} *)

(** 数据管理模块 - 整合所有数据加载和缓存功能 *)
module Data = struct
  let get_rhyme_data ?force_reload () =
    try Poetry_core.Json_core.get_rhyme_data_safe ?force_reload () with
    | Poetry_core.Json_core.Json_parse_error msg -> raise (Json_parse_error msg)
    | Poetry_core.Json_core.Cache_error msg -> raise (Cache_error msg)
    | _ -> None

  let get_all_rhyme_groups () =
    match get_rhyme_data () with Some data -> data.rhyme_groups | None -> []

  let get_rhyme_group_characters group_name =
    let groups = get_all_rhyme_groups () in
    try
      let _, group_data = List.find (fun (name, _) -> name = group_name) groups in
      group_data.characters
    with Not_found -> []

  let get_rhyme_group_category group_name =
    let groups = get_all_rhyme_groups () in
    try
      let _, group_data = List.find (fun (name, _) -> name = group_name) groups in
      match Poetry_core.Json_core.string_to_rhyme_category group_data.category with
      | Some cat -> cat
      | None -> Poetry_core.Poetry_types.PingSheng (* 默认值 *)
    with Not_found -> Poetry_core.Poetry_types.PingSheng

  let clear_cache () = Poetry_core.Json_core.Cache.clear_cache ()
  let get_cache_stats () = Poetry_core.Json_core.Cache.get_cache_stats ()
end

(** JSON处理模块 - 整合所有JSON相关功能 *)
module Json = struct
  let parse_rhyme_json json_string =
    try Poetry_core.Json_core.Parser.parse_rhyme_json json_string
    with Poetry_core.Json_core.Json_parse_error msg -> raise (Json_parse_error msg)

  let load_from_file ?filename () =
    try
      match filename with
      | Some file ->
          let content = Poetry_core.Json_core.Io.safe_read_file file in
          parse_rhyme_json content
      | None ->
          let content =
            Poetry_core.Json_core.Io.safe_read_file Poetry_core.Json_core.Io.default_rhyme_data_path
          in
          parse_rhyme_json content
    with
    | Poetry_core.Json_core.Json_parse_error msg -> raise (Json_parse_error msg)
    | Sys_error msg -> raise (Json_parse_error ("File error: " ^ msg))

  let clean_json_string json_string = Poetry_core.Json_core.Parser.clean_json_string json_string
end

(** 查询和分析模块 - 整合韵律分析功能 *)
module Analysis = struct
  let find_character_rhyme char =
    try
      (* 简化实现：通过韵组查找 *)
      let groups = Data.get_all_rhyme_groups () in
      let rec find_in_groups = function
        | [] -> None
        | (group_name, group_data) :: rest ->
            if List.mem char group_data.characters then
              (* 构造 rhyme_data_item *)
              let category =
                match Poetry_core.Json_core.string_to_rhyme_category group_data.category with
                | Some cat -> cat
                | None -> Poetry_core.Poetry_types.PingSheng
              in
              let group =
                match Poetry_core.Json_core.string_to_rhyme_group group_name with
                | Some grp -> grp
                | None -> Poetry_core.Poetry_types.UnknownRhyme
              in
              Some
                {
                  Poetry_core.Poetry_types.character = char;
                  category;
                  group;
                  variants = [];
                  usage_frequency = 1.0;
                }
            else find_in_groups rest
      in
      find_in_groups groups
    with _ -> None

  let get_character_rhyme_group char =
    match find_character_rhyme char with Some entry -> Some entry.group | None -> None

  let can_rhyme_together char1 char2 =
    match (get_character_rhyme_group char1, get_character_rhyme_group char2) with
    | Some group1, Some group2 -> group1 = group2
    | _ -> false

  let find_rhyming_characters char =
    (* Instead of converting group back to string, find it directly from the data *)
    let groups = Data.get_all_rhyme_groups () in
    let rec find_in_groups = function
      | [] -> []
      | (_, group_data) :: rest ->
          if List.mem char group_data.characters then
            group_data.characters |> List.filter (fun c -> c <> char)
          else find_in_groups rest
    in
    find_in_groups groups
end

(** 实用工具模块 - 整合辅助功能 *)
module Utils = struct
  let string_to_rhyme_category s = Poetry_core.Json_core.string_to_rhyme_category s
  let string_to_rhyme_group s = Poetry_core.Json_core.string_to_rhyme_group s

  let get_data_statistics () =
    let groups = Data.get_all_rhyme_groups () in
    let num_groups = List.length groups in
    let total_chars =
      groups
      |> List.fold_left (fun acc (_, group_data) -> acc + List.length group_data.characters) 0
    in
    (num_groups, total_chars)

  let print_statistics () =
    let num_groups, total_chars = get_data_statistics () in
    Printf.printf "韵律数据统计:\n";
    Printf.printf "  韵组数量: %d\n" num_groups;
    Printf.printf "  字符总数: %d\n" total_chars;
    let hits, misses, last_update = Data.get_cache_stats () in
    Printf.printf "  缓存命中: %d\n" hits;
    Printf.printf "  缓存未命中: %d\n" misses;
    Printf.printf "  最后更新: %.0f\n" last_update
end

(** {1 兼容性接口 - 保持向后兼容} *)

(* 为现有代码提供兼容接口，直接转发到模块化接口 *)

let get_rhyme_data ?force_reload () = Data.get_rhyme_data ?force_reload ()
let get_all_rhyme_groups () = Data.get_all_rhyme_groups ()
let get_rhyme_group_characters group = Data.get_rhyme_group_characters group
let get_rhyme_group_category group = Data.get_rhyme_group_category group
let find_character_rhyme char = Analysis.find_character_rhyme char
let can_rhyme_together char1 char2 = Analysis.can_rhyme_together char1 char2
let clear_cache () = Data.clear_cache ()
let string_to_rhyme_category s = Utils.string_to_rhyme_category s
let string_to_rhyme_group s = Utils.string_to_rhyme_group s
let parse_rhyme_json json = Json.parse_rhyme_json json
let load_from_file ?filename () = Json.load_from_file ?filename ()
let get_data_statistics () = Utils.get_data_statistics ()
let print_statistics () = Utils.print_statistics ()
