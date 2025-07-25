(** 骆言编译器语法元素格式化模块接口

    此模块专门处理Token、语法结构、函数调用、模块访问等语法元素的格式化。

    设计原则:
    - 语法一致性：遵循骆言语言的语法规范
    - 可读性：生成易读的语法元素表示
    - 完整性：覆盖所有主要语法结构
    - C代码生成友好：支持代码生成阶段的格式化需求

    用途：为语法分析、代码生成、语法树显示提供格式化服务 *)

(** 语法元素格式化工具模块 *)
module Syntax_formatters : sig
  val token_pattern : string -> string -> string
  (** Token模式: TokenType(value) *)

  val char_token_pattern : string -> char -> string
  (** Token模式: TokenType('char') *)

  val function_call_format : string -> string list -> string
  (** 函数调用格式化: FunctionName(arg1, arg2, ...) *)

  val module_access_format : string -> string -> string
  (** 模块访问格式化: Module.member *)

  val binary_function_pattern : string -> string -> string -> string
  (** 双参数函数模式: func_name(param1, param2) *)

  val luoyan_function_pattern : string -> string -> string
  (** C代码生成模式: luoyan_function_name(args) *)

  val luoyan_env_bind_pattern : string -> string -> string
  (** C环境绑定模式: luoyan_env_bind(env, "var", expr); *)

  val c_code_structure_pattern : string -> string -> string -> string
  (** C代码结构模式: includes + functions + main *)

  val luoyan_string_equality_pattern : string -> string -> string
  (** Luoyan字符串相等检查模式: luoyan_equals(expr, luoyan_string("str")) *)

  val c_type_cast_pattern : string -> string -> string
  (** C类型转换模式: (type)expr *)

  val c_record_field_pattern : string -> string -> string
  (** C记录字段格式: {"field_name", expr} *)

  val c_record_constructor_pattern : int -> string -> string
  (** C记录构造模式: luoyan_record(count, (luoyan_field_t[]){fields}) *)

  val c_record_get_pattern : string -> string -> string
  (** C记录访问模式: luoyan_record_get(record, "field") *)

  val c_record_update_pattern : string -> int -> string -> string
  (** C记录更新模式: luoyan_record_update(record, count, (luoyan_field_t[]){updates}) *)

  val c_constructor_pattern : string -> int -> string -> string
  (** C构造器模式: luoyan_constructor("name", count, args) *)

  val c_value_array_pattern : string -> string
  (** C值数组模式: (luoyan_value_t[]){values} *)

  val c_var_name_pattern : string -> int -> string
  (** C变量命名模式: luoyan_var_prefix_id *)

  val c_label_name_pattern : string -> int -> string
  (** C标签命名模式: luoyan_label_prefix_id *)

  val ascii_escape_pattern : int -> string
  (** ASCII转义模式: _asciiNUM_ *)

  val c_type_pointer_pattern : string -> string
  (** C类型模式: luoyan_type_name_t* *)

  val c_user_type_pattern : string -> string
  (** C用户类型模式: luoyan_user_name_t* *)

  val c_class_type_pattern : string -> string
  (** C类模式: luoyan_class_name_t* *)

  val c_private_type_pattern : string -> string
  (** C私有类型模式: luoyan_private_name_t* *)

  val type_conversion_log_pattern : string -> string -> string
  (** 类型转换日志模式: 将source_type转换为target_type *)

  val float_to_int_conversion_pattern : float -> int -> string
  (** 浮点数整数转换模式: 将浮点数X转换为整数Y *)

  val string_to_int_conversion_pattern : string -> int -> string
  (** 字符串整数转换模式: 将字符串"X"转换为整数Y *)

  val bool_to_int_conversion_pattern : bool -> int -> string
  (** 布尔值整数转换模式: 将布尔值X转换为整数Y *)

  val int_to_float_conversion_pattern : int -> float -> string
  (** 整数浮点数转换模式: 将整数X转换为浮点数Y *)

  val string_to_float_conversion_pattern : string -> float -> string
  (** 字符串浮点数转换模式: 将字符串"X"转换为浮点数Y *)

  val value_to_string_conversion_pattern : string -> string -> string
  (** 值到字符串转换模式: 将X转换为字符串"Y" *)
end

(** 导出的顶层函数 *)

val token_pattern : string -> string -> string
(** Token模式: TokenType(value) *)

val char_token_pattern : string -> char -> string
(** Token模式: TokenType('char') *)

val function_call_format : string -> string list -> string
(** 函数调用格式化: FunctionName(arg1, arg2, ...) *)

val module_access_format : string -> string -> string
(** 模块访问格式化: Module.member *)

val binary_function_pattern : string -> string -> string -> string
(** 双参数函数模式: func_name(param1, param2) *)

val luoyan_function_pattern : string -> string -> string
(** C代码生成模式: luoyan_function_name(args) *)

val luoyan_env_bind_pattern : string -> string -> string
(** C环境绑定模式: luoyan_env_bind(env, "var", expr); *)

val c_code_structure_pattern : string -> string -> string -> string
(** C代码结构模式: includes + functions + main *)

val luoyan_string_equality_pattern : string -> string -> string
(** Luoyan字符串相等检查模式: luoyan_equals(expr, luoyan_string("str")) *)

val c_type_cast_pattern : string -> string -> string
(** C类型转换模式: (type)expr *)

val c_record_field_pattern : string -> string -> string
(** C记录字段格式: {"field_name", expr} *)

val c_record_constructor_pattern : int -> string -> string
(** C记录构造模式: luoyan_record(count, (luoyan_field_t[]){fields}) *)

val c_record_get_pattern : string -> string -> string
(** C记录访问模式: luoyan_record_get(record, "field") *)

val c_record_update_pattern : string -> int -> string -> string
(** C记录更新模式: luoyan_record_update(record, count, (luoyan_field_t[]){updates}) *)

val c_constructor_pattern : string -> int -> string -> string
(** C构造器模式: luoyan_constructor("name", count, args) *)

val c_value_array_pattern : string -> string
(** C值数组模式: (luoyan_value_t[]){values} *)

val c_var_name_pattern : string -> int -> string
(** C变量命名模式: luoyan_var_prefix_id *)

val c_label_name_pattern : string -> int -> string
(** C标签命名模式: luoyan_label_prefix_id *)

val ascii_escape_pattern : int -> string
(** ASCII转义模式: _asciiNUM_ *)

val c_type_pointer_pattern : string -> string
(** C类型模式: luoyan_type_name_t* *)

val c_user_type_pattern : string -> string
(** C用户类型模式: luoyan_user_name_t* *)

val c_class_type_pattern : string -> string
(** C类模式: luoyan_class_name_t* *)

val c_private_type_pattern : string -> string
(** C私有类型模式: luoyan_private_name_t* *)

val type_conversion_log_pattern : string -> string -> string
(** 类型转换日志模式: 将source_type转换为target_type *)

val float_to_int_conversion_pattern : float -> int -> string
(** 浮点数整数转换模式: 将浮点数X转换为整数Y *)

val string_to_int_conversion_pattern : string -> int -> string
(** 字符串整数转换模式: 将字符串"X"转换为整数Y *)

val bool_to_int_conversion_pattern : bool -> int -> string
(** 布尔值整数转换模式: 将布尔值X转换为整数Y *)

val int_to_float_conversion_pattern : int -> float -> string
(** 整数浮点数转换模式: 将整数X转换为浮点数Y *)

val string_to_float_conversion_pattern : string -> float -> string
(** 字符串浮点数转换模式: 将字符串"X"转换为浮点数Y *)

val value_to_string_conversion_pattern : string -> string -> string
(** 值到字符串转换模式: 将X转换为字符串"Y" *)
