(** 骆言编译器核心格式化模块全面测试 - Stage 2.1: Core formatter tests
    
    本测试文件针对formatter_core.ml提供全面的测试覆盖率，特别关注：
    - TypeFormatter模块的完整测试
    - ReportFormatting模块的测试 
    - StringProcessingFormatter模块的测试
    - ExtendedFormatting模块的测试
    
    Author: Alpha, 主工作代理
    Fix #1692 - 测试覆盖率提升计划第二阶段
    @since 2025-07-29 *)

open Alcotest
open Yyocamlc_lib.Formatter_core

(** 帮助函数：检查字符串是否包含子字符串 *)
let contains_substring s sub =
  try
    let _ = Str.search_forward (Str.regexp_string sub) s 0 in
    true
  with Not_found -> false


(** 帮助函数：检查字符串是否是有效的格式化结果 *)
let is_valid_format result = String.length result > 0

(** 测试TypeFormatter模块 *)
module Test_TypeFormatter = struct
  (** 测试函数类型格式化 *)
  let test_format_function_type () =
    let result = TypeFormatter.format_function_type "int" "string" in
    check string "函数类型格式化" "(int -> string)" result;
    
    let complex_result = TypeFormatter.format_function_type "('a * 'b)" "('a -> 'b)" in
    check string "复杂函数类型格式化" "(('a * 'b) -> ('a -> 'b))" complex_result;
    
    let unit_result = TypeFormatter.format_function_type "unit" "unit" in
    check string "Unit函数类型格式化" "(unit -> unit)" unit_result

  (** 测试列表类型格式化 *)
  let test_format_list_type () =
    let result = TypeFormatter.format_list_type "int" in
    check string "整数列表类型格式化" "[int]" result;
    
    let string_result = TypeFormatter.format_list_type "string" in
    check string "字符串列表类型格式化" "[string]" string_result;
    
    let complex_result = TypeFormatter.format_list_type "('a * 'b)" in
    check string "复杂列表类型格式化" "[('a * 'b)]" complex_result

  (** 测试构造类型格式化 *)
  let test_format_construct_type () =
    let result = TypeFormatter.format_construct_type "List" ["int"] in
    check string "单参数构造类型" "List<int>" result;
    
    let multi_result = TypeFormatter.format_construct_type "Map" ["string"; "int"] in
    check string "多参数构造类型" "Map<string, int>" multi_result;
    
    let empty_result = TypeFormatter.format_construct_type "Unit" [] in
    check string "无参数构造类型" "Unit<>" empty_result

  (** 测试引用类型格式化 *)
  let test_format_reference_type () =
    let result = TypeFormatter.format_reference_type "int" in
    check string "整数引用类型" "ref<int>" result;
    
    let complex_result = TypeFormatter.format_reference_type "('a list)" in
    check string "复杂引用类型" "ref<('a list)>" complex_result

  (** 测试数组类型格式化 *)
  let test_format_array_type () =
    let result = TypeFormatter.format_array_type "int" in
    check string "整数数组类型" "[|int|]" result;
    
    let string_result = TypeFormatter.format_array_type "string" in
    check string "字符串数组类型" "[|string|]" string_result

  (** 测试类类型格式化 *)
  let test_format_class_type () =
    let result = TypeFormatter.format_class_type "Person" "name: string; age: int" in
    check bool "类类型包含类名" true (contains_substring result "Person");
    check bool "类类型包含方法" true (contains_substring result "name: string; age: int");
    
    let empty_result = TypeFormatter.format_class_type "Empty" "" in
    check bool "空类类型包含类名" true (contains_substring empty_result "Empty")

  (** 测试元组类型格式化 *)
  let test_format_tuple_type () =
    let result = TypeFormatter.format_tuple_type ["int"; "string"] in
    check string "两元素元组类型" "(int * string)" result;
    
    let triple_result = TypeFormatter.format_tuple_type ["int"; "string"; "bool"] in
    check string "三元素元组类型" "(int * string * bool)" triple_result;
    
    let single_result = TypeFormatter.format_tuple_type ["int"] in
    check string "单元素元组类型" "(int)" single_result

  (** 测试记录类型格式化 *)
  let test_format_record_type () =
    let result = TypeFormatter.format_record_type "name: string; age: int" in
    check string "记录类型格式化" "{name: string; age: int}" result;
    
    let empty_result = TypeFormatter.format_record_type "" in
    check string "空记录类型格式化" "{}" empty_result

  (** 测试对象类型格式化 *)
  let test_format_object_type () =
    let result = TypeFormatter.format_object_type "method1: unit -> int" in
    check string "对象类型格式化" "{method1: unit -> int}" result

  (** 测试多态变体类型格式化 *)
  let test_format_variant_type () =
    let result = TypeFormatter.format_variant_type "`A | `B of int" in
    check string "变体类型格式化" "[`A | `B of int]" result

  (** 测试扩展类型格式化 *)
  let test_extended_type_formatting () =
    let option_result = TypeFormatter.format_option_type "int" in
    check string "Option类型格式化" "int option" option_result;
    
    let result_result = TypeFormatter.format_result_type "string" "error" in
    check string "Result类型格式化" "(string, error) result" result_result;
    
    let generic_result = TypeFormatter.format_generic_type "List" ["int"; "string"] in
    check string "泛型类型格式化" "List<int, string>" generic_result;
    
    let simple_generic = TypeFormatter.format_generic_type "Option" [] in
    check string "无参数泛型类型" "Option" simple_generic
end

(** 测试ReportFormatting模块 *)
module Test_ReportFormatting = struct
  (** 测试Token注册器统计报告 *)
  let test_token_registry_stats () =
    let result = ReportFormatting.token_registry_stats 100 5 "关键字(20), 运算符(30)" in
    check bool "统计包含总数" true (contains_substring result "100");
    check bool "统计包含分类数" true (contains_substring result "5");
    check bool "统计包含详情" true (contains_substring result "关键字(20)");
    
    let empty_result = ReportFormatting.token_registry_stats 0 0 "" in
    check bool "空统计包含零值" true (contains_substring empty_result "0")

  (** 测试分类统计项格式化 *)
  let test_category_count_item () =
    let result = ReportFormatting.category_count_item "关键字" 25 in
    check string "分类统计项格式化" "关键字(25)" result;
    
    let zero_result = ReportFormatting.category_count_item "空分类" 0 in
    check string "零计数分类统计" "空分类(0)" zero_result

  (** 测试Token兼容性基础报告 *)
  let test_token_compatibility_report () =
    let timestamp = "2025-07-29 12:00:00" in
    let result = ReportFormatting.token_compatibility_report 84 timestamp in
    check bool "兼容性报告包含总数" true (contains_substring result "84");
    check bool "兼容性报告包含时间戳" true (contains_substring result timestamp);
    check bool "兼容性报告包含状态" true (contains_substring result "良好")

  (** 测试详细Token兼容性报告 *)
  let test_detailed_token_compatibility_report () =
    let timestamp = "2025-07-29 12:00:00" in
    let result = ReportFormatting.detailed_token_compatibility_report 84 timestamp in
    check bool "详细报告包含总数" true (contains_substring result "84");
    check bool "详细报告包含基础关键字" true (contains_substring result "基础关键字");
    check bool "详细报告包含文言文关键字" true (contains_substring result "文言文关键字");
    check bool "详细报告包含时间戳" true (contains_substring result timestamp)

  (** 测试扩展报告功能 *)
  let test_extended_report_features () =
    let summary_result = ReportFormatting.format_summary_section "测试结果" ["通过: 10"; "失败: 2"] in
    check bool "摘要部分包含标题" true (contains_substring summary_result "测试结果");
    check bool "摘要部分包含条目" true (contains_substring summary_result "通过: 10");
    
    let metrics_result = ReportFormatting.format_metrics_table [("覆盖率", "85%"); ("耗时", "120ms")] in
    check bool "指标表包含覆盖率" true (contains_substring metrics_result "覆盖率");
    check bool "指标表包含耗时" true (contains_substring metrics_result "120ms");
    
    let comparison_result = ReportFormatting.format_comparison_report "版本A" "版本B" ["性能提升10%"; "内存减少5%"] in
    check bool "比较报告包含版本A" true (contains_substring comparison_result "版本A");
    check bool "比较报告包含版本B" true (contains_substring comparison_result "版本B");
    check bool "比较报告包含差异" true (contains_substring comparison_result "性能提升10%")
end

(** 测试StringProcessingFormatter模块 *)
module Test_StringProcessingFormatter = struct
  (** 测试错误模板格式化 *)
  let test_format_error_template () =
    let result = StringProcessingFormatter.format_error_template "解析" "语法错误" in
    check bool "错误模板包含模板名" true (contains_substring result "解析");
    check bool "错误模板包含错误详情" true (contains_substring result "语法错误")

  (** 测试位置信息格式化 *)
  let test_format_position_info () =
    let result = StringProcessingFormatter.format_position_info 10 25 in
    check string "位置信息格式化" "第10行第25列" result;
    
    let zero_result = StringProcessingFormatter.format_position_info 0 0 in
    check string "零位置信息格式化" "第0行第0列" zero_result

  (** 测试Token信息格式化 *)
  let test_format_token_info () =
    let result = StringProcessingFormatter.format_token_info "IDENTIFIER" "变量名" in
    check string "Token信息格式化" "IDENTIFIER(变量名)" result;
    
    let empty_result = StringProcessingFormatter.format_token_info "EOF" "" in
    check string "空值Token信息" "EOF()" empty_result

  (** 测试报告段落格式化 *)
  let test_format_report_section () =
    let result = StringProcessingFormatter.format_report_section "错误汇总" "共发现3个错误" in
    check bool "报告段落包含标题" true (contains_substring result "错误汇总");
    check bool "报告段落包含内容" true (contains_substring result "共发现3个错误")

  (** 测试消息模板格式化 *)
  let test_format_message_template () =
    let result = StringProcessingFormatter.format_message_template "Hello %s" ["World"] in
    check bool "消息模板格式化有效" true (is_valid_format result);
    
    let multi_param = StringProcessingFormatter.format_message_template "名称: %s, 年龄: %s" ["张三"; "25"] in
    check bool "多参数消息模板有效" true (is_valid_format multi_param)

  (** 测试扩展字符串处理 *)
  let test_extended_string_processing () =
    let operation_result = StringProcessingFormatter.format_string_operation "大写转换" "hello" "HELLO" in
    check bool "字符串操作包含操作名" true (contains_substring operation_result "大写转换");
    check bool "字符串操作包含输入" true (contains_substring operation_result "hello");
    check bool "字符串操作包含结果" true (contains_substring operation_result "HELLO");
    
    let match_success = StringProcessingFormatter.format_pattern_match "\\d+" "123" true in
    check bool "匹配成功格式化包含模式" true (contains_substring match_success "\\d+");
    check bool "匹配成功格式化包含输入" true (contains_substring match_success "123");
    check bool "匹配成功格式化包含匹配" true (contains_substring match_success "匹配");
    
    let match_failure = StringProcessingFormatter.format_pattern_match "\\d+" "abc" false in
    check bool "匹配失败格式化包含不匹配" true (contains_substring match_failure "不匹配");
    
    let encoding_result = StringProcessingFormatter.format_encoding_info "UTF-8" "GBK" in
    check bool "编码信息包含源编码" true (contains_substring encoding_result "UTF-8");
    check bool "编码信息包含目标编码" true (contains_substring encoding_result "GBK")
end

(** 测试ExtendedFormatting模块 *)
module Test_ExtendedFormatting = struct
  (** 测试版本信息格式化 *)
  let test_format_version_info () =
    let result = ExtendedFormatting.format_version_info 1 2 3 in
    check string "版本信息格式化" "1.2.3" result;
    
    let major_result = ExtendedFormatting.format_version_info 2 0 0 in
    check string "主版本格式化" "2.0.0" major_result

  (** 测试构建信息格式化 *)
  let test_format_build_info () =
    let result = ExtendedFormatting.format_build_info "1.2.3" 456 "abc123" in
    check bool "构建信息包含版本" true (contains_substring result "1.2.3");
    check bool "构建信息包含构建号" true (contains_substring result "456");
    check bool "构建信息包含提交哈希" true (contains_substring result "abc123")

  (** 测试配置信息格式化 *)
  let test_format_config_info () =
    let entry_result = ExtendedFormatting.format_config_entry "debug" "true" "启用调试模式" in
    check bool "配置条目包含键" true (contains_substring entry_result "debug");
    check bool "配置条目包含值" true (contains_substring entry_result "true");
    check bool "配置条目包含描述" true (contains_substring entry_result "启用调试模式");
    
    let section_result = ExtendedFormatting.format_config_section "数据库" ["host=localhost"; "port=5432"] in
    check bool "配置段落包含段名" true (contains_substring section_result "数据库");
    check bool "配置段落包含条目" true (contains_substring section_result "host=localhost")

  (** 测试依赖信息格式化 *)
  let test_format_dependency_info () =
    let dep_result = ExtendedFormatting.format_dependency "alcotest" "1.2.0" false in
    check bool "依赖信息包含名称" true (contains_substring dep_result "alcotest");
    check bool "依赖信息包含版本" true (contains_substring dep_result "1.2.0");
    check bool "必需依赖不包含可选标记" false (contains_substring dep_result "可选");
    
    let optional_dep = ExtendedFormatting.format_dependency "lwt" "5.4.0" true in
    check bool "可选依赖包含可选标记" true (contains_substring optional_dep "可选");
    
    let tree_result = ExtendedFormatting.format_dependency_tree 1 "主依赖" ["子依赖1"; "子依赖2"] in
    check bool "依赖树包含主依赖" true (contains_substring tree_result "主依赖");
    check bool "依赖树包含子依赖" true (contains_substring tree_result "子依赖1")

  (** 测试环境信息格式化 *)
  let test_format_environment_info () =
    let normal_env = ExtendedFormatting.format_environment_var "PATH" "/usr/bin:/bin" false in
    check bool "普通环境变量包含名称" true (contains_substring normal_env "PATH");
    check bool "普通环境变量包含值" true (contains_substring normal_env "/usr/bin:/bin");
    
    let sensitive_env = ExtendedFormatting.format_environment_var "API_KEY" "secret123" true in
    check bool "敏感环境变量包含名称" true (contains_substring sensitive_env "API_KEY");
    check bool "敏感环境变量隐藏值" true (contains_substring sensitive_env "敏感信息已隐藏");
    check bool "敏感环境变量不包含实际值" false (contains_substring sensitive_env "secret123");
    
    let system_result = ExtendedFormatting.format_system_info "Linux" "5.4.0" "x86_64" in
    check bool "系统信息包含操作系统" true (contains_substring system_result "Linux");
    check bool "系统信息包含版本" true (contains_substring system_result "5.4.0");
    check bool "系统信息包含架构" true (contains_substring system_result "x86_64")
end

let () =
  run "骆言核心格式化模块全面测试"
    [
      ( "类型格式化器",
        [
          test_case "函数类型格式化" `Quick Test_TypeFormatter.test_format_function_type;
          test_case "列表类型格式化" `Quick Test_TypeFormatter.test_format_list_type;
          test_case "构造类型格式化" `Quick Test_TypeFormatter.test_format_construct_type;
          test_case "引用类型格式化" `Quick Test_TypeFormatter.test_format_reference_type;
          test_case "数组类型格式化" `Quick Test_TypeFormatter.test_format_array_type;
          test_case "类类型格式化" `Quick Test_TypeFormatter.test_format_class_type;
          test_case "元组类型格式化" `Quick Test_TypeFormatter.test_format_tuple_type;
          test_case "记录类型格式化" `Quick Test_TypeFormatter.test_format_record_type;
          test_case "对象类型格式化" `Quick Test_TypeFormatter.test_format_object_type;
          test_case "变体类型格式化" `Quick Test_TypeFormatter.test_format_variant_type;
          test_case "扩展类型格式化" `Quick Test_TypeFormatter.test_extended_type_formatting;
        ] );
      ( "报告格式化",
        [
          test_case "Token注册器统计报告" `Quick Test_ReportFormatting.test_token_registry_stats;
          test_case "分类统计项格式化" `Quick Test_ReportFormatting.test_category_count_item;
          test_case "Token兼容性基础报告" `Quick Test_ReportFormatting.test_token_compatibility_report;
          test_case "详细Token兼容性报告" `Quick Test_ReportFormatting.test_detailed_token_compatibility_report;
          test_case "扩展报告功能" `Quick Test_ReportFormatting.test_extended_report_features;
        ] );
      ( "字符串处理格式化",
        [
          test_case "错误模板格式化" `Quick Test_StringProcessingFormatter.test_format_error_template;
          test_case "位置信息格式化" `Quick Test_StringProcessingFormatter.test_format_position_info;
          test_case "Token信息格式化" `Quick Test_StringProcessingFormatter.test_format_token_info;
          test_case "报告段落格式化" `Quick Test_StringProcessingFormatter.test_format_report_section;
          test_case "消息模板格式化" `Quick Test_StringProcessingFormatter.test_format_message_template;
          test_case "扩展字符串处理" `Quick Test_StringProcessingFormatter.test_extended_string_processing;
        ] );
      ( "扩展格式化",
        [
          test_case "版本信息格式化" `Quick Test_ExtendedFormatting.test_format_version_info;
          test_case "构建信息格式化" `Quick Test_ExtendedFormatting.test_format_build_info;
          test_case "配置信息格式化" `Quick Test_ExtendedFormatting.test_format_config_info;
          test_case "依赖信息格式化" `Quick Test_ExtendedFormatting.test_format_dependency_info;
          test_case "环境信息格式化" `Quick Test_ExtendedFormatting.test_format_environment_info;
        ] );
    ]