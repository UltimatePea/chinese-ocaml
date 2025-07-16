(** 骆言词法分析器 - 状态管理模块接口 *)

type lexer_state = {
  input : string;
  length : int;
  position : int;
  current_line : int;
  current_column : int;
  filename : string;
}
(** 词法分析器状态 *)

val create_lexer_state : string -> string -> lexer_state
(** 创建词法状态 *)

val current_char : lexer_state -> char option
(** 获取当前字符 *)

val advance : lexer_state -> lexer_state
(** 向前移动 *)

val get_position : lexer_state -> Lexer_tokens.position
(** 获取当前位置信息 *)

val skip_comment : lexer_state -> lexer_state
(** 跳过单个注释 *)

val check_utf8_char : lexer_state -> int -> int -> int -> bool
(** 检查UTF-8字符匹配 *)

val skip_chinese_comment : lexer_state -> lexer_state
(** 跳过中文注释 「：注释内容：」 *)

val skip_whitespace_and_comments : lexer_state -> lexer_state
(** 跳过空白字符和注释 *)
