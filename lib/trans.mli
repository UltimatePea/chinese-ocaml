(** ===== Token类型 ===== *)

type token =
  | TImport   of string
  | TComment  of string
  | TKeyword  of string * string
  | TIdent    of string * string
  | TModIdent of string * string
  | TString   of string
  | TRaw      of string
  | TNum      of string
  | TOp       of string

val pp_token    : token -> string
val print_tokens: token list -> string

val tokenize : ?basedir:string -> string -> token list
(** [tokenize ?basedir src] 词法分析骆言源码，返回 token 列表。
    引入 指令不展开，仅记录为 TImport。 *)

(** ===== 标识符转换 ===== *)

val mangle : string -> string
(** [mangle name] 将用户标识符名转换为合法OCaml值标识符。
    纯ASCII名称原样返回，含非ASCII字符则编码为 luo__ + 十六进制UTF-8字节。 *)

val mangle_module : string -> string
(** [mangle_module name] 将用户标识符名转换为合法OCaml模块标识符。
    纯ASCII名称首字母大写后返回，含非ASCII字符则编码为 Luo__ + 十六进制UTF-8字节。
    OCaml要求模块名以大写字母开头，故前缀用大写 Luo__。 *)

val transpile : ?basedir:string -> string -> string
(** [transpile ?basedir src] 将骆言源码转换为标准OCaml源码。

    [basedir] 为源文件所在目录，用于解析 引入 指令中的相对路径。
    默认为空字符串（即当前工作目录）。

    语法规则：
    - 标识符用角括号括起：「名称」→ 名称
    - 注释用角括号加冒号：「：内容：」→ (* 内容 *)
    - 全角括号：（）→ ()，【】→ []
    - Unicode箭头：→ → ->，← → <-，≤ → <=，≥ → >=，≠ → <>
    - 句号：。→ ;;
    - 中文关键字：让→let，递归→rec，在→in，如果→if，等等
    - 引入 『路径.ly』 → 读取并内联编译指定文件
    - 《OCaml代码》 → 原样输出（内嵌原生OCaml）
*)
