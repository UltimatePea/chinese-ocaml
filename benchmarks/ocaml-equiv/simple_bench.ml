(* 简化算术运算基准测试 - OCaml版本 *)

(* 递归累加测试 *)
let rec cumulative_sum n =
  if n <= 0 then
    0
  else
    n + cumulative_sum (n - 1)

(* 递归累乘测试 *)  
let rec cumulative_product n =
  if n <= 1 then
    1
  else
    n * cumulative_product (n - 1)

(* 执行测试 *)
let test_scale = 20;;
Printf.printf "开始基准测试\n";;

let result1 = cumulative_sum test_scale;;
Printf.printf "累加结果:\n";;
Printf.printf "%d\n" result1;;

let result2 = cumulative_product 8;;
Printf.printf "累乘结果:\n";;
Printf.printf "%d\n" result2;;

let total_result = result1 + result2;;
Printf.printf "总结果:\n";;
Printf.printf "%d\n" total_result;;