(** 骆言解释器二元运算模块接口 - Chinese Programming Language Interpreter Binary Operations Interface

    这个模块实现了骆言编程语言中所有二元运算符和一元运算符的执行逻辑。 运算符模块是语言解释器的基础组件，负责处理各种数值运算、比较运算、 逻辑运算等核心计算功能。

    该模块的主要职责包括：
    - 实现所有二元运算符的语义
    - 实现所有一元运算符的语义
    - 处理运算符的类型检查和转换
    - 提供运算错误的处理和报告
    - 支持运算符的重载和多态

    @author 骆言项目组
    @since 0.1.0 *)

open Value_operations

val execute_binary_op : Ast.binary_op -> runtime_value -> runtime_value -> runtime_value
(** 二元运算执行函数，处理两个操作数的运算
    @param op 二元运算符类型
    @param left_val 左操作数值
    @param right_val 右操作数值
    @return 运算结果值
    @raise RuntimeError 当运算不支持或遇到运行时错误时
    @raise TypeError 当操作数类型不兼容时
    @raise DivisionByZero 当除零运算时
    @raise OverflowError 当运算结果溢出时
    @raise InvalidOperation 当运算符不适用于给定类型时 *)

val execute_unary_op : Ast.unary_op -> runtime_value -> runtime_value
(** 一元运算执行函数，处理单个操作数的运算
    @param op 一元运算符类型
    @param value 操作数值
    @return 运算结果值
    @raise RuntimeError 当运算不支持或遇到运行时错误时
    @raise TypeError 当操作数类型不兼容时
    @raise OverflowError 当运算结果溢出时
    @raise InvalidOperation 当运算符不适用于给定类型时 *)
