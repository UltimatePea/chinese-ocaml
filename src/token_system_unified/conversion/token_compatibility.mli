(** Token兼容性适配层接口 - 统一Token系统与现有代码的桥梁 *)

open Yyocamlc_lib.Unified_token_core

val convert_legacy_token_string : string -> string option -> unified_token option
(** 旧系统token名称到统一token的转换
    @param token_name 旧的token名称字符串
    @param value_opt 可选的token值
    @return 转换后的统一token，如果无法转换则返回None *)

val make_compatible_positioned_token :
  string -> string option -> string -> int -> int -> Yyocamlc_lib.Unified_token_core.positioned_token option
(** 创建兼容性positioned_token
    @param legacy_token_name 旧的token名称
    @param value_opt 可选的token值
    @param filename 文件名
    @param line 行号
    @param column 列号
    @return 带位置信息的统一token *)

val is_compatible_with_legacy : string -> bool
(** 检查是否兼容旧的token名称
    @param token_name 旧的token名称
    @return 如果支持则返回true *)

val get_supported_legacy_tokens : unit -> string list
(** 获取所有支持的旧token名称列表
    @return 支持的旧token名称字符串列表 *)

val generate_compatibility_report : unit -> string
(** 生成兼容性报告
    @return 兼容性状态报告字符串 *)

val generate_detailed_compatibility_report : unit -> string
(** 生成详细兼容性报告
    @return 详细兼容性状态报告字符串 *)

val map_basic_keywords : string -> unified_token option
(** 映射基础关键字 *)

val map_wenyan_keywords : string -> unified_token option
(** 映射文言文关键字 *)

val map_classical_keywords : string -> unified_token option
(** 映射古雅体关键字 *)

val map_natural_language_keywords : string -> unified_token option
(** 映射自然语言函数关键字 *)

val map_type_keywords : string -> unified_token option
(** 映射类型关键字 *)

val map_poetry_keywords : string -> unified_token option
(** 映射诗词关键字 *)

val map_misc_keywords : string -> unified_token option
(** 映射杂项关键字 *)

val map_legacy_keyword_to_unified : string -> unified_token option
(** 统一关键字映射接口 *)

val map_legacy_operator_to_unified : string -> unified_token option
(** 映射运算符 *)

val map_legacy_delimiter_to_unified : string -> unified_token option
(** 映射分隔符 *)

val map_legacy_literal_to_unified : string -> unified_token option
(** 映射字面量 *)

val map_legacy_identifier_to_unified : string -> unified_token option
(** 映射标识符 *)

val map_legacy_special_to_unified : string -> unified_token option
(** 映射特殊Token *)

type position_info = { line : int; column : int; offset : int; filename : string }
type positioned_token = Yyocamlc_lib.Unified_token_core.positioned_token

type conversion_error =
  | UnsupportedToken of string
  | InvalidPosition of position_info
  | MalformedToken of string

type conversion_result =
  | Success of Yyocamlc_lib.Unified_token_core.positioned_token
  | Error of conversion_error
