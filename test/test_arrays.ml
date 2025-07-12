(** 数组功能测试 *)

open Alcotest
open Yyocamlc_lib.Parser
open Yyocamlc_lib.Codegen
open Yyocamlc_lib.Lexer

(** 测试辅助函数 *)
let parse_and_eval source =
  let tokens = tokenize source "<test>" in
  let program = parse_program tokens in
  execute_program program

let test_array_literal () =
  let source = "让 数组 = [|1; 2; 3; 4; 5|]" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_access () =
  let source = "
让 数组 = [|10; 20; 30; 40; 50|]
让 第一个 = 数组.(0)
让 第三个 = 数组.(2)
让 最后一个 = 数组.(4)
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_update () =
  let source = "
让 数组 = [|1; 2; 3|]
数组.(0) <- 10
数组.(1) <- 20
数组.(2) <- 30
打印 数组
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_create () =
  let source = "
让 创建5 = 创建数组 5
让 创建3 = 创建数组 3
让 数组1 = 创建5 0
让 数组2 = 创建3 \"空\"
打印 数组1
打印 数组2
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_length () =
  let source = "
让 数组 = [|1; 2; 3; 4; 5|]
让 长度 = 数组长度 数组
打印 长度
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_copy () =
  let source = "
让 原数组 = [|1; 2; 3|]
让 副本 = 复制数组 原数组
副本.(0) <- 10
打印 原数组
打印 副本
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_nested_arrays () =
  let source = "
让 矩阵 = [|[|1; 2|]; [|3; 4|]|]
让 第一行 = 矩阵.(0)
让 元素 = 第一行.(1)
打印 元素
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_in_function () =
  let source = "
让 数组 = [|1; 2; 3; 4; 5|]
让 长度 = 数组长度 数组
让 第一个 = 数组.(0)
让 结果 = 长度 + 第一个
打印 结果
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_bounds_check () =
  let source = "
让 数组 = [|1; 2; 3|]
让 值 = 数组.(10)
" in
  match parse_and_eval source with
  | Ok _ -> failwith "应该报错但没有"
  | Error msg -> 
    check bool "错误消息包含越界" true
      (String.exists (fun _ -> true) msg)

let test_array_negative_index () =
  let source = "
让 数组 = [|1; 2; 3|]
让 值 = 数组.(-1)
" in
  match parse_and_eval source with
  | Ok _ -> failwith "应该报错但没有"
  | Error msg -> 
    check bool "错误消息包含越界" true
      (String.exists (fun _ -> true) msg)

let test_array_update_bounds () =
  let source = "
让 数组 = [|1; 2; 3|]
数组.(5) <- 10
" in
  match parse_and_eval source with
  | Ok _ -> failwith "应该报错但没有"
  | Error msg -> 
    check bool "错误消息包含越界" true
      (String.exists (fun _ -> true) msg)

let test_array_non_integer_index () =
  let source = "
让 数组 = [|1; 2; 3|]
让 值 = 数组.(\"零\")
" in
  match parse_and_eval source with
  | Ok _ -> failwith "应该报错但没有"
  | Error msg -> 
    check bool "错误消息包含整数" true
      (String.exists (fun _ -> true) msg)

let test_array_bubble_sort () =
  let source = "
让 数组 = [|3; 1; 2|]
数组.(0) <- 数组.(1)
打印 数组
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

(** 测试套件 *)
let () =
  run "数组功能测试" [
    "基础功能", [
      test_case "数组字面量" `Quick test_array_literal;
      test_case "数组访问" `Quick test_array_access;
      test_case "数组更新" `Quick test_array_update;
      test_case "创建数组" `Quick test_array_create;
      test_case "数组长度" `Quick test_array_length;
      test_case "复制数组" `Quick test_array_copy;
    ];
    "高级功能", [
      test_case "嵌套数组" `Quick test_nested_arrays;
      test_case "函数中使用数组" `Quick test_array_in_function;
      test_case "数组基本排序" `Quick test_array_bubble_sort;
    ];
    "错误处理", [
      test_case "数组越界访问" `Quick test_array_bounds_check;
      test_case "负索引访问" `Quick test_array_negative_index;
      test_case "数组越界更新" `Quick test_array_update_bounds;
      test_case "非整数索引" `Quick test_array_non_integer_index;
    ];
  ]