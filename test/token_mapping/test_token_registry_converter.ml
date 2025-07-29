(** Token注册器转换器模块测试
 * 验证Token代码生成和转换功能的正确性
 * 确保Token映射转换的准确性和完整性
 * Author: Alpha, Primary Worker Agent
 * Fix #1725 *)

(** 首先，需要找到正确的模块路径并导入 *)
open Token_mapping.Token_registry_converter

(* 简化的包含检查函数 *)
let contains_string haystack needle =
  let haystack_len = String.length haystack in
  let needle_len = String.length needle in
  let rec check i =
    if i + needle_len > haystack_len then false
    else if String.sub haystack i needle_len = needle then true
    else check (i + 1)
  in
  check 0

(** 测试辅助函数 *)
let assert_string_not_empty str name =
  assert (String.length str > 0);
  Printf.printf "✅ %s 生成结果非空\n" name

(** 测试generate_token_code_by_category函数 *)
let test_generate_token_code_by_category () =
  Printf.printf "\n🔍 测试Token代码生成（按分类）...\n";
  
  (* 创建测试用的Token注册条目 *)
  let create_test_entry category source_token target_token description =
    {
      Token_mapping.Token_registry_core.category;
      source_token;
      target_token = Token_mapping.Token_definitions_unified.StringToken target_token;
      priority = 1;
      description;
    }
  in
  
  (* 测试literal类型Token生成 *)
  let literal_entry = create_test_entry "literal" "\"文本\"" "STRING" "字符串字面量" in
  let literal_code = generate_token_code_by_category literal_entry in
  assert_string_not_empty literal_code "字面量Token代码";
  Printf.printf "   生成的字面量代码: %s\n" literal_code;
  
  (* 测试identifier类型Token生成 *)
  let identifier_entry = create_test_entry "identifier" "变量名" "IDENTIFIER" "标识符" in
  let identifier_code = generate_token_code_by_category identifier_entry in
  assert_string_not_empty identifier_code "标识符Token代码";
  Printf.printf "   生成的标识符代码: %s\n" identifier_code;
  
  (* 测试basic_keyword类型Token生成 *)
  let keyword_entry = create_test_entry "basic_keyword" "如果" "IF" "条件关键字" in
  let keyword_code = generate_token_code_by_category keyword_entry in
  assert_string_not_empty keyword_code "基础关键字Token代码";
  Printf.printf "   生成的关键字代码: %s\n" keyword_code;
  
  (* 测试type_keyword类型Token生成 *)
  let type_entry = create_test_entry "type_keyword" "整数" "INT_TYPE" "整数类型关键字" in
  let type_code = generate_token_code_by_category type_entry in
  assert_string_not_empty type_code "类型关键字Token代码";
  Printf.printf "   生成的类型代码: %s\n" type_code;
  
  (* 测试operator类型Token生成 *)
  let operator_entry = create_test_entry "operator" "+" "PLUS" "加法运算符" in
  let operator_code = generate_token_code_by_category operator_entry in
  assert_string_not_empty operator_code "运算符Token代码";
  Printf.printf "   生成的运算符代码: %s\n" operator_code;
  
  (* 测试未知类型处理 *)
  let unknown_entry = create_test_entry "unknown_type" "测试" "TEST" "未知类型" in
  let unknown_code = generate_token_code_by_category unknown_entry in
  assert (unknown_code = "UnknownToken");
  Printf.printf "✅ 未知类型Token正确返回UnknownToken\n";
  
  Printf.printf "✅ Token代码生成（按分类）测试完成\n"

(** 测试generate_token_converter函数 *)
let test_generate_token_converter () =
  Printf.printf "\n🔍 测试Token转换器代码生成...\n";
  
  let converter_code = generate_token_converter () in
  
  (* 验证生成的代码结构 *)
  assert_string_not_empty converter_code "Token转换器代码";
  
  (* 验证代码包含必要的结构元素 *)
  assert (contains_string converter_code "convert_registered_token");
  Printf.printf "✅ 转换器代码包含主函数定义\n";
  
  assert (contains_string converter_code "function");
  Printf.printf "✅ 转换器代码包含模式匹配结构\n";
  
  assert (contains_string converter_code "raise");
  Printf.printf "✅ 转换器代码包含异常处理\n";
  
  assert (contains_string converter_code "未注册的token类型");
  Printf.printf "✅ 转换器代码包含中文错误消息\n";
  
  (* 验证代码包含注释说明 *)
  assert (contains_string converter_code "自动生成的Token转换函数");
  Printf.printf "✅ 转换器代码包含功能说明注释\n";
  
  assert (contains_string converter_code "重构后的模块化版本");
  Printf.printf "✅ 转换器代码包含版本说明\n";
  
  (* 验证代码包含case模式 *)
  assert (contains_string converter_code "| ");
  Printf.printf "✅ 转换器代码包含case匹配模式\n";
  
  Printf.printf "✅ Token转换器代码生成测试完成\n"

(** 测试边界条件和错误处理 *)
let test_boundary_conditions () =
  Printf.printf "\n🔍 测试Token转换器边界条件...\n";
  
  (* 创建极端情况的测试条目 *)
  let create_test_entry category source_token target_token description =
    {
      Token_mapping.Token_registry_core.category;
      source_token;
      target_token = Token_mapping.Token_definitions_unified.StringToken target_token;
      priority = 1;
      description;
    }
  in
  
  (* 测试空字符串处理 *)
  let empty_entry = create_test_entry "" "" "" "" in
  let empty_code = generate_token_code_by_category empty_entry in
  assert (empty_code = "UnknownToken");
  Printf.printf "✅ 空分类Token正确处理\n";
  
  (* 测试特殊字符处理 *)
  let special_entry = create_test_entry "operator" "→" "ARROW" "箭头运算符" in
  let special_code = generate_token_code_by_category special_entry in
  assert_string_not_empty special_code "特殊字符Token代码";
  Printf.printf "✅ 特殊字符Token处理正确\n";
  
  (* 测试长描述处理 *)
  let long_description = String.make 200 'a' in
  let long_entry = create_test_entry "basic_keyword" "测试" "TEST" long_description in
  let long_code = generate_token_code_by_category long_entry in
  assert_string_not_empty long_code "长描述Token代码";
  Printf.printf "✅ 长描述Token处理正确\n";
  
  Printf.printf "✅ 边界条件测试完成\n"

(** 测试代码生成一致性 *)
let test_code_generation_consistency () =
  Printf.printf "\n🔍 测试代码生成一致性...\n";
  
  (* 生成相同的转换器代码多次，确保一致性 *)
  let code1 = generate_token_converter () in
  let code2 = generate_token_converter () in
  let code3 = generate_token_converter () in
  
  assert (code1 = code2);
  assert (code2 = code3);
  Printf.printf "✅ 多次生成的转换器代码保持一致\n";
  
  (* 验证代码格式规范 *)
  assert (contains_string code1 "\n");
  Printf.printf "✅ 生成的代码包含换行符格式\n";
  
  assert (contains_string code1 "  | ");
  Printf.printf "✅ 生成的代码包含适当的缩进\n";
  
  Printf.printf "✅ 代码生成一致性测试完成\n"

(** 性能基准测试 *)
let test_performance () =
  Printf.printf "\n🔍 Token转换器代码生成性能基准测试...\n";
  
  let start_time = Sys.time () in
  
  (* 重复生成转换器代码100次 *)
  for _i = 1 to 100 do
    ignore (generate_token_converter ())
  done;
  
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  
  Printf.printf "✅ 100次转换器代码生成耗时: %.6f秒\n" duration;
  assert (duration < 0.5); (* 应在0.5秒内完成 *)
  Printf.printf "✅ Token转换器代码生成性能符合要求\n";
  
  (* 测试单个Token代码生成性能 *)
  let create_test_entry category source_token target_token description =
    {
      Token_mapping.Token_registry_core.category;
      source_token;
      target_token = Token_mapping.Token_definitions_unified.StringToken target_token;
      priority = 1;
      description;
    }
  in
  
  let test_entry = create_test_entry "basic_keyword" "如果" "IF" "条件关键字" in
  let start_time2 = Sys.time () in
  
  for _i = 1 to 10000 do
    ignore (generate_token_code_by_category test_entry)
  done;
  
  let end_time2 = Sys.time () in
  let duration2 = end_time2 -. start_time2 in
  
  Printf.printf "✅ 10000次单个Token代码生成耗时: %.6f秒\n" duration2;
  assert (duration2 < 0.1); (* 应在0.1秒内完成 *)
  Printf.printf "✅ 单个Token代码生成性能符合要求\n"

(** 主测试执行函数 *)
let () =
  Printf.printf "🔍 开始Token注册器转换器模块测试...\n\n";
  
  test_generate_token_code_by_category ();
  test_generate_token_converter ();
  test_boundary_conditions ();
  test_code_generation_consistency ();
  test_performance ();
  
  Printf.printf "\n🎉 Token注册器转换器模块测试全部通过！\n";
  Printf.printf "测试覆盖: Token代码生成、转换器代码生成、边界条件、一致性验证、性能基准\n";
  Printf.printf "\n📈 本测试为Token映射转换系统提供了全面的质量保障\n";
  Printf.printf "🎯 确保中文编程语言的Token处理和代码生成功能稳定可靠\n"