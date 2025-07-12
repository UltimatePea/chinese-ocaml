(** 标准库功能测试 *)

open Alcotest
open Yyocamlc_lib.Parser
open Yyocamlc_lib.Codegen
open Yyocamlc_lib.Lexer

(** 测试辅助函数 *)
let parse_and_eval source =
  let tokens = tokenize source "<test>" in
  let program = parse_program tokens in
  execute_program program

(** 数学函数测试 *)
let test_math_functions () =
  (* 测试对数函数 *)
  let source1 = "让 结果 = 对数 10" in
  (match parse_and_eval source1 with
   | Ok _ -> ()
   | Error msg -> failwith msg);
   
  (* 测试三角函数 *)
  let source2 = "让 结果 = 正切 0.5" in
  (match parse_and_eval source2 with
   | Ok _ -> ()
   | Error msg -> failwith msg);
   
  (* 测试取整函数 *)
  let source3 = "让 结果 = 向上取整 3.2" in
  (match parse_and_eval source3 with
   | Ok _ -> ()
   | Error msg -> failwith msg);
   
  (* 测试最大公约数 *)
  let source4 = "让 结果 = 最大公约数 12 18" in
  (match parse_and_eval source4 with
   | Ok _ -> ()
   | Error msg -> failwith msg)

(** 字符串函数测试 *)
let test_string_functions () =
  (* 测试字符串连接 *)
  let source1 = "让 结果 = 字符串连接 \"你好\" \"世界\"" in
  (match parse_and_eval source1 with
   | Ok _ -> ()
   | Error msg -> failwith msg);
   
  (* 测试大写转换 *)
  let source2 = "让 结果 = 大写转换 \"hello\"" in
  (match parse_and_eval source2 with
   | Ok _ -> ()
   | Error msg -> failwith msg);
   
  (* 测试字符串分割 *)
  let source3 = "让 结果 = 字符串分割 \"a,b,c\" \",\"" in
  (match parse_and_eval source3 with
   | Ok _ -> ()
   | Error msg -> failwith msg);
   
  (* 测试去除空白 *)
  let source4 = "让 结果 = 去除空白 \"  hello  \"" in
  (match parse_and_eval source4 with
   | Ok _ -> ()
   | Error msg -> failwith msg)

(** 类型转换函数测试 *)
let test_conversion_functions () =
  (* 测试整数到字符串 *)
  let source1 = "让 结果 = 整数到字符串 42" in
  (match parse_and_eval source1 with
   | Ok _ -> ()
   | Error msg -> failwith msg);
   
  (* 测试字符串到整数 *)
  let source2 = "让 结果 = 字符串到整数 \"123\"" in
  (match parse_and_eval source2 with
   | Ok _ -> ()
   | Error msg -> failwith msg);
   
  (* 测试浮点数到字符串 *)
  let source3 = "让 结果 = 浮点数到字符串 3.14" in
  (match parse_and_eval source3 with
   | Ok _ -> ()
   | Error msg -> failwith msg);
   
  (* 测试字符串到浮点数 *)
  let source4 = "让 结果 = 字符串到浮点数 \"2.71\"" in
  (match parse_and_eval source4 with
   | Ok _ -> ()
   | Error msg -> failwith msg)

(** 高级数学函数测试 *)
let test_advanced_math () =
  (* 测试指数函数 *)
  let source1 = "让 结果 = 指数 1.0" in
  (match parse_and_eval source1 with
   | Ok _ -> ()
   | Error msg -> failwith msg);
   
  (* 测试反三角函数 *)
  let source2 = "让 结果 = 反正弦 0.5" in
  (match parse_and_eval source2 with
   | Ok _ -> ()
   | Error msg -> failwith msg);
   
  (* 测试十进制对数 *)
  let source3 = "让 结果 = 十进制对数 100" in
  (match parse_and_eval source3 with
   | Ok _ -> ()
   | Error msg -> failwith msg)

(** 字符串高级操作测试 *)
let test_advanced_string () =
  (* 测试字符串替换 *)
  let source1 = "让 结果 = 字符串替换 \"hello world\" \"world\" \"universe\"" in
  (match parse_and_eval source1 with
   | Ok _ -> ()
   | Error msg -> failwith msg);
   
  (* 测试子字符串 *)
  let source2 = "让 结果 = 子字符串 \"hello\" 1 3" in
  (match parse_and_eval source2 with
   | Ok _ -> ()
   | Error msg -> failwith msg);
   
  (* 测试字符串比较 *)
  let source3 = "让 结果 = 字符串比较 \"abc\" \"def\"" in
  (match parse_and_eval source3 with
   | Ok _ -> ()
   | Error msg -> failwith msg)

(** 数学运算组合测试 *)
let test_math_combinations () =
  let source = "
  让 角度 = 3.14159 / 4.0
  让 正弦值 = 正弦 角度
  让 余弦值 = 余弦 角度
  让 平方根值 = 平方根 2.0
  让 对数值 = 对数 10.0
  让 指数值 = 指数 1.0
  " in
  (match parse_and_eval source with
   | Ok _ -> ()
   | Error msg -> failwith msg)

(** 字符串处理综合测试 *)
let test_string_processing () =
  let source = "
  让 原始 = \"  Hello World  \"
  让 去空白 = 去除空白 原始
  让 大写 = 大写转换 去空白
  " in
  (match parse_and_eval source with
   | Ok _ -> ()
   | Error msg -> failwith msg)

(** 错误处理测试 *)
let test_error_handling () =
  (* 测试负数平方根 *)
  let source1 = "让 结果 = 平方根 -1" in
  (match parse_and_eval source1 with
   | Ok _ -> failwith "应该产生错误"
   | Error _ -> ());
   
  (* 测试除零的对数 *)
  let source2 = "让 结果 = 对数 0" in
  (match parse_and_eval source2 with
   | Ok _ -> failwith "应该产生错误"
   | Error _ -> ());
   
  (* 测试无效字符串转换 *)
  let source3 = "让 结果 = 字符串到整数 \"abc\"" in
  (match parse_and_eval source3 with
   | Ok _ -> failwith "应该产生错误"
   | Error _ -> ())

(** 测试套件 *)
let () =
  run "标准库功能测试" [
    "数学函数", [
      test_case "基础数学函数" `Quick test_math_functions;
      test_case "高级数学函数" `Quick test_advanced_math;
      test_case "数学运算组合" `Quick test_math_combinations;
    ];
    "字符串函数", [
      test_case "基础字符串函数" `Quick test_string_functions;
      test_case "高级字符串操作" `Quick test_advanced_string;
      test_case "字符串处理综合" `Quick test_string_processing;
    ];
    "类型转换", [
      test_case "基础类型转换" `Quick test_conversion_functions;
    ];
    "错误处理", [
      test_case "数学函数错误处理" `Quick test_error_handling;
    ];
  ]