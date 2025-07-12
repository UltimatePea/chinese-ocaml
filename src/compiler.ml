(** 骆言编译器核心模块 - Chinese Programming Language Compiler Core *)

open Ast
open Lexer
open Parser
open Semantic
open Codegen

(** 编译选项 *)
type compile_options = {
  show_tokens: bool;
  show_ast: bool;
  show_types: bool;
  check_only: bool;
  quiet_mode: bool;
  filename: string option;
  recovery_mode: bool;  (* 启用错误恢复模式 *)
  log_level: string;    (* 错误恢复日志级别: "quiet", "normal", "verbose", "debug" *)
  compile_to_c: bool;   (* 编译到C代码 *)
  c_output_file: string option;  (* C输出文件名 *)
}

(** 默认编译选项 *)
let default_options = {
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
let quiet_options = {
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
  try
    if not options.quiet_mode then Printf.printf "=== 词法分析 ===\n";
    let token_list = tokenize input_content "<字符串>" in
    
    if options.show_tokens then (
      Printf.printf "词元列表:\n";
      List.iter (fun (token, _pos) ->
        Printf.printf "  %s\n" (show_token token); flush_all ()
      ) token_list;
      Printf.printf "\n"; flush_all ()
    );
    
    if not options.quiet_mode then Printf.printf "=== 语法分析 ===\n";
    let program_ast = parse_program token_list in
    
    if options.show_ast then (
      Printf.printf "抽象语法树:\n";
      Printf.printf "%s\n\n" (show_program program_ast)
    );
    
    (* 显示类型推断信息 *)
    if options.show_types then (
      Types.show_program_types program_ast
    );
    
    if not options.quiet_mode then Printf.printf "=== 语义分析 ===\n";
    let semantic_check_result = 
      if options.quiet_mode then 
        Semantic.type_check_quiet program_ast
      else 
        type_check program_ast in
    
    if not semantic_check_result && not options.recovery_mode then (
      Printf.printf "语义分析失败\n";
      flush_all ();
      false
    ) else if not semantic_check_result && options.recovery_mode then (
      (* 在恢复模式下，即使语义分析失败也继续执行 *)
      if not options.quiet_mode then Printf.printf "语义分析失败，但在恢复模式下继续执行...\n";
      if not options.quiet_mode then Printf.printf "=== 代码执行 ===\n";
      Codegen.set_log_level options.log_level;
      if options.quiet_mode then
        interpret_quiet program_ast
      else
        interpret program_ast
    ) else if options.check_only then (
      if not options.quiet_mode then Printf.printf "检查完成，没有错误\n";
      true
    ) else if options.compile_to_c then (
      (* C代码生成 *)
      if not options.quiet_mode then Printf.printf "=== C代码生成 ===\n";
      let c_output = match options.c_output_file with
        | Some file -> file
        | None -> match options.filename with
          | Some f -> (Filename.remove_extension f) ^ ".c"
          | None -> "output.c"
      in
      let c_config = C_codegen.{
        output_file = c_output;
        include_debug = true;
        optimize = false;
        runtime_path = "c_backend/runtime/";
      } in
      C_codegen.compile_to_c c_config program_ast;
      true
    ) else (
      if not options.quiet_mode then Printf.printf "=== 代码执行 ===\n";
      Codegen.set_log_level options.log_level;
      if options.quiet_mode then
        interpret_quiet program_ast
      else
        interpret program_ast
    )
    
  with
  | LexError (msg, pos) -> 
    Printf.printf "词法错误 (行:%d, 列:%d): %s\n" pos.line pos.column msg; 
    flush_all ();
    false
  | SyntaxError (msg, pos) -> 
    Printf.printf "语法错误 (行:%d, 列:%d): %s\n" pos.line pos.column msg; 
    flush_all ();
    false
  | e -> 
    Printf.printf "未知错误: %s\n" (Printexc.to_string e); 
    flush_all ();
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
      Printf.printf "编译文件: %s\n" filename;
      Printf.printf "源代码:\n%s\n\n" input_content
    );
    
    compile_string options input_content
    
  with
  | Sys_error msg -> 
    Printf.printf "文件错误: %s\n" msg; 
    flush_all ();
    false
  | e -> 
    Printf.printf "未知错误: %s\n" (Printexc.to_string e); 
    flush_all ();
    false 