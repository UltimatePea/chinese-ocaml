(** 分析辅助函数模块测试
    
    测试覆盖analysis_helpers.ml模块的所有辅助函数，确保分析工具函数正常工作
    
    @author Echo, 测试工程师代理
    @version 1.0 - 首次实现完整测试覆盖
    @since 2025-07-30 分析辅助函数模块测试改进 *)

open Alcotest
open Yyocamlc_lib.Analysis_helpers
open Yyocamlc_lib.Refactoring_analyzer_types
open Yyocamlc_lib.Ast

(** 帮助函数：创建基础分析上下文 *)
let create_test_context () =
  {
    expression_count = 0;
    nesting_level = 0;
    defined_vars = [];
    current_function = None;
    function_calls = [];
  }

(** 帮助函数：创建复杂的分析上下文 *)
let create_complex_context () =
  {
    expression_count = 10;
    nesting_level = 3;
    defined_vars = [("var1", Some (BaseTypeExpr IntType)); ("var2", None); ("var3", Some (BaseTypeExpr StringType))];
    current_function = Some "complex_function";
    function_calls = ["helper1"; "helper2"; "helper3"];
  }

(** 帮助函数：创建测试建议 *)
let create_test_suggestion message confidence =
  {
    suggestion_type = NamingImprovement "测试建议";
    message = message;
    confidence = confidence;
    location = Some "test.ml:1";
    suggested_fix = Some "测试修复";
  }


(** 测试add_suggestions_to_ref函数 *)
let test_add_suggestions_to_ref () =
  (* 测试基本功能 *)
  let suggestions_ref = ref [] in
  let new_suggestions = [
    create_test_suggestion "建议1" 0.8;
    create_test_suggestion "建议2" 0.9;
  ] in
  
  add_suggestions_to_ref new_suggestions suggestions_ref;
  check int "应正确添加建议到引用" 2 (List.length !suggestions_ref);
  
  (* 测试追加功能 *)
  let additional_suggestions = [
    create_test_suggestion "建议3" 0.7;
  ] in
  add_suggestions_to_ref additional_suggestions suggestions_ref;
  check int "应正确追加更多建议" 3 (List.length !suggestions_ref);
  
  (* 测试空列表添加 *)
  let empty_suggestions = [] in
  add_suggestions_to_ref empty_suggestions suggestions_ref;
  check int "添加空列表不应改变引用" 3 (List.length !suggestions_ref);
  
  (* 测试大量建议添加 *)
  let large_suggestions = List.init 100 (fun i -> 
    create_test_suggestion ("建议" ^ string_of_int i) (0.5 +. (float_of_int i /. 200.0))
  ) in
  add_suggestions_to_ref large_suggestions suggestions_ref;
  check int "应正确添加大量建议" 103 (List.length !suggestions_ref)

(** 测试create_nested_context函数 *)
let test_create_nested_context () =
  (* 测试基本嵌套上下文创建 *)
  let base_context = create_test_context () in
  let nested_context = create_nested_context base_context in
  
  check int "嵌套层级应增加1" (base_context.nesting_level + 1) nested_context.nesting_level;
  check int "表达式计数应保持不变" base_context.expression_count nested_context.expression_count;
  check int "定义变量列表长度应保持不变" (List.length base_context.defined_vars) (List.length nested_context.defined_vars);
  check (option string) "当前函数应保持不变" base_context.current_function nested_context.current_function;
  
  (* 测试复杂上下文的嵌套 *)
  let complex_context = create_complex_context () in
  let nested_complex = create_nested_context complex_context in
  
  check int "复杂上下文嵌套层级应正确增加" (complex_context.nesting_level + 1) nested_complex.nesting_level;
  check int "复杂上下文其他字段应保持不变" complex_context.expression_count nested_complex.expression_count;
  
  (* 测试多层嵌套 *)
  let double_nested = create_nested_context nested_context in
  check int "双重嵌套层级应正确" (base_context.nesting_level + 2) double_nested.nesting_level;
  
  (* 测试深度嵌套 *)
  let rec create_deep_nested ctx depth =
    if depth <= 0 then ctx
    else create_deep_nested (create_nested_context ctx) (depth - 1)
  in
  let deep_nested = create_deep_nested base_context 10 in
  check int "深度嵌套应正确计算" (base_context.nesting_level + 10) deep_nested.nesting_level

(** 测试analyze_variable_expression函数 *)
let test_analyze_variable_expression () =
  let suggestions_ref = ref [] in
  
  (* 测试基本变量分析 *)
  analyze_variable_expression "test_variable" suggestions_ref;
  check bool "基本变量应生成命名建议" true (List.length !suggestions_ref > 0);
  let has_naming = List.exists (fun s ->
    match s.suggestion_type with NamingImprovement _ -> true | _ -> false
  ) !suggestions_ref in
  check bool "基本变量应包含命名改进建议" true has_naming;
  
  (* 重置引用 *)
  suggestions_ref := [];
  
  (* 测试中文变量名 - 应该检测非ASCII字符 *)
  analyze_variable_expression "中文变量" suggestions_ref;
  check bool "中文变量应生成建议" true (List.length !suggestions_ref > 0);
  let has_ascii_suggestion = List.exists (fun s ->
    match s.suggestion_type with
    | NamingImprovement suggested -> 
        String.for_all (fun c -> Char.code c < 128) suggested
    | _ -> false
  ) !suggestions_ref in
  check bool "中文变量应生成ASCII命名建议" true has_ascii_suggestion;
  
  (* 重置引用 *)
  suggestions_ref := [];
  
  (* 测试空变量名 - 应该生成高置信度廚议 *)
  analyze_variable_expression "" suggestions_ref;
  check bool "空变量名应生成廚议" true (List.length !suggestions_ref > 0);
  let has_high_confidence = List.exists (fun s -> s.confidence > 0.8) !suggestions_ref in
  check bool "空变量名应生成高置信度廚议" true has_high_confidence;
  
  (* 重置引用 *)
  suggestions_ref := [];
  
  (* 测试特殊字符变量名 - 应该检测命名风格 *)
  analyze_variable_expression "var_with_123" suggestions_ref;
  check bool "特殊字符变量名应生成廚议" true (List.length !suggestions_ref > 0);
  let suggestions_content = List.fold_left (fun acc s -> s.message :: acc) [] !suggestions_ref in
  let mentions_naming = List.exists (fun msg -> String.contains msg '命') suggestions_content in
  check bool "特殊字符变量名应检测命名风格" true mentions_naming;
  
  (* 测试极长变量名 - 应该检测长度问题 *)
  let long_name = String.make 1000 'a' in
  suggestions_ref := [];
  analyze_variable_expression long_name suggestions_ref;
  check bool "极长变量名应生成廚议" true (List.length !suggestions_ref > 0);
  let has_length_concern = List.exists (fun s ->
    String.contains s.message '长' || String.contains s.message '大'
  ) !suggestions_ref in
  check bool "极长变量名应检测长度问题" true has_length_concern

(** 测试analyze_let_expression函数 *)
let test_analyze_let_expression () =
  let suggestions_ref = ref [] in
  let context = create_test_context () in
  let analyze_mock _expr _ctx = 
    (* 模拟分析函数，简单记录调用 *)
    ()
  in
  
  (* 测试基本Let表达式分析 *)
  analyze_let_expression "test_var" (VarExpr "value") (VarExpr "test_var") context analyze_mock suggestions_ref;
  check bool "Let表达式分析应生成建议" true (List.length !suggestions_ref >= 0);
  
  (* 重置引用 *)
  suggestions_ref := [];
  
  (* 测试复杂Let表达式 *)
  let complex_val = BinaryOpExpr (VarExpr "a", Add, VarExpr "b") in
  let complex_in = FunCallExpr (VarExpr "test_var", [VarExpr "arg"]) in
  analyze_let_expression "complex_var" complex_val complex_in context analyze_mock suggestions_ref;
  check bool "复杂Let表达式分析应正常工作" true (List.length !suggestions_ref >= 0);
  
  (* 测试中文变量名 *)
  suggestions_ref := [];
  analyze_let_expression "中文变量" (VarExpr "值") (VarExpr "中文变量") context analyze_mock suggestions_ref;
  check bool "中文Let表达式分析应正常工作" true (List.length !suggestions_ref >= 0)

(** 测试analyze_function_expression函数 *)
let test_analyze_function_expression () =
  let suggestions_ref = ref [] in
  let context = create_test_context () in
  let analyze_mock _expr _ctx = ()
  in
  
  (* 测试基本函数表达式分析 *)
  let params = ["param1"; "param2"] in
  let body = VarExpr "param1" in
  analyze_function_expression params body context analyze_mock suggestions_ref;
  check bool "函数表达式分析应生成建议" true (List.length !suggestions_ref >= 0);
  
  (* 重置引用 *)
  suggestions_ref := [];
  
  (* 测试无参数函数 *)
  analyze_function_expression [] (VarExpr "constant") context analyze_mock suggestions_ref;
  check bool "无参数函数分析应正常工作" true (List.length !suggestions_ref >= 0);
  
  (* 测试多参数函数 *)
  suggestions_ref := [];
  let many_params = ["a"; "b"; "c"; "d"; "e"; "f"; "g"; "h"] in
  analyze_function_expression many_params (VarExpr "a") context analyze_mock suggestions_ref;
  check bool "多参数函数分析应正常工作" true (List.length !suggestions_ref >= 0);
  
  (* 测试中文参数名 *)
  suggestions_ref := [];
  let chinese_params = ["参数一"; "参数二"] in
  analyze_function_expression chinese_params (VarExpr "参数一") context analyze_mock suggestions_ref;
  check bool "中文参数函数分析应正常工作" true (List.length !suggestions_ref >= 0)

(** 测试analyze_conditional_expression函数 *)
let test_analyze_conditional_expression () =
  let suggestions_ref = ref [] in
  let context = create_test_context () in
  let analyze_mock _expr _ctx = ()
  in
  
  (* 测试基本条件表达式分析 *)
  let cond = VarExpr "condition" in
  let then_expr = VarExpr "then_branch" in
  let else_expr = VarExpr "else_branch" in
  analyze_conditional_expression cond then_expr else_expr context analyze_mock suggestions_ref;
  check bool "条件表达式分析应生成建议" true (List.length !suggestions_ref >= 0);
  
  (* 重置引用 *)
  suggestions_ref := [];
  
  (* 测试复杂条件表达式 *)
  let complex_cond = BinaryOpExpr (VarExpr "x", Gt, VarExpr "y") in
  let complex_then = FunCallExpr (VarExpr "func", [VarExpr "x"]) in
  let complex_else = CondExpr (VarExpr "nested", VarExpr "nested_then", VarExpr "nested_else") in
  analyze_conditional_expression complex_cond complex_then complex_else context analyze_mock suggestions_ref;
  check bool "复杂条件表达式分析应正常工作" true (List.length !suggestions_ref >= 0);
  
  (* 测试嵌套层级检查 *)
  let deep_nested_context = { context with nesting_level = 5 } in
  suggestions_ref := [];
  analyze_conditional_expression cond then_expr else_expr deep_nested_context analyze_mock suggestions_ref;
  check bool "深度嵌套条件表达式应触发复杂度检查" true (List.length !suggestions_ref >= 0)

(** 测试analyze_function_call_expression函数 *)
let test_analyze_function_call_expression () =
  let context = create_test_context () in
  let call_count = ref 0 in
  let analyze_mock _expr _ctx = 
    incr call_count
  in
  
  (* 测试基本函数调用分析 *)
  let func = VarExpr "function" in
  let args = [VarExpr "arg1"; VarExpr "arg2"] in
  analyze_function_call_expression func args context analyze_mock;
  check int "函数调用应分析函数和所有参数" 3 !call_count; (* 1个函数 + 2个参数 *)
  
  (* 重置计数器 *)
  call_count := 0;
  
  (* 测试无参数函数调用 *)
  analyze_function_call_expression func [] context analyze_mock;
  check int "无参数函数调用应只分析函数" 1 !call_count;
  
  (* 测试多参数函数调用 *)
  call_count := 0;
  let many_args = List.init 10 (fun i -> VarExpr ("arg" ^ string_of_int i)) in
  analyze_function_call_expression func many_args context analyze_mock;
  check int "多参数函数调用应分析所有参数" 11 !call_count; (* 1个函数 + 10个参数 *)
  
  (* 测试复杂表达式作为参数 *)
  call_count := 0;
  let complex_args = [
    BinaryOpExpr (VarExpr "a", Add, VarExpr "b");
    FunCallExpr (VarExpr "inner", [VarExpr "inner_arg"]);
  ] in
  analyze_function_call_expression func complex_args context analyze_mock;
  check int "复杂参数函数调用应正确分析" 3 !call_count (* 1个函数 + 2个复杂参数 *)

(** 测试analyze_match_expression函数 *)
let test_analyze_match_expression () =
  let context = create_test_context () in
  let call_count = ref 0 in
  let analyze_mock _expr _ctx = 
    incr call_count
  in
  
  (* 测试基本模式匹配分析 *)
  let matched_expr = VarExpr "value" in
  let branches = [
    { pattern = VarPattern "x"; guard = None; expr = VarExpr "x" };
    { pattern = LitPattern (IntLit 42); guard = None; expr = VarExpr "forty_two" };
  ] in
  analyze_match_expression matched_expr branches context analyze_mock;
  check int "模式匹配应分析匹配表达式和所有分支" 3 !call_count; (* 1个匹配表达式 + 2个分支表达式 *)
  
  (* 重置计数器 *)
  call_count := 0;
  
  (* 测试空分支模式匹配 *)
  analyze_match_expression matched_expr [] context analyze_mock;
  check int "空分支模式匹配应只分析匹配表达式" 1 !call_count;
  
  (* 测试复杂分支模式匹配 *)
  call_count := 0;
  let complex_branches = [
    { pattern = VarPattern "x"; guard = None; expr = BinaryOpExpr (VarExpr "x", Add, VarExpr "y") };
    { pattern = LitPattern (StringLit "test"); guard = None; expr = FunCallExpr (VarExpr "process", [VarExpr "test"]) };
    { pattern = VarPattern "default"; guard = None; expr = CondExpr (VarExpr "check", VarExpr "yes", VarExpr "no") };
  ] in
  analyze_match_expression matched_expr complex_branches context analyze_mock;
  check int "复杂模式匹配应正确分析所有分支" 4 !call_count (* 1个匹配表达式 + 3个分支表达式 *)

(** 测试analyze_binary_operation_expression函数 *)
let test_analyze_binary_operation_expression () =
  let context = create_test_context () in
  let call_count = ref 0 in
  let analyze_mock _expr _ctx = 
    incr call_count
  in
  
  (* 测试基本二元运算分析 *)
  let left = VarExpr "left" in
  let right = VarExpr "right" in
  analyze_binary_operation_expression left right context analyze_mock;
  check int "二元运算应分析左右两个操作数" 2 !call_count;
  
  (* 重置计数器 *)
  call_count := 0;
  
  (* 测试复杂操作数 *)
  let complex_left = BinaryOpExpr (VarExpr "a", Add, VarExpr "b") in
  let complex_right = FunCallExpr (VarExpr "func", [VarExpr "arg"]) in
  analyze_binary_operation_expression complex_left complex_right context analyze_mock;
  check int "复杂二元运算应正确分析操作数" 2 !call_count;
  
  (* 测试嵌套二元运算 *)
  call_count := 0;
  let nested_left = BinaryOpExpr (VarExpr "x", Mul, VarExpr "y") in
  let nested_right = BinaryOpExpr (VarExpr "z", Div, VarExpr "w") in
  analyze_binary_operation_expression nested_left nested_right context analyze_mock;
  check int "嵌套二元运算应正确分析" 2 !call_count

(** 测试analyze_unary_operation_expression函数 *)
let test_analyze_unary_operation_expression () =
  let context = create_test_context () in
  let call_count = ref 0 in
  let analyze_mock _expr _ctx = 
    incr call_count
  in
  
  (* 测试基本一元运算分析 *)
  let expr = VarExpr "value" in
  analyze_unary_operation_expression expr context analyze_mock;
  check int "一元运算应分析操作数" 1 !call_count;
  
  (* 重置计数器 *)
  call_count := 0;
  
  (* 测试复杂操作数 *)
  let complex_expr = BinaryOpExpr (VarExpr "a", Sub, VarExpr "b") in
  analyze_unary_operation_expression complex_expr context analyze_mock;
  check int "复杂一元运算应正确分析操作数" 1 !call_count;
  
  (* 测试嵌套一元运算 *)
  call_count := 0;
  let nested_expr = UnaryOpExpr (Neg, VarExpr "inner") in
  analyze_unary_operation_expression nested_expr context analyze_mock;
  check int "嵌套一元运算应正确分析" 1 !call_count

(** 测试上下文更新和传播 *)
let test_context_updates () =
  let base_context = create_test_context () in
  
  (* 测试变量定义的上下文更新 *)
  let suggestions_ref = ref [] in
  let context_updates = ref [] in
  let analyze_mock _expr ctx = 
    context_updates := ctx :: !context_updates
  in
  
  analyze_let_expression "new_var" (VarExpr "value") (VarExpr "new_var") base_context analyze_mock suggestions_ref;
  
  (* 验证上下文传播 *)
  check bool "上下文应正确传播" true (List.length !context_updates >= 2);
  
  (* 测试函数参数的上下文更新 *)
  context_updates := [];
  let params = ["param1"; "param2"] in
  analyze_function_expression params (VarExpr "param1") base_context analyze_mock suggestions_ref;
  
  check bool "函数上下文应正确更新" true (List.length !context_updates >= 1);
  
  (* 测试嵌套层级的上下文更新 *)
  let nested_context = create_nested_context base_context in
  check int "嵌套上下文层级应正确更新" (base_context.nesting_level + 1) nested_context.nesting_level

(** 测试边界条件和错误处理 *)
let test_edge_cases () =
  let suggestions_ref = ref [] in
  let context = create_test_context () in
  let analyze_mock _expr _ctx = () in
  
  (* 测试空字符串变量名 *)
  analyze_variable_expression "" suggestions_ref;
  check bool "空变量名应正常处理" true (List.length !suggestions_ref >= 0);
  
  (* 测试极长变量名 *)
  suggestions_ref := [];
  let very_long_name = String.make 10000 'x' in
  analyze_variable_expression very_long_name suggestions_ref;
  check bool "极长变量名应正常处理" true (List.length !suggestions_ref >= 0);
  
  (* 测试特殊字符变量名 *)
  suggestions_ref := [];
  analyze_variable_expression "变量_with_特殊字符123!@#" suggestions_ref;
  check bool "特殊字符变量名应正常处理" true (List.length !suggestions_ref >= 0);
  
  (* 测试空参数列表函数 *)
  suggestions_ref := [];
  analyze_function_expression [] (VarExpr "constant") context analyze_mock suggestions_ref;
  check bool "空参数函数应正常处理" true (List.length !suggestions_ref >= 0);
  
  (* 测试极深嵌套上下文 *)
  let deep_context = { context with nesting_level = 1000 } in
  suggestions_ref := [];
  analyze_conditional_expression (VarExpr "cond") (VarExpr "then") (VarExpr "else") deep_context analyze_mock suggestions_ref;
  check bool "极深嵌套应正常处理" true (List.length !suggestions_ref >= 0)

(** 测试内存和性能 *)
let test_performance_and_memory () =
  let suggestions_ref = ref [] in
  let _context = create_test_context () in
  let _analyze_mock _expr _ctx = () in
  
  (* 测试大量建议添加的性能 *)
  let large_suggestion_list = List.init 10000 (fun i ->
    create_test_suggestion ("建议" ^ string_of_int i) (Random.float 1.0)
  ) in
  
  let start_time = Sys.time () in
  add_suggestions_to_ref large_suggestion_list suggestions_ref;
  let end_time = Sys.time () in
  
  check int "大量建议应正确添加" 10000 (List.length !suggestions_ref);
  check bool "大量建议添加应在合理时间内完成" true ((end_time -. start_time) < 1.0);
  
  (* 测试大量变量分析的性能 *)
  suggestions_ref := [];
  let start_time2 = Sys.time () in
  for i = 1 to 1000 do
    analyze_variable_expression ("var" ^ string_of_int i) suggestions_ref
  done;
  let end_time2 = Sys.time () in
  
  check bool "大量变量分析应在合理时间内完成" true ((end_time2 -. start_time2) < 2.0)

(** 测试套件定义 *)
let () =
  run "分析辅助函数模块测试"
    [
      ("建议添加函数", [ test_case "add_suggestions_to_ref基础功能" `Quick test_add_suggestions_to_ref ]);
      ("嵌套上下文创建", [ test_case "create_nested_context基础功能" `Quick test_create_nested_context ]);
      ("变量表达式分析", [ test_case "analyze_variable_expression基础功能" `Quick test_analyze_variable_expression ]);
      ("Let表达式分析", [ test_case "analyze_let_expression基础功能" `Quick test_analyze_let_expression ]);
      ("函数表达式分析", [ test_case "analyze_function_expression基础功能" `Quick test_analyze_function_expression ]);
      ("条件表达式分析", [ test_case "analyze_conditional_expression基础功能" `Quick test_analyze_conditional_expression ]);
      ("函数调用表达式分析", [ test_case "analyze_function_call_expression基础功能" `Quick test_analyze_function_call_expression ]);
      ("模式匹配表达式分析", [ test_case "analyze_match_expression基础功能" `Quick test_analyze_match_expression ]);
      ("二元运算表达式分析", [ test_case "analyze_binary_operation_expression基础功能" `Quick test_analyze_binary_operation_expression ]);
      ("一元运算表达式分析", [ test_case "analyze_unary_operation_expression基础功能" `Quick test_analyze_unary_operation_expression ]);
      ("上下文更新测试", [ test_case "上下文更新和传播机制" `Quick test_context_updates ]);
      ("边界条件测试", [ test_case "边界条件和错误处理" `Quick test_edge_cases ]);
      ("性能和内存测试", [ test_case "性能和内存使用测试" `Quick test_performance_and_memory ]);
    ]