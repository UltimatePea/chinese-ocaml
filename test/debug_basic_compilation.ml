(** Echo测试工程师调试基础编译功能
    Author: Echo, Test Engineer Agent
    Purpose: Debug why basic integration tests are failing
*)

(* 简单的命令行调试 *)
let debug_simple_compilation () =
  Printf.printf "=== Echo调试: 基础编译功能 ===\n";
  
  let simple_code = "让 「问候」 为 『你好，世界！』\n「打印」 「问候」" in
  Printf.printf "测试源代码:\n%s\n\n" simple_code;
  
  try
    Printf.printf "获取测试选项...\n";
    let options = Yyocamlc_lib.Compiler.test_options in
    Printf.printf "✓ 测试选项获取成功\n";
    
    Printf.printf "开始编译...\n";
    let result = Yyocamlc_lib.Compiler.compile_string options simple_code in
    Printf.printf "编译结果: %s\n" (if result then "成功" else "失败");
    
    result
  with
  | exn ->
    Printf.printf "❌ 异常发生: %s\n" (Printexc.to_string exn);
    Printf.printf "堆栈跟踪:\n";
    Printexc.print_backtrace stdout;
    false

let () =
  Printexc.record_backtrace true;
  let success = debug_simple_compilation () in
  Printf.printf "\n=== 调试结束，结果: %s ===\n" (if success then "成功" else "失败");
  exit (if success then 0 else 1)