(** AST模块辅助函数专项测试 - Fix #2147

    专门测试AST模块末尾的辅助函数，确保这些函数被完全覆盖：
    - make_int: 创建整数字面量表达式
    - make_string: 创建字符串字面量表达式
    - make_bool: 创建布尔字面量表达式
    - make_var: 创建变量表达式
    - make_binary_op: 创建二元运算表达式
    - make_call: 创建函数调用表达式

    这些辅助函数位于ast.ml的第271-287行，是提高覆盖率的关键目标。

    Author: Whisky, PR Worker
    @version 1.0
    @since 2025-08-04 Fix #2147 AST模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Ast

(** 测试工具辅助模块 *)
module TestUtils = struct
  let check_expr_equality desc expected actual =
    check (testable pp_expr equal_expr) desc expected actual
end

(** 专项测试make_int辅助函数 *)
let test_make_int_comprehensive () =
  (* 测试正整数 *)
  let pos_int = make_int 42 in
  TestUtils.check_expr_equality "正整数构造" (LitExpr (IntLit 42)) pos_int;

  (* 测试负整数 *)
  let neg_int = make_int (-100) in
  TestUtils.check_expr_equality "负整数构造" (LitExpr (IntLit (-100))) neg_int;

  (* 测试零 *)
  let zero_int = make_int 0 in
  TestUtils.check_expr_equality "零构造" (LitExpr (IntLit 0)) zero_int;

  (* 测试大整数 *)
  let large_int = make_int 1000000 in
  TestUtils.check_expr_equality "大整数构造" (LitExpr (IntLit 1000000)) large_int;

  (* 测试最小整数边界值 *)
  let min_int_expr = make_int min_int in
  TestUtils.check_expr_equality "最小整数构造" (LitExpr (IntLit min_int)) min_int_expr;

  (* 测试最大整数边界值 *)
  let max_int_expr = make_int max_int in
  TestUtils.check_expr_equality "最大整数构造" (LitExpr (IntLit max_int)) max_int_expr

(** 专项测试make_string辅助函数 *)
let test_make_string_comprehensive () =
  (* 测试普通字符串 *)
  let normal_str = make_string "普通字符串" in
  TestUtils.check_expr_equality "普通字符串构造" (LitExpr (StringLit "普通字符串")) normal_str;

  (* 测试空字符串 *)
  let empty_str = make_string "" in
  TestUtils.check_expr_equality "空字符串构造" (LitExpr (StringLit "")) empty_str;

  (* 测试英文字符串 *)
  let english_str = make_string "Hello World" in
  TestUtils.check_expr_equality "英文字符串构造" (LitExpr (StringLit "Hello World")) english_str;

  (* 测试包含特殊字符的字符串 *)
  let special_str = make_string "字符串\\n\\t\"测试\"" in
  TestUtils.check_expr_equality "特殊字符字符串构造" (LitExpr (StringLit "字符串\\n\\t\"测试\"")) special_str;

  (* 测试长字符串 *)
  let long_str = String.make 1000 'x' in
  let long_string_expr = make_string long_str in
  TestUtils.check_expr_equality "长字符串构造" (LitExpr (StringLit long_str)) long_string_expr;

  (* 测试Unicode字符串 *)
  let unicode_str = make_string "🎵诗词编程🎶" in
  TestUtils.check_expr_equality "Unicode字符串构造" (LitExpr (StringLit "🎵诗词编程🎶")) unicode_str;

  (* 测试单字符字符串 *)
  let single_char = make_string "言" in
  TestUtils.check_expr_equality "单字符字符串构造" (LitExpr (StringLit "言")) single_char

(** 专项测试make_bool辅助函数 *)
let test_make_bool_comprehensive () =
  (* 测试true值 *)
  let true_expr = make_bool true in
  TestUtils.check_expr_equality "true布尔值构造" (LitExpr (BoolLit true)) true_expr;

  (* 测试false值 *)
  let false_expr = make_bool false in
  TestUtils.check_expr_equality "false布尔值构造" (LitExpr (BoolLit false)) false_expr;

  (* 测试表达式结果为true的情况 *)
  let computed_true = make_bool (5 > 3) in
  TestUtils.check_expr_equality "计算得true" (LitExpr (BoolLit true)) computed_true;

  (* 测试表达式结果为false的情况 *)
  let computed_false = make_bool (1 > 10) in
  TestUtils.check_expr_equality "计算得false" (LitExpr (BoolLit false)) computed_false;

  (* 测试逻辑运算结果 *)
  let logic_result = make_bool (true && false) in
  TestUtils.check_expr_equality "逻辑运算结果" (LitExpr (BoolLit false)) logic_result

(** 专项测试make_var辅助函数 *)
let test_make_var_comprehensive () =
  (* 测试简单变量名 *)
  let simple_var = make_var "x" in
  TestUtils.check_expr_equality "简单变量名" (VarExpr "x") simple_var;

  (* 测试中文变量名 *)
  let chinese_var = make_var "变量名" in
  TestUtils.check_expr_equality "中文变量名" (VarExpr "变量名") chinese_var;

  (* 测试带下划线的变量名 *)
  let underscore_var = make_var "test_variable" in
  TestUtils.check_expr_equality "下划线变量名" (VarExpr "test_variable") underscore_var;

  (* 测试带数字的变量名 *)
  let numeric_var = make_var "var123" in
  TestUtils.check_expr_equality "数字变量名" (VarExpr "var123") numeric_var;

  (* 测试长变量名 *)
  let long_var = make_var "这是一个非常长的变量名用来测试make_var函数" in
  TestUtils.check_expr_equality "长变量名" (VarExpr "这是一个非常长的变量名用来测试make_var函数") long_var;

  (* 测试单字符变量名 *)
  let single_char_var = make_var "骆" in
  TestUtils.check_expr_equality "单字符变量名" (VarExpr "骆") single_char_var;

  (* 测试空字符串变量名（虽然不推荐） *)
  let empty_var = make_var "" in
  TestUtils.check_expr_equality "空变量名" (VarExpr "") empty_var

(** 专项测试make_binary_op辅助函数 *)
let test_make_binary_op_comprehensive () =
  (* 测试所有算术运算符 *)
  let add_expr = make_binary_op (make_int 5) Add (make_int 3) in
  TestUtils.check_expr_equality "加法运算"
    (BinaryOpExpr (LitExpr (IntLit 5), Add, LitExpr (IntLit 3)))
    add_expr;

  let sub_expr = make_binary_op (make_int 10) Sub (make_int 4) in
  TestUtils.check_expr_equality "减法运算"
    (BinaryOpExpr (LitExpr (IntLit 10), Sub, LitExpr (IntLit 4)))
    sub_expr;

  let mul_expr = make_binary_op (make_int 6) Mul (make_int 7) in
  TestUtils.check_expr_equality "乘法运算"
    (BinaryOpExpr (LitExpr (IntLit 6), Mul, LitExpr (IntLit 7)))
    mul_expr;

  let div_expr = make_binary_op (make_int 20) Div (make_int 5) in
  TestUtils.check_expr_equality "除法运算"
    (BinaryOpExpr (LitExpr (IntLit 20), Div, LitExpr (IntLit 5)))
    div_expr;

  let mod_expr = make_binary_op (make_int 15) Mod (make_int 4) in
  TestUtils.check_expr_equality "取模运算"
    (BinaryOpExpr (LitExpr (IntLit 15), Mod, LitExpr (IntLit 4)))
    mod_expr;

  (* 测试字符串连接运算符 *)
  let concat_expr = make_binary_op (make_string "Hello") Concat (make_string "World") in
  TestUtils.check_expr_equality "字符串连接"
    (BinaryOpExpr (LitExpr (StringLit "Hello"), Concat, LitExpr (StringLit "World")))
    concat_expr;

  (* 测试比较运算符 *)
  let eq_expr = make_binary_op (make_int 5) Eq (make_int 5) in
  TestUtils.check_expr_equality "相等比较"
    (BinaryOpExpr (LitExpr (IntLit 5), Eq, LitExpr (IntLit 5)))
    eq_expr;

  let lt_expr = make_binary_op (make_int 3) Lt (make_int 8) in
  TestUtils.check_expr_equality "小于比较"
    (BinaryOpExpr (LitExpr (IntLit 3), Lt, LitExpr (IntLit 8)))
    lt_expr;

  (* 测试逻辑运算符 *)
  let and_expr = make_binary_op (make_bool true) And (make_bool false) in
  TestUtils.check_expr_equality "逻辑与运算"
    (BinaryOpExpr (LitExpr (BoolLit true), And, LitExpr (BoolLit false)))
    and_expr;

  let or_expr = make_binary_op (make_bool false) Or (make_bool true) in
  TestUtils.check_expr_equality "逻辑或运算"
    (BinaryOpExpr (LitExpr (BoolLit false), Or, LitExpr (BoolLit true)))
    or_expr;

  (* 测试嵌套二元运算 *)
  let nested_expr =
    make_binary_op
      (make_binary_op (make_int 2) Mul (make_int 3))
      Add
      (make_binary_op (make_int 4) Div (make_int 2))
  in
  let expected_nested =
    BinaryOpExpr
      ( BinaryOpExpr (LitExpr (IntLit 2), Mul, LitExpr (IntLit 3)),
        Add,
        BinaryOpExpr (LitExpr (IntLit 4), Div, LitExpr (IntLit 2)) )
  in
  TestUtils.check_expr_equality "嵌套二元运算" expected_nested nested_expr;

  (* 测试变量运算 *)
  let var_expr = make_binary_op (make_var "x") Add (make_var "y") in
  TestUtils.check_expr_equality "变量运算" (BinaryOpExpr (VarExpr "x", Add, VarExpr "y")) var_expr

(** 专项测试make_call辅助函数 *)
let test_make_call_comprehensive () =
  (* 测试无参数函数调用 *)
  let no_args_call = make_call (make_var "get_random") [] in
  TestUtils.check_expr_equality "无参数函数调用" (FunCallExpr (VarExpr "get_random", [])) no_args_call;

  (* 测试单参数函数调用 *)
  let single_arg_call = make_call (make_var "print") [ make_string "Hello" ] in
  TestUtils.check_expr_equality "单参数函数调用"
    (FunCallExpr (VarExpr "print", [ LitExpr (StringLit "Hello") ]))
    single_arg_call;

  (* 测试多参数函数调用 *)
  let multi_args_call = make_call (make_var "add3") [ make_int 1; make_int 2; make_int 3 ] in
  TestUtils.check_expr_equality "多参数函数调用"
    (FunCallExpr (VarExpr "add3", [ LitExpr (IntLit 1); LitExpr (IntLit 2); LitExpr (IntLit 3) ]))
    multi_args_call;

  (* 测试不同类型参数的函数调用 *)
  let mixed_args_call =
    make_call (make_var "process")
      [ make_string "input"; make_int 42; make_bool true; make_var "config" ]
  in
  let expected_mixed =
    FunCallExpr
      ( VarExpr "process",
        [
          LitExpr (StringLit "input"); LitExpr (IntLit 42); LitExpr (BoolLit true); VarExpr "config";
        ] )
  in
  TestUtils.check_expr_equality "混合类型参数函数调用" expected_mixed mixed_args_call;

  (* 测试嵌套函数调用 *)
  let nested_call =
    make_call (make_var "outer_func") [ make_call (make_var "inner_func") [ make_int 10 ] ]
  in
  let expected_nested_call =
    FunCallExpr
      (VarExpr "outer_func", [ FunCallExpr (VarExpr "inner_func", [ LitExpr (IntLit 10) ]) ])
  in
  TestUtils.check_expr_equality "嵌套函数调用" expected_nested_call nested_call;

  (* 测试表达式作为函数的调用 *)
  let expr_func_call =
    make_call (make_binary_op (make_var "func_map") Add (make_int 0)) [ make_string "arg" ]
  in
  let expected_expr_func =
    FunCallExpr
      (BinaryOpExpr (VarExpr "func_map", Add, LitExpr (IntLit 0)), [ LitExpr (StringLit "arg") ])
  in
  TestUtils.check_expr_equality "表达式函数调用" expected_expr_func expr_func_call;

  (* 测试中文函数名调用 *)
  let chinese_func_call = make_call (make_var "计算") [ make_int 5; make_int 10 ] in
  TestUtils.check_expr_equality "中文函数名调用"
    (FunCallExpr (VarExpr "计算", [ LitExpr (IntLit 5); LitExpr (IntLit 10) ]))
    chinese_func_call

(** 测试辅助函数组合使用 *)
let test_helper_functions_combination () =
  (* 测试辅助函数相互组合 *)
  let combined_expr1 =
    make_call (make_var "calculate")
      [ make_binary_op (make_int 10) Mul (make_int 5); make_bool true ]
  in
  let expected_combined1 =
    FunCallExpr
      ( VarExpr "calculate",
        [ BinaryOpExpr (LitExpr (IntLit 10), Mul, LitExpr (IntLit 5)); LitExpr (BoolLit true) ] )
  in
  TestUtils.check_expr_equality "辅助函数组合1" expected_combined1 combined_expr1;

  (* 测试复杂组合表达式 *)
  let complex_expr =
    make_binary_op
      (make_call (make_var "func1") [ make_int 1; make_string "test" ])
      Add
      (make_call (make_var "func2") [ make_bool false ])
  in
  let expected_complex =
    BinaryOpExpr
      ( FunCallExpr (VarExpr "func1", [ LitExpr (IntLit 1); LitExpr (StringLit "test") ]),
        Add,
        FunCallExpr (VarExpr "func2", [ LitExpr (BoolLit false) ]) )
  in
  TestUtils.check_expr_equality "复杂组合表达式" expected_complex complex_expr;

  (* 测试深层嵌套组合 *)
  let deep_nested =
    make_call (make_var "outer")
      [
        make_call (make_var "middle")
          [ make_call (make_var "inner") [ make_binary_op (make_int 1) Add (make_int 2) ] ];
      ]
  in
  let expected_deep =
    FunCallExpr
      ( VarExpr "outer",
        [
          FunCallExpr
            ( VarExpr "middle",
              [
                FunCallExpr
                  (VarExpr "inner", [ BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)) ]);
              ] );
        ] )
  in
  TestUtils.check_expr_equality "深层嵌套组合" expected_deep deep_nested

(** 测试边界情况和特殊用法 *)
let test_helper_functions_edge_cases () =
  (* 测试极大整数 *)
  let max_int_expr = make_int max_int in
  TestUtils.check_expr_equality "最大整数" (LitExpr (IntLit max_int)) max_int_expr;

  (* 测试极小整数 *)
  let min_int_expr = make_int min_int in
  TestUtils.check_expr_equality "最小整数" (LitExpr (IntLit min_int)) min_int_expr;

  (* 测试长参数列表 *)
  let long_args = List.init 50 (fun i -> make_int i) in
  let long_call = make_call (make_var "long_function") long_args in
  let expected_long_args = List.init 50 (fun i -> LitExpr (IntLit i)) in
  let expected_long_call = FunCallExpr (VarExpr "long_function", expected_long_args) in
  TestUtils.check_expr_equality "长参数列表调用" expected_long_call long_call;

  (* 测试Unicode字符串 *)
  let unicode_expr = make_string "骆言🐪编程语言" in
  TestUtils.check_expr_equality "Unicode字符串" (LitExpr (StringLit "骆言🐪编程语言")) unicode_expr;

  (* 测试非常复杂的嵌套 *)
  let ultra_complex =
    make_binary_op
      (make_call (make_var "函数A")
         [ make_binary_op (make_int 10) Div (make_int 2); make_string "参数" ])
      Concat
      (make_string (show_expr (make_bool true)))
  in

  (* 验证这个复杂表达式可以正确构造 *)
  check bool "超复杂表达式构造成功" true
    (match ultra_complex with
    | BinaryOpExpr (FunCallExpr _, Concat, LitExpr (StringLit _)) -> true
    | _ -> false)

(** 主测试运行器 *)
let () =
  run "AST模块辅助函数专项测试 - Fix #2147"
    [
      ("make_int函数测试", [ test_case "make_int全面测试" `Quick test_make_int_comprehensive ]);
      ("make_string函数测试", [ test_case "make_string全面测试" `Quick test_make_string_comprehensive ]);
      ("make_bool函数测试", [ test_case "make_bool全面测试" `Quick test_make_bool_comprehensive ]);
      ("make_var函数测试", [ test_case "make_var全面测试" `Quick test_make_var_comprehensive ]);
      ( "make_binary_op函数测试",
        [ test_case "make_binary_op全面测试" `Quick test_make_binary_op_comprehensive ] );
      ("make_call函数测试", [ test_case "make_call全面测试" `Quick test_make_call_comprehensive ]);
      ( "辅助函数组合测试",
        [
          test_case "辅助函数组合使用" `Quick test_helper_functions_combination;
          test_case "边界情况和特殊用法" `Quick test_helper_functions_edge_cases;
        ] );
    ]
