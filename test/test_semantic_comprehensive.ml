(** 骆言语义分析器综合测试模块 - Fix #732 *)

open Alcotest
open Yyocamlc_lib

(* 测试辅助函数 *)
let run_semantic_analysis input =
  try
    let tokens = Lexer.tokenize input in
    match Parser.parse_program tokens with
    | Ok ast ->
        (match Semantic.check_program ast with
         | Ok typed_ast -> Ok typed_ast
         | Error msg -> Error msg)
    | Error msg -> Error ("解析错误: " ^ msg)
  with
  | exn -> Error (Printexc.to_string exn)

let check_semantic_success msg input =
  match run_semantic_analysis input with
  | Ok _ -> ()
  | Error err -> Alcotest.fail ("语义分析失败: " ^ err ^ " 输入: " ^ input)

let check_semantic_failure msg input expected_error =
  match run_semantic_analysis input with
  | Ok _ -> Alcotest.fail ("预期语义分析失败但成功了，输入: " ^ input)
  | Error err -> 
      if String.length expected_error > 0 && not (String.contains err (String.get expected_error 0)) then
        Alcotest.fail ("错误信息不匹配，期望包含: " ^ expected_error ^ ", 实际: " ^ err)

(* 类型检查测试 *)
let test_basic_type_checking () =
  (* 基本类型推断 *)
  check_semantic_success "整数类型推断" "设 x = 42";
  check_semantic_success "字符串类型推断" "设 s = \"你好\"";
  check_semantic_success "布尔类型推断" "设 b = 真";
  check_semantic_success "浮点类型推断" "设 f = 3.14";
  
  (* 函数类型推断 *)
  check_semantic_success "简单函数类型" "函数 f x = x + 1";
  check_semantic_success "高阶函数类型" "函数 map f 列表 = 匹配 列表 与 | [] -> [] | h :: t -> f h :: map f t";

let test_type_errors () =
  (* 类型不匹配错误 *)
  check_semantic_failure "类型不匹配" "设 x = 42 + \"hello\"" "类型";
  check_semantic_failure "函数参数类型错误" "设 f x = x + 1 in f \"hello\"" "类型";
  check_semantic_failure "条件类型错误" "若 \"not_bool\" 则 1 否则 2" "布尔";
  
  (* 未定义变量错误 *)
  check_semantic_failure "未定义变量" "x + 1" "未定义";
  check_semantic_failure "未定义函数" "未知函数 42" "未定义";

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