(** 骆言词法分析器接口 - Chinese Programming Language Lexer Interface *)

(** 词元类型 - 从 lexer_tokens 模块导入 *)
(** 重新导出token构造器以保持向后兼容性 *)
include module type of Lexer_tokens

val tokenize : string -> string -> positioned_token list
(** 词法分析主函数 *)

val next_token : Lexer_state.lexer_state -> token * position * Lexer_state.lexer_state
(** 获取下一个词元 *)

val find_keyword : string -> token option
(** 查找关键字 *)
