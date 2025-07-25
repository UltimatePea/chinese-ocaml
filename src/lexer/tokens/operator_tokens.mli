(** 骆言词法分析器 - 运算符Token *)

(** 运算符token，包括算术、比较、逻辑和赋值运算符 *)
type operator_token =
  (* 算术运算符 *)
  | Plus             (** + *)
  | Minus            (** - *)
  | Multiply         (** * *)
  | Star             (** * - alias for Multiply *)
  | Divide           (** / *)
  | Slash            (** / - alias for Divide *)
  | Modulo           (** % *)
  | Concat           (** ^ - 字符串连接 *)
  (* 赋值运算符 *)
  | Assign           (** = *)
  | RefAssign        (** := - for reference assignment *)
  (* 比较运算符 *)
  | Equal            (** == *)
  | NotEqual         (** <> *)
  | Less             (** < *)
  | LessEqual        (** <= *)
  | Greater          (** > *)
  | GreaterEqual     (** >= *)
  (* 函数和类型运算符 *)
  | Arrow            (** -> *)
  | DoubleArrow      (** => *)
  | AssignArrow      (** <- *)
  (* 访问运算符 *)
  | Dot              (** . *)
  | DoubleDot        (** .. *)
  | TripleDot        (** ... *)
  | Bang             (** ! - for dereferencing *)
  (* 其他运算符 *)
  | QuestionMark     (** ? *)
  | Tilde            (** ~ *)
[@@deriving show, eq]

(** 将运算符token转换为字符串表示 *)
val to_string : operator_token -> string

(** 将字符串转换为运算符token（如果匹配） *)
val from_string : string -> operator_token option

(** 检查是否为算术运算符 *)
val is_arithmetic : operator_token -> bool

(** 检查是否为比较运算符 *)
val is_comparison : operator_token -> bool

(** 检查是否为赋值运算符 *)
val is_assignment : operator_token -> bool

(** 检查是否为函数相关运算符 *)
val is_function_related : operator_token -> bool

(** 获取运算符的优先级（数字越大优先级越高） *)
val precedence : operator_token -> int