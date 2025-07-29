(** 骆言编译器C代码生成格式化模块全面测试 - Stage 2.1: Core formatter tests
    
    本测试文件针对formatter_codegen.ml提供全面的测试覆盖率，特别关注：
    - CCodegen模块的完整测试
    - EnhancedCCodegen模块的测试
    - CodeGenUtilities模块的测试
    
    Author: Alpha, 主工作代理
    Fix #1692 - 测试覆盖率提升计划第二阶段
    @since 2025-07-29 *)

open Alcotest
open Yyocamlc_lib.Formatter_codegen

(** 帮助函数：检查字符串是否包含子字符串 *)
let contains_substring s sub =
  try
    let _ = Str.search_forward (Str.regexp_string sub) s 0 in
    true
  with Not_found -> false

(** 帮助函数：检查字符串是否是有效的C代码格式 *)
let is_valid_c_format result = String.length result > 0 && not (String.contains result '\000')

(** 测试CCodegen模块 *)
module Test_CCodegen = struct
  (** 测试基础函数调用格式化 *)
  let test_function_calls () =
    let result = CCodegen.function_call "printf" ["\"Hello\""; "world"] in
    check bool "函数调用包含函数名" true (contains_substring result "printf");
    check bool "函数调用包含参数" true (contains_substring result "Hello");
    
    let binary_result = CCodegen.binary_function_call "add" "x" "y" in
    check bool "二元函数调用包含函数名" true (contains_substring binary_result "add");
    check bool "二元函数调用包含左操作数" true (contains_substring binary_result "x");
    check bool "二元函数调用包含右操作数" true (contains_substring binary_result "y");
    
    let unary_result = CCodegen.unary_function_call "neg" "value" in
    check bool "一元函数调用包含函数名" true (contains_substring unary_result "neg");
    check bool "一元函数调用包含操作数" true (contains_substring unary_result "value")

  (** 测试骆言特定格式 *)
  let test_luoyan_formats () =
    let call_result = CCodegen.luoyan_call "func_impl" 2 "args" in
    check bool "骆言调用包含函数代码" true (contains_substring call_result "func_impl");
    check bool "骆言调用包含参数数量" true (contains_substring call_result "2");
    check bool "骆言调用包含参数代码" true (contains_substring call_result "args");
    
    let bind_result = CCodegen.luoyan_bind_var "counter" "luoyan_int(42)" in
    check bool "变量绑定包含变量名" true (contains_substring bind_result "counter");
    check bool "变量绑定包含值" true (contains_substring bind_result "luoyan_int(42)");
    
    let string_result = CCodegen.luoyan_string "Hello World" in
    check bool "字符串值包含内容" true (contains_substring string_result "Hello World");
    
    let int_result = CCodegen.luoyan_int 42 in
    check bool "整数值包含数字" true (contains_substring int_result "42");
    
    let float_result = CCodegen.luoyan_float 3.14 in
    check bool "浮点数值包含数字" true (contains_substring float_result "3.14");
    
    let bool_true = CCodegen.luoyan_bool true in
    check bool "布尔真值格式化" true (contains_substring bool_true "true");
    
    let bool_false = CCodegen.luoyan_bool false in
    check bool "布尔假值格式化" true (contains_substring bool_false "false");
    
    let unit_result = CCodegen.luoyan_unit () in
    check bool "Unit值格式化有效" true (is_valid_c_format unit_result)

  (** 测试复杂骆言格式 *)
  let test_complex_luoyan_formats () =
    let equals_result = CCodegen.luoyan_equals "expr_var" "luoyan_int(10)" in
    check bool "相等比较包含变量" true (contains_substring equals_result "expr_var");
    check bool "相等比较包含值" true (contains_substring equals_result "luoyan_int(10)");
    
    let let_result = CCodegen.luoyan_let "x" "luoyan_int(5)" "body_code" in
    check bool "Let绑定包含变量名" true (contains_substring let_result "x");
    check bool "Let绑定包含值代码" true (contains_substring let_result "luoyan_int(5)");
    check bool "Let绑定包含主体代码" true (contains_substring let_result "body_code");
    
    let func_create = CCodegen.luoyan_function_create "test_func" "param1" in
    check bool "函数创建包含函数名" true (contains_substring func_create "test_func");
    check bool "函数创建包含第一参数" true (contains_substring func_create "param1");
    
    let pattern_match = CCodegen.luoyan_pattern_match "expr_var" in
    check bool "模式匹配包含表达式变量" true (contains_substring pattern_match "expr_var");
    
    let var_expr = CCodegen.luoyan_var_expr "var" "expr_code" in
    check bool "变量表达式包含变量" true (contains_substring var_expr "var");
    check bool "变量表达式包含表达式代码" true (contains_substring var_expr "expr_code")

  (** 测试环境绑定和字符串处理 *)
  let test_environment_and_strings () =
    let env_bind = CCodegen.luoyan_env_bind "variable" "value_expr" in
    check bool "环境绑定包含变量" true (contains_substring env_bind "variable");
    check bool "环境绑定包含值表达式" true (contains_substring env_bind "value_expr");
    
    let func_with_args = CCodegen.luoyan_function_create_with_args "func_code" "function_name" in
    check bool "带参数函数创建包含函数代码" true (contains_substring func_with_args "func_code");
    check bool "带参数函数创建包含函数名" true (contains_substring func_with_args "function_name");
    
    let string_equality = CCodegen.luoyan_string_equality_check "expr_var" "test_string" in
    check bool "字符串相等检查包含变量" true (contains_substring string_equality "expr_var");
    check bool "字符串相等检查包含字符串" true (contains_substring string_equality "test_string")

  (** 测试异常处理格式化 *)
  let test_exception_handling () =
    let catch_result = CCodegen.luoyan_catch "catch_branch" in
    check bool "Catch包含分支代码" true (contains_substring catch_result "catch_branch");
    
    let try_catch = CCodegen.luoyan_try_catch "try_code" "catch_code" "finally_code" in
    check bool "Try-catch-finally包含try代码" true (contains_substring try_catch "try_code");
    check bool "Try-catch-finally包含catch代码" true (contains_substring try_catch "catch_code");
    check bool "Try-catch-finally包含finally代码" true (contains_substring try_catch "finally_code");
    
    let raise_result = CCodegen.luoyan_raise "exception_expr" in
    check bool "Raise包含异常表达式" true (contains_substring raise_result "exception_expr")

  (** 测试C语句和控制结构 *)
  let test_c_statements_and_control () =
    let statement = CCodegen.c_statement "printf(\"hello\")" in
    check bool "C语句以分号结尾" true (String.get statement (String.length statement - 1) = ';');
    
    let sequence = CCodegen.c_statement_sequence "stmt1" "stmt2" in
    check bool "语句序列包含第一条语句" true (contains_substring sequence "stmt1");
    check bool "语句序列包含第二条语句" true (contains_substring sequence "stmt2");
    
    let block = CCodegen.c_statement_block ["stmt1"; "stmt2"; "stmt3"] in
    check bool "语句块包含所有语句" true (contains_substring block "stmt1");
    
    let template = CCodegen.c_template_with_includes "#include <stdio.h>" "int main() { return 0; }" "// end" in
    check bool "C模板包含头文件" true (contains_substring template "#include <stdio.h>");
    check bool "C模板包含主体" true (contains_substring template "int main")

  (** 测试变量声明和控制流 *)
  let test_declarations_and_control_flow () =
    let var_decl = CCodegen.c_variable_declaration "int" "counter" "0" in
    check bool "变量声明包含类型" true (contains_substring var_decl "int");
    check bool "变量声明包含变量名" true (contains_substring var_decl "counter");
    check bool "变量声明包含初始值" true (contains_substring var_decl "0");
    
    let const_decl = CCodegen.c_const_declaration "const char*" "message" "\"Hello\"" in
    check bool "常量声明包含const关键字" true (contains_substring const_decl "const");
    check bool "常量声明包含类型" true (contains_substring const_decl "char*");
    
    let if_stmt = CCodegen.c_if_statement "x > 0" "printf(\"positive\");" in
    check bool "If语句包含条件" true (contains_substring if_stmt "x > 0");
    check bool "If语句包含主体" true (contains_substring if_stmt "printf");
    
    let if_else = CCodegen.c_if_else_statement "x > 0" "positive();" "negative();" in
    check bool "If-else语句包含else分支" true (contains_substring if_else "else");
    
    let while_loop = CCodegen.c_while_loop "i < 10" "i++;" in
    check bool "While循环包含条件" true (contains_substring while_loop "i < 10");
    check bool "While循环包含主体" true (contains_substring while_loop "i++");
    
    let for_loop = CCodegen.c_for_loop "int i = 0" "i < 10" "i++" "process(i);" in
    check bool "For循环包含初始化" true (contains_substring for_loop "int i = 0");
    check bool "For循环包含条件" true (contains_substring for_loop "i < 10");
    check bool "For循环包含增量" true (contains_substring for_loop "i++")

  (** 测试函数和结构体定义 *)
  let test_function_and_struct_definitions () =
    let func_decl = CCodegen.c_function_declaration "int" "add" ["int a"; "int b"] in
    check bool "函数声明包含返回类型" true (contains_substring func_decl "int");
    check bool "函数声明包含函数名" true (contains_substring func_decl "add");
    check bool "函数声明包含参数" true (contains_substring func_decl "int a");
    
    let func_def = CCodegen.c_function_definition "int" "multiply" ["int x"; "int y"] "return x * y;" in
    check bool "函数定义包含主体" true (contains_substring func_def "return x * y");
    
    let struct_def = CCodegen.c_struct_definition "Point" [("int", "x"); ("int", "y")] in
    check bool "结构体定义包含结构体名" true (contains_substring struct_def "Point");
    check bool "结构体定义包含字段类型" true (contains_substring struct_def "int");
    check bool "结构体定义包含字段名" true (contains_substring struct_def "x");
    
    let enum_def = CCodegen.c_enum_definition "Color" ["RED"; "GREEN"; "BLUE"] in
    check bool "枚举定义包含枚举名" true (contains_substring enum_def "Color");
    check bool "枚举定义包含值" true (contains_substring enum_def "RED")
end

(** 测试EnhancedCCodegen模块 *)
module Test_EnhancedCCodegen = struct
  (** 测试类型转换和构造器匹配 *)
  let test_type_conversion_and_constructors () =
    let cast_result = EnhancedCCodegen.type_cast "int" "3.14" in
    check bool "类型转换包含目标类型" true (contains_substring cast_result "int");
    check bool "类型转换包含表达式" true (contains_substring cast_result "3.14");
    
    let constructor_result = EnhancedCCodegen.constructor_match "expr_var" "Some" in
    check bool "构造器匹配包含变量" true (contains_substring constructor_result "expr_var");
    check bool "构造器匹配包含构造器" true (contains_substring constructor_result "Some");
    
    let string_eq = EnhancedCCodegen.string_equality_escaped "var" "test" in
    check bool "转义字符串相等检查有效" true (is_valid_c_format string_eq)

  (** 测试扩展的骆言函数调用 *)
  let test_enhanced_luoyan_calls () =
    let cast_call = EnhancedCCodegen.luoyan_call_with_cast "func_name" "int" ["arg1"; "arg2"] in
    check bool "带转换的调用包含转换类型" true (contains_substring cast_call "int");
    check bool "带转换的调用包含函数名" true (contains_substring cast_call "func_name");
    
    let conditional = EnhancedCCodegen.luoyan_conditional_binding "result" "condition" "true_expr" "false_expr" in
    check bool "条件绑定包含变量名" true (contains_substring conditional "result");
    check bool "条件绑定包含条件" true (contains_substring conditional "condition");
    check bool "条件绑定包含真表达式" true (contains_substring conditional "true_expr");
    check bool "条件绑定包含假表达式" true (contains_substring conditional "false_expr");
    
    let dynamic_call = EnhancedCCodegen.luoyan_dynamic_call "func_expr" "args_array" in
    check bool "动态调用包含函数表达式" true (contains_substring dynamic_call "func_expr");
    check bool "动态调用包含参数数组" true (contains_substring dynamic_call "args_array");
    
    let partial_app = EnhancedCCodegen.luoyan_partial_application "func_expr" "partial_args" in
    check bool "部分应用包含函数表达式" true (contains_substring partial_app "func_expr");
    check bool "部分应用包含部分参数" true (contains_substring partial_app "partial_args")

  (** 测试内存管理 *)
  let test_memory_management () =
    let alloc_result = EnhancedCCodegen.luoyan_alloc 1024 in
    check bool "分配内存包含大小" true (contains_substring alloc_result "1024");
    
    let free_result = EnhancedCCodegen.luoyan_free "ptr" in
    check bool "释放内存包含指针" true (contains_substring free_result "ptr");
    
    let gc_result = EnhancedCCodegen.luoyan_gc_collect () in
    check bool "垃圾回收调用有效" true (is_valid_c_format gc_result)

  (** 测试数据结构操作 *)
  let test_data_structure_operations () =
    let array_create = EnhancedCCodegen.luoyan_array_create 10 in
    check bool "数组创建包含大小" true (contains_substring array_create "10");
    
    let array_get = EnhancedCCodegen.luoyan_array_get "arr" 5 in
    check bool "数组获取包含数组" true (contains_substring array_get "arr");
    check bool "数组获取包含索引" true (contains_substring array_get "5");
    
    let array_set = EnhancedCCodegen.luoyan_array_set "arr" 3 "value" in
    check bool "数组设置包含数组" true (contains_substring array_set "arr");
    check bool "数组设置包含索引" true (contains_substring array_set "3");
    check bool "数组设置包含值" true (contains_substring array_set "value");
    
    let record_create = EnhancedCCodegen.luoyan_record_create 5 in
    check bool "记录创建包含字段数量" true (contains_substring record_create "5");
    
    let record_get = EnhancedCCodegen.luoyan_record_get "record" "field_name" in
    check bool "记录获取包含记录" true (contains_substring record_get "record");
    check bool "记录获取包含字段名" true (contains_substring record_get "field_name");
    
    let record_set = EnhancedCCodegen.luoyan_record_set "record" "field_name" "new_value" in
    check bool "记录设置包含记录" true (contains_substring record_set "record");
    check bool "记录设置包含字段名" true (contains_substring record_set "field_name");
    check bool "记录设置包含新值" true (contains_substring record_set "new_value")

  (** 测试类型检查和错误处理 *)
  let test_type_checking_and_error_handling () =
    let type_check = EnhancedCCodegen.luoyan_type_check "value" "int" in
    check bool "类型检查包含值" true (contains_substring type_check "value");
    check bool "类型检查包含期望类型" true (contains_substring type_check "int");
    
    let is_type = EnhancedCCodegen.luoyan_is_type "value" "string" in
    check bool "类型判断包含值" true (contains_substring is_type "value");
    check bool "类型判断包含类型名" true (contains_substring is_type "string");
    
    let error_throw = EnhancedCCodegen.luoyan_error_throw 404 "Not found" in
    check bool "错误抛出包含错误码" true (contains_substring error_throw "404");
    check bool "错误抛出包含消息" true (contains_substring error_throw "Not found");
    
    let error_propagate = EnhancedCCodegen.luoyan_error_propagate "error" in
    check bool "错误传播包含错误" true (contains_substring error_propagate "error");
    
    let error_check = EnhancedCCodegen.luoyan_error_check "result" in
    check bool "错误检查包含结果" true (contains_substring error_check "result")

  (** 测试调试和性能 *)
  let test_debugging_and_performance () =
    let debug_trace = EnhancedCCodegen.luoyan_debug_trace "test_function" "arguments" in
    check bool "调试追踪包含函数名" true (contains_substring debug_trace "test_function");
    check bool "调试追踪包含参数" true (contains_substring debug_trace "arguments");
    
    let profile_start = EnhancedCCodegen.luoyan_profile_start "optimization" in
    check bool "性能分析开始包含标签" true (contains_substring profile_start "optimization");
    
    let profile_end = EnhancedCCodegen.luoyan_profile_end "optimization" in
    check bool "性能分析结束包含标签" true (contains_substring profile_end "optimization")
end

(** 测试CodeGenUtilities模块 *)
module Test_CodeGenUtilities = struct
  (** 测试代码注释 *)
  let test_code_comments () =
    let line_comment = CodeGenUtilities.c_line_comment "This is a line comment" in
    check bool "行注释以//开头" true (String.sub line_comment 0 2 = "//");
    check bool "行注释包含内容" true (contains_substring line_comment "This is a line comment");
    
    let block_comment = CodeGenUtilities.c_block_comment "Block comment content" in
    check bool "块注释包含/*" true (contains_substring block_comment "/*");
    check bool "块注释包含*/" true (contains_substring block_comment "*/");
    check bool "块注释包含内容" true (contains_substring block_comment "Block comment content");
    
    let doc_comment = CodeGenUtilities.c_doc_comment "Documentation comment" in
    check bool "文档注释包含/**" true (contains_substring doc_comment "/**");
    check bool "文档注释包含内容" true (contains_substring doc_comment "Documentation comment")

  (** 测试代码格式化 *)
  let test_code_formatting () =
    let indented = CodeGenUtilities.c_indent_block "line1\nline2\nline3" 1 in
    check bool "缩进块包含原内容" true (contains_substring indented "line1");
    check bool "缩进块包含缩进" true (contains_substring indented "    line1");
    
    let params_with_values = CodeGenUtilities.c_format_parameter_list ["int a"; "char* b"; "float c"] in
    check bool "参数列表包含所有参数" true (contains_substring params_with_values "int a");
    check bool "参数列表使用逗号分隔" true (contains_substring params_with_values ", ");
    
    let empty_params = CodeGenUtilities.c_format_parameter_list [] in
    check string "空参数列表返回void" "void" empty_params

  (** 测试预处理器指令 *)
  let test_preprocessor_directives () =
    let system_include = CodeGenUtilities.c_include_system "stdio.h" in
    check bool "系统头文件包含<>" true (contains_substring system_include "<stdio.h>");
    
    let local_include = CodeGenUtilities.c_include_local "myheader.h" in
    check bool "本地头文件包含双引号" true (contains_substring local_include "\"myheader.h\"");
    
    let define_result = CodeGenUtilities.c_define "MAX_SIZE" "1024" in
    check bool "宏定义包含名称" true (contains_substring define_result "MAX_SIZE");
    check bool "宏定义包含值" true (contains_substring define_result "1024");
    
    let ifdef_result = CodeGenUtilities.c_ifdef "DEBUG" in
    check bool "ifdef包含条件" true (contains_substring ifdef_result "DEBUG");
    
    let ifndef_result = CodeGenUtilities.c_ifndef "HEADER_H" in
    check bool "ifndef包含条件" true (contains_substring ifndef_result "HEADER_H");
    
    let endif_result = CodeGenUtilities.c_endif () in
    check string "endif格式正确" "#endif" endif_result

  (** 测试代码块管理 *)
  let test_code_block_management () =
    let scope_block = CodeGenUtilities.c_scope_block ["int x = 0;"; "printf(\"%d\", x);"; "return x;"] in
    check bool "作用域块包含大括号开始" true (contains_substring scope_block "{");
    check bool "作用域块包含大括号结束" true (contains_substring scope_block "}");
    check bool "作用域块包含语句" true (contains_substring scope_block "int x = 0");
    
    let namespace_block = CodeGenUtilities.c_namespace_block "MyNamespace" "int func() { return 42; }" in
    check bool "命名空间块包含命名空间名" true (contains_substring namespace_block "MyNamespace");
    check bool "命名空间块包含内容" true (contains_substring namespace_block "int func()")
end

let () =
  run "骆言C代码生成格式化模块全面测试"
    [
      ( "C代码生成基础",
        [
          test_case "基础函数调用格式化" `Quick Test_CCodegen.test_function_calls;
          test_case "骆言特定格式" `Quick Test_CCodegen.test_luoyan_formats;
          test_case "复杂骆言格式" `Quick Test_CCodegen.test_complex_luoyan_formats;
          test_case "环境绑定和字符串处理" `Quick Test_CCodegen.test_environment_and_strings;
          test_case "异常处理格式化" `Quick Test_CCodegen.test_exception_handling;
          test_case "C语句和控制结构" `Quick Test_CCodegen.test_c_statements_and_control;
          test_case "变量声明和控制流" `Quick Test_CCodegen.test_declarations_and_control_flow;
          test_case "函数和结构体定义" `Quick Test_CCodegen.test_function_and_struct_definitions;
        ] );
      ( "增强C代码生成",
        [
          test_case "类型转换和构造器匹配" `Quick Test_EnhancedCCodegen.test_type_conversion_and_constructors;
          test_case "扩展的骆言函数调用" `Quick Test_EnhancedCCodegen.test_enhanced_luoyan_calls;
          test_case "内存管理" `Quick Test_EnhancedCCodegen.test_memory_management;
          test_case "数据结构操作" `Quick Test_EnhancedCCodegen.test_data_structure_operations;
          test_case "类型检查和错误处理" `Quick Test_EnhancedCCodegen.test_type_checking_and_error_handling;
          test_case "调试和性能" `Quick Test_EnhancedCCodegen.test_debugging_and_performance;
        ] );
      ( "代码生成工具",
        [
          test_case "代码注释" `Quick Test_CodeGenUtilities.test_code_comments;
          test_case "代码格式化" `Quick Test_CodeGenUtilities.test_code_formatting;
          test_case "预处理器指令" `Quick Test_CodeGenUtilities.test_preprocessor_directives;
          test_case "代码块管理" `Quick Test_CodeGenUtilities.test_code_block_management;
        ] );
    ]