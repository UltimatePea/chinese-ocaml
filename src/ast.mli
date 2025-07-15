(** 骆言抽象语法树 - Chinese Programming Language AST 接口文件 *)


(** 基础类型 *)
type base_type =
  | IntType (** 整数 *)
  | FloatType (** 浮点数 *)
  | StringType (** 字符串 *)
  | BoolType (** 布尔值 *)
  | UnitType (** 单元类型 () *)

(** 二元运算符 *)
type binary_op =
  | Add
  | Sub
  | Mul
  | Div
  | Mod (** 算术运算符 *)
  | Concat (** 字符串连接运算符 *)
  | Eq
  | Neq (** 比较运算符 *)
  | Lt
  | Le
  | Gt
  | Ge
  | And
  | Or (** 逻辑运算符 *)

(** 一元运算符 *)
type unary_op =
  | Neg (** - *)
  | Not (** 非 *)

(** 标识符 *)
type identifier = string

(** 字面量 *)
type literal = 
  | IntLit of int 
  | FloatLit of float 
  | StringLit of string 
  | BoolLit of bool 
  | UnitLit

(** 模式匹配 *)
type pattern =
  | WildcardPattern (** _ *)
  | VarPattern of identifier (** x *)
  | LitPattern of literal (** 1, "hello", 真 *)
  | ConstructorPattern of identifier * pattern list (** Some x *)
  | TuplePattern of pattern list (** (x, y) *)
  | ListPattern of pattern list (** [x; y; z] *)
  | ConsPattern of pattern * pattern (** head :: tail *)
  | EmptyListPattern (** [] *)
  | OrPattern of pattern * pattern (** p1 | p2 *)
  | ExceptionPattern of identifier * pattern option (** 异常名 参数模式 *)
  | PolymorphicVariantPattern of identifier * pattern option (** 多态变体模式 *)

(** 类型表达式 *)
type type_expr =
  | BaseTypeExpr of base_type
  | TypeVar of identifier (** 'a *)
  | FunType of type_expr * type_expr (** type1 -> type2 *)
  | TupleType of type_expr list (** type1 * type2 * ... *)
  | ListType of type_expr (** type list *)
  | ConstructType of identifier * type_expr list (** MyType of type1 * type2 *)
  | RefType of type_expr (** type ref - 引用类型 *)
  | PolymorphicVariantType of (identifier * type_expr option) list (** 多态变体类型 *)

(** 类型定义 *)
type type_def =
  | AliasType of type_expr
  | AlgebraicType of (identifier * type_expr option) list (** 构造器列表 *)
  | RecordType of (identifier * type_expr) list (** 字段列表 *)
  | PrivateType of type_expr (** 私有类型 *)
  | PolymorphicVariantTypeDef of (identifier * type_expr option) list (** 多态变体类型定义 *)

(** 宏系统 *)
type macro_name = string

(** 宏参数 *)
type macro_param =
  | ExprParam of identifier (** 表达式参数 *)
  | StmtParam of identifier (** 语句参数 *)
  | TypeParam of identifier (** 类型参数 *)

(** 模块系统 *)
type module_name = string

(** 模块类型系统 *)
type module_type_name = string

(** 模块签名项 *)
type signature_item =
  | SigValue of identifier * type_expr (** 值签名: 名称 : 类型 *)
  | SigTypeDecl of identifier * type_def option (** 类型签名: type 名称 [= 定义] *)
  | SigModule of identifier * module_type (** 子模块签名: module 名称 : 模块类型 *)
  | SigException of identifier * type_expr option (** 异常签名 *)

(** 模块类型 *)
and module_type =
  | Signature of signature_item list (** 具体签名: sig ... end *)
  | ModuleTypeName of module_type_name (** 命名模块类型 *)
  | FunctorType of identifier * module_type * module_type (** 函子类型: (参数 : 输入类型) -> 输出类型 *)

(** 相互递归类型定义 *)
type expr =
  | LitExpr of literal
  | VarExpr of identifier
  | BinaryOpExpr of expr * binary_op * expr
  | UnaryOpExpr of unary_op * expr
  | FunCallExpr of expr * expr list
  | CondExpr of expr * expr * expr (** 如果 条件 那么 expr1 否则 expr2 *)
  | TupleExpr of expr list (** (expr1, expr2, ...) *)
  | ListExpr of expr list (** [expr1; expr2; ...] *)
  | MatchExpr of expr * match_branch list (** 匹配 expr 与 | 模式 -> 表达式 *)
  | FunExpr of identifier list * expr (** 函数 x y -> 表达式 *)
  | FunExprWithType of (identifier * type_expr option) list * type_expr option * expr (** 函数 (x : type) (y : type) : return_type -> 表达式 *)
  | LabeledFunExpr of label_param list * expr (** 标签函数 *)
  | LabeledFunCallExpr of expr * label_arg list (** 标签函数调用 *)
  | LetExpr of identifier * expr * expr (** 让 x = expr1 在 expr2 中 *)
  | LetExprWithType of identifier * type_expr * expr * expr (** 让 x : type = expr1 在 expr2 中 *)
  | MacroCallExpr of macro_call (** 宏调用 *)
  | AsyncExpr of async_expr (** 异步表达式 *)
  | SemanticLetExpr of identifier * string * expr * expr (** 让 x 作为 语义标签 = expr1 在 expr2 中 *)
  | CombineExpr of expr list (** 组合 expr1 以及 expr2 以及 ... *)
  | OrElseExpr of expr * expr (** expr1 否则返回 expr2 - 智能默认值 *)
  | RecordExpr of (identifier * expr) list (** { 字段1 = expr1; 字段2 = expr2; ... } *)
  | FieldAccessExpr of expr * identifier (** expr.字段名 *)
  | RecordUpdateExpr of expr * (identifier * expr) list (** { expr 与 字段1 = expr1; ... } *)
  | ArrayExpr of expr list (** [|expr1; expr2; ...|] *)
  | ArrayAccessExpr of expr * expr (** array.(index) *)
  | ArrayUpdateExpr of expr * expr * expr (** array.(index) <- value *)
  | TryExpr of expr * match_branch list * expr option (** 尝试 expr 捕获 | 模式 -> 表达式 最终 expr *)
  | RaiseExpr of expr (** 抛出 expr *)
  | RefExpr of expr (** 引用 expr *)
  | DerefExpr of expr (** !expr *)
  | AssignExpr of expr * expr (** expr := expr *)
  | ConstructorExpr of identifier * expr list (** Constructor application: 构造器 expr1 expr2 ... *)
  | ModuleAccessExpr of expr * identifier (** 模块成员访问: 模块.成员 *)
  | FunctorCallExpr of expr * expr (** 函子调用: Functor(Module) *)
  | FunctorExpr of identifier * module_type * expr (** 函子定义: functor (X : SIG) -> struct ... end *)
  | ModuleExpr of stmt list (** 模块表达式: struct ... end *)
  | TypeAnnotationExpr of expr * type_expr (** 类型注解表达式: (expr : type) *)
  | PolymorphicVariantExpr of identifier * expr option (** 多态变体表达式: 「标签」 或 「标签」 值 *)

(** 匹配分支 *)
and match_branch = {
  pattern : pattern;
  guard : expr option; (** guard条件: 当 condition *)
  expr : expr; (** 分支表达式 *)
}

(** 异步表达式 *)
and async_expr =
  | AsyncFunc of expr (** 异步函数 *)
  | AwaitExpr of expr (** 等待异步结果 *)
  | SpawnExpr of expr (** 创建新任务 *)
  | ChannelExpr of expr (** 通道操作 *)

(** 宏调用 *)
and macro_call = { 
  macro_call_name : macro_name; 
  args : expr list 
}

(** 语句 *)
and stmt =
  | ExprStmt of expr
  | LetStmt of identifier * expr (** 让 x = 表达式 *)
  | LetStmtWithType of identifier * type_expr * expr (** 让 x : type = 表达式 *)
  | RecLetStmt of identifier * expr (** 递归 让 f = 表达式 *)
  | RecLetStmtWithType of identifier * type_expr * expr (** 递归 让 f : type = 表达式 *)
  | SemanticLetStmt of identifier * string * expr (** 让 x 作为 语义标签 = 表达式 *)
  | TypeDefStmt of identifier * type_def
  | ModuleDefStmt of module_def (** 模块定义 *)
  | ModuleImportStmt of module_import (** 模块导入 *)
  | ModuleTypeDefStmt of module_type_name * module_type (** 模块类型定义 *)
  | MacroDefStmt of macro_def (** 宏定义 *)
  | ExceptionDefStmt of identifier * type_expr option (** 异常定义 *)
  | IncludeStmt of expr (** 包含模块: include ModuleName *)

(** 模块定义 *)
and module_def = {
  module_def_name : module_name;
  module_type_annotation : module_type option; (** 可选的模块类型注解 *)
  exports : (identifier * type_expr) list; (** 导出的函数和类型 *)
  statements : stmt list; (** 模块内的语句 *)
}

(** 模块导入 *)
and module_import = {
  module_import_name : module_name;
  imports : (identifier * identifier option) list; (** (原名称, 别名) *)
}

(** 标签参数 *)
and label_param = {
  label_name: identifier; (** 标签名称 *)
  param_name: identifier; (** 参数名称 *)
  param_type: type_expr option; (** 参数类型 *)
  is_optional: bool; (** 是否可选 *)
  default_value: expr option; (** 默认值 *)
}

(** 标签参数值 *)
and label_arg = {
  arg_label: identifier; (** 标签名称 *)
  arg_value: expr; (** 参数值 *)
}

(** 宏定义 *)
and macro_def = { 
  macro_def_name : macro_name; 
  params : macro_param list; 
  body : expr (** 宏体 *)
}

(** 程序 - 语句列表 *)
type program = stmt list

(** 类型显示和比较函数（由 ppx_deriving 生成） *)


(** base_type 类型的显示函数 *)
val pp_base_type : Format.formatter -> base_type -> unit
val show_base_type : base_type -> string
val equal_base_type : base_type -> base_type -> bool

(** binary_op 类型的显示函数 *)
val pp_binary_op : Format.formatter -> binary_op -> unit
val show_binary_op : binary_op -> string
val equal_binary_op : binary_op -> binary_op -> bool

(** unary_op 类型的显示函数 *)
val pp_unary_op : Format.formatter -> unary_op -> unit
val show_unary_op : unary_op -> string
val equal_unary_op : unary_op -> unary_op -> bool

(** identifier 类型的显示函数 *)
val pp_identifier : Format.formatter -> identifier -> unit
val show_identifier : identifier -> string
val equal_identifier : identifier -> identifier -> bool

(** literal 类型的显示函数 *)
val pp_literal : Format.formatter -> literal -> unit
val show_literal : literal -> string
val equal_literal : literal -> literal -> bool

(** pattern 类型的显示函数 *)
val pp_pattern : Format.formatter -> pattern -> unit
val show_pattern : pattern -> string
val equal_pattern : pattern -> pattern -> bool

(** type_expr 类型的显示函数 *)
val pp_type_expr : Format.formatter -> type_expr -> unit
val show_type_expr : type_expr -> string
val equal_type_expr : type_expr -> type_expr -> bool

(** type_def 类型的显示函数 *)
val pp_type_def : Format.formatter -> type_def -> unit
val show_type_def : type_def -> string
val equal_type_def : type_def -> type_def -> bool

(** macro_name 类型的显示函数 *)
val pp_macro_name : Format.formatter -> macro_name -> unit
val show_macro_name : macro_name -> string
val equal_macro_name : macro_name -> macro_name -> bool

(** macro_param 类型的显示函数 *)
val pp_macro_param : Format.formatter -> macro_param -> unit
val show_macro_param : macro_param -> string
val equal_macro_param : macro_param -> macro_param -> bool

(** module_name 类型的显示函数 *)
val pp_module_name : Format.formatter -> module_name -> unit
val show_module_name : module_name -> string
val equal_module_name : module_name -> module_name -> bool

(** module_type_name 类型的显示函数 *)
val pp_module_type_name : Format.formatter -> module_type_name -> unit
val show_module_type_name : module_type_name -> string
val equal_module_type_name : module_type_name -> module_type_name -> bool

(** signature_item 类型的显示函数 *)
val pp_signature_item : Format.formatter -> signature_item -> unit
val show_signature_item : signature_item -> string
val equal_signature_item : signature_item -> signature_item -> bool

(** module_type 类型的显示函数 *)
val pp_module_type : Format.formatter -> module_type -> unit
val show_module_type : module_type -> string
val equal_module_type : module_type -> module_type -> bool

(** expr 类型的显示函数 *)
val pp_expr : Format.formatter -> expr -> unit
val show_expr : expr -> string
val equal_expr : expr -> expr -> bool

(** match_branch 类型的显示函数 *)
val pp_match_branch : Format.formatter -> match_branch -> unit
val show_match_branch : match_branch -> string
val equal_match_branch : match_branch -> match_branch -> bool

(** async_expr 类型的显示函数 *)
val pp_async_expr : Format.formatter -> async_expr -> unit
val show_async_expr : async_expr -> string
val equal_async_expr : async_expr -> async_expr -> bool

(** macro_call 类型的显示函数 *)
val pp_macro_call : Format.formatter -> macro_call -> unit
val show_macro_call : macro_call -> string
val equal_macro_call : macro_call -> macro_call -> bool

(** stmt 类型的显示函数 *)
val pp_stmt : Format.formatter -> stmt -> unit
val show_stmt : stmt -> string
val equal_stmt : stmt -> stmt -> bool

(** module_def 类型的显示函数 *)
val pp_module_def : Format.formatter -> module_def -> unit
val show_module_def : module_def -> string
val equal_module_def : module_def -> module_def -> bool

(** module_import 类型的显示函数 *)
val pp_module_import : Format.formatter -> module_import -> unit
val show_module_import : module_import -> string
val equal_module_import : module_import -> module_import -> bool

(** label_param 类型的显示函数 *)
val pp_label_param : Format.formatter -> label_param -> unit
val show_label_param : label_param -> string
val equal_label_param : label_param -> label_param -> bool

(** label_arg 类型的显示函数 *)
val pp_label_arg : Format.formatter -> label_arg -> unit
val show_label_arg : label_arg -> string
val equal_label_arg : label_arg -> label_arg -> bool

(** macro_def 类型的显示函数 *)
val pp_macro_def : Format.formatter -> macro_def -> unit
val show_macro_def : macro_def -> string
val equal_macro_def : macro_def -> macro_def -> bool

(** program 类型的显示函数 *)
val pp_program : Format.formatter -> program -> unit
val show_program : program -> string
val equal_program : program -> program -> bool

(** 辅助函数 *)

(** 创建整数字面量表达式 *)
val make_int : int -> expr

(** 创建字符串字面量表达式 *)
val make_string : string -> expr

(** 创建布尔字面量表达式 *)
val make_bool : bool -> expr

(** 创建变量表达式 *)
val make_var : string -> expr

(** 创建二元运算表达式 *)
val make_binary_op : expr -> binary_op -> expr -> expr

(** 创建函数调用表达式 *)
val make_call : expr -> expr list -> expr