(** 骆言统一错误处理系统 - 工具函数模块接口 *)

open Error_types

(** 向后兼容的辅助函数 *)
val result_to_value : ('a, exn) result -> 'a
(** 将Result转换为值，在出错时抛出异常 *)

val create_eval_position : int -> Compiler_errors.position
(** 创建位置信息 *)

val safe_execute : (unit -> 'a) -> 'a unified_result
(** 安全执行函数，返回Result而不是抛出异常 *)

val result_to_unified_result : ('a, exn) result -> 'a unified_result
(** 将Result转换为统一错误Result *)

val ( >>= ) : 'a unified_result -> ('a -> 'b unified_result) -> 'b unified_result
(** 链式错误处理 - monadic bind *)

val map_error : (unified_error -> unified_error) -> 'a unified_result -> 'a unified_result
(** 错误映射 *)

val with_default : 'a -> 'a unified_result -> 'a
(** 默认值处理 *)

val log_error : unified_error -> unit
(** 记录错误到日志（如果启用） *)

(** 第二阶段：便捷错误创建函数 *)

val create_lexical_error : ?pos:Compiler_errors.position -> lexical_error_type -> unified_error
(** 创建词法错误 *)

val create_parse_error : ?pos:Compiler_errors.position -> parse_error_type -> unified_error
(** 创建解析错误 *)

val create_runtime_error : ?pos:Compiler_errors.position -> runtime_error_type -> unified_error
(** 创建运行时错误 *)

val create_poetry_error : ?pos:Compiler_errors.position -> poetry_error_type -> unified_error
(** 创建诗词错误 *)

val create_system_error : ?pos:Compiler_errors.position -> system_error_type -> unified_error
(** 创建系统错误 *)

val invalid_character_error : ?pos:Compiler_errors.position -> string -> unified_error
(** 便捷函数：创建无效字符错误 *)

val unterminated_quoted_identifier_error : ?pos:Compiler_errors.position -> unit -> unified_error
(** 便捷函数：创建未闭合引用标识符错误 *)

val invalid_type_keyword_error : ?pos:Compiler_errors.position -> string -> unified_error
(** 便捷函数：创建无效类型关键字错误 *)

val arithmetic_error : ?pos:Compiler_errors.position -> string -> unified_error
(** 便捷函数：创建算术错误 *)

val rhyme_data_error : ?pos:Compiler_errors.position -> string -> unified_error
(** 便捷函数：创建韵律数据错误 *)

val json_parse_error : ?pos:Compiler_errors.position -> string -> unified_error
(** 便捷函数：创建JSON解析错误 *)

val file_load_error : ?pos:Compiler_errors.position -> string -> unified_error
(** 便捷函数：创建文件加载错误 *)

val parallelism_error : ?pos:Compiler_errors.position -> string -> unified_error
(** 便捷函数：创建对偶错误 *)

val error_to_result : unified_error -> 'a unified_result
(** 将新错误类型转换为Result.Error *)

val safe_failwith_to_error : (string -> unified_error) -> string -> 'a unified_result
(** 安全执行函数，将failwith替换为统一错误 *)
