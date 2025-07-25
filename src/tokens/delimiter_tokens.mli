(** 骆言词法分析器 - 分隔符令牌类型定义接口 *)

(** 括号类型 *)
type parenthesis_delimiter =
  | LeftParen | RightParen | LeftBracket | RightBracket 
  | LeftBrace | RightBrace | LeftArray | RightArray
[@@deriving show, eq]

(** 标点符号 *)
type punctuation_delimiter =
  | Comma | Semicolon | Colon | QuestionMark | Tilde 
  | Pipe | Underscore | LeftQuote | RightQuote
[@@deriving show, eq]

(** 中文分隔符 *)
type chinese_delimiter =
  | ChineseLeftParen | ChineseRightParen | ChineseLeftBracket | ChineseRightBracket
  | ChineseSquareLeftBracket | ChineseSquareRightBracket | ChineseComma | ChineseSemicolon
  | ChineseColon | ChineseDoubleColon | ChinesePipe | ChineseLeftArray | ChineseRightArray
[@@deriving show, eq]

(** 特殊令牌 *)
type special_delimiter =
  | Newline | EOF
[@@deriving show, eq]

(** 统一分隔符类型 *)
type delimiter_token =
  | Parenthesis of parenthesis_delimiter
  | Punctuation of punctuation_delimiter
  | Chinese of chinese_delimiter
  | Special of special_delimiter
[@@deriving show, eq]

(** 分隔符转换为字符串 *)
val delimiter_token_to_string : delimiter_token -> string

(** 判断是否为左括号 *)
val is_left_delimiter : delimiter_token -> bool

(** 判断是否为右括号 *)
val is_right_delimiter : delimiter_token -> bool

(** 获取匹配的右括号 *)
val get_matching_right_delimiter : delimiter_token -> delimiter_token option