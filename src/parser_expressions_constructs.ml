(** 骆言语法分析器构造表达式解析模块
    
    本模块专门处理构造表达式的解析：
    - 括号表达式处理
    - 标签表达式(多态变体)
    - 类型关键字表达式
    - 后缀操作(字段访问、数组索引)
    
    技术债务重构 - Fix #1050
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-24 *)

open Ast
open Lexer
open Parser_utils

(** 判断token是否为类型关键字 *)
let is_type_keyword_token = function
  | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword | ListTypeKeyword
  | ArrayTypeKeyword ->
      true
  | _ -> false

(** 判断token是否为容器类型 *)
let is_container_token = function
  | LeftParen | ChineseLeftParen | LeftArray | ChineseLeftArray | LeftBrace -> true
  | _ -> false

(** 解析标签表达式 *)
let parse_tag_expr parse_primary_expr state =
  (* 多态变体表达式: 标签 「标签名」 [值] *)
  let state1 = advance_parser state in
  let tag_name, state2 = parse_identifier state1 in
  let token, _ = current_token state2 in
  if is_identifier_like token then
    (* 有值的多态变体: 标签 「标签名」 值 *)
    let value_expr, state3 = parse_primary_expr state2 in
    (PolymorphicVariantExpr (tag_name, Some value_expr), state3)
  else
    (* 无值的多态变体: 标签 「标签名」 *)
    (PolymorphicVariantExpr (tag_name, None), state2)

(** 类型关键字到中文名称的映射表 *)
let type_keyword_mapping = [
  (IntTypeKeyword, "整数");
  (FloatTypeKeyword, "浮点数");
  (StringTypeKeyword, "字符串");
  (BoolTypeKeyword, "布尔值");
  (ListTypeKeyword, "列表");
  (ArrayTypeKeyword, "数组");
]

(** 公共的类型关键字处理函数 *)
let parse_type_keyword_to_var type_name state =
  let state1 = advance_parser state in
  let _next_token, _ = current_token state1 in
  (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
  (VarExpr type_name, state1)

(** 解析类型关键字表达式 *)
let parse_type_keyword_expr state =
  let token, _ = current_token state in
  match List.assoc_opt token type_keyword_mapping with
  | Some type_name -> parse_type_keyword_to_var type_name state
  | None ->
      raise
        (Parser_utils.make_unexpected_token_error
           ("parse_type_keyword_expr: " ^ show_token token)
           (snd (current_token state)))

(** 解析括号表达式 *)
let parse_parenthesized_expr parse_expr parse_postfix_expr state =
  let state1 = advance_parser state in
  let token, _ = current_token state1 in
  if is_right_paren token then
    (* 处理单元字面量 () *)
    let state2 = advance_parser state1 in
    parse_postfix_expr (LitExpr UnitLit) state2
  else
    (* 处理括号表达式 (expr) *)
    let expr, state2 = parse_expr state1 in
    let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
    parse_postfix_expr expr state3


(** 解析容器表达式（括号、数组、记录） - 接口要求的函数 *)
let parse_container_expressions parse_expression parse_array_expression parse_record_expression state =
  let token, _ = current_token state in
  match token with
  | LeftParen | ChineseLeftParen ->
      (* 括号表达式 *)
      let state1 = advance_parser state in
      let expr, state2 = parse_expression state1 in
      let state3 = expect_token_punctuation state2 is_right_paren "right paren" in
      (expr, state3)
  | LeftArray | ChineseLeftArray ->
      (* 数组表达式 *)
      parse_array_expression state
  | LeftBrace ->
      (* 记录表达式 *)
      parse_record_expression state
  | _ ->
      let _, pos = current_token state in
      raise (Parser_utils.make_unexpected_token_error
             ("parse_container_expressions: 不支持的容器token " ^ show_token token)
             pos)