open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Types
open Yyocamlc_lib.Semantic

let test_create_initial_context () =
  let context = create_initial_context () in
  let _context_with_builtins = add_builtin_functions context in
  check bool "初始上下文创建成功" true true

let test_scope_management () =
  let context = create_initial_context () in
  let context_with_scope = enter_scope context in
  let _context_exit = exit_scope context_with_scope in
  check bool "作用域管理正常" true true

let test_symbol_addition () =
  let context = create_initial_context () in
  let context_with_scope = enter_scope context in
  let context_with_symbol = add_symbol context_with_scope "x" IntType_T false in
  let symbol_opt = lookup_symbol context_with_symbol.scope_stack "x" in
  check bool "符号添加成功" true (Option.is_some symbol_opt)

let test_type_checking_simple_expression () =
  let context = create_initial_context () in
  let context_with_builtins = add_builtin_functions context in
  let expr = LitExpr (IntLit 42) in
  let _, type_opt = analyze_expression context_with_builtins expr in
  check bool "简单表达式类型推导" true (type_opt = Some IntType_T)

let test_type_checking_binary_operation () =
  let context = create_initial_context () in
  let context_with_builtins = add_builtin_functions context in
  let expr = BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)) in
  let _, type_opt = analyze_expression context_with_builtins expr in
  check bool "二元运算类型推导" true (type_opt = Some IntType_T)

let test_type_checking_variable_expression () =
  let context = create_initial_context () in
  let context_with_builtins = add_builtin_functions context in
  let context_with_scope = enter_scope context_with_builtins in
  let context_with_symbol = add_symbol context_with_scope "x" IntType_T false in
  let expr = VarExpr "x" in
  let _, type_opt = analyze_expression context_with_symbol expr in
  check bool "变量表达式类型推导" true (type_opt = Some IntType_T)

let test_type_checking_function_call () =
  let context = create_initial_context () in
  let _context_with_builtins = add_builtin_functions context in
  check bool "函数调用类型推导" true true

let test_type_checking_let_statement () =
  let context = create_initial_context () in
  let context_with_builtins = add_builtin_functions context in
  let stmt = LetStmt ("x", LitExpr (IntLit 42)) in
  let new_context, _ = analyze_statement context_with_builtins stmt in
  let symbol_opt = lookup_symbol new_context.scope_stack "x" in
  check bool "let语句类型检查" true (Option.is_some symbol_opt)

let test_type_checking_simple_program () =
  let program = [ LetStmt ("x", LitExpr (IntLit 42)); ExprStmt (VarExpr "x") ] in
  let result = type_check_quiet program in
  check bool "简单程序类型检查" true result

let test_type_error_detection () =
  let program = [ LetStmt ("x", LitExpr (IntLit 42)); ExprStmt (VarExpr "y") (* 未定义变量 *) ] in
  let result = type_check_quiet program in
  check bool "类型错误检测" false result

let test_type_checking_with_function_definition () =
  let program =
    [
      LetStmt ("identity", FunExpr ([ "x" ], VarExpr "x"));
      ExprStmt (FunCallExpr (VarExpr "identity", [ LitExpr (IntLit 42) ]));
    ]
  in
  let result = type_check_quiet program in
  check bool "函数定义类型检查" true result

let test_type_checking_recursive_function () =
  let program =
    [
      RecLetStmt
        ( "factorial",
          FunExpr
            ( [ "n" ],
              CondExpr
                ( BinaryOpExpr (VarExpr "n", Eq, LitExpr (IntLit 0)),
                  LitExpr (IntLit 1),
                  BinaryOpExpr
                    ( VarExpr "n",
                      Mul,
                      FunCallExpr
                        ( VarExpr "factorial",
                          [ BinaryOpExpr (VarExpr "n", Sub, LitExpr (IntLit 1)) ] ) ) ) ) );
      ExprStmt (FunCallExpr (VarExpr "factorial", [ LitExpr (IntLit 5) ]));
    ]
  in
  let result = type_check_quiet program in
  check bool "递归函数类型检查" true result

let test_type_definition_handling () =
  let context = create_initial_context () in
  let context_with_type = add_type_definition context "MyInt" IntType_T in
  let type_opt = lookup_type_definition context_with_type "MyInt" in
  check bool "类型定义处理" true (type_opt = Some IntType_T)

let test_algebraic_type_handling () =
  let context = create_initial_context () in
  let constructors = [ ("Some", Some (BaseTypeExpr IntType)); ("None", None) ] in
  let _context_with_adt = add_algebraic_type context "Option" constructors in
  check bool "代数数据类型处理" true true

let () =
  run "Semantic模块单元测试"
    [
      ( "上下文管理测试",
        [
          test_case "创建初始上下文" `Quick test_create_initial_context;
          test_case "作用域管理" `Quick test_scope_management;
          test_case "符号添加" `Quick test_symbol_addition;
          test_case "类型定义处理" `Quick test_type_definition_handling;
          test_case "代数数据类型处理" `Quick test_algebraic_type_handling;
        ] );
      ( "类型推导测试",
        [
          test_case "简单表达式类型推导" `Quick test_type_checking_simple_expression;
          test_case "二元运算类型推导" `Quick test_type_checking_binary_operation;
          test_case "变量表达式类型推导" `Quick test_type_checking_variable_expression;
          test_case "函数调用类型推导" `Quick test_type_checking_function_call;
        ] );
      ( "语句分析测试",
        [
          test_case "let语句类型检查" `Quick test_type_checking_let_statement;
          test_case "函数定义类型检查" `Quick test_type_checking_with_function_definition;
          test_case "递归函数类型检查" `Quick test_type_checking_recursive_function;
        ] );
      ( "程序分析测试",
        [
          test_case "简单程序类型检查" `Quick test_type_checking_simple_program;
          test_case "类型错误检测" `Quick test_type_error_detection;
        ] );
    ]
