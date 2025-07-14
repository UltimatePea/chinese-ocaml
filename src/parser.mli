(** 骆言语法分析器接口 - Chinese Programming Language Parser Interface *)

(** 语法错误异常 *)
exception SyntaxError of string * Lexer.position

(** 解析器状态 *)
type parser_state = {
  token_array: Lexer.positioned_token array;
  array_length: int;
  current_pos: int;
}

(** 主要解析函数 *)

(** 解析完整程序 - 主要入口点 *)
val parse_program : Lexer.positioned_token list -> Ast.program

(** 解析语句 *)
val parse_statement : parser_state -> Ast.stmt * parser_state

(** 解析表达式 *)
val parse_expression : parser_state -> Ast.expr * parser_state

(** 解析类型表达式 *)
val parse_type_expression : parser_state -> Ast.type_expr * parser_state

(** 解析类型定义 *)
val parse_type_definition : parser_state -> Ast.type_def * parser_state

(** 解析模式 *)
val parse_pattern : parser_state -> Ast.pattern * parser_state

(** 解析模块类型 *)
val parse_module_type : parser_state -> Ast.module_type * parser_state

(** 解析器状态管理 *)

(** 创建解析器状态 *)
val create_parser_state : Lexer.positioned_token list -> parser_state

(** 获取当前词元 *)
val current_token : parser_state -> Lexer.positioned_token

(** 查看下一个词元 *)
val peek_token : parser_state -> Lexer.positioned_token

(** 前进到下一个词元 *)
val advance_parser : parser_state -> parser_state

(** 跳过换行符 *)
val skip_newlines : parser_state -> parser_state

(** 词元处理工具函数 *)

(** 期望特定词元 *)
val expect_token : parser_state -> Lexer.token -> parser_state

(** 检查是否为特定词元 *)
val is_token : parser_state -> Lexer.token -> bool

(** 解析标识符 *)
val parse_identifier : parser_state -> string * parser_state

(** 解析标识符（允许关键字） *)
val parse_identifier_allow_keywords : parser_state -> string * parser_state

(** 解析字面量 *)
val parse_literal : parser_state -> Ast.literal * parser_state

(** 标点符号助手函数 *)

(** 检查各种标点符号 *)
val is_left_paren : Lexer.token -> bool
val is_right_paren : Lexer.token -> bool
val is_left_bracket : Lexer.token -> bool
val is_right_bracket : Lexer.token -> bool
val is_left_brace : Lexer.token -> bool
val is_right_brace : Lexer.token -> bool
val is_comma : Lexer.token -> bool
val is_semicolon : Lexer.token -> bool
val is_colon : Lexer.token -> bool
val is_pipe : Lexer.token -> bool
val is_arrow : Lexer.token -> bool
val is_double_arrow : Lexer.token -> bool
val is_assign_arrow : Lexer.token -> bool
val is_left_array : Lexer.token -> bool
val is_right_array : Lexer.token -> bool

(** 检查标点符号条件 *)
val is_punctuation : parser_state -> (Lexer.token -> bool) -> bool

(** 期望特定标点符号 *)
val expect_token_punctuation : parser_state -> (Lexer.token -> bool) -> string -> parser_state

(** 专门的解析函数 *)

(** 自然语言函数定义解析 *)
val parse_natural_function_definition : parser_state -> Ast.expr * parser_state

(** 古雅体/古典语言解析 *)
val parse_ancient_function_definition : parser_state -> Ast.expr * parser_state
val parse_ancient_match_expression : parser_state -> Ast.expr * parser_state
val parse_ancient_list_expression : parser_state -> Ast.expr * parser_state
val parse_ancient_conditional_expression : parser_state -> Ast.expr * parser_state

(** 文言文解析 *)
val parse_wenyan_let_expression : parser_state -> Ast.expr * parser_state
val parse_wenyan_simple_let_expression : parser_state -> Ast.expr * parser_state
val parse_wenyan_compound_identifier : parser_state -> string * parser_state

(** 宏解析 *)
val parse_macro_params : Ast.macro_param list -> parser_state -> Ast.macro_param list * parser_state

(** 列表解析 *)
val parse_list_expression : parser_state -> Ast.expr * parser_state

(** 参数列表解析 *)
val parse_parameter_list : parser_state -> Ast.identifier list * parser_state

(** 二元运算助手函数 *)

(** 词元转二元运算符 *)
val token_to_binary_op : Lexer.token -> Ast.binary_op option

(** 运算符优先级 *)
val operator_precedence : Ast.binary_op -> int

(** 语句终结符处理 *)

(** 跳过可选的语句终结符 *)
val skip_optional_statement_terminator : parser_state -> parser_state