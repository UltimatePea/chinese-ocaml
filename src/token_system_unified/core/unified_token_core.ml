(** 统一Token核心系统 - 模块化重构版本 作为协调器和向后兼容层，委派给专门的子模块 *)

(* 重新导出核心类型 *)
include Token_types

(** Token优先级定义 *)
type token_priority =
  | HighPriority  (** 高优先级：关键字、保留字 *)
  | MediumPriority  (** 中优先级：运算符、分隔符 *)
  | LowPriority  (** 低优先级：标识符、字面量 *)

(** 统一的Token定义 - 消除各种重复定义 *)
type unified_token =
  (* 字面量Token *)
  | IntToken of int
  | FloatToken of float
  | StringToken of string
  | BoolToken of bool
  | ChineseNumberToken of string
  | UnitToken
  (* 标识符Token *)
  | IdentifierToken of string
  | QuotedIdentifierToken of string
  | ConstructorToken of string
  | IdentifierTokenSpecial of string
  | ModuleNameToken of string
  | TypeNameToken of string
  (* 基础关键字Token *)
  | LetKeyword
  | FunKeyword
  | IfKeyword
  | ThenKeyword
  | ElseKeyword
  | MatchKeyword
  | WithKeyword
  | TypeKeyword
  | TrueKeyword
  | FalseKeyword
  (* 运算符Token *)
  | PlusOperator
  | MinusOperator
  | MultiplyOperator
  | DivideOperator
  | EqualOperator
  | NotEqualOperator
  | LessThanOperator
  | GreaterThanOperator
  (* 分隔符Token *)
  | LeftParenDelimiter
  | RightParenDelimiter
  | LeftBracketDelimiter
  | RightBracketDelimiter
  | CommaDelimiter
  | SemicolonDelimiter
  (* 特殊Token *)
  | EOFToken
  | NewlineToken

(** 创建简单Token *)
let make_simple_token token_type = 
  match token_type with
  | "int" -> IntToken 0
  | "string" -> StringToken ""
  | "bool" -> BoolToken false
  | "let" -> LetKeyword
  | "fun" -> FunKeyword
  | "if" -> IfKeyword
  | "+" -> PlusOperator
  | "-" -> MinusOperator
  | "(" -> LeftParenDelimiter
  | ")" -> RightParenDelimiter
  | "eof" -> EOFToken
  | _ -> IdentifierToken token_type

(** 获取Token优先级 *)
let get_token_priority = function
  | LetKeyword | FunKeyword | IfKeyword | ThenKeyword | ElseKeyword 
  | MatchKeyword | WithKeyword | TypeKeyword | TrueKeyword | FalseKeyword -> HighPriority
  | PlusOperator | MinusOperator | MultiplyOperator | DivideOperator 
  | EqualOperator | NotEqualOperator | LessThanOperator | GreaterThanOperator
  | LeftParenDelimiter | RightParenDelimiter | LeftBracketDelimiter 
  | RightBracketDelimiter | CommaDelimiter | SemicolonDelimiter -> MediumPriority
  | IntToken _ | FloatToken _ | StringToken _ | BoolToken _ | ChineseNumberToken _
  | UnitToken | IdentifierToken _ | QuotedIdentifierToken _ | ConstructorToken _
  | IdentifierTokenSpecial _ | ModuleNameToken _ | TypeNameToken _
  | EOFToken | NewlineToken -> LowPriority

(* 向后兼容的模块别名 *)
module TokenCategoryChecker = struct
  include Token_category_checker
end

(* 重新导出函数以保持向后兼容性 *)
let get_token_category = Token_category_checker.get_token_category

(* 重新导出字符串转换函数 *)
let string_of_token = Token_types.TokenUtils.token_to_string

(* 重新导出工具函数以保持向后兼容性 *)
let make_positioned_token token position = (token, position)
let default_position = { line = 1; column = 1; filename = "unknown" }
let equal_token = Token_types.equal_token
