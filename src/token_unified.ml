(** 统一Token系统 - 技术债务清理 Issue #1375
    
    消除Token系统重复实现，建立统一的Token类型体系。
    替代重复模块：token_types.ml, token_types_core.ml, lexer_tokens.ml等
    
    Author: Beta, 代码审查专员
    Date: 2025-07-26 *)

(** 位置信息定义 *)
type position = { 
  filename : string; 
  line : int; 
  column : int; 
  offset : int 
}

(** Token元数据 *)
type token_metadata = {
  category : [`Literal | `Identifier | `Keyword | `Operator | `Delimiter | `Special];
  priority : [`High | `Medium | `Low];
  chinese_name : string option;
  aliases : string list;
  deprecated : bool;
}

(** 基础关键字类型 *)
type basic_keyword = [
  | `Let (* 让 *)
  | `Fun (* 函数 *)
  | `In (* 在 *)
  | `Rec (* 递归 *)
  | `Type (* 类型 *)
  | `Private (* 私有 *)
  | `And (* 并且 *)
  | `As (* 作为 *)
]

(** 类型系统关键字 *)
type type_keyword = [
  | `Int (* 整数 *)
  | `Float (* 浮点数 *)
  | `String (* 字符串 *)
  | `Bool (* 布尔 *)
  | `Unit (* 单元 *)
  | `List (* 列表 *)
  | `Array (* 数组 *)
  | `Option (* 选项 *)
  | `Ref (* 引用 *)
]

(** 控制流关键字 *)
type control_keyword = [
  | `If (* 如果 *)
  | `Then (* 那么 *)
  | `Else (* 否则 *)
  | `Match (* 匹配 *)
  | `With (* 与 *)
  | `When (* 当 *)
  | `Try (* 尝试 *)
  | `Catch (* 捕获 *)
  | `Finally (* 最终 *)
  | `Raise (* 抛出 *)
]

(** 古典语言关键字 *)
type classical_keyword = [
  | `Have (* 有 *)
  | `One (* 一 *)
  | `Name (* 名 *)
  | `Set (* 设 *)
  | `Also (* 亦 *)
  | `Call (* 调 *)
  | `ThenGet (* 则得 *)
  | `AlsoHave (* 亦有 *)
]

(** 操作符类型 *)
type operator = [
  (* 算术操作符 *)
  | `Plus (* + *)
  | `Minus (* - *)
  | `Multiply (* * *)
  | `Divide (* / *)
  | `Modulo (* % *)
  | `Power (* ** *)
  (* 比较操作符 *)
  | `Equal (* = *)
  | `NotEqual (* <> *)
  | `LessThan (* < *)
  | `LessEqual (* <= *)
  | `GreaterThan (* > *)
  | `GreaterEqual (* >= *)
  (* 逻辑操作符 *)
  | `LogicalAnd (* && *)
  | `LogicalOr (* || *)
  | `LogicalNot (* not *)
  (* 赋值和引用 *)
  | `Assign (* := *)
  | `Dereference (* ! *)
  | `Reference (* ref *)
  (* 函数组合 *)
  | `Arrow (* -> *)
  | `DoubleArrow (* => *)
  | `PipeForward (* |> *)
  | `PipeBackward (* <| *)
]

(** 分隔符类型 *)
type delimiter = [
  | `LeftParen (* ( *)
  | `RightParen (* ) *)
  | `LeftBrace (* { *)
  | `RightBrace (* } *)
  | `LeftBracket (* [ *)
  | `RightBracket (* ] *)
  | `Semicolon (* ; *)
  | `Comma (* , *)
  | `Dot (* . *)
  | `Colon (* : *)
  | `DoubleColon (* :: *)
]

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

(** 位置化Token *)
type positioned_token = {
  token : unified_token;
  position : position;
  metadata : token_metadata option;
}

(** Token工具函数 *)
module Utils = struct
  (** 获取Token的字符串表示 *)
  let token_to_string = function
    | IntToken i -> string_of_int i
    | FloatToken f -> string_of_float f
    | StringToken s -> "\"" ^ s ^ "\""
    | BoolToken true -> "真"
    | BoolToken false -> "假"
    | ChineseNumberToken s -> s
    | UnitToken -> "()"
    | IdentifierToken s -> s
    | QuotedIdentifierToken s -> "「" ^ s ^ "」"
    | ConstructorToken s -> s
    | ModuleNameToken s -> s
    | TypeNameToken s -> s
    | BasicKeyword `Let -> "让"
    | BasicKeyword `Fun -> "函数"
    | BasicKeyword `In -> "在"
    | BasicKeyword `Rec -> "递归"
    | BasicKeyword `Type -> "类型"
    | BasicKeyword `Private -> "私有"
    | BasicKeyword `And -> "并且"
    | BasicKeyword `As -> "作为"
    | TypeKeyword `Int -> "整数"
    | TypeKeyword `Float -> "浮点数"
    | TypeKeyword `String -> "字符串"
    | TypeKeyword `Bool -> "布尔"
    | TypeKeyword `Unit -> "单元"
    | TypeKeyword `List -> "列表"
    | TypeKeyword `Array -> "数组"
    | TypeKeyword `Option -> "选项"
    | TypeKeyword `Ref -> "引用"
    | ControlKeyword `If -> "如果"
    | ControlKeyword `Then -> "那么"
    | ControlKeyword `Else -> "否则"
    | ControlKeyword `Match -> "匹配"
    | ControlKeyword `With -> "与"
    | ControlKeyword `When -> "当"
    | ControlKeyword `Try -> "尝试"
    | ControlKeyword `Catch -> "捕获"
    | ControlKeyword `Finally -> "最终"
    | ControlKeyword `Raise -> "抛出"
    | ClassicalKeyword `Have -> "有"
    | ClassicalKeyword `One -> "一"
    | ClassicalKeyword `Name -> "名"
    | ClassicalKeyword `Set -> "设"
    | ClassicalKeyword `Also -> "亦"
    | ClassicalKeyword `Call -> "调"
    | ClassicalKeyword `ThenGet -> "则得"
    | ClassicalKeyword `AlsoHave -> "亦有"
    | OperatorToken `Plus -> "+"
    | OperatorToken `Minus -> "-"
    | OperatorToken `Multiply -> "*"
    | OperatorToken `Divide -> "/"
    | OperatorToken `Modulo -> "%"
    | OperatorToken `Power -> "**"
    | OperatorToken `Equal -> "="
    | OperatorToken `NotEqual -> "<>"
    | OperatorToken `LessThan -> "<"
    | OperatorToken `LessEqual -> "<="
    | OperatorToken `GreaterThan -> ">"
    | OperatorToken `GreaterEqual -> ">="
    | OperatorToken `LogicalAnd -> "&&"
    | OperatorToken `LogicalOr -> "||"
    | OperatorToken `LogicalNot -> "not"
    | OperatorToken `Assign -> ":="
    | OperatorToken `Dereference -> "!"
    | OperatorToken `Reference -> "ref"
    | OperatorToken `Arrow -> "->"
    | OperatorToken `DoubleArrow -> "=>"
    | OperatorToken `PipeForward -> "|>"
    | OperatorToken `PipeBackward -> "<|"
    | DelimiterToken `LeftParen -> "("
    | DelimiterToken `RightParen -> ")"
    | DelimiterToken `LeftBrace -> "{"
    | DelimiterToken `RightBrace -> "}"
    | DelimiterToken `LeftBracket -> "["
    | DelimiterToken `RightBracket -> "]"
    | DelimiterToken `Semicolon -> ";"
    | DelimiterToken `Comma -> ","
    | DelimiterToken `Dot -> "."
    | DelimiterToken `Colon -> ":"
    | DelimiterToken `DoubleColon -> "::"
    | EOF -> "<EOF>"
    | Error msg -> "<ERROR: " ^ msg ^ ">"

  (** 获取Token类别 *)
  let get_category = function
    | IntToken _ | FloatToken _ | StringToken _ | BoolToken _ 
    | ChineseNumberToken _ | UnitToken -> `Literal
    | IdentifierToken _ | QuotedIdentifierToken _ | ConstructorToken _ 
    | ModuleNameToken _ | TypeNameToken _ -> `Identifier
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