(** 骆言编译器 - Legacy Token类型兼容性桥接层
    
    为遗留Token系统提供向新统一Token系统的无缝迁移桥接。
    此模块确保现有代码可以继续使用旧的Token类型接口，
    同时在后台自动映射到新的统一Token系统。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-26
    @issue #1355 Phase 2 Token系统整合 *)

open Yyocamlc_lib.Token_types

(** {1 基础类型转换函数} *)

(** 基础字面量转换 *)
let convert_int_token (i : int) : Literals.literal_token =
  Literals.IntToken i

let convert_float_token (f : float) : Literals.literal_token =
  Literals.FloatToken f

let convert_string_token (s : string) : Literals.literal_token =
  Literals.StringToken s

let convert_bool_token (b : bool) : Literals.literal_token =
  Literals.BoolToken b

let convert_chinese_number_token (s : string) : Literals.literal_token =
  Literals.ChineseNumberToken s

(** 标识符转换 *)
let convert_simple_identifier (s : string) : Identifiers.identifier_token =
  Identifiers.QuotedIdentifierToken s

let convert_quoted_identifier (s : string) : Identifiers.identifier_token =
  Identifiers.QuotedIdentifierToken s

let convert_special_identifier (s : string) : Identifiers.identifier_token =
  Identifiers.IdentifierTokenSpecial s

(** 核心关键字转换 *)
let convert_let_keyword () : Keywords.keyword_token =
  Keywords.LetKeyword

let convert_fun_keyword () : Keywords.keyword_token =
  Keywords.FunKeyword

let convert_if_keyword () : Keywords.keyword_token =
  Keywords.IfKeyword

let convert_then_keyword () : Keywords.keyword_token =
  Keywords.ThenKeyword

let convert_else_keyword () : Keywords.keyword_token =
  Keywords.ElseKeyword

(** 操作符转换 *)
let convert_plus_op () : Operators.operator_token =
  Operators.Plus

let convert_minus_op () : Operators.operator_token =
  Operators.Minus

let convert_multiply_op () : Operators.operator_token =
  Operators.Multiply

let convert_divide_op () : Operators.operator_token =
  Operators.Divide

let convert_equal_op () : Operators.operator_token =
  Operators.Equal

(** 分隔符转换 *)
let convert_left_paren () : Delimiters.delimiter_token =
  Delimiters.LeftParen

let convert_right_paren () : Delimiters.delimiter_token =
  Delimiters.RightParen

let convert_comma () : Delimiters.delimiter_token =
  Delimiters.Comma

let convert_semicolon () : Delimiters.delimiter_token =
  Delimiters.Semicolon

(** 特殊Token转换 *)
let convert_eof () : Special.special_token =
  Special.EOF

let convert_newline () : Special.special_token =
  Special.Newline

let convert_comment (s : string) : Special.special_token =
  Special.Comment s

let convert_whitespace (s : string) : Special.special_token =
  Special.Whitespace s

(** {1 统一Token构造函数} *)

(** 创建字面量Token *)
let make_literal_token (lit : Literals.literal_token) : token =
  LiteralToken lit

(** 创建标识符Token *)
let make_identifier_token (id : Identifiers.identifier_token) : token =
  IdentifierToken id

(** 创建核心语言关键字Token *)
let make_core_language_token (kw : Keywords.keyword_token) : token =
  KeywordToken kw

(** 创建操作符Token *)
let make_operator_token (op : Operators.operator_token) : token =
  OperatorToken op

(** 创建分隔符Token *)
let make_delimiter_token (del : Delimiters.delimiter_token) : token =
  DelimiterToken del

(** 创建特殊Token *)
let make_special_token (sp : Special.special_token) : token =
  SpecialToken sp

(** {1 位置信息处理} *)

(** 创建位置信息 *)
let make_position ~line ~column ~filename : position =
  { line; column; filename }

(** 创建带位置的Token *)
let make_positioned_token ~token ~position ~text:_ : positioned_token =
  (token, position)

(** {1 Token类别检查工具} *)

(** 检查Token类别 *)
let get_token_category (token : token) : string =
  match token with
  | LiteralToken _ -> "literal"
  | IdentifierToken _ -> "identifier"
  | KeywordToken _ -> "keyword"
  | OperatorToken _ -> "operator"
  | DelimiterToken _ -> "delimiter"
  | SpecialToken _ -> "special"

(** 检查是否为字面量 *)
let is_literal_token (token : token) : bool =
  match token with
  | LiteralToken _ -> true
  | _ -> false

(** 检查是否为标识符 *)
let is_identifier_token (token : token) : bool =
  match token with
  | IdentifierToken _ -> true
  | _ -> false

(** 检查是否为关键字 *)
let is_keyword_token (token : token) : bool =
  match token with
  | KeywordToken _ -> true
  | _ -> false

(** 检查是否为操作符 *)
let is_operator_token (token : token) : bool =
  match token with
  | OperatorToken _ -> true
  | _ -> false

(** 检查是否为分隔符 *)
let is_delimiter_token (token : token) : bool =
  match token with
  | DelimiterToken _ -> true
  | _ -> false

(** 检查是否为特殊Token *)
let is_special_token (token : token) : bool =
  match token with
  | SpecialToken _ -> true
  | _ -> false

(** {1 调试和诊断工具} *)

(** Token类型名称 *)
let token_type_name (token : token) : string =
  match token with
  | LiteralToken _ -> "Literal"
  | IdentifierToken _ -> "Identifier"
  | KeywordToken _ -> "Keyword"
  | OperatorToken _ -> "Operator"
  | DelimiterToken _ -> "Delimiter"
  | SpecialToken _ -> "Special"

(** 统计Token流中各类型Token的数量 *)
let count_token_types (tokens : token list) : (string * int) list =
  let counts = Hashtbl.create 16 in
  List.iter (fun token ->
    let type_name = token_type_name token in
    let current_count = 
      try Hashtbl.find counts type_name
      with Not_found -> 0 
    in
    Hashtbl.replace counts type_name (current_count + 1)
  ) tokens;
  
  Hashtbl.fold (fun type_name count acc ->
    (type_name, count) :: acc
  ) counts []

(** {1 批量处理工具} *)

(** 批量创建字面量Token *)
let make_literal_tokens (values : (string * [`Int of int | `Float of float | `String of string | `Bool of bool]) list) : token list =
  List.map (fun (_, value) ->
    let lit = match value with
      | `Int i -> convert_int_token i
      | `Float f -> convert_float_token f  
      | `String s -> convert_string_token s
      | `Bool b -> convert_bool_token b
    in
    make_literal_token lit
  ) values

(** 批量创建标识符Token *)
let make_identifier_tokens (names : string list) : token list =
  List.map (fun name ->
    let id = convert_simple_identifier name in
    make_identifier_token id
  ) names

(** {1 实验性转换功能} *)

(** 尝试从字符串推断Token类型 *)
let infer_token_from_string (s : string) : token option =
  try
    (* 尝试解析为整数 *)
    let i = int_of_string s in
    Some (make_literal_token (convert_int_token i))
  with Failure _ ->
  try
    (* 尝试解析为浮点数 *)
    let f = float_of_string s in
    Some (make_literal_token (convert_float_token f))
  with Failure _ ->
    (* 检查是否为关键字 *)
    match s with
    | "let" | "让" -> Some (make_core_language_token (convert_let_keyword ()))
    | "fun" | "函数" -> Some (make_core_language_token (convert_fun_keyword ()))
    | "if" | "如果" -> Some (make_core_language_token (convert_if_keyword ()))
    | "then" | "那么" -> Some (make_core_language_token (convert_then_keyword ()))
    | "else" | "否则" -> Some (make_core_language_token (convert_else_keyword ()))
    | "+" -> Some (make_operator_token (convert_plus_op ()))
    | "-" -> Some (make_operator_token (convert_minus_op ()))
    | "*" -> Some (make_operator_token (convert_multiply_op ()))
    | "/" -> Some (make_operator_token (convert_divide_op ()))
    | "=" -> Some (make_operator_token (convert_equal_op ()))
    | "(" -> Some (make_delimiter_token (convert_left_paren ()))
    | ")" -> Some (make_delimiter_token (convert_right_paren ()))
    | "," -> Some (make_delimiter_token (convert_comma ()))
    | ";" -> Some (make_delimiter_token (convert_semicolon ()))
    | _ -> Some (make_identifier_token (convert_simple_identifier s))

(** 简单的Token流验证 *)
let validate_token_stream (tokens : token list) : bool =
  try
    List.iter (fun token ->
      let _ = get_token_category token in
      ()
    ) tokens;
    true
  with
  | _ -> false