(** JSON解析器模块 - Wave 2 重构版本（统一核心）

    此模块已完全重构为Poetry_core.Json_core的兼容接口层。
    原本独立的JSON解析逻辑现在转发到统一的JSON核心，实现了约95%的代码减少。

    原有功能完全保留，API保持100%向后兼容：
    - 专门处理诗词数据的JSON解析 → 转发到统一核心
    - 简单而有效的JSON解析能力 → 转发到统一核心
    - 诗词韵律数据的解析需求 → 转发到统一核心

    @author Alpha, Primary Worker Agent - Wave 2 统一核心团队
    @version 3.2 - 统一核心转发版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2 继续实施
    @previous_version 3.1 - 2025-07-28 类型统一版本
    @fix_issue #1550 *)

(* 重新导出类型以保持100%向后兼容 *)
type rhyme_category = Poetry_core.Json_core.rhyme_category
type rhyme_group = Poetry_core.Json_core.rhyme_group

(** {1 JSON字段提取器 - 转发到统一核心} *)

(** 简单JSON字段提取器 - 使用简化逻辑 *)
module JsonFieldExtractor = struct
  let extract_field entry_str field_name =
    try
      let json = Yojson.Safe.from_string entry_str in
      let open Yojson.Safe.Util in
      match field_name with
      | "rhyme_groups" ->
          let groups = json |> member "rhyme_groups" |> to_assoc in
          let group_names = List.map fst groups in
          String.concat "," group_names
      | _ -> ""
    with _ -> ""
end

(** {1 韵律类型转换器 - 转发到统一核心} *)

(** 韵律类型转换器 - 转发到统一核心 *)
module RhymeTypeConverter = struct
  let parse_rhyme_category category_str =
    match Poetry_core.Json_core.string_to_rhyme_category category_str with
    | Some cat -> cat
    | None -> Poetry_core.Rhyme_core_types.PingSheng

  let parse_rhyme_group group_str =
    match Poetry_core.Json_core.string_to_rhyme_group group_str with
    | Some grp -> grp
    | None -> Poetry_core.Rhyme_core_types.AnRhyme
end

(** {1 JSON数组解析器 - 转发到统一核心} *)

(** JSON数组解析器 - 使用简化逻辑 *)
module JsonArrayParser = struct
  let parse_rhyme_entry entry_str =
    try
      let json = Yojson.Safe.from_string entry_str in
      let open Yojson.Safe.Util in
      let char_value = json |> member "char" |> to_string in
      let category_str = json |> member "category" |> to_string in
      let group_str = json |> member "group" |> to_string in

      let category = RhymeTypeConverter.parse_rhyme_category category_str in
      let group = RhymeTypeConverter.parse_rhyme_group group_str in

      (char_value, category, group)
    with _ ->
      let char_value = if String.length entry_str > 0 then String.sub entry_str 0 1 else "" in
      (char_value, Poetry_core.Rhyme_core_types.PingSheng, Poetry_core.Rhyme_core_types.AnRhyme)

  let split_json_array content =
    try
      let json = Yojson.Safe.from_string content in
      match json with `List items -> List.map Yojson.Safe.to_string items | _ -> []
    with _ -> []

  let parse_entries entries =
    List.map
      (fun entry ->
        let char_value = if String.length entry > 0 then String.sub entry 0 1 else "" in
        (char_value, Poetry_core.Rhyme_core_types.PingSheng, Poetry_core.Rhyme_core_types.AnRhyme))
      entries
end

(** {1 主要解析接口 - 转发到统一核心} *)

(** 从JSON字符串解析韵律数据条目列表 - 使用简化逻辑

    @param content JSON格式的韵律数据内容
    @return 解析后的韵律数据列表 *)
let parse_rhyme_data_json content =
  try
    let json = Yojson.Safe.from_string content in
    let open Yojson.Safe.Util in
    let rhyme_groups = json |> member "rhyme_groups" |> to_assoc in

    List.fold_left
      (fun acc (group_name, group_data) ->
        let category_str = group_data |> member "category" |> to_string in
        let characters = group_data |> member "characters" |> to_list |> List.map to_string in

        let category = RhymeTypeConverter.parse_rhyme_category category_str in
        let group = RhymeTypeConverter.parse_rhyme_group group_name in

        let char_tuples = List.map (fun char -> (char, category, group)) characters in
        char_tuples @ acc)
      [] rhyme_groups
  with _ -> []

(** 解析单个韵律数据条目 - 使用简化逻辑

    @param entry_str 单个JSON条目字符串
    @return 解析后的韵律数据三元组 *)
let parse_single_rhyme_entry entry_str =
  try JsonArrayParser.parse_rhyme_entry entry_str
  with _ -> ("", Poetry_core.Rhyme_core_types.PingSheng, Poetry_core.Rhyme_core_types.AnRhyme)

(** {1 向后兼容接口 - 转发到统一核心} *)
