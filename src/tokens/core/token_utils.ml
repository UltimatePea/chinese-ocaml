(** 骆言Token系统整合重构 - Token公共工具函数
    提供Token处理的各种实用工具和辅助函数 *)

open Token_types

(** Token创建工具 *)
module TokenCreator = struct
  (** 创建位置信息 *)
  let make_position line column filename = { line; column; filename }

  (** 创建带位置的Token *)
  let make_positioned_token token position = (token, position)

  (** 创建扩展Token（包含元数据） *)
  let make_extended_token token position source_module =
    let metadata = {
      creation_time = Unix.time ();
      source_module;
      token_id = Random.int 10000;
      priority = token_precedence token;
    } in
    { token; position; metadata }

  (** 便利函数：创建字面量Token *)
  let make_int_token i = Literal (IntToken i)
  let make_float_token f = Literal (FloatToken f)
  let make_string_token s = Literal (StringToken s)
  let make_bool_token b = Literal (BoolToken b)
  let make_chinese_number_token s = Literal (ChineseNumberToken s)

  (** 便利函数：创建关键字Token *)
  let make_let_keyword () = Keyword (Basic LetKeyword)
  let make_if_keyword () = Keyword (Basic IfKeyword)
  let make_then_keyword () = Keyword (Basic ThenKeyword)
  let make_else_keyword () = Keyword (Basic ElseKeyword)

  (** 便利函数：创建操作符Token *)
  let make_plus_op () = Operator (Arithmetic Plus)
  let make_minus_op () = Operator (Arithmetic Minus)
  let make_multiply_op () = Operator (Arithmetic Multiply)
  let make_divide_op () = Operator (Arithmetic Divide)
  let make_assign_op () = Operator (Assignment Assign)
  let make_equal_op () = Operator (Comparison Equal)

  (** 便利函数：创建分隔符Token *)
  let make_left_paren () = Delimiter (Parenthesis LeftParen)
  let make_right_paren () = Delimiter (Parenthesis RightParen)
  let make_left_bracket () = Delimiter (Parenthesis LeftBracket)
  let make_right_bracket () = Delimiter (Parenthesis RightBracket)
  let make_comma () = Delimiter (Punctuation Comma)
  let make_semicolon () = Delimiter (Punctuation Semicolon)

  (** 便利函数：创建标识符Token *)
  let make_quoted_identifier s = Identifier (QuotedIdentifierToken s)
  let make_special_identifier s = Identifier (IdentifierTokenSpecial s)
end

(** Token分类工具 *)
module TokenClassifier = struct
  (** 检查Token是否为特定类型 *)
  let is_keyword = function | Keyword _ -> true | _ -> false
  let is_literal = function | Literal _ -> true | _ -> false
  let is_operator = function | Operator _ -> true | _ -> false
  let is_delimiter = function | Delimiter _ -> true | _ -> false
  let is_identifier = function | Identifier _ -> true | _ -> false
  let is_wenyan = function | Wenyan _ -> true | _ -> false
  let is_natural_language = function | NaturalLanguage _ -> true | _ -> false
  let is_poetry = function | Poetry _ -> true | _ -> false

  (** 获取Token分类 *)
  let get_token_category = function
    | Keyword _ -> KeywordCategory
    | Literal _ -> LiteralCategory
    | Operator _ -> OperatorCategory
    | Delimiter _ -> DelimiterCategory
    | Identifier _ -> IdentifierCategory
    | Wenyan _ -> WenyanCategory
    | NaturalLanguage _ -> NaturalLanguageCategory
    | Poetry _ -> PoetryCategory

  (** 获取Token分类名称 *)
  let get_category_name = function
    | KeywordCategory -> "关键字"
    | LiteralCategory -> "字面量"
    | OperatorCategory -> "操作符"
    | DelimiterCategory -> "分隔符"
    | IdentifierCategory -> "标识符"
    | WenyanCategory -> "文言文"
    | NaturalLanguageCategory -> "自然语言"
    | PoetryCategory -> "诗词"

  (** 特定类型判断函数 *)
  let is_numeric_token = function
    | Literal (IntToken _) | Literal (FloatToken _) | Literal (ChineseNumberToken _) -> true
    | _ -> false

  let is_string_token = function
    | Literal (StringToken _) -> true
    | _ -> false

  let is_control_flow_token = function
    | Keyword (Control _) -> true
    | _ -> false

  let is_binary_op_token = function
    | Operator (Arithmetic _) | Operator (Comparison _) | Operator (Logical (And | Or)) -> true
    | _ -> false

  let is_unary_op_token = function
    | Operator (Logical Not) -> true
    | _ -> false

  let is_left_delimiter_token = function
    | Delimiter (Parenthesis (LeftParen | LeftBracket | LeftBrace)) -> true
    | _ -> false

  let is_right_delimiter_token = function
    | Delimiter (Parenthesis (RightParen | RightBracket | RightBrace)) -> true
    | _ -> false
end

(** Token转换工具 *)
module TokenConverter = struct
  (** Token转换为字符串 *)
  let token_to_string = function
    | Keyword (Basic LetKeyword) -> "让"
    | Keyword (Basic IfKeyword) -> "如果"
    | Keyword (Basic ThenKeyword) -> "那么"
    | Keyword (Basic ElseKeyword) -> "否则"
    | Keyword (Basic FunctionKeyword) -> "函数"
    | Keyword (Basic RecKeyword) -> "递归"
    | Keyword (Type IntKeyword) -> "整数"
    | Keyword (Type FloatKeyword) -> "小数"
    | Keyword (Type StringKeyword) -> "字符串"
    | Keyword (Type BoolKeyword) -> "布尔"
    | Keyword (Type ListKeyword) -> "列表"
    | Keyword (Type TypeKeyword) -> "类型"
    | Keyword (Control MatchKeyword) -> "匹配"
    | Keyword (Control WithKeyword) -> "与"
    | Keyword (Control WhenKeyword) -> "当"
    | Keyword (Control TryKeyword) -> "尝试"
    | Keyword (Control WhileKeyword) -> "循环"
    | Keyword (Control ForKeyword) -> "遍历"
    | Keyword (Module ModuleKeyword) -> "模块"
    | Keyword (Module OpenKeyword) -> "打开"
    | Keyword (Module IncludeKeyword) -> "包含"
    | Keyword (Module StructKeyword) -> "结构"
    | Keyword (Module SigKeyword) -> "签名"
    | Literal (IntToken i) -> string_of_int i
    | Literal (FloatToken f) -> string_of_float f
    | Literal (StringToken s) -> "\"" ^ s ^ "\""
    | Literal (BoolToken true) -> "真"
    | Literal (BoolToken false) -> "假"
    | Literal (ChineseNumberToken s) -> s
    | Operator (Arithmetic Plus) -> "+"
    | Operator (Arithmetic Minus) -> "-"
    | Operator (Arithmetic Multiply) -> "*"
    | Operator (Arithmetic Divide) -> "/"
    | Operator (Arithmetic Modulo) -> "%"
    | Operator (Arithmetic Power) -> "**"
    | Operator (Comparison Equal) -> "="
    | Operator (Comparison NotEqual) -> "!="
    | Operator (Comparison LessThan) -> "<"
    | Operator (Comparison LessEqual) -> "<="
    | Operator (Comparison GreaterThan) -> ">"
    | Operator (Comparison GreaterEqual) -> ">="
    | Operator (Logical And) -> "并且"
    | Operator (Logical Or) -> "或者"
    | Operator (Logical Not) -> "非"
    | Operator (Assignment Assign) -> ":="
    | Operator (Assignment PlusAssign) -> "+="
    | Operator (Assignment MinusAssign) -> "-="
    | Operator (Assignment MultiplyAssign) -> "*="
    | Operator (Assignment DivideAssign) -> "/="
    | Delimiter (Parenthesis LeftParen) -> "("
    | Delimiter (Parenthesis RightParen) -> ")"
    | Delimiter (Parenthesis LeftBracket) -> "["
    | Delimiter (Parenthesis RightBracket) -> "]"
    | Delimiter (Parenthesis LeftBrace) -> "{"
    | Delimiter (Parenthesis RightBrace) -> "}"
    | Delimiter (Punctuation Comma) -> ","
    | Delimiter (Punctuation Semicolon) -> ";"
    | Delimiter (Punctuation Colon) -> ":"
    | Delimiter (Punctuation Dot) -> "."
    | Delimiter (Special Newline) -> "\\n"
    | Delimiter (Special EOF) -> "<EOF>"
    | Identifier (QuotedIdentifierToken s) -> "'" ^ s ^ "'"
    | Identifier (IdentifierTokenSpecial s) -> s
    | Identifier (Variable s) -> s
    | Identifier (Function s) -> s ^ "()"
    | Identifier (Type s) -> s ^ "_t"
    | Identifier (Module s) -> s ^ "_mod"
    | Wenyan (WenyanKeyword s) -> "文言:" ^ s
    | Wenyan (WenyanOperator s) -> "操作:" ^ s
    | Wenyan (WenyanNumber s) -> "数字:" ^ s
    | Wenyan (WenyanText s) -> "文本:" ^ s
    | NaturalLanguage (ChineseText s) -> "中文:" ^ s
    | NaturalLanguage (EnglishText s) -> "英文:" ^ s
    | NaturalLanguage (MixedText s) -> "混合:" ^ s
    | NaturalLanguage (PunctuationText s) -> "标点:" ^ s
    | Poetry (ClassicalPoetry s) -> "古诗:" ^ s
    | Poetry (ModernPoetry s) -> "现代诗:" ^ s
    | Poetry (Couplet s) -> "对联:" ^ s
    | Poetry (Haiku s) -> "俳句:" ^ s
    | Poetry (Sonnet s) -> "十四行诗:" ^ s
    | _ -> "<未知Token>"

  (** 位置信息转换为字符串 *)
  let position_to_string pos =
    Printf.sprintf "%s:%d:%d" pos.filename pos.line pos.column

  (** 带位置Token转换为字符串 *)
  let positioned_token_to_string (token, position) =
    Printf.sprintf "%s@%s" (token_to_string token) (position_to_string position)
end

(** Token比较工具 *)
module TokenComparator = struct
  (** Token相等性比较（使用派生的equal函数） *)
  let equal_token = equal_token

  (** 位置相等性比较 *)
  let equal_position = equal_position

  (** 带位置Token相等性比较 *)
  let equal_positioned_token = equal_positioned_token

  (** Token优先级比较 *)
  let compare_precedence t1 t2 =
    compare (token_precedence t1) (token_precedence t2)

  (** 按类型比较Token *)
  let compare_by_category t1 t2 =
    let cat1 = TokenClassifier.get_token_category t1 in
    let cat2 = TokenClassifier.get_token_category t2 in
    compare cat1 cat2
end

(** Token验证工具 *)
module TokenValidator = struct
  (** 验证Token是否有效 *)
  let is_valid_token = function
    | Keyword _ | Literal _ | Operator _ | Delimiter _ 
    | Identifier _ | Wenyan _ | NaturalLanguage _ | Poetry _ -> true

  (** 验证位置信息是否有效 *)
  let is_valid_position pos =
    pos.line >= 1 && pos.column >= 1 && pos.filename <> ""

  (** 验证带位置Token是否有效 *)
  let is_valid_positioned_token (token, position) =
    is_valid_token token && is_valid_position position

  (** 验证Token列表是否有效 *)
  let validate_token_list tokens =
    List.for_all is_valid_token tokens
end