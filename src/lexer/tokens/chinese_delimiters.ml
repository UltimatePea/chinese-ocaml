(** 骆言词法分析器 - 中文标点符号Token *)

type chinese_delimiter =
  | ChineseLeftParen
  | ChineseRightParen
  | ChineseLeftBracket
  | ChineseRightBracket
  | ChineseSquareLeftBracket
  | ChineseSquareRightBracket
  | ChineseLeftArray
  | ChineseRightArray
  | ChineseComma
  | ChineseSemicolon
  | ChineseColon
  | ChineseDoubleColon
  | ChinesePipe
  | ChineseArrow
  | ChineseDoubleArrow
  | ChineseAssignArrow
[@@deriving show, eq]

let to_string = function
  | ChineseLeftParen -> "（"
  | ChineseRightParen -> "）"
  | ChineseLeftBracket -> "「"
  | ChineseRightBracket -> "」"
  | ChineseSquareLeftBracket -> "【"
  | ChineseSquareRightBracket -> "】"
  | ChineseLeftArray -> "「|"
  | ChineseRightArray -> "|」"
  | ChineseComma -> "，"
  | ChineseSemicolon -> "；"
  | ChineseColon -> "："
  | ChineseDoubleColon -> "：："
  | ChinesePipe -> "｜"
  | ChineseArrow -> "→"
  | ChineseDoubleArrow -> "⇒"
  | ChineseAssignArrow -> "←"

let from_string = function
  | "（" -> Some ChineseLeftParen
  | "）" -> Some ChineseRightParen
  | "「" -> Some ChineseLeftBracket
  | "」" -> Some ChineseRightBracket
  | "【" -> Some ChineseSquareLeftBracket
  | "】" -> Some ChineseSquareRightBracket
  | "「|" -> Some ChineseLeftArray
  | "|」" -> Some ChineseRightArray
  | "，" -> Some ChineseComma
  | "；" -> Some ChineseSemicolon
  | "：" -> Some ChineseColon
  | "：：" -> Some ChineseDoubleColon
  | "｜" -> Some ChinesePipe
  | "→" -> Some ChineseArrow
  | "⇒" -> Some ChineseDoubleArrow
  | "←" -> Some ChineseAssignArrow
  | _ -> None

let is_chinese_left_delimiter = function
  | ChineseLeftParen | ChineseLeftBracket | ChineseSquareLeftBracket | ChineseLeftArray -> true
  | _ -> false

let is_chinese_right_delimiter = function
  | ChineseRightParen | ChineseRightBracket | ChineseSquareRightBracket | ChineseRightArray -> true
  | _ -> false

let is_chinese_bracket_pair = function
  | ChineseLeftParen | ChineseRightParen | ChineseLeftBracket | ChineseRightBracket
  | ChineseSquareLeftBracket | ChineseSquareRightBracket | ChineseLeftArray | ChineseRightArray ->
      true
  | _ -> false

let get_matching_chinese_bracket = function
  | ChineseLeftParen -> Some ChineseRightParen
  | ChineseRightParen -> Some ChineseLeftParen
  | ChineseLeftBracket -> Some ChineseRightBracket
  | ChineseRightBracket -> Some ChineseLeftBracket
  | ChineseSquareLeftBracket -> Some ChineseSquareRightBracket
  | ChineseSquareRightBracket -> Some ChineseSquareLeftBracket
  | ChineseLeftArray -> Some ChineseRightArray
  | ChineseRightArray -> Some ChineseLeftArray
  | _ -> None

let is_chinese_punctuation = function
  | ChineseComma | ChineseSemicolon | ChineseColon | ChineseDoubleColon | ChinesePipe -> true
  | _ -> false

let is_chinese_arrow = function
  | ChineseArrow | ChineseDoubleArrow | ChineseAssignArrow -> true
  | _ -> false
