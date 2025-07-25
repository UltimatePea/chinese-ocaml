(** 骆言词法分析器 - 操作符令牌类型定义接口 *)

(** 算术操作符 *)
type arithmetic_operator = Plus | Minus | Multiply | Star | Divide | Slash | Modulo
[@@deriving show, eq]

(** 比较操作符 *)
type comparison_operator = Equal | NotEqual | Less | LessEqual | Greater | GreaterEqual
[@@deriving show, eq]

(** 逻辑操作符 *)
type logical_operator = And | Or | Not [@@deriving show, eq]

(** 赋值操作符 *)
type assignment_operator = Assign | RefAssign [@@deriving show, eq]

(** 特殊操作符 *)
type special_operator =
  | Concat
  | Arrow
  | DoubleArrow
  | Dot
  | DoubleDot
  | TripleDot
  | Bang
  | AssignArrow
[@@deriving show, eq]

(** 中文操作符 *)
type chinese_operator = ChineseArrow | ChineseDoubleArrow | ChineseAssignArrow
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

val operator_token_to_string : operator_token -> string
(** 操作符转换为字符串 *)

val get_operator_precedence : operator_token -> int
(** 获取操作符优先级 *)

val is_binary_operator : operator_token -> bool
(** 判断是否为二元操作符 *)

val is_unary_operator : operator_token -> bool
(** 判断是否为一元操作符 *)
