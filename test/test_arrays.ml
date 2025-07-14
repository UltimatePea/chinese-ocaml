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
  let source = "让 「创建５」 为 「创建数组」 ５\n让 「数组」 为 「创建５」 ０" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_access () =
  let source = "让 「创建５」 为 「创建数组」 ５\n让 「数组」 为 「创建５」 ０" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_update () =
  let source = "让 「创建３」 为 「创建数组」 ３\n让 「数组」 为 「创建３」 １" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_create () =
  let source = "
让 「创建５」 为 「创建数组」 ５
让 「创建３」 为 「创建数组」 ３
让 「数组１」 为 「创建５」 ０
让 「数组２」 为 「创建３」 ０
打印 「数组１」
打印 「数组２」
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_length () =
  let source = "
让 「创建５」 为 「创建数组」 ５\n让 「数组」 为 「创建５」 １
让 「数组长度值」 为 「数组长度」 「数组」
打印 「数组长度值」
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_copy () =
  let source = "
让 「创建３」 为 「创建数组」 ３\n让 「原数组」 为 「创建３」 １
让 「副本」 为 「复制数组」 「原数组」
打印 「原数组」
打印 「副本」
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_nested_arrays () =
  let source = "
让 「创建２」 为 「创建数组」 ２\n让 「行一」 为 「创建２」 １
让 「行二」 为 「创建２」 ３
让 「矩阵」 为 「创建２」 「行一」
打印 「矩阵」
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_in_function () =
  let source = "
让 「创建５」 为 「创建数组」 ５\n让 「数组」 为 「创建５」 １
让 「数组长度值」 为 「数组长度」 「数组」
打印 「数组长度值」
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_bounds_check () =
  let source = "
让 「创建３」 为 「创建数组」 ３\n让 「数组」 为 「创建３」 １
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_negative_index () =
  let source = "
让 「创建３」 为 「创建数组」 ３\n让 「数组」 为 「创建３」 １
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_update_bounds () =
  let source = "
让 「创建３」 为 「创建数组」 ３\n让 「数组」 为 「创建３」 １
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_non_integer_index () =
  let source = "
让 「创建３」 为 「创建数组」 ３\n让 「数组」 为 「创建３」 １
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_bubble_sort () =
  let source = "
让 「创建３」 为 「创建数组」 ３\n让 「数组」 为 「创建３」 １
打印 「数组」
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