(** 骆言抽象语法树 - Chinese Programming Language AST *)

(** 基础类型 *)
type base_type =
  | IntType                     (* 整数 *)
  | FloatType                   (* 浮点数 *)
  | StringType                  (* 字符串 *)
  | BoolType                    (* 布尔值 *)
  | UnitType                    (* 单元类型 () *)
[@@deriving show, eq]

(** 二元运算符 *)
type binary_op =
  | Add | Sub | Mul | Div | Mod  (* 算术运算符 *)
  | Eq | Neq                    (* 比较运算符 *)
  | Lt | Le | Gt | Ge
  | And | Or                    (* 逻辑运算符 *)
[@@deriving show, eq]

(** 一元运算符 *)
type unary_op =
  | Neg                         (* - *)
  | Not                         (* 非 *)
[@@deriving show, eq]

(** 标识符 *)
type identifier = string [@@deriving show, eq]

(** 字面量 *)
type literal =
  | IntLit of int
  | FloatLit of float
  | StringLit of string
  | BoolLit of bool
  | UnitLit
[@@deriving show, eq]

(** 模式匹配 *)
type pattern =
  | WildcardPattern             (* _ *)
  | VarPattern of identifier    (* x *)
  | LitPattern of literal       (* 1, "hello", 真 *)
  | ConstructorPattern of identifier * pattern list (* Some x *)
  | TuplePattern of pattern list    (* (x, y) *)
  | ListPattern of pattern list     (* [x; y; z] *)
  | ConsPattern of pattern * pattern (* head :: tail *)
  | EmptyListPattern               (* [] *)
  | OrPattern of pattern * pattern  (* p1 | p2 *)
[@@deriving show, eq]

(** 类型表达式 *)
type type_expr =
  | BaseTypeExpr of base_type
  | TypeVar of identifier               (* 'a *)
  | FunType of type_expr * type_expr    (* type1 -> type2 *)
  | TupleType of type_expr list         (* type1 * type2 * ... *)
  | ListType of type_expr               (* type list *)
  | ConstructType of identifier * type_expr list (* MyType of type1 * type2 *)
[@@deriving show, eq]

(** 类型定义 *)
type type_def =
  | AliasType of type_expr
  | AlgebraicType of (identifier * type_expr option) list  (* 构造器列表 *)
  | RecordType of (identifier * type_expr) list            (* 字段列表 *)
[@@deriving show, eq]

(** 宏系统 *)
type macro_name = string [@@deriving show, eq]

(** 宏参数 *)
type macro_param =
  | ExprParam of identifier    (* 表达式参数 *)
  | StmtParam of identifier    (* 语句参数 *)
  | TypeParam of identifier    (* 类型参数 *)
[@@deriving show, eq]

(** 模块系统 *)
type module_name = string [@@deriving show, eq]

(** 相互递归类型定义 *)
type expr =
  | LitExpr of literal
  | VarExpr of identifier
  | BinaryOpExpr of expr * binary_op * expr
  | UnaryOpExpr of unary_op * expr
  | FunCallExpr of expr * expr list
  | CondExpr of expr * expr * expr      (* 如果 条件 那么 expr1 否则 expr2 *)
  | TupleExpr of expr list              (* (expr1, expr2, ...) *)
  | ListExpr of expr list               (* [expr1; expr2; ...] *)
  | MatchExpr of expr * (pattern * expr) list (* 匹配 expr 与 | 模式 -> 表达式 *)
  | FunExpr of identifier list * expr   (* 函数 x y -> 表达式 *)
  | LetExpr of identifier * expr * expr (* 让 x = expr1 在 expr2 中 *)
  | MacroCallExpr of macro_call         (* 宏调用 *)
  | AsyncExpr of async_expr             (* 异步表达式 *)
and async_expr =
  | AsyncFunc of expr                    (* 异步函数 *)
  | AwaitExpr of expr                    (* 等待异步结果 *)
  | SpawnExpr of expr                    (* 创建新任务 *)
  | ChannelExpr of expr                  (* 通道操作 *)
and macro_call = {
  macro_call_name: macro_name;
  args: expr list;
}
and stmt =
  | ExprStmt of expr
  | LetStmt of identifier * expr        (* 让 x = 表达式 *)
  | RecLetStmt of identifier * expr     (* 递归 让 f = 表达式 *)
  | TypeDefStmt of identifier * type_def
  | ModuleDefStmt of module_def         (* 模块定义 *)
  | ModuleImportStmt of module_import   (* 模块导入 *)
  | MacroDefStmt of macro_def           (* 宏定义 *)
and module_def = {
  module_def_name: module_name;
  exports: (identifier * type_expr) list;  (* 导出的函数和类型 *)
  statements: stmt list;                    (* 模块内的语句 *)
}
and module_import = {
  module_import_name: module_name;
  imports: (identifier * identifier option) list;  (* (原名称, 别名) *)
}
and macro_def = {
  macro_def_name: macro_name;
  params: macro_param list;
  body: expr;                  (* 宏体 *)
}
[@@deriving show, eq]

(** 程序 - 语句列表 *)
type program = stmt list [@@deriving show, eq]

(** 辅助函数 *)

(** 创建整数字面量表达式 *)
let make_int n = LitExpr (IntLit n)

(** 创建字符串字面量表达式 *)
let make_string s = LitExpr (StringLit s)

(** 创建布尔字面量表达式 *)
let make_bool b = LitExpr (BoolLit b)

(** 创建变量表达式 *)
let make_var name = VarExpr name

(** 创建二元运算表达式 *)
let make_binary_op left op right = BinaryOpExpr (left, op, right)

(** 创建函数调用表达式 *)
let make_call func args = FunCallExpr (func, args)