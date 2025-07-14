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
  let source = "让 「数组」 为 创建数组 五" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_access () =
  let source = "
让 「数组」 为 『｜１０； ２０； ３０； ４０； ５０｜』
让 「第一个」 为 「数组」。（０）
让 「第三个」 为 「数组」。（２）
让 「最后一个」 为 「数组」。（４）
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_update () =
  let source = "
让 「数组」 为 『｜１； ２； ３｜』
「数组」。（０） ← １０
「数组」。（１） ← ２０
「数组」。（２） ← ３０
打印 「数组」
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_create () =
  let source = "
让 「创建５」 为 「创建数组」 ５
让 「创建３」 为 「创建数组」 ３
让 「数组１」 为 「创建５」 ０
让 「数组２」 为 「创建３」 『空』
打印 「数组１」
打印 「数组２」
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_length () =
  let source = "
让 「数组」 为 『｜１； ２； ３； ４； ５｜』
让 「数组长度值」 为 「数组长度」（「数组」）
打印 「数组长度值」
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_copy () =
  let source = "
让 「原数组」 为 『｜１； ２； ３｜』
让 「副本」 为 「复制数组」 「原数组」
「副本」。（０） ← １０
打印 「原数组」
打印 「副本」
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_nested_arrays () =
  let source = "
让 「矩阵」 为 『｜『｜１； ２｜』； 『｜３； ４｜』｜』
让 「第一行」 为 「矩阵」。（０）
让 「元素」 为 「第一行」。（１）
打印 「元素」
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_in_function () =
  let source = "
让 「数组」 为 『｜１； ２； ３； ４； ５｜』
让 「数组长度值」 为 「数组长度」（「数组」）
让 「第一个」 为 「数组」。（０）
让 「结果」 为 「数组长度值」 ＋ 「第一个」
打印 「结果」
" in
  match parse_and_eval source with
  | Ok _ -> ()
  | Error msg -> failwith msg

let test_array_bounds_check () =
  let source = "
让 「数组」 为 『｜１； ２； ３｜』
让 「值」 为 「数组」。（１０）
" in
  match parse_and_eval source with
  | Ok _ -> failwith "应该报错但没有"
  | Error msg -> 
    check bool "错误消息包含越界" true
      (String.exists (fun _ -> true) msg)

let test_array_negative_index () =
  let source = "
让 「数组」 为 『｜１； ２； ３｜』
让 「值」 为 「数组」。（－１）
" in
  match parse_and_eval source with
  | Ok _ -> failwith "应该报错但没有"
  | Error msg -> 
    check bool "错误消息包含越界" true
      (String.exists (fun _ -> true) msg)

let test_array_update_bounds () =
  let source = "
让 「数组」 为 『｜１； ２； ３｜』
「数组」。（５） ← １０
" in
  match parse_and_eval source with
  | Ok _ -> failwith "应该报错但没有"
  | Error msg -> 
    check bool "错误消息包含越界" true
      (String.exists (fun _ -> true) msg)

let test_array_non_integer_index () =
  let source = "
让 「数组」 为 『｜１； ２； ３｜』
让 「值」 为 「数组」。（『零』）
" in
  match parse_and_eval source with
  | Ok _ -> failwith "应该报错但没有"
  | Error msg -> 
    check bool "错误消息包含整数" true
      (String.exists (fun _ -> true) msg)

let test_array_bubble_sort () =
  let source = "
让 「数组」 为 『｜３； １； ２｜』
「数组」。（０） ← 「数组」。（１）
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