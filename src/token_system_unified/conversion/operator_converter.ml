(** 骆言编译器 - 操作符和分隔符转换器
    
    处理所有操作符和分隔符Token的转换，支持中英文表示。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Yyocamlc_lib.Token_types
open Error_types
open Token_converter

(** 操作符映射表 *)
let operator_mappings =
  [
    (* 算术操作符 *)
    ("+", Operator Plus);
    ("加", Operator Plus);
    ("-", Operator Minus);
    ("减", Operator Minus);
    ("*", Operator Multiply);
    ("乘", Operator Multiply);
    ("×", Operator Multiply);
    ("/", Operator Divide);
    ("除", Operator Divide);
    ("÷", Operator Divide);
    (* 比较操作符 *)
    ("=", Operator Equal);
    ("等于", Operator Equal);
    ("<>", Operator NotEqual);
    ("不等于", Operator NotEqual);
    ("≠", Operator NotEqual);
    ("<", Operator LessThan);
    ("小于", Operator LessThan);
    ("<=", Operator LessThanOrEqual);
    ("小于等于", Operator LessThanOrEqual);
    ("≤", Operator LessThanOrEqual);
    (">", Operator GreaterThan);
    ("大于", Operator GreaterThan);
    (">=", Operator GreaterThanOrEqual);
    ("大于等于", Operator GreaterThanOrEqual);
    ("≥", Operator GreaterThanOrEqual);
    (* 逻辑操作符 *)
    ("&&", Operator LogicalAnd);
    ("并且", Operator LogicalAnd);
    ("||", Operator LogicalOr);
    ("或者", Operator LogicalOr);
    (* 赋值和箭头 *)
    (":=", Operator Assignment);
    ("赋值", Operator Assignment);
    ("->", Operator Arrow);
    ("箭头", Operator Arrow);
    ("→", Operator Arrow);
    ("=>", Operator DoubleArrow);
    ("双箭头", Operator DoubleArrow);
    ("⇒", Operator DoubleArrow);
  ]

(** 分隔符映射表 *)
let delimiter_mappings =
  [
    (* 括号 *)
    ("(", Delimiter LeftParen);
    ("左括号", Delimiter LeftParen);
    (")", Delimiter RightParen);
    ("右括号", Delimiter RightParen);
    ("[", Delimiter LeftBracket);
    ("左方括号", Delimiter LeftBracket);
    ("]", Delimiter RightBracket);
    ("右方括号", Delimiter RightBracket);
    ("{", Delimiter LeftBrace);
    ("左大括号", Delimiter LeftBrace);
    ("}", Delimiter RightBrace);
    ("右大括号", Delimiter RightBrace);
    (* 标点符号 *)
    (";", Delimiter Semicolon);
    ("分号", Delimiter Semicolon);
    (",", Delimiter Comma);
    ("逗号", Delimiter Comma);
    (".", Delimiter Dot);
    ("点", Delimiter Dot);
    (":", Delimiter Colon);
    ("冒号", Delimiter Colon);
    ("::", Delimiter DoubleColon);
    ("双冒号", Delimiter DoubleColon);
    ("|", Delimiter Pipe);
    ("管道", Delimiter Pipe);
    ("_", Delimiter Underscore);
    ("下划线", Delimiter Underscore);
  ]

(** 创建查找表 *)
let create_lookup_tables mappings =
  let text_to_token = Hashtbl.create 64 in
  let token_to_text = Hashtbl.create 64 in

  List.iter
    (fun (text, token) ->
      Hashtbl.add text_to_token text token;
      (* 只存储第一个（通常是符号形式）作为默认输出 *)
      if not (Hashtbl.mem token_to_text token) then Hashtbl.add token_to_text token text)
    mappings;

  (text_to_token, token_to_text)

(** 操作符查找表 *)
let op_text_to_token, op_token_to_text = create_lookup_tables operator_mappings

(** 分隔符查找表 *)
let delim_text_to_token, delim_token_to_text = create_lookup_tables delimiter_mappings

(** 操作符转换器实现 *)
let operator_converter =
  let module OperatorConverter = struct
    let name = "operator_converter"
    let converter_type = OperatorConverter

    let string_to_token config text =
      let search_text = if config.case_sensitive then text else String.lowercase_ascii text in
      try
        let token = Hashtbl.find op_text_to_token search_text in
        ok_result token
      with Not_found -> error_result (UnknownToken (text, None))

    let token_to_string config token =
      try
        let text = Hashtbl.find op_token_to_text token in
        (* 如果启用中文别名，尝试查找中文表示 *)
        if config.enable_aliases then
          (* 查找中文版本 - 使用简化的检查 *)
          let chinese_version =
            List.find_opt (fun (t, tok) -> tok = token && String.length t > 1) operator_mappings
          in
          match chinese_version with
          | Some (chinese_text, _) -> ok_result chinese_text
          | None -> ok_result text
        else ok_result text
      with Not_found -> error_result (ConversionError ("operator_token", "string"))

    let can_handle_string text =
      Hashtbl.mem op_text_to_token text
      || Hashtbl.mem op_text_to_token (String.lowercase_ascii text)

    let can_handle_token token = Hashtbl.mem op_token_to_text token

    let supported_tokens () =
      let tokens = ref [] in
      Hashtbl.iter (fun token _ -> tokens := token :: !tokens) op_token_to_text;
      !tokens
  end in
  (module OperatorConverter : CONVERTER)

(** 分隔符转换器实现 *)
let delimiter_converter =
  let module DelimiterConverter = struct
    let name = "delimiter_converter"
    let converter_type = DelimiterConverter

    let string_to_token config text =
      let search_text = if config.case_sensitive then text else String.lowercase_ascii text in
      try
        let token = Hashtbl.find delim_text_to_token search_text in
        ok_result token
      with Not_found -> error_result (UnknownToken (text, None))

    let token_to_string config token =
      try
        let text = Hashtbl.find delim_token_to_text token in
        (* 如果启用中文别名，尝试查找中文表示 *)
        if config.enable_aliases then
          let chinese_version =
            List.find_opt (fun (t, tok) -> tok = token && String.length t > 1) delimiter_mappings
          in
          match chinese_version with
          | Some (chinese_text, _) -> ok_result chinese_text
          | None -> ok_result text
        else ok_result text
      with Not_found -> error_result (ConversionError ("delimiter_token", "string"))

    let can_handle_string text =
      Hashtbl.mem delim_text_to_token text
      || Hashtbl.mem delim_text_to_token (String.lowercase_ascii text)

    let can_handle_token token = Hashtbl.mem delim_token_to_text token

    let supported_tokens () =
      let tokens = ref [] in
      Hashtbl.iter (fun token _ -> tokens := token :: !tokens) delim_token_to_text;
      !tokens
  end in
  (module DelimiterConverter : CONVERTER)

(** 获取操作符优先级（用于解析器） *)
let get_operator_precedence_info token =
  let precedence = get_operator_precedence token in
  let associativity = get_operator_associativity token in
  (precedence, associativity)

(** 检查是否为二元操作符 *)
let is_binary_operator = function
  | Operator
      ( Plus | Minus | Multiply | Divide | Equal | NotEqual | LessThan | LessThanOrEqual
      | GreaterThan | GreaterThanOrEqual | LogicalAnd | LogicalOr ) ->
      true
  | _ -> false

(** 检查是否为一元操作符 *)
let is_unary_operator = function Operator Minus -> true (* 负号可以是一元操作符 *) | _ -> false

(** 检查是否为比较操作符 *)
let is_comparison_operator = function
  | Operator (Equal | NotEqual | LessThan | LessThanOrEqual | GreaterThan | GreaterThanOrEqual) ->
      true
  | _ -> false

(** 检查是否为算术操作符 *)
let is_arithmetic_operator = function
  | Operator (Plus | Minus | Multiply | Divide) -> true
  | _ -> false

(** 检查是否为逻辑操作符 *)
let is_logical_operator = function Operator (LogicalAnd | LogicalOr) -> true | _ -> false

(** 检查括号是否匹配 *)
let check_bracket_matching tokens =
  let rec check stack = function
    | [] ->
        if stack = [] then ok_result ()
        else error_result (ParsingError ("不匹配的括号", { line = 0; column = 0; offset = 0 }))
    | token :: rest -> (
        match token with
        | Delimiter LeftParen -> check ('(' :: stack) rest
        | Delimiter LeftBracket -> check ('[' :: stack) rest
        | Delimiter LeftBrace -> check ('{' :: stack) rest
        | Delimiter RightParen -> (
            match stack with
            | '(' :: remaining_stack -> check remaining_stack rest
            | _ -> error_result (ParsingError ("括号不匹配", { line = 0; column = 0; offset = 0 })))
        | Delimiter RightBracket -> (
            match stack with
            | '[' :: remaining_stack -> check remaining_stack rest
            | _ -> error_result (ParsingError ("方括号不匹配", { line = 0; column = 0; offset = 0 })))
        | Delimiter RightBrace -> (
            match stack with
            | '{' :: remaining_stack -> check remaining_stack rest
            | _ -> error_result (ParsingError ("大括号不匹配", { line = 0; column = 0; offset = 0 })))
        | _ -> check stack rest)
  in
  check [] tokens

(** 获取操作符和分隔符统计信息 *)
let get_operator_delimiter_stats token_list =
  let count_ops =
    List.fold_left
      (fun acc token -> match token with Operator _ -> acc + 1 | _ -> acc)
      0 token_list
  in
  let count_delims =
    List.fold_left
      (fun acc token -> match token with Delimiter _ -> acc + 1 | _ -> acc)
      0 token_list
  in
  [ ("operators", count_ops); ("delimiters", count_delims); ("total", count_ops + count_delims) ]
