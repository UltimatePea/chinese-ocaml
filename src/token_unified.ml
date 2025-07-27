(** 统一Token系统 - 技术债务清理 Issue #1375

    消除Token系统重复实现，建立统一的Token类型体系。 替代重复模块：token_types.ml, token_types_core.ml, lexer_tokens.ml等

    Author: Beta, 代码审查专员 Date: 2025-07-26 *)

type position = { filename : string; line : int; column : int; offset : int }
(** 位置信息定义 *)

type token_metadata = {
  category : [ `Literal | `Identifier | `Keyword | `Operator | `Delimiter | `Special ];
  priority : [ `High | `Medium | `Low ];
  chinese_name : string option;
  aliases : string list;
  deprecated : bool;
}
(** Token元数据 *)

type basic_keyword =
  [ `Let (* 让 *)
  | `Fun (* 函数 *)
  | `In (* 在 *)
  | `Rec (* 递归 *)
  | `Type (* 类型 *)
  | `Private (* 私有 *)
  | `And (* 并且 *)
  | `As (* 作为 *) ]
(** 基础关键字类型 *)

type type_keyword =
  [ `Int (* 整数 *)
  | `Float (* 浮点数 *)
  | `String (* 字符串 *)
  | `Bool (* 布尔 *)
  | `Unit (* 单元 *)
  | `List (* 列表 *)
  | `Array (* 数组 *)
  | `Option (* 选项 *)
  | `Ref (* 引用 *) ]
(** 类型系统关键字 *)

type control_keyword =
  [ `If (* 如果 *)
  | `Then (* 那么 *)
  | `Else (* 否则 *)
  | `Match (* 匹配 *)
  | `With (* 与 *)
  | `When (* 当 *)
  | `Try (* 尝试 *)
  | `Catch (* 捕获 *)
  | `Finally (* 最终 *)
  | `Raise (* 抛出 *) ]
(** 控制流关键字 *)

type classical_keyword =
  [ `Have (* 有 *)
  | `One (* 一 *)
  | `Name (* 名 *)
  | `Set (* 设 *)
  | `Also (* 亦 *)
  | `Call (* 调 *)
  | `ThenGet (* 则得 *)
  | `AlsoHave (* 亦有 *) ]
(** 古典语言关键字 *)

type operator =
  [ (* 算术操作符 *)
    `Plus
    (* + *)
  | `Minus (* - *)
  | `Multiply (* * *)
  | `Divide (* / *)
  | `Modulo (* % *)
  | `Power (* ** *)
  | (* 比较操作符 *)
    `Equal
    (* = *)
  | `NotEqual (* <> *)
  | `LessThan (* < *)
  | `LessEqual (* <= *)
  | `GreaterThan (* > *)
  | `GreaterEqual (* >= *)
  | (* 逻辑操作符 *)
    `LogicalAnd
    (* && *)
  | `LogicalOr (* || *)
  | `LogicalNot (* not *)
  | (* 赋值和引用 *)
    `Assign
    (* := *)
  | `Dereference (* ! *)
  | `Reference (* ref *)
  | (* 函数组合 *)
    `Arrow
    (* -> *)
  | `DoubleArrow (* => *)
  | `PipeForward (* |> *)
  | `PipeBackward (* <| *) ]
(** 操作符类型 *)

type delimiter =
  [ `LeftParen (* ( *)
  | `RightParen (* ) *)
  | `LeftBrace (* { *)
  | `RightBrace (* } *)
  | `LeftBracket (* [ *)
  | `RightBracket (* ] *)
  | `Semicolon (* ; *)
  | `Comma (* , *)
  | `Dot (* . *)
  | `Colon (* : *)
  | `DoubleColon (* :: *) ]
(** 分隔符类型 *)

(** 统一Token类型定义 *)
type unified_token =
  (* 字面量 *)
  | IntToken of int
  | FloatToken of float
  | StringToken of string
  | BoolToken of bool
  | ChineseNumberToken of string
  | UnitToken
  (* 标识符 *)
  | IdentifierToken of string
  | QuotedIdentifierToken of string
  | ConstructorToken of string
  | ModuleNameToken of string
  | TypeNameToken of string
  (* 关键字 - 按类别组织 *)
  | BasicKeyword of basic_keyword
  | TypeKeyword of type_keyword
  | ControlKeyword of control_keyword
  | ClassicalKeyword of classical_keyword
  (* 操作符和分隔符 *)
  | OperatorToken of operator
  | DelimiterToken of delimiter
  (* 特殊Token *)
  | EOF
  | Error of string

type positioned_token = {
  token : unified_token;
  position : position;
  metadata : token_metadata option;
}
(** 位置化Token *)

(** Token工具函数 *)
module Utils = struct
  (** 获取字面量Token的字符串表示 *)
  let literal_token_to_string = function
    | IntToken i -> string_of_int i
    | FloatToken f -> string_of_float f
    | StringToken s -> "\"" ^ s ^ "\""
    | BoolToken true -> "真"
    | BoolToken false -> "假"
    | ChineseNumberToken s -> s
    | UnitToken -> "()"
    | _ -> "<非字面量token>"

  (** 获取标识符Token的字符串表示 *)
  let identifier_token_to_string = function
    | IdentifierToken s -> s
    | QuotedIdentifierToken s -> "「" ^ s ^ "」"
    | ConstructorToken s -> s
    | ModuleNameToken s -> s
    | TypeNameToken s -> s
    | _ -> "<非标识符token>"

  (** 获取基础关键字Token的字符串表示 *)
  let basic_keyword_to_string = function
    | `Let -> "让"
    | `Fun -> "函数"
    | `In -> "在"
    | `Rec -> "递归"
    | `Type -> "类型"
    | `Private -> "私有"
    | `And -> "并且"
    | `As -> "作为"

  (** 获取类型关键字Token的字符串表示 *)
  let type_keyword_to_string = function
    | `Int -> "整数"
    | `Float -> "浮点数"
    | `String -> "字符串"
    | `Bool -> "布尔"
    | `Unit -> "单元"
    | `List -> "列表"
    | `Array -> "数组"
    | `Option -> "选项"
    | `Ref -> "引用"

  (** 获取控制关键字Token的字符串表示 *)
  let control_keyword_to_string = function
    | `If -> "如果"
    | `Then -> "那么"
    | `Else -> "否则"
    | `Match -> "匹配"
    | `With -> "与"
    | `When -> "当"
    | `Try -> "尝试"
    | `Catch -> "捕获"
    | `Finally -> "最终"
    | `Raise -> "抛出"

  (** 获取古典关键字Token的字符串表示 *)
  let classical_keyword_to_string = function
    | `Have -> "有"
    | `One -> "一"
    | `Name -> "名"
    | `Set -> "设"
    | `Also -> "亦"
    | `Call -> "调"
    | `ThenGet -> "则得"
    | `AlsoHave -> "亦有"

  (** 获取操作符Token的字符串表示 *)
  let operator_token_to_string = function
    | `Plus -> "+"
    | `Minus -> "-"
    | `Multiply -> "*"
    | `Divide -> "/"
    | `Modulo -> "%"
    | `Power -> "**"
    | `Equal -> "="
    | `NotEqual -> "<>"
    | `LessThan -> "<"
    | `LessEqual -> "<="
    | `GreaterThan -> ">"
    | `GreaterEqual -> ">="
    | `LogicalAnd -> "&&"
    | `LogicalOr -> "||"
    | `LogicalNot -> "not"
    | `Assign -> ":="
    | `Dereference -> "!"
    | `Reference -> "ref"
    | `Arrow -> "->"
    | `DoubleArrow -> "=>"
    | `PipeForward -> "|>"
    | `PipeBackward -> "<|"

  (** 获取分隔符Token的字符串表示 *)
  let delimiter_token_to_string = function
    | `LeftParen -> "("
    | `RightParen -> ")"
    | `LeftBrace -> "{"
    | `RightBrace -> "}"
    | `LeftBracket -> "["
    | `RightBracket -> "]"
    | `Semicolon -> ";"
    | `Comma -> ","
    | `Dot -> "."
    | `Colon -> ":"
    | `DoubleColon -> "::"

  (** 获取Token的字符串表示 - 重构后的主函数 *)
  let token_to_string = function
    | (IntToken _ | FloatToken _ | StringToken _ | BoolToken _ | ChineseNumberToken _ | UnitToken)
      as t ->
        literal_token_to_string t
    | ( IdentifierToken _ | QuotedIdentifierToken _ | ConstructorToken _ | ModuleNameToken _
      | TypeNameToken _ ) as t ->
        identifier_token_to_string t
    | BasicKeyword k -> basic_keyword_to_string k
    | TypeKeyword k -> type_keyword_to_string k
    | ControlKeyword k -> control_keyword_to_string k
    | ClassicalKeyword k -> classical_keyword_to_string k
    | OperatorToken op -> operator_token_to_string op
    | DelimiterToken delim -> delimiter_token_to_string delim
    | EOF -> "<EOF>"
    | Error msg -> "<ERROR: " ^ msg ^ ">"

  (** 获取Token类别 *)
  let get_category = function
    | IntToken _ | FloatToken _ | StringToken _ | BoolToken _ | ChineseNumberToken _ | UnitToken ->
        `Literal
    | IdentifierToken _ | QuotedIdentifierToken _ | ConstructorToken _ | ModuleNameToken _
    | TypeNameToken _ ->
        `Identifier
    | BasicKeyword _ | TypeKeyword _ | ControlKeyword _ | ClassicalKeyword _ -> `Keyword
    | OperatorToken _ -> `Operator
    | DelimiterToken _ -> `Delimiter
    | EOF | Error _ -> `Special

  (** 检查Token是否已弃用 *)
  let is_deprecated = function
    (* 可在此标记已弃用的Token *)
    | _ -> false

  (** 获取Token的中文名称 *)
  let get_chinese_name = function
    | BasicKeyword `Let -> Some "让"
    | BasicKeyword `Fun -> Some "函数"
    | ControlKeyword `If -> Some "如果"
    | TypeKeyword `Int -> Some "整数"
    | ClassicalKeyword `Have -> Some "有"
    | _ -> None
end
