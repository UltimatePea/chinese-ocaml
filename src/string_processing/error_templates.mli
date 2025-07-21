(** 统一错误消息模板模块

    本模块提供了所有错误消息的统一格式化功能， 用于确保错误消息的一致性和可维护性。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** {1 函数参数错误模板} *)

val function_param_error : string -> int -> int -> string
(** [function_param_error function_name expected_count actual_count] 生成函数参数数量错误消息 *)

val function_param_type_error : string -> string -> string
(** [function_param_type_error function_name expected_type] 生成函数参数类型错误消息 *)

val function_single_param_error : string -> string
(** [function_single_param_error function_name] 生成期望单个参数的错误消息 *)

val function_double_param_error : string -> string
(** [function_double_param_error function_name] 生成期望两个参数的错误消息 *)

val function_no_param_error : string -> string
(** [function_no_param_error function_name] 生成不需要参数的错误消息 *)

(** {1 类型错误模板} *)

val type_mismatch_error : string -> string -> string
(** [type_mismatch_error expected_type actual_type] 生成类型不匹配错误消息 *)

val undefined_variable_error : string -> string
(** [undefined_variable_error var_name] 生成未定义变量错误消息 *)

val index_out_of_bounds_error : int -> int -> string
(** [index_out_of_bounds_error index length] 生成数组索引越界错误消息 *)

(** {1 文件操作错误模板} *)

val file_operation_error : string -> string -> string
(** [file_operation_error operation filename] 生成文件操作错误消息 *)

(** {1 通用功能错误模板} *)

val generic_function_error : string -> string -> string
(** [generic_function_error function_name error_desc] 生成通用函数错误消息 *)

(** {1 编译器错误模板} *)

val unsupported_feature : string -> string
(** [unsupported_feature feature] 生成不支持功能的错误消息 *)

val unexpected_state : string -> string -> string
(** [unexpected_state state context] 生成意外状态错误消息 *)

val invalid_character : char -> string
(** [invalid_character char] 生成无效字符错误消息 *)

val syntax_error : string -> string -> string
(** [syntax_error message position] 生成语法错误消息 *)

val semantic_error : string -> string -> string
(** [semantic_error message context] 生成语义错误消息 *)

(** {1 诗词解析错误模板} *)

val poetry_char_count_mismatch : int -> int -> string
(** [poetry_char_count_mismatch expected actual] 生成诗词字符数不匹配错误消息 *)

val poetry_verse_count_warning : int -> string
(** [poetry_verse_count_warning count] 生成诗词句数警告消息 *)

val poetry_rhyme_mismatch : int -> string -> string -> string
(** [poetry_rhyme_mismatch verse_num expected_rhyme actual_rhyme] 生成诗词韵脚不匹配错误消息 *)

val poetry_tone_pattern_error : int -> string -> string -> string
(** [poetry_tone_pattern_error verse_num expected_pattern actual_pattern] 生成诗词平仄错误消息 *)

(** {1 数据处理错误模板} *)

val data_loading_error : string -> string -> string -> string
(** [data_loading_error data_type filename reason] 生成数据加载错误消息 *)

val data_validation_error : string -> string -> string -> string
(** [data_validation_error field_name value reason] 生成数据验证错误消息 *)

val data_format_error : string -> string -> string
(** [data_format_error expected_format actual_format] 生成数据格式错误消息 *)
