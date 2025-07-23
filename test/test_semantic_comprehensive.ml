(** 骆言语义分析器综合测试模块 - Fix #985 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Types
open Yyocamlc_lib.Semantic

(* 测试辅助函数 *)
let create_test_context () =
  let context = create_initial_context () in
  add_builtin_functions context

let check_expression_type context expr expected_type =
  let _, type_opt = analyze_expression context expr in
  match type_opt with
  | Some typ -> typ = expected_type
  | None -> false

(* 基本表达式语义测试 *)
let test_basic_type_checking () =
  let context = create_test_context () in
  
  (* 整数字面量 *)
  let int_expr = LitExpr (IntLit 42) in
  check bool "整数字面量类型推导" true (check_expression_type context int_expr IntType_T);
  
  (* 字符串字面量 *)
  let str_expr = LitExpr (StringLit "你好") in
  check bool "字符串字面量类型推导" true (check_expression_type context str_expr StringType_T);
  
  (* 布尔字面量 *)
  let bool_expr = LitExpr (BoolLit true) in
  check bool "布尔字面量类型推导" true (check_expression_type context bool_expr BoolType_T);
  
  (* 单位字面量 *)
  let unit_expr = LitExpr UnitLit in
  check bool "单位字面量类型推导" true (check_expression_type context unit_expr UnitType_T);

let test_type_errors () =
  let context = create_test_context () in
  
  (* 未定义变量应该产生错误 *)
  let undefined_var_expr = VarExpr "未定义变量" in
  let new_context, type_opt = analyze_expression context undefined_var_expr in
  check bool "未定义变量检测" true (type_opt = None || List.length new_context.error_list > 0);

let test_scope_analysis () =
  (* 作用域正确性 *)
  check_semantic_success "嵌套作用域" {|
    设 x = 1 in
    设 y = (设 x = 2 in x + 1) in
    x + y
  |};
  
  check_semantic_success "函数作用域" {|
    函数 外层 x =
      函数 内层 y = x + y in
      内层 10
  |};
  
  (* 作用域错误 *)
  check_semantic_failure "变量作用域越界" {|
    (设 x = 1 in x);
    x
  |} "未定义";

let test_function_signatures () =
  (* 函数签名验证 *)
  check_semantic_success "递归函数" {|
    函数 阶乘 n =
      若 n <= 1 则 1
      否则 n * 阶乘 (n - 1)
  |};
  
  check_semantic_success "相互递归" {|
    函数 偶数 n = 若 n = 0 则 真 否则 奇数 (n - 1)
    and 奇数 n = 若 n = 0 则 假 否则 偶数 (n - 1)
  |};
  
  (* 函数调用参数数量检查 *)
  check_semantic_failure "参数过多" "设 f x = x + 1 in f 1 2" "参数";
  check_semantic_failure "参数过少" "设 f x y = x + y in f 1" "参数";

let test_pattern_matching () =
  (* 模式匹配完整性 *)
  check_semantic_success "完整模式匹配" {|
    函数 处理选项 opt =
      匹配 opt 与
      | Some x -> x
      | None -> 0
  |};
  
  (* 模式匹配详尽性检查 *)
  check_semantic_failure "不完整模式匹配" {|
    函数 处理选项 opt =
      匹配 opt 与
      | Some x -> x
  |} "不完整";
  
  (* 复杂模式匹配 *)
  check_semantic_success "嵌套模式匹配" {|
    函数 处理嵌套 数据 =
      匹配 数据 与
      | (Some x, y) -> x + y
      | (None, y) -> y
  |};

let test_type_inference () =
  (* 复杂类型推断 *)
  check_semantic_success "列表类型推断" "设 列表 = [1; 2; 3]";
  check_semantic_success "记录类型推断" "设 人员 = { 姓名 = \"张三\"; 年龄 = 25 }";
  
  (* 多态类型推断 *)
  check_semantic_success "多态函数" "函数 身份 x = x";
  check_semantic_success "多态列表函数" "函数 头部 列表 = 匹配 列表 与 | h :: _ -> Some h | [] -> None";

let test_chinese_semantics () =
  (* 中文语义特色 *)
  check_semantic_success "中文变量名" "设 中文变量 = 42";
  check_semantic_success "中文函数名" "函数 中文函数 参数 = 参数 * 2";
  
  (* 诗词编程语义 *)
  check_semantic_success "诗词风格语义" {|
    设 春眠不觉晓 = 42
    设 处处闻啼鸟 = 春眠不觉晓 + 1
    函数 夜来风雨声 花落知多少 = 花落知多少 * 处处闻啼鸟
  |};

let test_error_recovery () =
  (* 语义错误恢复 *)
  check_semantic_failure "多重类型错误" {|
    设 x = 42 + \"error1\"
    设 y = \"error2\" * 3
    x + y
  |} "类型";
  
  (* 级联错误处理 *)
  check_semantic_failure "级联错误" {|
    设 f = 未定义函数
    设 结果 = f 42
    结果 + 1
  |} "未定义";

let test_performance_semantics () =
  (* 大型程序语义分析性能 *)
  let large_program = 
    String.concat "\n" (List.init 100 (fun i -> 
      Printf.sprintf "设 变量%d = %d" i i)) in
  check_semantic_success "大型程序" large_program;
  
  (* 深度嵌套语义分析 *)
  let deep_nested = 
    String.concat " in " (List.init 50 (fun i -> 
      Printf.sprintf "设 x%d = %d" i i)) ^ " in x0" in
  check_semantic_success "深度嵌套" deep_nested;

let test_builtin_functions () =
  (* 内置函数语义 *)
  check_semantic_success "数学函数" "abs (-42)";
  check_semantic_success "字符串函数" "String.length \"你好\"";
  check_semantic_success "列表函数" "List.map (fun x -> x + 1) [1; 2; 3]";
  
  (* 内置函数类型检查 *)
  check_semantic_failure "内置函数类型错误" "abs \"not_number\"" "类型";

let test_module_semantics () =
  (* 模块语义分析 *)
  check_semantic_success "模块访问" "Math.pi";
  check_semantic_success "模块函数调用" "List.length [1; 2; 3]";
  
  (* 模块不存在错误 *)
  check_semantic_failure "不存在模块" "NonExistent.function 42" "未定义";

(* 诗词编程特色语义测试 *)
let test_poetry_semantics () =
  (* 韵律编程语义 *)
  check_semantic_success "韵律语义" {|
    设 月落乌啼霜满天 = 42
    设 江枫渔火对愁眠 = 36
    设 姑苏城外寒山寺 = 月落乌啼霜满天 + 江枫渔火对愁眠
    设 夜半钟声到客船 = 姑苏城外寒山寺 * 2
  |};
  
  (* 对仗编程语义 *)
  check_semantic_success "对仗语义" {|
    函数 山重水复疑无路 参数 = 参数 * 2
    函数 柳暗花明又一村 参数 = 参数 + 1
    设 result = 山重水复疑无路 (柳暗花明又一村 10)
  |};

(* 测试套件定义 *)
let semantic_comprehensive_tests = [
  "基础类型检查", `Quick, test_basic_type_checking;
  "类型错误检测", `Quick, test_type_errors;
  "作用域分析", `Quick, test_scope_analysis;
  "函数签名验证", `Quick, test_function_signatures;
  "模式匹配语义", `Quick, test_pattern_matching;
  "类型推断", `Quick, test_type_inference;
  "中文语义特色", `Quick, test_chinese_semantics;
  "错误恢复机制", `Quick, test_error_recovery;
  "性能语义分析", `Slow, test_performance_semantics;
  "内置函数语义", `Quick, test_builtin_functions;
  "模块语义分析", `Quick, test_module_semantics;
  "诗词编程语义", `Quick, test_poetry_semantics;
]

(* 运行测试 *)
let () =
  run "Semantic综合测试" [
    "semantic_comprehensive", semantic_comprehensive_tests;
  ]