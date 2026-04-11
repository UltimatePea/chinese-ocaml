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



(* 你好世界 — 骆言第一个程序 *)

(* let () = 输出.行 "你好，世界！" *)
let () = Luo__e8be93e587ba.luo__e8a18c "你好，世界！"
