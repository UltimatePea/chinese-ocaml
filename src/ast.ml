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
  | Concat                      (* 字符串连接运算符 *)
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
  | ExceptionPattern of identifier * pattern option  (* 异常名 参数模式 *)
[@@deriving show, eq]

(** 类型表达式 *)
type type_expr =
  | BaseTypeExpr of base_type
  | TypeVar of identifier               (* 'a *)
  | FunType of type_expr * type_expr    (* type1 -> type2 *)
  | TupleType of type_expr list         (* type1 * type2 * ... *)
  | ListType of type_expr               (* type list *)
  | ConstructType of identifier * type_expr list (* MyType of type1 * type2 *)
  | RefType of type_expr                (* type ref - 引用类型 *)
[@@deriving show, eq]

(** 类型定义 *)
type type_def =
  | AliasType of type_expr
  | AlgebraicType of (identifier * type_expr option) list  (* 构造器列表 *)
  | RecordType of (identifier * type_expr) list            (* 字段列表 *)
  | PrivateType of type_expr                               (* 私有类型 *)
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

(** 模块类型系统 *)
type module_type_name = string [@@deriving show, eq]

(** 模块签名项 *)
type signature_item =
  | SigValue of identifier * type_expr        (* 值签名: 名称 : 类型 *)
  | SigTypeDecl of identifier * type_def option   (* 类型签名: type 名称 [= 定义] *)
  | SigModule of identifier * module_type     (* 子模块签名: module 名称 : 模块类型 *)
  | SigException of identifier * type_expr option  (* 异常签名 *)

(** 模块类型 *)
and module_type =
  | Signature of signature_item list          (* 具体签名: sig ... end *)
  | ModuleTypeName of module_type_name        (* 命名模块类型 *)
  | FunctorType of identifier * module_type * module_type  (* 函子类型: (参数 : 输入类型) -> 输出类型 *)

[@@deriving show, eq]

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
  | MatchExpr of expr * match_branch list (* 匹配 expr 与 | 模式 -> 表达式 *)
  | FunExpr of identifier list * expr   (* 函数 x y -> 表达式 *)
  | FunExprWithType of (identifier * type_expr option) list * type_expr option * expr  (* 函数 (x : type) (y : type) : return_type -> 表达式 *)
  | LetExpr of identifier * expr * expr (* 让 x = expr1 在 expr2 中 *)
  | LetExprWithType of identifier * type_expr * expr * expr  (* 让 x : type = expr1 在 expr2 中 *)
  | MacroCallExpr of macro_call         (* 宏调用 *)
  | AsyncExpr of async_expr             (* 异步表达式 *)
  | SemanticLetExpr of identifier * string * expr * expr (* 让 x 作为 语义标签 = expr1 在 expr2 中 *)
  | CombineExpr of expr list            (* 组合 expr1 以及 expr2 以及 ... *)
  | OrElseExpr of expr * expr           (* expr1 否则返回 expr2 - 智能默认值 *)
  | RecordExpr of (identifier * expr) list  (* { 字段1 = expr1; 字段2 = expr2; ... } *)
  | FieldAccessExpr of expr * identifier    (* expr.字段名 *)
  | RecordUpdateExpr of expr * (identifier * expr) list  (* { expr 与 字段1 = expr1; ... } *)
  | ArrayExpr of expr list                  (* [|expr1; expr2; ...|] *)
  | ArrayAccessExpr of expr * expr          (* array.(index) *)
  | ArrayUpdateExpr of expr * expr * expr   (* array.(index) <- value *)
  | TryExpr of expr * match_branch list * expr option  (* 尝试 expr 捕获 | 模式 -> 表达式 最终 expr *)
  | RaiseExpr of expr                       (* 抛出 expr *)
  | RefExpr of expr                         (* 引用 expr *)
  | DerefExpr of expr                       (* !expr *)
  | AssignExpr of expr * expr               (* expr := expr *)
  | ConstructorExpr of identifier * expr list  (* Constructor application: 构造器 expr1 expr2 ... *)
  | ModuleAccessExpr of expr * identifier      (* 模块成员访问: 模块.成员 *)
  | FunctorCallExpr of expr * expr          (* 函子调用: Functor(Module) *)
  | FunctorExpr of identifier * module_type * expr (* 函子定义: functor (X : SIG) -> struct ... end *)
  | ModuleExpr of stmt list                 (* 模块表达式: struct ... end *)
  | TypeAnnotationExpr of expr * type_expr  (* 类型注解表达式: (expr : type) *)
and match_branch = {
  pattern: pattern;
  guard: expr option;    (* guard条件: 当 condition *)
  expr: expr;           (* 分支表达式 *)
}
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
  | LetStmtWithType of identifier * type_expr * expr  (* 让 x : type = 表达式 *)
  | RecLetStmt of identifier * expr     (* 递归 让 f = 表达式 *)
  | RecLetStmtWithType of identifier * type_expr * expr  (* 递归 让 f : type = 表达式 *)
  | SemanticLetStmt of identifier * string * expr (* 让 x 作为 语义标签 = 表达式 *)
  | TypeDefStmt of identifier * type_def
  | ModuleDefStmt of module_def         (* 模块定义 *)
  | ModuleImportStmt of module_import   (* 模块导入 *)
  | ModuleTypeDefStmt of module_type_name * module_type  (* 模块类型定义 *)
  | MacroDefStmt of macro_def           (* 宏定义 *)
  | ExceptionDefStmt of identifier * type_expr option  (* 异常定义 *)
  | IncludeStmt of expr                 (* 包含模块: include ModuleName *)
and module_def = {
  module_def_name: module_name;
  module_type_annotation: module_type option;  (* 可选的模块类型注解 *)
  exports: (identifier * type_expr) list;      (* 导出的函数和类型 *)
  statements: stmt list;                        (* 模块内的语句 *)
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