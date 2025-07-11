(** 豫语编译器主程序 - Chinese Programming Language Compiler Main *)

open Lexer
open Parser
open Semantic
open Codegen

(** 编译选项 *)
type 编译选项 = {
  显示词元: bool;
  显示AST: bool;
  显示类型: bool;
  仅检查: bool;
  文件名: string option;
}

(** 默认编译选项 *)
let 默认选项 = {
  显示词元 = false;
  显示AST = false;
  显示类型 = false;
  仅检查 = false;
  文件名 = None;
}

(** 编译单个文件 *)
let 编译文件 选项 文件名 =
  try
    let 输入内容 = 
      let ic = open_in 文件名 in
      let 内容 = really_input_string ic (in_channel_length ic) in
      close_in ic;
      内容
    in
    
    Printf.printf "编译文件: %s\n" 文件名;
    Printf.printf "源代码:\n%s\n\n" 输入内容;
    
    (* 词法分析 *)
    Printf.printf "=== 词法分析 ===\n";
    let 词元列表 = 词法分析 输入内容 文件名 in
    
    if 选项.显示词元 then (
      Printf.printf "词元列表:\n";
      List.iter (fun (词元, 位置) ->
        Printf.printf "  %s (行:%d, 列:%d)\n" 
          (show_词元 词元) 位置.行号 位置.列号
      ) 词元列表;
      Printf.printf "\n"
    );
    
    (* 语法分析 *)
    Printf.printf "=== 语法分析 ===\n";
    let 程序AST = 解析程序 词元列表 in
    
    if 选项.显示AST then (
      Printf.printf "抽象语法树:\n";
      Printf.printf "%s\n\n" (show_程序 程序AST)
    );
    
    (* 语义分析 *)
    Printf.printf "=== 语义分析 ===\n";
    let 语义检查结果 = 类型检查 程序AST in
    
    if not 语义检查结果 then (
      Printf.printf "语义分析失败，停止编译\n";
      false
    ) else if 选项.仅检查 then (
      Printf.printf "编译检查完成，没有错误\n";
      true
    ) else (
      (* 代码执行 *)
      Printf.printf "=== 代码执行 ===\n";
      解释执行 程序AST
    )
    
  with
  | Sys_error msg -> 
    Printf.printf "文件错误: %s\n" msg; 
    false
  | 词法错误 (消息, 位置) -> 
    Printf.printf "词法错误 (行:%d, 列:%d): %s\n" 位置.行号 位置.列号 消息; 
    false
  | 语法错误 (消息, 位置) -> 
    Printf.printf "语法错误 (行:%d, 列:%d): %s\n" 位置.行号 位置.列号 消息; 
    false
  | e -> 
    Printf.printf "未知错误: %s\n" (Printexc.to_string e); 
    false

(** 编译字符串 *)
let 编译字符串 选项 输入内容 =
  try
    Printf.printf "=== 词法分析 ===\n";
    let 词元列表 = 词法分析 输入内容 "<字符串>" in
    
    if 选项.显示词元 then (
      Printf.printf "词元列表:\n";
      List.iter (fun (词元, 位置) ->
        Printf.printf "  %s\n" (show_词元 词元)
      ) 词元列表;
      Printf.printf "\n"
    );
    
    Printf.printf "=== 语法分析 ===\n";
    let 程序AST = 解析程序 词元列表 in
    
    if 选项.显示AST then (
      Printf.printf "抽象语法树:\n";
      Printf.printf "%s\n\n" (show_程序 程序AST)
    );
    
    Printf.printf "=== 语义分析 ===\n";
    let 语义检查结果 = 类型检查 程序AST in
    
    if not 语义检查结果 then (
      Printf.printf "语义分析失败\n";
      false
    ) else if 选项.仅检查 then (
      Printf.printf "检查完成，没有错误\n";
      true
    ) else (
      Printf.printf "=== 代码执行 ===\n";
      解释执行 程序AST
    )
    
  with
  | 词法错误 (消息, 位置) -> 
    Printf.printf "词法错误 (行:%d, 列:%d): %s\n" 位置.行号 位置.列号 消息; 
    false
  | 语法错误 (消息, 位置) -> 
    Printf.printf "语法错误 (行:%d, 列:%d): %s\n" 位置.行号 位置.列号 消息; 
    false
  | e -> 
    Printf.printf "未知错误: %s\n" (Printexc.to_string e); 
    false

(** 交互式模式 *)
let 交互式模式 () =
  Printf.printf "豫语交互式解释器 v0.1\n";
  Printf.printf "输入 ':quit' 退出, ':help' 查看帮助\n\n";
  
  let 初始环境 = [
    ("打印", 内置函数值 (function
      | [字符串值 s] -> print_endline s; 单元值
      | [值] -> print_endline (值到字符串 值); 单元值
      | _ -> raise (运行时错误 "打印函数期望一个参数")));
  ] in
  
  let rec 循环 环境 =
    Printf.printf "豫语> ";
    flush stdout;
    let 输入 = read_line () in
    
    match 输入 with
    | ":quit" -> Printf.printf "再见！\n"
    | ":help" -> 
      Printf.printf "可用命令:\n";
      Printf.printf "  :quit  - 退出\n";
      Printf.printf "  :help  - 显示帮助\n";
      Printf.printf "或者输入豫语表达式进行求值\n\n";
      循环 环境
    | _ ->
      try
        let 词元列表 = 词法分析 输入 "<交互式>" in
        let 程序AST = 解析程序 词元列表 in
        let 语义检查结果 = 类型检查 程序AST in
        
        if 语义检查结果 then (
          match 程序AST with
          | [表达式语句 表达式] ->
            let 新环境 = 交互式求值 表达式 环境 in
            循环 新环境
          | _ ->
            if 解释执行 程序AST then
              循环 环境
            else
              循环 环境
        ) else (
          循环 环境
        )
      with
      | End_of_file -> Printf.printf "\n再见！\n"
      | 词法错误 (消息, 位置) -> 
        Printf.printf "词法错误: %s\n" 消息; 
        循环 环境
      | 语法错误 (消息, 位置) -> 
        Printf.printf "语法错误: %s\n" 消息; 
        循环 环境
      | e -> 
        Printf.printf "错误: %s\n" (Printexc.to_string e); 
        循环 环境
  in
  
  try
    循环 初始环境
  with
  | End_of_file -> Printf.printf "\n再见！\n"

(** 显示帮助信息 *)
let 显示帮助 () =
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
let rec 解析参数 参数列表 选项 =
  match 参数列表 with
  | [] -> 选项
  | "-tokens" :: 剩余参数 -> 解析参数 剩余参数 { 选项 with 显示词元 = true }
  | "-ast" :: 剩余参数 -> 解析参数 剩余参数 { 选项 with 显示AST = true }
  | "-types" :: 剩余参数 -> 解析参数 剩余参数 { 选项 with 显示类型 = true }
  | "-check" :: 剩余参数 -> 解析参数 剩余参数 { 选项 with 仅检查 = true }
  | "-i" :: 剩余参数 -> 解析参数 剩余参数 选项
  | ("-h" | "-help") :: _ -> 显示帮助 (); exit 0
  | 文件名 :: 剩余参数 -> 解析参数 剩余参数 { 选项 with 文件名 = Some 文件名 }

(** 主函数 *)
let () =
  let 参数列表 = List.tl (Array.to_list Sys.argv) in
  
  if 参数列表 = [] then (
    交互式模式 ()
  ) else if List.mem "-i" 参数列表 then (
    交互式模式 ()
  ) else (
    let 选项 = 解析参数 参数列表 默认选项 in
    
    match 选项.文件名 with
    | None -> 
      Printf.printf "错误: 没有指定输入文件\n";
      显示帮助 ();
      exit 1
    | Some 文件名 ->
      let 成功 = 编译文件 选项 文件名 in
      if not 成功 then exit 1
  )