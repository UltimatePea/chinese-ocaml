(** 骆言语法分析器基础工具模块 - Chinese Programming Language Parser Utilities *)

open Ast
open Lexer

exception SyntaxError of string * position
(** 语法错误 *)

(** 统一的错误消息生成函数 - 避免重复的错误模式 *)
let make_unexpected_token_error token pos = SyntaxError ("意外的词元: " ^ token, pos)

let make_expected_but_found_error expected found pos =
  SyntaxError ("期望" ^ expected ^ "，但遇到 " ^ found, pos)

type parser_state = { token_array : positioned_token array; array_length : int; current_pos : int }

(** 基础解析器状态操作 *)

(** 创建解析状态 *)
let create_parser_state token_list =
  let arr = Array.of_list token_list in
  { token_array = arr; array_length = Array.length arr; current_pos = 0 }

(** 获取当前词元 *)
let current_token state =
  if state.current_pos >= state.array_length then (EOF, { line = 0; column = 0; filename = "" })
  else state.token_array.(state.current_pos)

(** 查看下一个词元（不消费） *)
let peek_token state =
  let next_pos = state.current_pos + 1 in
  if next_pos >= state.array_length then (EOF, { line = 0; column = 0; filename = "" })
  else state.token_array.(next_pos)

(** 向前移动 *)
let advance_parser state =
  if state.current_pos >= state.array_length then state
  else { state with current_pos = state.current_pos + 1 }

(** 跳过换行符函数 - 通用版本 *)
let rec skip_newlines state =
  let token, _ = current_token state in
  if token = EOF then state
  else if token = Semicolon || token = ChineseSemicolon || token = Newline then
    skip_newlines (advance_parser state)
  else state

(** 期望特定词元 *)
let expect_token state expected_token =
  let token, pos = current_token state in
  if token = expected_token then advance_parser state
  else raise (make_expected_but_found_error (show_token expected_token) (show_token token) pos)

(** 检查是否为特定词元 *)
let is_token state target_token =
  let token, _ = current_token state in
  token = target_token

(** 标识符解析 *)

(** 解析标识符（严格引用模式）*)
let parse_identifier state =
  let token, pos = current_token state in
  match token with
  | QuotedIdentifierToken name -> (name, advance_parser state)
  | _ -> raise (make_expected_but_found_error "引用标识符「名称」" (show_token token) pos)

(** 解析标识符（严格引用模式下的关键字处理）*)
let parse_identifier_allow_keywords state =
  (* 允许各种标识符形式，包括普通标识符和引用标识符 *)
  let token, pos = current_token state in
  match token with
  | QuotedIdentifierToken name -> (name, advance_parser state)
  | EmptyKeyword ->
      (* 特殊处理：在模式匹配中，"空" 可以作为构造器名 *)
      ("空", advance_parser state)
  | _ -> raise (make_expected_but_found_error "引用标识符「名称」" (show_token token) pos)

(** 解析wenyan风格的复合标识符（可能包含多个部分） *)
let parse_wenyan_compound_identifier state =
  let rec collect_parts parts state =
    let token, pos = current_token state in
    match token with
    | QuotedIdentifierToken name -> collect_parts (name :: parts) (advance_parser state)
    | IdentifierTokenSpecial name ->
        (* 支持特殊标识符如"数值" *)
        collect_parts (name :: parts) (advance_parser state)
    | NumberKeyword -> collect_parts ("数" :: parts) (advance_parser state)
    | EmptyKeyword -> collect_parts ("空" :: parts) (advance_parser state)
    | ValueKeyword ->
        (* ValueKeyword 不应该被包含在标识符中，它是语法分隔符 *)
        if parts = [] then raise (make_expected_but_found_error "标识符" (show_token token) pos)
        else (String.concat "" (List.rev parts), state)
    | _ ->
        if parts = [] then raise (make_expected_but_found_error "标识符" (show_token token) pos)
        else (String.concat "" (List.rev parts), state)
  in
  collect_parts [] state

(** 中文标点符号辅助函数 *)

let is_left_paren token = token = LeftParen || token = ChineseLeftParen
let is_right_paren token = token = RightParen || token = ChineseRightParen
let is_left_bracket token = token = LeftBracket || token = ChineseLeftBracket
let is_right_bracket token = token = RightBracket || token = ChineseRightBracket
let is_left_brace token = token = LeftBrace
let is_right_brace token = token = RightBrace
let is_comma token = token = Comma
let is_semicolon token = token = Semicolon || token = ChineseSemicolon || token = AfterThatKeyword
let is_colon token = token = Colon || token = ChineseColon
let is_double_colon token = token = ChineseDoubleColon
let is_pipe token = token = Pipe || token = ChinesePipe
let is_arrow token = token = Arrow || token = ChineseArrow
let is_left_array token = token = LeftArray || token = ChineseLeftArray

(** Token分类辅助函数 *)

(* 辅助函数：检查是否是标识符类型的token *)
let is_identifier_like token =
  match token with
  | QuotedIdentifierToken _ | EmptyKeyword | FunKeyword | TypeKeyword | LetKeyword | IfKeyword
  | ThenKeyword | ElseKeyword | MatchKeyword | WithKeyword | TrueKeyword | FalseKeyword | AndKeyword
  | OrKeyword | NotKeyword | ModuleKeyword | NumberKeyword | ValueKeyword ->
      true
  | _ -> false

(* 辅助函数：检查是否是字面量token *)
let is_literal_token token =
  match token with
  | IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ | BoolToken _ | OneKeyword ->
      true
  | _ -> false

(* 辅助函数：检查是否是类型注解的双冒号 *)
let is_type_colon token = match token with ChineseDoubleColon -> true | _ -> false

(** 检查当前token是否为指定的标点符号（ASCII或中文） *)
let is_punctuation state check_fn =
  let token, _ = current_token state in
  check_fn token

(** 期望指定的标点符号（ASCII或中文版本） *)
let expect_token_punctuation state check_fn description =
  let token, pos = current_token state in
  if check_fn token then advance_parser state
  else raise (make_expected_but_found_error description (show_token token) pos)

(** 数字和字面量解析 *)

(** 中文数字转换为整数 *)
let chinese_digit_to_int = function
  | "零" -> 0
  | "一" -> 1
  | "二" -> 2
  | "三" -> 3
  | "四" -> 4
  | "五" -> 5
  | "六" -> 6
  | "七" -> 7
  | "八" -> 8
  | "九" -> 9
  | "十" -> 10
  | _ -> raise (Types.SemanticError ("无效的中文数字", "chinese_digit_to_int"))

(** 将中文数字字符串转换为整数 *)
let chinese_number_to_int chinese_str =
  (* 直接使用整个字符串，因为我们期望单个中文数字字符 *)
  if chinese_str = "点" then raise (Types.SemanticError ("暂不支持小数点", "chinese_number_to_int"))
  else chinese_digit_to_int chinese_str

(** 解析字面量 *)
let parse_literal state =
  let token, pos = current_token state in
  match token with
  | IntToken n -> (IntLit n, advance_parser state)
  | ChineseNumberToken chinese_num ->
      let n = chinese_number_to_int chinese_num in
      (IntLit n, advance_parser state)
  | FloatToken f -> (FloatLit f, advance_parser state)
  | StringToken s -> (StringLit s, advance_parser state)
  | BoolToken b -> (BoolLit b, advance_parser state)
  | _ -> raise (make_expected_but_found_error "字面量" (show_token token) pos)

(** 运算符解析 *)

(** 运算符映射表 - 数据与逻辑分离架构 *)
let binary_operator_mappings =
  [
    (* ASCII运算符 *)
    (Plus, Add);
    (Minus, Sub);
    (Star, Mul);
    (Multiply, Mul);
    (Slash, Div);
    (Divide, Div);
    (Modulo, Mod);
    (Concat, Concat);
    (Equal, Eq);
    (NotEqual, Neq);
    (Less, Lt);
    (LessEqual, Le);
    (Greater, Gt);
    (GreaterEqual, Ge);
    (AndKeyword, And);
    (OrKeyword, Or);
    (* 中文运算符关键字 *)
    (PlusKeyword, Add);
    (AddToKeyword, Add);
    (SubtractKeyword, Sub);
    (MultiplyKeyword, Mul);
    (DivideKeyword, Div);
    (GreaterThanWenyan, Gt);
    (LessThanWenyan, Lt);
    (EqualToKeyword, Eq);
    (LessThanEqualToKeyword, Le);
    (* 古雅风格运算符 *)
    (AncientAddToKeyword, Add);
  ]

(** 运算符快速查找哈希表 *)
let binary_operator_table =
  let table = Hashtbl.create (List.length binary_operator_mappings) in
  List.iter (fun (token, op) -> Hashtbl.add table token op) binary_operator_mappings;
  table

(** 解析二元运算符 - 优化后的查表实现 *)
let token_to_binary_op token =
  try Some (Hashtbl.find binary_operator_table token) with Not_found -> None

(** 诗词解析公共工具函数 - 消除重复代码 *)

(** 解析标识符内容（支持引用标识符、特殊标识符和字符串） *)
let parse_identifier_content state =
  let token, pos = current_token state in
  match token with
  | QuotedIdentifierToken name -> (name, advance_parser state)
  | IdentifierTokenSpecial name -> (name, advance_parser state)
  | StringToken content -> (content, advance_parser state)
  | _ -> raise (SyntaxError ("期望标识符内容", pos))

(** 解析特定关键字（支持引用标识符和特殊标识符） *)
let parse_specific_keyword state keyword =
  let token, pos = current_token state in
  match token with
  | QuotedIdentifierToken kw when kw = keyword -> advance_parser state
  | IdentifierTokenSpecial kw when kw = keyword -> advance_parser state
  | _ -> raise (SyntaxError ("期望 '" ^ keyword ^ "' 关键字", pos))

(** 类型解析公共工具函数 - 消除重复代码 *)

(** 基本类型映射表 *)
let basic_type_mappings =
  [
    (IntTypeKeyword, BaseTypeExpr IntType);
    (FloatTypeKeyword, BaseTypeExpr FloatType);
    (StringTypeKeyword, BaseTypeExpr StringType);
    (BoolTypeKeyword, BaseTypeExpr BoolType);
    (UnitTypeKeyword, BaseTypeExpr UnitType);
    (ListTypeKeyword, TypeVar "列表");
    (ArrayTypeKeyword, TypeVar "数组");
  ]

(** 尝试解析基本类型 *)
let try_parse_basic_type token state =
  let rec find_mapping mappings =
    match mappings with
    | [] -> None
    | (t, type_expr) :: rest ->
        if t = token then Some (type_expr, advance_parser state) else find_mapping rest
  in
  find_mapping basic_type_mappings
