(** 骆言Token系统整合重构 - Token注册和管理系统接口 *)

open Token_types

(** Token注册表类型 *)
type t

(** 创建新的Token注册表 *)
val create : unit -> t

(** 获取下一个Token ID *)
val next_token_id : t -> int

(** 注册关键字 *)
val register_keyword : t -> key:string -> keyword:keyword_type -> unit

(** 注册操作符 *)
val register_operator : t -> key:string -> operator:operator_type -> unit

(** 注册分隔符 *)
val register_delimiter : t -> key:string -> delimiter:delimiter_type -> unit

(** 查找关键字 *)
val lookup_keyword : t -> string -> keyword_type option

(** 查找操作符 *)
val lookup_operator : t -> string -> operator_type option

(** 查找分隔符 *)
val lookup_delimiter : t -> string -> delimiter_type option

(** 通用Token查找 *)
val lookup_token : t -> string -> token option

(** 检查Token是否已注册 *)  
val is_registered : t -> string -> bool

(** 获取所有已注册的关键字 *)
val get_all_keywords : t -> (string * keyword_type) list

(** 获取所有已注册的操作符 *)
val get_all_operators : t -> (string * operator_type) list

(** 获取所有已注册的分隔符 *)
val get_all_delimiters : t -> (string * delimiter_type) list

(** 获取注册表统计信息 *)
val get_stats : t -> string

(** 清空注册表 *)
val clear : t -> unit

(** 注册表大小 *)
val size : t -> int

(** 初始化默认Token注册表 *)
val init_default_registry : unit -> t

(** 获取默认注册表 *)
val get_default_registry : unit -> t