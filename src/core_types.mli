(** 骆言类型系统核心类型定义接口 - Core Type Definitions Interface

    这个模块定义了骆言编程语言类型系统的核心数据结构和操作函数。 类型系统是静态类型语言的基础，负责类型检查、类型推断和类型安全保证。
    该模块提供了类型表示、类型环境管理、类型替换和类型查询等核心功能。

    该模块的主要职责包括：
    - 定义语言支持的所有类型表示
    - 提供类型环境的管理接口
    - 实现类型替换和类型变量处理
    - 支持类型推断和类型检查
    - 管理函数重载和多态类型

    支持的类型系统特性：
    - 基础类型：整数、浮点数、字符串、布尔值、单位类型
    - 复合类型：函数类型、元组类型、列表类型、数组类型
    - 用户定义类型：构造类型、记录类型、类类型
    - 高级类型：类型变量、多态变型、私有类型
    - 引用类型：可变引用和不可变引用

    @author 骆言项目组
    @since 0.1.0 *)

(** 类型定义，表示骆言语言中所有可能的类型 *)
type typ =
  | IntType_T  (** 整数类型，表示有符号整数值 *)
  | FloatType_T  (** 浮点数类型，表示双精度浮点数值 *)
  | StringType_T  (** 字符串类型，表示UTF-8编码的字符序列 *)
  | BoolType_T  (** 布尔类型，表示真值或假值 *)
  | UnitType_T  (** 单位类型，表示无意义的值，类似于void *)
  | FunType_T of typ * typ  (** 函数类型，表示从参数类型到返回值类型的映射 *)
  | TupleType_T of typ list  (** 元组类型，表示多个类型的有序组合 *)
  | ListType_T of typ  (** 列表类型，表示同类型元素的序列 *)
  | TypeVar_T of string  (** 类型变量，用于泛型和类型推断 *)
  | ConstructType_T of string * typ list  (** 构造类型，表示用户定义的代数数据类型 *)
  | RefType_T of typ  (** 引用类型，表示对其他类型的可变引用 *)
  | RecordType_T of (string * typ) list  (** 记录类型，表示具名字段的结构体 *)
  | ArrayType_T of typ  (** 数组类型，表示同类型元素的固定大小数组 *)
  | ClassType_T of string * (string * typ) list  (** 类类型，表示面向对象的类定义 *)
  | ObjectType_T of (string * typ) list  (** 对象类型，表示具有方法和字段的对象 *)
  | PrivateType_T of string * typ  (** 私有类型，表示模块内部的抽象类型 *)
  | PolymorphicVariantType_T of (string * typ option) list  (** 多态变型，表示开放的变型类型 *)
[@@deriving show, eq]

(** 类型方案，表示多态类型的参数化形式 *)
type type_scheme =
  | TypeScheme of string list * typ
      (** TypeScheme (type_params, typ) 其中：
          - type_params: 类型参数列表（泛型参数）
          - typ: 参数化的类型表达式

          类型方案用于表示多态函数和泛型类型，允许类型参数的绑定和实例化。 例如：'a -> 'a -> 'a 可以表示为 TypeScheme (["a"],
          FunType_T(...)) *)

module TypeEnv : Map.S with type key = string
(** 类型环境模块，提供类型名称到类型方案的映射

    类型环境是类型检查器的核心数据结构，维护当前作用域中所有标识符的类型信息。 使用高效的映射数据结构实现，支持快速的类型查找和环境扩展。 *)

type env = type_scheme TypeEnv.t
(** 类型环境类型，将变量名称映射到其类型方案

    类型环境在类型检查过程中维护变量的类型信息，支持：
    - 变量类型的查找和绑定
    - 作用域的嵌套和遮蔽
    - 类型方案的泛化和实例化
    - 递归类型的处理 *)

module OverloadMap : Map.S with type key = string
(** 函数重载表模块，管理函数重载的类型信息

    支持同一函数名称的多个类型签名，用于实现函数重载和特化。 每个函数名称可以对应多个类型方案，类型检查器在解析时选择最匹配的版本。 *)

type overload_env = type_scheme list OverloadMap.t
(** 函数重载环境，将函数名称映射到其所有重载版本的类型方案列表

    重载环境管理函数的多个签名，支持：
    - 重载函数的注册和查找
    - 重载解析和类型匹配
    - 类型推断中的重载处理 *)

module SubstMap : Map.S with type key = string
(** 类型替换模块，管理类型变量的替换操作

    类型替换是类型推断的核心操作，用于将类型变量替换为具体类型。 支持复杂的类型替换操作，包括递归替换和循环检测。 *)

type type_subst = typ SubstMap.t
(** 类型替换映射，将类型变量名称映射到其替换的类型

    类型替换在类型推断过程中用于：
    - 统一类型变量和具体类型
    - 实现类型推断的合一算法
    - 处理类型约束的求解 *)

val new_type_var : unit -> typ
(** 生成新的类型变量，用于类型推断

    @return 新的类型变量

    该函数生成唯一的类型变量标识符，用于类型推断过程中的类型占位。 生成的类型变量保证在整个推断过程中的唯一性，避免变量名冲突。

    使用场景：
    - 类型推断中的类型占位
    - 泛型函数的类型参数
    - 类型约束的表示 *)

val empty_subst : type_subst
(** 空的类型替换映射

    @return 空的类型替换

    空替换表示没有任何类型变量被替换的状态， 是类型推断算法的初始状态和中性元素。 *)

val single_subst : string -> typ -> type_subst
(** 创建单一类型替换映射

    @param var_name 类型变量名称
    @param typ 替换的目标类型
    @return 包含单一替换的映射

    该函数创建一个只包含一个类型变量替换的映射， 常用于类型推断中的基本替换操作。 *)

val string_of_typ : typ -> string
(** 将类型转换为字符串表示

    @param typ 要转换的类型
    @return 类型的字符串表示

    该函数将类型转换为人类可读的字符串格式，用于：
    - 错误消息的类型显示
    - 调试信息的输出
    - 类型注解的生成

    支持所有类型的格式化，包括复杂的嵌套类型和多态类型。 *)

val free_vars : typ -> string list
(** 获取类型中的自由类型变量列表

    @param typ 要分析的类型
    @return 类型中所有自由变量的名称列表

    自由变量是指在类型表达式中出现但未被绑定的类型变量。 该函数递归遍历类型结构，收集所有自由变量：
    - 基础类型：无自由变量
    - 类型变量：变量本身
    - 复合类型：递归收集子类型的自由变量

    用途：
    - 类型方案的泛化
    - 类型替换的范围确定
    - 类型推断的约束分析 *)

val contains_type_var : string -> typ -> bool
(** 检查类型是否包含指定的类型变量

    @param var_name 要检查的类型变量名称
    @param typ 要检查的类型
    @return 布尔值，true表示包含该类型变量

    该函数用于检查类型中是否包含特定的类型变量， 常用于类型推断中的occurs检查，防止无限递归类型的产生。

    用途：
    - 类型统一中的occurs检查
    - 类型替换的循环检测
    - 类型约束的一致性检查 *)

val is_base_type : typ -> bool
(** 检查类型是否是基础类型

    @param typ 要检查的类型
    @return 布尔值，true表示是基础类型

    基础类型包括：IntType_T、FloatType_T、StringType_T、BoolType_T、UnitType_T

    该函数用于类型分析和优化，帮助区分基础类型和复合类型。 *)

val is_compound_type : typ -> bool
(** 检查类型是否是复合类型

    @param typ 要检查的类型
    @return 布尔值，true表示是复合类型

    复合类型包括：函数类型、元组类型、列表类型、数组类型等

    该函数与is_base_type互补，用于类型分析和处理策略选择。 *)
