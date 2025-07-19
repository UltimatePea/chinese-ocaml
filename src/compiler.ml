(** 骆言编译器核心模块 - Chinese Programming Language Compiler Core *)

open Lexer
open Parser

(** 初始化模块日志器 *)
let log_info, _, log_error = Logger_utils.init_info_warn_error_loggers "Compiler"

open Compiler_config
(** 重新导出编译器配置类型 *)

type compile_options = Compiler_config.compile_options
(** 编译器选项 *)

(** 默认编译选项 *)
let default_options = Compiler_config.default_options

(** 安静模式编译选项 - 用于测试 *)
let quiet_options = Compiler_config.quiet_options

(** 编译字符串 - 重构后的简化版本 *)
let compile_string options input_content =
  (* 在安静模式下设置全局日志级别为静默 *)
  let original_level = Logger.get_level () in
  if options.quiet_mode then Logger.set_level Logger.QUIET;
  try
    (* 编译阶段1: 词法分析 *)
    let token_list = Compiler_phases.perform_lexical_analysis options input_content in

    (* 编译阶段2: 语法分析 *)
    let program_ast = Compiler_phases.perform_syntax_analysis options token_list in

    (* 编译阶段3: 语义分析 *)
    let semantic_check_result = Compiler_phases.perform_semantic_analysis options program_ast in

    (* 编译阶段4: 决定执行模式并执行 *)
    let result =
      Compiler_phases.determine_execution_mode options semantic_check_result program_ast
    in

    (* 恢复原始日志级别 *)
    if options.quiet_mode then Logger.set_level original_level;
    result
  with
  (* 旧式 LexError 已迁移到统一错误处理系统 *)
  | SyntaxError (msg, pos) ->
      (* 恢复原始日志级别 *)
      if options.quiet_mode then Logger.set_level original_level;
      log_error (Printf.sprintf "语法错误 (行:%d, 列:%d): %s" pos.line pos.column msg);
      false
  | e ->
      (* 恢复原始日志级别 *)
      if options.quiet_mode then Logger.set_level original_level;
      log_error ("未知错误: " ^ Printexc.to_string e);
      false

(** 编译单个文件 *)
let compile_file options filename =
  try
    let input_content =
      let ic = open_in filename in
      let content = really_input_string ic (in_channel_length ic) in
      close_in ic;
      content
    in

    if not options.quiet_mode then (
      log_info ("编译文件: " ^ filename);
      log_info ("源代码:\n" ^ input_content ^ "\n"));

    compile_string options input_content
  with
  | Sys_error msg ->
      log_error ("文件错误: " ^ msg);
      false
  | e ->
      log_error ("未知错误: " ^ Printexc.to_string e);
      false
