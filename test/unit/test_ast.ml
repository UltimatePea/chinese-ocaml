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

(** 诗词相关类型测试 *)
let test_poetry_types () =
  (* 测试诗词形式枚举 *)
  let five_char = FiveCharPoetry in
  let seven_char = SevenCharPoetry in
  let quatrain = Quatrain in
  
  check (testable pp_poetry_form equal_poetry_form) "五言诗类型" FiveCharPoetry five_char;
  check (testable pp_poetry_form equal_poetry_form) "七言诗类型" SevenCharPoetry seven_char;
  check (testable pp_poetry_form equal_poetry_form) "绝句类型" Quatrain quatrain;
  
  (* 测试韵律信息结构 *)
  let rhyme_info = {
    rhyme_category = "平声";
    rhyme_position = 4;
    rhyme_pattern = "AABA";
  } in
  
  check (testable pp_rhyme_info equal_rhyme_info) "韵律信息构造" 
    { rhyme_category = "平声"; rhyme_position = 4; rhyme_pattern = "AABA" }
    rhyme_info;
    
  (* 测试声调类型 *)
  let level_tone = LevelTone in
  let falling_tone = FallingTone in
  
  check (testable pp_tone_type equal_tone_type) "平声类型" LevelTone level_tone;
  check (testable pp_tone_type equal_tone_type) "仄声类型" FallingTone falling_tone;
  
  (* 测试声调约束 *)
  let alternating = AlternatingTones in
  let parallel = ParallelTones in
  let specific = SpecificPattern [LevelTone; FallingTone; LevelTone] in
  
  check (testable pp_tone_constraint equal_tone_constraint) "平仄交替约束" AlternatingTones alternating;
  check (testable pp_tone_constraint equal_tone_constraint) "平仄对仗约束" ParallelTones parallel;
  check (testable pp_tone_constraint equal_tone_constraint) "特定平仄模式" 
    (SpecificPattern [LevelTone; FallingTone; LevelTone]) specific

let test_poetry_expressions () =
  (* 测试诗词注解表达式 *)
  let base_expr = make_string "春眠不觉晓" in
  let poetry_expr = PoetryAnnotatedExpr (base_expr, FiveCharPoetry) in
  
  check (testable pp_expr equal_expr) "诗词注解表达式"
    (PoetryAnnotatedExpr (LitExpr (StringLit "春眠不觉晓"), FiveCharPoetry))
    poetry_expr;
    
  (* 测试押韵注解表达式 *)
  let rhyme_info = {
    rhyme_category = "平声";
    rhyme_position = 4;
    rhyme_pattern = "AABA";
  } in
  let rhyme_expr = RhymeAnnotatedExpr (base_expr, rhyme_info) in
  
  check (testable pp_expr equal_expr) "押韵注解表达式"
    (RhymeAnnotatedExpr (LitExpr (StringLit "春眠不觉晓"), rhyme_info))
    rhyme_expr;
    
  (* 测试平仄注解表达式 *)
  let tone_pattern = {
    tone_sequence = [LevelTone; FallingTone; LevelTone; FallingTone; LevelTone];
    tone_constraints = [AlternatingTones];
  } in
  let tone_expr = ToneAnnotatedExpr (base_expr, tone_pattern) in
  
  check (testable pp_expr equal_expr) "平仄注解表达式"
    (ToneAnnotatedExpr (LitExpr (StringLit "春眠不觉晓"), tone_pattern))
    tone_expr;
    
  (* 测试对偶结构表达式 *)
  let left_part = make_string "春眠不觉晓" in
  let right_part = make_string "处处闻啼鸟" in
  let parallel_expr = ParallelStructureExpr (left_part, right_part) in
  
  check (testable pp_expr equal_expr) "对偶结构表达式"
    (ParallelStructureExpr (LitExpr (StringLit "春眠不觉晓"), LitExpr (StringLit "处处闻啼鸟")))
    parallel_expr

let test_meter_constraints () =
  (* 测试韵律约束 *)
  let basic_constraint = {
    character_count = 5;
    syllable_pattern = Some "平仄平仄平";
    caesura_position = Some 2;
    rhyme_scheme = Some "ABAB";
  } in
  
  check (testable pp_meter_constraint equal_meter_constraint) "基础韵律约束"
    { character_count = 5; syllable_pattern = Some "平仄平仄平"; 
      caesura_position = Some 2; rhyme_scheme = Some "ABAB" }
    basic_constraint;
    
  (* 测试韵律验证表达式 *)
  let base_expr = make_string "白日依山尽" in
  let validated_expr = MeterValidatedExpr (base_expr, basic_constraint) in
  
  check (testable pp_expr equal_expr) "韵律验证表达式"
    (MeterValidatedExpr (LitExpr (StringLit "白日依山尽"), basic_constraint))
    validated_expr

let test_complex_poetry_structures () =
  (* 测试复杂诗词结构组合 *)
  let rhyme_info = {
    rhyme_category = "平声";
    rhyme_position = 4;
    rhyme_pattern = "AABA";
  } in
  
  let meter_constraint = {
    character_count = 7;
    syllable_pattern = Some "平仄仄平平仄仄";
    caesura_position = Some 4;
    rhyme_scheme = Some "AABA";
  } in
  
  (* 嵌套的诗词表达式：韵律验证 + 押韵注解 + 诗词形式 *)
  let base_expr = make_string "床前明月光疑是地上霜" in
  let rhyme_annotated = RhymeAnnotatedExpr (base_expr, rhyme_info) in
  let meter_validated = MeterValidatedExpr (rhyme_annotated, meter_constraint) in
  let poetry_annotated = PoetryAnnotatedExpr (meter_validated, SevenCharPoetry) in
  
  check (testable pp_expr equal_expr) "复杂诗词结构组合"
    (PoetryAnnotatedExpr (
      MeterValidatedExpr (
        RhymeAnnotatedExpr (LitExpr (StringLit "床前明月光疑是地上霜"), rhyme_info),
        meter_constraint
      ),
      SevenCharPoetry
    ))
    poetry_annotated

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
      ( "诗词类型测试",
        [
          test_case "诗词相关类型" `Quick test_poetry_types;
          test_case "韵律约束测试" `Quick test_meter_constraints;
        ] );
      ( "诗词表达式测试",
        [
          test_case "诗词注解表达式" `Quick test_poetry_expressions;
          test_case "复杂诗词结构" `Quick test_complex_poetry_structures;
        ] );
    ]
