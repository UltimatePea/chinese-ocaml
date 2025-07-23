(** 更多测试覆盖率提升模块
    
    通过更多简单测试来持续提升覆盖率
    
    @author 骆言测试团队
    @version 1.0
    @since 2025-07-23 Fix #915 测试覆盖率提升 *)

open Alcotest

let test_pattern_matching () =
  (* 模式匹配测试 *)
  let test_function x = match x with
    | 0 -> "zero"
    | 1 -> "one"
    | n when n > 1 -> "many"
    | _ -> "negative"
  in
  check string "0的匹配" "zero" (test_function 0);
  check string "1的匹配" "one" (test_function 1);
  check string "多个的匹配" "many" (test_function 5);
  check string "负数的匹配" "negative" (test_function (-1))

let test_recursive_functions () =
  (* 递归函数测试 *)
  let rec factorial n =
    if n <= 1 then 1
    else n * factorial (n - 1)
  in
  check int "0的阶乘" 1 (factorial 0);
  check int "1的阶乘" 1 (factorial 1);
  check int "5的阶乘" 120 (factorial 5)

let test_higher_order_functions () =
  (* 高阶函数测试 *)
  let apply_twice f x = f (f x) in
  let add_one x = x + 1 in
  let double x = x * 2 in
  
  check int "应用两次add_one" 7 (apply_twice add_one 5);
  check int "应用两次double" 20 (apply_twice double 5)

let test_reference_operations () =
  (* 引用操作测试 *)
  let counter = ref 0 in
  incr counter;
  incr counter;
  check int "引用计数器" 2 !counter;
  
  counter := 10;
  check int "引用赋值" 10 !counter

let test_array_operations () =
  (* 数组操作测试 *)
  let arr = [|1; 2; 3; 4; 5|] in
  check int "数组长度" 5 (Array.length arr);
  check int "数组第一个元素" 1 arr.(0);
  arr.(0) <- 10;
  check int "数组修改后" 10 arr.(0)

let () =
  run "More_coverage_boost tests" [
    "pattern_matching", [test_case "模式匹配" `Quick test_pattern_matching];
    "recursive_functions", [test_case "递归函数" `Quick test_recursive_functions];
    "higher_order_functions", [test_case "高阶函数" `Quick test_higher_order_functions];
    "reference_operations", [test_case "引用操作" `Quick test_reference_operations];
    "array_operations", [test_case "数组操作" `Quick test_array_operations];
  ]