(** 骆言词法分析器 - 中文标点符号识别模块接口 *)

(** 检查全角符号 *)
val check_fullwidth_symbol : Lexer_state.lexer_state -> int -> bool

(** 全角数字检查 *)
val is_fullwidth_digit : Lexer_state.lexer_state -> bool

(** 处理双冒号的特殊逻辑 *)
val handle_colon_sequence : Lexer_state.lexer_state -> Lexer_tokens.position -> (Lexer_tokens.token * Lexer_tokens.position * Lexer_state.lexer_state) option

(** 处理全角符号 *)
val handle_fullwidth_symbols : Lexer_state.lexer_state -> Lexer_tokens.position -> (Lexer_tokens.token * Lexer_tokens.position * Lexer_state.lexer_state) option

(** 检查中文标点符号 *)
val check_chinese_punctuation : Lexer_state.lexer_state -> int -> int -> int -> bool

(** 处理中文标点符号 *)
val handle_chinese_punctuation : Lexer_state.lexer_state -> Lexer_tokens.position -> (Lexer_tokens.token * Lexer_tokens.position * Lexer_state.lexer_state) option

(** 处理中文操作符 *)
val handle_chinese_operators : Lexer_state.lexer_state -> Lexer_tokens.position -> (Lexer_tokens.token * Lexer_tokens.position * Lexer_state.lexer_state) option

(** 处理箭头符号 *)
val handle_arrow_symbols : Lexer_state.lexer_state -> Lexer_tokens.position -> (Lexer_tokens.token * Lexer_tokens.position * Lexer_state.lexer_state) option

(** 主函数 - 中文标点符号识别 *)
val recognize_chinese_punctuation : Lexer_state.lexer_state -> Lexer_tokens.position -> (Lexer_tokens.token * Lexer_tokens.position * Lexer_state.lexer_state) option

(** 管道符号识别（已禁用） *)
val recognize_pipe_right_bracket : Lexer_state.lexer_state -> Lexer_tokens.position -> (Lexer_tokens.token * Lexer_tokens.position * Lexer_state.lexer_state) option