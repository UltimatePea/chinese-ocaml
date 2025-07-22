(** 骆言语法分析器基础表达式解析模块 - 整合版
   
    本模块将原有的多个细分基础表达式模块整合为一个统一模块：
    - parser_expressions_primary.ml
    - parser_expressions_literals_primary.ml  
    - parser_expressions_keywords_primary.ml
    - parser_expressions_compound_primary.ml
    - parser_expressions_poetry_primary.ml
    - parser_expressions_identifiers.ml
    - parser_expressions_basic.ml (部分功能)
    
    整合目的：
    1. 减少模块间的循环依赖
    2. 提高代码的可维护性
    3. 简化项目结构
    4. 保持所有现有功能完整
    
    技术债务重构 - Fix #796
    @author 骆言AI代理
    @version 3.0 (整合版)
    @since 2025-07-21
*)

open Ast
open Lexer
open Parser_utils

(** ==================== 函数调用辅助函数 ==================== *)

(** 解析函数参数列表 - 重构版本 *)

(* 解析单个参数表达式的辅助函数 *)
let parse_single_argument parse_expression token current_state =
  match token with
  | QuotedIdentifierToken var_name ->
      let st1 = advance_parser current_state in
      (VarExpr var_name, st1)
  | IntToken i ->
      let st1 = advance_parser current_state in
      (LitExpr (IntLit i), st1)
  | ChineseNumberToken s ->
      let st1 = advance_parser current_state in
      let n = Parser_utils.chinese_number_to_int s in
      (LitExpr (IntLit n), st1)
  | FloatToken f ->
      let st1 = advance_parser current_state in
      (LitExpr (FloatLit f), st1)
  | StringToken s ->
      let st1 = advance_parser current_state in
      (LitExpr (StringLit s), st1)
  | TrueKeyword ->
      let st1 = advance_parser current_state in
      (LitExpr (BoolLit true), st1)
  | FalseKeyword ->
      let st1 = advance_parser current_state in
      (LitExpr (BoolLit false), st1)
  | OneKeyword ->
      let st1 = advance_parser current_state in
      (LitExpr (IntLit 1), st1)
  | LeftParen | ChineseLeftParen ->
      (* 使用完整表达式解析器来处理复杂的括号表达式（如嵌套函数调用） *)
      let st1 = advance_parser current_state in
      let inner_expr, st2 = parse_expression st1 in
      let st3 = expect_token_punctuation st2 is_right_paren "right parenthesis" in
      (inner_expr, st3)
  | _ -> 
      raise (Parser_utils.make_unexpected_token_error 
        ("Expected basic argument expression in function call, got: " ^ show_token token) 
        (snd (current_token current_state)))

(* 递归收集参数的辅助函数 *)
let rec collect_function_arguments parse_expression args current_state =
  let token, _ = current_token current_state in
  if Parser_expressions_utils.is_argument_token token then
    let arg_expr, next_state = parse_single_argument parse_expression token current_state in
    collect_function_arguments parse_expression (arg_expr :: args) next_state
  else
    (List.rev args, current_state)

(* 主函数参数解析函数 *)
let parse_function_arguments parse_expression state =
  collect_function_arguments parse_expression [] state

(** ==================== 字面量表达式解析 ==================== *)

(** 解析字面量表达式（整数、浮点数、字符串、布尔值） *)
let parse_literal_expr state =
  let token, _ = current_token state in
  match token with
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ ->
      let literal, state1 = parse_literal state in
      (LitExpr literal, state1)
  | BoolToken _ -> (
      (* 检查是否是复合标识符的开始（如"真值"、"假值"） *)
      let token_after, _ = peek_token state in
      match token_after with
      | QuotedIdentifierToken _ ->
          (* 可能是复合标识符，使用parse_identifier_allow_keywords解析 *)
          let name, state1 = parse_identifier_allow_keywords state in
          (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
          (VarExpr name, state1)
      | _ ->
          (* 解析为布尔字面量 *)
          let literal, state1 = parse_literal state in
          (LitExpr literal, state1))
  | OneKeyword ->
      (* 将"一"关键字转换为数字字面量1 *)
      let state1 = advance_parser state in
      (LitExpr (IntLit 1), state1)
  | _ ->
      raise (Parser_utils.make_unexpected_token_error
               ("parse_literal_expr: " ^ show_token token)
               (snd (current_token state)))

(** ==================== 标识符表达式解析 - 重构版本 ==================== *)

(* 决定是函数调用还是变量引用的辅助函数 *)
let parse_function_call_or_variable parse_expression name state =
  let next_token, _ = current_token state in
  if Parser_expressions_utils.is_argument_token next_token then
    (* 函数调用：收集参数 *)
    let args, final_state = parse_function_arguments parse_expression state in
    (FunCallExpr (VarExpr name, args), final_state)
  else
    (* 变量引用 *)
    (VarExpr name, state)

(* 处理带引号的标识符 *)
let parse_quoted_identifier parse_expression name state =
  let state1 = advance_parser state in
  (* 检查是否看起来像字符串字面量而非变量名 *)
  if Parser_expressions_utils.looks_like_string_literal name then
    (LitExpr (StringLit name), state1)
  else
    parse_function_call_or_variable parse_expression name state1

(* 处理特殊标识符 *)
let parse_special_identifier parse_expression name state =
  let state1 = advance_parser state in
  parse_function_call_or_variable parse_expression name state1

(* 处理数值关键字复合标识符 *)
let parse_number_keyword_identifier parse_expression state =
  let name, state1 = parse_wenyan_compound_identifier state in
  parse_function_call_or_variable parse_expression name state1

(* 处理其他关键字复合标识符 *)
let parse_keyword_compound_identifier parse_expression state =
  let name, state1 = parse_identifier_allow_keywords state in
  parse_function_call_or_variable parse_expression name state1

(** 解析标识符表达式（变量引用和函数调用）- 重构版本 *)
let parse_identifier_expr parse_expression state =
  let token, _ = current_token state in
  match token with
  | QuotedIdentifierToken name ->
      parse_quoted_identifier parse_expression name state
      
  | IdentifierTokenSpecial name ->
      parse_special_identifier parse_expression name state
      
  | NumberKeyword ->
      parse_number_keyword_identifier parse_expression state
      
  | EmptyKeyword | TypeKeyword | ThenKeyword | ElseKeyword | WithKeyword | WithOpKeyword
  | AsKeyword | WhenKeyword | TrueKeyword | FalseKeyword | AndKeyword | OrKeyword 
  | NotKeyword | ValueKeyword ->
      parse_keyword_compound_identifier parse_expression state
      
  | _ ->
      raise (Parser_utils.make_unexpected_token_error
               ("parse_identifier_expr: " ^ show_token token)
               (snd (current_token state)))

(** ==================== 关键字表达式解析 ==================== *)

(** 解析标签表达式 *)
let parse_tag_expr parse_primary_expression state =
  (* 多态变体表达式: 标签 「标签名」 [值] *)
  let state1 = advance_parser state in
  let tag_name, state2 = parse_identifier state1 in
  let token, _ = current_token state2 in
  if is_identifier_like token then
    (* 有值的多态变体: 标签 「标签名」 值 *)
    let value_expr, state3 = parse_primary_expression state2 in
    (PolymorphicVariantExpr (tag_name, Some value_expr), state3)
  else
    (* 无值的多态变体: 标签 「标签名」 *)
    (PolymorphicVariantExpr (tag_name, None), state2)

(** 解析类型关键字表达式 *)
let parse_type_keyword_expr state =
  let token, _ = current_token state in
  match token with
  | IntTypeKeyword ->
      let state1 = advance_parser state in
      let _next_token, _ = current_token state1 in
      (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
        (VarExpr "整数", state1)
  | FloatTypeKeyword ->
      let state1 = advance_parser state in
      let _next_token, _ = current_token state1 in
      (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
        (VarExpr "浮点数", state1)
  | StringTypeKeyword ->
      let state1 = advance_parser state in
      let _next_token, _ = current_token state1 in
      (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
        (VarExpr "字符串", state1)
  | BoolTypeKeyword ->
      let state1 = advance_parser state in
      let _next_token, _ = current_token state1 in
      (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
        (VarExpr "布尔值", state1)
  | ListTypeKeyword ->
      let state1 = advance_parser state in
      let _next_token, _ = current_token state1 in
      (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
        (VarExpr "列表", state1)
  | ArrayTypeKeyword ->
      let state1 = advance_parser state in
      let _next_token, _ = current_token state1 in
      (* 暂时处理为变量引用，待后续完善函数调用逻辑 *)
        (VarExpr "数组", state1)
  | _ ->
      raise (Parser_utils.make_unexpected_token_error
               ("parse_type_keyword_expr: " ^ show_token token)
               (snd (current_token state)))

(** ==================== 复合表达式解析 ==================== *)

(** 解析括号表达式 *)
let parse_parenthesized_expr parse_expression parse_postfix_expression state =
  let state1 = advance_parser state in
  let expr, state2 = parse_expression state1 in
  let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
  parse_postfix_expression expr state3

(** 解析模块表达式 *)
let parse_module_expr state =
  Parser_expressions_utils.parse_module_expression state


(** ==================== 诗词表达式解析 ==================== *)

(** 解析古典诗词表达式 *)
let parse_poetry_expr state =
  let token, _ = current_token state in
  match token with
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword ->
      Parser_poetry.parse_poetry_expression state
  | _ ->
      raise (Parser_utils.make_unexpected_token_error
               ("parse_poetry_expr: " ^ show_token token)
               (snd (current_token state)))

(** ==================== 古雅体表达式解析 ==================== *)

(** 解析古雅体表达式 *)
let parse_ancient_expr parse_expression state =
  let token, _ = current_token state in
  match token with
  | AncientDefineKeyword ->
      Parser_ancient.parse_ancient_function_definition parse_expression state
  | AncientObserveKeyword ->
      Parser_ancient.parse_ancient_match_expression parse_expression Parser_patterns.parse_pattern state
  | AncientListStartKeyword ->
      Parser_ancient.parse_ancient_list_expression parse_expression state
  | _ ->
      raise (Parser_utils.make_unexpected_token_error
               ("parse_ancient_expr: " ^ show_token token)
               (snd (current_token state)))

(** ==================== 后缀表达式解析 ==================== *)

(** 解析后缀表达式（字段访问、数组索引等） *)
let rec parse_postfix_expr parse_expression expr state =
  let token, _ = current_token state in
  match token with
  | Dot -> (
      let state1 = advance_parser state in
      let token2, _ = current_token state1 in
      match token2 with
      | QuotedIdentifierToken field_name ->
          let state2 = advance_parser state1 in
          let new_expr = FieldAccessExpr (expr, field_name) in
          parse_postfix_expr parse_expression new_expr state2
      | _ -> (expr, state))
  | LeftBracket | ChineseLeftBracket ->
      (* 数组索引 *)
      let state1 = advance_parser state in
      let index_expr, state2 = parse_expression state1 in
      let state3 = expect_token_punctuation state2 is_right_bracket "right bracket" in
      let new_expr = ArrayAccessExpr (expr, index_expr) in
      parse_postfix_expr parse_expression new_expr state3
  | _ -> (expr, state)

(** ==================== 主解析函数 - 重构版本 ==================== *)

(* 解析字面量表达式辅助函数 *)
let rec parse_literal_expressions state =
  parse_literal_expr state

(* 解析标识符表达式辅助函数 *)
and parse_identifier_expressions parse_expression state =
  parse_identifier_expr parse_expression state

(* 解析类型关键字表达式辅助函数 *)
and parse_type_keyword_expressions state =
  parse_type_keyword_expr state

(* 解析容器表达式辅助函数 *)
and parse_container_expressions parse_expression parse_array_expression parse_record_expression state =
  let token, pos = current_token state in
  match token with
  (* 括号表达式 *)
  | LeftParen | ChineseLeftParen ->
      parse_parenthesized_expr parse_expression (parse_postfix_expr parse_expression) state
  (* 数组表达式 *)
  | LeftArray | ChineseLeftArray ->
      let array_expr, state1 = parse_array_expression state in
      parse_postfix_expr parse_expression array_expr state1
  (* 记录表达式 *)
  | LeftBrace ->
      let record_expr, state1 = parse_record_expression state in
      parse_postfix_expr parse_expression record_expr state1
  | _ ->
      raise (Parser_utils.make_unexpected_token_error
               ("parse_container_expressions: 不支持的容器token " ^ show_token token)
               pos)

(* 解析特殊关键字表达式辅助函数 *)
and parse_special_keyword_expressions parse_expression _parse_array_expression _parse_record_expression state =
  let token, pos = current_token state in
  match token with
  (* 标签表达式 - 需要特殊处理递归调用 *)
  | TagKeyword ->
      (* 暂时跳过标签表达式的递归调用，留待后续处理 *)
      raise (Parser_utils.make_unexpected_token_error
               "TagKeyword递归调用需要在主函数中处理" pos)
  (* 模块表达式 *)
  | ModuleKeyword ->
      parse_module_expr state
  (* 组合表达式 - 委派给结构化表达式模块 *)
  | CombineKeyword ->
      raise (Parser_utils.make_unexpected_token_error
               "CombineKeyword应由主表达式解析器处理" pos)
  (* 诗词表达式 *)
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword ->
      parse_poetry_expr state
  (* 古雅体表达式 *)
  | AncientDefineKeyword | AncientObserveKeyword | AncientListStartKeyword ->
      parse_ancient_expr parse_expression state
  | _ ->
      raise (Parser_utils.make_unexpected_token_error
               ("parse_special_keyword_expressions: 不支持的特殊token " ^ show_token token)
               pos)

(* 处理错误情况和不支持的语法 *)
and handle_unsupported_syntax token pos =
  match token with
  (* 现代列表语法禁用提示 *)
  | LeftBracket | ChineseLeftBracket ->
      let ancient_list_error_msg =
        "请使用古雅体列表语法替代 [...]。\n\
         空列表：空空如也\n\
         有元素的列表：列开始 元素1 其一 元素2 其二 元素3 其三 列结束\n\
         模式匹配：有首有尾 首名为「变量名」尾名为「尾部变量名」"
      in
      raise (SyntaxError (ancient_list_error_msg, pos))
  (* DefineKeyword特殊处理 *)
  | DefineKeyword ->
      raise (Types.ParseError ("DefineKeyword应由主解析器处理", pos.line, pos.column))
  (* 其他不支持的token *)
  | _ ->
      raise (Parser_utils.make_unexpected_token_error
               ("parse_primary_expr: 不支持的token " ^ show_token token)
               pos)

(** 解析基础表达式 - 重构后的统一入口函数 *)
and parse_primary_expr parse_expression parse_array_expression parse_record_expression state =
  (* 首先跳过所有换行符 *)
  let state = Parser_expressions_utils.skip_newlines state in
  let token, pos = current_token state in
  
  try
    match token with
    (* 字面量表达式 *)
    | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ 
    | BoolToken _ | OneKeyword ->
        parse_literal_expressions state
        
    (* 标识符表达式 *)
    | QuotedIdentifierToken _ | IdentifierTokenSpecial _ | NumberKeyword | EmptyKeyword | TypeKeyword 
    | ThenKeyword | ElseKeyword | WithKeyword | WithOpKeyword | AsKeyword | WhenKeyword
    | TrueKeyword | FalseKeyword | AndKeyword | OrKeyword | NotKeyword | ValueKeyword ->
        parse_identifier_expressions parse_expression state
        
    (* 类型关键字表达式 *)
    | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword 
    | BoolTypeKeyword | ListTypeKeyword | ArrayTypeKeyword ->
        parse_type_keyword_expressions state
        
    (* 容器表达式 *)
    | LeftParen | ChineseLeftParen | LeftArray | ChineseLeftArray | LeftBrace ->
        parse_container_expressions parse_expression parse_array_expression parse_record_expression state
        
    (* 标签表达式 - 需要递归调用 *)
    | TagKeyword ->
        parse_tag_expr (parse_primary_expr parse_expression parse_array_expression parse_record_expression) state
        
    (* 其他特殊关键字表达式 *)
    | ModuleKeyword | CombineKeyword | ParallelStructKeyword 
    | FiveCharKeyword | SevenCharKeyword | AncientDefineKeyword 
    | AncientObserveKeyword | AncientListStartKeyword ->
        parse_special_keyword_expressions parse_expression parse_array_expression parse_record_expression state
        
    (* 不支持的语法 *)
    | _ ->
        handle_unsupported_syntax token pos
        
  with
  | exn ->
      (* 添加上下文信息到异常 *)
      let error_msg = Printf.sprintf "parse_primary_expr在解析token %s时失败: %s" 
                        (show_token token) (Printexc.to_string exn) in
      raise (Parser_utils.make_unexpected_token_error error_msg pos)

(** ==================== 向后兼容性函数 ==================== *)

(** 向后兼容：解析函数调用或变量 *)
let parse_function_call_or_variable name state =
  let next_token, _ = current_token state in
  if Parser_expressions_utils.is_argument_token next_token then
    (* 函数调用：收集参数 - 使用只解析基本表达式的函数 *)
    let basic_expression_parser st =
      let token, _ = current_token st in
      match token with
      | QuotedIdentifierToken var_name ->
          let st1 = advance_parser st in
          (VarExpr var_name, st1)
      | IntToken i ->
          let st1 = advance_parser st in
          (LitExpr (IntLit i), st1)
      | ChineseNumberToken s ->
          let st1 = advance_parser st in
          let n = Parser_utils.chinese_number_to_int s in
          (LitExpr (IntLit n), st1)
      | FloatToken f ->
          let st1 = advance_parser st in
          (LitExpr (FloatLit f), st1)
      | StringToken s ->
          let st1 = advance_parser st in
          (LitExpr (StringLit s), st1)
      | TrueKeyword ->
          let st1 = advance_parser st in
          (LitExpr (BoolLit true), st1)
      | FalseKeyword ->
          let st1 = advance_parser st in
          (LitExpr (BoolLit false), st1)
      | OneKeyword ->
          let st1 = advance_parser st in
          (LitExpr (IntLit 1), st1)
      | _ -> 
          raise (Parser_utils.make_unexpected_token_error 
            ("Expected basic argument expression, got: " ^ show_token token) 
            (snd (current_token st)))
    in
    let args, final_state = parse_function_arguments basic_expression_parser state in
    (FunCallExpr (VarExpr name, args), final_state)
  else
    (* 变量引用 *)
    (VarExpr name, state)