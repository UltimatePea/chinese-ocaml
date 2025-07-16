(** 骆言编译器主程序接口 - Chinese Programming Language Compiler Main Interface *)

val interactive_mode : unit -> unit
(** 交互式模式 - 启动交互式解释器 *)

val show_help : unit -> unit
(** 显示帮助信息 *)

val parse_args :
  string list -> Yyocamlc_lib.Compiler.compile_options -> Yyocamlc_lib.Compiler.compile_options
(** 解析命令行参数 *)
