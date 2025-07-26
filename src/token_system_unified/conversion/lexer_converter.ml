(** 骆言Token系统整合重构 - 词法分析器Token转换 将原有的分散Token类型转换为统一的核心Token类型 *)

open Yyocamlc_lib.Token_types

(** 词法分析器Token转换器 *)
module LexerConverter = struct
  type input = string * position
  type output = token * position

  let name = "LexerConverter"
  let version = "1.0.0"

  (** 检查输入兼容性 *)
  let is_compatible (text, _pos) = String.length text > 0

  (** 关键字转换映射 *)
  let keyword_mapping =
    [
      ("让", Keywords.LetKeyword);
      ("如果", Keywords.IfKeyword);
      ("那么", Keywords.ThenKeyword);
      ("否则", Keywords.ElseKeyword);
      ("函数", Keywords.FunKeyword);
      ("递归", Keywords.RecKeyword);
      ("整数", Keywords.TypeKeyword); (* 类型相关 *)
      ("小数", Keywords.TypeKeyword); (* 类型相关 *)
      ("字符串", Keywords.TypeKeyword); (* 类型相关 *)
      ("布尔", Keywords.TypeKeyword); (* 类型相关 *)
      ("列表", Keywords.TypeKeyword); (* 类型相关 *)
      ("类型", Keywords.TypeKeyword);
      ("匹配", Keywords.MatchKeyword);
      ("与", Keywords.WithKeyword);
      ("当", Keywords.WhenKeyword);
      ("尝试", Keywords.TryKeyword);
      ("循环", Keywords.WhileKeyword);
      ("遍历", Keywords.ForKeyword);
      ("模块", Keywords.ModuleKeyword);
      ("打开", Keywords.OpenKeyword);
      ("包含", Keywords.IncludeKeyword);
      ("结构", Keywords.StructKeyword);
      ("签名", Keywords.SigKeyword);
    ]

  (** 操作符转换映射 *)
  let operator_mapping =
    [
      ("+", Arithmetic Plus);
      ("-", Arithmetic Minus);
      ("*", Arithmetic Multiply);
      ("/", Arithmetic Divide);
      ("%", Arithmetic Modulo);
      ("**", Arithmetic Power);
      ("=", Comparison Equal);
      ("!=", Comparison NotEqual);
      ("<", Comparison LessThan);
      ("<=", Comparison LessEqual);
      (">", Comparison GreaterThan);
      (">=", Comparison GreaterEqual);
      ("并且", Logical And);
      ("或者", Logical Or);
      ("非", Logical Not);
      (":=", Assignment Assign);
      ("+=", Assignment PlusAssign);
      ("-=", Assignment MinusAssign);
      ("*=", Assignment MultiplyAssign);
      ("/=", Assignment DivideAssign);
    ]

  (** 分隔符转换映射 *)
  let delimiter_mapping =
    [
      ("(", Parenthesis LeftParen);
      (")", Parenthesis RightParen);
      ("[", Parenthesis LeftBracket);
      ("]", Parenthesis RightBracket);
      ("{", Parenthesis LeftBrace);
      ("}", Parenthesis RightBrace);
      (",", Punctuation Comma);
      (";", Punctuation Semicolon);
      (":", Punctuation Colon);
      (".", Punctuation Dot);
      ("?", Punctuation QuestionMark);
      ("!", Punctuation ExclamationMark);
      ("\n", Special Newline);
      (" ", Special Whitespace);
      ("\t", Special Tab);
    ]

  (** 尝试解析为整数 *)
  let try_parse_int text = try Some (int_of_string text) with Failure _ -> None

  (** 尝试解析为浮点数 *)
  let try_parse_float text = try Some (float_of_string text) with Failure _ -> None

  (** 检查是否为中文数字 *)
  let is_chinese_number text =
    let chinese_digits = [ "零"; "一"; "二"; "三"; "四"; "五"; "六"; "七"; "八"; "九"; "十"; "百"; "千"; "万" ] in
    List.exists (fun digit -> String.contains text (String.get digit 0)) chinese_digits

  (** 检查是否为布尔值 *)
  let try_parse_bool text =
    match text with "真" | "true" -> Some true | "假" | "false" -> Some false | _ -> None

  (** 检查是否为字符串字面量 *)
  let is_string_literal text =
    String.length text >= 2 && text.[0] = '"' && text.[String.length text - 1] = '"'

  (** 提取字符串内容 *)
  let extract_string_content text = String.sub text 1 (String.length text - 2)

  (** 检查是否为标识符 *)
  let is_identifier text =
    let is_alpha_or_chinese c =
      (c >= 'a' && c <= 'z')
      || (c >= 'A' && c <= 'Z')
      || (Char.code c >= 0x4e00 && Char.code c <= 0x9fff)
    in
    let is_alnum_or_chinese_or_underscore c =
      is_alpha_or_chinese c || (c >= '0' && c <= '9') || c = '_'
    in
    String.length text > 0
    && is_alpha_or_chinese text.[0]
    && String.for_all is_alnum_or_chinese_or_underscore text

  (** 检查是否为引用标识符 *)
  let is_quoted_identifier text =
    String.length text >= 2 && text.[0] = '\'' && text.[String.length text - 1] = '\''

  (** 提取引用标识符内容 *)
  let extract_quoted_identifier_content text = String.sub text 1 (String.length text - 2)

  (** 主要转换函数 *)
  let convert (text, position) =
    let token =
      (* 尝试匹配关键字 *)
      match List.assoc_opt text keyword_mapping with
      | Some kw -> Keyword kw
      | None -> (
          (* 尝试匹配操作符 *)
          match List.assoc_opt text operator_mapping with
          | Some op -> Operator op
          | None -> (
              (* 尝试匹配分隔符 *)
              match List.assoc_opt text delimiter_mapping with
              | Some del -> Delimiter del
              | None -> (
                  if
                    (* 尝试解析字面量 *)
                    is_string_literal text
                  then Literal (StringToken (extract_string_content text))
                  else
                    match try_parse_int text with
                    | Some i -> Literal (IntToken i)
                    | None -> (
                        match try_parse_float text with
                        | Some f -> Literal (FloatToken f)
                        | None -> (
                            match try_parse_bool text with
                            | Some b -> Literal (BoolToken b)
                            | None ->
                                if is_chinese_number text then Literal (ChineseNumberToken text)
                                else if is_quoted_identifier text then
                                  Identifier
                                    (QuotedIdentifierToken (extract_quoted_identifier_content text))
                                else if is_identifier text then
                                  Identifier (IdentifierTokenSpecial text)
                                else
                                  (* 默认作为自然语言处理 *)
                                  NaturalLanguage (ChineseText text))))))
    in
    (token, position)
end

(** 批量词法转换器 *)
module BatchLexerConverter = struct
  include LexerConverter

  (** 批量转换 *)
  let convert_batch inputs = List.map convert inputs

  (** 并行转换（简化版，实际应该使用真正的并行处理） *)
  let convert_parallel inputs = convert_batch inputs
end

(** 安全词法转换器 *)
module SafeLexerConverter = struct
  type input = string * position
  type output = token * position

  type error =
    | IncompatibleInput of string
    | ConversionFailed of string
    | UnsupportedFeature of string

  type 'a result = ('a, error) Result.t

  let name = "SafeLexerConverter"
  let version = "1.0.0"

  (** 安全转换函数 *)
  let safe_convert input =
    try
      if LexerConverter.is_compatible input then Ok (LexerConverter.convert input)
      else Error (IncompatibleInput "Input text is empty or invalid")
    with
    | Failure msg -> Error (ConversionFailed msg)
    | Invalid_argument msg -> Error (UnsupportedFeature msg)
    | _ -> Error (ConversionFailed "Unknown conversion error")

  (** 批量安全转换 *)
  let safe_convert_batch inputs =
    let results = List.map safe_convert inputs in
    let successes = List.filter_map (function Ok x -> Some x | Error _ -> None) results in
    let errors = List.filter_map (function Error e -> Some e | Ok _ -> None) results in
    if List.length errors = 0 then Ok successes else Error errors
end
