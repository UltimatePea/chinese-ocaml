(** 豫语抽象语法树 - Chinese Programming Language AST *)

(** 基础类型 *)
type 基础类型 =
  | 整数类型                    (* 整数 *)
  | 浮点类型                    (* 浮点数 *)
  | 字符串类型                  (* 字符串 *)
  | 布尔类型                    (* 布尔值 *)
  | 单元类型                    (* 单元类型 () *)
[@@deriving show, eq]

(** 二元运算符 *)
type 二元运算符 =
  | 加法 | 减法 | 乘法 | 除法   (* 算术运算符 *)
  | 等于 | 不等于               (* 比较运算符 *)
  | 小于 | 小于等于 | 大于 | 大于等于
  | 逻辑与 | 逻辑或             (* 逻辑运算符 *)
[@@deriving show, eq]

(** 一元运算符 *)
type 一元运算符 =
  | 负号                        (* - *)
  | 逻辑非                      (* 非 *)
[@@deriving show, eq]

(** 标识符 *)
type 标识符 = string [@@deriving show, eq]

(** 字面量 *)
type 字面量 =
  | 整数字面量 of int
  | 浮点字面量 of float
  | 字符串字面量 of string
  | 布尔字面量 of bool
  | 单元字面量
[@@deriving show, eq]

(** 模式匹配 *)
type 模式 =
  | 通配符模式                  (* _ *)
  | 变量模式 of 标识符          (* x *)
  | 字面量模式 of 字面量        (* 1, "hello", 真 *)
  | 构造器模式 of 标识符 * 模式 list (* Some x *)
  | 元组模式 of 模式 list       (* (x, y) *)
  | 列表模式 of 模式 list       (* [x; y; z] *)
  | 或模式 of 模式 * 模式       (* p1 | p2 *)
[@@deriving show, eq]

(** 表达式 *)
type 表达式 =
  | 字面量表达式 of 字面量
  | 变量表达式 of 标识符
  | 二元运算表达式 of 表达式 * 二元运算符 * 表达式
  | 一元运算表达式 of 一元运算符 * 表达式
  | 函数调用表达式 of 表达式 * 表达式 list
  | 条件表达式 of 表达式 * 表达式 * 表达式    (* 如果 条件 那么 expr1 否则 expr2 *)
  | 元组表达式 of 表达式 list                 (* (expr1, expr2, ...) *)
  | 列表表达式 of 表达式 list                 (* [expr1; expr2; ...] *)
  | 匹配表达式 of 表达式 * (模式 * 表达式) list (* 匹配 expr 与 | 模式 -> 表达式 *)
  | 函数表达式 of 标识符 list * 表达式        (* 函数 x y -> 表达式 *)
  | 让表达式 of 标识符 * 表达式 * 表达式      (* 让 x = expr1 在 expr2 中 *)
[@@deriving show, eq]

(** 语句 *)
type 语句 =
  | 表达式语句 of 表达式
  | 让语句 of 标识符 * 表达式                 (* 让 x = 表达式 *)
  | 递归让语句 of 标识符 * 表达式             (* 递归 让 f = 表达式 *)
  | 类型定义语句 of 标识符 * 类型定义
[@@deriving show, eq]

(** 类型定义 *)
and 类型定义 =
  | 别名类型 of 类型表达式
  | 代数类型 of (标识符 * 类型表达式 option) list  (* 构造器列表 *)
  | 记录类型 of (标识符 * 类型表达式) list        (* 字段列表 *)
[@@deriving show, eq]

(** 类型表达式 *)
and 类型表达式 =
  | 基础类型表达式 of 基础类型
  | 类型变量 of 标识符                        (* 'a *)
  | 函数类型 of 类型表达式 * 类型表达式       (* type1 -> type2 *)
  | 元组类型 of 类型表达式 list               (* type1 * type2 * ... *)
  | 列表类型 of 类型表达式                    (* type list *)
  | 构造类型 of 标识符 * 类型表达式 list      (* MyType of type1 * type2 *)
[@@deriving show, eq]

(** 程序 - 语句列表 *)
type 程序 = 语句 list [@@deriving show, eq]

(** 辅助函数 *)

(** 创建整数字面量表达式 *)
let 整数 n = 字面量表达式 (整数字面量 n)

(** 创建字符串字面量表达式 *)
let 字符串 s = 字面量表达式 (字符串字面量 s)

(** 创建布尔字面量表达式 *)
let 布尔 b = 字面量表达式 (布尔字面量 b)

(** 创建变量表达式 *)
let 变量 name = 变量表达式 name

(** 创建二元运算表达式 *)
let 二元运算 left op right = 二元运算表达式 (left, op, right)

(** 创建函数调用表达式 *)
let 调用 func args = 函数调用表达式 (func, args)