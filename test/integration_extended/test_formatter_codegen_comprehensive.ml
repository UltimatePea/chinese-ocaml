(** 代码生成格式化器全面测试套件 测试覆盖formatter_codegen.ml模块的所有核心功能 *)

open Alcotest
open Yyocamlc_lib.Formatter_codegen

(** 测试辅助函数模块 *)
module TestHelpers = struct
  (** 验证字符串包含特定子串 *)
  let contains_substring haystack needle =
    let haystack_len = String.length haystack in
    let needle_len = String.length needle in
    let rec search i =
      if i + needle_len > haystack_len then false
      else if String.sub haystack i needle_len = needle then true
      else search (i + 1)
    in
    search 0

  (** 验证字符串以特定前缀开始 *)
  let starts_with str prefix =
    let str_len = String.length str in
    let prefix_len = String.length prefix in
    str_len >= prefix_len && String.sub str 0 prefix_len = prefix

  (** 验证字符串以特定后缀结束 *)
  let ends_with str suffix =
    let str_len = String.length str in
    let suffix_len = String.length suffix in
    str_len >= suffix_len && String.sub str (str_len - suffix_len) suffix_len = suffix

  (** 验证生成的代码不为空 *)
  let assert_not_empty code = String.length (String.trim code) > 0

  (** 验证生成的代码格式正确（基础检查） *)
  let assert_valid_c_syntax code =
    (* 基础语法检查：确保括号匹配 *)
    let count_char c str =
      let count = ref 0 in
      String.iter (fun ch -> if ch = c then incr count) str;
      !count
    in
    let open_parens = count_char '(' code in
    let close_parens = count_char ')' code in
    let open_braces = count_char '{' code in
    let close_braces = count_char '}' code in
    open_parens = close_parens && open_braces = close_braces

  (** 创建测试参数列表 *)
  let create_test_args () = [ "arg1"; "arg2"; "arg3" ]

  (** 创建测试字段列表 *)
  let create_test_fields () = [ ("int", "field1"); ("char*", "field2"); ("double", "field3") ]

  (** 创建测试语句列表 *)
  let create_test_statements () =
    [ "int x = 42;"; "char* str = \"hello\";"; "return x + strlen(str);" ]
end

(** CCodegen模块测试 *)

let test_ccodegen_function_calls () =
  (* 测试基础函数调用 *)
  let result = CCodegen.function_call "printf" [ "\"Hello\""; "world" ] in
  check bool "函数调用应包含函数名" true (TestHelpers.contains_substring result "printf");
  check bool "函数调用应包含参数" true (TestHelpers.contains_substring result "Hello");
  check bool "函数调用应包含括号" true (TestHelpers.contains_substring result "(");

  (* 测试二元函数调用 *)
  let binary_result = CCodegen.binary_function_call "add" "x" "y" in
  check bool "二元函数调用应包含两个参数" true
    (TestHelpers.contains_substring binary_result "x"
    && TestHelpers.contains_substring binary_result "y");

  (* 测试一元函数调用 *)
  let unary_result = CCodegen.unary_function_call "abs" "value" in
  check bool "一元函数调用应包含一个参数" true (TestHelpers.contains_substring unary_result "value")

let test_ccodegen_luoyan_calls () =
  (* 测试骆言函数调用 *)
  let luoyan_call_result = CCodegen.luoyan_call "func_code" 2 "args" in
  check bool "骆言调用应包含luoyan_call" true
    (TestHelpers.contains_substring luoyan_call_result "luoyan_call");
  check bool "骆言调用应包含参数数量" true (TestHelpers.contains_substring luoyan_call_result "2");

  (* 测试骆言变量绑定 *)
  let bind_result = CCodegen.luoyan_bind_var "x" "42" in
  check bool "骆言变量绑定应包含变量名" true (TestHelpers.contains_substring bind_result "x");
  check bool "骆言变量绑定应包含值" true (TestHelpers.contains_substring bind_result "42")

let test_ccodegen_luoyan_literals () =
  (* 测试骆言字符串 *)
  let str_result = CCodegen.luoyan_string "测试" in
  check bool "骆言字符串应包含luoyan_string" true
    (TestHelpers.contains_substring str_result "luoyan_string");
  check bool "骆言字符串应包含内容" true (TestHelpers.contains_substring str_result "测试");

  (* 测试骆言整数 *)
  let int_result = CCodegen.luoyan_int 42 in
  check bool "骆言整数应包含luoyan_int" true (TestHelpers.contains_substring int_result "luoyan_int");
  check bool "骆言整数应包含数值" true (TestHelpers.contains_substring int_result "42");

  (* 测试骆言浮点数 *)
  let float_result = CCodegen.luoyan_float 3.14 in
  check bool "骆言浮点数应包含luoyan_float" true
    (TestHelpers.contains_substring float_result "luoyan_float");

  (* 测试骆言布尔值 *)
  let bool_true_result = CCodegen.luoyan_bool true in
  let bool_false_result = CCodegen.luoyan_bool false in
  check bool "骆言布尔值true应包含true" true (TestHelpers.contains_substring bool_true_result "true");
  check bool "骆言布尔值false应包含false" true (TestHelpers.contains_substring bool_false_result "false");

  (* 测试骆言单元值 *)
  let unit_result = CCodegen.luoyan_unit () in
  check bool "骆言单元值应包含luoyan_unit" true (TestHelpers.contains_substring unit_result "luoyan_unit")

let test_ccodegen_luoyan_advanced () =
  (* 测试骆言let表达式 *)
  let let_result = CCodegen.luoyan_let "x" "42" "body_code" in
  check bool "骆言let应包含变量名" true (TestHelpers.contains_substring let_result "x");
  check bool "骆言let应包含值代码" true (TestHelpers.contains_substring let_result "42");

  (* 测试骆言函数创建 *)
  let func_create_result = CCodegen.luoyan_function_create "test_func" "param" in
  check bool "骆言函数创建应包含函数名" true (TestHelpers.contains_substring func_create_result "test_func");

  (* 测试骆言模式匹配 *)
  let pattern_match_result = CCodegen.luoyan_pattern_match "expr_var" in
  check bool "骆言模式匹配应包含表达式变量" true (TestHelpers.contains_substring pattern_match_result "expr_var")

let test_ccodegen_exception_handling () =
  (* 测试骆言异常捕获 *)
  let catch_result = CCodegen.luoyan_catch "branch_code" in
  check bool "骆言异常捕获应包含luoyan_catch" true
    (TestHelpers.contains_substring catch_result "luoyan_catch");

  (* 测试骆言try-catch *)
  let try_catch_result = CCodegen.luoyan_try_catch "try_code" "catch_code" "finally_code" in
  check bool "骆言try-catch应包含try代码" true (TestHelpers.contains_substring try_catch_result "try_code");

  (* 测试骆言抛出异常 *)
  let raise_result = CCodegen.luoyan_raise "exception_expr" in
  check bool "骆言抛出异常应包含luoyan_raise" true
    (TestHelpers.contains_substring raise_result "luoyan_raise")

let test_ccodegen_c_structures () =
  (* 测试C语句 *)
  let stmt_result = CCodegen.c_statement "expression" in
  check bool "C语句应以分号结尾" true (TestHelpers.ends_with stmt_result ";");

  (* 测试C语句序列 *)
  let seq_result = CCodegen.c_statement_sequence "stmt1" "stmt2" in
  check bool "C语句序列应包含两个语句" true
    (TestHelpers.contains_substring seq_result "stmt1"
    && TestHelpers.contains_substring seq_result "stmt2");

  (* 测试C语句块 *)
  let block_result = CCodegen.c_statement_block (TestHelpers.create_test_statements ()) in
  check bool "C语句块应包含所有语句" true (TestHelpers.contains_substring block_result "int x = 42;");

  (* 测试C变量声明 *)
  let var_decl_result = CCodegen.c_variable_declaration "int" "x" "42" in
  check bool "C变量声明应包含类型" true (TestHelpers.contains_substring var_decl_result "int");
  check bool "C变量声明应包含变量名" true (TestHelpers.contains_substring var_decl_result "x")

let test_ccodegen_control_flow () =
  (* 测试C if语句 *)
  let if_result = CCodegen.c_if_statement "condition" "then_block" in
  check bool "C if语句应包含条件" true (TestHelpers.contains_substring if_result "condition");
  check bool "C if语句应包含then块" true (TestHelpers.contains_substring if_result "then_block");

  (* 测试C if-else语句 *)
  let if_else_result = CCodegen.c_if_else_statement "condition" "then_block" "else_block" in
  check bool "C if-else语句应包含else" true (TestHelpers.contains_substring if_else_result "else");

  (* 测试C while循环 *)
  let while_result = CCodegen.c_while_loop "condition" "body" in
  check bool "C while循环应包含while关键字" true (TestHelpers.contains_substring while_result "while");

  (* 测试C for循环 *)
  let for_result = CCodegen.c_for_loop "init" "condition" "increment" "body" in
  check bool "C for循环应包含for关键字" true (TestHelpers.contains_substring for_result "for");
  check bool "C for循环应包含初始化" true (TestHelpers.contains_substring for_result "init")

let test_ccodegen_function_definitions () =
  (* 测试C函数声明 *)
  let func_decl_result = CCodegen.c_function_declaration "int" "add" [ "int a"; "int b" ] in
  check bool "C函数声明应包含返回类型" true (TestHelpers.contains_substring func_decl_result "int");
  check bool "C函数声明应包含函数名" true (TestHelpers.contains_substring func_decl_result "add");

  (* 测试C函数定义 *)
  let func_def_result =
    CCodegen.c_function_definition "int" "add" [ "int a"; "int b" ] "return a + b;"
  in
  check bool "C函数定义应包含函数体" true (TestHelpers.contains_substring func_def_result "return a + b;")

let test_ccodegen_struct_definitions () =
  (* 测试C结构体定义 *)
  let struct_result = CCodegen.c_struct_definition "Point" (TestHelpers.create_test_fields ()) in
  check bool "C结构体应包含typedef" true (TestHelpers.contains_substring struct_result "typedef");
  check bool "C结构体应包含结构体名" true (TestHelpers.contains_substring struct_result "Point");

  (* 测试C枚举定义 *)
  let enum_result = CCodegen.c_enum_definition "Color" [ "RED"; "GREEN"; "BLUE" ] in
  check bool "C枚举应包含enum关键字" true (TestHelpers.contains_substring enum_result "enum");
  check bool "C枚举应包含枚举值" true (TestHelpers.contains_substring enum_result "RED")

(** EnhancedCCodegen模块测试 *)

let test_enhanced_ccodegen_type_operations () =
  (* 测试类型转换 *)
  let cast_result = EnhancedCCodegen.type_cast "int" "value" in
  check bool "类型转换应包含目标类型" true (TestHelpers.contains_substring cast_result "int");
  check bool "类型转换应包含表达式" true (TestHelpers.contains_substring cast_result "value");

  (* 测试构造器匹配 *)
  let constructor_result = EnhancedCCodegen.constructor_match "expr" "Some" in
  check bool "构造器匹配应包含构造器名" true (TestHelpers.contains_substring constructor_result "Some");

  (* 测试字符串相等性检查 *)
  let str_eq_result = EnhancedCCodegen.string_equality_escaped "var" "test" in
  check bool "字符串相等性检查应包含luoyan_equals" true
    (TestHelpers.contains_substring str_eq_result "luoyan_equals")

let test_enhanced_ccodegen_advanced_calls () =
  (* 测试带类型转换的骆言调用 *)
  let cast_call_result = EnhancedCCodegen.luoyan_call_with_cast "func" "int" [ "arg1"; "arg2" ] in
  check bool "带转换的调用应包含类型转换" true (TestHelpers.contains_substring cast_call_result "int");

  (* 测试条件绑定 *)
  let cond_bind_result =
    EnhancedCCodegen.luoyan_conditional_binding "var" "condition" "true_expr" "false_expr"
  in
  check bool "条件绑定应包含变量名" true (TestHelpers.contains_substring cond_bind_result "var");
  check bool "条件绑定应包含三元操作符" true (TestHelpers.contains_substring cond_bind_result "?");

  (* 测试动态调用 *)
  let dynamic_call_result = EnhancedCCodegen.luoyan_dynamic_call "func_expr" "args_array" in
  check bool "动态调用应包含luoyan_dynamic_call" true
    (TestHelpers.contains_substring dynamic_call_result "luoyan_dynamic_call");

  (* 测试部分应用 *)
  let partial_app_result = EnhancedCCodegen.luoyan_partial_application "func_expr" "partial_args" in
  check bool "部分应用应包含luoyan_partial_application" true
    (TestHelpers.contains_substring partial_app_result "luoyan_partial_application")

let test_enhanced_ccodegen_memory_management () =
  (* 测试内存分配 *)
  let alloc_result = EnhancedCCodegen.luoyan_alloc 1024 in
  check bool "内存分配应包含luoyan_alloc" true (TestHelpers.contains_substring alloc_result "luoyan_alloc");
  check bool "内存分配应包含大小" true (TestHelpers.contains_substring alloc_result "1024");

  (* 测试内存释放 *)
  let free_result = EnhancedCCodegen.luoyan_free "ptr" in
  check bool "内存释放应包含luoyan_free" true (TestHelpers.contains_substring free_result "luoyan_free");

  (* 测试垃圾回收 *)
  let gc_result = EnhancedCCodegen.luoyan_gc_collect () in
  check bool "垃圾回收应包含luoyan_gc_collect" true
    (TestHelpers.contains_substring gc_result "luoyan_gc_collect")

let test_enhanced_ccodegen_data_structures () =
  (* 测试数组创建 *)
  let array_create_result = EnhancedCCodegen.luoyan_array_create 10 in
  check bool "数组创建应包含luoyan_array_create" true
    (TestHelpers.contains_substring array_create_result "luoyan_array_create");

  (* 测试数组获取 *)
  let array_get_result = EnhancedCCodegen.luoyan_array_get "array" 5 in
  check bool "数组获取应包含luoyan_array_get" true
    (TestHelpers.contains_substring array_get_result "luoyan_array_get");

  (* 测试数组设置 *)
  let array_set_result = EnhancedCCodegen.luoyan_array_set "array" 5 "value" in
  check bool "数组设置应包含luoyan_array_set" true
    (TestHelpers.contains_substring array_set_result "luoyan_array_set");

  (* 测试记录创建 *)
  let record_create_result = EnhancedCCodegen.luoyan_record_create 3 in
  check bool "记录创建应包含luoyan_record_create" true
    (TestHelpers.contains_substring record_create_result "luoyan_record_create");

  (* 测试记录获取 *)
  let record_get_result = EnhancedCCodegen.luoyan_record_get "record" "field" in
  check bool "记录获取应包含字段名" true (TestHelpers.contains_substring record_get_result "field");

  (* 测试记录设置 *)
  let record_set_result = EnhancedCCodegen.luoyan_record_set "record" "field" "value" in
  check bool "记录设置应包含字段名和值" true
    (TestHelpers.contains_substring record_set_result "field"
    && TestHelpers.contains_substring record_set_result "value")

let test_enhanced_ccodegen_type_checking () =
  (* 测试类型检查 *)
  let type_check_result = EnhancedCCodegen.luoyan_type_check "value" "int" in
  check bool "类型检查应包含luoyan_type_check" true
    (TestHelpers.contains_substring type_check_result "luoyan_type_check");

  (* 测试类型判断 *)
  let is_type_result = EnhancedCCodegen.luoyan_is_type "value" "string" in
  check bool "类型判断应包含luoyan_is_type" true
    (TestHelpers.contains_substring is_type_result "luoyan_is_type")

let test_enhanced_ccodegen_error_handling () =
  (* 测试错误抛出 *)
  let error_throw_result = EnhancedCCodegen.luoyan_error_throw 404 "Not found" in
  check bool "错误抛出应包含错误代码" true (TestHelpers.contains_substring error_throw_result "404");
  check bool "错误抛出应包含错误消息" true (TestHelpers.contains_substring error_throw_result "Not found");

  (* 测试错误传播 *)
  let error_propagate_result = EnhancedCCodegen.luoyan_error_propagate "error" in
  check bool "错误传播应包含luoyan_error_propagate" true
    (TestHelpers.contains_substring error_propagate_result "luoyan_error_propagate");

  (* 测试错误检查 *)
  let error_check_result = EnhancedCCodegen.luoyan_error_check "result" in
  check bool "错误检查应包含luoyan_error_check" true
    (TestHelpers.contains_substring error_check_result "luoyan_error_check")

let test_enhanced_ccodegen_debugging () =
  (* 测试调试跟踪 *)
  let debug_trace_result = EnhancedCCodegen.luoyan_debug_trace "func_name" "args" in
  check bool "调试跟踪应包含函数名" true (TestHelpers.contains_substring debug_trace_result "func_name");

  (* 测试性能分析开始 *)
  let profile_start_result = EnhancedCCodegen.luoyan_profile_start "label" in
  check bool "性能分析开始应包含luoyan_profile_start" true
    (TestHelpers.contains_substring profile_start_result "luoyan_profile_start");

  (* 测试性能分析结束 *)
  let profile_end_result = EnhancedCCodegen.luoyan_profile_end "label" in
  check bool "性能分析结束应包含luoyan_profile_end" true
    (TestHelpers.contains_substring profile_end_result "luoyan_profile_end")

(** CodeGenUtilities模块测试 *)

let test_codegen_utilities_comments () =
  (* 测试行注释 *)
  let line_comment_result = CodeGenUtilities.c_line_comment "这是注释" in
  check bool "行注释应以//开头" true (TestHelpers.starts_with line_comment_result "//");
  check bool "行注释应包含注释内容" true (TestHelpers.contains_substring line_comment_result "这是注释");

  (* 测试块注释 *)
  let block_comment_result = CodeGenUtilities.c_block_comment "块注释" in
  check bool "块注释应包含/*" true (TestHelpers.contains_substring block_comment_result "/*");
  check bool "块注释应包含*/" true (TestHelpers.contains_substring block_comment_result "*/");

  (* 测试文档注释 *)
  let doc_comment_result = CodeGenUtilities.c_doc_comment "文档注释" in
  check bool "文档注释应包含/**" true (TestHelpers.contains_substring doc_comment_result "/**")

let test_codegen_utilities_formatting () =
  (* 测试代码缩进 *)
  let indent_result = CodeGenUtilities.c_indent_block "line1\nline2" 1 in
  check bool "缩进结果应不为空" true (TestHelpers.assert_not_empty indent_result);
  check bool "缩进结果应包含空格" true (TestHelpers.contains_substring indent_result "    ");

  (* 测试参数列表格式化 *)
  let param_list_result = CodeGenUtilities.c_format_parameter_list [ "int x"; "char* y" ] in
  check bool "参数列表应包含参数" true (TestHelpers.contains_substring param_list_result "int x");

  (* 测试空参数列表 *)
  let empty_param_result = CodeGenUtilities.c_format_parameter_list [] in
  check string "空参数列表应返回void" "void" empty_param_result

let test_codegen_utilities_preprocessor () =
  (* 测试系统头文件包含 *)
  let system_include_result = CodeGenUtilities.c_include_system "stdio.h" in
  check bool "系统头文件包含应使用尖括号" true (TestHelpers.contains_substring system_include_result "<stdio.h>");

  (* 测试本地头文件包含 *)
  let local_include_result = CodeGenUtilities.c_include_local "myheader.h" in
  check bool "本地头文件包含应使用引号" true
    (TestHelpers.contains_substring local_include_result "\"myheader.h\"");

  (* 测试宏定义 *)
  let define_result = CodeGenUtilities.c_define "MAX_SIZE" "1024" in
  check bool "宏定义应包含#define" true (TestHelpers.contains_substring define_result "#define");
  check bool "宏定义应包含宏名" true (TestHelpers.contains_substring define_result "MAX_SIZE");

  (* 测试条件编译 *)
  let ifdef_result = CodeGenUtilities.c_ifdef "DEBUG" in
  check bool "ifdef应包含#ifdef" true (TestHelpers.contains_substring ifdef_result "#ifdef");

  let ifndef_result = CodeGenUtilities.c_ifndef "RELEASE" in
  check bool "ifndef应包含#ifndef" true (TestHelpers.contains_substring ifndef_result "#ifndef");

  let endif_result = CodeGenUtilities.c_endif () in
  check string "endif应返回#endif" "#endif" endif_result

let test_codegen_utilities_blocks () =
  (* 测试作用域块 *)
  let scope_block_result = CodeGenUtilities.c_scope_block (TestHelpers.create_test_statements ()) in
  check bool "作用域块应包含大括号" true
    (TestHelpers.contains_substring scope_block_result "{"
    && TestHelpers.contains_substring scope_block_result "}");

  (* 测试命名空间块 *)
  let namespace_result = CodeGenUtilities.c_namespace_block "MyNamespace" "content" in
  check bool "命名空间应包含namespace关键字" true
    (TestHelpers.contains_substring namespace_result "namespace");
  check bool "命名空间应包含名称" true (TestHelpers.contains_substring namespace_result "MyNamespace")

(** 集成测试 *)

let test_codegen_integration_complete_workflow () =
  (* 测试完整的C代码生成工作流程 *)

  (* 1. 创建函数声明 *)
  let func_decl = CCodegen.c_function_declaration "int" "main" [ "void" ] in
  check bool "函数声明应创建成功" true (TestHelpers.assert_not_empty func_decl);

  (* 2. 创建变量声明 *)
  let var_decl = CCodegen.c_variable_declaration "int" "result" "42" in
  check bool "变量声明应创建成功" true (TestHelpers.assert_not_empty var_decl);

  (* 3. 创建函数调用 *)
  let func_call = CCodegen.function_call "printf" [ "\"Result: %d\\n\""; "result" ] in
  check bool "函数调用应创建成功" true (TestHelpers.assert_not_empty func_call);

  (* 4. 组合成完整的函数体 *)
  let func_body = CCodegen.c_statement_block [ var_decl; func_call; "return 0;" ] in
  check bool "函数体应创建成功" true (TestHelpers.assert_not_empty func_body);

  (* 5. 创建完整的函数定义 *)
  let complete_func = CCodegen.c_function_definition "int" "main" [ "void" ] func_body in
  check bool "完整函数定义应创建成功" true (TestHelpers.assert_not_empty complete_func);
  check bool "完整函数定义应包含所有组件" true
    (TestHelpers.contains_substring complete_func "main"
    && TestHelpers.contains_substring complete_func "result"
    && TestHelpers.contains_substring complete_func "printf")

let test_codegen_integration_luoyan_program () =
  (* 测试完整的骆言程序生成 *)

  (* 1. 创建骆言变量绑定 *)
  let var_binding = CCodegen.luoyan_bind_var "x" (CCodegen.luoyan_int 42) in
  check bool "骆言变量绑定应创建成功" true (TestHelpers.assert_not_empty var_binding);

  (* 2. 创建骆言函数 *)
  let func_call = CCodegen.luoyan_call "add" 2 (CCodegen.luoyan_int 10) in
  check bool "骆言函数调用应创建成功" true (TestHelpers.assert_not_empty func_call);

  (* 3. 创建骆言let表达式 *)
  let let_expr = CCodegen.luoyan_let "result" func_call var_binding in
  check bool "骆言let表达式应创建成功" true (TestHelpers.assert_not_empty let_expr);

  (* 4. 验证组合结果 *)
  check bool "骆言程序应包含所有组件" true
    (TestHelpers.contains_substring let_expr "luoyan_let"
    && TestHelpers.contains_substring let_expr "result"
    && TestHelpers.contains_substring let_expr "add")

let test_codegen_integration_error_handling_workflow () =
  (* 测试错误处理工作流程 *)

  (* 1. 创建try表达式 *)
  let try_expr = CCodegen.luoyan_try_catch "risky_operation()" "handle_error()" "cleanup()" in
  check bool "try表达式应创建成功" true (TestHelpers.assert_not_empty try_expr);

  (* 2. 创建错误检查 *)
  let error_check = EnhancedCCodegen.luoyan_error_check "result" in
  check bool "错误检查应创建成功" true (TestHelpers.assert_not_empty error_check);

  (* 3. 创建错误抛出 *)
  let error_throw = EnhancedCCodegen.luoyan_error_throw 500 "Internal error" in
  check bool "错误抛出应创建成功" true (TestHelpers.assert_not_empty error_throw);

  (* 4. 验证错误处理组合 *)
  check bool "错误处理应包含所有组件" true
    (TestHelpers.contains_substring try_expr "luoyan_try_catch"
    && TestHelpers.contains_substring error_check "luoyan_error_check"
    && TestHelpers.contains_substring error_throw "luoyan_error_throw")

(** 性能和压力测试 *)

let test_codegen_performance_large_generation () =
  (* 测试大量代码生成的性能 *)
  let start_time = Sys.time () in

  (* 生成大量函数调用 *)
  let large_call_list =
    let rec generate_calls n acc =
      if n <= 0 then acc
      else
        let call = CCodegen.function_call ("func" ^ string_of_int n) [ "arg1"; "arg2" ] in
        generate_calls (n - 1) (call :: acc)
    in
    generate_calls 100 []
  in

  (* 组合成大型代码块 *)
  let large_block = CCodegen.c_statement_block large_call_list in

  let end_time = Sys.time () in

  check bool "大量代码生成应成功" true (TestHelpers.assert_not_empty large_block);
  check bool "大量代码生成应在合理时间内完成" true (end_time -. start_time < 1.0);
  check bool "生成的代码应包含所有函数调用" true
    (TestHelpers.contains_substring large_block "func1"
    && TestHelpers.contains_substring large_block "func50"
    && TestHelpers.contains_substring large_block "func100")

(** 测试套件定义 *)

let ccodegen_tests =
  [
    test_case "函数调用生成测试" `Quick test_ccodegen_function_calls;
    test_case "骆言调用生成测试" `Quick test_ccodegen_luoyan_calls;
    test_case "骆言字面量生成测试" `Quick test_ccodegen_luoyan_literals;
    test_case "骆言高级功能生成测试" `Quick test_ccodegen_luoyan_advanced;
    test_case "异常处理生成测试" `Quick test_ccodegen_exception_handling;
    test_case "C结构生成测试" `Quick test_ccodegen_c_structures;
    test_case "控制流生成测试" `Quick test_ccodegen_control_flow;
    test_case "函数定义生成测试" `Quick test_ccodegen_function_definitions;
    test_case "结构体定义生成测试" `Quick test_ccodegen_struct_definitions;
  ]

let enhanced_ccodegen_tests =
  [
    test_case "类型操作测试" `Quick test_enhanced_ccodegen_type_operations;
    test_case "高级调用测试" `Quick test_enhanced_ccodegen_advanced_calls;
    test_case "内存管理测试" `Quick test_enhanced_ccodegen_memory_management;
    test_case "数据结构测试" `Quick test_enhanced_ccodegen_data_structures;
    test_case "类型检查测试" `Quick test_enhanced_ccodegen_type_checking;
    test_case "错误处理测试" `Quick test_enhanced_ccodegen_error_handling;
    test_case "调试功能测试" `Quick test_enhanced_ccodegen_debugging;
  ]

let utilities_tests =
  [
    test_case "注释生成测试" `Quick test_codegen_utilities_comments;
    test_case "格式化测试" `Quick test_codegen_utilities_formatting;
    test_case "预处理器指令测试" `Quick test_codegen_utilities_preprocessor;
    test_case "代码块测试" `Quick test_codegen_utilities_blocks;
  ]

let integration_tests =
  [
    test_case "完整工作流程集成测试" `Quick test_codegen_integration_complete_workflow;
    test_case "骆言程序生成集成测试" `Quick test_codegen_integration_luoyan_program;
    test_case "错误处理工作流程集成测试" `Quick test_codegen_integration_error_handling_workflow;
  ]

let performance_tests = [ test_case "大量代码生成性能测试" `Slow test_codegen_performance_large_generation ]

(** 主测试运行器 *)
let () =
  run "Formatter_codegen代码生成格式化器综合测试套件"
    [
      ("CCodegen模块测试", ccodegen_tests);
      ("EnhancedCCodegen模块测试", enhanced_ccodegen_tests);
      ("CodeGenUtilities模块测试", utilities_tests);
      ("集成测试", integration_tests);
      ("性能测试", performance_tests);
    ]
