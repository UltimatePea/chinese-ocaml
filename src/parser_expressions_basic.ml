(** 骆言语法分析器基础表达式解析模块
    
    本模块包含基础表达式解析功能，从主表达式解析器中提取：
    - 赋值表达式解析
    - 一元表达式解析
    - 字面量表达式解析
    - 复合表达式解析
    - 关键字表达式解析
    - 诗词表达式解析
    
    提取目的：减少主文件parser_expressions.ml的复杂度
    创建时间：技术债务清理 Fix #654 *)

open Ast
open Lexer
open Parser_utils

(** 解析赋值表达式 *)
let parse_assignment_expression parse_expression parse_or_else_expression state =
  let left_expr, state1 = parse_or_else_expression state in
  let token, _ = current_token state1 in
  if token = RefAssign then
    let state2 = advance_parser state1 in
    let right_expr, state3 = parse_expression state2 in
    (AssignExpr (left_expr, right_expr), state3)
  else (left_expr, state1)

(** 解析一元表达式 *)
let parse_unary_expression parse_unary_expression_rec parse_primary_expression state =
  let token, _pos = current_token state in
  match token with
  | Minus ->
      let state1 = advance_parser state in
      let expr, state2 = parse_unary_expression_rec state1 in
      (UnaryOpExpr (Neg, expr), state2)
  | NotKeyword ->
      let state1 = advance_parser state in
      let expr, state2 = parse_unary_expression_rec state1 in
      (UnaryOpExpr (Not, expr), state2)
  | Bang ->
      let state1 = advance_parser state in
      let expr, state2 = parse_unary_expression_rec state1 in
      (DerefExpr expr, state2)
  | _ -> parse_primary_expression state

(** 解析字面量表达式（整数、浮点数、字符串、布尔值） *)
let parse_literal_expressions parse_function_call_or_variable state =
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
          parse_function_call_or_variable name state1
      | _ ->
          (* 解析为布尔字面量 *)
          let literal, state1 = parse_literal state in
          (LitExpr literal, state1))
  | _ -> invalid_arg "parse_literal_expressions: 不是字面量类token"

(** 解析复合表达式（数组、记录、模块等） *)
let parse_compound_expressions parse_expression parse_function_call_or_variable parse_postfix_expression parse_array_expression parse_record_expression parse_combine_expression parse_module_expression state =
  let token, _pos = current_token state in
  match token with
  | QuotedIdentifierToken name ->
      let state1 = advance_parser state in
      (* Check if this looks like a string literal rather than a variable name *)
      if Parser_expressions_utils.looks_like_string_literal name then
        (LitExpr (StringLit name), state1)
      else parse_function_call_or_variable name state1
  | LeftParen | ChineseLeftParen ->
      let state1 = advance_parser state in
      let expr, state2 = parse_expression state1 in
      let state3 = expect_token_punctuation state2 is_right_paren "right parenthesis" in
      parse_postfix_expression expr state3
  | LeftArray | ChineseLeftArray -> parse_array_expression state
  | LeftBrace ->
      let record_expr, state1 = parse_record_expression state in
      parse_postfix_expression record_expr state1
  | ModuleKeyword -> parse_module_expression state
  | CombineKeyword -> parse_combine_expression state
  | LeftBracket | ChineseLeftBracket ->
      (* 禁用现代列表语法，提示使用古雅体语法 *)
      raise
        (SyntaxError
           ( "请使用古雅体列表语法替代 [...]。\n" ^ "空列表：空空如也\n" ^ "有元素的列表：列开始 元素1 其一 元素2 其二 元素3 其三 列结束\n"
             ^ "模式匹配：有首有尾 首名为「变量名」尾名为「尾部变量名」",
             snd (current_token state) ))
  | _ -> invalid_arg "parse_compound_expressions: 不是复合表达式类token"

(** 解析关键字表达式（标签、数值等特殊关键字） *)
let parse_keyword_expressions parse_expression parse_function_call_or_variable parse_primary_expression state =
  let token, _ = current_token state in
  match token with
  | TagKeyword ->
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
  | NumberKeyword ->
      (* 尝试解析wenyan复合标识符，如"数值" *)
      let name, state1 = parse_wenyan_compound_identifier state in
      parse_function_call_or_variable name state1
  | OneKeyword ->
      (* 将"一"关键字转换为数字字面量1 *)
      let state1 = advance_parser state in
      (LitExpr (IntLit 1), state1)
  | DefineKeyword ->
      (* 调用主解析器中的自然语言函数定义解析 *)
      let _token, pos = current_token state in
      raise (Types.ParseError ("DefineKeyword应由主解析器处理", pos.line, pos.column))
  | AncientDefineKeyword -> Parser_ancient.parse_ancient_function_definition parse_expression state
  | AncientObserveKeyword ->
      Parser_ancient.parse_ancient_match_expression parse_expression Parser_patterns.parse_pattern
        state
  | AncientListStartKeyword -> Parser_ancient.parse_ancient_list_expression parse_expression state
  | EmptyKeyword | TypeKeyword | ThenKeyword | ElseKeyword | WithKeyword | TrueKeyword
  | FalseKeyword | AndKeyword | OrKeyword | NotKeyword | ValueKeyword ->
      (* Handle keywords that might be part of compound identifiers *)
      let name, state1 = parse_identifier_allow_keywords state in
      parse_function_call_or_variable name state1
  | _ -> invalid_arg "parse_keyword_expressions: 不是关键字表达式类token"

(** 解析古典诗词表达式 *)
let parse_poetry_expressions state =
  let token, _ = current_token state in
  match token with
  | ParallelStructKeyword | FiveCharKeyword | SevenCharKeyword ->
      Parser_poetry.parse_poetry_expression state
  | _ -> invalid_arg "parse_poetry_expressions: 不是诗词表达式类token"