(** 骆言值操作高级类型模块接口 - Value Operations Advanced Types Interface

    技术债务改进：大型模块重构优化 Phase 2.2 - value_operations.ml 完整模块化 提供高级运行时值操作的公共接口

    @author 骆言AI代理
    @version 2.2 - 完整模块化第二阶段
    @since 2025-07-24 Fix #1048 *)

open Value_types
open Ast

val register_constructors : runtime_env -> type_def -> runtime_env
(** 注册构造器函数 *)

(** 运行时值相等性比较 - 现在从 Value_operations_basic 模块提供 *)

val is_comparable_value : runtime_value -> bool
(** 检查值是否为可比较类型 *)

val deep_equal : runtime_value -> runtime_value -> bool
(** 深度比较运行时值（更严格的比较） *)

val same_type : runtime_value -> runtime_value -> bool
(** 检查两个值是否为同一类型 *)

val make_ref_value : runtime_value -> runtime_value
(** 创建引用值 *)

val deref_value : runtime_value -> runtime_value
(** 获取引用的值 *)

val set_ref_value : runtime_value -> runtime_value -> runtime_value
(** 设置引用的值 *)

val make_constructor_value : string -> runtime_value list -> runtime_value
(** 创建构造器值 *)

val get_constructor_name : runtime_value -> string
(** 获取构造器的名称 *)

val get_constructor_args : runtime_value -> runtime_value list
(** 获取构造器的参数 *)

val make_exception_value : string -> runtime_value option -> runtime_value
(** 创建异常值 *)

val get_exception_name : runtime_value -> string
(** 获取异常的名称 *)

val get_exception_payload : runtime_value -> runtime_value option
(** 获取异常的载荷 *)

val make_polymorphic_variant : string -> runtime_value option -> runtime_value
(** 创建多态变体值 *)

val get_variant_tag : runtime_value -> string
(** 获取多态变体的标签 *)

val get_variant_value : runtime_value -> runtime_value option
(** 获取多态变体的值 *)

val make_module_value : (string * runtime_value) list -> runtime_value
(** 创建模块值 *)

val get_module_bindings : runtime_value -> (string * runtime_value) list
(** 获取模块的绑定列表 *)

val lookup_module_member : runtime_value -> string -> runtime_value
(** 从模块中查找成员 *)

val module_has_member : runtime_value -> string -> bool
(** 检查模块是否包含指定成员 *)

val get_module_member_names : runtime_value -> string list
(** 获取模块的所有成员名称 *)

val merge_modules : runtime_value -> runtime_value -> runtime_value
(** 合并两个模块 *)

(** Alcotest ValueModule - 用于测试 *)
module ValueModule : sig
  type t = runtime_value

  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
end
