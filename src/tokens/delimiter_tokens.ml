(** 骆言词法分析器 - 分隔符令牌类型定义 *)

(** 括号类型 *)
type parenthesis_delimiter =
  | LeftParen (* ( *)
  | RightParen (* ) *)
  | LeftBracket (* [ *)
  | RightBracket (* ] *)
  | LeftBrace (* { *)
  | RightBrace (* } *)
  | LeftArray (* [| *)
  | RightArray (* |] *)
[@@deriving show, eq]

(** 标点符号 *)
type punctuation_delimiter =
  | Comma (* , *)
  | Semicolon (* ; *)
  | Colon (* : *)
  | QuestionMark (* ? *)
  | Tilde (* ~ *)
  | Pipe (* | *)
  | Underscore (* _ *)
  | LeftQuote (* 「 *)
  | RightQuote (* 」 *)
[@@deriving show, eq]

(** 中文分隔符 *)
type chinese_delimiter =
  | ChineseLeftParen (* （ *)
  | ChineseRightParen (* ） *)
  | ChineseLeftBracket (* 「 - 用于列表 *)
  | ChineseRightBracket (* 」 - 用于列表 *)
  | ChineseSquareLeftBracket (* 【 - 方形左括号 *)
  | ChineseSquareRightBracket (* 】 - 方形右括号 *)
  | ChineseComma (* ， *)
  | ChineseSemicolon (* ； *)
  | ChineseColon (* ： *)
  | ChineseDoubleColon (* ：： - 类型注解 *)
  | ChinesePipe (* ｜ *)
  | ChineseLeftArray (* 「| *)
  | ChineseRightArray (* |」 *)
[@@deriving show, eq]

(** 特殊令牌 *)
type special_delimiter =
  | Newline
  | EOF
[@@deriving show, eq]

(** 统一分隔符类型 *)
type delimiter_token =
  | Parenthesis of parenthesis_delimiter
  | Punctuation of punctuation_delimiter
  | Chinese of chinese_delimiter
  | Special of special_delimiter
[@@deriving show, eq]

(** 分隔符转换为字符串 *)
let delimiter_token_to_string = function
  | Parenthesis pd -> (match pd with
    | LeftParen -> "("
    | RightParen -> ")"
    | LeftBracket -> "["
    | RightBracket -> "]"
    | LeftBrace -> "{"
    | RightBrace -> "}"
    | LeftArray -> "[|"
    | RightArray -> "|]")
  | Punctuation pd -> (match pd with
    | Comma -> ","
    | Semicolon -> ";"
    | Colon -> ":"
    | QuestionMark -> "?"
    | Tilde -> "~"
    | Pipe -> "|"
    | Underscore -> "_"
    | LeftQuote -> "「"
    | RightQuote -> "」")
  | Chinese cd -> (match cd with
    | ChineseLeftParen -> "（"
    | ChineseRightParen -> "）"
    | ChineseLeftBracket -> "「"
    | ChineseRightBracket -> "」"
    | ChineseSquareLeftBracket -> "【"
    | ChineseSquareRightBracket -> "】"
    | ChineseComma -> "，"
    | ChineseSemicolon -> "；"
    | ChineseColon -> "："
    | ChineseDoubleColon -> "：："
    | ChinesePipe -> "｜"
    | ChineseLeftArray -> "「|"
    | ChineseRightArray -> "|」")
  | Special sd -> (match sd with
    | Newline -> "\\n"
    | EOF -> "EOF")

(** 判断是否为左括号 *)
let is_left_delimiter = function
  | Parenthesis (LeftParen | LeftBracket | LeftBrace | LeftArray) -> true
  | Chinese (ChineseLeftParen | ChineseLeftBracket | ChineseSquareLeftBracket | ChineseLeftArray) -> true
  | _ -> false

(** 判断是否为右括号 *)
let is_right_delimiter = function
  | Parenthesis (RightParen | RightBracket | RightBrace | RightArray) -> true
  | Chinese (ChineseRightParen | ChineseRightBracket | ChineseSquareRightBracket | ChineseRightArray) -> true
  | _ -> false

(** 获取匹配的右括号 *)
let get_matching_right_delimiter = function
  | Parenthesis LeftParen -> Some (Parenthesis RightParen)
  | Parenthesis LeftBracket -> Some (Parenthesis RightBracket)
  | Parenthesis LeftBrace -> Some (Parenthesis RightBrace)
  | Parenthesis LeftArray -> Some (Parenthesis RightArray)
  | Chinese ChineseLeftParen -> Some (Chinese ChineseRightParen)
  | Chinese ChineseLeftBracket -> Some (Chinese ChineseRightBracket)
  | Chinese ChineseSquareLeftBracket -> Some (Chinese ChineseSquareRightBracket)
  | Chinese ChineseLeftArray -> Some (Chinese ChineseRightArray)
  | _ -> None