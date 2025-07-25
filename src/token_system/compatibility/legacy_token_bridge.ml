(** 骆言编译器 - 旧Token系统兼容性桥接
    
    提供新旧Token系统之间的兼容性桥接，确保现有代码能够
    逐步迁移到新的统一Token系统。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Token_system_core.Token_types
open Token_system_core.Token_errors

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
  | LegacyTokens.IntToken i -> ok_result (Literal (IntToken i))
  | LegacyTokens.FloatToken f -> ok_result (Literal (FloatToken f))
  | LegacyTokens.StringToken s -> ok_result (Literal (StringToken s))
  | LegacyTokens.BoolToken b -> ok_result (Literal (BoolToken b))
  | LegacyTokens.ChineseNumberToken s -> ok_result (Literal (ChineseNumberToken s))
  | LegacyTokens.QuotedIdentifierToken s -> ok_result (Identifier (QuotedIdentifierToken s))
  | LegacyTokens.IdentifierTokenSpecial s -> ok_result (Identifier (IdentifierTokenSpecial s))
  | LegacyTokens.LetToken -> ok_result (CoreLanguage LetKeyword)
  | LegacyTokens.RecToken -> ok_result (CoreLanguage RecKeyword)
  | LegacyTokens.InToken -> ok_result (CoreLanguage InKeyword)
  | LegacyTokens.FunToken -> ok_result (CoreLanguage FunKeyword)
  | LegacyTokens.IfToken -> ok_result (CoreLanguage IfKeyword)
  | LegacyTokens.ThenToken -> ok_result (CoreLanguage ThenKeyword)
  | LegacyTokens.ElseToken -> ok_result (CoreLanguage ElseKeyword)
  | LegacyTokens.MatchToken -> ok_result (CoreLanguage MatchKeyword)
  | LegacyTokens.WithToken -> ok_result (CoreLanguage WithKeyword)
  | LegacyTokens.TrueToken -> ok_result (CoreLanguage TrueKeyword)
  | LegacyTokens.FalseToken -> ok_result (CoreLanguage FalseKeyword)
  | LegacyTokens.PlusToken -> ok_result (Operator Plus)
  | LegacyTokens.MinusToken -> ok_result (Operator Minus)
  | LegacyTokens.MultToken -> ok_result (Operator Multiply)
  | LegacyTokens.DivToken -> ok_result (Operator Divide)
  | LegacyTokens.EqualToken -> ok_result (Operator Equal)
  | LegacyTokens.NotEqualToken -> ok_result (Operator NotEqual)
  | LegacyTokens.LessThanToken -> ok_result (Operator LessThan)
  | LegacyTokens.GreaterThanToken -> ok_result (Operator GreaterThan)
  | LegacyTokens.ArrowToken -> ok_result (Operator Arrow)
  | LegacyTokens.LeftParenToken -> ok_result (Delimiter LeftParen)
  | LegacyTokens.RightParenToken -> ok_result (Delimiter RightParen)
  | LegacyTokens.LeftBracketToken -> ok_result (Delimiter LeftBracket)
  | LegacyTokens.RightBracketToken -> ok_result (Delimiter RightBracket)
  | LegacyTokens.SemicolonToken -> ok_result (Delimiter Semicolon)
  | LegacyTokens.CommaToken -> ok_result (Delimiter Comma)
  | LegacyTokens.EOFToken -> ok_result (Special EOF)
  | LegacyTokens.UnknownToken s -> error_result (UnknownToken (s, None))

(** 从新Token转换为旧Token *)
let convert_to_legacy_token = function
  | Literal (IntToken i) -> ok_result (LegacyTokens.IntToken i)
  | Literal (FloatToken f) -> ok_result (LegacyTokens.FloatToken f)
  | Literal (StringToken s) -> ok_result (LegacyTokens.StringToken s)
  | Literal (BoolToken b) -> ok_result (LegacyTokens.BoolToken b)
  | Literal (ChineseNumberToken s) -> ok_result (LegacyTokens.ChineseNumberToken s)
  | Identifier (QuotedIdentifierToken s) -> ok_result (LegacyTokens.QuotedIdentifierToken s)
  | Identifier (IdentifierTokenSpecial s) -> ok_result (LegacyTokens.IdentifierTokenSpecial s)
  | Identifier (SimpleIdentifier _) ->
      error_result (ConversionError ("simple_identifier", "legacy_token"))
  | CoreLanguage LetKeyword -> ok_result LegacyTokens.LetToken
  | CoreLanguage RecKeyword -> ok_result LegacyTokens.RecToken
  | CoreLanguage InKeyword -> ok_result LegacyTokens.InToken
  | CoreLanguage FunKeyword -> ok_result LegacyTokens.FunToken
  | CoreLanguage IfKeyword -> ok_result LegacyTokens.IfToken
  | CoreLanguage ThenKeyword -> ok_result LegacyTokens.ThenToken
  | CoreLanguage ElseKeyword -> ok_result LegacyTokens.ElseToken
  | CoreLanguage MatchKeyword -> ok_result LegacyTokens.MatchToken
  | CoreLanguage WithKeyword -> ok_result LegacyTokens.WithToken
  | CoreLanguage TrueKeyword -> ok_result LegacyTokens.TrueToken
  | CoreLanguage FalseKeyword -> ok_result LegacyTokens.FalseToken
  | Operator Plus -> ok_result LegacyTokens.PlusToken
  | Operator Minus -> ok_result LegacyTokens.MinusToken
  | Operator Multiply -> ok_result LegacyTokens.MultToken
  | Operator Divide -> ok_result LegacyTokens.DivToken
  | Operator Equal -> ok_result LegacyTokens.EqualToken
  | Operator NotEqual -> ok_result LegacyTokens.NotEqualToken
  | Operator LessThan -> ok_result LegacyTokens.LessThanToken
  | Operator GreaterThan -> ok_result LegacyTokens.GreaterThanToken
  | Operator Arrow -> ok_result LegacyTokens.ArrowToken
  | Delimiter LeftParen -> ok_result LegacyTokens.LeftParenToken
  | Delimiter RightParen -> ok_result LegacyTokens.RightParenToken
  | Delimiter LeftBracket -> ok_result LegacyTokens.LeftBracketToken
  | Delimiter RightBracket -> ok_result LegacyTokens.RightBracketToken
  | Delimiter Semicolon -> ok_result LegacyTokens.SemicolonToken
  | Delimiter Comma -> ok_result LegacyTokens.CommaToken
  | Special EOF -> ok_result LegacyTokens.EOFToken
  (* 不支持的Token类型 *)
  | _ -> error_result (ConversionError ("unified_token", "legacy_token"))

(** 批量转换函数 *)
let convert_legacy_token_list legacy_tokens =
  let rec convert_all acc = function
    | [] -> ok_result (List.rev acc)
    | legacy_token :: rest -> (
        match convert_from_legacy_token legacy_token with
        | Ok new_token -> convert_all (new_token :: acc) rest
        | Error err -> error_result err)
  in
  convert_all [] legacy_tokens

let convert_to_legacy_token_list new_tokens =
  let rec convert_all acc = function
    | [] -> ok_result (List.rev acc)
    | new_token :: rest -> (
        match convert_to_legacy_token new_token with
        | Ok legacy_token -> convert_all (legacy_token :: acc) rest
        | Error err -> error_result err)
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
      (fun token ->
        match token with
        | Wenyan _ -> "考虑重构文言文语法为现代中文表达"
        | Ancient _ -> "考虑简化古雅体语法为更常用的形式"
        | NaturalLanguage _ -> "考虑使用符号表示替代自然语言关键字"
        | Semantic _ -> "考虑整合到核心语言关键字中"
        | ErrorHandling _ -> "考虑使用标准异常处理语法"
        | ModuleSystem _ -> "模块系统Token需要特殊处理"
        | MacroSystem _ -> "宏系统Token需要专门的迁移策略"
        | Identifier (SimpleIdentifier _) -> "简单标识符可以保持不变或转换为引用标识符"
        | _ -> "需要手动检查和迁移")
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
        | Error err -> (conv, fail + 1, token :: unsup, err :: errs))
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
          | Wenyan _ -> "文言文关键字"
          | Ancient _ -> "古雅体关键字"
          | NaturalLanguage _ -> "自然语言关键字"
          | _ -> "其他不支持类型"))
      report.unsupported_tokens
  in
  let suggestion_lines =
    "" :: "迁移建议:"
    :: List.mapi (fun i suggestion -> Printf.sprintf "%d. %s" (i + 1) suggestion) report.suggestions
  in

  String.concat "\n" (lines @ unsupported_info @ suggestion_lines)
