(** 错误恢复模块测试套件
    
    验证error_handler_recovery.ml模块的错误恢复策略功能
    包括恢复策略确定、恢复执行和继续处理判断
    
    创建目的：提升错误处理模块测试覆盖率至60%以上 Fix #925 第二阶段 *)

open Alcotest
open Yyocamlc_lib.Error_handler_recovery
open Yyocamlc_lib.Compiler_errors
open Yyocamlc_lib.Error_handler_types
open Yyocamlc_lib.Error_handler_statistics

(** 测试辅助函数 *)
let create_test_position () = 
  { filename = "测试文件.ly"; line = 10; column = 5 }

let create_test_context () =
  create_context ~source_file:"test.ly" ~function_name:"test_func" 
    ~module_name:"Test" ~call_stack:["main"; "test_func"] ()

let create_error_of_type error_type =
  let pos = create_test_position () in
  match error_type with
  | "lex" -> make_error_info (LexError ("词法错误", pos))
  | "parse" -> make_error_info (ParseError ("解析错误", pos))
  | "syntax" -> make_error_info (SyntaxError ("语法错误", pos))
  | "poetry" -> make_error_info (PoetryParseError ("诗词解析错误", Some pos))
  | "type" -> make_error_info (TypeError ("类型错误", Some pos))
  | "semantic" -> make_error_info (SemanticError ("语义错误", Some pos))
  | "codegen" -> make_error_info (CodegenError ("代码生成错误", "测试上下文"))
  | "runtime" -> make_error_info (RuntimeError ("运行时错误", Some pos))
  | "exception" -> make_error_info (ExceptionRaised ("异常错误", Some pos))
  | "internal" -> make_error_info ~severity:Fatal (InternalError "内部错误")
  | "unimplemented" -> make_error_info (UnimplementedFeature ("未实现功能", "测试上下文"))
  | "io" -> make_error_info (IOError ("IO错误", "测试文件路径"))
  | _ -> make_error_info (SyntaxError ("默认错误", pos))

(** 测试确定恢复策略 *)
let test_determine_recovery_strategy () =
  Printf.printf "测试确定恢复策略功能...\n";
  
  (* 测试词法错误的恢复策略 *)
  let lex_error = create_error_of_type "lex" in
  let lex_strategy = determine_recovery_strategy lex_error.error_type in
  check (bool) "词法错误应使用SkipAndContinue策略" true
    (lex_strategy = SkipAndContinue);
  
  (* 测试解析错误的恢复策略 *)
  let parse_error = create_error_of_type "parse" in
  let parse_strategy = determine_recovery_strategy parse_error.error_type in
  check (bool) "解析错误应使用SyncToNextStatement策略" true
    (parse_strategy = SyncToNextStatement);
  
  (* 测试语法错误的恢复策略 *)
  let syntax_error = create_error_of_type "syntax" in
  let syntax_strategy = determine_recovery_strategy syntax_error.error_type in
  check (bool) "语法错误应使用SyncToNextStatement策略" true
    (syntax_strategy = SyncToNextStatement);
  
  (* 测试诗词解析错误的恢复策略 *)
  let poetry_error = create_error_of_type "poetry" in
  let poetry_strategy = determine_recovery_strategy poetry_error.error_type in
  check (bool) "诗词解析错误应使用SkipAndContinue策略" true
    (poetry_strategy = SkipAndContinue);
  
  (* 测试类型错误的恢复策略 *)
  let type_error = create_error_of_type "type" in
  let type_strategy = determine_recovery_strategy type_error.error_type in
  check (bool) "类型错误应使用SkipAndContinue策略" true
    (type_strategy = SkipAndContinue);
  
  Printf.printf "恢复策略确定测试完成\n"

(** 测试代码生成和运行时错误的恢复策略 *)
let test_advanced_recovery_strategies () =
  Printf.printf "测试高级恢复策略功能...\n";
  
  (* 测试代码生成错误的恢复策略 *)
  let codegen_error = create_error_of_type "codegen" in
  let codegen_strategy = determine_recovery_strategy codegen_error.error_type in
  check (bool) "代码生成错误应使用TryAlternative策略" true
    (match codegen_strategy with TryAlternative _ -> true | _ -> false);
  
  (* 测试运行时错误的恢复策略 *)
  let runtime_error = create_error_of_type "runtime" in
  let runtime_strategy = determine_recovery_strategy runtime_error.error_type in
  check (bool) "运行时错误应使用RequestUserInput策略" true
    (runtime_strategy = RequestUserInput);
  
  (* 测试异常错误的恢复策略 *)
  let exception_error = create_error_of_type "exception" in
  let exception_strategy = determine_recovery_strategy exception_error.error_type in
  check (bool) "异常错误应使用RequestUserInput策略" true
    (exception_strategy = RequestUserInput);
  
  (* 测试内部错误的恢复策略 *)
  let internal_error = create_error_of_type "internal" in
  let internal_strategy = determine_recovery_strategy internal_error.error_type in
  check (bool) "内部错误应使用Abort策略" true
    (internal_strategy = Abort);
  
  (* 测试未实现功能错误的恢复策略 *)
  let unimpl_error = create_error_of_type "unimplemented" in
  let unimpl_strategy = determine_recovery_strategy unimpl_error.error_type in
  check (bool) "未实现功能错误应使用TryAlternative策略" true
    (match unimpl_strategy with TryAlternative _ -> true | _ -> false);
  
  (* 测试IO错误的恢复策略 *)
  let io_error = create_error_of_type "io" in
  let io_strategy = determine_recovery_strategy io_error.error_type in
  check (bool) "IO错误应使用TryAlternative策略" true
    (match io_strategy with TryAlternative _ -> true | _ -> false);
  
  Printf.printf "高级恢复策略测试完成\n"

(** 测试错误恢复执行 *)
let test_attempt_recovery () =
  Printf.printf "测试错误恢复执行功能...\n";
  
  let context = create_test_context () in
  let base_error = create_error_of_type "syntax" in
  
  (* 测试SkipAndContinue恢复 *)
  let skip_enhanced = create_enhanced_error ~recovery_strategy:SkipAndContinue base_error context in
  let skip_result = attempt_recovery skip_enhanced in
  check (bool) "SkipAndContinue策略应该成功恢复" true skip_result;
  
  (* 测试SyncToNextStatement恢复 *)
  let sync_enhanced = create_enhanced_error ~recovery_strategy:SyncToNextStatement base_error context in
  let sync_result = attempt_recovery sync_enhanced in
  check (bool) "SyncToNextStatement策略应该成功恢复" true sync_result;
  
  (* 测试TryAlternative恢复 *)
  let alt_enhanced = create_enhanced_error ~recovery_strategy:(TryAlternative "替代方案") base_error context in
  let alt_result = attempt_recovery alt_enhanced in
  check (bool) "TryAlternative策略应该成功恢复" true alt_result;
  
  (* 测试RequestUserInput恢复 *)
  let user_enhanced = create_enhanced_error ~recovery_strategy:RequestUserInput base_error context in
  let user_result = attempt_recovery user_enhanced in
  check (bool) "RequestUserInput策略应该返回false（需要用户交互）" false user_result;
  
  (* 测试Abort恢复 *)
  let abort_enhanced = create_enhanced_error ~recovery_strategy:Abort base_error context in
  let abort_result = attempt_recovery abort_enhanced in
  check (bool) "Abort策略应该返回false" false abort_result;
  
  Printf.printf "错误恢复执行测试完成\n"

(** 测试恢复统计更新 *)
let test_recovery_statistics () =
  Printf.printf "测试恢复统计更新功能...\n";
  
  let context = create_test_context () in
  let base_error = create_error_of_type "type" in
  
  (* 记录恢复前的统计 *)
  let before_recovered = global_stats.recovered_errors in
  
  (* 执行一次成功的恢复 *)
  let enhanced = create_enhanced_error ~recovery_strategy:SkipAndContinue base_error context in
  let _ = attempt_recovery enhanced in
  
  (* 检查统计是否更新 *)
  check (bool) "成功恢复应该增加recovered_errors计数" true
    (global_stats.recovered_errors > before_recovered);
  
  Printf.printf "恢复统计更新测试完成\n"

(** 测试继续处理条件判断 *)
let test_should_continue_processing () =
  Printf.printf "测试继续处理条件判断功能...\n";
  
  (* 重置统计信息以确保测试环境干净 *)
  global_stats.total_errors <- 0;
  global_stats.fatal_errors <- 0;
  
  (* 正常情况下应该继续处理 *)
  let should_continue_normal = should_continue_processing () in
  check (bool) "正常情况下应该继续处理" true should_continue_normal;
  
  (* 模拟致命错误情况 *)
  global_stats.fatal_errors <- 1;
  let should_continue_fatal = should_continue_processing () in
  check (bool) "存在致命错误时不应该继续处理" false should_continue_fatal;
  
  (* 重置致命错误，测试错误数量超限情况 *)
  global_stats.fatal_errors <- 0;
  global_stats.total_errors <- 101; (* 超过默认限制 *)
  let should_continue_overlimit = should_continue_processing () in
  check (bool) "错误数量超限时不应该继续处理" false should_continue_overlimit;
  
  (* 重置统计信息 *)
  global_stats.total_errors <- 0;
  global_stats.fatal_errors <- 0;
  
  Printf.printf "继续处理条件判断测试完成\n"

(** 测试边界条件和异常情况 *)
let test_edge_cases () =
  Printf.printf "测试边界条件和异常情况...\n";
  
  let context = create_test_context () in
  
  (* 测试语义错误的恢复策略 *)
  let semantic_error = create_error_of_type "semantic" in
  let semantic_strategy = determine_recovery_strategy semantic_error.error_type in
  check (bool) "语义错误应使用SkipAndContinue策略" true
    (semantic_strategy = SkipAndContinue);
  
  (* 测试多次尝试恢复的情况 *)
  let base_error = create_error_of_type "parse" in
  let enhanced_multiple = create_enhanced_error ~recovery_strategy:SyncToNextStatement 
    ~attempt_count:3 base_error context in
  let multiple_result = attempt_recovery enhanced_multiple in
  check (bool) "多次尝试恢复应该仍然有效" true multiple_result;
  
  (* 测试带有相关错误的恢复 *)
  let related_error = create_enhanced_error base_error context in
  let main_enhanced = create_enhanced_error ~recovery_strategy:SkipAndContinue 
    ~related_errors:[related_error] base_error context in
  let related_result = attempt_recovery main_enhanced in
  check (bool) "带有相关错误的恢复应该成功" true related_result;
  
  Printf.printf "边界条件和异常情况测试完成\n"

(** 错误恢复模块测试套件 *)
let () =
  run "Error_handler_recovery模块测试" [
    ("确定恢复策略", [ test_case "基本恢复策略" `Quick test_determine_recovery_strategy ]);
    ("高级恢复策略", [ test_case "代码生成和运行时错误" `Quick test_advanced_recovery_strategies ]);
    ("恢复执行", [ test_case "错误恢复执行" `Quick test_attempt_recovery ]);
    ("统计更新", [ test_case "恢复统计更新" `Quick test_recovery_statistics ]);
    ("继续处理判断", [ test_case "继续处理条件" `Quick test_should_continue_processing ]);
    ("边界条件", [ test_case "边界和异常情况" `Quick test_edge_cases ]);
  ]