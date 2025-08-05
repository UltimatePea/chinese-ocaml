(* 
 * 尾递归优化验证测试
 * 
 * Author: Whisky, PR Worker  
 * 测试目标: 验证骆言列表函数的尾递归优化实现
 *)

open Printf
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_collections

(* 简单的栈溢出测试 *)
let test_tail_recursion_stack_safety () =
  printf "=== 尾递归栈溢出保护测试 ===\n";
  
  (* 创建大列表 *)
  let large_size = 100000 in
  let rec create_list acc n =
    if n <= 0 then acc
    else create_list (IntValue n :: acc) (n - 1)
  in
  let large_list = ListValue (create_list [] large_size) in
  printf "创建%d元素列表: 成功\n" large_size;
  
  try
    (* 测试映射函数 *)
    let map_func = List.assoc "映射" collection_functions in
    let double_func = BuiltinFunctionValue (fun args -> 
      match args with [IntValue x] -> IntValue (x * 2) | _ -> failwith "double error") in
    let partial_map = (match map_func with 
      | BuiltinFunctionValue f -> f [double_func] 
      | _ -> failwith "not a function") in
    let _ = (match partial_map with 
      | BuiltinFunctionValue f -> f [large_list] 
      | _ -> failwith "not a function") in
    printf "映射函数: 栈溢出保护成功 ✅\n";
    
    (* 测试过滤函数 *)
    let filter_func = List.assoc "过滤" collection_functions in
    let even_func = BuiltinFunctionValue (fun args -> 
      match args with [IntValue x] -> BoolValue (x mod 2 = 0) | _ -> failwith "even error") in
    let partial_filter = (match filter_func with 
      | BuiltinFunctionValue f -> f [even_func] 
      | _ -> failwith "not a function") in
    let _ = (match partial_filter with 
      | BuiltinFunctionValue f -> f [large_list] 
      | _ -> failwith "not a function") in
    printf "过滤函数: 栈溢出保护成功 ✅\n";
    
    (* 测试连接函数 *)
    let concat_func = List.assoc "连接" collection_functions in
    let half_list = ListValue (create_list [] (large_size / 2)) in
    let partial_concat = (match concat_func with 
      | BuiltinFunctionValue f -> f [half_list] 
      | _ -> failwith "not a function") in
    let _ = (match partial_concat with 
      | BuiltinFunctionValue f -> f [half_list] 
      | _ -> failwith "not a function") in
    printf "连接函数: 栈溢出保护成功 ✅\n";
    
    printf "\n✅ 所有尾递归优化测试通过!\n\n"
  with
  | Stack_overflow -> printf "\n❌ 检测到栈溢出 - 尾递归优化失败!\n\n"
  | e -> printf "\n❌ 其他错误: %s\n\n" (Printexc.to_string e)

let run_tests () =
  printf "骆言列表函数尾递归优化验证测试\n";
  printf "Issue #2190 修复验证\n";
  printf "Author: Whisky, PR Worker\n";
  printf "================================\n\n";
  
  test_tail_recursion_stack_safety ();
  
  printf "验证测试完成!\n"

let () = run_tests ()