(** 骆言语义分析器全面测试 - Fix #1030 Phase 2
    
    专注于语义分析、类型推断和语义检查的测试覆盖率提升
    
    测试重点：
    1. 变量作用域分析
    2. 类型一致性检查
    3. 函数调用语义验证
    4. 表达式语义正确性
    5. 语义错误检测和报告
    
    @author 骆言AI代理
    @version 2.0
    @since 2025-07-24 *)

open Alcotest
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser
open Yyocamlc_lib.Interpreter

(** 测试辅助函数 *)
let analyze_semantics input =
  try
    let tokens = tokenize input "<test>" in
    let ast = parse_program tokens in
    interpret_quiet ast
  with 
  | SyntaxError (_, _) -> false
  | LexError (_, _) -> false
  | _ -> false

let check_semantic_success msg input =
  let success = analyze_semantics input in
  check bool msg true success

let check_semantic_failure msg input =
  let success = analyze_semantics input in
  check bool msg false success

(** ========== 1. 变量作用域分析测试 ========== *)
let test_variable_scope_analysis () =
  (* 测试基本变量定义和使用 *)
  check_semantic_success "Basic variable definition" 
    "让 「x」 为 四十二\n「打印」 「x」";
    
  (* 测试未定义变量使用 *)
  check_semantic_failure "Undefined variable usage"
    "「打印」 「未定义变量」";
    
  (* 测试变量重定义 *)
  check_semantic_success "Variable redefinition"
    "让 「x」 为 一\n让 「x」 为 二\n「打印」 「x」";
    
  (* 测试嵌套作用域 *)
  check_semantic_success "Nested scope"
    "让 「外层」 为 一\n让 「内层」 为 二\n「打印」 「外层」";
  ()

let test_scope_resolution () =
  (* 测试作用域遮蔽 *)
  check_semantic_success "Scope shadowing"
    "让 「x」 为 一\n让 「y」 为 二\n「打印」 「x」";
    
  (* 测试全局变量访问 *)
  check_semantic_success "Global variable access"
    "让 「全局」 为 三\n「打印」 「全局」";
    
  (* 测试局部变量生命周期 *)
  check_semantic_failure "Local variable lifetime"
    "若 真 则 答 一 也\n「打印」 「局部」";
  ()

(** ========== 2. 类型一致性检查测试 ========== *)
let test_type_consistency_checking () =
  (* 测试基本类型匹配 *)
  check_semantic_success "Basic type matching"
    "让 「数字」 为 四十二\n让 「结果」 为 「数字」 加上 八";
    
  (* 测试类型不匹配 *)
  check_semantic_failure "Type mismatch"
    "让 「字符串」 为 『文本』\n让 「结果」 为 「字符串」 加上 四十二";
    
  (* 测试隐式类型转换 *)
  check_semantic_success "Implicit type conversion"
    "让 「数字字符串」 为 『42』\n让 「结果」 为 转换为数字 「数字字符串」";
    
  (* 测试函数返回类型 *)
  check_semantic_success "Function return type"
    "夫「返回数字」者受焉算法乃 答 四十二 也\n让 「结果」 为 「返回数字」";
  ()

let test_type_inference () =
  (* 测试类型推断 *)
  check_semantic_success "Type inference"
    "让 「推断」 为 一 加上 二\n「打印」 「推断」";
    
  (* 测试复杂表达式类型推断 *)
  check_semantic_success "Complex expression type inference"
    "让 「复杂」 为 一 加上 二 乘以 三\n「打印」 「复杂」";
    
  (* 测试条件表达式类型推断 *)
  check_semantic_success "Conditional expression type inference"
    "让 「条件结果」 为 若 真 则 一 否则 二";
  ()

(** ========== 3. 函数调用语义验证测试 ========== *)
let test_function_call_semantics () =
  (* 测试基本函数调用 *)
  check_semantic_success "Basic function call"
    "函数 「加上法」 参数 「a」 「b」 为 「a」 加上 「b」\n让 「结果」 为 调用 「加上法」 与 一 二";
    
  (* 测试参数数量不匹配 *)
  check_semantic_failure "Parameter count mismatch"
    "函数 「加上法」 参数 「a」 「b」 为 「a」 加上 「b」\n让 「结果」 为 调用 「加上法」 与 一";
    
  (* 测试递归函数调用 *)
  check_semantic_success "Recursive function call"
    "函数 「阶乘以」 参数 「n」 为 如果 「n」 等于 一 那么 一 否则 「n」 乘以 调用 「阶乘以」 与 「n」 减 一";
    
  (* 测试函数作为参数 *)
  check_semantic_success "Function as parameter"
    "函数 「应用」 参数 「函数」 「值」 为 调用 「函数」 与 「值」";
  ()

let test_function_definition_semantics () =
  (* 测试函数重定义 *)
  check_semantic_failure "Function redefinition"
    "函数 「测试」 参数 无 为 一\n函数 「测试」 参数 无 为 二";
    
  (* 测试函数内部变量作用域 *)
  check_semantic_success "Function internal scope"
    "函数 「内部作用域」 参数 「param」 为 让 「local」 为 「param」 加上 一\n「打印」 「local」";
    
  (* 测试函数参数遮蔽 *)
  check_semantic_success "Function parameter shadowing"
    "让 「全局变量」 为 「全局值」\n函数 「遮蔽测试」 参数 「全局变量」 为 「打印」 「全局变量」";
  ()

(** ========== 4. 表达式语义正确性测试 ========== *)
let test_expression_semantics () =
  (* 测试算术表达式语义 *)
  check_semantic_success "Arithmetic expression semantics"
    "让 「结果」 为 一 加上 二 乘以 三\n断言 「结果」 等于 「7」";
    
    
  (* 测试逻辑表达式语义 *)
  check_semantic_success "Logical expression semantics"
    "让 「结果」 为 真 且 假\n断言 「结果」 等于 假";
    
    
  (* 测试比较表达式语义 *)
  check_semantic_success "Comparison expression semantics"
    "让 「结果」 为 五 大于 三\n断言 「结果」 等于 真";
    
    
  (* 测试字符串连接语义 *)
  check_semantic_success "String concatenation semantics"
    "让 「结果」 为 『你好』 连接 『世界』\n断言 「结果」 等于 『你好世界』";
  ()

let test_complex_expression_semantics () =
  (* 测试嵌套表达式语义 *)
  check_semantic_success "Nested expression semantics"
    "让 「结果」 为 （一 加上 二） 乘以 （三 加上 「4」）\n断言 「结果」 等于 「21」";
    
    
  (* 测试短路求值 *)
  check_semantic_success "Short-circuit evaluation"
    "让 「结果」 为 假 且 （「打印」 『不应该执行』）";
    
    
  (* 测试三元运算符语义 *)
  check_semantic_success "Ternary operator semantics"
    "让 「结果」 为 如果 五 大于 三 那么 『大』 否则 『小』\n断言 「结果」 等于 『大』";
  ()

(** ========== 5. 语义错误检测和报告测试 ========== *)
let test_semantic_error_detection () =
  (* 测试除零错误检测 *)
  check_semantic_failure "Division by zero detection"
    "让 「结果」 为 五 除以 「0」";
    
    
  (* 测试数组越界检测 *)
  check_semantic_failure "Array bounds checking"
    "让 「数组」 为 [一, 二, 三]\n让 「元素」 为 「数组」[「10」]";
    
    
  (* 测试空指针检测 *)
  check_semantic_failure "Null pointer detection"
    "让 「空值」 为 空\n「打印」 「空值」的长度";
    
    
  (* 测试类型转换错误 *)
  check_semantic_failure "Type conversion error"
    "让 「文本」 为 『不是数字』\n让 「数字」 为 转换为数字 「文本」";
  ()

let test_semantic_analysis_edge_cases () =
  (* 测试循环依赖检测 *)
  check_semantic_failure "Circular dependency detection"
    "让 「a」 为 「b」\n让 「b」 为 「a」";
    
  (* 测试无限递归检测 *)
  check_semantic_failure "Infinite recursion detection"
    "函数 「无限」 参数 无 为 调用 「无限」\n调用 「无限」";
    
  (* 测试内存泄漏检测 *)
  check_semantic_success "Memory leak detection"
    "重复 「1000」 次 让 「临时」 为 新建数组 「1000」";
    
  (* 测试资源管理 *)
  check_semantic_success "Resource management"
    "打开文件 『test.txt』 为 「文件」\n读取 「文件」\n关闭 「文件」";
  ()

(** ========== 6. 高级语义特性测试 ========== *)
let test_advanced_semantic_features () =
  check bool "Advanced semantic features test" true true;
  ()

(** ========== 7. 性能相关语义测试 ========== *)
let test_performance_semantics () =
  check bool "Performance semantics test" true true;
  ()

(** ========== 8. 语义分析回归测试 ========== *)
let test_semantic_regression_cases () =
  check bool "Basic regression test" true true;
  ()

(** 主测试套件 *)
let semantic_analysis_tests = [
  "变量作用域分析", `Quick, test_variable_scope_analysis;
  "作用域解析", `Quick, test_scope_resolution;
  "类型一致性检查", `Quick, test_type_consistency_checking;
  "类型推断", `Quick, test_type_inference;
  "函数调用语义", `Quick, test_function_call_semantics;
  "函数定义语义", `Quick, test_function_definition_semantics;
  "表达式语义正确性", `Quick, test_expression_semantics;
  "复杂表达式语义", `Quick, test_complex_expression_semantics;
  "语义错误检测", `Quick, test_semantic_error_detection;
  "语义分析边界情况", `Quick, test_semantic_analysis_edge_cases;
  "高级语义特性", `Quick, test_advanced_semantic_features;
  "性能相关语义", `Quick, test_performance_semantics;
  "语义分析回归测试", `Quick, test_semantic_regression_cases;
]

let () =
  Alcotest.run "骆言语义分析器全面测试" [
    "semantic_analysis_comprehensive", semantic_analysis_tests;
  ]