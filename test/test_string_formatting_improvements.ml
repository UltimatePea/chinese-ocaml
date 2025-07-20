(* 字符串格式化改进模块的单元测试 *)

open Yyocamlc_lib
open String_processing_utils

(* 测试CCodegenFormatting模块的新增函数 *)
let test_c_codegen_formatting () =
  (* 测试环境绑定格式化 *)
  let env_bind_result = CCodegenFormatting.env_bind "x" "luoyan_int(42L)" in
  assert (env_bind_result = "luoyan_env_bind(env, \"x\", luoyan_int(42L));");
  
  let env_lookup_result = CCodegenFormatting.env_lookup "y" in
  assert (env_lookup_result = "luoyan_env_lookup(env, \"y\")");
  
  (* 测试运行时类型包装 *)
  let int_result = CCodegenFormatting.luoyan_int 42 in
  assert (int_result = "luoyan_int(42L)");
  
  let float_result = CCodegenFormatting.luoyan_float 3.14 in
  assert (float_result = "luoyan_float(3.14)");
  
  let string_result = CCodegenFormatting.luoyan_string "hello" in
  assert (string_result = "luoyan_string(\"hello\")");
  
  let bool_true_result = CCodegenFormatting.luoyan_bool true in
  assert (bool_true_result = "luoyan_bool(true)");
  
  let bool_false_result = CCodegenFormatting.luoyan_bool false in
  assert (bool_false_result = "luoyan_bool(false)");
  
  let unit_result = CCodegenFormatting.luoyan_unit () in
  assert (unit_result = "luoyan_unit()");
  
  (* 测试包含文件格式化 *)
  let include_result = CCodegenFormatting.include_header "stdio.h" in
  assert (include_result = "#include <stdio.h>");
  
  let include_local_result = CCodegenFormatting.include_local_header "myheader.h" in
  assert (include_local_result = "#include \"myheader.h\"");
  
  (* 测试递归函数绑定 *)
  let recursive_result = CCodegenFormatting.recursive_binding "fact" "lambda_expr" in
  assert (recursive_result = "luoyan_env_bind(env, \"fact\", luoyan_unit()); luoyan_env_bind(env, \"fact\", lambda_expr);");
  
  (* 测试C语言控制结构 *)
  let if_with_else = CCodegenFormatting.if_statement "x > 0" "return 1;" (Some "return 0;") in
  assert (if_with_else = "if (x > 0) { return 1; } else { return 0; }");
  
  let if_without_else = CCodegenFormatting.if_statement "x > 0" "print(x);" None in
  assert (if_without_else = "if (x > 0) { print(x); }");
  
  (* 测试C语言表达式格式化 *)
  let assign_result = CCodegenFormatting.assignment "result" "x + y" in
  assert (assign_result = "result = x + y;");
  
  let return_result = CCodegenFormatting.return_statement "result" in
  assert (return_result = "return result;");
  
  let func_decl_result = CCodegenFormatting.function_declaration "int" "add" ["int a"; "int b"] in
  assert (func_decl_result = "int add(int a, int b)");
  
  print_endline "✅ CCodegenFormatting模块测试通过"

(* 测试ErrorMessageTemplates模块的新增函数 *)
let test_error_message_templates () =
  (* 测试编译器错误模板 *)
  let unsupported_result = ErrorMessageTemplates.unsupported_feature "尾递归优化" in
  assert (unsupported_result = "不支持的功能: 尾递归优化");
  
  let unexpected_result = ErrorMessageTemplates.unexpected_state "PARSED" "类型检查阶段" in
  assert (unexpected_result = "意外的状态: PARSED (上下文: 类型检查阶段)");
  
  let invalid_char_result = ErrorMessageTemplates.invalid_character '&' in
  assert (invalid_char_result = "无效字符: &");
  
  let syntax_result = ErrorMessageTemplates.syntax_error "缺少分号" "第10行" in
  assert (syntax_result = "语法错误 第10行: 缺少分号");
  
  let semantic_result = ErrorMessageTemplates.semantic_error "类型不匹配" "函数add" in
  assert (semantic_result = "语义错误在 函数add: 类型不匹配");
  
  (* 测试诗词解析错误模板 *)
  let char_count_result = ErrorMessageTemplates.poetry_char_count_mismatch 7 5 in
  assert (char_count_result = "字符数不匹配：期望7字，实际5字");
  
  let verse_count_result = ErrorMessageTemplates.poetry_verse_count_warning 3 in
  assert (verse_count_result = "绝句包含3句，通常为4句");
  
  let rhyme_result = ErrorMessageTemplates.poetry_rhyme_mismatch 2 "东韵" "江韵" in
  assert (rhyme_result = "第2句韵脚不匹配：期望东韵，实际江韵");
  
  let tone_result = ErrorMessageTemplates.poetry_tone_pattern_error 1 "平仄平仄平仄仄" "仄平仄平平仄仄" in
  assert (tone_result = "第1句平仄不符：期望平仄平仄平仄仄，实际仄平仄平平仄仄");
  
  (* 测试数据处理错误模板 *)
  let data_load_result = ErrorMessageTemplates.data_loading_error "韵律" "rhyme_data.json" "文件不存在" in
  assert (data_load_result = "加载韵律数据失败 (rhyme_data.json): 文件不存在");
  
  let data_valid_result = ErrorMessageTemplates.data_validation_error "韵脚" "ong" "不在允许列表中" in
  assert (data_valid_result = "数据验证失败 - 韵脚: \"ong\" (不在允许列表中)");
  
  let data_format_result = ErrorMessageTemplates.data_format_error "JSON" "XML" in
  assert (data_format_result = "数据格式错误：期望JSON格式，实际XML格式");
  
  print_endline "✅ ErrorMessageTemplates模块测试通过"

(* 综合测试：演示实际使用场景 *)
let test_integration_example () =
  (* 模拟C代码生成场景 *)
  let var_name = "my_var" in
  let expr_code = CCodegenFormatting.luoyan_int 100 in
  let binding_code = CCodegenFormatting.env_bind var_name expr_code in
  let lookup_code = CCodegenFormatting.env_lookup var_name in
  
  (* 模拟错误处理场景 *)
  let error_msg = ErrorMessageTemplates.type_mismatch_error "整数" "字符串" in
  let syntax_error_msg = ErrorMessageTemplates.syntax_error "缺少右括号" "第15行第20列" in
  
  (* 模拟诗词处理场景 *)
  let poetry_error = ErrorMessageTemplates.poetry_char_count_mismatch 5 7 in
  
  Printf.printf "=== 集成测试示例 ===\n";
  Printf.printf "C代码绑定: %s\n" binding_code;
  Printf.printf "C代码查找: %s\n" lookup_code;
  Printf.printf "类型错误: %s\n" error_msg;
  Printf.printf "语法错误: %s\n" syntax_error_msg;
  Printf.printf "诗词错误: %s\n" poetry_error;
  
  print_endline "✅ 集成测试通过"

(* 主测试函数 *)
let () =
  print_endline "开始测试字符串格式化改进模块...";
  test_c_codegen_formatting ();
  test_error_message_templates ();
  test_integration_example ();
  print_endline "🎉 所有测试通过！字符串格式化改进模块工作正常。"