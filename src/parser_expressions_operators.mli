(** 骆言语法分析器运算符和特殊表达式解析模块接口
    
    本模块提供运算符和特殊表达式的解析功能，从基础表达式解析器中分离出来。
    
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-24 *)

open Ast
open Lexer

(** ==================== 标签表达式解析 ==================== *)

(** 解析标签表达式（多态变体）
    @param parse_primary_expr 基础表达式解析函数
    @param state 解析器状态
    @return 解析结果和新状态 *)
val parse_tag_expr : (Parser_utils.parser_state -> expr * Parser_utils.parser_state) -> 
                    Parser_utils.parser_state -> expr * Parser_utils.parser_state

(** ==================== 括号表达式解析 ==================== *)

(** 解析括号表达式
    @param parse_expr 表达式解析函数
    @param state 解析器状态
    @return 解析结果和新状态 *)
val parse_parenthesized_expr : (Parser_utils.parser_state -> expr * Parser_utils.parser_state) -> 
                              Parser_utils.parser_state -> expr * Parser_utils.parser_state

(** ==================== 模块表达式解析 ==================== *)

(** 解析模块表达式
    @param state 解析器状态
    @return 解析结果和新状态 *)
val parse_module_expr : Parser_utils.parser_state -> expr * Parser_utils.parser_state

(** ==================== 诗词表达式解析 ==================== *)

(** 解析古典诗词表达式
    @param state 解析器状态
    @return 解析结果和新状态 *)
val parse_poetry_expr : Parser_utils.parser_state -> expr * Parser_utils.parser_state

(** ==================== 古雅体表达式解析 ==================== *)

(** 解析古雅体表达式
    @param parse_expr 表达式解析函数
    @param state 解析器状态
    @return 解析结果和新状态 *)
val parse_ancient_expr : (Parser_utils.parser_state -> expr * Parser_utils.parser_state) -> 
                        Parser_utils.parser_state -> expr * Parser_utils.parser_state

(** ==================== 容器表达式解析 ==================== *)

(** 解析容器表达式（数组、记录、括号）
    @param parse_expr 表达式解析函数
    @param parse_array_expr 数组表达式解析函数
    @param parse_record_expr 记录表达式解析函数
    @param state 解析器状态
    @return 解析结果和新状态 *)
val parse_container_exprs : (Parser_utils.parser_state -> expr * Parser_utils.parser_state) ->
                           (Parser_utils.parser_state -> expr * Parser_utils.parser_state) ->
                           (Parser_utils.parser_state -> expr * Parser_utils.parser_state) ->
                           Parser_utils.parser_state -> expr * Parser_utils.parser_state

(** ==================== 特殊关键字表达式解析 ==================== *)

(** 解析特殊关键字表达式
    @param parse_expr 表达式解析函数
    @param parse_array_expr 数组表达式解析函数
    @param parse_record_expr 记录表达式解析函数
    @param state 解析器状态
    @return 解析结果和新状态 *)
val parse_special_keyword_exprs : (Parser_utils.parser_state -> expr * Parser_utils.parser_state) ->
                                 (Parser_utils.parser_state -> expr * Parser_utils.parser_state) ->
                                 (Parser_utils.parser_state -> expr * Parser_utils.parser_state) ->
                                 Parser_utils.parser_state -> expr * Parser_utils.parser_state

(** ==================== Token识别函数 ==================== *)

(** 判断是否为容器类型token
    @param token 待检查的token
    @return 是否为容器token *)
val is_container_token : token -> bool

(** 判断是否为特殊关键字token
    @param token 待检查的token
    @return 是否为特殊关键字token *)
val is_special_keyword_token : token -> bool