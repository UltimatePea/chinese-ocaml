(** 骆言统一错误处理系统接口 - Chinese Programming Language Unified Error Handling System Interface *)

open Compiler_errors

(** 统一错误码定义 *)
type error_code = 
  | SyntaxError of string * position
  | RuntimeError of string * position option
  | TypeError of string * position option
  | LexError of string * position
  | SemanticError of string * position option
  | CompilerInternalError of string

(** 错误结果类型 *)
type 'a result = ('a, error_code) Result.t

(** 将异常转换为Result类型 *)
val to_result : (unit -> 'a) -> 'a result

(** 创建运行时错误 *)
val make_runtime_error : string -> position option -> 'a result

(** 创建语法错误 *)
val make_syntax_error : string -> position -> 'a result

(** 创建类型错误 *)
val make_type_error : string -> position option -> 'a result

(** 创建词法错误 *)
val make_lex_error : string -> position -> 'a result

(** 创建语义错误 *)
val make_semantic_error : string -> position option -> 'a result

(** 从错误码中获取消息 *)
val error_message : error_code -> string

(** 从错误码中获取位置 *)
val error_position : error_code -> position option

(** 将错误码转换为标准异常 *)
val error_to_exception : error_code -> exn

(** Result 单子操作 *)
module ResultOps : sig
  (** 绑定操作 *)
  val bind : 'a result -> ('a -> 'b result) -> 'b result

  (** 映射操作 *)
  val map : ('a -> 'b) -> 'a result -> 'b result

  (** 绑定操作符 *)
  val (>>=) : 'a result -> ('a -> 'b result) -> 'b result

  (** 映射操作符 *)
  val (>|=) : 'a result -> ('a -> 'b) -> 'b result

  (** 将多个结果合并，如果有任何错误则返回第一个错误 *)
  val all : 'a result list -> 'a list result

  (** 尝试第一个操作，失败时尝试第二个 *)
  val or_else : 'a result -> (unit -> 'a result) -> 'a result
end

(** 简化的位置创建函数 *)
val create_position : string -> int -> int -> position

(** 评估位置创建函数 *)
val create_eval_position : int -> position