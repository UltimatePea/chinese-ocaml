open Alcotest
open Yyocamlc_lib.Ast

let test_ast_construction () =
  let int_expr = make_int 42 in
  let string_expr = make_string "hello" in
  let bool_expr = make_bool true in
  let var_expr = make_var "x" in

  check
    (testable
       (fun fmt expr ->
         match expr with
         | LitExpr (IntLit i) -> Format.fprintf fmt "IntLit(%d)" i
         | LitExpr (StringLit s) -> Format.fprintf fmt "StringLit(%s)" s
         | LitExpr (BoolLit b) -> Format.fprintf fmt "BoolLit(%b)" b
         | VarExpr v -> Format.fprintf fmt "VarExpr(%s)" v
         | _ -> Format.fprintf fmt "Other")
       (fun a b -> equal_expr a b))
    "整数表达式构造" (LitExpr (IntLit 42)) int_expr;

  check
    (testable
       (fun fmt expr ->
         match expr with
         | LitExpr (StringLit s) -> Format.fprintf fmt "StringLit(%s)" s
         | _ -> Format.fprintf fmt "Other")
       (fun a b -> equal_expr a b))
    "字符串表达式构造" (LitExpr (StringLit "hello")) string_expr;

  check
    (testable
       (fun fmt expr ->
         match expr with
         | LitExpr (BoolLit b) -> Format.fprintf fmt "BoolLit(%b)" b
         | _ -> Format.fprintf fmt "Other")
       (fun a b -> equal_expr a b))
    "布尔表达式构造" (LitExpr (BoolLit true)) bool_expr;

  check
    (testable
       (fun fmt expr ->
         match expr with
         | VarExpr v -> Format.fprintf fmt "VarExpr(%s)" v
         | _ -> Format.fprintf fmt "Other")
       (fun a b -> equal_expr a b))
    "变量表达式构造" (VarExpr "x") var_expr

let test_binary_operations () =
  let add_expr = make_binary_op (make_int 1) Add (make_int 2) in
  let sub_expr = make_binary_op (make_int 5) Sub (make_int 3) in

  check
    (testable
       (fun fmt expr ->
         match expr with
         | BinaryOpExpr (left, op, right) ->
             Format.fprintf fmt "BinaryOpExpr(%s, %s, %s)"
               (match left with LitExpr (IntLit i) -> string_of_int i | _ -> "?")
               (show_binary_op op)
               (match right with LitExpr (IntLit i) -> string_of_int i | _ -> "?")
         | _ -> Format.fprintf fmt "Other")
       (fun a b -> equal_expr a b))
    "加法表达式构造"
    (BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)))
    add_expr;

  check
    (testable
       (fun fmt expr ->
         match expr with
         | BinaryOpExpr (left, op, right) ->
             Format.fprintf fmt "BinaryOpExpr(%s, %s, %s)"
               (match left with LitExpr (IntLit i) -> string_of_int i | _ -> "?")
               (show_binary_op op)
               (match right with LitExpr (IntLit i) -> string_of_int i | _ -> "?")
         | _ -> Format.fprintf fmt "Other")
       (fun a b -> equal_expr a b))
    "减法表达式构造"
    (BinaryOpExpr (LitExpr (IntLit 5), Sub, LitExpr (IntLit 3)))
    sub_expr

let test_function_call () =
  let func_expr = make_var "print" in
  let args = [ make_string "hello"; make_int 42 ] in
  let call_expr = make_call func_expr args in

  check
    (testable
       (fun fmt expr ->
         match expr with
         | FunCallExpr (func, args) ->
             Format.fprintf fmt "FunCallExpr(%s, [%d args])"
               (match func with VarExpr name -> name | _ -> "?")
               (List.length args)
         | _ -> Format.fprintf fmt "Other")
       (fun a b -> equal_expr a b))
    "函数调用表达式构造"
    (FunCallExpr (VarExpr "print", [ LitExpr (StringLit "hello"); LitExpr (IntLit 42) ]))
    call_expr

let test_poetry_types () =
  let four_char = FourCharPoetry in
  let five_char = FiveCharPoetry in
  let seven_char = SevenCharPoetry in
  let parallel_prose = ParallelProse in

  check (testable pp_poetry_form equal_poetry_form) "四言诗类型" FourCharPoetry four_char;
  check (testable pp_poetry_form equal_poetry_form) "五言诗类型" FiveCharPoetry five_char;
  check (testable pp_poetry_form equal_poetry_form) "七言诗类型" SevenCharPoetry seven_char;
  check (testable pp_poetry_form equal_poetry_form) "骈体文类型" ParallelProse parallel_prose

let test_tone_patterns () =
  let level_tone = LevelTone in
  let falling_tone = FallingTone in
  let rising_tone = RisingTone in
  let departing_tone = DepartingTone in
  let entering_tone = EnteringTone in

  check (testable pp_tone_type equal_tone_type) "平声" LevelTone level_tone;
  check (testable pp_tone_type equal_tone_type) "仄声" FallingTone falling_tone;
  check (testable pp_tone_type equal_tone_type) "上声" RisingTone rising_tone;
  check (testable pp_tone_type equal_tone_type) "去声" DepartingTone departing_tone;
  check (testable pp_tone_type equal_tone_type) "入声" EnteringTone entering_tone

let test_complex_expressions () =
  let nested_expr =
    make_binary_op
      (make_binary_op (make_int 1) Add (make_int 2))
      Mul
      (make_binary_op (make_int 3) Sub (make_int 4))
  in

  check
    (testable
       (fun fmt expr ->
         match expr with
         | BinaryOpExpr
             ( BinaryOpExpr (LitExpr (IntLit i1), op1, LitExpr (IntLit i2)),
               op_main,
               BinaryOpExpr (LitExpr (IntLit i3), op2, LitExpr (IntLit i4)) ) ->
             Format.fprintf fmt
               "BinaryOpExpr(BinaryOpExpr(%d, %s, %d), %s, BinaryOpExpr(%d, %s, %d))" i1
               (show_binary_op op1) i2 (show_binary_op op_main) i3 (show_binary_op op2) i4
         | _ -> Format.fprintf fmt "Other")
       (fun a b -> equal_expr a b))
    "复杂嵌套表达式"
    (BinaryOpExpr
       ( BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)),
         Mul,
         BinaryOpExpr (LitExpr (IntLit 3), Sub, LitExpr (IntLit 4)) ))
    nested_expr

let test_rhyme_info () =
  let rhyme = { rhyme_category = "东韵"; rhyme_position = 1; rhyme_pattern = "平水韵" } in

  check (testable pp_rhyme_info equal_rhyme_info) "韵律信息构造" rhyme rhyme

let test_tone_patterns_complex () =
  let pattern =
    {
      tone_sequence = [ LevelTone; FallingTone; RisingTone ];
      tone_constraints = [ AlternatingTones; ParallelTones ];
    }
  in

  check (testable pp_tone_pattern equal_tone_pattern) "复杂音调模式" pattern pattern

let test_meter_constraints () =
  let meter =
    {
      character_count = 5;
      syllable_pattern = Some "平平仄仄平";
      caesura_position = Some 3;
      rhyme_scheme = Some "AABA";
    }
  in

  check (testable pp_meter_constraint equal_meter_constraint) "韵律约束" meter meter

let () =
  run "AST模块单元测试"
    [
      ( "AST构造测试",
        [
          test_case "基本表达式构造" `Quick test_ast_construction;
          test_case "二元运算表达式" `Quick test_binary_operations;
          test_case "函数调用表达式" `Quick test_function_call;
          test_case "复杂嵌套表达式" `Quick test_complex_expressions;
        ] );
      ( "古典诗词特性测试",
        [
          test_case "诗词形式类型" `Quick test_poetry_types;
          test_case "音调类型" `Quick test_tone_patterns;
          test_case "韵律信息" `Quick test_rhyme_info;
          test_case "复杂音调模式" `Quick test_tone_patterns_complex;
          test_case "韵律约束" `Quick test_meter_constraints;
        ] );
    ]
