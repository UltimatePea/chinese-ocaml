(** 骆言编译器C代码生成器综合测试
    为issue #749提升测试覆盖率至50%+ - C代码生成模块测试增强 *)

open Alcotest
open Yyocamlc_lib.C_codegen
open Yyocamlc_lib.Ast

(** 测试辅助函数 *)
let string_contains s substr =
  try
    let _ = Str.search_forward (Str.regexp_string substr) s 0 in
    true
  with Not_found -> false

let check_c_output test_name expected_substrings actual_output =
  List.iter (fun substr ->
    check bool (Printf.sprintf "%s_contains_%s" test_name substr)
      true (string_contains actual_output substr)
  ) expected_substrings

(** 创建测试用的代码生成配置 *)
let create_test_config () =
  Yyocamlc_lib.C_codegen_context.
    {
      c_output_file = "test_output.c";
      include_debug = false;
      optimize = false;
      runtime_path = "./runtime";
    }

(** 创建测试用的代码生成上下文 *)
let create_test_context () =
  let config = create_test_config () in
  create_context config

(** 集合类型代码生成测试 - 测试列表表达式 *)
let test_collections_codegen () =
  let ctx = create_test_context () in
  
  (* 测试列表字面量 *)
  let list_expr = ListExpr [LitExpr (IntLit 1); LitExpr (IntLit 2); LitExpr (IntLit 3)] in
  let list_code = gen_expr ctx list_expr in
  check_c_output "list_generation" ["1"; "2"; "3"] list_code;
  
  (* 测试数组访问 *)
  let array_access = ArrayAccessExpr (VarExpr "arr", LitExpr (IntLit 0)) in
  let array_code = gen_expr ctx array_access in
  check_c_output "array_access" ["arr"; "0"] array_code;
  
  (* 测试空列表 *)
  let empty_list = ListExpr [] in
  let empty_code = gen_expr ctx empty_list in
  check bool "empty_list_generation" true (String.length empty_code > 0)

(** 异常处理代码生成测试 - 测试异常表达式 *)
let test_exceptions_codegen () =
  let ctx = create_test_context () in
  
  (* 测试异常抛出 *)
  let throw_expr = RaiseExpr (LitExpr (StringLit "error message")) in
  let throw_code = gen_expr ctx throw_expr in
  check_c_output "exception_throw" ["error message"] throw_code;
  
  (* 测试try-catch结构 *)
  let try_expr = TryExpr (
    LitExpr (IntLit 42),
    [{ pattern = VarPattern "e"; guard = None; expr = LitExpr (IntLit 0) }],
    Some (LitExpr (IntLit (-1)))
  ) in
  let try_code = gen_expr ctx try_expr in
  check_c_output "try_catch" ["42"; "0"] try_code

(** 结构化数据代码生成测试 - 测试记录和构造器表达式 *)
let test_structured_data_codegen () =
  let ctx = create_test_context () in
  
  (* 测试记录类型访问 *)
  let record_access = FieldAccessExpr (VarExpr "person", "name") in
  let record_code = gen_expr ctx record_access in
  check_c_output "record_access" ["person"; "name"] record_code;
  
  (* 测试记录更新 *)
  let record_update = RecordUpdateExpr (VarExpr "person", [("age", LitExpr (IntLit 25))]) in
  let update_code = gen_expr ctx record_update in
  check_c_output "record_update" ["person"; "age"; "25"] update_code;
  
  (* 测试构造器表达式 *)
  let constructor_expr = ConstructorExpr ("Some", [LitExpr (IntLit 42)]) in
  let constructor_code = gen_expr ctx constructor_expr in
  check_c_output "constructor_expr" ["Some"; "42"] constructor_code

(** 高级模式匹配代码生成测试 - 测试模式匹配表达式 *)
let test_advanced_patterns_codegen () =
  let ctx = create_test_context () in
  
  (* 测试嵌套模式匹配 *)
  let nested_pattern = MatchExpr (
    VarExpr "value",
    [
      { pattern = ConstructorPattern ("Some", [WildcardPattern]); guard = None; expr = LitExpr (IntLit 1) };
      { pattern = LitPattern (IntLit 0); guard = None; expr = LitExpr (IntLit 2) };
      { pattern = WildcardPattern; guard = None; expr = LitExpr (IntLit 3) }
    ]
  ) in
  let pattern_code = gen_expr ctx nested_pattern in
  check_c_output "nested_pattern" ["value"; "Some"] pattern_code;
  
  (* 测试守卫条件 *)
  let guarded_pattern = MatchExpr (
    VarExpr "x",
    [
      { pattern = VarPattern "n"; 
        guard = Some (BinaryOpExpr (VarExpr "n", Gt, LitExpr (IntLit 0))); 
        expr = VarExpr "n" };
      { pattern = WildcardPattern; guard = None; expr = LitExpr (IntLit (-1)) }
    ]
  ) in
  let guard_code = gen_expr ctx guarded_pattern in
  check_c_output "guarded_pattern" ["x"; "n"; "0"] guard_code

(** 复杂字面量代码生成测试 - 测试各种字面量表达式 *)
let test_complex_literals_codegen () =
  let ctx = create_test_context () in
  
  (* 测试字符串字面量 *)
  let string_lit = LitExpr (StringLit "x") in
  let string_code = gen_expr ctx string_lit in
  check_c_output "string_literal" ["x"] string_code;
  
  (* 测试浮点数字面量 *)
  let float_lit = LitExpr (FloatLit 3.14) in
  let float_code = gen_expr ctx float_lit in
  check_c_output "float_literal" ["3.14"] float_code;
  
  (* 测试布尔字面量 *)
  let bool_true = LitExpr (BoolLit true) in
  let bool_false = LitExpr (BoolLit false) in
  let true_code = gen_expr ctx bool_true in
  let false_code = gen_expr ctx bool_false in
  check_c_output "bool_true" ["true"] true_code;
  check_c_output "bool_false" ["false"] false_code;
  
  (* 测试Unicode字符串字面量 *)
  let unicode_str = LitExpr (StringLit "你好世界") in
  let unicode_code = gen_expr ctx unicode_str in
  check bool "unicode_string_generation" true (String.length unicode_code > 0)

(** 操作符代码生成测试 - 测试二元和一元运算符 *)
let test_operations_codegen () =
  let ctx = create_test_context () in
  
  (* 测试算术运算符 *)
  let arithmetic_ops = [(Add, "+"); (Sub, "-"); (Mul, "*"); (Div, "/"); (Mod, "%")] in
  List.iter (fun (op, op_str) ->
    let expr = BinaryOpExpr (LitExpr (IntLit 10), op, LitExpr (IntLit 5)) in
    let code = gen_expr ctx expr in
    check_c_output (Printf.sprintf "arithmetic_%s" op_str) ["10"; "5"] code
  ) arithmetic_ops;
  
  (* 测试比较运算符 *)
  let comparison_ops = [(Eq, "=="); (Neq, "!="); (Lt, "<"); (Gt, ">"); (Le, "<="); (Ge, ">=")] in
  List.iter (fun (op, op_str) ->
    let expr = BinaryOpExpr (VarExpr "x", op, VarExpr "y") in
    let code = gen_expr ctx expr in
    check_c_output (Printf.sprintf "comparison_%s" op_str) ["x"; "y"] code
  ) comparison_ops;
  
  (* 测试逻辑运算符 *)
  let logical_ops = [(And, "&&"); (Or, "||")] in
  List.iter (fun (op, op_str) ->
    let expr = BinaryOpExpr (LitExpr (BoolLit true), op, LitExpr (BoolLit false)) in
    let code = gen_expr ctx expr in
    check_c_output (Printf.sprintf "logical_%s" op_str) ["true"; "false"] code
  ) logical_ops;
  
  (* 测试一元运算符 *)
  let unary_ops = [(Neg, "-"); (Not, "!")] in
  List.iter (fun (op, op_str) ->
    let expr = UnaryOpExpr (op, VarExpr "x") in
    let code = gen_expr ctx expr in
    check_c_output (Printf.sprintf "unary_%s" op_str) ["x"] code
  ) unary_ops

(** 复杂表达式代码生成测试 *)
let test_complex_expressions_codegen () =
  let ctx = create_test_context () in
  
  (* 测试函数调用链 *)
  let chained_call = FunCallExpr (
    VarExpr "f",
    [FunCallExpr (VarExpr "g", [LitExpr (IntLit 42)])]
  ) in
  let chain_code = gen_expr ctx chained_call in
  check_c_output "chained_function_call" ["f"; "g"; "42"] chain_code;
  
  (* 测试条件表达式嵌套 *)
  let nested_cond = CondExpr (
    BinaryOpExpr (VarExpr "x", Gt, LitExpr (IntLit 0)),
    CondExpr (
      BinaryOpExpr (VarExpr "x", Lt, LitExpr (IntLit 10)),
      LitExpr (StringLit "small positive"),
      LitExpr (StringLit "large positive")
    ),
    LitExpr (StringLit "negative or zero")
  ) in
  let cond_code = gen_expr ctx nested_cond in
  check_c_output "nested_conditional" ["x"; "0"; "10"; "small positive"; "large positive"] cond_code;
  
  (* 测试复杂数组索引 *)
  let complex_index = ArrayAccessExpr (
    ArrayAccessExpr (VarExpr "matrix", LitExpr (IntLit 0)),
    BinaryOpExpr (VarExpr "i", Add, LitExpr (IntLit 1))
  ) in
  let index_code = gen_expr ctx complex_index in
  check_c_output "complex_array_index" ["matrix"; "0"; "i"; "1"] index_code

(** 控制流语句代码生成测试 *)
let test_control_flow_codegen () =
  let ctx = create_test_context () in
  
  (* 测试let语句 *)
  let let_stmt = LetStmt ("i", LitExpr (IntLit 0)) in
  let let_code = gen_stmt ctx let_stmt in
  check_c_output "let_statement" ["i"; "0"] let_code;
  
  (* 测试表达式语句 *)
  let expr_stmt = ExprStmt (BinaryOpExpr (VarExpr "running", Eq, LitExpr (BoolLit true))) in
  let expr_code = gen_stmt ctx expr_stmt in
  check_c_output "expression_statement" ["running"; "true"] expr_code;
  
  (* 测试条件表达式作为控制流 *)
  let switch_like = MatchExpr (
    VarExpr "choice",
    [
      { pattern = LitPattern (IntLit 1); guard = None; expr = LitExpr (StringLit "One") };
      { pattern = LitPattern (IntLit 2); guard = None; expr = LitExpr (StringLit "Two") };
      { pattern = WildcardPattern; guard = None; expr = LitExpr (StringLit "Other") }
    ]
  ) in
  let switch_code = gen_expr ctx switch_like in
  check_c_output "switch_like_expression" ["choice"; "One"; "Two"; "Other"] switch_code

(** 函数定义代码生成测试 *)
let test_function_definition_codegen () =
  let ctx = create_test_context () in
  
  (* 测试简单函数定义 *)
  let simple_func = FunExpr (
    ["a"; "b"],
    BinaryOpExpr (VarExpr "a", Add, VarExpr "b")
  ) in
  let func_code = gen_expr ctx simple_func in
  check_c_output "simple_function" ["a"; "b"] func_code;
  
  (* 测试递归函数定义 *)
  let recursive_func = FunExpr (
    ["n"],
    CondExpr (
      BinaryOpExpr (VarExpr "n", Le, LitExpr (IntLit 1)),
      LitExpr (IntLit 1),
      BinaryOpExpr (
        VarExpr "n",
        Mul,
        FunCallExpr (VarExpr "factorial", [BinaryOpExpr (VarExpr "n", Sub, LitExpr (IntLit 1))])
      )
    )
  ) in
  let rec_code = gen_expr ctx recursive_func in
  check_c_output "recursive_function" ["n"; "1"; "factorial"] rec_code

(** 错误处理和边界情况测试 *)
let test_error_handling_codegen () =
  let ctx = create_test_context () in
  
  (* 测试单元表达式处理 *)
  let unit_expr = LitExpr UnitLit in
  let unit_code = gen_expr ctx unit_expr in
  check bool "unit_literal_generation" true (String.length unit_code > 0);
  
  (* 测试类型不匹配操作符处理 *)
  let mixed_op = BinaryOpExpr (LitExpr (StringLit "hello"), Add, LitExpr (IntLit 42)) in
  let mixed_code = gen_expr ctx mixed_op in
  check bool "mixed_type_operation_handling" true (String.length mixed_code > 0);
  
  (* 测试深度嵌套表达式 *)
  let rec create_nested_expr depth =
    if depth <= 0 then LitExpr (IntLit 1)
    else BinaryOpExpr (create_nested_expr (depth - 1), Add, LitExpr (IntLit depth))
  in
  let deep_expr = create_nested_expr 10 in
  let deep_code = gen_expr ctx deep_expr in
  check bool "deep_nested_expression" true (String.length deep_code > 0)

(** 性能和压力测试 *)
let test_performance_codegen () =
  let ctx = create_test_context () in
  
  (* 测试大型程序生成 *)
  let large_program = List.init 100 (fun i ->
    LetStmt (
      Printf.sprintf "func_%d" i,
      FunExpr (
        ["x"],
        BinaryOpExpr (VarExpr "x", Add, LitExpr (IntLit i))
      )
    )
  ) in
  let large_code = gen_program ctx large_program in
  check bool "large_program_generation" true (String.length large_code > 1000);
  
  (* 测试复杂表达式生成 *)
  let complex_expr = List.fold_left (fun acc i ->
    BinaryOpExpr (acc, Mul, BinaryOpExpr (VarExpr (Printf.sprintf "x_%d" i), Add, LitExpr (IntLit i)))
  ) (LitExpr (IntLit 1)) (List.init 20 (fun i -> i)) in
  let complex_code = gen_expr ctx complex_expr in
  check bool "complex_expression_generation" true (String.length complex_code > 100)

(** 代码格式和美化测试 *)
let test_code_formatting () =
  let ctx = create_test_context () in
  
  (* 测试嵌套表达式格式 *)
  let nested_expr = CondExpr (
    LitExpr (BoolLit true),
    LetExpr ("x", LitExpr (IntLit 1), 
      LetExpr ("y", LitExpr (IntLit 2), VarExpr "y")),
    LitExpr (IntLit 0)
  ) in
  let formatted_code = gen_expr ctx nested_expr in
  check bool "nested_expression_formatting" true (String.length formatted_code > 0);
  
  (* 测试多个语句生成 *)
  let stmt_list = [
    LetStmt ("a", LitExpr (IntLit 1));
    LetStmt ("b", LitExpr (IntLit 2));
    LetStmt ("c", LitExpr (IntLit 3))
  ] in
  let stmt_code = String.concat "\n" (List.map (gen_stmt ctx) stmt_list) in
  check bool "multiple_statements_formatting" true (String.length stmt_code > 0)

(** C语言特定特性测试 *)
let test_c_specific_features () =
  let ctx = create_test_context () in
  
  (* 测试引用操作 *)
  let reference_expr = RefExpr (VarExpr "ptr") in
  let ref_code = gen_expr ctx reference_expr in
  check_c_output "reference_creation" ["ptr"] ref_code;
  
  (* 测试解引用 *)
  let deref_expr = DerefExpr (VarExpr "var") in
  let deref_code = gen_expr ctx deref_expr in
  check_c_output "dereference" ["var"] deref_code;
  
  (* 测试类型注解 *)
  let type_annotated = TypeAnnotationExpr (LitExpr (FloatLit 3.14), BaseTypeExpr IntType) in
  let annotated_code = gen_expr ctx type_annotated in
  check_c_output "type_annotation" ["3.14"] annotated_code;
  
  (* 测试数组操作 *)
  let array_expr = ArrayExpr [LitExpr (IntLit 1); LitExpr (IntLit 2); LitExpr (IntLit 3)] in
  let array_code = gen_expr ctx array_expr in
  check_c_output "array_creation" ["1"; "2"; "3"] array_code

(** 集成测试 - 端到端C代码生成 *)
let test_end_to_end_codegen () =
  let config = create_test_config () in
  
  (* 测试完整的C程序生成 *)
  let complete_program = [
    LetStmt ("main", FunExpr (
      [],
      LetExpr ("result", FunCallExpr (VarExpr "fibonacci", [LitExpr (IntLit 10)]),
        FunCallExpr (VarExpr "print", [VarExpr "result"]))
    ));
    LetStmt ("fibonacci", FunExpr (
      ["n"],
      CondExpr (
        BinaryOpExpr (VarExpr "n", Le, LitExpr (IntLit 1)),
        VarExpr "n",
        BinaryOpExpr (
          FunCallExpr (VarExpr "fibonacci", [BinaryOpExpr (VarExpr "n", Sub, LitExpr (IntLit 1))]),
          Add,
          FunCallExpr (VarExpr "fibonacci", [BinaryOpExpr (VarExpr "n", Sub, LitExpr (IntLit 2))])
        )
      )
    ))
  ] in
  let complete_code = generate_c_code config complete_program in
  check_c_output "complete_program" [
    "main"; "result"; "fibonacci"; "10"; "print"; "n"; "1"; "2"
  ] complete_code;
  
  (* 验证生成的代码包含必要的头文件 *)
  check bool "includes_headers" true (string_contains complete_code "#include");
  
  (* 验证生成代码的基本结构 *)
  check bool "contains_main_function" true (string_contains complete_code "main");
  check bool "contains_fibonacci_function" true (string_contains complete_code "fibonacci")

(** 测试套件 *)
let test_suite = [
  ("集合类型代码生成", `Quick, test_collections_codegen);
  ("异常处理代码生成", `Quick, test_exceptions_codegen);
  ("结构化数据代码生成", `Quick, test_structured_data_codegen);
  ("高级模式匹配代码生成", `Quick, test_advanced_patterns_codegen);
  ("复杂字面量代码生成", `Quick, test_complex_literals_codegen);
  ("操作符代码生成", `Quick, test_operations_codegen);
  ("复杂表达式代码生成", `Quick, test_complex_expressions_codegen);
  ("控制流语句代码生成", `Quick, test_control_flow_codegen);
  ("函数定义代码生成", `Quick, test_function_definition_codegen);
  ("错误处理和边界情况", `Quick, test_error_handling_codegen);
  ("性能和压力测试", `Slow, test_performance_codegen);
  ("代码格式和美化", `Quick, test_code_formatting);
  ("C语言特定特性", `Quick, test_c_specific_features);
  ("端到端C代码生成", `Quick, test_end_to_end_codegen);
]

let () = run "C代码生成器综合测试" [("C代码生成器综合测试", test_suite)]