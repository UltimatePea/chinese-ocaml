(** 骆言词法分析器 - 运算符Token *)

type operator_token =
  | Plus
  | Minus
  | Multiply
  | Star
  | Divide
  | Slash
  | Modulo
  | Concat
  | Assign
  | RefAssign
  | Equal
  | NotEqual
  | Less
  | LessEqual
  | Greater
  | GreaterEqual
  | Arrow
  | DoubleArrow
  | AssignArrow
  | Dot
  | DoubleDot
  | TripleDot
  | Bang
  | QuestionMark
  | Tilde
[@@deriving show, eq]

let to_string = function
  | Plus -> "+"
  | Minus -> "-"
  | Multiply -> "*"
  | Star -> "*"
  | Divide -> "/"
  | Slash -> "/"
  | Modulo -> "%"
  | Concat -> "^"
  | Assign -> "="
  | RefAssign -> ":="
  | Equal -> "=="
  | NotEqual -> "<>"
  | Less -> "<"
  | LessEqual -> "<="
  | Greater -> ">"
  | GreaterEqual -> ">="
  | Arrow -> "->"
  | DoubleArrow -> "=>"
  | AssignArrow -> "<-"
  | Dot -> "."
  | DoubleDot -> ".."
  | TripleDot -> "..."
  | Bang -> "!"
  | QuestionMark -> "?"
  | Tilde -> "~"

let from_string = function
  | "+" -> Some Plus
  | "-" -> Some Minus
  | "*" -> Some Multiply
  | "/" -> Some Divide
  | "%" -> Some Modulo
  | "^" -> Some Concat
  | "=" -> Some Assign
  | ":=" -> Some RefAssign
  | "==" -> Some Equal
  | "<>" -> Some NotEqual
  | "<" -> Some Less
  | "<=" -> Some LessEqual
  | ">" -> Some Greater
  | ">=" -> Some GreaterEqual
  | "->" -> Some Arrow
  | "=>" -> Some DoubleArrow
  | "<-" -> Some AssignArrow
  | "." -> Some Dot
  | ".." -> Some DoubleDot
  | "..." -> Some TripleDot
  | "!" -> Some Bang
  | "?" -> Some QuestionMark
  | "~" -> Some Tilde
  | _ -> None

let is_arithmetic = function
  | Plus | Minus | Multiply | Star | Divide | Slash | Modulo | Concat -> true
  | _ -> false

let is_comparison = function
  | Equal | NotEqual | Less | LessEqual | Greater | GreaterEqual -> true
  | _ -> false

let is_assignment = function Assign | RefAssign | AssignArrow -> true | _ -> false
let is_function_related = function Arrow | DoubleArrow -> true | _ -> false

let precedence = function
  | Multiply | Star | Divide | Slash | Modulo -> 7
  | Plus | Minus -> 6
  | Concat -> 5
  | Equal | NotEqual | Less | LessEqual | Greater | GreaterEqual -> 4
  | Arrow | DoubleArrow -> 3
  | Assign | RefAssign | AssignArrow -> 1
  | _ -> 0
