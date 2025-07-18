(** 骆言解释器模式匹配模块接口 - Chinese Programming Language Interpreter Pattern Matcher Interface

    这个模块是骆言编程语言模式匹配功能的核心实现，负责处理模式匹配语句、 异常处理和数据结构解构等高级语言特性。模式匹配是函数式编程语言的重要特性， 提供了强大的数据处理和控制流能力。

    该模块的主要职责包括：
    - 实现模式匹配的核心算法
    - 支持各种模式类型的匹配逻辑
    - 处理模式匹配中的变量绑定
    - 管理构造器函数的注册和使用
    - 提供异常处理的模式匹配支持

    支持的模式类型：
    - 字面量模式：整数、字符串、布尔值等常量匹配
    - 变量模式：变量绑定和通配符匹配
    - 构造器模式：代数数据类型的构造器匹配
    - 元组模式：元组的结构化匹配
    - 列表模式：列表的头尾分解匹配
    - 记录模式：记录类型的字段匹配
    - 或模式：多个模式的选择匹配
    - 守卫模式：带条件的模式匹配

    @author 骆言项目组
    @since 0.1.0 *)

val match_pattern :
  Ast.pattern ->
  Value_operations.runtime_value ->
  (string * Value_operations.runtime_value) list ->
  (string * Value_operations.runtime_value) list option
(** 模式匹配核心函数，尝试将值与模式进行匹配

    @param pattern 待匹配的模式
    @param value 待匹配的运行时值
    @param env 当前环境，用于查找构造器和变量
    @return 匹配成功时返回Some(新的变量绑定)，失败时返回None

    该函数是模式匹配的核心实现，支持所有类型的模式匹配：

    1. 字面量模式匹配：
    - 整数字面量：检查值是否为相同的整数
    - 浮点数字面量：检查值是否为相同的浮点数
    - 字符串字面量：检查值是否为相同的字符串
    - 布尔值字面量：检查值是否为相同的布尔值
    - 单位值：检查值是否为unit

    2. 变量模式匹配：
    - 标识符变量：总是匹配成功，绑定变量到值
    - 通配符模式：总是匹配成功，不绑定任何变量
    - 类型标注变量：匹配成功且类型兼容时绑定变量

    3. 构造器模式匹配：
    - 无参构造器：检查值是否为相同的构造器
    - 有参构造器：递归匹配构造器的参数
    - 递归类型构造器：支持递归数据结构的匹配

    4. 元组模式匹配：
    - 检查值是否为元组类型
    - 递归匹配元组的每个元素
    - 支持嵌套元组的匹配

    5. 列表模式匹配：
    - 空列表模式：检查值是否为空列表
    - 头尾模式：将列表分解为头部和尾部进行匹配
    - 完全列表模式：匹配固定长度的列表

    6. 记录模式匹配：
    - 字段模式：匹配记录的指定字段
    - 部分匹配：只匹配记录的部分字段
    - 嵌套记录：支持记录字段的递归匹配

    7. 或模式匹配：
    - 尝试匹配多个候选模式
    - 返回第一个成功匹配的结果
    - 支持模式的优先级排序

    8. 守卫模式匹配：
    - 先执行基本模式匹配
    - 然后检查守卫条件
    - 只有条件为真时才匹配成功

    匹配过程中的变量绑定：
    - 收集模式中的所有变量绑定
    - 检查变量名称的唯一性
    - 创建新的环境绑定
    - 支持变量的类型推断

    性能优化：
    - 模式匹配的编译时优化
    - 决策树的构建和优化
    - 重复模式的缓存机制

    @raise PatternMatchError 当模式匹配遇到无效模式时
    @raise TypeError 当类型不兼容时
    @raise UnboundConstructor 当构造器未定义时 *)

val execute_match :
  (string * Value_operations.runtime_value) list ->
  Value_operations.runtime_value ->
  Ast.match_branch list ->
  ((string * Value_operations.runtime_value) list -> Ast.expr -> Value_operations.runtime_value) ->
  Value_operations.runtime_value
(** 执行模式匹配语句，选择匹配的分支并执行

    @param env 当前执行环境
    @param value 待匹配的值
    @param branches 模式匹配分支列表
    @param eval_expr 表达式求值函数
    @return 匹配分支的执行结果

    该函数实现match表达式的执行逻辑：

    1. 分支尝试过程：
    - 按顺序尝试每个分支的模式匹配
    - 对每个分支调用match_pattern函数
    - 选择第一个匹配成功的分支

    2. 分支执行过程：
    - 合并原环境和匹配绑定的变量
    - 在新环境中执行分支的表达式
    - 返回表达式的执行结果

    3. 守卫条件处理：
    - 如果分支包含守卫条件，先求值守卫表达式
    - 只有守卫条件为真时才执行分支体
    - 支持复杂的守卫条件逻辑

    4. 完整性检查：
    - 检查模式匹配是否覆盖所有情况
    - 警告或错误提示不完整的模式匹配
    - 支持默认分支的处理

    5. 嵌套匹配支持：
    - 支持模式匹配的嵌套使用
    - 正确处理嵌套匹配的变量作用域
    - 优化嵌套匹配的性能

    执行流程： 1. 遍历所有分支 2. 对每个分支尝试模式匹配 3. 如果匹配成功，检查守卫条件（如果有） 4. 执行匹配分支的表达式 5. 返回执行结果

    @raise MatchFailure 当没有任何分支匹配时
    @raise GuardFailure 当守卫条件求值失败时
    @raise RuntimeError 当分支表达式执行失败时 *)

val execute_exception_match :
  (string * Value_operations.runtime_value) list ->
  Value_operations.runtime_value ->
  Ast.match_branch list ->
  ((string * Value_operations.runtime_value) list -> Ast.expr -> Value_operations.runtime_value) ->
  Value_operations.runtime_value
(** 执行异常匹配，专门用于异常处理的模式匹配

    @param env 当前执行环境
    @param exception_value 抛出的异常值
    @param branches 异常处理分支列表
    @param eval_expr 表达式求值函数
    @return 异常处理分支的执行结果

    该函数实现try-catch语句中异常处理的模式匹配：

    1. 异常类型匹配：
    - 根据异常的类型信息进行匹配
    - 支持异常类型的层次结构匹配
    - 处理自定义异常类型的匹配

    2. 异常值解构：
    - 提取异常对象的详细信息
    - 支持异常参数的模式匹配
    - 绑定异常信息到变量

    3. 异常处理执行：
    - 在异常处理环境中执行分支
    - 支持异常的重新抛出
    - 处理异常处理过程中的嵌套异常

    4. 异常匹配特性：
    - 支持多种异常类型的统一处理
    - 提供异常信息的详细解构
    - 支持异常的条件匹配

    5. 错误恢复机制：
    - 支持异常的优雅恢复
    - 提供异常处理的清理逻辑
    - 维护异常处理的状态一致性

    与普通模式匹配的区别：
    - 专门处理异常类型的匹配
    - 支持异常的特殊语义
    - 提供异常处理的上下文信息
    - 支持异常的传播控制

    @raise UnhandledException 当没有合适的异常处理分支时
    @raise NestedExceptionError 当异常处理过程中发生新异常时
    @raise InvalidExceptionPattern 当异常模式无效时 *)

val register_constructors :
  (string * Value_operations.runtime_value) list ->
  Ast.type_def ->
  (string * Value_operations.runtime_value) list
(** 注册类型定义中的构造器函数到环境

    @param env 当前环境
    @param type_def 类型定义
    @return 注册构造器后的新环境

    该函数处理用户定义类型的构造器注册：

    1. 构造器函数生成：
    - 为每个构造器创建对应的函数
    - 设置构造器的参数类型和返回类型
    - 生成构造器的运行时表示

    2. 类型信息管理：
    - 注册类型的元信息
    - 维护类型和构造器的映射关系
    - 支持类型的递归定义

    3. 构造器函数特性：
    - 支持有参数和无参数的构造器
    - 处理构造器的重载和多态
    - 优化构造器的调用性能

    4. 环境更新：
    - 在当前环境中添加构造器绑定
    - 维护构造器的作用域和可见性
    - 支持构造器的模块化管理

    5. 递归类型支持：
    - 处理递归类型的构造器定义
    - 支持相互递归的类型定义
    - 管理递归构造器的初始化

    构造器注册过程： 1. 解析类型定义中的构造器信息 2. 为每个构造器生成函数实现 3. 注册构造器到当前环境 4. 更新类型系统的构造器映射 5. 返回更新后的环境

    支持的构造器类型：
    - 枚举型构造器：无参数的简单构造器
    - 产品型构造器：有参数的复合构造器
    - 递归型构造器：引用自身类型的构造器
    - 多态型构造器：带类型参数的构造器

    @raise DuplicateConstructor 当构造器名称重复时
    @raise InvalidTypeDefinition 当类型定义无效时
    @raise RecursiveTypeError 当递归类型定义有问题时 *)
