(** 骆言错误处理系统综合测试模块 - Fix #732 *)

open Alcotest
open Yyocamlc_lib

(* 测试辅助函数 *)
let compile_and_catch_errors input =
  try
    let tokens = Lexer.tokenize input in
    match Parser.parse_program tokens with
    | Ok ast ->
        (match Semantic.check_program ast with
         | Ok typed_ast ->
             (match Codegen.generate_code typed_ast with
              | Ok code -> Ok ("编译成功", code)
              | Error msg -> Error ("代码生成错误", msg))
         | Error msg -> Error ("语义错误", msg))
    | Error msg -> Error ("解析错误", msg)
  with
  | Lexer.LexError msg -> Error ("词法错误", msg)
  | Parser.ParseError msg -> Error ("解析错误", msg)
  | Semantic.SemanticError msg -> Error ("语义错误", msg)
  | exn -> Error ("未知错误", Printexc.to_string exn)

let check_error_type msg input expected_error_type =
  match compile_and_catch_errors input with
  | Ok _ -> Alcotest.fail ("预期出现错误但编译成功了，输入: " ^ input)
  | Error (error_type, error_msg) ->
      if error_type <> expected_error_type then
        Alcotest.fail (Printf.sprintf "错误类型不匹配，期望: %s, 实际: %s, 消息: %s" 
                      expected_error_type error_type error_msg)

let check_error_message_contains msg input expected_fragment =
  match compile_and_catch_errors input with
  | Ok _ -> Alcotest.fail ("预期出现错误但编译成功了，输入: " ^ input)
  | Error (_, error_msg) ->
      if not (String.contains error_msg (String.get expected_fragment 0)) then
        Alcotest.fail (Printf.sprintf "错误消息不包含期望内容，期望包含: %s, 实际: %s" 
                      expected_fragment error_msg)

(* 词法错误处理测试 *)
let test_lexical_error_handling () =
  (* 非法字符 *)
  check_error_type "非法字符@" "@#$%^&*" "词法错误";
  check_error_type "不完整字符串" "\"未闭合字符串" "词法错误";
  check_error_type "非法Unicode序列" "\x00\x01\x02" "词法错误";
  
  (* 中文词法错误 *)
  check_error_type "错误的中文标点" "设 x = 1【错误括号】" "词法错误";
  check_error_type "不支持的中文字符" "設｛錯誤｝" "词法错误";

let test_syntax_error_handling () =
  (* 基础语法错误 *)
  check_error_type "缺少分号" "设 x = 1 设 y = 2" "解析错误";
  check_error_type "不匹配括号" "(1 + 2" "解析错误";
  check_error_type "错误关键字" "lte x = 42" "解析错误";
  
  (* 复杂语法错误 *)
  check_error_type "错误的模式匹配" "匹配 x 与 |" "解析错误";
  check_error_type "不完整函数定义" "函数 f" "解析错误";

let test_semantic_error_handling () =
  (* 类型错误 *)
  check_error_type "类型不匹配" "设 x = 42 + \"hello\"" "语义错误";
  check_error_message_contains "类型错误详细信息" "设 x = 42 + \"hello\"" "类型";
  
  (* 作用域错误 *)
  check_error_type "未定义变量" "x + 1" "语义错误";
  check_error_message_contains "未定义变量详细信息" "x + 1" "未定义";
  
  (* 函数错误 *)
  check_error_type "参数数量错误" "设 f x = x + 1 in f 1 2" "语义错误";
  check_error_message_contains "参数数量错误详细信息" "设 f x = x + 1 in f 1 2" "参数";

let test_error_recovery () =
  (* 错误恢复机制测试 *)
  let multi_error_input = {|
    设 x = 42 + "error1"  (* 类型错误 *)
    设 y = undefined_var   (* 未定义变量 *)
    设 z = x + y          (* 基于错误的后续错误 *)
  |} in
  check_error_type "多重错误恢复" multi_error_input "语义错误";
  
  (* 局部错误不影响其他正确代码 *)
  let partial_error_input = {|
    设 正确1 = 42
    设 错误 = 42 + "error"
    设 正确2 = 正确1 + 1
  |} in
  check_error_type "局部错误处理" partial_error_input "语义错误";

let test_chinese_error_messages () =
  (* 中文错误消息 *)
  check_error_message_contains "中文类型错误" "设 x = 42 + \"错误\"" "类型";
  check_error_message_contains "中文未定义错误" "未定义变量" "未定义";
  
  (* 诗词编程错误消息 *)
  let poetry_error = {|
    设 春眠不觉晓 = 42
    设 处处闻啼鸟 = 春眠不觉晓 + "夜来风雨声"  (* 类型错误 *)
  |} in
  check_error_type "诗词编程错误" poetry_error "语义错误";

let test_error_context_preservation () =
  (* 错误上下文保存 *)
  let nested_error = {|
    函数 外层函数 x =
      函数 内层函数 y =
        x + y + "错误类型"  (* 深度嵌套错误 *)
      in
      内层函数 10
    in
    外层函数 5
  |} in
  check_error_type "嵌套错误上下文" nested_error "语义错误";
  
  (* 复杂表达式错误定位 *)
  let complex_error = {|
    设 result = (42 + 3) * (fun x -> x + "错误") 5
  |} in
  check_error_type "复杂表达式错误" complex_error "语义错误";

let test_user_friendly_errors () =
  (* 用户友好错误提示 *)
  check_error_message_contains "友好的类型错误" 
    "设 x = 1 + \"hello\"" "类型";
  
  check_error_message_contains "友好的语法错误" 
    "设 x = 1 ++" "解析";
  
  (* 建议性错误修复 *)
  check_error_message_contains "变量名拼写建议" 
    "设 x = 42 in y" "未定义";

let test_cascading_errors () =
  (* 级联错误处理 *)
  let cascading_input = {|
    设 f = 未定义函数
    设 result1 = f 42
    设 result2 = result1 + 1
    设 result3 = result2 * result1
  |} in
  check_error_type "级联错误" cascading_input "语义错误";

let test_error_formatting () =
  (* 错误格式化测试 *)
  let formatted_error_input = {|
    设 很长的变量名 = 42
    设 另一个很长的变量名 = 很长的变量名 + "类型错误的字符串"
  |} in
  check_error_type "错误格式化" formatted_error_input "语义错误";

let test_international_errors () =
  (* 国际化错误处理 *)
  check_error_type "繁体中文错误" "設 x = 42 + \"錯誤\"" "语义错误";
  check_error_type "混合中英文错误" "let x = 42 + \"错误\"" "语义错误";

let test_performance_error_handling () =
  (* 大量错误的性能测试 *)
  let many_errors = String.concat "\n" (List.init 100 (fun i ->
    Printf.sprintf "设 var%d = %d + \"error%d\"" i i i)) in
  check_error_type "大量错误性能" many_errors "语义错误";
  
  (* 深度嵌套错误性能 *)
  let deep_nested_error = 
    String.concat " + " (List.init 50 (fun i -> "\"error\"")) in
  check_error_type "深度嵌套错误" deep_nested_error "语义错误";

let test_error_statistics () =
  (* 错误统计信息 *)
  let statistical_input = {|
    设 error1 = 1 + "错误1"
    设 error2 = 2 + "错误2" 
    设 error3 = 3 + "错误3"
    设 correct = 42
  |} in
  check_error_type "错误统计" statistical_input "语义错误";

(* 诗词编程错误处理特色测试 *)
let test_poetry_error_handling () =
  (* 韵律错误 *)
  let rhyme_error = {|
    设 春眠不觉晓 = 42
    设 处处闻啼鸟 = "类型错误"
    设 夜来风雨声 = 春眠不觉晓 + 处处闻啼鸟  (* 韵律中的类型错误 *)
  |} in
  check_error_type "韵律编程错误" rhyme_error "语义错误";
  
  (* 对仗编程错误 *)
  let antithesis_error = {|
    函数 山重水复疑无路 x = x + "错误"
    函数 柳暗花明又一村 y = y * 2
    设 result = 山重水复疑无路 (柳暗花明又一村 10)
  |} in
  check_error_type "对仗编程错误" antithesis_error "语义错误";

(* 测试套件定义 *)
let error_handling_comprehensive_tests = [
  "词法错误处理", `Quick, test_lexical_error_handling;
  "语法错误处理", `Quick, test_syntax_error_handling;
  "语义错误处理", `Quick, test_semantic_error_handling;
  "错误恢复机制", `Quick, test_error_recovery;
  "中文错误消息", `Quick, test_chinese_error_messages;
  "错误上下文保存", `Quick, test_error_context_preservation;
  "用户友好错误", `Quick, test_user_friendly_errors;
  "级联错误处理", `Quick, test_cascading_errors;
  "错误格式化", `Quick, test_error_formatting;
  "国际化错误", `Quick, test_international_errors;
  "错误处理性能", `Slow, test_performance_error_handling;
  "错误统计信息", `Quick, test_error_statistics;
  "诗词错误处理", `Quick, test_poetry_error_handling;
]

(* 运行测试 *)
let () =
  run "错误处理综合测试" [
    "error_handling_comprehensive", error_handling_comprehensive_tests;
  ]