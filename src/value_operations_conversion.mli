(** 骆言值操作类型转换模块接口 - Value Operations Type Conversion Interface
    
    技术债务改进：大型模块重构优化 Phase 2.2 - value_operations.ml 完整模块化
    提供运行时值类型转换和字符串化的公共接口
    
    @author 骆言AI代理
    @version 2.2 - 完整模块化第二阶段  
    @since 2025-07-24 Fix #1048
*)

open Value_types

(** 值转换为字符串 - 主要的字符串化函数 *)
val value_to_string : runtime_value -> string

(** 值转换为布尔值 *)
val value_to_bool : runtime_value -> bool

(** 尝试将值转换为整数 *)
val try_to_int : runtime_value -> int option

(** 尝试将值转换为浮点数 *)
val try_to_float : runtime_value -> float option

(** 尝试将值转换为字符串 *)
val try_to_string : runtime_value -> string option

(** 强制转换为整数（不成功则抛出异常） *)
val force_to_int : runtime_value -> int

(** 强制转换为浮点数（不成功则抛出异常） *)
val force_to_float : runtime_value -> float

(** 强制转换为字符串（总是成功） *)
val force_to_string : runtime_value -> string

(** 检查值是否可以转换为整数 *)
val can_convert_to_int : runtime_value -> bool

(** 检查值是否可以转换为浮点数 *)
val can_convert_to_float : runtime_value -> bool

(** 检查值是否可以转换为字符串（总是可以） *)
val can_convert_to_string : runtime_value -> bool

(** 基础类型值转换为字符串 *)
val basic_value_to_string : runtime_value -> string

(** 容器类型值转换为字符串 *)
val container_value_to_string : (runtime_value -> string) -> runtime_value -> string

(** 函数类型值转换为字符串 *)
val function_value_to_string : runtime_value -> string

(** 构造器和异常类型值转换为字符串 *)
val constructor_value_to_string : (runtime_value -> string) -> runtime_value -> string

(** 模块类型值转换为字符串 *)
val module_value_to_string : runtime_value -> string

(** 运行时值打印函数（用于 Format 模块） *)
val runtime_value_pp : Format.formatter -> runtime_value -> unit