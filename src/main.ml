(** 骆言编译器主程序 - Chinese Programming Language Compiler Main *)

open Yyocamlc_lib.Compiler
open Yyocamlc_lib.Codegen

(** 交互式模式 *)
let interactive_mode () =
  Printf.printf "骆言交互式解释器 v0.1\n";
  Printf.printf "输入 ':quit' 退出, ':help' 查看帮助\n\n";
  
  let initial_env = [
    ("打印", BuiltinFunctionValue (function
      | [StringValue s] -> print_endline s; UnitValue
      | [value] -> print_endline (value_to_string value); UnitValue
      | _ -> raise (RuntimeError "打印函数期望一个参数")));
  ] in
  
  let rec loop env =
    Printf.printf "骆言> ";
    flush stdout;
    let input = read_line () in
    
    match input with
    | ":quit" -> Printf.printf "再见！\n"
    | ":help" -> 
      Printf.printf "可用命令:\n";
      Printf.printf "  :quit  - 退出\n";
      Printf.printf "  :help  - 显示帮助\n";
      Printf.printf "或者输入骆言表达式进行求值\n\n";
      loop env
    | _ ->
      try
        let _success = compile_string default_options input in
        loop env
      with
      | End_of_file -> Printf.printf "\n再见！\n"
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
  Printf.printf "骆言编译器 v0.1 - 中文编程语言\n\n";
  Printf.printf "用法:\n";
  Printf.printf "  luoyanc [选项] [文件]\n\n";
  Printf.printf "选项:\n";
  Printf.printf "  -tokens     显示词元列表\n";
  Printf.printf "  -ast        显示抽象语法树\n";
  Printf.printf "  -types      显示类型信息\n";
  Printf.printf "  -check      仅进行语法和类型检查\n";
  Printf.printf "  -i          交互式模式\n";
  Printf.printf "  -h, -help   显示此帮助信息\n\n";
  Printf.printf "示例:\n";
  Printf.printf "  luoyanc program.yu         # 编译并运行程序\n";
  Printf.printf "  luoyanc -check program.yu  # 仅检查程序\n";
  Printf.printf "  luoyanc -i                 # 进入交互式模式\n"

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