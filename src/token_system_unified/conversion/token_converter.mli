(** 骆言编译器 - 统一Token转换器接口
    
    提供统一的Token转换功能。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Yyocamlc_lib.Token_types
open Yyocamlc_lib.Error_types

(** {1 转换器类型和配置} *)

(** 转换器类型 *)
type converter_type =
  | KeywordConverter  (** 关键字转换器 *)
  | IdentifierConverter  (** 标识符转换器 *)
  | LiteralConverter  (** 字面量转换器 *)
  | OperatorConverter  (** 操作符转换器 *)
  | DelimiterConverter  (** 分隔符转换器 *)

type converter_config = {
  enable_legacy_support : bool;  (** 启用遗留支持 *)
  strict_mode : bool;  (** 严格模式 *)
  enable_aliases : bool;  (** 启用别名支持 *)
  case_sensitive : bool;  (** 大小写敏感 *)
}
(** 转换器配置 *)

val default_config : converter_config
(** 默认转换器配置 *)

(** {1 转换器接口} *)

(** 转换器模块接口 *)
module type CONVERTER = sig
  val name : string
  (** 转换器名称 *)

  val converter_type : converter_type
  (** 转换器类型 *)

  val string_to_token : converter_config -> string -> token token_result
  (** 从字符串转换为Token
      @param config 转换器配置
      @param text 输入字符串
      @return Token转换结果 *)

  val token_to_string : converter_config -> token -> string token_result
  (** 从Token转换为字符串
      @param config 转换器配置
      @param token 输入Token
      @return 字符串转换结果 *)

  val can_handle_string : string -> bool
  (** 检查是否可以处理给定的字符串
      @param text 输入字符串
      @return 如果可以处理返回true *)

  val can_handle_token : token -> bool
  (** 检查是否可以处理给定的Token
      @param token 输入Token
      @return 如果可以处理返回true *)

  val supported_tokens : unit -> token list
  (** 获取支持的Token列表
      @return 支持的Token列表 *)
end

(** {1 转换器注册表} *)

(** 转换器注册表模块 *)
module ConverterRegistry : sig
  val register_converter : (module CONVERTER) -> unit
  (** 注册转换器
      @param converter 要注册的转换器模块 *)

  val get_all_converters : unit -> (module CONVERTER) list
  (** 获取所有注册的转换器
      @return 所有转换器列表 *)

  val get_converters_by_type : converter_type -> (module CONVERTER) list
  (** 根据类型获取转换器
      @param converter_type 转换器类型
      @return 指定类型的转换器列表 *)

  val find_converter_for_string : string -> (module CONVERTER) option
  (** 查找能处理字符串的转换器
      @param text 要处理的字符串
      @return 能处理该字符串的转换器，如果没有则返回None *)

  val find_converter_for_token : token -> (module CONVERTER) option
  (** 查找能处理Token的转换器
      @param token 要处理的Token
      @return 能处理该Token的转换器，如果没有则返回None *)
end

(** {1 统一转换器} *)

(** 统一转换器模块 *)
module UnifiedConverter : sig
  val convert_string_to_token : ?config:converter_config -> string -> token token_result
  (** 从字符串转换为Token
      @param config 转换器配置，可选，默认为default_config
      @param text 输入字符串
      @return Token转换结果 *)

  val convert_token_to_string : ?config:converter_config -> token -> string token_result
  (** 从Token转换为字符串
      @param config 转换器配置，可选，默认为default_config
      @param token 输入Token
      @return 字符串转换结果 *)

  val convert_strings_to_tokens : ?config:converter_config -> string list -> token list token_result
  (** 批量转换字符串列表为Token列表
      @param config 转换器配置，可选
      @param strings 字符串列表
      @return Token列表转换结果 *)

  val convert_tokens_to_strings : ?config:converter_config -> token list -> string list token_result
  (** 批量转换Token列表为字符串列表
      @param config 转换器配置，可选
      @param tokens Token列表
      @return 字符串列表转换结果 *)

  val get_converter_stats : unit -> (string * int) list
  (** 获取转换器统计信息
      @return (转换器类型, 数量) 列表 *)
end

(** {1 兼容性支持} *)

(** 遗留系统兼容性模块 *)
module LegacySupport : sig
  val convert_from_legacy_token : 'a -> token token_result
  (** 从旧的Token类型转换
      @param legacy_token 旧Token
      @return 统一Token转换结果 *)

  val convert_to_legacy_token : token -> 'a token_result
  (** 转换为旧的Token类型
      @param unified_token 统一Token
      @return 旧Token转换结果 *)
end

(** {1 转换器工厂} *)

(** 转换器工厂模块 *)
module ConverterFactory : sig
  val create_keyword_converter : (string * token) list -> (module CONVERTER)
  (** 创建关键字转换器
      @param keyword_map (字符串, Token) 映射列表
      @return 关键字转换器模块 *)

  val create_literal_converter : unit -> (module CONVERTER)
  (** 创建字面量转换器
      @return 字面量转换器模块 *)
end
