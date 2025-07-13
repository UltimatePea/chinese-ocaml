(* 斐波那契数列性能基准测试 - OCaml版本 *)

(* 经典递归实现 *)
let rec classic_fibonacci n =
  match n with
  | 0 -> 0
  | 1 -> 1
  | _ -> classic_fibonacci (n - 1) + classic_fibonacci (n - 2)

(* 尾递归实现 *)
let tail_recursive_fibonacci n =
  let rec aux i a b =
    if i <= 0 then
      a
    else
      aux (i - 1) b (a + b)
  in
  aux n 0 1

(* 迭代实现 *)
let iterative_fibonacci n =
  if n <= 1 then
    n
  else
    let rec loop i prev2 prev1 =
      if i >= n then
        prev1
      else
        loop (i + 1) prev1 (prev1 + prev2)
    in
    loop 2 0 1

(* 批量计算测试 *)
let batch_fibonacci impl upper_limit =
  let rec calculate_batch i acc =
    if i > upper_limit then
      acc
    else
      calculate_batch (i + 1) (acc + impl i)
  in
  calculate_batch 1 0

(* 性能测试函数 *)
let performance_test impl_name impl_func test_value =
  Printf.printf "开始 %s 性能测试\n" impl_name;
  
  (* 单个值计算测试 *)
  let result1 = impl_func test_value in
  Printf.printf "%s(%d) = %d\n" impl_name test_value result1;
  
  (* 批量计算测试 *)
  let result2 = batch_fibonacci impl_func (test_value - 5) in
  Printf.printf "%s 批量计算结果: %d\n" impl_name result2;
  
  result1 + result2

(* 综合性能对比 *)
let comprehensive_test test_scale =
  Printf.printf "=== 斐波那契数列性能基准测试 ===\n";
  Printf.printf "测试规模: %d\n" test_scale;
  
  (* 经典递归测试 *)
  let classic_result = performance_test "经典递归" classic_fibonacci test_scale in
  
  (* 尾递归测试 *)
  let tail_recursive_result = performance_test "尾递归" tail_recursive_fibonacci (test_scale + 10) in
  
  (* 迭代测试 *)
  let iterative_result = performance_test "迭代实现" iterative_fibonacci (test_scale + 10) in
  
  Printf.printf "=== 性能测试完成 ===\n";
  Printf.printf "经典递归总分: %d\n" classic_result;
  Printf.printf "尾递归总分: %d\n" tail_recursive_result;
  Printf.printf "迭代实现总分: %d\n" iterative_result;
  
  classic_result + tail_recursive_result + iterative_result

(* 执行基准测试 *)
let () =
  let test_scale = 25 in
  let final_result = comprehensive_test test_scale in
  Printf.printf "斐波那契基准测试完成，总分: %d\n" final_result