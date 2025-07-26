(** 骆言Token系统整合重构 - 操作符映射管理接口 *)

open Yyocamlc_lib.Token_types

(** 操作符映射模块 *)
module OperatorMapping : sig
  val lookup_symbol_operator : string -> operator_type option
  (** 查找符号操作符 *)

  val lookup_chinese_operator : string -> operator_type option
  (** 查找中文操作符 *)

  val lookup_operator : string -> operator_type option
  (** 通用操作符查找 *)

  val operator_to_symbol : operator_type -> string option
  (** 操作符转换为符号 *)

  val operator_to_chinese : operator_type -> string option
  (** 操作符转换为中文 *)

  val is_operator : string -> bool
  (** 检查是否为操作符 *)

  val get_operator_precedence : operator_type -> int
  (** 获取操作符优先级 *)

  val get_operator_associativity : operator_type -> associativity
  (** 获取操作符结合性 *)

  val is_binary_operator : operator_type -> bool
  (** 检查是否为二元操作符 *)

  val is_unary_operator : operator_type -> bool
  (** 检查是否为一元操作符 *)

  val get_operators_by_category : string -> string list
  (** 按类别获取操作符 *)

  val get_all_symbol_operators : unit -> string list
  (** 获取所有符号操作符 *)

  val get_all_chinese_operators : unit -> string list
  (** 获取所有中文操作符 *)

  val get_operator_stats : unit -> string
  (** 操作符统计信息 *)
end

(** 操作符优先级表 *)
module OperatorPrecedenceTable : sig
  type precedence_entry = {
    operator : operator_type;
    precedence : int;
    associativity : associativity;
    arity : [ `Unary | `Binary ];
  }

  val find_precedence_info : operator_type -> precedence_entry option
  (** 查找操作符优先级信息 *)

  val compare_precedence : operator_type -> operator_type -> int
  (** 比较两个操作符的优先级 *)
end
