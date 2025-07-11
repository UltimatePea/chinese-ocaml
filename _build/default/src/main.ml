(** 豫语编译器主程序 - Chinese Programming Language Compiler Main *)

open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser
open Yyocamlc_lib.Semantic
open Yyocamlc_lib.Codegen
open Yyocamlc_lib.Ast

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
    
    (* 词法分析 *)
    Printf.printf "=== 词法分析 ===\n";
    let token_list = tokenize input_content filename in
    
    if options.show_tokens then (
      Printf.printf "词元列表:\n";
      List.iter (fun (token, pos) ->
        Printf.printf "  %s (行:%d, 列:%d)\n" 
          (show_token token) pos.line pos.column
      ) token_list;
      Printf.printf "\n"
    );
    
    (* 语法分析 *)
    Printf.printf "=== 语法分析 ===\n";
    let program_ast = parse_program token_list in
    
    if options.show_ast then (
      Printf.printf "抽象语法树:\n";
      Printf.printf "%s\n\n" (show_program program_ast)
    );
    
    (* 语义分析 *)
    Printf.printf "=== 语义分析 ===\n";
    let semantic_check_result = type_check program_ast in
    
    if not semantic_check_result then (
      Printf.printf "语义分析失败，停止编译\n";
      false
    ) else if options.check_only then (
      Printf.printf "编译检查完成，没有错误\n";
      true
    ) else (
      (* 代码执行 *)
      Printf.printf "=== 代码执行 ===\n";
      interpret program_ast
    )
    
  with
  | Sys_error msg -> 
    Printf.printf "文件错误: %s\n" msg; 
    false
  | LexError (msg, pos) -> 
    Printf.printf "词法错误 (行:%d, 列:%d): %s\n" pos.line pos.column msg; 
    false
  | SyntaxError (msg, pos) -> 
    Printf.printf "语法错误 (行:%d, 列:%d): %s\n" pos.line pos.column msg; 
    false
  | e -> 
    Printf.printf "未知错误: %s\n" (Printexc.to_string e); 
    false

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

(** 交互式模式 *)
let interactive_mode () =
  Printf.printf "豫语交互式解释器 v0.1\n";
  Printf.printf "输入 ':quit' 退出, ':help' 查看帮助\n\n";
  
  let initial_env = [
    ("打印", BuiltinFunctionValue (function
      | [StringValue s] -> print_endline s; UnitValue
      | [value] -> print_endline (value_to_string value); UnitValue
      | _ -> raise (RuntimeError "打印函数期望一个参数")));
  ] in
  
  let rec loop env =
    Printf.printf "豫语> ";
    flush stdout;
    let input = read_line () in
    
    match input with
    | ":quit" -> Printf.printf "再见！\n"
    | ":help" -> 
      Printf.printf "可用命令:\n";
      Printf.printf "  :quit  - 退出\n";
      Printf.printf "  :help  - 显示帮助\n";
      Printf.printf "或者输入豫语表达式进行求值\n\n";
      loop env
    | _ ->
      try
        let token_list = tokenize input "<交互式>" in
        let program_ast = parse_program token_list in
        let semantic_check_result = type_check program_ast in
        
        if semantic_check_result then (
          match program_ast with
          | [ExprStmt expr] ->
            let new_env = interactive_eval expr env in
            loop new_env
          | _ ->
            if interpret program_ast then
              loop env
            else
              loop env
        ) else (
          loop env
        )
      with
      | End_of_file -> Printf.printf "\n再见！\n"
      | LexError (msg, _pos) -> 
        Printf.printf "词法错误: %s\n" msg; 
        loop env
      | SyntaxError (msg, _pos) -> 
        Printf.printf "语法错误: %s\n" msg; 
        loop env
      | e -> 
        Printf.printf "错误: %s\n" (Printexc.to_string e); 
        loop env
  in
  
  try
    loop initial_env
  with
  | End_of_file -> Printf.printf "\n再见！\n"

(** 显示帮助信息 *)
let show_help () =
  Printf.printf "豫语编译器 v0.1 - 中文编程语言\n\n";
  Printf.printf "用法:\n";
  Printf.printf "  yyocamlc [选项] [文件]\n\n";
  Printf.printf "选项:\n";
  Printf.printf "  -tokens     显示词元列表\n";
  Printf.printf "  -ast        显示抽象语法树\n";
  Printf.printf "  -types      显示类型信息\n";
  Printf.printf "  -check      仅进行语法和类型检查\n";
  Printf.printf "  -i          交互式模式\n";
  Printf.printf "  -h, -help   显示此帮助信息\n\n";
  Printf.printf "示例:\n";
  Printf.printf "  yyocamlc program.yu         # 编译并运行程序\n";
  Printf.printf "  yyocamlc -check program.yu  # 仅检查程序\n";
  Printf.printf "  yyocamlc -i                 # 进入交互式模式\n"

(** 解析命令行参数 *)
let rec parse_args arg_list options =
  match arg_list with
  | [] -> options
  | "-tokens" :: rest_args -> parse_args rest_args { options with show_tokens = true }
  | "-ast" :: rest_args -> parse_args rest_args { options with show_ast = true }
  | "-types" :: rest_args -> parse_args rest_args { options with show_types = true }
  | "-check" :: rest_args -> parse_args rest_args { options with check_only = true }
  | "-i" :: rest_args -> parse_args rest_args options
  | ("-h" | "-help") :: _ -> show_help (); exit 0
  | filename :: rest_args -> parse_args rest_args { options with filename = Some filename }

(** 主函数 *)
let () =
  let arg_list = List.tl (Array.to_list Sys.argv) in
  
  if arg_list = [] then (
    interactive_mode ()
  ) else if List.mem "-i" arg_list then (
    interactive_mode ()
  ) else (
    let options = parse_args arg_list default_options in
    
    match options.filename with
    | None -> 
      Printf.printf "错误: 没有指定输入文件\n";
      show_help ();
      exit 1
    | Some filename ->
      let success = compile_file options filename in
      if not success then exit 1
  )