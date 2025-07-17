(** 骆言语法分析器基础工具模块 - Chinese Programming Language Parser Utilities *)

open Ast
open Lexer
open Lexer_tokens

exception SyntaxError of string * position
(** 语法错误 *)

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

(** 期望特定词元 *)
let expect_token state expected_token =
  let token, pos = current_token state in
  if token = expected_token then advance_parser state
  else raise (SyntaxError ("期望 " ^ show_token expected_token ^ "，但遇到 " ^ show_token token, pos))

(** 检查是否为特定词元 *)
let is_token state target_token =
  let token, _ = current_token state in
  token = target_token

(** 检查是否为符合条件的标点符号 *)
let is_punctuation state predicate =
  let token, _ = current_token state in
  predicate token

(** 期望符合条件的标点符号 *)
let expect_token_punctuation state predicate name =
  let token, pos = current_token state in
  if predicate token then advance_parser state
  else raise (SyntaxError ("期望 " ^ name ^ "，但遇到 " ^ show_token token, pos))

(** 标识符解析 *)

(** 解析标识符（严格引用模式）*)
let parse_identifier state =
  let token, pos = current_token state in
  match token with
  | QuotedIdentifierToken name -> (name, advance_parser state)
  | _ -> raise (SyntaxError ("期望引用标识符「名称」，但遇到 " ^ show_token token, pos))

(** 解析标识符（严格引用模式下的关键字处理）*)
let parse_identifier_allow_keywords state =
  (* 允许各种标识符形式，包括普通标识符和引用标识符 *)
  let token, pos = current_token state in
  match token with
  | QuotedIdentifierToken name -> (name, advance_parser state)
  | EmptyKeyword ->
      (* 特殊处理：在模式匹配中，"空" 可以作为构造器名 *)
      ("空", advance_parser state)
  | _ -> raise (SyntaxError ("期望引用标识符「名称」，但遇到 " ^ show_token token, pos))

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
        if parts = [] then raise (SyntaxError ("期望标识符，但遇到 " ^ show_token token, pos))
        else (String.concat "" (List.rev parts), state)
    | _ ->
        if parts = [] then raise (SyntaxError ("期望标识符，但遇到 " ^ show_token token, pos))
        else (String.concat "" (List.rev parts), state)
  in
  collect_parts [] state

(** 中文标点符号辅助函数 *)

let is_right_paren token = token = RightParen || token = ChineseRightParen
let is_left_bracket token = token = LeftBracket || token = ChineseLeftBracket
let is_right_bracket token = token = RightBracket || token = ChineseRightBracket
let is_left_brace token = token = LeftBrace
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
  match token with IntToken _ | ChineseNumberToken _ | FloatToken _ | StringToken _ | BoolToken _ -> true | _ -> false

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
  else raise (SyntaxError ("期望 " ^ description ^ "，但遇到 " ^ show_token token, pos))

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
  | _ -> raise (SyntaxError ("期望字面量，但遇到 " ^ show_token token, pos))

(** 运算符解析 *)

(** 解析二元运算符 *)
let token_to_binary_op token =
  match token with
  | Plus -> Some Add
  | Minus -> Some Sub
  | Star -> Some Mul
  | Multiply -> Some Mul
  | Slash -> Some Div
  | Divide -> Some Div
  | Modulo -> Some Mod
  | Concat -> Some Concat
  | Equal -> Some Eq
  | NotEqual -> Some Neq
  | Less -> Some Lt
  | LessEqual -> Some Le
  | Greater -> Some Gt
  | GreaterEqual -> Some Ge
  | AndKeyword -> Some And
  | OrKeyword -> Some Or
  (* 中文运算符关键字支持 *)
  | PlusKeyword -> Some Add
  | AddToKeyword -> Some Add
  | SubtractKeyword -> Some Sub
  | MultiplyKeyword -> Some Mul
  | DivideKeyword -> Some Div
  | GreaterThanWenyan -> Some Gt
  | LessThanWenyan -> Some Lt
  | EqualToKeyword -> Some Eq
  | LessThanEqualToKeyword -> Some Le
  (* 古雅风格运算符 *)
  | AncientAddToKeyword -> Some Add
  | _ -> None
