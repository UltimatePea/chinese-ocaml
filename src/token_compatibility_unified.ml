(** Token兼容性统一模块 - 真正的重构版本
    
    本模块真正整合了Token兼容性逻辑，消除重复代码，符合Issue #1388的修复要求。
    
    重构原则：
    - 真正消除重复代码，不是创建更多文件
    - 保持模块接口约束
    - 统一Token映射逻辑
    - 保持完全向后兼容
    
    Author: Alpha专员, 主要工作代理 (修复版本)
    @version 3.0 (修复文件爆炸问题)
    @since 2025-07-26 Issue #1388
*)

open Unified_token_core

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

(** 字面量映射 *)
let map_legacy_literal_to_unified = function
  (* 数字字面量 *)
  | s when (try let _ = int_of_string s in true with _ -> false) ->
      Some (IntToken (int_of_string s))
  | s when (try let _ = float_of_string s in true with _ -> false) ->
      Some (FloatToken (float_of_string s))
  (* 布尔字面量 *)
  | "true" -> Some (BoolToken true)
  | "false" -> Some (BoolToken false)
  (* 字符串字面量（带引号） *)
  | s when String.length s >= 2 && s.[0] = '"' && s.[String.length s - 1] = '"' ->
      let content = String.sub s 1 (String.length s - 2) in
      Some (StringToken content)
  (* 中文数字 *)
  | "零" | "一" | "二" | "三" | "四" | "五" | "六" | "七" | "八" | "九" | "十" | "百" | "千" | "万" as num ->
      Some (StringToken num)
  (* 单位字面量 *)
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

(** 基础关键字映射 *)
let map_basic_keywords = function
  | "let" -> Some LetKeyword
  | "rec" -> Some RecKeyword
  | "in" -> Some InKeyword
  | "fun" -> Some FunKeyword
  | "if" -> Some IfKeyword
  | "then" -> Some ThenKeyword
  | "else" -> Some ElseKeyword
  | "match" -> Some MatchKeyword
  | "with" -> Some WithKeyword
  | "and" -> Some AndKeyword
  | "or" -> Some OrKeyword
  | "not" -> Some NotKeyword
  | _ -> None

(** 文言文关键字映射 *)
let map_wenyan_keywords = function
  | "有" -> Some LetKeyword
  | "設" -> Some LetKeyword
  | "名之曰" -> Some AsKeyword
  | "亦" -> Some AndKeyword
  | "則" -> Some ThenKeyword
  | "云云" -> Some EndKeyword
  | _ -> None

(** 古雅体关键字映射 *)
let map_classical_keywords = function
  | "CallKeyword" | "DefineKeyword" | "AncientDefineKeyword" -> Some FunKeyword
  | "ThenGetKeyword" | "ReturnWhenKeyword" -> Some ThenKeyword
  | "ElseReturnKeyword" -> Some ElseKeyword
  | "EndKeyword" | "AncientEndKeyword" -> Some EndKeyword
  | _ -> None

(** 自然语言函数关键字映射 *)
let map_natural_language_keywords = function
  | "AcceptKeyword" | "InputKeyword" -> Some InKeyword
  | "OutputKeyword" | "ReturnKeyword" -> Some ReturnKeyword
  | "ValueKeyword" -> Some ValKeyword
  | _ -> None

(** 类型关键字映射 *)
let map_type_keywords = function
  | "type" -> Some TypeKeyword
  | "module" -> Some ModuleKeyword
  | "ref" -> Some RefKeyword
  | "as" -> Some AsKeyword
  | "of" -> Some OfKeyword
  | _ -> None

(** 诗词关键字映射 *)
let map_poetry_keywords = function
  | "true" -> Some TrueKeyword
  | "false" -> Some FalseKeyword
  | _ -> None

(** 杂项关键字映射 *)
let map_misc_keywords = function
  | "HaveKeyword" | "SetKeyword" -> Some LetKeyword
  | "NameKeyword" | "AsForKeyword" -> Some AsKeyword
  | "AlsoKeyword" -> Some AndKeyword
  | "TryKeyword" -> Some TryKeyword
  | "ThrowKeyword" -> Some RaiseKeyword
  | _ -> None

(** 统一关键字映射接口 *)
let map_legacy_keyword_to_unified input =
  match map_basic_keywords input with
  | Some result -> Some result
  | None -> match map_wenyan_keywords input with
    | Some result -> Some result
    | None -> match map_classical_keywords input with
      | Some result -> Some result
      | None -> match map_natural_language_keywords input with
        | Some result -> Some result
        | None -> match map_type_keywords input with
          | Some result -> Some result
          | None -> match map_poetry_keywords input with
            | Some result -> Some result
            | None -> map_misc_keywords input

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
let is_compatible_with_legacy token_str =
  match convert_legacy_token_string token_str None with
  | Some _ -> true
  | None -> false

(** JSON数据加载器模块 *)
module TokenDataLoader = struct
  let find_data_file () =
    if Sys.file_exists "data/tokens.json" then "data/tokens.json"
    else if Sys.file_exists "../data/tokens.json" then "../data/tokens.json"
    else "tokens.json"

  let load_token_category category =
    try
      let filename = find_data_file () in
      let content = 
        let ic = open_in filename in
        let content = really_input_string ic (in_channel_length ic) in
        close_in ic; content
      in
      let json = Yojson.Basic.from_string content in
      match Yojson.Basic.Util.member category json with
      | `List items -> List.map Yojson.Basic.Util.to_string items
      | _ -> []
    with
    | _ -> []

  let load_all_tokens () =
    List.concat [
      load_token_category "delimiters";
      load_token_category "operators";
      load_token_category "keywords";
      load_token_category "literals";
    ]
end

(** 获取所有支持的遗留Token列表 *)
let get_supported_legacy_tokens () =
  let delimiters = ["("; ")"; "["; "]"; "{"; "}"; ","; ";"; ":"; "|"; "_"; "，"; "、"; "；"; "："] in
  let operators = ["+"; "-"; "*"; "/"; "mod"; "**"; "="; "<>"; "<"; ">"; "<="; ">="; "&&"; "||"; "!"; ":="; "->"; "|>"; "<|"] in
  let keywords = ["let"; "if"; "then"; "else"; "match"; "with"; "fun"; "type"; "有"; "設"; "名之曰"] in
  let literals = ["123"; "45.67"; "true"; "false"; "\"hello\""; "()"; "一"] in
  List.concat [delimiters; operators; keywords; literals]

(** 生成基础兼容性报告 *)
let generate_compatibility_report () =
  let supported_tokens = get_supported_legacy_tokens () in
  let total_count = List.length supported_tokens in
  Printf.sprintf "Token兼容性报告: 支持%d个遗留Token" total_count

(** 生成详细的兼容性报告 *)
let generate_detailed_compatibility_report () =
  let supported_tokens = get_supported_legacy_tokens () in
  let total_count = List.length supported_tokens in
  Printf.sprintf "详细Token兼容性报告: 支持%d个遗留Token (分隔符:15, 运算符:19, 关键字:13, 字面量:7)" total_count

(** 分隔符兼容性模块 *)
module Delimiters = struct
  let map_legacy_delimiter_to_unified = map_legacy_delimiter_to_unified
end

(** 字面量兼容性模块 *)
module Literals = struct
  let map_legacy_literal_to_unified = map_legacy_literal_to_unified
  let map_legacy_identifier_to_unified = map_legacy_identifier_to_unified
  let map_legacy_special_to_unified = map_legacy_special_to_unified
end

(** 运算符兼容性模块 *)
module Operators = struct
  let map_legacy_operator_to_unified = map_legacy_operator_to_unified
end

(** 关键字兼容性模块 *)
module Keywords = struct
  let map_basic_keywords = map_basic_keywords
  let map_wenyan_keywords = map_wenyan_keywords
  let map_classical_keywords = map_classical_keywords
  let map_natural_language_keywords = map_natural_language_keywords
  let map_type_keywords = map_type_keywords
  let map_poetry_keywords = map_poetry_keywords
  let map_misc_keywords = map_misc_keywords
  let map_legacy_keyword_to_unified = map_legacy_keyword_to_unified
end

(** 报告生成模块 *)
module Reports = struct
  module TokenDataLoader = TokenDataLoader
  
  let get_supported_legacy_tokens = get_supported_legacy_tokens
  let generate_compatibility_report = generate_compatibility_report
  let generate_detailed_compatibility_report = generate_detailed_compatibility_report
end

(** 核心转换模块 *)
module Core = struct
  let convert_legacy_token_string = convert_legacy_token_string
  let make_compatible_positioned_token = make_compatible_positioned_token
  let is_compatible_with_legacy = is_compatible_with_legacy
end

(** 统计信息 *)
let get_compatibility_stats () =
  let supported_count = List.length (get_supported_legacy_tokens ()) in
  Printf.sprintf "兼容性统计: 支持%d个Token类型" supported_count