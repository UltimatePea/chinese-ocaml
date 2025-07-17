(** 骆言编译器核心模块 - Chinese Programming Language Compiler Core *)

open Ast
open Lexer
open Parser
open Semantic
open Codegen

(** 初始化模块日志器 *)
let log_info, log_warn, log_error = Logger_utils.init_info_warn_error_loggers "Compiler"

(** 编译选项 *)
type compile_options = {
  show_tokens : bool;
  show_ast : bool;
  show_types : bool;
  check_only : bool;
  quiet_mode : bool;
  filename : string option;
  recovery_mode : bool; (* 启用错误恢复模式 *)
  log_level : string; (* 错误恢复日志级别: "quiet", "normal", "verbose", "debug" *)
  compile_to_c : bool; (* 编译到C代码 *)
  c_output_file : string option; (* C输出文件名 *)
}
(** 编译选项 *)

(** 默认编译选项 *)
let default_options =
  {
    show_tokens = false;
    show_ast = false;
    show_types = false;
    check_only = false;
    quiet_mode = false;
    filename = None;
    recovery_mode = true;
    log_level = "normal";
    compile_to_c = false;
    c_output_file = None;
  }

(** 安静模式编译选项 - 用于测试 *)
let quiet_options =
  {
    show_tokens = false;
    show_ast = false;
    show_types = false;
    check_only = false;
    quiet_mode = true;
    filename = None;
    recovery_mode = true;
    log_level = "quiet";
    compile_to_c = false;
    c_output_file = None;
  }

(** 编译字符串 *)
let compile_string options input_content =
  (* 在安静模式下设置全局日志级别为静默 *)
  let original_level = Logger.get_level () in
  if options.quiet_mode then Logger.set_level Logger.QUIET;
  try
    if not options.quiet_mode then log_info "=== 词法分析 ===";
    let token_list = tokenize input_content "<字符串>" in

    if options.show_tokens then (
      log_info "词元列表:";
      List.iter (fun (token, _pos) -> log_info ("  " ^ show_token token)) token_list;
      log_info "");

    if not options.quiet_mode then log_info "=== 语法分析 ===";
    let program_ast = parse_program token_list in

    if options.show_ast then (
      log_info "抽象语法树:";
      log_info (show_program program_ast ^ "\n"));

    (* 显示类型推断信息 *)
    if options.show_types then Types.show_program_types program_ast;

    if not options.quiet_mode then log_info "=== 语义分析 ===";
    let semantic_check_result =
      if options.quiet_mode then Semantic.type_check_quiet program_ast else type_check program_ast
    in

    let result =
      if (not semantic_check_result) && (not options.recovery_mode) && not options.compile_to_c then (
        log_error "语义分析失败";
        false)
      else if (not semantic_check_result) && options.recovery_mode && not options.compile_to_c then (
        (* 在恢复模式下，即使语义分析失败也继续执行 *)
        if not options.quiet_mode then log_warn "语义分析失败，但在恢复模式下继续执行...";
        if not options.quiet_mode then log_info "=== 代码执行 ===";
        (* 设置日志级别现在通过Error_recovery模块处理 *)
        let config = Error_recovery.get_recovery_config () in
        Error_recovery.set_recovery_config { config with log_level = options.log_level };
        if options.quiet_mode then interpret_quiet program_ast else interpret program_ast)
      else if options.check_only then (
        if not options.quiet_mode then log_info "检查完成，没有错误";
        true)
      else if options.compile_to_c then (
        (* C代码生成 *)
        if not options.quiet_mode then log_info "=== C代码生成 ===";
        let c_output =
          match options.c_output_file with
          | Some file -> file
          | None -> (
              match options.filename with
              | Some f -> Filename.remove_extension f ^ ".c"
              | None -> "output.c")
        in
        let c_config =
          C_codegen_context.
            {
              c_output_file = c_output;
              include_debug = true;
              optimize = false;
              runtime_path = "C后端/runtime/";
            }
        in
        (match C_codegen.compile_to_c c_config program_ast with
         | Ok () -> true
         | Error err -> 
           log_error ("C代码生成失败: " ^ Compiler_errors.format_error_message err);
           false))
      else (
        if not options.quiet_mode then log_info "=== 代码执行 ===";
        (* 设置日志级别现在通过Error_recovery模块处理 *)
        let config = Error_recovery.get_recovery_config () in
        Error_recovery.set_recovery_config { config with log_level = options.log_level };
        if options.quiet_mode then interpret_quiet program_ast else interpret program_ast)
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
