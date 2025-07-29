(** 骆言语法分析器综合测试模块 - Fix #732 *)

open Alcotest
open Yyocamlc_lib

(* 测试辅助函数 *)
let run_parser input =
  try
    let tokens = Lexer.tokenize input in
    match Parser.parse_program tokens with
    | Ok ast -> Ok ast
    | Error msg -> Error msg
  with
  | exn -> Error (Printexc.to_string exn)

let check_parse_success msg input =
  match run_parser input with
  | Ok _ -> ()
  | Error err -> Alcotest.fail ("解析失败: " ^ err ^ " 输入: " ^ input)

let check_parse_failure msg input =
  match run_parser input with
  | Ok _ -> Alcotest.fail ("预期解析失败但成功了，输入: " ^ input)
  | Error _ -> ()

(* 基础语法解析测试 *)
let test_basic_expressions () =
  (* 数字字面量 *)
  check_parse_success "整数字面量" "42";
  check_parse_success "浮点数字面量" "3.14";
  check_parse_success "中文数字" "二十三";
  
  (* 字符串字面量 *)
  check_parse_success "字符串字面量" "\"你好世界\"";
  check_parse_success "空字符串" "\"\"";
  
  (* 布尔字面量 *)
  check_parse_success "真值" "真";
  check_parse_success "假值" "假";

let test_chinese_keywords () =
  (* 变量声明 *)
  check_parse_success "中文变量声明" "设 x = 42";
  check_parse_success "函数定义" "函数 f x = x + 1";
  
  (* 条件语句 *)
  check_parse_success "条件语句" "若 x > 0 则 x 否则 0";
  
  (* 模式匹配 *)
  check_parse_success "模式匹配" "匹配 x 与 | 0 -> \"零\" | _ -> \"非零\"";

let test_complex_expressions () =
  (* 嵌套表达式 *)
  check_parse_success "嵌套算术" "((1 + 2) * 3) / 4";
  check_parse_success "函数调用" "f (g (h x))";
  
  (* 列表操作 *)
  check_parse_success "列表字面量" "[1; 2; 3]";
  check_parse_success "列表拼接" "[1; 2] @ [3; 4]";
  
  (* 记录操作 *)
  check_parse_success "记录创建" "{ 姓名 = \"张三\"; 年龄 = 25 }";
  check_parse_success "记录访问" "person.姓名";

let test_poetry_syntax () =
  (* 诗词编程语法 *)
  check_parse_success "七言绝句风格" 
    "春眠不觉晓函数 (处处闻啼鸟参数) = 夜来风雨声返回 (花落知多少参数 + 1)";
  
  check_parse_success "五言律诗风格"
    "设 床前明月光 = 疑是地上霜表达式 (举头望明月值)";

let test_error_recovery () =
  (* 语法错误恢复测试 *)
  check_parse_failure "缺少右括号" "(1 + 2";
  check_parse_failure "非法字符" "let x = @#$";
  check_parse_failure "不完整表达式" "if x then";
  check_parse_failure "错误的关键字" "lte x = 42";

let test_unicode_support () =
  (* Unicode字符支持 *)
  check_parse_success "中文标识符" "设 变量名 = 值";
  check_parse_success "繁体中文" "設 變量名 = 值";
  check_parse_success "中文标点" "设 x = 1，y = 2";

let test_edge_cases () =
  (* 边界条件测试 *)
  check_parse_success "空程序" "";
  check_parse_success "只有注释" "(* 这是注释 *)";
  check_parse_success "多行程序" "设 x = 1\n设 y = 2\nx + y";
  
  (* 大数字 *)
  check_parse_success "大整数" "9223372036854775807";
  check_parse_success "小数精度" "0.123456789012345";

let test_performance_critical_paths () =
  (* 性能关键路径测试 *)
  let deep_nested = String.make 100 '(' ^ "42" ^ String.make 100 ')' in
  check_parse_success "深度嵌套" deep_nested;
  
  let long_identifier = "设 " ^ (String.make 1000 'x') ^ " = 42" in
  check_parse_success "长标识符" long_identifier;

(* 集成测试 - 完整程序解析 *)
let test_complete_programs () =
  (* 斐波那契数列 *)
  let fibonacci = {|
    函数 斐波那契 n =
      若 n <= 1 则 n
      否则 斐波那契 (n - 1) + 斐波那契 (n - 2)
  |} in
  check_parse_success "斐波那契程序" fibonacci;
  
  (* 快速排序 *)
  let quicksort = {|
    函数 快速排序 列表 =
      匹配 列表 与
      | [] -> []
      | 头 :: 尾 ->
          设 小于 = 过滤 (fun x -> x < 头) 尾 in
          设 大于等于 = 过滤 (fun x -> x >= 头) 尾 in
          快速排序 小于 @ [头] @ 快速排序 大于等于
  |} in
  check_parse_success "快速排序程序" quicksort;

(* 诗词编程特色测试 *)
let test_poetry_features () =
  (* 韵律编程 *)
  let poetry_program = {|
    (* 春晓主题程序 *)
    设 春眠不觉晓 = 42
    设 处处闻啼鸟 = 36
    设 夜来风雨声 = 春眠不觉晓 + 处处闻啼鸟
    设 花落知多少 = 夜来风雨声 * 2
  |} in
  check_parse_success "韵律编程" poetry_program;
  
  (* 对仗编程 *)
  let antithesis_program = {|
    函数 山重水复疑无路 x = x * 2
    函数 柳暗花明又一村 y = y + 1
    设 结果 = 山重水复疑无路 (柳暗花明又一村 10)
  |} in
  check_parse_success "对仗编程" antithesis_program;

(* 测试套件定义 *)
let parser_comprehensive_tests = [
  "基础表达式解析", `Quick, test_basic_expressions;
  "中文关键字解析", `Quick, test_chinese_keywords;
  "复杂表达式解析", `Quick, test_complex_expressions;
  "诗词语法解析", `Quick, test_poetry_syntax;
  "错误恢复机制", `Quick, test_error_recovery;
  "Unicode支持", `Quick, test_unicode_support;
  "边界条件", `Quick, test_edge_cases;
  "性能关键路径", `Slow, test_performance_critical_paths;
  "完整程序解析", `Quick, test_complete_programs;
  "诗词编程特色", `Quick, test_poetry_features;
]

(* 运行测试 *)
let () =
  run "Parser综合测试" [
    "parser_comprehensive", parser_comprehensive_tests;
  ]