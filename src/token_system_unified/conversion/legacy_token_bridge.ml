(** 骆言编译器 - 旧Token系统兼容性桥接
    
    提供新旧Token系统之间的兼容性桥接，确保现有代码能够
    逐步迁移到新的统一Token系统。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Yyocamlc_lib.Token_types
open Yyocamlc_lib.Error_types
open Token_system_unified_core.Token_errors

(** 旧Token系统的模拟类型（基于现有代码推断） *)
module LegacyTokens = struct
  (** 模拟旧的Token类型（基于现有lexer_tokens.ml等文件） *)
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
    (* 关键字 - 简化版本 *)
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

(** 从旧Token转换为新Token *)
let convert_from_legacy_token = function
  | LegacyTokens.IntToken i -> Ok (LiteralToken (Literals.IntToken i))
  | LegacyTokens.FloatToken f -> Ok (LiteralToken (Literals.FloatToken f))
  | LegacyTokens.StringToken s -> Ok (LiteralToken (Literals.StringToken s))
  | LegacyTokens.BoolToken b -> Ok (LiteralToken (Literals.BoolToken b))
  | LegacyTokens.ChineseNumberToken s -> Ok (LiteralToken (Literals.ChineseNumberToken s))
  | LegacyTokens.QuotedIdentifierToken s -> Ok (IdentifierToken (Identifiers.QuotedIdentifierToken s))
  | LegacyTokens.IdentifierTokenSpecial s -> Ok (IdentifierToken (Identifiers.IdentifierTokenSpecial s))
  | LegacyTokens.LetToken -> Ok (KeywordToken Keywords.LetKeyword)
  | LegacyTokens.RecToken -> Ok (KeywordToken Keywords.RecKeyword)
  | LegacyTokens.InToken -> Ok (KeywordToken Keywords.InKeyword)
  | LegacyTokens.FunToken -> Ok (KeywordToken Keywords.FunKeyword)
  | LegacyTokens.IfToken -> Ok (KeywordToken Keywords.IfKeyword)
  | LegacyTokens.ThenToken -> Ok (KeywordToken Keywords.ThenKeyword)
  | LegacyTokens.ElseToken -> Ok (KeywordToken Keywords.ElseKeyword)
  | LegacyTokens.MatchToken -> Ok (KeywordToken Keywords.MatchKeyword)
  | LegacyTokens.WithToken -> Ok (KeywordToken Keywords.WithKeyword)
  | LegacyTokens.TrueToken -> Ok (KeywordToken Keywords.TrueKeyword)
  | LegacyTokens.FalseToken -> Ok (KeywordToken Keywords.FalseKeyword)
  | LegacyTokens.PlusToken -> Ok (OperatorToken Operators.Plus)
  | LegacyTokens.MinusToken -> Ok (OperatorToken Operators.Minus)
  | LegacyTokens.MultToken -> Ok (OperatorToken Operators.Multiply)
  | LegacyTokens.DivToken -> Ok (OperatorToken Operators.Divide)
  | LegacyTokens.EqualToken -> Ok (OperatorToken Operators.Equal)
  | LegacyTokens.NotEqualToken -> Ok (OperatorToken Operators.NotEqual)
  | LegacyTokens.LessThanToken -> Ok (OperatorToken Operators.LessThan)
  | LegacyTokens.GreaterThanToken -> Ok (OperatorToken Operators.GreaterThan)
  | LegacyTokens.ArrowToken -> Ok (OperatorToken Operators.Arrow)
  | LegacyTokens.LeftParenToken -> Ok (DelimiterToken Delimiters.LeftParen)
  | LegacyTokens.RightParenToken -> Ok (DelimiterToken Delimiters.RightParen)
  | LegacyTokens.LeftBracketToken -> Ok (DelimiterToken Delimiters.LeftBracket)
  | LegacyTokens.RightBracketToken -> Ok (DelimiterToken Delimiters.RightBracket)
  | LegacyTokens.SemicolonToken -> Ok (DelimiterToken Delimiters.Semicolon)
  | LegacyTokens.CommaToken -> Ok (DelimiterToken Delimiters.Comma)
  | LegacyTokens.EOFToken -> Ok (SpecialToken Special.EOF)
  | LegacyTokens.UnknownToken s -> Error (SystemError ("Unknown token: " ^ s))

(** 从新Token转换为旧Token *)
let convert_to_legacy_token = function
  | LiteralToken (Literals.IntToken i) -> Ok (LegacyTokens.IntToken i)
  | LiteralToken (Literals.FloatToken f) -> Ok (LegacyTokens.FloatToken f)
  | LiteralToken (Literals.StringToken s) -> Ok (LegacyTokens.StringToken s)
  | LiteralToken (Literals.BoolToken b) -> Ok (LegacyTokens.BoolToken b)
  | LiteralToken (Literals.ChineseNumberToken s) -> Ok (LegacyTokens.ChineseNumberToken s)
  | IdentifierToken (Identifiers.QuotedIdentifierToken s) -> Ok (LegacyTokens.QuotedIdentifierToken s)
  | IdentifierToken (Identifiers.IdentifierTokenSpecial s) -> Ok (LegacyTokens.IdentifierTokenSpecial s)
  | IdentifierToken (Identifiers.ConstructorToken s) -> Ok (LegacyTokens.QuotedIdentifierToken s)
  | IdentifierToken (Identifiers.ModuleIdToken s) -> Ok (LegacyTokens.QuotedIdentifierToken s)
  | IdentifierToken (Identifiers.TypeIdToken s) -> Ok (LegacyTokens.QuotedIdentifierToken s)
  | IdentifierToken (Identifiers.LabelToken s) -> Ok (LegacyTokens.QuotedIdentifierToken s)
  | KeywordToken Keywords.LetKeyword -> Ok LegacyTokens.LetToken
  | KeywordToken Keywords.RecKeyword -> Ok LegacyTokens.RecToken
  | KeywordToken Keywords.InKeyword -> Ok LegacyTokens.InToken
  | KeywordToken Keywords.FunKeyword -> Ok LegacyTokens.FunToken
  | KeywordToken Keywords.IfKeyword -> Ok LegacyTokens.IfToken
  | KeywordToken Keywords.ThenKeyword -> Ok LegacyTokens.ThenToken
  | KeywordToken Keywords.ElseKeyword -> Ok LegacyTokens.ElseToken
  | KeywordToken Keywords.MatchKeyword -> Ok LegacyTokens.MatchToken
  | KeywordToken Keywords.WithKeyword -> Ok LegacyTokens.WithToken
  | KeywordToken Keywords.TrueKeyword -> Ok LegacyTokens.TrueToken
  | KeywordToken Keywords.FalseKeyword -> Ok LegacyTokens.FalseToken
  | OperatorToken Operators.Plus -> Ok LegacyTokens.PlusToken
  | OperatorToken Operators.Minus -> Ok LegacyTokens.MinusToken
  | OperatorToken Operators.Multiply -> Ok LegacyTokens.MultToken
  | OperatorToken Operators.Divide -> Ok LegacyTokens.DivToken
  | OperatorToken Operators.Equal -> Ok LegacyTokens.EqualToken
  | OperatorToken Operators.NotEqual -> Ok LegacyTokens.NotEqualToken
  | OperatorToken Operators.LessThan -> Ok LegacyTokens.LessThanToken
  | OperatorToken Operators.GreaterThan -> Ok LegacyTokens.GreaterThanToken
  | OperatorToken Operators.Arrow -> Ok LegacyTokens.ArrowToken
  | DelimiterToken Delimiters.LeftParen -> Ok LegacyTokens.LeftParenToken
  | DelimiterToken Delimiters.RightParen -> Ok LegacyTokens.RightParenToken
  | DelimiterToken Delimiters.LeftBracket -> Ok LegacyTokens.LeftBracketToken
  | DelimiterToken Delimiters.RightBracket -> Ok LegacyTokens.RightBracketToken
  | DelimiterToken Delimiters.Semicolon -> Ok LegacyTokens.SemicolonToken
  | DelimiterToken Delimiters.Comma -> Ok LegacyTokens.CommaToken
  | SpecialToken Special.EOF -> Ok LegacyTokens.EOFToken
  (* 不支持的Token类型 *)
  | _ -> Error (SystemError "Unsupported token conversion")

(** 批量转换函数 *)
let convert_legacy_token_list legacy_tokens =
  let rec convert_all acc = function
    | [] -> Ok (List.rev acc)
    | legacy_token :: rest -> (
        match convert_from_legacy_token legacy_token with
        | Ok new_token -> convert_all (new_token :: acc) rest
        | Error err -> Error err)
  in
  convert_all [] legacy_tokens

let convert_to_legacy_token_list new_tokens =
  let rec convert_all acc = function
    | [] -> Ok (List.rev acc)
    | new_token :: rest -> (
        match convert_to_legacy_token new_token with
        | Ok legacy_token -> convert_all (legacy_token :: acc) rest
        | Error err -> Error err)
  in
  convert_all [] new_tokens

(** 兼容性检查 *)
let check_compatibility_status () =
  let supported_conversions =
    [
      "literals";
      "basic_identifiers";
      "core_keywords";
      "basic_operators";
      "basic_delimiters";
      "special_tokens";
    ]
  in
  let unsupported_conversions =
    [
      "wenyan_keywords";
      "ancient_keywords";
      "natural_language_keywords";
      "semantic_keywords";
      "error_handling_keywords";
      "module_system_keywords";
      "macro_system_keywords";
      "simple_identifiers";
    ]
  in
  (supported_conversions, unsupported_conversions)

(** 生成迁移建议 *)
let generate_migration_suggestions unsupported_tokens =
  let suggestions =
    List.map
      (fun _token ->
        (* Note: Legacy patterns removed as they're not in current token system *)
        "考虑升级到新的Token系统")
      unsupported_tokens
  in
  suggestions

type compatibility_report = {
  total_tokens : int;
  converted_tokens : int;
  failed_tokens : int;
  unsupported_tokens : token list;
  conversion_errors : token_error list;
  suggestions : string list;
}
(** 兼容性报告 *)

let generate_compatibility_report tokens =
  let total = List.length tokens in
  let converted, failed, unsupported, errors =
    List.fold_left
      (fun (conv, fail, unsup, errs) token ->
        match convert_to_legacy_token token with
        | Ok _ -> (conv + 1, fail, unsup, errs)
        | Error (SystemError msg) -> 
            let token_err = ConversionError ("legacy_bridge", msg) in
            (conv, fail + 1, token :: unsup, token_err :: errs)
        | Error err -> 
            let token_err = ConversionError ("legacy_bridge", "Unknown error") in
            (conv, fail + 1, token :: unsup, token_err :: errs))
      (0, 0, [], []) tokens
  in

  let suggestions = generate_migration_suggestions unsupported in

  {
    total_tokens = total;
    converted_tokens = converted;
    failed_tokens = failed;
    unsupported_tokens = List.rev unsupported;
    conversion_errors = List.rev errors;
    suggestions;
  }

(** 格式化兼容性报告 *)
let format_compatibility_report report =
  let lines =
    [
      Printf.sprintf "兼容性报告";
      Printf.sprintf "==========";
      Printf.sprintf "总Token数: %d" report.total_tokens;
      Printf.sprintf "成功转换: %d" report.converted_tokens;
      Printf.sprintf "转换失败: %d" report.failed_tokens;
      Printf.sprintf "转换成功率: %.2f%%"
        (float_of_int report.converted_tokens /. float_of_int report.total_tokens *. 100.0);
      "";
      "不支持的Token类型:";
    ]
  in
  let unsupported_info =
    List.mapi
      (fun i token ->
        Printf.sprintf "%d. %s" (i + 1)
          (match token with
          | _ -> "不支持的Token类型"))
      report.unsupported_tokens
  in
  let suggestion_lines =
    "" :: "迁移建议:"
    :: List.mapi (fun i suggestion -> Printf.sprintf "%d. %s" (i + 1) suggestion) report.suggestions
  in

  String.concat "\n" (lines @ unsupported_info @ suggestion_lines)
