(* 骆言编译输出 *)


(* 骆言标准库 — 输出模块

    提供终端输入输出函数。
    用法：引入 『骆言/输出.ly』
    访问：「输出」之「行」，「输出」之「格式」，等 *)

(* module 输出 = struct *)
module Luo__e8be93e587ba = struct
  (* let 行    = print_endline *)
  let luo__e8a18c    = print_endline
  (* let 打印  = print_string *)
  let luo__e68993e58db0  = print_string
  (* let 整数  = print_int *)
  let luo__e695b4e695b0  = print_int
  (* let 浮点  = print_float *)
  let luo__e6b5aee782b9  = print_float
  (* let 换行  = print_newline *)
  let luo__e68da2e8a18c  = print_newline
  (* let 格式  = Printf.printf *)
  let luo__e6a0bce5bc8f  = Printf.printf
  (* let 格式串= Printf.sprintf *)
  let luo__e6a0bce5bc8fe4b8b2= Printf.sprintf
  (* let 读行  = read_line *)
  let luo__e8afbbe8a18c  = read_line
end



(* 骆言标准库 — 列表模块

    提供列表操作函数，对应 OCaml 的 List 模块。
    用法：引入 『骆言/列表.ly』
    访问：「列表」之「映射」，「列表」之「左折」，等 *)

(* module 列表 = struct *)
module Luo__e58897e8a1a8 = struct
  (* let 长度  = List.length *)
  let luo__e995bfe5baa6  = List.length
  (* let 映射  = List.map *)
  let luo__e698a0e5b084  = List.map
  (* let 过滤  = List.filter *)
  let luo__e8bf87e6bba4  = List.filter
  (* let 左折  = List.fold_left *)
  let luo__e5b7a6e68a98  = List.fold_left
  (* let 右折  = List.fold_right *)
  let luo__e58fb3e68a98  = List.fold_right
  (* let 反转  = List.rev *)
  let luo__e58f8de8bdac  = List.rev
  (* let 拼接  = List.append *)
  let luo__e68bbce68ea5  = List.append
  (* let 遍历  = List.iter *)
  let luo__e9818de58e86  = List.iter
  (* let 查找  = List.find *)
  let luo__e69fa5e689be  = List.find
  (* let 排序  = List.sort *)
  let luo__e68e92e5ba8f  = List.sort
  (* let 头    = List.hd *)
  let luo__e5a4b4    = List.hd
  (* let 尾    = List.tl *)
  let luo__e5b0be    = List.tl
  (* let 存在  = List.exists *)
  let luo__e5ad98e59ca8  = List.exists
  (* let 全部  = List.for_all *)
  let luo__e585a8e983a8  = List.for_all
  (* let 组合  = List.combine *)
  let luo__e7bb84e59088  = List.combine
  (* let 展平  = List.concat *)
  let luo__e5b195e5b9b3  = List.concat
end



(* 列表操作示例 *)

(* let 数列 = [1;2;3;4;5] *)
let luo__e695b0e58897 = [1;2;3;4;5]

(* let 平方列表 = 列表.映射 (fun x -> x * x) 数列 *)
let luo__e5b9b3e696b9e58897e8a1a8 = Luo__e58897e8a1a8.luo__e698a0e5b084 (fun x -> x * x) luo__e695b0e58897

(* let 总和 = 列表.左折 (+) 0 数列 *)
let luo__e680bbe5928c = Luo__e58897e8a1a8.luo__e5b7a6e68a98 (+) 0 luo__e695b0e58897

let () =
  (* 输出.打印 "原列表："; *)
  Luo__e8be93e587ba.luo__e68993e58db0 "原列表：";
  (* 列表.遍历 (fun x -> 输出.格式 "%d " x) 数列; *)
  Luo__e58897e8a1a8.luo__e9818de58e86 (fun x -> Luo__e8be93e587ba.luo__e6a0bce5bc8f "%d " x) luo__e695b0e58897;
  (* 输出.换行 (); *)
  Luo__e8be93e587ba.luo__e68da2e8a18c ();
  (* 输出.打印 "平方列表："; *)
  Luo__e8be93e587ba.luo__e68993e58db0 "平方列表：";
  (* 列表.遍历 (fun x -> 输出.格式 "%d " x) 平方列表; *)
  Luo__e58897e8a1a8.luo__e9818de58e86 (fun x -> Luo__e8be93e587ba.luo__e6a0bce5bc8f "%d " x) luo__e5b9b3e696b9e58897e8a1a8;
  (* 输出.换行 (); *)
  Luo__e8be93e587ba.luo__e68da2e8a18c ();
  (* 输出.格式 "总和：%d\n" 总和 *)
  Luo__e8be93e587ba.luo__e6a0bce5bc8f "总和：%d\n" luo__e680bbe5928c
