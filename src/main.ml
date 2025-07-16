(** 骆言编译器主程序 - Chinese Programming Language Compiler Main *)

open Yyocamlc_lib.Compiler

(** 初始化模块日志器 *)
let log_info, log_error = Yyocamlc_lib.Logger_utils.init_info_error_loggers "Main"

(** 交互式模式 *)
let interactive_mode () =
  log_info "骆言交互式解释器 v0.1";
  log_info "输入 ':quit' 退出, ':help' 查看帮助\n";

  let initial_env = Yyocamlc_lib.Builtin_functions.builtin_functions in

  let rec loop env =
    Yyocamlc_lib.Logger.print_user_prompt "骆言> ";
    flush_all ();
    flush stdout;
    let input = read_line () in

    match input with
    | ":quit" -> log_info "再见！"
    | ":help" ->
        log_info "可用命令:";
        log_info "  :quit  - 退出";
        log_info "  :help  - 显示帮助";
        log_info "或者输入骆言表达式进行求值\n";
        loop env
    | _ -> (
        try
          let _ = compile_string default_options input in
          loop env
        with
        | End_of_file -> log_info "\n再见！"
        | e ->
            log_error ("错误: " ^ Printexc.to_string e);
            loop env)
  in

  try loop initial_env with End_of_file -> log_info "\n再见！"

(** 显示帮助信息 *)
let show_help () =
  log_info "骆言编译器 v0.1 - 中文编程语言\n";
  log_info "用法:";
  log_info "  luoyanc [选项] [文件]\n";
  log_info "选项:";
  log_info "  -tokens     显示词元列表";
  log_info "  -ast        显示抽象语法树";
  log_info "  -types      显示类型信息";
  log_info "  -check      仅进行语法和类型检查";
  log_info "  -verbose    详细日志模式";
  log_info "  -debug      调试日志模式";
  log_info "  -c          编译到C代码";
  log_info "  -o file     指定C输出文件名";
  log_info "  -i          交互式模式";
  log_info "  -h, -help   显示此帮助信息\n";
  log_info "示例:";
  log_info "  luoyanc program.ly         # 编译并运行程序";
  log_info "  luoyanc -check program.ly  # 仅检查程序";
  log_info "  luoyanc -c program.ly      # 编译到C代码";
  log_info "  luoyanc -c -o prog.c program.ly  # 编译到指定C文件";
  log_info "  luoyanc -i                 # 进入交互式模式"

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
  | "-o" :: output_file :: rest_args ->
      parse_args rest_args { options with c_output_file = Some output_file }
  | "-i" :: rest_args -> parse_args rest_args options
  | ("-h" | "-help") :: _ ->
      show_help ();
      exit 0
  | filename :: rest_args -> parse_args rest_args { options with filename = Some filename }

(** 主函数 *)
let () =
  (* 初始化日志系统 *)
  Yyocamlc_lib.Logger.init ();

  let arg_list = List.tl (Array.to_list Sys.argv) in

  if arg_list = [] then interactive_mode ()
  else if List.mem "-i" arg_list then interactive_mode ()
  else
    let options = parse_args arg_list default_options in

    match options.filename with
    | None ->
        log_error "错误: 没有指定输入文件";
        show_help ();
        exit 1
    | Some filename ->
        let success = compile_file options filename in
        if not success then exit 1
