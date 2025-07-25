(** 骆言编译器核心格式化模块

    本模块包含通用格式化工具和基础功能，从unified_formatter.ml中拆分出来。 提供统一的格式化接口，消除Printf.sprintf依赖。

    重构目的：大型模块细化 - Fix #893
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-22 *)

(* 引入基础格式化器，实现零Printf.sprintf依赖 *)
open Utils.Base_formatter

(** 通用格式化工具 *)
module General = struct
  let format_identifier name = concat_strings [ "「"; name; "」" ]
  let format_function_signature name params = function_call_format name params

  let format_type_signature name type_params =
    concat_strings [ name; "<"; join_with_separator ", " type_params; ">" ]

  let format_module_path path = join_with_separator "." path
  let format_list items separator = join_with_separator separator items
  let format_key_value key value = context_message_pattern key value

  (** 中文语法相关 *)
  let format_chinese_list items = join_with_separator "、" items

  let format_variable_definition var_name = concat_strings [ "让 「"; var_name; "」 = 值" ]

  let format_context_info count item_type =
    concat_strings [ "当前作用域中有 "; int_to_string count; " 个可用"; item_type ]

  (** 扩展通用格式化 *)
  let format_range start_val end_val =
    concat_strings [ int_to_string start_val; ".."; int_to_string end_val ]

  let format_percentage value = concat_strings [ float_to_string value; "%" ]
  let format_size_info bytes = concat_strings [ int_to_string bytes; " 字节" ]
  let format_duration_ms ms = concat_strings [ int_to_string ms; "ms" ]
  let format_duration_sec sec = concat_strings [ float_to_string sec; "秒" ]
end

(** 索引和数组操作格式化 *)
module Collections = struct
  let index_out_of_bounds index length = index_out_of_bounds_pattern index length

  let array_access_error array_name index =
    concat_strings [ "数组 "; array_name; " 索引 "; int_to_string index; " 访问错误" ]

  let array_bounds_error index array_length =
    concat_strings [ "数组索引越界: "; int_to_string index; " (数组长度: "; int_to_string array_length; ")" ]

  let list_operation_error operation = context_message_pattern "列表操作错误" operation

  (** 扩展集合操作 *)
  let empty_collection_error operation collection_type =
    concat_strings [ "空"; collection_type; "错误: 无法执行操作 "; operation ]

  let collection_size_mismatch expected actual =
    concat_strings [ "集合大小不匹配: 期望 "; int_to_string expected; ", 实际 "; int_to_string actual ]

  let format_collection_info collection_type size capacity =
    concat_strings [ collection_type; " 信息: 大小 "; int_to_string size; "/"; int_to_string capacity ]
end

(** 转换和类型转换格式化 *)
module Conversions = struct
  let type_conversion target_type expr = concat_strings [ "("; target_type; ")"; expr ]

  let casting_error from_type to_type = concat_strings [ "无法将 "; from_type; " 转换为 "; to_type ]

  (** 扩展转换功能 *)
  let format_conversion_attempt from_type to_type =
    concat_strings [ "尝试转换: "; from_type; " -> "; to_type ]

  let format_conversion_success from_type to_type result =
    concat_strings [ "转换成功: "; from_type; " -> "; to_type; " = "; result ]

  let format_conversion_failure from_type to_type reason =
    concat_strings [ "转换失败: "; from_type; " -> "; to_type; " ("; reason; ")" ]
end

(** 类型系统格式化 - Phase 3B 新增 *)
module TypeFormatter = struct
  (** 函数类型格式化 *)
  let format_function_type param_type ret_type =
    concat_strings [ "("; param_type; " -> "; ret_type; ")" ]

  (** 列表类型格式化 *)
  let format_list_type element_type = concat_strings [ "["; element_type; "]" ]

  (** 构造类型格式化 *)
  let format_construct_type name type_args =
    concat_strings [ name; "<"; join_with_separator ", " type_args; ">" ]

  (** 引用类型格式化 *)
  let format_reference_type inner_type = concat_strings [ "ref<"; inner_type; ">" ]

  (** 数组类型格式化 *)
  let format_array_type element_type = concat_strings [ "[|"; element_type; "|]" ]

  (** 类类型格式化 *)
  let format_class_type name methods_str = concat_strings [ "class "; name; " {"; methods_str; "}" ]

  (** 元组类型格式化 *)
  let format_tuple_type type_list = concat_strings [ "("; join_with_separator " * " type_list; ")" ]

  (** 记录类型格式化 *)
  let format_record_type fields_str = concat_strings [ "{"; fields_str; "}" ]

  (** 对象类型格式化 *)
  let format_object_type methods_str = concat_strings [ "{"; methods_str; "}" ]

  (** 多态变体类型格式化 *)
  let format_variant_type variants_str = concat_strings [ "["; variants_str; "]" ]

  (** 扩展类型格式化 *)
  let format_option_type inner_type = concat_strings [ inner_type; " option" ]

  let format_result_type ok_type error_type =
    concat_strings [ "("; ok_type; ", "; error_type; ") result" ]

  let format_generic_type base_type type_params =
    match type_params with
    | [] -> base_type
    | _ -> concat_strings [ base_type; "<"; join_with_separator ", " type_params; ">" ]
end

(** 报告格式化模块 *)
module ReportFormatting = struct
  (** Token注册器统计报告 *)
  let token_registry_stats total categories_count categories_detail =
    concat_strings
      [
        "\n=== Token注册器统计 ===\n";
        "注册Token数: ";
        int_to_string total;
        " 个\n";
        "分类数: ";
        int_to_string categories_count;
        " 个\n";
        "分类详情: ";
        categories_detail;
        "\n  ";
      ]

  (** 分类统计项格式化 *)
  let category_count_item category count =
    concat_strings [ category; "("; int_to_string count; ")" ]

  (** Token兼容性基础报告 *)
  let token_compatibility_report total_count timestamp =
    concat_strings
      [
        "Token兼容性报告\n================\n";
        "总支持Token数量: ";
        int_to_string total_count;
        "\n";
        "兼容性状态: 良好\n";
        "报告生成时间: ";
        timestamp;
      ]

  (** 详细Token兼容性报告 *)
  let detailed_token_compatibility_report total_count report_timestamp =
    concat_strings
      [
        "详细Token兼容性报告\n";
        "=====================\n\n";
        "支持的Token类型:\n";
        "- 基础关键字: 19个\n";
        "- 文言文关键字: 12个\n";
        "- 古雅体关键字: 8个\n";
        "- 运算符: 22个\n";
        "- 分隔符: 23个\n\n";
        "总计: ";
        int_to_string total_count;
        "个Token类型\n";
        "兼容性覆盖率: 良好\n\n";
        "报告生成时间: ";
        report_timestamp;
      ]

  (** 扩展报告功能 *)
  let format_summary_section title items =
    let header = concat_strings [ "=== "; title; " ===" ] in
    let formatted_items = List.map (fun item -> concat_strings [ "- "; item ]) items in
    join_with_separator "\n" (header :: formatted_items)

  let format_metrics_table metrics =
    let header = "指标\t\t值" in
    let separator = "----\t\t----" in
    let formatted_metrics =
      List.map (fun (name, value) -> concat_strings [ name; "\t\t"; value ]) metrics
    in
    join_with_separator "\n" (header :: separator :: formatted_metrics)

  let format_comparison_report name1 name2 differences =
    let header = concat_strings [ "比较报告: "; name1; " vs "; name2 ] in
    let diff_section = "差异:" in
    let formatted_diffs = List.map (fun diff -> concat_strings [ "- "; diff ]) differences in
    join_with_separator "\n" (header :: diff_section :: formatted_diffs)
end

(** Phase 4: 字符串处理基础设施格式化 *)
module StringProcessingFormatter = struct
  (** 错误模板格式化 *)
  let format_error_template template_name error_detail =
    concat_strings [ template_name; "模板错误: "; error_detail ]

  (** 位置信息格式化 *)
  let format_position_info line column =
    concat_strings [ "第"; int_to_string line; "行第"; int_to_string column; "列" ]

  (** Token信息格式化 *)
  let format_token_info token_name token_value =
    concat_strings [ token_name; "("; token_value; ")" ]

  (** 报告段落格式化 *)
  let format_report_section section_title section_content =
    concat_strings [ "=== "; section_title; " ===\n"; section_content ]

  (** 消息模板格式化 *)
  let format_message_template template_text parameters =
    let replace_placeholder text params =
      List.fold_left
        (fun acc param ->
          let index = try String.index acc '%' with Not_found -> -1 in
          if index >= 0 && index < String.length acc - 1 && acc.[index + 1] = 's' then
            String.sub acc 0 index ^ param
            ^ String.sub acc (index + 2) (String.length acc - index - 2)
          else acc)
        text params
    in
    replace_placeholder template_text parameters

  (** 扩展字符串处理 *)
  let format_string_operation operation input_str result_str =
    concat_strings [ "字符串操作 ["; operation; "]: '"; input_str; "' -> '"; result_str; "'" ]

  let format_pattern_match pattern input success =
    let status = if success then "匹配" else "不匹配" in
    concat_strings [ "模式匹配: '"; pattern; "' "; status; " '"; input; "'" ]

  let format_encoding_info original_encoding target_encoding =
    concat_strings [ "编码转换: "; original_encoding; " -> "; target_encoding ]
end

(** 扩展功能模块 *)
module ExtendedFormatting = struct
  (** 版本信息格式化 *)
  let format_version_info major minor patch =
    concat_strings [ int_to_string major; "."; int_to_string minor; "."; int_to_string patch ]

  let format_build_info version build_number commit_hash =
    concat_strings [ version; " (构建 "; int_to_string build_number; ", 提交 "; commit_hash; ")" ]

  (** 配置信息格式化 *)
  let format_config_entry key value description =
    concat_strings [ key; " = "; value; " # "; description ]

  let format_config_section section_name entries =
    let header = concat_strings [ "["; section_name; "]" ] in
    join_with_separator "\n" (header :: entries)

  (** 依赖信息格式化 *)
  let format_dependency name version optional =
    let opt_marker = if optional then " (可选)" else "" in
    concat_strings [ name; " v"; version; opt_marker ]

  let format_dependency_tree level dependency_name sub_deps =
    let indent = String.make (level * 2) ' ' in
    let main_entry = concat_strings [ indent; dependency_name ] in
    let sub_entries = List.map (fun sub -> concat_strings [ indent; "  "; sub ]) sub_deps in
    join_with_separator "\n" (main_entry :: sub_entries)

  (** 环境信息格式化 *)
  let format_environment_var name value sensitive =
    if sensitive then concat_strings [ name; " = ***（敏感信息已隐藏）" ]
    else concat_strings [ name; " = "; value ]

  let format_system_info os_name os_version arch =
    concat_strings [ os_name; " "; os_version; " ("; arch; ")" ]
end
