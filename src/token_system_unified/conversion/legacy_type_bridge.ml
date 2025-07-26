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

let convert_string_token (s : string) : literal_token =
  StringToken s

let convert_bool_token (b : bool) : literal_token =
  BoolToken b

let convert_chinese_number_token (s : string) : literal_token =
  ChineseNumberToken s

(** 标识符转换 *)
let convert_simple_identifier (s : string) : identifier_token =
  SimpleIdentifier s

let convert_quoted_identifier (s : string) : identifier_token =
  QuotedIdentifierToken s

let convert_special_identifier (s : string) : identifier_token =
  IdentifierTokenSpecial s

(** 核心关键字转换 *)
let convert_let_keyword () : core_language_token =
  LetKeyword

let convert_fun_keyword () : core_language_token =
  FunKeyword

let convert_if_keyword () : core_language_token =
  IfKeyword

let convert_then_keyword () : core_language_token =
  ThenKeyword

let convert_else_keyword () : core_language_token =
  ElseKeyword

(** 操作符转换 *)
let convert_plus_op () : operator_token =
  Plus

let convert_minus_op () : operator_token =
  Minus

let convert_multiply_op () : operator_token =
  Multiply

let convert_divide_op () : operator_token =
  Divide

let convert_equal_op () : operator_token =
  Equal

(** 分隔符转换 *)
let convert_left_paren () : delimiter_token =
  LeftParen

let convert_right_paren () : delimiter_token =
  RightParen

let convert_comma () : delimiter_token =
  Comma

let convert_semicolon () : delimiter_token =
  Semicolon

(** 特殊Token转换 *)
let convert_eof () : special_token =
  EOF

let convert_newline () : special_token =
  Newline

let convert_comment (s : string) : special_token =
  Comment s

let convert_whitespace (s : string) : special_token =
  Whitespace s

(** {1 统一Token构造函数} *)

(** 创建字面量Token *)
let make_literal_token (lit : literal_token) : token =
  Literal lit

(** 创建标识符Token *)
let make_identifier_token (id : identifier_token) : token =
  Identifier id

(** 创建核心语言关键字Token *)
let make_core_language_token (kw : core_language_token) : token =
  CoreLanguage kw

(** 创建操作符Token *)
let make_operator_token (op : operator_token) : token =
  Operator op

(** 创建分隔符Token *)
let make_delimiter_token (del : delimiter_token) : token =
  Delimiter del

(** 创建特殊Token *)
let make_special_token (sp : special_token) : token =
  Special sp

(** {1 位置信息处理} *)

(** 创建位置信息 *)
let make_position ~line ~column ~offset : position =
  { line; column; offset }

(** 创建带位置的Token *)
let make_positioned_token ~token ~position ~text : positioned_token =
  { token; position; text }

(** {1 Token类别检查工具} *)

(** 检查Token类别 *)
let get_token_category (token : token) : token_category =
  get_token_category token

(** 检查是否为字面量 *)
let is_literal_token (token : token) : bool =
  match token with
  | Literal _ -> true
  | _ -> false

(** 检查是否为标识符 *)
let is_identifier_token (token : token) : bool =
  match token with
  | Identifier _ -> true
  | _ -> false

(** 检查是否为关键字 *)
let is_keyword_token (token : token) : bool =
  match token with
  | CoreLanguage _ 
  | Semantic _
  | ErrorHandling _
  | ModuleSystem _
  | MacroSystem _
  | Wenyan _
  | Ancient _
  | NaturalLanguage _ -> true
  | _ -> false

(** 检查是否为操作符 *)
let is_operator_token (token : token) : bool =
  match token with
  | Operator _ -> true
  | _ -> false

(** 检查是否为分隔符 *)
let is_delimiter_token (token : token) : bool =
  match token with
  | Delimiter _ -> true
  | _ -> false

(** 检查是否为特殊Token *)
let is_special_token (token : token) : bool =
  match token with
  | Special _ -> true
  | _ -> false

(** {1 调试和诊断工具} *)

(** Token类型名称 *)
let token_type_name (token : token) : string =
  match token with
  | Literal _ -> "Literal"
  | Identifier _ -> "Identifier"
  | CoreLanguage _ -> "CoreLanguage"
  | Semantic _ -> "Semantic"
  | ErrorHandling _ -> "ErrorHandling"
  | ModuleSystem _ -> "ModuleSystem"
  | MacroSystem _ -> "MacroSystem"
  | Wenyan _ -> "Wenyan"
  | Ancient _ -> "Ancient"
  | NaturalLanguage _ -> "NaturalLanguage"
  | Operator _ -> "Operator"
  | Delimiter _ -> "Delimiter"
  | Special _ -> "Special"

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