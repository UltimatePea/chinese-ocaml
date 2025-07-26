(** 骆言编译器 - 操作符和分隔符转换器
    
    处理所有操作符和分隔符Token的转换，支持中英文表示。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Yyocamlc_lib.Token_types
open Yyocamlc_lib.Error_types
open Token_converter

(** 操作符映射表 *)
let operator_mappings =
  [
    (* 算术操作符 *)
    ("+", OperatorToken Operators.Plus);
    ("加", OperatorToken Operators.Plus);
    ("-", OperatorToken Operators.Minus);
    ("减", OperatorToken Operators.Minus);
    ("*", OperatorToken Operators.Multiply);
    ("乘", OperatorToken Operators.Multiply);
    ("×", OperatorToken Operators.Multiply);
    ("/", OperatorToken Operators.Divide);
    ("除", OperatorToken Operators.Divide);
    ("÷", OperatorToken Operators.Divide);
    (* 比较操作符 *)
    ("=", OperatorToken Operators.Equal);
    ("等于", OperatorToken Operators.Equal);
    ("<>", OperatorToken Operators.NotEqual);
    ("不等于", OperatorToken Operators.NotEqual);
    ("≠", OperatorToken Operators.NotEqual);
    ("<", OperatorToken Operators.LessThan);
    ("小于", OperatorToken Operators.LessThan);
    ("<=", OperatorToken Operators.LessEqual);
    ("小于等于", OperatorToken Operators.LessEqual);
    ("≤", OperatorToken Operators.LessEqual);
    (">", OperatorToken Operators.GreaterThan);
    ("大于", OperatorToken Operators.GreaterThan);
    (">=", OperatorToken Operators.GreaterEqual);
    ("大于等于", OperatorToken Operators.GreaterEqual);
    ("≥", OperatorToken Operators.GreaterEqual);
    (* 逻辑操作符 *)
    ("&&", OperatorToken Operators.LogicalAnd);
    ("并且", OperatorToken Operators.LogicalAnd);
    ("||", OperatorToken Operators.LogicalOr);
    ("或者", OperatorToken Operators.LogicalOr);
    (* 赋值和箭头 *)
    (":=", OperatorToken Operators.Assign);
    ("赋值", OperatorToken Operators.Assign);
    ("->", OperatorToken Operators.Arrow);
    ("箭头", OperatorToken Operators.Arrow);
    ("→", OperatorToken Operators.Arrow);
    ("=>", OperatorToken Operators.DoubleArrow);
    ("双箭头", OperatorToken Operators.DoubleArrow);
    ("⇒", OperatorToken Operators.DoubleArrow);
  ]

(** 分隔符映射表 *)
let delimiter_mappings =
  [
    (* 括号 *)
    ("(", DelimiterToken (Delimiters.LeftParen));
    ("左括号", DelimiterToken (Delimiters.LeftParen));
    (")", DelimiterToken (Delimiters.RightParen));
    ("右括号", DelimiterToken (Delimiters.RightParen));
    ("[", DelimiterToken (Delimiters.LeftBracket));
    ("左方括号", DelimiterToken (Delimiters.LeftBracket));
    ("]", DelimiterToken (Delimiters.RightBracket));
    ("右方括号", DelimiterToken (Delimiters.RightBracket));
    ("{", DelimiterToken (Delimiters.LeftBrace));
    ("左大括号", DelimiterToken (Delimiters.LeftBrace));
    ("}", DelimiterToken (Delimiters.RightBrace));
    ("右大括号", DelimiterToken (Delimiters.RightBrace));
    (* 标点符号 *)
    (";", DelimiterToken (Delimiters.Semicolon));
    ("分号", DelimiterToken (Delimiters.Semicolon));
    (",", DelimiterToken (Delimiters.Comma));
    ("逗号", DelimiterToken (Delimiters.Comma));
    (* Dot is not defined in delimiters, treating as operator *)
    (":", DelimiterToken (Delimiters.Colon));
    ("冒号", DelimiterToken (Delimiters.Colon));
    ("::", DelimiterToken (Delimiters.ChineseDoubleColon));
    ("双冒号", DelimiterToken (Delimiters.ChineseDoubleColon));
    ("|", DelimiterToken (Delimiters.Pipe));
    ("管道", DelimiterToken (Delimiters.Pipe));
    ("_", DelimiterToken (Delimiters.Underscore));
    ("下划线", DelimiterToken (Delimiters.Underscore));
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
        Result.Ok token
      with Not_found -> Result.Error (Yyocamlc_lib.Error_types.CompilerError ("Unknown token: " ^ text))

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
          | Some (chinese_text, _) -> Result.Ok chinese_text
          | None -> Result.Ok text
        else Result.Ok text
      with Not_found -> Result.Error (ConversionError ("operator_token", "string"))

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
        Result.Ok token
      with Not_found -> Result.Error (Yyocamlc_lib.Error_types.CompilerError ("Unknown token: " ^ text))

    let token_to_string config token =
      try
        let text = Hashtbl.find delim_token_to_text token in
        (* 如果启用中文别名，尝试查找中文表示 *)
        if config.enable_aliases then
          let chinese_version =
            List.find_opt (fun (t, tok) -> tok = token && String.length t > 1) delimiter_mappings
          in
          match chinese_version with
          | Some (chinese_text, _) -> Result.Ok chinese_text
          | None -> Result.Ok text
        else Result.Ok text
      with Not_found -> Result.Error (ConversionError ("delimiter_token", "string"))

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
let is_unary_operator = function OperatorToken Operators.Minus -> true (* 负号可以是一元操作符 *) | _ -> false

(** 检查是否为比较操作符 *)
let is_comparison_operator = function
  | OperatorToken (Operators.Equal | Operators.NotEqual | Operators.LessThan | Operators.LessEqual | Operators.GreaterThan | Operators.GreaterEqual) ->
      true
  | _ -> false

(** 检查是否为算术操作符 *)
let is_arithmetic_operator = function
  | OperatorToken (Operators.Plus | Operators.Minus | Operators.Multiply | Operators.Divide) -> true
  | _ -> false

(** 检查是否为逻辑操作符 *)
let is_logical_operator = function OperatorToken (Operators.LogicalAnd | Operators.LogicalOr) -> true | _ -> false

(** 检查括号是否匹配 *)
let check_bracket_matching tokens =
  let rec check stack = function
    | [] ->
        if stack = [] then Result.Ok ()
        else Result.Error (Yyocamlc_lib.Error_types.CompilerError ("不匹配的括号", { line = 0; column = 0; offset = 0 }))
    | token :: rest -> (
        match token with
        | DelimiterToken (Delimiters.LeftParen) -> check ('(' :: stack) rest
        | DelimiterToken (Delimiters.LeftBracket) -> check ('[' :: stack) rest
        | DelimiterToken (Delimiters.LeftBrace) -> check ('{' :: stack) rest
        | DelimiterToken (Delimiters.RightParen) -> (
            match stack with
            | '(' :: remaining_stack -> check remaining_stack rest
            | _ -> Result.Error (Yyocamlc_lib.Error_types.CompilerError ("括号不匹配", { line = 0; column = 0; offset = 0 })))
        | DelimiterToken (Delimiters.RightBracket) -> (
            match stack with
            | '[' :: remaining_stack -> check remaining_stack rest
            | _ -> Result.Error (Yyocamlc_lib.Error_types.CompilerError ("方括号不匹配", { line = 0; column = 0; offset = 0 })))
        | DelimiterToken (Delimiters.RightBrace) -> (
            match stack with
            | '{' :: remaining_stack -> check remaining_stack rest
            | _ -> Result.Error (Yyocamlc_lib.Error_types.CompilerError ("大括号不匹配", { line = 0; column = 0; offset = 0 })))
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
