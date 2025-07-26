(** 骆言编译器 - Legacy Token类型兼容性桥接层
    
    为遗留Token系统提供向新统一Token系统的无缝迁移桥接。
    此模块确保现有代码可以继续使用旧的Token类型接口，
    同时在后台自动映射到新的统一Token系统。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-26
    @issue #1355 Phase 2 Token系统整合 *)

(** {1 基础类型转换函数} *)

(** 基础字面量转换 *)
let convert_int_token (i : int) : Yyocamlc_lib.Token_types.literal_token =
  Yyocamlc_lib.Token_types.IntToken i

let convert_float_token (f : float) : Yyocamlc_lib.Token_types.literal_token =
  Yyocamlc_lib.Token_types.FloatToken f

let convert_string_token (s : string) : Yyocamlc_lib.Token_types.literal_token =
  Yyocamlc_lib.Token_types.StringToken s

let convert_bool_token (b : bool) : Yyocamlc_lib.Token_types.literal_token =
  Yyocamlc_lib.Token_types.BoolToken b

let convert_chinese_number_token (s : string) : Yyocamlc_lib.Token_types.literal_token =
  Yyocamlc_lib.Token_types.ChineseNumberToken s

(** 标识符转换 *)
let convert_simple_identifier (s : string) : Yyocamlc_lib.Token_types.identifier_token =
  Yyocamlc_lib.Token_types.SimpleIdentifier s

let convert_quoted_identifier (s : string) : Yyocamlc_lib.Token_types.identifier_token =
  Yyocamlc_lib.Token_types.QuotedIdentifierToken s

let convert_special_identifier (s : string) : Yyocamlc_lib.Token_types.identifier_token =
  Yyocamlc_lib.Token_types.IdentifierTokenSpecial s

(** 核心关键字转换 *)
let convert_let_keyword () : Yyocamlc_lib.Token_types.core_language_token =
  Yyocamlc_lib.Token_types.LetKeyword

let convert_fun_keyword () : Yyocamlc_lib.Token_types.core_language_token =
  Yyocamlc_lib.Token_types.FunKeyword

let convert_if_keyword () : Yyocamlc_lib.Token_types.core_language_token =
  Yyocamlc_lib.Token_types.IfKeyword

let convert_then_keyword () : Yyocamlc_lib.Token_types.core_language_token =
  Yyocamlc_lib.Token_types.ThenKeyword

let convert_else_keyword () : Yyocamlc_lib.Token_types.core_language_token =
  Yyocamlc_lib.Token_types.ElseKeyword

(** 操作符转换 *)
let convert_plus_op () : Yyocamlc_lib.Token_types.operator_token =
  Yyocamlc_lib.Token_types.Plus

let convert_minus_op () : Yyocamlc_lib.Token_types.operator_token =
  Yyocamlc_lib.Token_types.Minus

let convert_multiply_op () : Yyocamlc_lib.Token_types.operator_token =
  Yyocamlc_lib.Token_types.Multiply

let convert_divide_op () : Yyocamlc_lib.Token_types.operator_token =
  Yyocamlc_lib.Token_types.Divide

let convert_equal_op () : Yyocamlc_lib.Token_types.operator_token =
  Yyocamlc_lib.Token_types.Equal

(** 分隔符转换 *)
let convert_left_paren () : Yyocamlc_lib.Token_types.delimiter_token =
  Yyocamlc_lib.Token_types.LeftParen

let convert_right_paren () : Yyocamlc_lib.Token_types.delimiter_token =
  Yyocamlc_lib.Token_types.RightParen

let convert_comma () : Yyocamlc_lib.Token_types.delimiter_token =
  Yyocamlc_lib.Token_types.Comma

let convert_semicolon () : Yyocamlc_lib.Token_types.delimiter_token =
  Yyocamlc_lib.Token_types.Semicolon

(** 特殊Token转换 *)
let convert_eof () : Yyocamlc_lib.Token_types.special_token =
  Yyocamlc_lib.Token_types.EOF

let convert_newline () : Yyocamlc_lib.Token_types.special_token =
  Yyocamlc_lib.Token_types.Newline

let convert_comment (s : string) : Yyocamlc_lib.Token_types.special_token =
  Yyocamlc_lib.Token_types.Comment s

let convert_whitespace (s : string) : Yyocamlc_lib.Token_types.special_token =
  Yyocamlc_lib.Token_types.Whitespace s

(** {1 统一Token构造函数} *)

(** 创建字面量Token *)
let make_literal_token (lit : Yyocamlc_lib.Token_types.literal_token) : Yyocamlc_lib.Token_types.token =
  Yyocamlc_lib.Token_types.Literal lit

(** 创建标识符Token *)
let make_identifier_token (id : Yyocamlc_lib.Token_types.identifier_token) : Yyocamlc_lib.Token_types.token =
  Yyocamlc_lib.Token_types.Identifier id

(** 创建核心语言关键字Token *)
let make_core_language_token (kw : Yyocamlc_lib.Token_types.core_language_token) : Yyocamlc_lib.Token_types.token =
  Yyocamlc_lib.Token_types.CoreLanguage kw

(** 创建操作符Token *)
let make_operator_token (op : Yyocamlc_lib.Token_types.operator_token) : Yyocamlc_lib.Token_types.token =
  Yyocamlc_lib.Token_types.Operator op

(** 创建分隔符Token *)
let make_delimiter_token (del : Yyocamlc_lib.Token_types.delimiter_token) : Yyocamlc_lib.Token_types.token =
  Yyocamlc_lib.Token_types.Delimiter del

(** 创建特殊Token *)
let make_special_token (sp : Yyocamlc_lib.Token_types.special_token) : Yyocamlc_lib.Token_types.token =
  Yyocamlc_lib.Token_types.Special sp

(** {1 位置信息处理} *)

(** 创建位置信息 *)
let make_position ~line ~column ~offset : Yyocamlc_lib.Token_types.position =
  { line; column; offset }

(** 创建带位置的Token *)
let make_positioned_token ~token ~position ~text : Yyocamlc_lib.Token_types.positioned_token =
  { token; position; text }

(** {1 Token类别检查工具} *)

(** 检查Token类别 *)
let get_token_category (token : Yyocamlc_lib.Token_types.token) : Yyocamlc_lib.Token_types.token_category =
  Yyocamlc_lib.Token_types.get_token_category token

(** 检查是否为字面量 *)
let is_literal_token (token : Yyocamlc_lib.Token_types.token) : bool =
  match token with
  | Yyocamlc_lib.Token_types.Literal _ -> true
  | _ -> false

(** 检查是否为标识符 *)
let is_identifier_token (token : Yyocamlc_lib.Token_types.token) : bool =
  match token with
  | Yyocamlc_lib.Token_types.Identifier _ -> true
  | _ -> false

(** 检查是否为关键字 *)
let is_keyword_token (token : Yyocamlc_lib.Token_types.token) : bool =
  match token with
  | Yyocamlc_lib.Token_types.CoreLanguage _ 
  | Yyocamlc_lib.Token_types.Semantic _
  | Yyocamlc_lib.Token_types.ErrorHandling _
  | Yyocamlc_lib.Token_types.ModuleSystem _
  | Yyocamlc_lib.Token_types.MacroSystem _
  | Yyocamlc_lib.Token_types.Wenyan _
  | Yyocamlc_lib.Token_types.Ancient _
  | Yyocamlc_lib.Token_types.NaturalLanguage _ -> true
  | _ -> false

(** 检查是否为操作符 *)
let is_operator_token (token : Yyocamlc_lib.Token_types.token) : bool =
  match token with
  | Yyocamlc_lib.Token_types.Operator _ -> true
  | _ -> false

(** 检查是否为分隔符 *)
let is_delimiter_token (token : Yyocamlc_lib.Token_types.token) : bool =
  match token with
  | Yyocamlc_lib.Token_types.Delimiter _ -> true
  | _ -> false

(** 检查是否为特殊Token *)
let is_special_token (token : Yyocamlc_lib.Token_types.token) : bool =
  match token with
  | Yyocamlc_lib.Token_types.Special _ -> true
  | _ -> false

(** {1 调试和诊断工具} *)

(** Token类型名称 *)
let token_type_name (token : Yyocamlc_lib.Token_types.token) : string =
  match token with
  | Yyocamlc_lib.Token_types.Literal _ -> "Literal"
  | Yyocamlc_lib.Token_types.Identifier _ -> "Identifier"
  | Yyocamlc_lib.Token_types.CoreLanguage _ -> "CoreLanguage"
  | Yyocamlc_lib.Token_types.Semantic _ -> "Semantic"
  | Yyocamlc_lib.Token_types.ErrorHandling _ -> "ErrorHandling"
  | Yyocamlc_lib.Token_types.ModuleSystem _ -> "ModuleSystem"
  | Yyocamlc_lib.Token_types.MacroSystem _ -> "MacroSystem"
  | Yyocamlc_lib.Token_types.Wenyan _ -> "Wenyan"
  | Yyocamlc_lib.Token_types.Ancient _ -> "Ancient"
  | Yyocamlc_lib.Token_types.NaturalLanguage _ -> "NaturalLanguage"
  | Yyocamlc_lib.Token_types.Operator _ -> "Operator"
  | Yyocamlc_lib.Token_types.Delimiter _ -> "Delimiter"
  | Yyocamlc_lib.Token_types.Special _ -> "Special"

(** 统计Token流中各类型Token的数量 *)
let count_token_types (tokens : Yyocamlc_lib.Token_types.token list) : (string * int) list =
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
let make_literal_tokens (values : (string * [`Int of int | `Float of float | `String of string | `Bool of bool]) list) : Yyocamlc_lib.Token_types.token list =
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
let make_identifier_tokens (names : string list) : Yyocamlc_lib.Token_types.token list =
  List.map (fun name ->
    let id = convert_simple_identifier name in
    make_identifier_token id
  ) names

(** {1 实验性转换功能} *)

(** 尝试从字符串推断Token类型 *)
let infer_token_from_string (s : string) : Yyocamlc_lib.Token_types.token option =
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
let validate_token_stream (tokens : Yyocamlc_lib.Token_types.token list) : bool =
  try
    List.iter (fun token ->
      let _ = get_token_category token in
      ()
    ) tokens;
    true
  with
  | _ -> false