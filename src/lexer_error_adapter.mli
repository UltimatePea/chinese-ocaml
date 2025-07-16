(** 词法分析器错误处理适配器 - 统一错误处理系统迁移 *)

open Token_types
open Compiler_errors

val convert_position : Token_types.position -> Lexer.position
(** 将Token_types.position转换为Lexer.position *)

val create_lex_error : ?suggestions:string list -> string -> Token_types.position -> 'a error_result
(** 创建词法错误的统一处理函数 *)

(** 词法分析器错误处理结果类型 *)
type 'a lex_result = LexOk of 'a | LexError of error_info

val safe_lex_operation : (unit -> 'a) -> 'a lex_result
(** 安全的词法分析函数包装器 *)

(** 词法分析器错误处理的便捷函数 *)
module LexErrorHandler : sig
  val unterminated_comment : Token_types.position -> 'a error_result
  val unterminated_chinese_comment : Token_types.position -> 'a error_result
  val unterminated_string : Token_types.position -> 'a error_result
  val unterminated_quoted_identifier : Token_types.position -> 'a error_result
  val identifiers_must_be_quoted : Token_types.position -> 'a error_result
  val ascii_letters_as_keywords_only : Token_types.position -> 'a error_result
end

val raise_from_error_result : 'a lex_result -> 'a
(** 兼容性函数：将错误结果转换为异常 *)

val process_lex_results : 'a lex_result list -> 'a list * error_info list
(** 批量处理词法分析结果 *)

val attempt_error_recovery : error_info -> Lexer_core.lexer_state -> string option
(** 错误恢复策略 *)

val integrate_with_error_handler :
  Lexer_core.lexer_state -> error_info -> Error_handler.enhanced_error_info
(** 词法分析器状态与统一错误处理系统的集成 *)
