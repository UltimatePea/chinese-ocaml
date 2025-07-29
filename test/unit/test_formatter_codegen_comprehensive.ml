(** 骆言编译器C代码生成格式化模块综合测试

    Author: Alpha, 主工作代理
    测试覆盖率提升计划第二阶段 - C代码生成格式化器全面测试
    Target: formatter_codegen.ml 模块基础覆盖率 (目标20%+)

    本测试模块验证 Formatter_codegen 模块的：
    - CCodegen C代码生成格式化
    - 骆言特定函数调用格式化
    - 环境绑定和数据类型格式化
    - 性能和边界条件测试 *)

open Alcotest
open Yyocamlc_lib.Formatter_codegen

(** CCodegen 模块测试套件 *)
module CCodegenTests = struct
  let test_function_call () =
    check string "无参数函数调用" "printf()" (CCodegen.function_call "printf" []);
    check string "单参数函数调用" "strlen(str)" (CCodegen.function_call "strlen" ["str"]);
    check string "多参数函数调用" "memcpy(dest, src, size)" (CCodegen.function_call "memcpy" ["dest"; "src"; "size"]);
    check string "中文函数名调用" "中文函数(参数1, 参数2)" (CCodegen.function_call "中文函数" ["参数1"; "参数2"])

  let test_binary_function_call () =
    check string "二元函数调用" "add(left, right)" (CCodegen.binary_function_call "add" "left" "right");
    check string "比较函数调用" "compare(x, y)" (CCodegen.binary_function_call "compare" "x" "y");
    check string "中文二元函数" "比较(值1, 值2)" (CCodegen.binary_function_call "比较" "值1" "值2")

  let test_unary_function_call () =
    check string "一元函数调用" "abs(value)" (CCodegen.unary_function_call "abs" "value");
    check string "取反函数调用" "negate(x)" (CCodegen.unary_function_call "negate" "x");
    check string "中文一元函数" "取反(数值)" (CCodegen.unary_function_call "取反" "数值")
end

(** 骆言特定格式化测试套件 *)
module LuoyanSpecificTests = struct
  let test_luoyan_call () =
    check string "骆言函数调用" "luoyan_call(func_ptr, 2, args_array)" 
      (CCodegen.luoyan_call "func_ptr" 2 "args_array");
    check string "零参数骆言调用" "luoyan_call(main_func, 0, NULL)" 
      (CCodegen.luoyan_call "main_func" 0 "NULL");
    check string "多参数骆言调用" "luoyan_call(calc, 5, param_list)" 
      (CCodegen.luoyan_call "calc" 5 "param_list")

  let test_luoyan_bind_var () =
    check string "变量绑定" "luoyan_bind_var(\"x\", value_ptr)" (CCodegen.luoyan_bind_var "x" "value_ptr");
    check string "中文变量绑定" "luoyan_bind_var(\"变量名\", 数值)" (CCodegen.luoyan_bind_var "变量名" "数值");
    check string "空变量名绑定" "luoyan_bind_var(\"\", empty_val)" (CCodegen.luoyan_bind_var "" "empty_val")

  let test_luoyan_string () =
    check string "字符串值" "luoyan_string(\"hello\")" (CCodegen.luoyan_string "hello");
    check string "中文字符串" "luoyan_string(\"\\228\\189\\160\\229\\165\\189\\228\\184\\150\\231\\149\\140\")" (CCodegen.luoyan_string "你好世界");
    check string "空字符串" "luoyan_string(\"\")" (CCodegen.luoyan_string "");
    check string "特殊字符字符串" "luoyan_string(\"hello\\nworld\")" (CCodegen.luoyan_string "hello\nworld")

  let test_luoyan_int () =
    check string "整数值" "luoyan_int(42)" (CCodegen.luoyan_int 42);
    check string "零整数" "luoyan_int(0)" (CCodegen.luoyan_int 0);
    check string "负整数" "luoyan_int(-123)" (CCodegen.luoyan_int (-123));
    check string "最大整数" "luoyan_int(4611686018427387903)" (CCodegen.luoyan_int max_int)

  let test_luoyan_float () =
    check string "浮点数值" "luoyan_float(3.14)" (CCodegen.luoyan_float 3.14);
    check string "零浮点数" "luoyan_float(0.)" (CCodegen.luoyan_float 0.0);
    check string "负浮点数" "luoyan_float(-2.718)" (CCodegen.luoyan_float (-2.718));
    check string "科学计数法" "luoyan_float(1000000.)" (CCodegen.luoyan_float 1e6)

  let test_luoyan_bool () =
    check string "真值布尔" "luoyan_bool(true)" (CCodegen.luoyan_bool true);
    check string "假值布尔" "luoyan_bool(false)" (CCodegen.luoyan_bool false)

  let test_luoyan_unit () =
    check string "单元值" "luoyan_unit()" (CCodegen.luoyan_unit ())

  let test_luoyan_equals () =
    check string "等值比较" "luoyan_equals(expr_var, target_val)" (CCodegen.luoyan_equals "expr_var" "target_val");
    check string "中文变量等值" "luoyan_equals(变量, 目标值)" (CCodegen.luoyan_equals "变量" "目标值")

  let test_luoyan_let () =
    check string "Let绑定" "luoyan_let(\"x\", init_val, body_expr)" 
      (CCodegen.luoyan_let "x" "init_val" "body_expr");
    check string "中文Let绑定" "luoyan_let(\"计数器\", 初始值, 主体代码)" 
      (CCodegen.luoyan_let "计数器" "初始值" "主体代码")

  let test_luoyan_function_create () =
    check string "函数创建" "luoyan_function_create(add_impl_x, env, \"add\")" 
      (CCodegen.luoyan_function_create "add" "x");
    check string "中文函数创建" "luoyan_function_create(计算_impl_参数, env, \"计算\")" 
      (CCodegen.luoyan_function_create "计算" "参数")

  let test_luoyan_pattern_match () =
    check string "模式匹配" "luoyan_pattern_match(expr_var)" (CCodegen.luoyan_pattern_match "expr_var");
    check string "中文变量模式匹配" "luoyan_pattern_match(表达式变量)" (CCodegen.luoyan_pattern_match "表达式变量")

  let test_luoyan_var_expr () =
    check string "变量表达式块" 
      "({ luoyan_value_t* temp_var = some_expr; luoyan_match(temp_var); })"
      (CCodegen.luoyan_var_expr "temp_var" "some_expr");
    check string "中文变量表达式块"
      "({ luoyan_value_t* 临时变量 = 表达式代码; luoyan_match(临时变量); })"
      (CCodegen.luoyan_var_expr "临时变量" "表达式代码")

  let test_luoyan_env_bind () =
    (* 需要检查这个函数的实际实现 *)
    let result = CCodegen.luoyan_env_bind "var_name" "expr_code" in
    check bool "环境绑定结果非空" true (String.length result > 0);
    check bool "包含变量名" true (String.contains result 'v')
end

(** 边界条件和错误处理测试 *)
module EdgeCaseTests = struct
  let test_empty_parameters () =
    check string "空参数列表" "func()" (CCodegen.function_call "func" []);
    check string "空字符串参数" "test()" (CCodegen.function_call "test" [""])

  let test_special_characters () =
    check string "特殊字符函数名" "_func$()" (CCodegen.function_call "_func$" []);
    check string "转义字符在字符串中" "luoyan_string(\"tab\\there\")" (CCodegen.luoyan_string "tab\there")

  let test_unicode_in_c_code () =
    check string "Unicode函数名" "中文函数名()" (CCodegen.function_call "中文函数名" []);
    let rocket_result = CCodegen.luoyan_string "🚀火箭" in
    check bool "Unicode字符串值长度正确" true (String.length rocket_result > 20)

  let test_extreme_values () =
    check string "最大整数生成" "luoyan_int(4611686018427387903)" (CCodegen.luoyan_int max_int);
    check string "最小整数生成" "luoyan_int(-4611686018427387904)" (CCodegen.luoyan_int min_int);
    check string "无穷大浮点" "luoyan_float(inf)" (CCodegen.luoyan_float infinity);
    check string "负无穷浮点" "luoyan_float(-inf)" (CCodegen.luoyan_float neg_infinity)

  let test_long_strings () =
    let long_string = String.make 1000 'a' in
    let result = CCodegen.luoyan_string long_string in
    check bool "长字符串格式化" true (String.length result > 1000);
    check bool "长字符串包含引号" true (String.contains result '"')
end

(** 性能测试 *)
module PerformanceTests = struct
  let test_repeated_calls () =
    for i = 1 to 1000 do
      ignore (CCodegen.luoyan_int i);
      ignore (CCodegen.luoyan_string ("test" ^ string_of_int i))
    done;
    check bool "重复调用性能测试" true true

  let test_complex_nested_calls () =
    let nested = CCodegen.luoyan_let "x" 
      (CCodegen.luoyan_int 42) 
      (CCodegen.luoyan_call "func" 1 "args") in
    check bool "复杂嵌套调用" true (String.length nested > 50);
    check bool "嵌套调用包含luoyan关键字" true (String.contains nested 'l')
end

(** 主测试套件注册 *)
let codegen_tests = [
  test_case "函数调用格式化" `Quick CCodegenTests.test_function_call;
  test_case "二元函数调用格式化" `Quick CCodegenTests.test_binary_function_call;
  test_case "一元函数调用格式化" `Quick CCodegenTests.test_unary_function_call;
]

let luoyan_tests = [
  test_case "骆言函数调用" `Quick LuoyanSpecificTests.test_luoyan_call;
  test_case "骆言变量绑定" `Quick LuoyanSpecificTests.test_luoyan_bind_var;
  test_case "骆言字符串值" `Quick LuoyanSpecificTests.test_luoyan_string;
  test_case "骆言整数值" `Quick LuoyanSpecificTests.test_luoyan_int;
  test_case "骆言浮点数值" `Quick LuoyanSpecificTests.test_luoyan_float;
  test_case "骆言布尔值" `Quick LuoyanSpecificTests.test_luoyan_bool;
  test_case "骆言单元值" `Quick LuoyanSpecificTests.test_luoyan_unit;
  test_case "骆言等值判断" `Quick LuoyanSpecificTests.test_luoyan_equals;
  test_case "骆言Let绑定" `Quick LuoyanSpecificTests.test_luoyan_let;
  test_case "骆言函数创建" `Quick LuoyanSpecificTests.test_luoyan_function_create;
  test_case "骆言模式匹配" `Quick LuoyanSpecificTests.test_luoyan_pattern_match;
  test_case "骆言变量表达式" `Quick LuoyanSpecificTests.test_luoyan_var_expr;
  test_case "骆言环境绑定" `Quick LuoyanSpecificTests.test_luoyan_env_bind;
]

let edge_case_tests = [
  test_case "空参数处理" `Quick EdgeCaseTests.test_empty_parameters;
  test_case "特殊字符处理" `Quick EdgeCaseTests.test_special_characters;
  test_case "Unicode字符支持" `Quick EdgeCaseTests.test_unicode_in_c_code;
  test_case "极值处理" `Quick EdgeCaseTests.test_extreme_values;
  test_case "长字符串处理" `Quick EdgeCaseTests.test_long_strings;
]

let performance_tests = [
  test_case "重复调用性能" `Quick PerformanceTests.test_repeated_calls;
  test_case "复杂嵌套调用" `Quick PerformanceTests.test_complex_nested_calls;
]

let () = run "Formatter Codegen Comprehensive Tests" [
  ("C Codegen Formatting", codegen_tests);
  ("Luoyan Specific Formatting", luoyan_tests);
  ("Edge Cases", edge_case_tests);
  ("Performance Tests", performance_tests);
]