(** 统一Token转换器 - 技术债务清理 Issue #1375

    整合所有Token转换逻辑到统一接口，消除重复实现。 替代模块：token_conversion_*.ml, lexer_token_converter.ml等

    Author: Beta, 代码审查专员 Date: 2025-07-26 *)

open Token_unified

type converter_strategy =
  [ `Direct  (** 直接转换策略 *) | `Classical  (** 古典语言转换策略 *) | `Natural  (** 自然语言转换策略 *) ]
(** 转换策略类型 *)

type conversion_context = {
  strategy : converter_strategy;
  allow_deprecated : bool;
  fallback_enabled : bool;
  strict_mode : bool;
}
(** 转换上下文 *)

exception Unknown_token of string
(** 转换异常 *)

exception Conversion_failed of string * string (* token, reason *)

(** 默认转换上下文 *)
let default_context =
  { strategy = `Direct; allow_deprecated = false; fallback_enabled = true; strict_mode = false }

(** 字面量转换模块 *)
module Literal = struct
  (** 转换中文数字到Token *)
  let convert_chinese_number str =
    match str with
    | "零" -> Some (IntToken 0)
    | "一" -> Some (IntToken 1)
    | "二" -> Some (IntToken 2)
    | "三" -> Some (IntToken 3)
    | "四" -> Some (IntToken 4)
    | "五" -> Some (IntToken 5)
    | "六" -> Some (IntToken 6)
    | "七" -> Some (IntToken 7)
    | "八" -> Some (IntToken 8)
    | "九" -> Some (IntToken 9)
    | "十" -> Some (IntToken 10)
    | _ when String.contains str '.' -> (
        (* 处理浮点数 - 点字符 *)
        try Some (ChineseNumberToken str) with _ -> None)
    | _ -> Some (ChineseNumberToken str)

  (** 转换字面量 *)
  let convert str =
    (* 尝试转换为整数 *)
    try Some (IntToken (int_of_string str))
    with Failure _ -> (
      (* 尝试转换为浮点数 *)
      try Some (FloatToken (float_of_string str))
      with Failure _ -> (
        (* 尝试转换为布尔值 *)
        match str with
        | "真" | "true" -> Some (BoolToken true)
        | "假" | "false" -> Some (BoolToken false)
        | "()" -> Some UnitToken
        | _ when String.length str >= 2 && str.[0] = '"' && str.[String.length str - 1] = '"' ->
            Some (StringToken (String.sub str 1 (String.length str - 2)))
        | _ -> convert_chinese_number str))
end

(** 标识符转换模块 *)
module Identifier = struct
  (** 检查是否为引用标识符 *)
  let is_quoted_identifier str =
    String.length str >= 4
    && String.sub str 0 3 = "「"
    && String.sub str (String.length str - 3) 3 = "」"

  (** 检查是否为构造器 *)
  let is_constructor str =
    String.length str > 0
    &&
    let first_char = str.[0] in
    (first_char >= 'A' && first_char <= 'Z') || first_char > '\127'

  (** 转换标识符 *)
  let convert str =
    if is_quoted_identifier str then
      let content = String.sub str 1 (String.length str - 2) in
      Some (QuotedIdentifierToken content)
    else if is_constructor str then Some (ConstructorToken str)
    else if String.contains str '.' then Some (ModuleNameToken str)
    else Some (IdentifierToken str)
end

(** 关键字转换模块 *)
module Keyword = struct
  (** 基础关键字转换 *)
  let convert_basic str =
    match str with
    | "让" | "let" -> Some `Let
    | "函数" | "fun" -> Some `Fun
    | "在" | "in" -> Some `In
    | "递归" | "rec" -> Some `Rec
    | "类型" | "type" -> Some `Type
    | "私有" | "private" -> Some `Private
    | "并且" | "and" -> Some `And
    | "作为" | "as" -> Some `As
    | _ -> None

  (** 类型关键字转换 *)
  let convert_type str =
    match str with
    | "整数" | "int" -> Some `Int
    | "浮点数" | "float" -> Some `Float
    | "字符串" | "string" -> Some `String
    | "布尔" | "bool" -> Some `Bool
    | "单元" | "unit" -> Some `Unit
    | "列表" | "list" -> Some `List
    | "数组" | "array" -> Some `Array
    | "选项" | "option" -> Some `Option
    | "引用" | "ref" -> Some `Ref
    | _ -> None

  (** 控制流关键字转换 *)
  let convert_control str =
    match str with
    | "如果" | "if" -> Some `If
    | "那么" | "then" -> Some `Then
    | "否则" | "else" -> Some `Else
    | "匹配" | "match" -> Some `Match
    | "与" | "with" -> Some `With
    | "当" | "when" -> Some `When
    | "尝试" | "try" -> Some `Try
    | "捕获" | "catch" -> Some `Catch
    | "最终" | "finally" -> Some `Finally
    | "抛出" | "raise" -> Some `Raise
    | _ -> None

  (** 古典语言关键字转换 *)
  let convert_classical str =
    match str with
    | "有" | "have" -> Some `Have
    | "一" | "one" -> Some `One
    | "名" | "name" -> Some `Name
    | "设" | "set" -> Some `Set
    | "亦" | "also" -> Some `Also
    | "调" | "call" -> Some `Call
    | "则得" | "then_get" -> Some `ThenGet
    | "亦有" | "also_have" -> Some `AlsoHave
    | _ -> None

  (** 统一关键字转换 *)
  let convert str =
    match convert_basic str with
    | Some kw -> Some (BasicKeyword kw)
    | None -> (
        match convert_type str with
        | Some kw -> Some (TypeKeyword kw)
        | None -> (
            match convert_control str with
            | Some kw -> Some (ControlKeyword kw)
            | None -> (
                match convert_classical str with
                | Some kw -> Some (ClassicalKeyword kw)
                | None -> None)))
end

(** 操作符转换模块 *)
module Operator = struct
  (** 转换操作符 *)
  let convert str =
    match str with
    (* 算术操作符 *)
    | "+" -> Some `Plus
    | "-" -> Some `Minus
    | "*" -> Some `Multiply
    | "/" -> Some `Divide
    | "%" -> Some `Modulo
    | "**" -> Some `Power
    (* 比较操作符 *)
    | "=" -> Some `Equal
    | "<>" | "!=" -> Some `NotEqual
    | "<" -> Some `LessThan
    | "<=" -> Some `LessEqual
    | ">" -> Some `GreaterThan
    | ">=" -> Some `GreaterEqual
    (* 逻辑操作符 *)
    | "&&" -> Some `LogicalAnd
    | "||" -> Some `LogicalOr
    | "not" | "非" -> Some `LogicalNot
    (* 赋值和引用 *)
    | ":=" -> Some `Assign
    | "!" -> Some `Dereference
    | "ref" | "引用" -> Some `Reference
    (* 函数组合 *)
    | "->" -> Some `Arrow
    | "=>" -> Some `DoubleArrow
    | "|>" -> Some `PipeForward
    | "<|" -> Some `PipeBackward
    | _ -> None
end

(** 分隔符转换模块 *)
module Delimiter = struct
  (** 转换分隔符 *)
  let convert str =
    match str with
    | "(" -> Some `LeftParen
    | ")" -> Some `RightParen
    | "{" -> Some `LeftBrace
    | "}" -> Some `RightBrace
    | "[" -> Some `LeftBracket
    | "]" -> Some `RightBracket
    | ";" -> Some `Semicolon
    | "," -> Some `Comma
    | "." -> Some `Dot
    | ":" -> Some `Colon
    | "::" -> Some `DoubleColon
    | _ -> None
end

(** 主转换函数 *)
let rec convert_token str context =
  (* 按优先级尝试转换 *)
  match context.strategy with
  | `Classical -> (
      (* 古典语言优先 *)
      match Keyword.convert_classical str with
      | Some kw -> Some (ClassicalKeyword kw)
      | None -> convert_token str { context with strategy = `Direct })
  | `Natural ->
      (* 自然语言优先，暂时等同于直接转换 *)
      convert_token str { context with strategy = `Direct }
  | `Direct -> (
      (* 直接转换策略 *)
      match Keyword.convert str with
      | Some token -> Some token
      | None -> (
          match Operator.convert str with
          | Some op -> Some (OperatorToken op)
          | None -> (
              match Delimiter.convert str with
              | Some delim -> Some (DelimiterToken delim)
              | None -> (
                  match Literal.convert str with
                  | Some token -> Some token
                  | None -> (
                      match Identifier.convert str with
                      | Some token -> Some token
                      | None ->
                          if context.fallback_enabled then Some (Error ("Unknown token: " ^ str))
                          else None)))))

(** 便利函数：使用默认上下文转换 *)
let convert str = convert_token str default_context

(** 严格模式转换：失败时抛出异常 *)
let convert_strict str =
  let context = { default_context with strict_mode = true; fallback_enabled = false } in
  match convert_token str context with Some token -> token | None -> raise (Unknown_token str)

(** 批量转换函数 *)
let convert_tokens str_list context =
  List.map
    (fun str ->
      match convert_token str context with
      | Some token -> token
      | None -> Error ("Failed to convert: " ^ str))
    str_list
