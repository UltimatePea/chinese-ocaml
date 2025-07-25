(** 骆言内置函数辅助工具模块接口 - 消除参数验证代码重复 * Chinese Programming Language Builtin Function Helpers Interface -
    Eliminate Parameter Validation Code Duplication *)

open Value_operations

val single_string_builtin : string -> (string -> string) -> runtime_value list -> runtime_value
(** 单参数字符串内置函数辅助器 * 接受函数名、字符串操作函数和参数列表，返回字符串值 *)

val single_int_builtin : string -> (int -> int) -> runtime_value list -> runtime_value
(** 单参数整数内置函数辅助器 * 接受函数名、整数操作函数和参数列表，返回整数值 *)

val single_float_builtin : string -> (float -> float) -> runtime_value list -> runtime_value
(** 单参数浮点数内置函数辅助器 * 接受函数名、浮点数操作函数和参数列表，返回浮点数值 *)

val single_bool_builtin : string -> (bool -> bool) -> runtime_value list -> runtime_value
(** 单参数布尔值内置函数辅助器 * 接受函数名、布尔值操作函数和参数列表，返回布尔值 *)

val single_to_string_builtin :
  string -> (runtime_value -> string -> 'a) -> ('a -> string) -> runtime_value list -> runtime_value
(** 单参数转字符串内置函数辅助器 * 接受函数名、期待函数、值转换器和参数列表，返回字符串值 *)

val single_conversion_builtin :
  string ->
  (runtime_value -> string -> 'a) ->
  ('a -> 'b) ->
  ('b -> runtime_value) ->
  runtime_value list ->
  runtime_value
(** 单参数类型转换内置函数辅助器 * 接受函数名、期待函数、转换函数、结果包装器和参数列表，返回转换后的值 *)

val double_string_builtin :
  string -> (string -> string -> string) -> runtime_value list -> runtime_value
(** 双参数字符串内置函数辅助器 * 接受函数名、字符串操作函数和参数列表，返回字符串值 *)

val double_string_to_bool_builtin :
  string -> (string -> string -> bool) -> runtime_value list -> runtime_value
(** 双参数字符串返回布尔值内置函数辅助器 * 接受函数名、字符串谓词函数和参数列表，返回布尔值 *)

val single_list_builtin :
  string -> (runtime_value list -> runtime_value list) -> runtime_value list -> runtime_value
(** 单参数列表内置函数辅助器 * 接受函数名、列表操作函数和参数列表，返回列表值 *)

val single_file_builtin : string -> (string -> runtime_value) -> runtime_value list -> runtime_value
(** 单参数文件操作内置函数辅助器 * 接受函数名、文件操作函数和参数列表，处理文件错误 *)

val curried_double_string_builtin :
  string -> (string -> string -> string) -> runtime_value list -> runtime_value
(** 复合内置函数构建器 - 支持柯里化风格的双参数函数 * 接受函数名、字符串操作函数和参数列表，返回柯里化的内置函数值 *)

val curried_double_string_to_bool_builtin :
  string -> (string -> string -> bool) -> runtime_value list -> runtime_value
(** 复合内置函数构建器 - 支持柯里化风格的双参数返回布尔值函数 * 接受函数名、字符串谓词函数和参数列表，返回柯里化的内置函数值 *)

val curried_string_to_list_builtin :
  string -> (string -> string -> string list) -> runtime_value list -> runtime_value
(** 复合内置函数构建器 - 支持柯里化风格的双参数列表函数 * 接受函数名、字符串操作函数和参数列表，返回柯里化的内置函数值 *)
