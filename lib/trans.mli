val mangle : string -> string
(** [mangle name] 将用户标识符名转换为合法OCaml标识符。
    纯ASCII名称原样返回，含非ASCII字符则编码为 luo__ + 十六进制UTF-8字节。 *)

val transpile : string -> string
(** [transpile src] 将骆言源码转换为标准OCaml源码。

    语法规则：
    - 标识符用角括号括起：「名称」→ 名称
    - 注释用角括号加冒号：「：内容：」→ (* 内容 *)
    - 全角括号：（）→ ()，【】→ []
    - Unicode箭头：→ → ->，← → <-，≤ → <=，≥ → >=，≠ → <>
    - 句号：。→ ;;
    - 中文关键字：让→let，递归→rec，在→in，如果→if，等等
*)
