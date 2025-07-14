(** 骆言编译器主程序 - Chinese Programming Language Compiler Main *)

open Yyocamlc_lib.Compiler
open Yyocamlc_lib.Codegen

(** 初始化模块日志器 *)
let (log_debug, log_info, log_warn, log_error) = Yyocamlc_lib.Logger.init_module_logger "Main"
let _ = (log_debug, log_info, log_warn)  (* 避免未使用警告 *)

(** 交互式模式 *)
let interactive_mode () =
  Printf.printf "骆言交互式解释器 v0.1\n"; flush_all ();
  Printf.printf "输入 ':quit' 退出, ':help' 查看帮助\n\n"; flush_all ();
  
  let initial_env = [
    ("打印", BuiltinFunctionValue (function
      | [StringValue s] -> print_endline s; UnitValue
      | [value] -> print_endline (value_to_string value); UnitValue
      | _ -> raise (RuntimeError "打印函数期望一个参数")));
  ] in
  
  let rec loop env =
    Printf.printf "骆言> "; flush_all ();
    flush stdout;
    let input = read_line () in
    
    match input with
    | ":quit" -> Printf.printf "再见！\n"; flush_all ()
    | ":help" -> 
      Printf.printf "可用命令:\n"; flush_all ();
      Printf.printf "  :quit  - 退出\n"; flush_all ();
      Printf.printf "  :help  - 显示帮助\n"; flush_all ();
      Printf.printf "或者输入骆言表达式进行求值\n\n"; flush_all ();
      loop env
    | _ ->
      try
        let _success = compile_string default_options input in
        loop env
      with
      | End_of_file -> Printf.printf "\n再见！\n"; flush_all ()
      | e -> 
        Printf.printf "错误: %s\n" (Printexc.to_string e); flush_all (); 
        loop env
  in
  
  try
    loop initial_env
  with
  | End_of_file -> Printf.printf "\n再见！\n"; flush_all ()

(** 显示帮助信息 *)
let show_help () =
  Printf.printf "骆言编译器 v0.1 - 中文编程语言\n\n"; flush_all ();
  Printf.printf "用法:\n"; flush_all ();
  Printf.printf "  luoyanc [选项] [文件]\n\n"; flush_all ();
  Printf.printf "选项:\n"; flush_all ();
  Printf.printf "  -tokens     显示词元列表\n"; flush_all ();
  Printf.printf "  -ast        显示抽象语法树\n"; flush_all ();
  Printf.printf "  -types      显示类型信息\n"; flush_all ();
  Printf.printf "  -check      仅进行语法和类型检查\n"; flush_all ();
  Printf.printf "  -verbose    详细日志模式\n"; flush_all ();
  Printf.printf "  -debug      调试日志模式\n"; flush_all ();
  Printf.printf "  -c          编译到C代码\n"; flush_all ();
  Printf.printf "  -o file     指定C输出文件名\n"; flush_all ();
  Printf.printf "  -i          交互式模式\n"; flush_all ();
  Printf.printf "  -h, -help   显示此帮助信息\n\n"; flush_all ();
  Printf.printf "示例:\n"; flush_all ();
  Printf.printf "  luoyanc program.ly         # 编译并运行程序\n"; flush_all ();
  Printf.printf "  luoyanc -check program.ly  # 仅检查程序\n"; flush_all ();
  Printf.printf "  luoyanc -c program.ly      # 编译到C代码\n"; flush_all ();
  Printf.printf "  luoyanc -c -o prog.c program.ly  # 编译到指定C文件\n"; flush_all ();
  Printf.printf "  luoyanc -i                 # 进入交互式模式\n"; flush_all ()

(** 解析命令行参数 *)
let rec parse_args arg_list options =
  match arg_list with
  | [] -> options
  | "-tokens" :: rest_args -> parse_args rest_args { options with show_tokens = true }
  | "-ast" :: rest_args -> parse_args rest_args { options with show_ast = true }
  | "-types" :: rest_args -> parse_args rest_args { options with show_types = true }
  | "-check" :: rest_args -> parse_args rest_args { options with check_only = true }
  | "-verbose" :: rest_args -> parse_args rest_args { options with log_level = "verbose" }
  | "-debug" :: rest_args -> parse_args rest_args { options with log_level = "debug" }
  | "-c" :: rest_args -> parse_args rest_args { options with compile_to_c = true }
  | "-o" :: output_file :: rest_args -> parse_args rest_args { options with c_output_file = Some output_file }
  | "-i" :: rest_args -> parse_args rest_args options
  | ("-h" | "-help") :: _ -> show_help (); exit 0
  | filename :: rest_args -> parse_args rest_args { options with filename = Some filename }

(** 主函数 *)
let () =
  (* 初始化日志系统 *)
  Yyocamlc_lib.Logger.init ();
  
  let arg_list = List.tl (Array.to_list Sys.argv) in
  
  if arg_list = [] then (
    interactive_mode ()
  ) else if List.mem "-i" arg_list then (
    interactive_mode ()
  ) else (
    let options = parse_args arg_list default_options in
    
    match options.filename with
    | None -> 
      log_error "错误: 没有指定输入文件";
      show_help ();
      exit 1
    | Some filename ->
      let success = compile_file options filename in
      if not success then exit 1
  )