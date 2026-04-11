(* 骆言编译输出 *)


(* 骆言标准库 — 输出模块

    提供终端输入输出函数。
    用法：引入 『骆言/输出.ly』
    访问：「输出」之「行」，「输出」之「格式」，等 *)

module Luo__e8be93e587ba = struct
  let luo__e8a18c    = print_endline
  let luo__e68993e58db0  = print_string
  let luo__e695b4e695b0  = print_int
  let luo__e6b5aee782b9  = print_float
  let luo__e68da2e8a18c  = print_newline
  let luo__e6a0bce5bc8f  = Printf.printf
  let luo__e6a0bce5bc8fe4b8b2= Printf.sprintf
  let luo__e8afbbe8a18c  = read_line
end



(* 骆言标准库 — 列表模块

    提供列表操作函数，对应 OCaml 的 List 模块。
    用法：引入 『骆言/列表.ly』
    访问：「列表」之「映射」，「列表」之「左折」，等 *)

module Luo__e58897e8a1a8 = struct
  let luo__e995bfe5baa6  = List.length
  let luo__e698a0e5b084  = List.map
  let luo__e8bf87e6bba4  = List.filter
  let luo__e5b7a6e68a98  = List.fold_left
  let luo__e58fb3e68a98  = List.fold_right
  let luo__e58f8de8bdac  = List.rev
  let luo__e68bbce68ea5  = List.append
  let luo__e9818de58e86  = List.iter
  let luo__e69fa5e689be  = List.find
  let luo__e68e92e5ba8f  = List.sort
  let luo__e5a4b4    = List.hd
  let luo__e5b0be    = List.tl
  let luo__e5ad98e59ca8  = List.exists
  let luo__e585a8e983a8  = List.for_all
  let luo__e7bb84e59088  = List.combine
  let luo__e5b195e5b9b3  = List.concat
end



(* 列表操作示例 *)

let luo__e695b0e58897 = [1;2;3;4;5]

let luo__e5b9b3e696b9e58897e8a1a8 = Luo__e58897e8a1a8.luo__e698a0e5b084 (fun x -> x * x) luo__e695b0e58897

let luo__e680bbe5928c = Luo__e58897e8a1a8.luo__e5b7a6e68a98 (+) 0 luo__e695b0e58897

let () =
  Luo__e8be93e587ba.luo__e68993e58db0 "原列表：";
  Luo__e58897e8a1a8.luo__e9818de58e86 (fun x -> Luo__e8be93e587ba.luo__e6a0bce5bc8f "%d " x) luo__e695b0e58897;
  Luo__e8be93e587ba.luo__e68da2e8a18c ();
  Luo__e8be93e587ba.luo__e68993e58db0 "平方列表：";
  Luo__e58897e8a1a8.luo__e9818de58e86 (fun x -> Luo__e8be93e587ba.luo__e6a0bce5bc8f "%d " x) luo__e5b9b3e696b9e58897e8a1a8;
  Luo__e8be93e587ba.luo__e68da2e8a18c ();
  Luo__e8be93e587ba.luo__e6a0bce5bc8f "总和：%d\n" luo__e680bbe5928c
