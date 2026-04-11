val generate : unit -> string
(** [generate ()] 返回骆言标准库的OCaml代码字符串。
    此代码应前置于每个编译单元，以便中文标识符能够解析到对应的OCaml函数。

    原理：每个中文名称（如"打印行"）经过 Trans.mangle 处理后得到一个合法
    OCaml 标识符（如 luo__e68993e58db0e8a18c），然后通过 let 绑定映射到
    对应的 OCaml 函数（如 print_endline）。 *)
