(** 骆言Token系统整合重构 - 操作符映射管理接口 *)

open Yyocamlc_lib.Token_types

(** 操作符映射模块 *)
module OperatorMapping : sig
  val lookup_symbol_operator : string -> Operators.operator_token option
  (** 查找符号操作符 *)

  val lookup_chinese_operator : string -> Operators.operator_token option
  (** 查找中文操作符 *)

  val lookup_operator : string -> Operators.operator_token option
  (** 通用操作符查找 *)

  val operator_to_symbol : Operators.operator_token -> string option
  (** 操作符转换为符号 *)

  val operator_to_chinese : Operators.operator_token -> string option
  (** 操作符转换为中文 *)

  val is_operator : string -> bool
  (** 检查是否为操作符 *)

  val get_operator_precedence : Operators.operator_token -> int
  (** 获取操作符优先级 *)

  val get_operator_associativity : Operators.operator_token -> associativity
  (** 获取操作符结合性 *)

  val is_binary_operator : Operators.operator_token -> bool
  (** 检查是否为二元操作符 *)

  val is_unary_operator : Operators.operator_token -> bool
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
    operator : Operators.operator_token;
    precedence : int;
    associativity : associativity;
    arity : [ `Unary | `Binary ];
  }

  val find_precedence_info : Operators.operator_token -> precedence_entry option
  (** 查找操作符优先级信息 *)

  val compare_precedence : Operators.operator_token -> Operators.operator_token -> int
  (** 比较两个操作符的优先级 *)
end
