(** JSON解析器模块 - 专门处理诗词数据的JSON解析

    从原 poetry_data_loader.ml 中提取的JSON解析功能，提供简单而有效的JSON解析能力。 专门优化用于诗词韵律数据的解析需求。

    @author 骆言诗词编程团队 - Phase 15 超长文件重构
    @version 1.0
    @since 2025-07-21 *)

open Rhyme_groups.Rhyme_group_types

(** {1 JSON字段提取器} *)

(** 简单JSON字段提取器 *)
module JsonFieldExtractor = struct
  let extract_field entry_str field_name =
    let field_pattern = "\"" ^ field_name ^ "\":" in
    try
      (* 查找字段模式的位置 *)
      let rec find_pattern pos =
        if pos + String.length field_pattern > String.length entry_str then raise Not_found
        else if String.sub entry_str pos (String.length field_pattern) = field_pattern then pos
        else find_pattern (pos + 1)
      in
      let pattern_pos = find_pattern 0 in
      let value_start_pos = pattern_pos + String.length field_pattern in

      (* 跳过空白符，找到值的起始引号 *)
      let rec skip_whitespace pos =
        if pos >= String.length entry_str then pos
        else
          match entry_str.[pos] with
          | ' ' | '\t' | '\n' | '\r' -> skip_whitespace (pos + 1)
          | '"' -> pos + 1 (* 跳过开始引号 *)
          | _ -> pos
      in
      let value_start = skip_whitespace value_start_pos in

      (* 找到值的结束引号 *)
      let value_end = String.index_from entry_str value_start '"' in
      String.sub entry_str value_start (value_end - value_start)
    with Not_found | Invalid_argument _ -> ""
end

(** {1 韵律类型转换器} *)

(** 韵律类型转换器 *)
module RhymeTypeConverter = struct
  let parse_rhyme_category = function
    | "PingSheng" -> PingSheng
    | "ZeSheng" -> ZeSheng
    | "ShangSheng" -> ShangSheng
    | "QuSheng" -> QuSheng
    | "RuSheng" -> RuSheng
    | _ -> PingSheng (* 默认值 *)

  let parse_rhyme_group = function
    | "AnRhyme" -> AnRhyme
    | "SiRhyme" -> SiRhyme
    | "TianRhyme" -> TianRhyme
    | "WangRhyme" -> WangRhyme
    | "QuRhyme" -> QuRhyme
    | "YuRhyme" -> YuRhyme
    | "HuaRhyme" -> HuaRhyme
    | "FengRhyme" -> FengRhyme
    | "YueRhyme" -> YueRhyme
    | "JiangRhyme" -> JiangRhyme
    | "HuiRhyme" -> HuiRhyme
    | _ -> UnknownRhyme (* 默认值 *)
end

(** {1 JSON数组解析器} *)

(** JSON数组解析器 *)
module JsonArrayParser = struct
  let parse_rhyme_entry entry_str =
    let char_value = JsonFieldExtractor.extract_field entry_str "char" in
    let category_str = JsonFieldExtractor.extract_field entry_str "category" in
    let group_str = JsonFieldExtractor.extract_field entry_str "group" in

    let category = RhymeTypeConverter.parse_rhyme_category category_str in
    let group = RhymeTypeConverter.parse_rhyme_group group_str in

    (char_value, category, group)

  let split_json_array content =
    let trimmed = String.trim content in
    if String.length trimmed < 2 || trimmed.[0] <> '[' || trimmed.[String.length trimmed - 1] <> ']'
    then []
    else
      let inner = String.sub trimmed 1 (String.length trimmed - 2) in
      String.split_on_char '}' inner

  let parse_entries entries =
    List.fold_left
      (fun acc entry ->
        if String.contains entry '"' then
          try
            let parsed = parse_rhyme_entry (entry ^ "}") in
            parsed :: acc
          with _ -> acc
        else acc)
      [] entries
    |> List.rev
end

(** {1 主要解析接口} *)

(** 从JSON字符串解析韵律数据条目列表

    @param content JSON格式的韵律数据内容
    @return 解析后的韵律数据列表 *)
let parse_rhyme_data_json content =
  let entries = JsonArrayParser.split_json_array content in
  JsonArrayParser.parse_entries entries

(** 解析单个韵律数据条目

    @param entry_str 单个JSON条目字符串
    @return 解析后的韵律数据三元组 *)
let parse_single_rhyme_entry entry_str = JsonArrayParser.parse_rhyme_entry entry_str
