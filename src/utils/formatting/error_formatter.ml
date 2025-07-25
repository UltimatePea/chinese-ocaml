(** 骆言统一错误格式化工具模块实现 - Unified Error Formatting Implementation 重构说明：Printf.sprintf统一化第四阶段Phase
    4.1完全重构 - Fix #866
    - 消除所有Printf.sprintf依赖，使用Base_formatter统一格式化
    - 统一错误消息格式标准，提升代码维护性
    - 模块化设计，支持复杂错误格式化场景

    @author 骆言编译器团队
    @since 2025-07-22 Issue #866 Printf.sprintf统一化第四阶段 *)

open Utils.Base_formatter

(** 内部格式化辅助函数 *)
module Internal_formatter = struct
  let format_key_value key value = generic_error_pattern key value
  let format_position filename line col = position_standard filename line col
  let format_position_no_col filename line = concat_strings [ filename; ":"; int_to_string line ]
  let format_context_info count suffix = concat_strings [ int_to_string count; suffix ]

  let format_triple_with_dash pos severity message =
    concat_strings [ pos; " - "; severity; "："; message ]

  let format_category_error category details = generic_error_pattern category details

  (** 测试消息格式化器 - 第九阶段扩展 *)
  module Test_message_formatter = struct
    (** JSON相关测试消息 *)
    let json_parse_failure msg = parse_failure_pattern "JSON" msg

    let empty_json_failure exn = generic_error_pattern "空JSON处理失败" (Printexc.to_string exn)
    let error_type_mismatch exn = type_mismatch_error_pattern (Printexc.to_string exn)
    let should_produce_error desc = concat_strings [ desc; " 应该产生错误" ]

    let wrong_error_type desc exn = concat_strings [ desc; " 错误类型不正确: "; Printexc.to_string exn ]

    (** 韵律相关测试消息 *)
    let structure_validation_failure exn = generic_error_pattern "韵组结构验证失败" (Printexc.to_string exn)

    let classification_test_failure exn = generic_error_pattern "韵类分类测试失败" (Printexc.to_string exn)

    let uniqueness_test_failure exn = generic_error_pattern "字符唯一性测试失败" (Printexc.to_string exn)

    (** 字符相关测试消息 *)
    let character_found_message char = concat_strings [ "找到字符 "; char ]

    let character_should_exist char = concat_strings [ "字符 "; char; " 应该存在" ]
    let character_should_not_exist char = concat_strings [ "字符 "; char; " 不应该存在" ]
    let character_rhyme_group char = concat_strings [ "字符 "; char; " 应属于鱼韵" ]

    let character_rhyme_match char1 char2 should_match =
      concat_strings [ char1; " 和 "; char2; " "; (if should_match then "应该押韵" else "不应该押韵") ]

    (** Unicode测试消息 *)
    let unicode_processing_message char = concat_strings [ "Unicode字符 "; char; " 被正确处理" ]

    let unicode_test_failure exn = generic_error_pattern "Unicode测试失败" (Printexc.to_string exn)
    let simplified_recognition simp = concat_strings [ "简体字 "; simp; " 被识别" ]
    let traditional_recognition trad = concat_strings [ "繁体字 "; trad; " 被识别" ]

    let traditional_simplified_failure exn =
      generic_error_pattern "繁简字符测试失败" (Printexc.to_string exn)

    (** 性能测试消息 *)
    let large_data_failure exn = generic_error_pattern "大规模数据测试失败" (Printexc.to_string exn)

    let query_performance_failure exn = generic_error_pattern "查询性能测试失败" (Printexc.to_string exn)

    let memory_usage_failure exn = generic_error_pattern "内存使用测试失败" (Printexc.to_string exn)

    let long_name_failure exn = generic_error_pattern "长字符名测试失败" (Printexc.to_string exn)

    let special_char_failure exn = generic_error_pattern "特殊字符测试失败" (Printexc.to_string exn)

    let error_recovery_failure exn = generic_error_pattern "错误恢复失败" (Printexc.to_string exn)

    (** 艺术性评价测试消息 *)
    let score_range_message desc dimension = concat_strings [ desc; " - "; dimension; "评分在有效范围" ]

    let dimension_correct_message desc dimension =
      concat_strings [ desc; " - "; dimension; "评价维度正确" ]

    let evaluation_failure_message desc dimension error =
      concat_strings [ desc; " "; dimension; "评价失败: "; error ]

    let context_creation_message desc = concat_strings [ desc; " - 上下文创建成功" ]
    let context_creation_failure desc error = concat_strings [ desc; " 上下文创建失败: "; error ]
    let empty_poem_failure error = generic_error_pattern "空诗句处理失败" error
    let dimension_count_message desc = concat_strings [ desc; " - 评价维度数量" ]
    let complete_evaluation_failure desc error = concat_strings [ desc; " 完整评价失败: "; error ]

    let unicode_processing_message_with_feature desc feature =
      concat_strings [ desc; " - "; feature; "处理" ]

    let unicode_processing_failure desc feature error =
      concat_strings [ desc; " "; feature; "处理失败: "; error ]

    let long_poem_failure error = generic_error_pattern "长诗词处理失败" error
    let abnormal_char_failure desc error = concat_strings [ desc; " 异常字符处理失败: "; error ]
    let extreme_case_failure desc error = concat_strings [ desc; " 极限情况处理失败: "; error ]
    let abnormal_char_message desc = concat_strings [ desc; " - 异常字符处理" ]
    let extreme_case_message desc = concat_strings [ desc; " - 极限情况处理" ]

    (** 通用测试异常消息 *)
    let unexpected_exception exn = unexpected_exception_pattern (Printexc.to_string exn)
  end
end

(** 错误类型定义 *)
type error_severity = Fatal  (** 致命错误 *) | Error  (** 错误 *) | Warning  (** 警告 *) | Info  (** 信息 *)

type position_info = { filename : string; line : int; column : int option }
(** 位置信息类型 *)

(** 错误消息格式化工具 *)
module Message = struct
  (** 获取错误严重性的中文描述 *)
  let severity_to_chinese = function
    | Fatal -> "致命错误"
    | Error -> "错误"
    | Warning -> "警告"
    | Info -> "信息"

  (** 格式化基本错误消息 *)
  let format_error severity message =
    Internal_formatter.format_key_value (severity_to_chinese severity) message

  (** 格式化位置信息 *)
  let format_position pos =
    match pos.column with
    | Some col -> Internal_formatter.format_position pos.filename pos.line col
    | None -> Internal_formatter.format_position_no_col pos.filename pos.line

  (** 格式化带位置的错误消息 *)
  let format_error_with_position severity message pos =
    Internal_formatter.format_triple_with_dash (format_position pos) (severity_to_chinese severity)
      message

  (** 格式化词法错误 *)
  let format_lexical_error error_type details =
    Internal_formatter.format_category_error "词法错误" (error_type ^ " '" ^ details ^ "'")

  (** 格式化语法错误 *)
  let format_parse_error error_type details =
    Internal_formatter.format_category_error "解析错误" (error_type ^ " '" ^ details ^ "'")

  (** 格式化语义错误 *)
  let format_semantic_error error_type details =
    Internal_formatter.format_category_error "语义错误" (error_type ^ " '" ^ details ^ "'")

  (** 格式化类型错误 *)
  let format_type_error error_type details =
    Internal_formatter.format_category_error "类型错误" (error_type ^ " '" ^ details ^ "'")

  (** 格式化运行时错误 *)
  let format_runtime_error error_type details =
    Internal_formatter.format_category_error "运行时错误" (error_type ^ " '" ^ details ^ "'")
end

(** 错误恢复建议工具 *)
module Recovery = struct
  (** 生成错误恢复建议 *)
  let suggest_recovery error_message =
    let suggestions = ref [] in

    (* 基于错误消息关键词生成建议 *)
    if Str.string_match (Str.regexp ".*未.*") error_message 0 then
      suggestions := "检查语法是否完整" :: !suggestions;

    if Str.string_match (Str.regexp ".*无效.*") error_message 0 then
      suggestions := "检查标识符或关键字拼写" :: !suggestions;

    if Str.string_match (Str.regexp ".*缺少.*") error_message 0 then
      suggestions := "补充缺失的语法元素" :: !suggestions;

    if Str.string_match (Str.regexp ".*类型.*") error_message 0 then
      suggestions := "检查变量类型是否匹配" :: !suggestions;

    match !suggestions with [] -> [ "检查代码语法和语义" ] | _ -> List.rev !suggestions

  (** 格式化恢复建议 *)
  let format_suggestions suggestions =
    match suggestions with
    | [] -> ""
    | [ single ] -> Internal_formatter.format_key_value "建议" single
    | multiple ->
        let numbered_suggestions =
          List.mapi
            (fun i suggestion -> concat_strings [ "  "; int_to_string (i + 1); ". "; suggestion ])
            multiple
        in
        "建议：\n" ^ String.concat "\n" numbered_suggestions

  (** 组合错误消息和建议 *)
  let combine_error_and_suggestions error_msg suggestions =
    let suggestion_text = format_suggestions suggestions in
    if String.length suggestion_text = 0 then error_msg else error_msg ^ "\n" ^ suggestion_text
end

(** 错误统计和报告工具 *)
module Statistics = struct
  type error_stats = { fatal_count : int; error_count : int; warning_count : int; info_count : int }
  (** 错误统计信息 *)

  (** 格式化错误统计报告 *)
  let format_error_summary stats =
    let parts = [] in
    let parts =
      if stats.fatal_count > 0 then
        Internal_formatter.format_context_info stats.fatal_count "个致命错误" :: parts
      else parts
    in
    let parts =
      if stats.error_count > 0 then
        Internal_formatter.format_context_info stats.error_count "个错误" :: parts
      else parts
    in
    let parts =
      if stats.warning_count > 0 then
        Internal_formatter.format_context_info stats.warning_count "个警告" :: parts
      else parts
    in
    let parts =
      if stats.info_count > 0 then
        Internal_formatter.format_context_info stats.info_count "个信息" :: parts
      else parts
    in

    match parts with [] -> "编译成功，无错误或警告" | _ -> "编译完成：" ^ String.concat "，" (List.rev parts)

  (** 判断是否有阻塞性错误 *)
  let has_blocking_errors stats = stats.fatal_count > 0 || stats.error_count > 0
end

(** 用户友好的错误消息工具 *)
module UserFriendly = struct
  (** 将技术错误消息转换为用户友好的描述 *)
  let make_user_friendly technical_message =
    (* 简化技术术语为用户友好的描述 *)
    let message = String.lowercase_ascii technical_message in
    if Str.string_match (Str.regexp ".*failwith.*") message 0 then "程序遇到了意外情况"
    else if Str.string_match (Str.regexp ".*not_found.*") message 0 then "找不到指定的内容"
    else if Str.string_match (Str.regexp ".*invalid_argument.*") message 0 then "提供的参数无效"
    else if Str.string_match (Str.regexp ".*end_of_file.*") message 0 then "文件意外结束"
    else technical_message

  (** 添加解决方案提示 *)
  let add_solution_hint error_message hint =
    error_message ^ "\n💡 " ^ Internal_formatter.format_key_value "提示" hint

  (** 格式化详细错误报告 *)
  let format_detailed_report error_message position_opt suggestions =
    let header =
      match position_opt with
      | Some pos -> Message.format_position pos ^ " - " ^ error_message
      | None -> error_message
    in

    let friendly_message = make_user_friendly error_message in
    let suggestion_text = Recovery.format_suggestions suggestions in

    if String.length suggestion_text = 0 then header ^ "\n" ^ friendly_message
    else header ^ "\n" ^ friendly_message ^ "\n" ^ suggestion_text
end
