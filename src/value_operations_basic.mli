(** 骆言基础值操作模块接口 - Basic Value Operations Module Interface *)

open Value_types

(** 基础值转换为字符串 - 安全版本返回Result *)
val string_of_basic_value : runtime_value -> (string, string) result

(** 基础值转换为字符串 - 向后兼容版本 *)
val string_of_basic_value_unsafe : runtime_value -> string

(** 基础值比较 - 安全版本返回Result *)
val compare_basic_values : runtime_value -> runtime_value -> (int, string) result

(** 基础值比较 - 向后兼容版本 *)
val compare_basic_values_unsafe : runtime_value -> runtime_value -> int
val equals_basic_values : runtime_value -> runtime_value -> bool

(** 数值运算 *)
val add_numeric_values : runtime_value -> runtime_value -> runtime_value
val subtract_numeric_values : runtime_value -> runtime_value -> runtime_value
val multiply_numeric_values : runtime_value -> runtime_value -> runtime_value
val divide_numeric_values : runtime_value -> runtime_value -> runtime_value
val modulo_numeric_values : runtime_value -> runtime_value -> runtime_value

(** 数值比较 *)
val less_than_numeric : runtime_value -> runtime_value -> runtime_value
val less_equal_numeric : runtime_value -> runtime_value -> runtime_value
val greater_than_numeric : runtime_value -> runtime_value -> runtime_value
val greater_equal_numeric : runtime_value -> runtime_value -> runtime_value

(** 字符串操作 *)
val concat_string_values : runtime_value -> runtime_value -> runtime_value

(** 逻辑运算 *)
val logical_and : runtime_value -> runtime_value -> runtime_value
val logical_or : runtime_value -> runtime_value -> runtime_value
val logical_not : runtime_value -> runtime_value

(** 类型转换 *)
val to_int_value : runtime_value -> runtime_value
val to_float_value : runtime_value -> runtime_value
val to_string_value : runtime_value -> runtime_value
val to_bool_value : runtime_value -> runtime_value