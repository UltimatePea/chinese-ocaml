(* 斐波那契基准测试 - OCaml版本 *)

(* 经典递归实现 *)
let rec fibonacci n =
  match n with
  | 0 -> 0
  | 1 -> 1
  | _ -> fibonacci (n - 1) + fibonacci (n - 2)

(* 执行测试 *)
let () = Printf.printf "斐波那契基准测试\n";;

let small_value = fibonacci 15;;
Printf.printf "斐波那契(15):\n";;
Printf.printf "%d\n" small_value;;

let medium_value = fibonacci 20;;
Printf.printf "斐波那契(20):\n";;
Printf.printf "%d\n" medium_value;;

let large_value = fibonacci 25;;
Printf.printf "斐波那契(25):\n";;
Printf.printf "%d\n" large_value;;

let total_score = small_value + medium_value + large_value;;
Printf.printf "总分:\n";;
Printf.printf "%d\n" total_score;;