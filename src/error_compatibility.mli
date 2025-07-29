(** 错误处理兼容性层 - 为遗留错误类型提供现代化接口
    
    此模块提供遗留异常类型到现代 CompilerError 系统的适配器，
    确保向后兼容性的同时推动错误处理标准化。
    
    Author: Alpha, 主要工作代理
    Purpose: Fix #1646 - 错误处理系统现代化 *)

open Compiler_errors_types

(** {1 遗留异常适配器} *)

val legacy_type_error : string -> 'a
(** 兼容 Types.TypeError，转换为现代 CompilerError *)

val legacy_parse_error : string -> int -> int -> 'a
(** 兼容 Types.ParseError，转换为现代 CompilerError *)

val legacy_codegen_error : string -> string -> 'a
(** 兼容 Types.CodegenError，转换为现代 CompilerError *)

val legacy_semantic_error : string -> string -> 'a
(** 兼容 Types.SemanticError，转换为现代 CompilerError *)

(** {1 现代错误创建函数} *)

val create_type_error : ?pos:position -> ?suggestions:string list -> string -> 'a
(** 创建类型错误，支持位置信息和建议 *)

val create_parse_error : pos:position -> ?suggestions:string list -> string -> 'a
(** 创建解析错误，必须包含位置信息 *)

val create_syntax_error : pos:position -> ?suggestions:string list -> string -> 'a
(** 创建语法错误，必须包含位置信息 *)

val create_semantic_error : ?pos:position -> ?context:string -> ?suggestions:string list -> string -> 'a
(** 创建语义错误，支持位置和上下文信息 *)

val create_codegen_error : context:string -> ?suggestions:string list -> string -> 'a
(** 创建代码生成错误，必须包含上下文 *)

val create_runtime_error : ?pos:position -> ?suggestions:string list -> string -> 'a
(** 创建运行时错误，支持位置信息 *)

(** {1 位置信息工具} *)

val create_position : filename:string -> line:int -> column:int -> position
(** 创建位置信息记录 *)

val position_from_line_col : filename:string -> line:int -> column:int -> position
(** 从行列号创建位置信息（与上面功能相同，提供别名） *)

val unknown_position : filename:string -> position
(** 创建位置未知的记录 *)

(** {1 错误建议工具} *)

val suggest_similar_identifier : string -> string list -> string list
(** 为拼写错误的标识符生成建议 *)

val suggest_type_fix : expected:string -> actual:string -> string list
(** 为类型错误生成修复建议 *)

val suggest_syntax_fix : expected:string -> string list
(** 为语法错误生成修复建议 *)