(** 骆言语法分析器函数调用处理模块接口 - Chinese Programming Language Parser Function Calls Interface *)

(** {1 概述}

    本模块专门处理骆言语言中的函数调用表达式解析，支持多种调用语法：
    - 括号形式的函数调用：函数名(参数1, 参数2)
    - 无括号形式的函数调用：函数名 参数1 参数2
    - 带标签的函数调用：函数名 ~标签1:值1 ~标签2:值2

    设计目标：
    - 支持中英文混合的函数调用语法
    - 处理复杂的参数列表结构
    - 提供灵活的标签参数支持
    - 统一的错误处理机制

    @author 骆言编程团队
    @version 1.0
    @since 2025-07-19 *)

(** {2 核心函数调用解析} *)

val parse_function_call_or_variable :
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  (Ast.expr -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  string ->
  Parser_utils.parser_state ->
  Ast.expr * Parser_utils.parser_state
(** 解析函数调用或变量引用的主入口函数

    根据当前token类型自动选择合适的解析策略：
    - 遇到波浪号(~)时解析标签函数调用
    - 遇到左括号时解析括号形式函数调用
    - 其他情况解析无括号函数调用或变量引用

    @param parse_expression 表达式解析函数
    @param parse_primary_expression 基础表达式解析函数
    @param parse_postfix_expression 后缀表达式解析函数
    @param name 函数或变量名称
    @param state 当前解析器状态
    @return (解析得到的表达式, 更新后的解析器状态)
    @raise SyntaxError 当遇到语法错误时 *)

(** {3 标签函数调用解析} *)

val parse_labeled_function_call :
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  (Ast.expr -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  string ->
  Parser_utils.parser_state ->
  Ast.expr * Parser_utils.parser_state
(** 解析带标签的函数调用

    处理形如 "函数名 ~标签1:值1 ~标签2:值2" 的调用语法。 标签参数允许以任意顺序传递，提高函数调用的可读性。

    @param parse_expression 表达式解析函数
    @param parse_postfix_expression 后缀表达式解析函数
    @param parse_primary_expression 基础表达式解析函数
    @param name 函数名称
    @param state 当前解析器状态
    @return (LabeledFunCallExpr表达式, 更新后的解析器状态) *)

(** {4 括号函数调用解析} *)

val parse_parenthesized_function_call :
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  (Ast.expr -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  string ->
  Parser_utils.parser_state ->
  Ast.expr * Parser_utils.parser_state
(** 解析括号形式的函数调用

    处理标准的函数调用语法：函数名(参数1, 参数2, ...) 支持中英文括号：() 和 （） 支持中英文逗号分隔：, 和 ，

    @param parse_expression 表达式解析函数
    @param parse_postfix_expression 后缀表达式解析函数
    @param name 函数名称
    @param state 当前解析器状态
    @return (FunCallExpr表达式, 更新后的解析器状态)
    @raise SyntaxError 当括号不匹配或参数语法错误时 *)

val parse_parenthesized_function_args :
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  Parser_utils.parser_state ->
  Ast.expr list * Parser_utils.parser_state
(** 解析括号内的函数参数列表

    递归解析逗号分隔的参数列表，直到遇到右括号。 支持空参数列表和任意数量的参数。

    @param parse_expression 表达式解析函数
    @param state 当前解析器状态（应指向左括号之后）
    @return (参数表达式列表, 更新后的解析器状态)
    @raise SyntaxError 当参数语法错误或括号不匹配时 *)

(** {5 无括号函数调用解析} *)

val parse_unparenthesized_function_call_or_variable :
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  (Ast.expr -> Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  string ->
  Parser_utils.parser_state ->
  Ast.expr * Parser_utils.parser_state
(** 解析无括号形式的函数调用或变量引用

    处理简洁的函数调用语法：函数名 参数1 参数2 ... 如果没有参数，则解析为变量引用。

    @param parse_primary_expression 基础表达式解析函数
    @param parse_postfix_expression 后缀表达式解析函数
    @param name 函数或变量名称
    @param state 当前解析器状态
    @return (FunCallExpr或VarExpr表达式, 更新后的解析器状态) *)

val collect_function_arguments :
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  Parser_utils.parser_state ->
  Ast.expr list * Parser_utils.parser_state
(** 收集无括号函数调用的参数

    持续收集基础表达式作为函数参数，直到遇到不能作为参数的token。 支持的参数类型包括：
    - 带引号的标识符
    - 整数和浮点数字面量
    - 中文数字
    - 字符串字面量
    - 布尔值字面量

    @param parse_primary_expression 基础表达式解析函数
    @param state 当前解析器状态
    @return (参数表达式列表（已反转），更新后的解析器状态) *)

(** {6 标签参数处理} *)

val parse_label_arg_list :
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  Ast.label_arg list ->
  Parser_utils.parser_state ->
  Ast.label_arg list * Parser_utils.parser_state
(** 解析标签参数列表

    递归解析以波浪号(~)开头的标签参数，直到遇到非标签token。 每个标签参数的格式为：~标签名:值表达式

    @param parse_primary_expression 基础表达式解析函数
    @param arg_list 已解析的标签参数列表（累积器）
    @param state 当前解析器状态
    @return (标签参数列表（已反转），更新后的解析器状态) *)

val parse_label_arg :
  (Parser_utils.parser_state -> Ast.expr * Parser_utils.parser_state) ->
  Parser_utils.parser_state ->
  Ast.label_arg * Parser_utils.parser_state
(** 解析单个标签参数

    解析形如 "标签名:值表达式" 的标签参数。 标签名必须是有效的标识符，冒号是必需的分隔符。

    @param parse_primary_expression 基础表达式解析函数
    @param state 当前解析器状态（应指向标签名）
    @return (标签参数记录, 更新后的解析器状态)
    @raise SyntaxError 当标签语法错误或缺少冒号时 *)

(** {7 设计说明}

    本模块采用高阶函数设计，通过参数传递其他解析函数，实现：

    1. **模块解耦**: 避免循环依赖，保持模块间的清晰边界 2. **解析器组合**: 支持不同类型表达式解析器的灵活组合 3. **错误传播**: 统一的错误处理和状态传递机制 4.
    **语法扩展**: 便于添加新的函数调用语法支持

    使用模式：
    - 主解析器调用本模块函数进行函数调用解析
    - 通过函数参数传递具体的表达式解析逻辑
    - 保持解析器状态的一致性和错误处理的统一性 *)
