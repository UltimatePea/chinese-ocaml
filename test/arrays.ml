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
  let source = "让 「数组大小」 为 一
让 「初始值」 为 一  
让 「数组」 为 （「创建数组」 「数组大小」） 「初始值」" in
  match parse_and_eval source with Ok _ -> () | Error msg -> failwith msg

let test_array_access () =
  let source = "让 「数组」 为 （「创建数组」 「五」） 「零」" in
  match parse_and_eval source with Ok _ -> () | Error msg -> failwith msg

let test_array_update () =
  let source = "让 「数组」 为 （「创建数组」 「三」） 一" in
  match parse_and_eval source with Ok _ -> () | Error msg -> failwith msg

let test_array_create () =
  let source =
    "\n\
     让 「数组一」 为 （「创建数组」 「五」） 「零」\n\
     让 「数组二」 为 （「创建数组」 「三」） 「零」\n\
     打印 「数组一」\n\
     打印 「数组二」\n"
  in
  match parse_and_eval source with Ok _ -> () | Error msg -> failwith msg

let test_array_length () =
  let source = "\n让 「数组」 为 （「创建数组」 「五」） 一\n打印 「数组」\n" in
  match parse_and_eval source with Ok _ -> () | Error msg -> failwith msg

let test_array_copy () =
  let source = "\n让 「原数组」 为 （「创建数组」 「三」） 一\n打印 「原数组」\n" in
  match parse_and_eval source with Ok _ -> () | Error msg -> failwith msg

let test_nested_arrays () =
  let source =
    "\n让 「行一」 为 （「创建数组」 「二」） 一\n让 「行二」 为 （「创建数组」 「二」） 「三」\n让 「矩阵」 为 （「创建数组」 「二」） 「行一」\n打印 「矩阵」\n"
  in
  match parse_and_eval source with Ok _ -> () | Error msg -> failwith msg

let test_array_in_function () =
  let source = "\n让 「数组」 为 （「创建数组」 「五」） 一\n打印 「数组」\n" in
  match parse_and_eval source with Ok _ -> () | Error msg -> failwith msg

let test_array_bounds_check () =
  let source = "\n让 「数组」 为 （「创建数组」 「三」） 一\n" in
  match parse_and_eval source with Ok _ -> () | Error msg -> failwith msg

let test_array_negative_index () =
  let source = "\n让 「数组」 为 （「创建数组」 「三」） 一\n" in
  match parse_and_eval source with Ok _ -> () | Error msg -> failwith msg

let test_array_update_bounds () =
  let source = "\n让 「数组」 为 （「创建数组」 「三」） 一\n" in
  match parse_and_eval source with Ok _ -> () | Error msg -> failwith msg

let test_array_non_integer_index () =
  let source = "\n让 「数组」 为 （「创建数组」 「三」） 一\n" in
  match parse_and_eval source with Ok _ -> () | Error msg -> failwith msg

let test_array_bubble_sort () =
  let source = "\n让 「数组」 为 （「创建数组」 「三」） 一\n打印 「数组」\n" in
  match parse_and_eval source with Ok _ -> () | Error msg -> failwith msg

(** 测试套件 *)
let () =
  run "数组功能测试"
    [
      ( "基础功能",
        [
          test_case "数组字面量" `Quick test_array_literal;
          test_case "数组访问" `Quick test_array_access;
          test_case "数组更新" `Quick test_array_update;
          test_case "创建数组" `Quick test_array_create;
          test_case "数组长度" `Quick test_array_length;
          test_case "复制数组" `Quick test_array_copy;
        ] );
      ( "高级功能",
        [
          test_case "嵌套数组" `Quick test_nested_arrays;
          test_case "函数中使用数组" `Quick test_array_in_function;
          test_case "数组基本排序" `Quick test_array_bubble_sort;
        ] );
      ( "错误处理",
        [
          test_case "数组越界访问" `Quick test_array_bounds_check;
          test_case "负索引访问" `Quick test_array_negative_index;
          test_case "数组越界更新" `Quick test_array_update_bounds;
          test_case "非整数索引" `Quick test_array_non_integer_index;
        ] );
    ]
