(** 骆言词法分析器接口 - Chinese Programming Language Lexer Interface *)

(** 词元类型 - 从 lexer_tokens 模块导入 *)
type token = Lexer_tokens.token [@@deriving show, eq]

(** 位置信息 - 从 lexer_tokens 模块导入 *)
type position = Lexer_tokens.position [@@deriving show, eq]

(** 带位置信息的词元 - 从 lexer_tokens 模块导入 *)
type positioned_token = Lexer_tokens.positioned_token [@@deriving show, eq]

(** 词法分析异常 *)
exception LexError of string * position

(** 词法分析主函数 *)
val tokenize : string -> string -> positioned_token list

(** 获取下一个词元 *)
val next_token : Lexer_state.lexer_state -> (token * position * Lexer_state.lexer_state)

(** 查找关键字 *)
val find_keyword : string -> token option