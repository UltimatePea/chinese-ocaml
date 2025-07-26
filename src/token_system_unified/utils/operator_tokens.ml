(** 骆言词法分析器 - 操作符令牌类型定义 *)

(** 算术操作符 *)
type arithmetic_operator =
  | Plus (* + *)
  | Minus (* - *)
  | Multiply (* * *)
  | Star (* * - alias for Multiply *)
  | Divide (* / *)
  | Slash (* / - alias for Divide *)
  | Modulo (* % *)
[@@deriving show, eq]

(** 比较操作符 *)
type comparison_operator =
  | Equal (* == *)
  | NotEqual (* <> *)
  | Less (* < *)
  | LessEqual (* <= *)
  | Greater (* > *)
  | GreaterEqual (* >= *)
[@@deriving show, eq]

(** 逻辑操作符 *)
type logical_operator =
  | And
  (* && *)
  | Or
  (* || *)
  | Not (* ! - logical not *)
[@@deriving show, eq]

(** 赋值操作符 *)
type assignment_operator =
  | Assign
  (* = *)
  | RefAssign (* := - for reference assignment *)
[@@deriving show, eq]

(** 特殊操作符 *)
type special_operator =
  | Concat (* ^ - 字符串连接 *)
  | Arrow (* -> *)
  | DoubleArrow (* => *)
  | Dot (* . *)
  | DoubleDot (* .. *)
  | TripleDot (* ... *)
  | Bang (* ! - for dereferencing *)
  | AssignArrow (* <- *)
[@@deriving show, eq]

(** 中文操作符 *)
type chinese_operator =
  | ChineseArrow (* → *)
  | ChineseDoubleArrow (* ⇒ *)
  | ChineseAssignArrow (* ← *)
[@@deriving show, eq]

(** 统一操作符类型 *)
type operator_token =
  | Arithmetic of arithmetic_operator
  | Comparison of comparison_operator
  | Logical of logical_operator
  | Assignment of assignment_operator
  | Special of special_operator
  | Chinese of chinese_operator
[@@deriving show, eq]

(** 操作符转换为字符串 *)
let operator_token_to_string = function
  | Arithmetic ao -> (
      match ao with
      | Plus -> "+"
      | Minus -> "-"
      | Multiply | Star -> "*"
      | Divide | Slash -> "/"
      | Modulo -> "%")
  | Comparison co -> (
      match co with
      | Equal -> "=="
      | NotEqual -> "<>"
      | Less -> "<"
      | LessEqual -> "<="
      | Greater -> ">"
      | GreaterEqual -> ">=")
  | Logical lo -> ( match lo with And -> "&&" | Or -> "||" | Not -> "!")
  | Assignment ao -> ( match ao with Assign -> "=" | RefAssign -> ":=")
  | Special so -> (
      match so with
      | Concat -> "^"
      | Arrow -> "->"
      | DoubleArrow -> "=>"
      | Dot -> "."
      | DoubleDot -> ".."
      | TripleDot -> "..."
      | Bang -> "!"
      | AssignArrow -> "<-")
  | Chinese co -> (
      match co with ChineseArrow -> "→" | ChineseDoubleArrow -> "⇒" | ChineseAssignArrow -> "←")

(** 获取操作符优先级 *)
let get_operator_precedence = function
  | Logical Or -> 1
  | Logical And -> 2
  | Comparison _ -> 3
  | Arithmetic (Plus | Minus) -> 4
  | Arithmetic (Multiply | Star | Divide | Slash | Modulo) -> 5
  | Logical Not -> 6
  | Special (Dot | DoubleDot | TripleDot) -> 7
  | _ -> 0 (* 其他操作符优先级最低 *)

(** 判断是否为二元操作符 *)
let is_binary_operator = function
  | Arithmetic _ | Comparison _ | Assignment _
  | Special (Concat | Arrow | DoubleArrow | AssignArrow)
  | Chinese _
  | Logical (And | Or) ->
      true
  | _ -> false

(** 判断是否为一元操作符 *)
let is_unary_operator = function
  | Arithmetic Minus | Logical Not | Special Bang -> true
  | _ -> false
