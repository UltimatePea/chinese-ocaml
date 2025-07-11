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
  filename: string option;
}

(** 默认编译选项 *)
let default_options = {
  show_tokens = false;
  show_ast = false;
  show_types = false;
  check_only = false;
  filename = None;
}

(** 编译字符串 *)
let compile_string options input_content =
  try
    Printf.printf "=== 词法分析 ===\n";
    let token_list = tokenize input_content "<字符串>" in
    
    if options.show_tokens then (
      Printf.printf "词元列表:\n";
      List.iter (fun (token, _pos) ->
        Printf.printf "  %s\n" (show_token token)
      ) token_list;
      Printf.printf "\n"
    );
    
    Printf.printf "=== 语法分析 ===\n";
    let program_ast = parse_program token_list in
    
    if options.show_ast then (
      Printf.printf "抽象语法树:\n";
      Printf.printf "%s\n\n" (show_program program_ast)
    );
    
    Printf.printf "=== 语义分析 ===\n";
    let semantic_check_result = type_check program_ast in
    
    if not semantic_check_result then (
      Printf.printf "语义分析失败\n";
      false
    ) else if options.check_only then (
      Printf.printf "检查完成，没有错误\n";
      true
    ) else (
      Printf.printf "=== 代码执行 ===\n";
      interpret program_ast
    )
    
  with
  | LexError (msg, pos) -> 
    Printf.printf "词法错误 (行:%d, 列:%d): %s\n" pos.line pos.column msg; 
    false
  | SyntaxError (msg, pos) -> 
    Printf.printf "语法错误 (行:%d, 列:%d): %s\n" pos.line pos.column msg; 
    false
  | e -> 
    Printf.printf "未知错误: %s\n" (Printexc.to_string e); 
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
    
    Printf.printf "编译文件: %s\n" filename;
    Printf.printf "源代码:\n%s\n\n" input_content;
    
    compile_string options input_content
    
  with
  | Sys_error msg -> 
    Printf.printf "文件错误: %s\n" msg; 
    false
  | e -> 
    Printf.printf "未知错误: %s\n" (Printexc.to_string e); 
    false 