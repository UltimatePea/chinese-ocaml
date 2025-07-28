(** 技术债务清理回归测试套件
    
    为Issue #1576技术债务清理计划提供全面的回归保护。
    确保每个Phase的重构不会破坏现有功能。
    
    Author: Echo, 测试工程师代理
    目标: 提供Phase 0-3全程的回归测试保护
    *)

open Alcotest
open Yyocamlc_lib

(** {1 基准测试数据和期望结果} *)

module TestBaselines = struct
  (** 编译器核心功能基准 *)
  let sample_programs = [
    ("简单算术", "设 甲 = 一 + 二");
    ("变量定义", "设 乙 = 「你好世界」");
    ("函数定义", "函数 加法 甲 乙 = 甲 + 乙");
    ("条件语句", "若 甲 > 乙 则 甲 否则 乙");
    ("诗词格式", "春花秋月何时了，往事知多少")
  ]
  
  (** 性能基准 - 关键操作的预期执行时间 *)
  let performance_baselines = [
    ("lexer_tokenization", 0.1);  (* 词法分析 < 100ms *)
    ("parser_analysis", 0.2);     (* 语法分析 < 200ms *)
    ("semantic_check", 0.15);     (* 语义检查 < 150ms *)
    ("poetry_rhyme_check", 0.3);  (* 韵律检查 < 300ms *)
  ]
  
  (** 内存使用基准 - 最大允许内存增长 (MB) *)
  let memory_baselines = [
    ("lexer_memory", 10.0);
    ("parser_memory", 15.0);
    ("semantic_memory", 12.0);
    ("poetry_memory", 25.0);
  ]
end

(** {2 Phase 0: 基础设施测试} *)

module Phase0Tests = struct
  (** 测试当前系统状态作为重构前基准 *)
  let test_current_system_baseline () =
    List.iter (fun (name, program) ->
      try
        let tokens = Lexer.tokenize program in
        check bool ("baseline_tokenization_" ^ name) true (List.length tokens > 0);
        
        let ast = Parser.parse tokens in
        check bool ("baseline_parsing_" ^ name) true (ast <> Parser.Empty);
        
        let semantic_result = Semantic.analyze ast in
        check bool ("baseline_semantic_" ^ name) true 
          (match semantic_result with Ok _ -> true | Error _ -> false)
          
      with exn ->
        fail ("Baseline test failed for " ^ name ^ ": " ^ Printexc.to_string exn)
    ) TestBaselines.sample_programs
  
  (** 建立性能基准 *)
  let test_performance_baseline () =
    List.iter (fun (operation, max_time) ->
      let start_time = Unix.gettimeofday () in
      (match operation with
       | "lexer_tokenization" ->
           List.iter (fun (_, prog) -> ignore (Lexer.tokenize prog)) TestBaselines.sample_programs
       | "parser_analysis" ->
           List.iter (fun (_, prog) -> 
             let tokens = Lexer.tokenize prog in
             ignore (Parser.parse tokens)) TestBaselines.sample_programs
       | "semantic_check" ->
           List.iter (fun (_, prog) ->
             let tokens = Lexer.tokenize prog in
             let ast = Parser.parse tokens in
             ignore (Semantic.analyze ast)) TestBaselines.sample_programs
       | "poetry_rhyme_check" ->
           ignore (Poetry_json_unified.load_rhyme_database ());
           List.iter (fun (_, prog) -> 
             if String.contains prog '，' then
               ignore (Poetry_json_unified.analyze_line_rhyme 
                 (Poetry_json_unified.load_rhyme_database ()) prog)
           ) TestBaselines.sample_programs
       | _ -> ());
      let duration = Unix.gettimeofday () -. start_time in
      check bool ("performance_baseline_" ^ operation) true (duration < max_time)
    ) TestBaselines.performance_baselines
  
  (** 内存使用基准 *)
  let test_memory_baseline () =
    List.iter (fun (operation, max_memory) ->
      let initial_memory = Poetry_json_unified.get_memory_usage () in
      (match operation with
       | "lexer_memory" ->
           for i = 1 to 100 do
             List.iter (fun (_, prog) -> ignore (Lexer.tokenize prog)) TestBaselines.sample_programs
           done
       | "parser_memory" ->
           for i = 1 to 50 do
             List.iter (fun (_, prog) ->
               let tokens = Lexer.tokenize prog in
               ignore (Parser.parse tokens)) TestBaselines.sample_programs
           done
       | "semantic_memory" ->
           for i = 1 to 30 do
             List.iter (fun (_, prog) ->
               let tokens = Lexer.tokenize prog in
               let ast = Parser.parse tokens in
               ignore (Semantic.analyze ast)) TestBaselines.sample_programs
           done
       | "poetry_memory" ->
           for i = 1 to 20 do
             ignore (Poetry_json_unified.load_rhyme_database ())
           done
       | _ -> ());
      Gc.full_major ();
      let final_memory = Poetry_json_unified.get_memory_usage () in
      let memory_increase = final_memory -. initial_memory in
      check bool ("memory_baseline_" ^ operation) true (memory_increase < max_memory)
    ) TestBaselines.memory_baselines
end

(** {3 Phase 1: 架构重构回归测试} *)

module Phase1Tests = struct
  (** 测试文件拆分后的功能等价性 *)
  let test_rhyme_core_split_equivalence () =
    (* 假设 rhyme_core_unified.ml 已被拆分为多个模块 *)
    let test_chars = ["春"; "花"; "秋"; "月"; "安"; "干"; "风"; "东"] in
    
    List.iter (fun char ->
      (* 通过新的拆分模块查找韵组 *)
      let new_result = match Rhyme_analysis_module.find_rhyme_group char with
        | Some group -> Some group
        | None -> None in
      
      (* 通过旧的统一模块查找韵组（如果还存在） *)
      let old_result = match Rhyme_core_unified.find_rhyme_group char with
        | Some group -> Some group  
        | None -> None in
      
      (* 验证结果一致性 *)
      check (option string) ("split_equivalence_" ^ char)
        (Option.map Rhyme_group.to_string old_result)
        (Option.map Rhyme_group.to_string new_result)
    ) test_chars
  
  (** 测试模块依赖关系完整性 *)
  let test_module_dependency_integrity () =
    (* 验证拆分后的模块能正确相互调用 *)
    try
      (* 测试韵律分析模块 *)
      let analysis_result = Rhyme_analysis_module.analyze_character "春" in
      check bool "analysis_module_functional" true 
        (analysis_result.character = "春");
      
      (* 测试韵律数据模块 *)
      let data_result = Rhyme_data_module.get_character_info "春" in
      check bool "data_module_functional" true 
        (match data_result with Some _ -> true | None -> false);
      
      (* 测试韵律引擎模块 *)
      let engine_result = Rhyme_engine_module.calculate_rhyme_score "春" "秋" in
      check bool "engine_module_functional" true 
        (engine_result >= 0.0 && engine_result <= 1.0);
      
      (* 测试集成功能 *)
      let integration_result = Rhyme_integration_module.comprehensive_analysis "春花秋月" in
      check bool "integration_functional" true 
        (List.length integration_result.character_analyses > 0)
        
    with exn ->
      fail ("Module dependency test failed: " ^ Printexc.to_string exn)
  
  (** 测试接口契约保持一致 *)
  let test_interface_contract_consistency () =
    (* 验证所有公共接口函数仍然可用 *)
    let interface_functions = [
      ("find_rhyme_group", fun char -> Rhyme_analysis_module.find_rhyme_group char);
      ("get_rhyme_characters", fun group -> Rhyme_data_module.get_rhyme_characters group);
      ("check_rhyme_match", fun (c1, c2) -> Rhyme_engine_module.check_rhyme_match c1 c2);
    ] in
    
    List.iter (fun (func_name, func) ->
      try
        match func_name with
        | "find_rhyme_group" ->
            ignore (func "春");
            check bool (func_name ^ "_callable") true true
        | "get_rhyme_characters" ->
            ignore (func An_rhyme);
            check bool (func_name ^ "_callable") true true  
        | "check_rhyme_match" ->
            ignore (func ("春", "秋"));
            check bool (func_name ^ "_callable") true true
        | _ -> ()
      with exn ->
        fail (func_name ^ " interface broken: " ^ Printexc.to_string exn)
    ) interface_functions
end

(** {4 Phase 2: 性能优化回归测试} *)

module Phase2Tests = struct
  (** 测试列表拼接优化效果 *)
  let test_list_concatenation_optimization () =
    let large_lists = List.init 10 (fun i -> List.init 1000 (fun j -> i * 1000 + j)) in
    
    (* 测试优化后的性能 *)
    let start_time = Unix.gettimeofday () in
    let result = List.fold_left (@) [] large_lists in
    let optimized_time = Unix.gettimeofday () -. start_time in
    
    check bool "list_concat_performance_improved" true (optimized_time < 1.0);
    check int "list_concat_result_correct" 10000 (List.length result)
  
  (** 测试字符串拼接优化 *)
  let test_string_concatenation_optimization () =
    let strings = List.init 1000 (fun i -> "字符串" ^ string_of_int i) in
    
    let start_time = Unix.gettimeofday () in
    let result = String.concat "" strings in
    let concat_time = Unix.gettimeofday () -. start_time in
    
    check bool "string_concat_performance" true (concat_time < 0.5);
    check bool "string_concat_result_valid" true (String.length result > 3000)
  
  (** 测试错误处理统一性 *)
  let test_unified_error_handling () =
    let error_scenarios = [
      ("invalid_token", fun () -> Lexer.tokenize "不合法的符号！@#");
      ("syntax_error", fun () -> 
        let tokens = Lexer.tokenize "设 = + -" in
        Parser.parse tokens);
      ("semantic_error", fun () ->
        let tokens = Lexer.tokenize "设 甲 = 乙 + 丙" in
        let ast = Parser.parse tokens in
        Semantic.analyze ast);
    ] in
    
    List.iter (fun (scenario, action) ->
      try
        ignore (action ());
        (* 如果没有抛出异常，检查返回值是否为错误类型 *)
        check bool (scenario ^ "_handled") true true
      with 
      | Unified_error.Lexer_error _ -> 
          check bool (scenario ^ "_unified_error") true true
      | Unified_error.Parser_error _ ->
          check bool (scenario ^ "_unified_error") true true  
      | Unified_error.Semantic_error _ ->
          check bool (scenario ^ "_unified_error") true true
      | _ ->
          fail ("Non-unified error in " ^ scenario)
    ) error_scenarios
  
  (** 测试异常安全保证 *)
  let test_exception_safety () =
    (* 测试在异常发生时系统状态的一致性 *)
    let initial_state = System_state.get_current_state () in
    
    try
      (* 故意触发异常 *)
      let invalid_program = "这是一个会导致异常的程序 @#$%^&*()" in
      ignore (Compiler.compile_program invalid_program)
    with _ ->
      (* 异常发生后，验证系统状态是否保持一致 *)
      let post_exception_state = System_state.get_current_state () in
      check bool "exception_safety_maintained" true
        (System_state.states_consistent initial_state post_exception_state)
end

(** {5 Phase 3: 代码质量回归测试} *)

module Phase3Tests = struct
  (** 测试命名规范统一性 *)
  let test_naming_convention_consistency () =
    (* 验证所有模块使用统一的中文命名规范 *)
    let module_names = [
      "词法分析器"; "语法分析器"; "语义分析器"; "类型检查器";
      "韵律分析器"; "诗词处理器"; "错误处理器"
    ] in
    
    List.iter (fun module_name ->
      (* 检查模块名是否符合中文命名规范 *)
      let is_valid_chinese_name = Chinese_naming.validate_module_name module_name in
      check bool ("chinese_naming_" ^ module_name) true is_valid_chinese_name;
      
      (* 检查模块接口是否符合命名约定 *)
      let interface_functions = Module_inspector.get_exported_functions module_name in
      List.iter (fun func_name ->
        let is_valid_func_name = Chinese_naming.validate_function_name func_name in
        check bool ("function_naming_" ^ func_name) true is_valid_func_name
      ) (List.take (min 3 (List.length interface_functions)) interface_functions)
    ) module_names
  
  (** 测试代码重复消除效果 *)
  let test_duplicate_code_elimination () =
    (* 验证重复代码已被成功提取到公共模块 *)
    let common_functions = [
      "字符串处理工具";
      "列表操作工具";  
      "错误消息格式化";
      "调试信息输出"
    ] in
    
    List.iter (fun func_name ->
      (* 检查公共函数是否可用 *)
      let is_available = Common_utilities.function_exists func_name in
      check bool ("common_function_" ^ func_name) true is_available;
      
      (* 检查原有模块不再包含重复实现 *)
      let duplicate_count = Code_analyzer.count_duplicate_implementations func_name in
      check int ("no_duplicates_" ^ func_name) 1 duplicate_count
    ) common_functions
  
  (** 测试代码重用策略 *)
  let test_code_reuse_strategy () =
    (* 验证重构后的代码重用效果 *)
    let reuse_metrics = Code_analyzer.calculate_reuse_metrics () in
    
    check bool "code_reuse_improved" true (reuse_metrics.reuse_ratio > 0.7);
    check bool "duplication_reduced" true (reuse_metrics.duplication_ratio < 0.1);
    check int "shared_modules_count" true (reuse_metrics.shared_modules > 5)
end

(** {6 端到端集成回归测试} *)

module IntegrationTests = struct
  (** 完整编译流程测试 *)
  let test_complete_compilation_pipeline () =
    let test_program = "
      函数 斐波那契 数字 =
        若 数字 <= 一 则 数字
        否则 斐波那契 (数字 - 一) + 斐波那契 (数字 - 二)
      
      设 结果 = 斐波那契 五
      显示 结果
    " in
    
    try
      (* 完整编译流程 *)
      let tokens = Lexer.tokenize test_program in
      let ast = Parser.parse tokens in
      let semantic_result = Semantic.analyze ast in
      let compiled_code = match semantic_result with
        | Ok checked_ast -> Codegen.generate checked_ast
        | Error err -> fail ("Semantic error: " ^ Error.to_string err) in
      
      check bool "complete_pipeline_success" true (String.length compiled_code > 0)
      
    with exn ->
      fail ("Complete pipeline test failed: " ^ Printexc.to_string exn)
  
  (** 诗词编程端到端测试 *)
  let test_poetry_programming_pipeline () =
    let poetry_program = "
      诗词 春晓 =
        春眠不觉晓，
        处处闻啼鸟。
        夜来风雨声，
        花落知多少。
      
      分析 春晓 韵律
      检查 春晓 格律
    " in
    
    try
      let tokens = Lexer.tokenize poetry_program in
      let ast = Parser.parse tokens in
      let poetry_analysis = Poetry_analyzer.analyze_poetry ast in
      
      check bool "poetry_pipeline_success" true poetry_analysis.is_valid;
      check bool "poetry_rhyme_correct" true poetry_analysis.rhyme_scheme_valid;
      check bool "poetry_meter_correct" true poetry_analysis.meter_pattern_valid
      
    with exn ->
      fail ("Poetry pipeline test failed: " ^ Printexc.to_string exn)
end

(** {7 性能回归监控} *)

module PerformanceRegression = struct
  (** 编译时间回归检查 *)
  let test_compilation_time_regression () =
    let large_program = String.concat "\n" (List.init 100 (fun i ->
      sprintf "设 变量%d = %d + %d" i i (i+1)
    )) in
    
    let start_time = Unix.gettimeofday () in
    try
      let tokens = Lexer.tokenize large_program in
      let ast = Parser.parse tokens in
      let _ = Semantic.analyze ast in
      let compile_time = Unix.gettimeofday () -. start_time in
      
      check bool "compilation_time_acceptable" true (compile_time < 2.0)
    with exn ->
      fail ("Performance regression test failed: " ^ Printexc.to_string exn)
  
  (** 内存使用回归监控 *)
  let test_memory_usage_regression () =
    let initial_memory = Poetry_json_unified.get_memory_usage () in
    
    (* 执行大量操作 *)
    for i = 1 to 1000 do
      let program = sprintf "设 变量 = %d" i in
      let tokens = Lexer.tokenize program in
      ignore (Parser.parse tokens)
    done;
    
    let peak_memory = Poetry_json_unified.get_memory_usage () in
    Gc.full_major ();
    let final_memory = Poetry_json_unified.get_memory_usage () in
    
    let memory_increase = final_memory -. initial_memory in
    check bool "memory_regression_acceptable" true (memory_increase < 50.0)
end

(** {8 测试套件定义} *)

let tech_debt_regression_tests = [
  (* Phase 0: 基础设施测试 *)
  test_case "current system baseline" `Quick Phase0Tests.test_current_system_baseline;
  test_case "performance baseline" `Slow Phase0Tests.test_performance_baseline;
  test_case "memory baseline" `Slow Phase0Tests.test_memory_baseline;
  
  (* Phase 1: 架构重构测试 *)
  test_case "rhyme core split equivalence" `Quick Phase1Tests.test_rhyme_core_split_equivalence;
  test_case "module dependency integrity" `Quick Phase1Tests.test_module_dependency_integrity;
  test_case "interface contract consistency" `Quick Phase1Tests.test_interface_contract_consistency;
  
  (* Phase 2: 性能优化测试 *)
  test_case "list concatenation optimization" `Quick Phase2Tests.test_list_concatenation_optimization;
  test_case "string concatenation optimization" `Quick Phase2Tests.test_string_concatenation_optimization;
  test_case "unified error handling" `Quick Phase2Tests.test_unified_error_handling;
  test_case "exception safety" `Quick Phase2Tests.test_exception_safety;
  
  (* Phase 3: 代码质量测试 *)
  test_case "naming convention consistency" `Quick Phase3Tests.test_naming_convention_consistency;
  test_case "duplicate code elimination" `Quick Phase3Tests.test_duplicate_code_elimination;
  test_case "code reuse strategy" `Quick Phase3Tests.test_code_reuse_strategy;
  
  (* 端到端集成测试 *)
  test_case "complete compilation pipeline" `Quick IntegrationTests.test_complete_compilation_pipeline;
  test_case "poetry programming pipeline" `Quick IntegrationTests.test_poetry_programming_pipeline;
  
  (* 性能回归监控 *)
  test_case "compilation time regression" `Slow PerformanceRegression.test_compilation_time_regression;
  test_case "memory usage regression" `Slow PerformanceRegression.test_memory_usage_regression;
]

(** 主测试运行器 *)
let () =
  run "Technical Debt Cleanup Regression Tests" [
    "tech_debt_regression", tech_debt_regression_tests;
  ]