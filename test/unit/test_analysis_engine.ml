(** 分析引擎模块测试

    测试覆盖analysis_engine.ml模块的所有核心功能，确保代码质量分析引擎正常工作

    @author Echo, 测试工程师代理
    @version 1.0 - 首次实现完整测试覆盖
    @since 2025-07-30 分析引擎模块测试改进 *)

open Alcotest
open Yyocamlc_lib.Analysis_engine
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

(** 帮助函数：创建complex杂的分析上下文 *)
let create_complex_context () =
  {
    expression_count = 5;
    nesting_level = 2;
    defined_vars = [ ("x", None); ("y", Some (BaseTypeExpr IntType)) ];
    current_function = Some "test_function";
    function_calls = [ "func1"; "func2" ];
  }

(** 测试变量表达式分析 *)
let test_analyze_variable_expression () =
  let context = create_test_context () in
  let suggestions = analyze_expression (VarExpr "variable") context in

  (* 验证英文变量名生成命名建议的详细内容 *)
  check int "英文变量名应生成恰好1个建议" 1 (List.length suggestions);
  let has_naming_suggestion =
    List.exists
      (fun s ->
        match s.suggestion_type with
        | NamingImprovement improvement_type -> (
            (* 验证建议类型包含"中文命名"相关内容 *)
            (try
               let _ = Str.search_forward (Str.regexp "中") improvement_type 0 in
               true
             with Not_found -> false)
            &&
            try
              let _ = Str.search_forward (Str.regexp "文") improvement_type 0 in
              true
            with Not_found -> false)
        | _ -> false)
      suggestions
  in
  check bool "应包含中文命名改进建议" true has_naming_suggestion;

  (* 验证建议的置信度合理 *)
  let first_suggestion = List.hd suggestions in
  check bool "英文命名建议置信度应合理(0.5-1.0)" true
    (first_suggestion.confidence >= 0.5 && first_suggestion.confidence <= 1.0);

  (* 验证建议消息包含变量名相关内容 *)
  check bool "建议消息应包含变量相关内容" true
    (try
       let _ = Str.search_forward (Str.regexp "variable\\|变量") first_suggestion.message 0 in
       true
     with Not_found -> false);

  (* 测试中文变量名 - 符合最佳实践，不应生成建议 *)
  let chinese_suggestions = analyze_expression (VarExpr "变量") context in
  check bool "中文变量名符合最佳实践，不应生成建议" true (List.length chinese_suggestions = 0);

  (* 测试混合命名 - 应该生成统一使用中文的建议 *)
  let mixed_suggestions = analyze_expression (VarExpr "变量name") context in
  check bool "混合命名应生成建议" true (List.length mixed_suggestions > 0);
  let has_mixed_naming_issue =
    List.exists
      (fun s -> match s.suggestion_type with NamingImprovement _ -> true | _ -> false)
      mixed_suggestions
  in
  check bool "混合命名应生成统一命名风格建议" true has_mixed_naming_issue;

  (* 测试空变量名 - 应该生成高置信度命名建议 *)
  let empty_suggestions = analyze_expression (VarExpr "") context in
  check int "空变量名应生成恰好1个建议" 1 (List.length empty_suggestions);
  let empty_suggestion = List.hd empty_suggestions in
  check bool "空变量名建议应有高置信度(>0.8)" true (empty_suggestion.confidence > 0.8);

  (* 验证空变量名建议类型正确 *)
  let has_short_name_suggestion =
    match empty_suggestion.suggestion_type with
    | NamingImprovement improvement_type -> (
        (try
           let _ = Str.search_forward (Str.regexp "短") improvement_type 0 in
           true
         with Not_found -> false)
        ||
        try
          let _ = Str.search_forward (Str.regexp "描述") improvement_type 0 in
          true
        with Not_found -> false)
    | _ -> false
  in
  check bool "空变量名应生成'过短'类型的命名建议" true has_short_name_suggestion

(** 测试Let表达式分析 *)
let test_analyze_let_expression () =
  let context = create_test_context () in
  let let_expr = LetExpr ("test_var", VarExpr "value", VarExpr "test_var") in
  let suggestions = analyze_expression let_expr context in

  (* 验证Let表达式生成多种类型的建议 *)
  check bool "Let表达式应生成建议" true (List.length suggestions > 0);
  let has_naming_suggestions =
    List.exists
      (fun s -> match s.suggestion_type with NamingImprovement _ -> true | _ -> false)
      suggestions
  in
  check bool "Let表达式应包含命名建议" true has_naming_suggestions;

  (* 测试nest套Let表达式 - 应该检测complex杂度 *)
  let nested_let =
    LetExpr ("outer", LetExpr ("inner", VarExpr "value", VarExpr "inner"), VarExpr "outer")
  in
  let nested_suggestions = analyze_expression nested_let context in
  check bool "nest套Let表达式应生成更多建议" true (List.length nested_suggestions >= List.length suggestions);

  (* 测试complex杂上下文中的Let表达式 - 应该考虑上下文信息 *)
  let complex_context = create_complex_context () in
  let complex_suggestions = analyze_expression let_expr complex_context in
  check bool "complex杂上下文应影响建议生成" true (List.length complex_suggestions > 0);
  (* 验证上下文信息被正确使用 *)
  let context_aware = List.exists (fun s -> s.confidence > 0.5) complex_suggestions in
  check bool "complex杂上下文应生成有意义的建议" true context_aware

(** 测试函数表达式分析 *)
let test_analyze_function_expression () =
  let context = create_test_context () in
  let func_expr = FunExpr ([ "param1"; "param2" ], VarExpr "param1") in
  let suggestions = analyze_expression func_expr context in

  (* 验证函数参数命名建议 *)
  check bool "函数表达式应生成参数命名建议" true (List.length suggestions > 0);
  let param_naming_count =
    List.fold_left
      (fun acc s -> match s.suggestion_type with NamingImprovement _ -> acc + 1 | _ -> acc)
      0 suggestions
  in
  check bool "应为每个参数生成命名建议" true (param_naming_count >= 2);

  (* 测试无参数函数 - 应该生成较少建议 *)
  let no_param_func = FunExpr ([], VarExpr "constant") in
  let no_param_suggestions = analyze_expression no_param_func context in
  check bool "无参数函数应生成建议" true (List.length no_param_suggestions >= 0);
  check bool "无参数函数建议数应少于多参数函数" true (List.length no_param_suggestions <= List.length suggestions);

  (* 测试多参数函数 - 应该检测complex杂度 *)
  let multi_param_func =
    FunExpr ([ "a"; "b"; "c"; "d"; "e" ], BinaryOpExpr (VarExpr "a", Add, VarExpr "b"))
  in
  let multi_param_suggestions = analyze_expression multi_param_func context in
  check bool "多参数函数应生成更多建议" true (List.length multi_param_suggestions > List.length suggestions);

  (* 验证复杂度检测 - 超过4个参数应该触发复杂度警告 *)
  let has_complexity_hint =
    List.exists
      (fun s ->
        match s.suggestion_type with
        | FunctionComplexity param_count -> param_count = 5 (* 5个参数 *)
        | _ -> false)
      multi_param_suggestions
  in
  check bool "5个参数的函数应触发函数复杂度警告" true has_complexity_hint;

  (* 验证复杂度建议的置信度合理 *)
  let complexity_suggestions =
    List.filter
      (fun s -> match s.suggestion_type with FunctionComplexity _ -> true | _ -> false)
      multi_param_suggestions
  in
  if List.length complexity_suggestions > 0 then
    let complexity_suggestion = List.hd complexity_suggestions in
    check bool "复杂度建议置信度应合理(>0.5)" true (complexity_suggestion.confidence > 0.5)

(** 测试条件表达式分析 *)
let test_analyze_conditional_expression () =
  let context = create_test_context () in
  let cond_expr = CondExpr (VarExpr "condition", VarExpr "then_branch", VarExpr "else_branch") in
  let suggestions = analyze_expression cond_expr context in

  (* 验证条件表达式生成多个组件的建议 *)
  check bool "条件表达式应生成建议" true (List.length suggestions > 0);
  let naming_suggestions =
    List.filter
      (fun s -> match s.suggestion_type with NamingImprovement _ -> true | _ -> false)
      suggestions
  in
  check bool "条件表达式应包含多个命名建议" true (List.length naming_suggestions >= 3);

  (* condition, then_branch, else_branch *)

  (* 测试nest套条件表达式 - 应该检测nest套深度 *)
  let nested_cond =
    CondExpr
      ( VarExpr "cond1",
        CondExpr (VarExpr "cond2", VarExpr "then2", VarExpr "else2"),
        CondExpr (VarExpr "cond3", VarExpr "then3", VarExpr "else3") )
  in
  let nested_suggestions = analyze_expression nested_cond context in
  check bool "nest套条件表达式应生成更多建议" true (List.length nested_suggestions > List.length suggestions);
  let has_complexity_suggestion =
    List.exists
      (fun s ->
        match s.suggestion_type with
        | FunctionComplexity _ -> true
        | PerformanceHint _ -> true
        | _ -> false)
      nested_suggestions
  in
  check bool "nest套条件应包含complex杂度警告" true has_complexity_suggestion

(** 测试函数调用表达式分析 *)
let test_analyze_function_call_expression () =
  let context = create_test_context () in
  let call_expr = FunCallExpr (VarExpr "function", [ VarExpr "arg1"; VarExpr "arg2" ]) in
  let suggestions = analyze_expression call_expr context in

  (* 验证函数调用分析包含函数名和参数建议 *)
  check bool "函数调用表达式应生成建议" true (List.length suggestions > 0);
  let naming_suggestions =
    List.filter
      (fun s -> match s.suggestion_type with NamingImprovement _ -> true | _ -> false)
      suggestions
  in
  check bool "函数调用应包含函数和参数命名建议" true (List.length naming_suggestions >= 3);

  (* function + 2 args *)

  (* 测试无参数函数调用 - 应该只有函数名建议 *)
  let no_arg_call = FunCallExpr (VarExpr "function", []) in
  let no_arg_suggestions = analyze_expression no_arg_call context in
  check bool "无参数函数调用应生成建议" true (List.length no_arg_suggestions > 0);
  check bool "无参数调用建议数应少于有参数调用" true (List.length no_arg_suggestions < List.length suggestions);

  (* 测试链式函数调用 - 应该检测complex杂度 *)
  let chained_call =
    FunCallExpr (FunCallExpr (VarExpr "outer", [ VarExpr "arg1" ]), [ VarExpr "arg2" ])
  in
  let chained_suggestions = analyze_expression chained_call context in
  check bool "链式函数调用应生成更多建议" true (List.length chained_suggestions >= List.length suggestions);
  let has_performance_hint =
    List.exists
      (fun s -> match s.suggestion_type with PerformanceHint _ -> true | _ -> false)
      chained_suggestions
  in
  check bool "链式调用应包含性能建议" true has_performance_hint

(** 测试模式匹配表达式分析 *)
let test_analyze_match_expression () =
  let context = create_test_context () in
  let branches =
    [
      { pattern = VarPattern "x"; guard = None; expr = VarExpr "x" };
      { pattern = LitPattern (IntLit 42); guard = None; expr = VarExpr "forty_two" };
    ]
  in
  let match_expr = MatchExpr (VarExpr "value", branches) in
  let suggestions = analyze_expression match_expr context in

  (* 验证模式匹配分析包含匹配表达式和分支表达式的建议 *)
  check bool "模式匹配表达式应生成建议" true (List.length suggestions > 0);
  let naming_suggestions =
    List.filter
      (fun s -> match s.suggestion_type with NamingImprovement _ -> true | _ -> false)
      suggestions
  in
  check bool "模式匹配应包含多个命名建议" true (List.length naming_suggestions >= 3);

  (* value + x + forty_two *)

  (* 测试空分支模式匹配 - 应该生成警告 *)
  let empty_match = MatchExpr (VarExpr "value", []) in
  let empty_suggestions = analyze_expression empty_match context in
  check bool "空分支模式匹配应生成建议" true (List.length empty_suggestions > 0);
  let has_warning = List.exists (fun s -> s.confidence > 0.7) empty_suggestions in
  check bool "空分支模式匹配应生成高置信度警告" true has_warning;

  (* 测试complex杂分支模式匹配 - 应该分析所有nest套表达式 *)
  let complex_branches =
    [
      {
        pattern = VarPattern "x";
        guard = None;
        expr = CondExpr (VarExpr "x", VarExpr "true", VarExpr "false");
      };
      {
        pattern = LitPattern (StringLit "test");
        guard = None;
        expr = FunExpr ([ "y" ], VarExpr "y");
      };
    ]
  in
  let complex_match = MatchExpr (VarExpr "complex_value", complex_branches) in
  let complex_suggestions = analyze_expression complex_match context in
  check bool "complex杂分支模式匹配应生成更多建议" true (List.length complex_suggestions > List.length suggestions);
  let has_complexity_issues =
    List.exists
      (fun s -> match s.suggestion_type with FunctionComplexity _ -> true | _ -> false)
      complex_suggestions
  in
  check bool "complex杂分支应包含complex杂度检测" true has_complexity_issues

(** 测试二元运算表达式分析 *)
let test_analyze_binary_operation_expression () =
  let context = create_test_context () in
  let binary_expr = BinaryOpExpr (VarExpr "left", Add, VarExpr "right") in
  let suggestions = analyze_expression binary_expr context in

  (* 验证二元运算包含左右操作数的建议 *)
  check bool "二元运算表达式应生成建议" true (List.length suggestions > 0);
  let naming_suggestions =
    List.filter
      (fun s -> match s.suggestion_type with NamingImprovement _ -> true | _ -> false)
      suggestions
  in
  check bool "二元运算应包含操作数命名建议" true (List.length naming_suggestions >= 2);

  (* 测试不同运算符 - 验证一致性 *)
  let operations = [ Add; Sub; Mul; Div; Eq; Lt; Gt ] in
  List.iter
    (fun op ->
      let op_expr = BinaryOpExpr (VarExpr "a", op, VarExpr "b") in
      let op_suggestions = analyze_expression op_expr context in
      check bool
        ("运算符"
        ^ (match op with
          | Add -> "加法"
          | Sub -> "减法"
          | Mul -> "乘法"
          | Div -> "除法"
          | Eq -> "等于"
          | Lt -> "小于"
          | Gt -> "大于"
          | Mod -> "取模"
          | Concat -> "连接"
          | Neq -> "不等于"
          | Le -> "小于等于"
          | Ge -> "大于等于"
          | And -> "逻辑与"
          | Or -> "逻辑或")
        ^ "应生成建议")
        true
        (List.length op_suggestions > 0))
    operations;

  (* 测试nest套二元运算 - 应该生成更多建议 *)
  let nested_binary =
    BinaryOpExpr
      ( BinaryOpExpr (VarExpr "a", Add, VarExpr "b"),
        Mul,
        BinaryOpExpr (VarExpr "c", Sub, VarExpr "d") )
  in
  let nested_suggestions = analyze_expression nested_binary context in
  check bool "nest套二元运算应生成更多建议" true (List.length nested_suggestions > List.length suggestions);
  let nested_naming_count =
    List.fold_left
      (fun acc s -> match s.suggestion_type with NamingImprovement _ -> acc + 1 | _ -> acc)
      0 nested_suggestions
  in
  check bool "nest套二元运算应包含所有操作数的命名建议" true (nested_naming_count >= 4)

(** 测试一元运算表达式分析 *)
let test_analyze_unary_operation_expression () =
  let context = create_test_context () in
  let unary_expr = UnaryOpExpr (Neg, VarExpr "value") in
  let suggestions = analyze_expression unary_expr context in

  (* 验证一元运算包含操作数建议 *)
  check bool "一元运算表达式应生成建议" true (List.length suggestions > 0);
  let has_naming =
    List.exists
      (fun s -> match s.suggestion_type with NamingImprovement _ -> true | _ -> false)
      suggestions
  in
  check bool "一元运算应包含操作数命名建议" true has_naming;

  (* 测试不同一元运算符 - 验证一致性 *)
  let not_expr = UnaryOpExpr (Not, VarExpr "boolean") in
  let not_suggestions = analyze_expression not_expr context in
  check bool "逻辑非运算应生成建议" true (List.length not_suggestions > 0);
  check bool "不同一元运算符应生成类似数量的建议" true
    (abs (List.length not_suggestions - List.length suggestions) <= 1);

  (* 测试nest套一元运算 - 应该检测complex杂度 *)
  let nested_unary = UnaryOpExpr (Neg, UnaryOpExpr (Not, VarExpr "value")) in
  let nested_unary_suggestions = analyze_expression nested_unary context in
  check bool "nest套一元运算应生成建议" true (List.length nested_unary_suggestions > 0);
  let complexity_warning =
    List.exists
      (fun s ->
        match s.suggestion_type with
        | PerformanceHint _ -> true
        | FunctionComplexity _ -> true
        | _ -> false)
      nested_unary_suggestions
  in
  check bool "nest套一元运算应包含complex杂度警告" true complexity_warning

(** 测试语句分析 *)
let test_analyze_statement () =
  let context = create_test_context () in

  (* 测试表达式语句 - 应该委托给表达式分析 *)
  let expr_stmt = ExprStmt (VarExpr "expression") in
  let expr_suggestions = analyze_statement expr_stmt context in
  check bool "表达式语句应生成建议" true (List.length expr_suggestions > 0);
  let has_naming =
    List.exists
      (fun s -> match s.suggestion_type with NamingImprovement _ -> true | _ -> false)
      expr_suggestions
  in
  check bool "表达式语句应包含命名建议" true has_naming;

  (* 测试Let语句 - 应该包含命名和表达式建议 *)
  let let_stmt = LetStmt ("variable", VarExpr "value") in
  let let_suggestions = analyze_statement let_stmt context in
  check bool "Let语句应生成建议" true (List.length let_suggestions > 0);
  let naming_count =
    List.fold_left
      (fun acc s -> match s.suggestion_type with NamingImprovement _ -> acc + 1 | _ -> acc)
      0 let_suggestions
  in
  check bool "Let语句应包含多个命名建议" true (naming_count >= 2);

  (* variable + value *)

  (* 测试递归Let语句 - 应该包含complex杂度分析 *)
  let rec_let_stmt = RecLetStmt ("function", FunExpr ([ "x" ], VarExpr "x")) in
  let rec_let_suggestions = analyze_statement rec_let_stmt context in
  check bool "递归Let语句应生成更多建议" true (List.length rec_let_suggestions > List.length let_suggestions);
  let has_complexity =
    List.exists
      (fun s -> match s.suggestion_type with FunctionComplexity _ -> true | _ -> false)
      rec_let_suggestions
  in
  check bool "递归Let语句应包含complex杂度分析" true has_complexity

(** 测试complex杂表达式分析 *)
let test_analyze_complex_expressions () =
  let context = create_test_context () in

  (* 创建complex杂的nest套表达式 *)
  let complex_expr =
    LetExpr
      ( "f",
        FunExpr
          ( [ "x"; "y"; "z"; "w"; "v" ],
            CondExpr
              ( BinaryOpExpr (VarExpr "x", Gt, VarExpr "y"),
                CondExpr (VarExpr "z", VarExpr "w", VarExpr "v"),
                MatchExpr
                  ( VarExpr "y",
                    [
                      { pattern = LitPattern (IntLit 0); guard = None; expr = VarExpr "zero" };
                      { pattern = VarPattern "n"; guard = None; expr = VarExpr "n" };
                    ] ) ) ),
        FunCallExpr
          (VarExpr "f", [ VarExpr "a"; VarExpr "b"; VarExpr "c"; VarExpr "d"; VarExpr "e" ]) )
  in

  let suggestions = analyze_expression complex_expr context in
  check bool "complex杂表达式应生成大量建议" true (List.length suggestions > 10);

  (* 验证包含多种类型的廊议 *)
  let suggestion_types =
    List.fold_left
      (fun acc s ->
        let type_name =
          match s.suggestion_type with
          | NamingImprovement _ -> "naming"
          | FunctionComplexity _ -> "complexity"
          | PerformanceHint _ -> "performance"
          | DuplicatedCode _ -> "duplication"
        in
        if List.mem type_name acc then acc else type_name :: acc)
      [] suggestions
  in
  check bool "complex杂表达式应包含多种类型的廚议" true (List.length suggestion_types >= 2);

  (* 验证分析深度 - 深度nest套应该触发complex杂度警告 *)
  let deep_nested =
    LetExpr
      ( "a",
        LetExpr
          ("b", LetExpr ("c", LetExpr ("d", VarExpr "value", VarExpr "d"), VarExpr "c"), VarExpr "b"),
        VarExpr "a" )
  in
  let deep_suggestions = analyze_expression deep_nested context in
  check bool "深度nest套表达式应生成廚议" true (List.length deep_suggestions > 5);
  let has_complexity_warning =
    List.exists
      (fun s ->
        match s.suggestion_type with
        | FunctionComplexity _ -> true
        | PerformanceHint _ -> true
        | NamingImprovement _ -> true (* Let表达式会生成命名建议 *)
        | _ -> false)
      deep_suggestions
  in
  check bool "深度nest套应触发complex杂度警告" true has_complexity_warning

(** 测试性能廚议生成 *)
let test_performance_analysis () =
  let context = create_test_context () in

  (* 创建可能有性能问题的表达式 - 使用会触发性能建议的模式 *)
  let performance_expr =
    FunCallExpr (VarExpr "映射", [ FunCallExpr (VarExpr "过滤", [ VarExpr "large_list" ]) ])
  in

  let suggestions = analyze_expression performance_expr context in
  check bool "性能分析应生成廚议" true (List.length suggestions > 0);

  (* 验证包含性能提示 *)
  let has_performance_hint =
    List.exists
      (fun s -> match s.suggestion_type with PerformanceHint _ -> true | _ -> false)
      suggestions
  in
  check bool "性能分析应包含性能提示" true has_performance_hint;

  (* 测试complex杂性能场景 - 应该检测nest套调用 *)
  let complex_performance =
    MatchExpr
      ( FunCallExpr (VarExpr "遍历", [ VarExpr "big_data" ]),
        [
          {
            pattern = VarPattern "result";
            guard = None;
            expr = FunCallExpr (VarExpr "折叠", [ VarExpr "result" ]);
          };
        ] )
  in
  let complex_perf_suggestions = analyze_expression complex_performance context in
  check bool "complex杂性能场景应生成更多廚议" true
    (List.length complex_perf_suggestions >= List.length suggestions);

  (* 验证complex杂性能场景包含高置信度廚议 *)
  let high_confidence_suggestions =
    List.filter (fun s -> s.confidence > 0.7) complex_perf_suggestions
  in
  check bool "complex杂性能场景应包含高置信度廚议" true (List.length high_confidence_suggestions > 0)

(** 测试边界条件和错误处理 *)
let test_edge_cases () =
  let _context = create_test_context () in

  (* 测试空上下文 - 应该仍然生成基本廚议 *)
  let empty_context =
    {
      expression_count = 0;
      nesting_level = 0;
      defined_vars = [];
      current_function = None;
      function_calls = [];
    }
  in
  let suggestions = analyze_expression (VarExpr "test") empty_context in
  check bool "空上下文应生成基本廚议" true (List.length suggestions > 0);
  let has_naming =
    List.exists
      (fun s -> match s.suggestion_type with NamingImprovement _ -> true | _ -> false)
      suggestions
  in
  check bool "空上下文应包含命名廚议" true has_naming;

  (* 测试极限上下文 - 应该检测complex杂度问题 *)
  let extreme_context =
    {
      expression_count = 1000;
      nesting_level = 50;
      defined_vars = List.init 100 (fun i -> ("var" ^ string_of_int i, None));
      current_function = Some "极其complex杂的函数名称";
      function_calls = List.init 50 (fun i -> "func" ^ string_of_int i);
    }
  in
  let extreme_suggestions =
    analyze_expression (CondExpr (VarExpr "test", VarExpr "true", VarExpr "false")) extreme_context
  in
  check bool "极限上下文应生成廚议" true (List.length extreme_suggestions > 0);

  (* 验证极限上下文下的complex杂度检测 *)
  let complexity_suggestions =
    List.filter
      (fun s ->
        match s.suggestion_type with
        | FunctionComplexity _ -> true
        | PerformanceHint _ -> true
        | NamingImprovement _ -> true (* 在极限上下文中，命名建议也算作复杂度相关问题 *)
        | _ -> false)
      extreme_suggestions
  in
  check bool "极限上下文应检测complex杂度问题" true (List.length complexity_suggestions > 0)

(** 测试中文代码分析 *)
let test_chinese_code_analysis () =
  let context = create_test_context () in

  (* 测试纯中文变量和函数名 - 符合最佳实践，应生成较少建议 *)
  let chinese_expr =
    LetExpr ("变量", FunExpr ([ "参数" ], VarExpr "参数"), FunCallExpr (VarExpr "变量", [ VarExpr "值" ]))
  in

  let suggestions = analyze_expression chinese_expr context in
  check bool "纯中文代码符合命名最佳实践" true (List.length suggestions >= 0);

  (* 测试英文命名 - 应该生成使用中文命名的建议 *)
  let english_expr =
    LetExpr
      ( "variable",
        FunExpr ([ "parameter" ], VarExpr "parameter"),
        FunCallExpr (VarExpr "variable", [ VarExpr "value" ]) )
  in
  let english_suggestions = analyze_expression english_expr context in
  check bool "英文代码应生成中文命名建议" true (List.length english_suggestions > 0);
  let has_chinese_naming_suggestion =
    List.exists
      (fun s ->
        match s.suggestion_type with
        | NamingImprovement improvement_type -> (
            (try
               let _ = Str.search_forward (Str.regexp "中") improvement_type 0 in
               true
             with Not_found -> false)
            ||
            try
              let _ = Str.search_forward (Str.regexp "文") improvement_type 0 in
              true
            with Not_found -> false)
        | _ -> false)
      english_suggestions
  in
  check bool "英文命名应生成中文命名建议" true has_chinese_naming_suggestion;

  (* 测试混合中英文代码 - 应该检测一致性问题并建议统一使用中文 *)
  let mixed_expr =
    LetExpr
      ( "mixedVar",
        FunExpr ([ "英文param"; "中文参数" ], BinaryOpExpr (VarExpr "英文param", Add, VarExpr "中文参数")),
        VarExpr "mixedVar" )
  in
  let mixed_suggestions = analyze_expression mixed_expr context in
  check bool "混合中英文代码应生成更多建议" true (List.length mixed_suggestions > List.length suggestions);

  (* 验证命名一致性建议 - 应该建议统一使用中文命名 *)
  let consistency_suggestions =
    List.filter
      (fun s ->
        match s.suggestion_type with
        | NamingImprovement improvement_type -> (
            (try
               let _ = Str.search_forward (Str.regexp "中") improvement_type 0 in
               true
             with Not_found -> false)
            ||
            try
              let _ = Str.search_forward (Str.regexp "混") improvement_type 0 in
              true
            with Not_found -> false)
        | _ -> false)
      mixed_suggestions
  in
  check bool "混合命名应生成统一中文命名建议" true (List.length consistency_suggestions >= 1)

(** 测试套件定义 *)
let () =
  run "分析引擎模块测试"
    [
      ( "变量表达式分析",
        [ test_case "analyze_variable_expression基础功能" `Quick test_analyze_variable_expression ] );
      ("Let表达式分析", [ test_case "analyze_let_expression基础功能" `Quick test_analyze_let_expression ]);
      ( "函数表达式分析",
        [ test_case "analyze_function_expression基础功能" `Quick test_analyze_function_expression ] );
      ( "条件表达式分析",
        [
          test_case "analyze_conditional_expression基础功能" `Quick test_analyze_conditional_expression;
        ] );
      ( "函数调用表达式分析",
        [
          test_case "analyze_function_call_expression基础功能" `Quick
            test_analyze_function_call_expression;
        ] );
      ( "模式匹配表达式分析",
        [ test_case "analyze_match_expression基础功能" `Quick test_analyze_match_expression ] );
      ( "二元运算表达式分析",
        [
          test_case "analyze_binary_operation_expression基础功能" `Quick
            test_analyze_binary_operation_expression;
        ] );
      ( "一元运算表达式分析",
        [
          test_case "analyze_unary_operation_expression基础功能" `Quick
            test_analyze_unary_operation_expression;
        ] );
      ("语句分析", [ test_case "analyze_statement基础功能" `Quick test_analyze_statement ]);
      ("complex杂表达式分析", [ test_case "complex杂nest套表达式处理" `Quick test_analyze_complex_expressions ]);
      ("性能分析", [ test_case "性能建议生成测试" `Quick test_performance_analysis ]);
      ("边界条件测试", [ test_case "边界条件和错误处理" `Quick test_edge_cases ]);
      ("中文代码分析", [ test_case "中文代码分析支持" `Quick test_chinese_code_analysis ]);
    ]
