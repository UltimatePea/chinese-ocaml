(** 参数验证DSL模块 - 消除内置函数中重复的参数验证模式 *)

open Value_operations

(** {1 类型定义} *)

(** 通用验证器类型 *)
type 'a validator = runtime_value -> 'a

(** {1 错误处理} *)

(** 运行时错误函数 *)
val runtime_error : string -> 'a

(** {1 类型验证器创建} *)

(** 创建类型验证器的通用函数 *)
val create_type_validator : string -> (runtime_value -> 'a option) -> 'a validator

(** {1 基本类型提取器} *)

(** 提取字符串值 *)
val extract_string : runtime_value -> string option

(** 提取整数值 *)
val extract_int : runtime_value -> int option

(** 提取浮点数值 *)
val extract_float : runtime_value -> float option

(** 提取布尔值 *)
val extract_bool : runtime_value -> bool option

(** 提取列表值 *)
val extract_list : runtime_value -> runtime_value list option

(** 提取数组值 *)
val extract_array : runtime_value -> runtime_value array option

(** 提取内置函数值 *)
val extract_builtin_function : runtime_value -> (runtime_value list -> runtime_value) option

(** {1 复合类型提取器} *)

(** 提取数值类型（整数或浮点数） *)
val extract_number : runtime_value -> runtime_value option

(** 提取字符串或列表 *)
val extract_string_or_list : runtime_value -> runtime_value option

(** 提取非空列表 *)
val extract_nonempty_list : runtime_value -> runtime_value list option

(** {1 预定义验证器} *)

(** 验证字符串类型 *)
val validate_string : string validator

(** 验证整数类型 *)
val validate_int : int validator

(** 验证浮点数类型 *)
val validate_float : float validator

(** 验证布尔值类型 *)
val validate_bool : bool validator

(** 验证列表类型 *)
val validate_list : runtime_value list validator

(** 验证数组类型 *)
val validate_array : runtime_value array validator

(** 验证内置函数类型 *)
val validate_builtin_function : (runtime_value list -> runtime_value) validator

(** 验证数值类型 *)
val validate_number : runtime_value validator

(** 验证字符串或列表类型 *)
val validate_string_or_list : runtime_value validator

(** 验证非空列表 *)
val validate_nonempty_list : runtime_value list validator

(** {1 带函数名的验证器} *)

(** 为验证器添加函数名信息 *)
val with_function_name : 'a validator -> string -> 'a validator

(** {1 参数数量验证} *)

(** 验证单个参数 *)
val validate_single : 'a validator -> string -> runtime_value list -> 'a

(** 验证两个参数 *)
val validate_double : 'a validator -> 'b validator -> string -> runtime_value list -> 'a * 'b

(** 验证三个参数 *)
val validate_triple : 'a validator -> 'b validator -> 'c validator -> string -> runtime_value list -> 'a * 'b * 'c

(** 验证无参数 *)
val validate_no_args : string -> runtime_value list -> unit

(** {1 便捷验证函数} *)

(** 期望字符串类型 *)
val expect_string : string validator

(** 期望整数类型 *)
val expect_int : int validator

(** 期望浮点数类型 *)
val expect_float : float validator

(** 期望布尔值类型 *)
val expect_bool : bool validator

(** 期望列表类型 *)
val expect_list : runtime_value list validator

(** 期望数组类型 *)
val expect_array : runtime_value array validator

(** 期望内置函数类型 *)
val expect_builtin_function : (runtime_value list -> runtime_value) validator

(** 期望数值类型 *)
val expect_number : runtime_value validator

(** 期望字符串或列表类型 *)
val expect_string_or_list : runtime_value validator

(** 期望非空列表 *)
val expect_nonempty_list : runtime_value list validator

(** {1 特殊验证器} *)

(** 验证非负整数 *)
val validate_non_negative : int validator

(** 期望非负整数 *)
val expect_non_negative : int validator