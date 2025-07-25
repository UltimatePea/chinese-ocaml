(** 骆言词法分析器 - 分隔符Token *)

type delimiter_token =
  | LeftParen | RightParen
  | LeftBracket | RightBracket
  | LeftBrace | RightBrace
  | LeftArray | RightArray
  | LeftQuote | RightQuote
  | Comma | Semicolon | Colon | Pipe | Underscore
  | Newline | EOF
[@@deriving show, eq]

let to_string = function
  | LeftParen -> "(" | RightParen -> ")"
  | LeftBracket -> "[" | RightBracket -> "]"
  | LeftBrace -> "{" | RightBrace -> "}"
  | LeftArray -> "[|" | RightArray -> "|]"
  | LeftQuote -> "「" | RightQuote -> "」"
  | Comma -> "," | Semicolon -> ";" | Colon -> ":"
  | Pipe -> "|" | Underscore -> "_"
  | Newline -> "\\n" | EOF -> "EOF"

let from_string = function
  | "(" -> Some LeftParen | ")" -> Some RightParen
  | "[" -> Some LeftBracket | "]" -> Some RightBracket
  | "{" -> Some LeftBrace | "}" -> Some RightBrace
  | "[|" -> Some LeftArray | "|]" -> Some RightArray
  | "「" -> Some LeftQuote | "」" -> Some RightQuote
  | "," -> Some Comma | ";" -> Some Semicolon | ":" -> Some Colon
  | "|" -> Some Pipe | "_" -> Some Underscore
  | "\\n" -> Some Newline | "EOF" -> Some EOF
  | _ -> None

let is_left_delimiter = function
  | LeftParen | LeftBracket | LeftBrace | LeftArray | LeftQuote -> true
  | _ -> false

let is_right_delimiter = function
  | RightParen | RightBracket | RightBrace | RightArray | RightQuote -> true
  | _ -> false

let is_bracket_pair = function
  | LeftParen | RightParen | LeftBracket | RightBracket | LeftBrace | RightBrace
  | LeftArray | RightArray | LeftQuote | RightQuote -> true
  | _ -> false

let get_matching_bracket = function
  | LeftParen -> Some RightParen | RightParen -> Some LeftParen
  | LeftBracket -> Some RightBracket | RightBracket -> Some LeftBracket
  | LeftBrace -> Some RightBrace | RightBrace -> Some LeftBrace
  | LeftArray -> Some RightArray | RightArray -> Some LeftArray
  | LeftQuote -> Some RightQuote | RightQuote -> Some LeftQuote
  | _ -> None

let is_punctuation = function
  | Comma | Semicolon | Colon | Pipe -> true
  | _ -> false