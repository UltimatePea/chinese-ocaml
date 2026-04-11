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



(* 骆言标准库 — 基础模块

    提供顶层工具绑定（比较、类型转换、引用等）。
    用法：引入 『骆言/基础.ly』 *)

(* 比较与数学 *)
let luo__e69c80e5a4a7         = max
let luo__e69c80e5b08f         = min
let luo__e7bb9de5afb9e580bc       = abs
let luo__e6af94e8be83         = compare

(* 引用与副作用 *)
let luo__e5bc95e794a8         = ref
let luo__e5bfbde795a5         = ignore

(* 类型转换 *)
let luo__e695b4e695b0e8bdace5ad97e7aca6e4b8b2 = string_of_int
let luo__e6b5aee782b9e8bdace5ad97e7aca6e4b8b2 = string_of_float
let luo__e5ad97e7aca6e4b8b2e8bdace695b4e695b0 = int_of_string
let luo__e5ad97e7aca6e4b8b2e8bdace6b5aee782b9 = float_of_string
let luo__e5ad97e7aca6e8bdace695b4e695b0   = Char.code
let luo__e695b4e695b0e8bdace5ad97e7aca6   = Char.chr



(* 自定义类型与模式匹配示例

    注意：构造子必须以大写ASCII字母开头（OCaml规范）
    例如 Leaf、Node 而非中文 *)

type luo__e6a091 =
  | Leaf
  | Node of luo__e6a091 * int * luo__e6a091

let rec luo__e6a091e79a84e6b7b1e5baa6 t =
  match t with
  | Leaf -> 0
  | Node (luo__e5b7a6,_,luo__e58fb3) ->
      1 + luo__e69c80e5a4a7 (luo__e6a091e79a84e6b7b1e5baa6 luo__e5b7a6) (luo__e6a091e79a84e6b7b1e5baa6 luo__e58fb3)

let luo__e7a4bae4be8be6a091 =
  Node (Node (Leaf,1,Leaf),2,Node (Leaf,3,Leaf))

let () =
  Luo__e8be93e587ba.luo__e6a0bce5bc8f "树的深度：%d\n" (luo__e6a091e79a84e6b7b1e5baa6 luo__e7a4bae4be8be6a091)
