(** 统一Token转换系统接口 - Issue #1318 技术债务重构
 *
 *  这个模块提供统一的Token转换接口，替代之前分散在20+个模块中的重复代码
 *
 *  @author 骆言技术债务清理团队 Issue #1318
 *  @version 1.0 - 初始统一转换系统
 *  @since 2025-07-25 *)

type converter_type =
  [ `Identifier  (** 标识符转换器 *)
  | `Literal  (** 字面量转换器 *)
  | `BasicKeyword  (** 基础关键字转换器 *)
  | `TypeKeyword  (** 类型关键字转换器 *)
  | `Classical  (** 古典语言转换器 *) ]
(** 转换器类型定义 *)

(** 转换结果类型 *)
type conversion_result = ConversionSuccess of Yyocamlc_lib.Lexer_tokens.token | ConversionFailure of string

exception Unified_conversion_failed of converter_type * string
(** 统一的转换异常 *)

type converter_registry =
  (converter_type * (Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token)) list
(** 转换器注册表类型 *)

(** 核心转换接口 *)

val convert_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token option
(** 统一的Token转换接口 - 按优先级尝试转换，返回option类型 *)

val convert_token_exn : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 强制转换Token - 失败时抛出异常 *)

val convert_token_list :
  Token_mapping.Token_definitions_unified.token list -> Yyocamlc_lib.Lexer_tokens.token list
(** 批量转换Token列表 - 异常版本 *)

val convert_token_list_safe :
  Token_mapping.Token_definitions_unified.token list -> Yyocamlc_lib.Lexer_tokens.token option list
(** 批量转换Token列表 - option版本 *)

(** 转换器管理接口 *)

val register_converter :
  converter_type -> (Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token) -> unit
(** 注册新的转换器 *)

val get_converter :
  converter_type -> Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
(** 获取指定类型的转换器 *)

val try_convert_with_type :
  converter_type -> Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token option
(** 尝试使用指定类型的转换器转换 - 返回option类型 *)

val reset_converters : unit -> unit
(** 重置转换器到默认状态 *)

(** 统计和诊断接口 *)

val get_conversion_stats : unit -> string
(** 获取转换统计信息 *)

val get_converter_details : unit -> (converter_type * string) list
(** 获取详细的转换器信息 *)

(** 向后兼容性接口 - 模拟原有的单独转换函数 *)
module CompatibilityInterface : sig
  val convert_identifier_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
  (** 标识符转换 *)

  val convert_literal_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
  (** 字面量转换 *)

  val convert_basic_keyword_token :
    Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
  (** 基础关键字转换 *)

  val convert_type_keyword_token :
    Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
  (** 类型关键字转换 *)

  val convert_classical_token : Token_mapping.Token_definitions_unified.token -> Yyocamlc_lib.Lexer_tokens.token
  (** 古典语言转换 *)
end
