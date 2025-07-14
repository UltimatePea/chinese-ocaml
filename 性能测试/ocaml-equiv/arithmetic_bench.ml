(* 算术运算性能基准测试 - OCaml版本 *)

(* 基础算术运算测试 *)
let rec arithmetic_test n =
  if n <= 0 then 0
  else
    let a = n + 1 in
    let b = n * 2 in
    let c = n - 1 in
    let d = n / 2 in
    let e = n mod 3 in
    a + b + c + d + e + arithmetic_test (n - 1)

(* 大整数计算测试 *)
let rec big_number_ops n =
  if n <= 1 then n
  else
    let prev1 = big_number_ops (n - 1) in
    let prev2 = big_number_ops (n - 2) in
    ((prev1 * 3) + (prev2 * 2)) mod 10000

(* 浮点数运算测试 *)
let float_test n =
  let result = ref 0.0 in
  let rec loop i acc = if i <= 0 then acc else loop (i - 1) (acc +. (1.0 /. 1.5 *. 2.3)) in
  loop n !result

(* 主测试函数 *)
let run_test scale =
  Printf.printf "开始算术运算性能测试\n";

  (* 整数运算测试 *)
  let start_time1 = Sys.time () in
  let result1 = arithmetic_test scale in
  let end_time1 = Sys.time () in

  Printf.printf "整数运算测试完成\n";
  Printf.printf "结果: %d\n" result1;
  Printf.printf "耗时: %f秒\n" (end_time1 -. start_time1);

  (* 大数运算测试 *)
  let start_time2 = Sys.time () in
  let result2 = big_number_ops (scale / 2) in
  let end_time2 = Sys.time () in

  Printf.printf "大数运算测试完成\n";
  Printf.printf "结果: %d\n" result2;
  Printf.printf "耗时: %f秒\n" (end_time2 -. start_time2);

  result1 + result2

(* 执行基准测试 *)
let () =
  let test_scale = 1000 in
  let final_result = run_test test_scale in
  Printf.printf "基准测试完成，总结果: %d\n" final_result
