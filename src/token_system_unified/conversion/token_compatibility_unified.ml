(** Token兼容性统一模块 - Conversion目录版本
    
    本模块为conversion目录提供Token兼容性功能，与src/token_compatibility_unified.ml保持一致。
    主要差别是使用Yyocamlc_lib模块路径。
    
    Author: Alpha专员, 主要工作代理 (修复版本)
    @version 3.0 (修复文件爆炸问题)
    @since 2025-07-26 Issue #1388
*)

open Yyocamlc_lib.Unified_token_core

(* Re-export all functions from the main implementation with proper module path *)

(** 分隔符映射 *)
let map_legacy_delimiter_to_unified = function
  | "(" -> Some LeftParen
  | ")" -> Some RightParen
  | "[" -> Some LeftBracket
  | "]" -> Some RightBracket
  | "{" -> Some LeftBrace
  | "}" -> Some RightBrace
  | "," | "，" | "、" -> Some Comma
  | ";" | "；" -> Some Semicolon
  | ":" | "：" -> Some Colon
  | "|" -> Some VerticalBar
  | "_" -> Some Underscore
  | _ -> None

(** 运算符映射 *)
let map_legacy_operator_to_unified = function
  | "+" -> Some PlusOp
  | "-" -> Some MinusOp
  | "*" -> Some MultiplyOp
  | "/" -> Some DivideOp
  | "mod" -> Some ModOp
  | "**" -> Some PowerOp
  | "=" -> Some EqualOp
  | "<>" -> Some NotEqualOp
  | "<" -> Some LessOp
  | ">" -> Some GreaterOp
  | "<=" -> Some LessEqualOp
  | ">=" -> Some GreaterEqualOp
  | "&&" -> Some LogicalAndOp
  | "||" -> Some LogicalOrOp
  | "!" -> Some LogicalNotOp
  | ":=" -> Some AssignOp
  | "->" -> Some ArrowOp
  | "|>" -> Some PipeOp
  | "<|" -> Some PipeBackOp
  | _ -> None

(** 字面量映射 *)
let map_legacy_literal_to_unified = function
  | s when (try let _ = int_of_string s in true with _ -> false) ->
      Some (IntToken (int_of_string s))
  | s when (try let _ = float_of_string s in true with _ -> false) ->
      Some (FloatToken (float_of_string s))
  | "true" -> Some (BoolToken true)
  | "false" -> Some (BoolToken false)
  | s when String.length s >= 2 && s.[0] = '"' && s.[String.length s - 1] = '"' ->
      let content = String.sub s 1 (String.length s - 2) in
      Some (StringToken content)
  | "零" | "一" | "二" | "三" | "四" | "五" | "六" | "七" | "八" | "九" | "十" | "百" | "千" | "万" as num ->
      Some (StringToken num)
  | "()" | "unit" -> Some (StringToken "()")
  | _ -> None

(** 标识符映射 *)
let map_legacy_identifier_to_unified = function
  | "EOF" | "Whitespace" | "Newline" | "Tab" -> None
  | s when String.length s > 0 && s.[0] = '_' -> Some (QuotedIdentifierToken s)
  | s when String.length s > 0 && Char.code s.[0] >= 97 && Char.code s.[0] <= 122 ->
      Some (IdentifierToken s)
  | s when String.length s > 0 && Char.code s.[0] >= 65 && Char.code s.[0] <= 90 ->
      Some (ConstructorToken s)
  | s when String.length s > 0 && Char.code s.[0] > 127 ->
      Some (IdentifierToken s)
  | s when String.length s >= 3 && s.[0] = '\'' && s.[String.length s - 1] = '\'' ->
      let content = String.sub s 1 (String.length s - 2) in
      Some (QuotedIdentifierToken content)
  | _ -> None

(** 特殊Token映射 *)
let map_legacy_special_to_unified = function
  | "EOF" -> Some (StringToken "EOF")
  | "\n" | "\t" | "\\n" | "\\t" -> Some (StringToken "whitespace")
  | s when (String.length s >= 4 && String.sub s 0 2 = "(*" && String.sub s (String.length s - 2) 2 = "*)")
        || (String.length s >= 2 && String.sub s 0 2 = "//") ->
      Some (StringToken s)
  | _ -> None

(** 关键字映射 - 简化的统一映射 *)
let map_legacy_keyword_to_unified = function
  (* 基础关键字 *)
  | "let" -> Some LetKeyword
  | "rec" -> Some RecKeyword
  | "in" -> Some InKeyword
  | "fun" -> Some FunKeyword
  | "if" -> Some IfKeyword
  | "then" -> Some ThenKeyword
  | "else" -> Some ElseKeyword
  | "match" -> Some MatchKeyword
  | "with" -> Some WithKeyword
  | "true" -> Some TrueKeyword
  | "false" -> Some FalseKeyword
  | "and" -> Some AndKeyword
  | "or" -> Some OrKeyword
  | "not" -> Some NotKeyword
  | "type" -> Some TypeKeyword
  | "module" -> Some ModuleKeyword
  | "ref" -> Some RefKeyword
  | "as" -> Some AsKeyword
  | "of" -> Some OfKeyword
  (* 扩展关键字 - 简化映射 *)
  | "HaveKeyword" | "SetKeyword" -> Some LetKeyword
  | "NameKeyword" | "AsForKeyword" -> Some AsKeyword
  | "AlsoKeyword" -> Some AndKeyword
  | "ThenGetKeyword" | "ReturnWhenKeyword" -> Some ThenKeyword
  | "CallKeyword" | "DefineKeyword" | "AncientDefineKeyword" -> Some FunKeyword
  | "ValueKeyword" -> Some ValKeyword
  | "AcceptKeyword" | "InputKeyword" -> Some InKeyword
  | "ElseReturnKeyword" -> Some ElseKeyword
  | "OutputKeyword" | "ReturnKeyword" -> Some ReturnKeyword
  | "EndKeyword" | "AncientEndKeyword" -> Some EndKeyword
  | "TryKeyword" -> Some TryKeyword
  | "ThrowKeyword" -> Some RaiseKeyword
  | _ -> None

(** 核心转换函数 *)
let convert_legacy_token_string token_str _value_opt =
  match map_legacy_keyword_to_unified token_str with
  | Some result -> Some result
  | None -> match map_legacy_operator_to_unified token_str with
    | Some result -> Some result
    | None -> match map_legacy_delimiter_to_unified token_str with
      | Some result -> Some result
      | None -> match map_legacy_literal_to_unified token_str with
        | Some result -> Some result
        | None -> match map_legacy_identifier_to_unified token_str with
          | Some result -> Some result
          | None -> map_legacy_special_to_unified token_str

(** 创建兼容的带位置Token *)
let make_compatible_positioned_token token_str value_opt filename line column =
  match convert_legacy_token_string token_str value_opt with
  | Some token ->
      let position = { filename; line; column; offset = 0 } in
      Some { token; position; metadata = None }
  | None -> None

(** 检查Token字符串是否与统一系统兼容 *)
let is_compatible_token_string token_str =
  match convert_legacy_token_string token_str None with
  | Some _ -> true
  | None -> false

(** 获取所有支持的遗留Token - 简化版本 *)
let get_supported_legacy_tokens () =
  let delimiters = ["("; ")"; "["; "]"; "{"; "}"; ","; ";"; ":"; "|"; "_"; "，"; "、"; "；"; "："] in
  let operators = ["+"; "-"; "*"; "/"; "mod"; "**"; "="; "<>"; "<"; ">"; "<="; ">="; "&&"; "||"; "!"; ":="; "->"; "|>"; "<|"] in
  let keywords = ["let"; "if"; "then"; "else"; "match"; "with"; "fun"; "type"] in
  let literals = ["123"; "45.67"; "true"; "false"; "\"hello\""; "()"; "一"] in
  List.concat [delimiters; operators; keywords; literals]

(** 生成兼容性报告 - 简化版本 *)
let generate_compatibility_report () =
  let supported_tokens = get_supported_legacy_tokens () in
  let total_count = List.length supported_tokens in
  Printf.sprintf "Token兼容性报告: 支持%d个遗留Token" total_count

(** 生成详细的兼容性报告 - 简化版本 *)
let generate_detailed_compatibility_report () =
  let supported_tokens = get_supported_legacy_tokens () in
  let total_count = List.length supported_tokens in
  Printf.sprintf "详细Token兼容性报告: 支持%d个遗留Token (分隔符:15, 运算符:19)" total_count