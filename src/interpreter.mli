(** 骆言解释器模块接口 - Chinese Programming Language Interpreter Module Interface

    这个模块是骆言编程语言的核心解释器模块，提供语言的执行环境和程序解释功能。 它负责管理全局环境、执行程序语句、处理宏展开和模块系统。

    该模块的主要职责包括：
    - 维护全局符号表（宏、模块、递归函数、函子）
    - 提供程序执行和语句求值接口
    - 支持交互式和批处理模式的程序解释
    - 管理运行时环境和值的生命周期

    @author 骆言项目组
    @since 0.1.0 *)

open Ast
open Value_operations

val macro_table : (string, Ast.macro_def) Hashtbl.t
(** 全局宏表，存储用户定义的宏定义

    键：宏名称（字符串） 值：宏定义（包含参数模式和替换体）

    该表用于在程序执行过程中查找和展开宏调用。 宏表在程序初始化时创建，并在遇到宏定义时更新。 *)

val module_table : (string, (string * runtime_value) list) Hashtbl.t
(** 全局模块表，存储已定义的模块及其导出符号

    键：模块名称（字符串） 值：模块导出的符号列表，每个符号包含名称和运行时值

    模块表支持骆言的模块系统，允许代码组织和命名空间管理。 模块在首次引入时加载，并缓存在此表中以供后续引用。 *)

val recursive_functions : (string, runtime_value) Hashtbl.t
(** 全局递归函数表，存储递归函数定义

    键：函数名称（字符串） 值：函数的运行时值表示

    该表专门用于处理递归函数的定义和调用，确保递归函数可以正确引用自身。 递归函数在定义时会被预先注册到此表中，以支持递归调用。 *)

val functor_table : (string, identifier * module_type * expr) Hashtbl.t
(** 全局函子表，存储函子（参数化模块）定义

    键：函子名称（字符串） 值：元组包含 (参数标识符, 参数模块类型, 函子体表达式)

    函子是骆言高级模块系统的一部分，允许定义参数化的模块。 函子在定义时注册到此表中，在应用时根据实际参数进行实例化。 *)

val expand_macro : Ast.macro_def -> expr list -> expr
(** 宏展开函数，将宏调用替换为其定义体

    @param macro_def 宏定义，包含参数模式和替换体
    @param args 宏调用的实际参数列表
    @return 展开后的表达式

    该函数实现宏的模式匹配和替换逻辑： 1. 将实际参数与宏定义的参数模式进行匹配 2. 在宏体中进行参数替换 3. 返回替换后的表达式用于进一步求值

    @raise MacroError 当参数匹配失败或替换过程出错时 *)

val execute_stmt : env -> stmt -> env * runtime_value
(** 执行单个语句，返回更新后的环境和执行结果

    @param env 当前执行环境，包含变量绑定和作用域信息
    @param stmt 待执行的语句
    @return 元组包含 (更新后的环境, 语句执行结果值)

    该函数是语句执行的核心入口点，支持所有类型的语句：
    - 表达式语句：求值表达式并返回结果
    - 变量定义：在环境中添加新的变量绑定
    - 函数定义：注册函数到当前环境
    - 控制流语句：条件判断、循环等
    - 模块相关语句：模块定义、导入等

    @raise RuntimeError 当语句执行过程中发生错误时
    @raise TypeError 当类型检查失败时 *)

val execute_program : program -> (runtime_value, string) result
(** 执行完整程序，返回程序执行结果或错误信息

    @param program 待执行的程序（语句列表）
    @return Result类型，成功时包含程序最终结果值，失败时包含错误信息

    该函数提供程序级别的执行接口： 1. 初始化全局执行环境 2. 按顺序执行程序中的所有语句 3. 处理程序执行过程中的异常和错误 4. 返回程序的最终执行结果

    程序执行过程中的错误会被捕获并转换为字符串形式返回。 *)

val interpret : program -> bool
(** 解释执行程序（带输出），返回执行是否成功

    @param program 待解释的程序
    @return 布尔值，true表示执行成功，false表示执行失败

    该函数提供交互式的程序解释功能：
    - 执行程序并将结果输出到标准输出
    - 捕获和显示执行过程中的错误信息
    - 提供详细的调试和诊断信息

    适用于交互式环境和开发调试场景。 *)

val interpret_quiet : program -> bool
(** 静默解释执行程序，返回执行是否成功

    @param program 待解释的程序
    @return 布尔值，true表示执行成功，false表示执行失败

    该函数提供静默模式的程序解释功能：
    - 执行程序但不输出结果到标准输出
    - 仅返回执行成功或失败的状态
    - 适用于批处理和自动化测试场景

    与 interpret 函数的区别在于不产生任何输出。 *)

val interpret_test : program -> bool
(** 测试模式解释执行程序，输出原始结果而不加前缀

    @param program 待解释的程序
    @return 布尔值，true表示执行成功，false表示执行失败

    该函数提供测试模式的程序解释功能：
    - 执行程序并输出结果到标准输出，但不加"结果: "前缀
    - 适用于端到端测试场景 *)

val interactive_eval : expr -> env -> runtime_value * env
(** 交互式表达式求值，用于REPL环境

    @param expr 待求值的表达式
    @param env 当前环境上下文
    @return 元组包含 (表达式求值结果, 更新后的环境)

    该函数专门为交互式环境设计：
    - 支持单个表达式的即时求值
    - 保持环境状态的连续性
    - 处理副作用和环境更新

    常用于REPL（读取-求值-输出循环）系统中， 允许用户逐步输入表达式并查看结果。

    @raise RuntimeError 当表达式求值失败时 *)
