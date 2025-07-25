(** 骆言Token系统整合重构 - Token注册和管理系统接口 *)

open Yyocamlc_lib.Token_types

type t
(** Token注册表类型 *)

val create : unit -> t
(** 创建新的Token注册表 *)

val next_token_id : t -> int
(** 获取下一个Token ID *)

val register_keyword : t -> key:string -> keyword:Keywords.keyword_token -> unit
(** 注册关键字 *)

val register_operator : t -> key:string -> operator:Operators.operator_token -> unit
(** 注册操作符 *)

val register_delimiter : t -> key:string -> delimiter:Delimiters.delimiter_token -> unit
(** 注册分隔符 *)

val lookup_keyword : t -> string -> Keywords.keyword_token option
(** 查找关键字 *)

val lookup_operator : t -> string -> Operators.operator_token option
(** 查找操作符 *)

val lookup_delimiter : t -> string -> Delimiters.delimiter_token option
(** 查找分隔符 *)

val lookup_token : t -> string -> token option
(** 通用Token查找 *)

val is_registered : t -> string -> bool
(** 检查Token是否已注册 *)

val get_all_keywords : t -> (string * Keywords.keyword_token) list
(** 获取所有已注册的关键字 *)

val get_all_operators : t -> (string * Operators.operator_token) list
(** 获取所有已注册的操作符 *)

val get_all_delimiters : t -> (string * Delimiters.delimiter_token) list
(** 获取所有已注册的分隔符 *)

val get_stats : t -> string
(** 获取注册表统计信息 *)

val get_token_text : token -> string option
(** 获取Token的文本表示 *)

val clear : t -> unit
(** 清空注册表 *)

val size : t -> int
(** 注册表大小 *)

val init_default_registry : unit -> t
(** 初始化默认Token注册表 *)

val get_default_registry : unit -> t
(** 获取默认注册表 *)
