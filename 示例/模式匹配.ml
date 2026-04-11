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



(* 骆言标准库 — 基础模块

    提供顶层工具绑定（比较、类型转换、引用等）。
    用法：引入 『骆言/基础.ly』 *)

(* 比较与数学 *)
(* let 最大         = max *)
let luo__e69c80e5a4a7         = max
(* let 最小         = min *)
let luo__e69c80e5b08f         = min
(* let 绝对值       = abs *)
let luo__e7bb9de5afb9e580bc       = abs
(* let 比较         = compare *)
let luo__e6af94e8be83         = compare

(* 引用与副作用 *)
(* let 引用         = ref *)
let luo__e5bc95e794a8         = ref
(* let 忽略         = ignore *)
let luo__e5bfbde795a5         = ignore

(* 类型转换 *)
(* let 整数转字符串 = string_of_int *)
let luo__e695b4e695b0e8bdace5ad97e7aca6e4b8b2 = string_of_int
(* let 浮点转字符串 = string_of_float *)
let luo__e6b5aee782b9e8bdace5ad97e7aca6e4b8b2 = string_of_float
(* let 字符串转整数 = int_of_string *)
let luo__e5ad97e7aca6e4b8b2e8bdace695b4e695b0 = int_of_string
(* let 字符串转浮点 = float_of_string *)
let luo__e5ad97e7aca6e4b8b2e8bdace6b5aee782b9 = float_of_string
(* let 字符转整数   = Char.code *)
let luo__e5ad97e7aca6e8bdace695b4e695b0   = Char.code
(* let 整数转字符   = Char.chr *)
let luo__e695b4e695b0e8bdace5ad97e7aca6   = Char.chr



(* 自定义类型与模式匹配示例 *)

(* type 树 = *)
type luo__e6a091 =
  (* | 叶 *)
  | Luo__e58fb6
  (* | 节 of 树 * int * 树 *)
  | Luo__e88a82 of luo__e6a091 * int * luo__e6a091

(* let rec 树的深度 t = *)
let rec luo__e6a091e79a84e6b7b1e5baa6 t =
  match t with
  (* | 叶 -> 0 *)
  | Luo__e58fb6 -> 0
  (* | 节 (左,_,右) -> *)
  | Luo__e88a82 (luo__e5b7a6,_,luo__e58fb3) ->
      (* 1 + 最大 (树的深度 左) (树的深度 右) *)
      1 + luo__e69c80e5a4a7 (luo__e6a091e79a84e6b7b1e5baa6 luo__e5b7a6) (luo__e6a091e79a84e6b7b1e5baa6 luo__e58fb3)

(* let 示例树 = *)
let luo__e7a4bae4be8be6a091 =
  (* 节 (节 (叶,1,叶),2,节 (叶,3,叶)) *)
  Luo__e88a82 (Luo__e88a82 (Luo__e58fb6,1,Luo__e58fb6),2,Luo__e88a82 (Luo__e58fb6,3,Luo__e58fb6))

let () =
  (* 输出.格式 "树的深度：%d\n" (树的深度 示例树) *)
  Luo__e8be93e587ba.luo__e6a0bce5bc8f "树的深度：%d\n" (luo__e6a091e79a84e6b7b1e5baa6 luo__e7a4bae4be8be6a091)
