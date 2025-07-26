(** 骆言Token系统整合重构 - Token公共工具函数 提供Token处理的各种实用工具和辅助函数 *)

open Token_types

(** Token创建工具 *)
module TokenCreator = struct
  (** 创建位置信息 *)
  let make_position line column filename = { line; column; filename }

  (** 创建带位置的Token *)
  let make_positioned_token token position = (token, position)

  (** 创建扩展Token（包含元数据） *)
  let make_extended_token token position source_module =
    let metadata =
      {
        creation_time = Unix.time ();
        source_module;
        token_id = Random.int 10000;
        priority = 1; (* 默认优先级 *)
      }
    in
    { token; position; metadata }

  (** 便利函数：创建字面量Token *)
  let make_int_token i = LiteralToken (Literals.IntToken i)

  let make_float_token f = LiteralToken (Literals.FloatToken f)
  let make_string_token s = LiteralToken (Literals.StringToken s)
  let make_bool_token b = LiteralToken (Literals.BoolToken b)
  let make_chinese_number_token s = LiteralToken (Literals.ChineseNumberToken s)

  (** 便利函数：创建关键字Token *)
  let make_let_keyword () = KeywordToken Keywords.LetKeyword

  let make_if_keyword () = KeywordToken Keywords.IfKeyword
  let make_then_keyword () = KeywordToken Keywords.ThenKeyword
  let make_else_keyword () = KeywordToken Keywords.ElseKeyword

  (** 便利函数：创建操作符Token *)
  let make_plus_op () = OperatorToken Operators.Plus

  let make_minus_op () = OperatorToken Operators.Minus
  let make_multiply_op () = OperatorToken Operators.Multiply
  let make_divide_op () = OperatorToken Operators.Divide
  let make_assign_op () = OperatorToken Operators.Assign
  let make_equal_op () = OperatorToken Operators.Equal

  (** 便利函数：创建分隔符Token *)
  let make_left_paren () = DelimiterToken Delimiters.LeftParen

  let make_right_paren () = DelimiterToken Delimiters.RightParen
  let make_left_bracket () = DelimiterToken Delimiters.LeftBracket
  let make_right_bracket () = DelimiterToken Delimiters.RightBracket
  let make_comma () = DelimiterToken Delimiters.Comma
  let make_semicolon () = DelimiterToken Delimiters.Semicolon

  (** 便利函数：创建标识符Token *)
  let make_quoted_identifier s = IdentifierToken (Identifiers.QuotedIdentifierToken s)

  let make_special_identifier s = IdentifierToken (Identifiers.IdentifierTokenSpecial s)
end

(** Token分类工具 *)
module TokenClassifier = struct
  (** 检查Token是否为特定类型 *)
  let is_keyword = function KeywordToken _ -> true | _ -> false

  let is_literal = function LiteralToken _ -> true | _ -> false
  let is_operator = function OperatorToken _ -> true | _ -> false
  let is_delimiter = function DelimiterToken _ -> true | _ -> false
  let is_identifier = function IdentifierToken _ -> true | _ -> false
  let is_special = function SpecialToken _ -> true | _ -> false

  (** 获取Token分类 *)
  let get_token_category = function
    | KeywordToken _ -> KeywordCategory
    | LiteralToken _ -> LiteralCategory
    | OperatorToken _ -> OperatorCategory
    | DelimiterToken _ -> DelimiterCategory
    | IdentifierToken _ -> IdentifierCategory
    | SpecialToken _ -> SpecialCategory

  (** 获取Token分类名称 *)
  let get_category_name = function
    | KeywordCategory -> "关键字"
    | LiteralCategory -> "字面量"
    | OperatorCategory -> "操作符"
    | DelimiterCategory -> "分隔符"
    | IdentifierCategory -> "标识符"
    | SpecialCategory -> "特殊"
    | WenyanCategory -> "文言文"
    | NaturalLanguageCategory -> "自然语言"
    | PoetryCategory -> "诗词"

  (** 特定类型判断函数 *)
  let is_numeric_token = function
    | LiteralToken (Literals.IntToken _) | LiteralToken (Literals.FloatToken _) | LiteralToken (Literals.ChineseNumberToken _) -> true
    | _ -> false

  let is_string_token = function LiteralToken (Literals.StringToken _) -> true | _ -> false
  let is_control_flow_token = function KeywordToken (Keywords.IfKeyword | Keywords.ThenKeyword | Keywords.ElseKeyword | Keywords.MatchKeyword) -> true | _ -> false

  let is_binary_op_token = function
    | OperatorToken (Operators.Plus | Operators.Minus | Operators.Multiply | Operators.Divide | Operators.Equal | Operators.NotEqual) -> true
    | _ -> false

  let is_unary_op_token = function OperatorToken Operators.LogicalNot -> true | _ -> false

  let is_left_delimiter_token = function
    | DelimiterToken (Delimiters.LeftParen | Delimiters.LeftBracket | Delimiters.LeftBrace) -> true
    | _ -> false

  let is_right_delimiter_token = function
    | DelimiterToken (Delimiters.RightParen | Delimiters.RightBracket | Delimiters.RightBrace) -> true
    | _ -> false
end

(** Token转换工具 *)
module TokenConverter = struct
  (** Token转换为字符串 - 使用自动生成的show函数 *)
  let token_to_string = Token_types.show_token

  (** 位置信息转换为字符串 *)
  let position_to_string pos = Printf.sprintf "%s:%d:%d" pos.filename pos.line pos.column

  (** 带位置Token转换为字符串 *)
  let positioned_token_to_string (token, position) =
    Printf.sprintf "%s@%s" (token_to_string token) (position_to_string position)
end

(** Token比较工具 *)
module TokenComparator = struct
  (** Token相等性比较（使用派生的equal函数） *)
  let equal_token = Token_types.equal_token

  (** 位置相等性比较 *)
  let equal_position = Token_types.equal_position

  (** 带位置Token相等性比较 *)
  let equal_positioned_token = Token_types.equal_positioned_token

  (** Token优先级比较 *)
  let compare_precedence t1 t2 =
    let get_precedence = function
      | KeywordToken _ -> 10  (* 关键字最高优先级 *)
      | OperatorToken (Operators.Multiply | Operators.Divide | Operators.Modulo) -> 8  (* 乘除模运算 *)
      | OperatorToken (Operators.Plus | Operators.Minus) -> 7  (* 加减运算 *)
      | OperatorToken (Operators.Equal | Operators.NotEqual | Operators.LessThan | Operators.LessEqual | Operators.GreaterThan | Operators.GreaterEqual) -> 6  (* 比较运算 *)
      | OperatorToken (Operators.LogicalAnd) -> 5  (* 逻辑与 *)
      | OperatorToken (Operators.LogicalOr) -> 4  (* 逻辑或 *)
      | OperatorToken (Operators.Assign | Operators.RefAssign) -> 3  (* 赋值运算 *)
      | OperatorToken _ -> 5  (* 其他运算符中等优先级 *)
      | DelimiterToken _ -> 2  (* 分隔符较低优先级 *)
      | IdentifierToken _ -> 1  (* 标识符低优先级 *)
      | LiteralToken _ -> 1  (* 字面量低优先级 *)
      | SpecialToken _ -> 0  (* 特殊token最低优先级 *)
    in
    let p1 = get_precedence t1 in
    let p2 = get_precedence t2 in
    compare p1 p2

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
    | KeywordToken _ | LiteralToken _ | OperatorToken _ | DelimiterToken _ | IdentifierToken _ | SpecialToken _ ->
        true

  (** 验证位置信息是否有效 *)
  let is_valid_position pos = pos.line >= 1 && pos.column >= 1 && pos.filename <> ""

  (** 验证带位置Token是否有效 *)
  let is_valid_positioned_token (token, position) =
    is_valid_token token && is_valid_position position

  (** 验证Token列表是否有效 *)
  let validate_token_list tokens = List.for_all is_valid_token tokens
end
