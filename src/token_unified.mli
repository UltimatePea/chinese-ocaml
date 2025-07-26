(** 统一Token系统接口 - 技术债务清理 Issue #1375 *)

type position = { filename : string; line : int; column : int; offset : int }
(** 位置信息 *)

type token_metadata = {
  category : [ `Literal | `Identifier | `Keyword | `Operator | `Delimiter | `Special ];
  priority : [ `High | `Medium | `Low ];
  chinese_name : string option;
  aliases : string list;
  deprecated : bool;
}
(** Token元数据 *)

type basic_keyword = [ `Let | `Fun | `In | `Rec | `Type | `Private | `And | `As ]
(** 关键字类型定义 *)

type type_keyword = [ `Int | `Float | `String | `Bool | `Unit | `List | `Array | `Option | `Ref ]

type control_keyword =
  [ `If | `Then | `Else | `Match | `With | `When | `Try | `Catch | `Finally | `Raise ]

type classical_keyword = [ `Have | `One | `Name | `Set | `Also | `Call | `ThenGet | `AlsoHave ]

type operator =
  [ `Plus
  | `Minus
  | `Multiply
  | `Divide
  | `Modulo
  | `Power
  | `Equal
  | `NotEqual
  | `LessThan
  | `LessEqual
  | `GreaterThan
  | `GreaterEqual
  | `LogicalAnd
  | `LogicalOr
  | `LogicalNot
  | `Assign
  | `Dereference
  | `Reference
  | `Arrow
  | `DoubleArrow
  | `PipeForward
  | `PipeBackward ]
(** 操作符和分隔符类型 *)

type delimiter =
  [ `LeftParen
  | `RightParen
  | `LeftBrace
  | `RightBrace
  | `LeftBracket
  | `RightBracket
  | `Semicolon
  | `Comma
  | `Dot
  | `Colon
  | `DoubleColon ]

(** 统一Token类型 *)
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
  (* 关键字 *)
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

(** Token工具函数模块 *)
module Utils : sig
  val token_to_string : unified_token -> string
  (** 将Token转换为字符串表示 *)

  val get_category :
    unified_token -> [ `Literal | `Identifier | `Keyword | `Operator | `Delimiter | `Special ]
  (** 获取Token的类别 *)

  val is_deprecated : unified_token -> bool
  (** 检查Token是否已弃用 *)

  val get_chinese_name : unified_token -> string option
  (** 获取Token的中文名称 *)
end
