(** 测试第二阶段Unified_formatter扩展功能 *)

open Utils.Base_formatter

let test_new_patterns () =
  (* 测试新增的Token格式化模式 *)
  let int_token_result = int_token_pattern 42 in
  let float_token_result = float_token_pattern 3.14 in
  let string_token_result = string_token_pattern "hello" in
  let id_token_result = identifier_token_pattern "variable" in
  let quoted_id_token_result = quoted_identifier_token_pattern "quoted_var" in

  (* 测试错误消息格式化模式 *)
  let undefined_var_result = undefined_variable_pattern "missing_var" in
  let already_defined_result = variable_already_defined_pattern "existing_var" in
  let module_error_result = module_member_error_pattern "MyModule" "missing_member" in
  let file_error_result = file_not_found_pattern "missing_file.ly" in

  (* 测试位置信息格式化模式 *)
  let simple_pos_result = simple_line_col_pattern 10 20 in
  let paren_pos_result = parenthesized_line_col_pattern 5 15 in
  let range_pos_result = range_position_pattern 1 5 3 10 in
  let error_marker_result = error_position_marker_pattern 8 12 in

  (* 测试C代码生成模式 *)
  let c_cast_result = c_type_cast_pattern "int" "expr" in
  let c_constructor_result = c_constructor_match_pattern "expr_var" "Constructor" in
  let c_string_eq_result = c_string_equality_escaped_pattern "var" "escaped_string" in

  (* 测试诗词分析模式 *)
  let poetry_report_result = poetry_evaluation_report_pattern "测试诗" "优秀" 85.5 in
  let rhyme_result = rhyme_group_pattern "东韵" in
  let tone_error_result = tone_error_pattern 3 "字" "平声" in
  let verse_analysis_result = verse_analysis_pattern 1 "春眠不觉晓" "晓" "效韵" in

  (* 测试编译和日志模式 *)
  let compiling_result = compiling_file_pattern "test.ly" in
  let stats_result = compilation_complete_stats_pattern 5 2.5 in
  let op_start_result = operation_start_pattern "编译" in
  let op_complete_result = operation_complete_pattern "编译" 1.2 in

  (* 打印结果进行验证 *)
  Printf.printf "=== 第二阶段Unified_formatter功能测试 ===\n\n";

  Printf.printf "Token格式化测试:\n";
  Printf.printf "  IntToken: %s\n" int_token_result;
  Printf.printf "  FloatToken: %s\n" float_token_result;
  Printf.printf "  StringToken: %s\n" string_token_result;
  Printf.printf "  IdentifierToken: %s\n" id_token_result;
  Printf.printf "  QuotedIdentifierToken: %s\n" quoted_id_token_result;

  Printf.printf "\n错误消息格式化测试:\n";
  Printf.printf "  未定义变量: %s\n" undefined_var_result;
  Printf.printf "  变量已定义: %s\n" already_defined_result;
  Printf.printf "  模块成员错误: %s\n" module_error_result;
  Printf.printf "  文件未找到: %s\n" file_error_result;

  Printf.printf "\n位置信息格式化测试:\n";
  Printf.printf "  简单行列: %s\n" simple_pos_result;
  Printf.printf "  括号行列: %s\n" paren_pos_result;
  Printf.printf "  范围位置: %s\n" range_pos_result;
  Printf.printf "  错误标记: %s\n" error_marker_result;

  Printf.printf "\nC代码生成格式化测试:\n";
  Printf.printf "  类型转换: %s\n" c_cast_result;
  Printf.printf "  构造器匹配: %s\n" c_constructor_result;
  Printf.printf "  字符串相等: %s\n" c_string_eq_result;

  Printf.printf "\n诗词分析格式化测试:\n";
  Printf.printf "  诗词报告: %s\n" poetry_report_result;
  Printf.printf "  韵组: %s\n" rhyme_result;
  Printf.printf "  字调错误: %s\n" tone_error_result;
  Printf.printf "  诗句分析: %s\n" verse_analysis_result;

  Printf.printf "\n编译日志格式化测试:\n";
  Printf.printf "  编译文件: %s\n" compiling_result;
  Printf.printf "  编译统计: %s\n" stats_result;
  Printf.printf "  操作开始: %s\n" op_start_result;
  Printf.printf "  操作完成: %s\n" op_complete_result;

  Printf.printf "\n=== 测试完成 ===\n"

let () = test_new_patterns ()
