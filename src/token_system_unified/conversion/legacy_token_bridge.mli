(** 骆言编译器 - 旧Token系统兼容性桥接接口
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Yyocamlc_lib.Token_types
(* Error types included in Token_types *)
(* Token errors are included via Yyocamlc_lib.Error_types *)

(** 旧Token系统模拟 *)
module LegacyTokens : sig
  type legacy_token =
    (* 基础类型 *)
    | IntToken of int
    | FloatToken of float
    | StringToken of string
    | BoolToken of bool
    | ChineseNumberToken of string
    (* 标识符 *)
    | QuotedIdentifierToken of string
    | IdentifierTokenSpecial of string
    (* 关键字 *)
    | LetToken
    | RecToken
    | InToken
    | FunToken
    | IfToken
    | ThenToken
    | ElseToken
    | MatchToken
    | WithToken
    | TrueToken
    | FalseToken
    (* 操作符 *)
    | PlusToken
    | MinusToken
    | MultToken
    | DivToken
    | EqualToken
    | NotEqualToken
    | LessThanToken
    | GreaterThanToken
    | ArrowToken
    (* 分隔符 *)
    | LeftParenToken
    | RightParenToken
    | LeftBracketToken
    | RightBracketToken
    | SemicolonToken
    | CommaToken
    | EOFToken
    (* 其他 *)
    | UnknownToken of string
end

val convert_from_legacy_token : LegacyTokens.legacy_token -> (token, string) result
(** 转换函数 *)

val convert_to_legacy_token : token -> (LegacyTokens.legacy_token, string) result

val convert_legacy_token_list : LegacyTokens.legacy_token list -> (token list, string) result
(** 批量转换 *)

val convert_to_legacy_token_list : token list -> (LegacyTokens.legacy_token list, string) result

val check_compatibility_status : unit -> string list * string list
(** 兼容性检查 *)

type compatibility_report = {
  total_tokens : int;
  converted_tokens : int;
  failed_tokens : int;
  unsupported_tokens : token list;
  conversion_errors : string list;
  suggestions : string list;
}
(** 兼容性报告 *)

val generate_compatibility_report : token list -> compatibility_report
val format_compatibility_report : compatibility_report -> string
