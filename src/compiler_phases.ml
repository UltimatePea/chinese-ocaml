(** 编译阶段处理模块 - Phase 8.3 技术债务清理 *)

open Compiler_config
open Ast
open Lexer
open Parser
open Semantic
open Interpreter
open Error_recovery

(** 初始化模块日志器 *)
let log_info, log_warn, log_error = Logger_utils.init_info_warn_error_loggers "Compiler_phases"

(** 词法分析阶段 *)
let perform_lexical_analysis options input_content =
  if not options.quiet_mode then log_info "=== 词法分析 ===";
  let token_list = tokenize input_content "<字符串>" in
  
  if options.show_tokens then (
    log_info "词元列表:";
    List.iter (fun (token, _pos) -> log_info ("  " ^ show_token token)) token_list;
    log_info "");
  
  token_list

(** 语法分析阶段 *)
let perform_syntax_analysis options token_list =
  if not options.quiet_mode then log_info "=== 语法分析 ===";
  let program_ast = parse_program token_list in
  
  if options.show_ast then (
    log_info "抽象语法树:";
    log_info (show_program program_ast ^ "\n"));
  
  (* 显示类型推断信息 *)
  if options.show_types then Types.show_program_types program_ast;
  
  program_ast

(** 语义分析阶段 *)
let perform_semantic_analysis options program_ast =
  if not options.quiet_mode then log_info "=== 语义分析 ===";
  if options.quiet_mode then 
    Semantic.type_check_quiet program_ast 
  else 
    type_check program_ast

(** 生成C代码输出文件名 *)
let generate_c_output_filename (options : compile_options) : string =
  match options.c_output_file with
  | Some file -> file
  | None -> (
      match options.filename with
      | Some f -> Filename.remove_extension f ^ Constants.RuntimeFunctions.c_extension
      | None -> "output" ^ Constants.RuntimeFunctions.c_extension)

(** C代码生成阶段 *)
let perform_c_code_generation options program_ast =
  if not options.quiet_mode then log_info "=== C代码生成 ===";
  let c_output = generate_c_output_filename options in
  let c_config = {
    C_codegen_context.c_output_file = c_output;
    C_codegen_context.include_debug = true;
    C_codegen_context.optimize = false;
    C_codegen_context.runtime_path = "C后端/runtime/";
  } in
  
  match C_codegen.compile_to_c c_config program_ast with
  | Ok () -> true
  | Error err ->
      log_error ("C代码生成失败: " ^ Compiler_errors.format_error_message err);
      false

(** 解释执行阶段 *)
let perform_interpretation options program_ast =
  if not options.quiet_mode then log_info "=== 代码执行 ===";
  (* 设置日志级别现在通过Error_recovery模块处理 *)
  let config = Error_recovery.get_recovery_config () in
  Error_recovery.set_recovery_config { config with log_level = options.log_level };
  
  if options.quiet_mode then 
    interpret_quiet program_ast 
  else 
    interpret program_ast

(** 恢复模式下的解释执行 *)
let perform_recovery_interpretation options program_ast =
  if not options.quiet_mode then log_warn "语义分析失败，但在恢复模式下继续执行...";
  perform_interpretation options program_ast

(** 决定编译执行模式 *)
let determine_execution_mode options semantic_check_result program_ast =
  if (not semantic_check_result) && (not options.recovery_mode) && not options.compile_to_c then (
    log_error "语义分析失败";
    false
  ) else if (not semantic_check_result) && options.recovery_mode && not options.compile_to_c then (
    perform_recovery_interpretation options program_ast
  ) else if options.check_only then (
    if not options.quiet_mode then log_info "检查完成，没有错误";
    true
  ) else if options.compile_to_c then (
    perform_c_code_generation options program_ast
  ) else (
    perform_interpretation options program_ast
  )