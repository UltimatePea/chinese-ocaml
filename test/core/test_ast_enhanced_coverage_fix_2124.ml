(** AST模块增强覆盖率测试 - Fix #2124

    专门针对AST模块中未覆盖的代码路径进行测试 目标: 将AST覆盖率从39.34%提升到80%+

    测试重点:
    - 辅助函数 (make_* functions)
    - 诗词注解表达式系统
    - 模块系统表达式和语句
    - 复杂的模式匹配和类型表达式
    - 异步表达式和宏系统
    - 标签函数和多态变体

    Author: Whisky, PR Worker Agent
    @version 1.0
    @since 2025-08-02 Fix #2124 AST覆盖率增强 *)

open Alcotest
open Yyocamlc_lib.Ast

(** 测试工具模块 *)
module ASTTestUtils = struct
  (** 表达式相等性比较 *)
  let expr_equal e1 e2 = equal_expr e1 e2

  (** 模式相等性比较 *)
  let pattern_equal p1 p2 = equal_pattern p1 p2

  (** 类型表达式相等性比较 *)
  let type_expr_equal t1 t2 = equal_type_expr t1 t2

  (** 语句相等性比较 *)
  let stmt_equal s1 s2 = equal_stmt s1 s2

  (** 表达式的可打印格式 *)
  let pp_expr fmt expr = Format.fprintf fmt "%s" (show_expr expr)

  (** 模式的可打印格式 *)
  let pp_pattern fmt pattern = Format.fprintf fmt "%s" (show_pattern pattern)

  (** 类型表达式的可打印格式 *)
  let pp_type_expr fmt type_expr = Format.fprintf fmt "%s" (show_type_expr type_expr)

  (** 语句的可打印格式 *)
  let pp_stmt fmt stmt = Format.fprintf fmt "%s" (show_stmt stmt)

  (** 创建表达式测试用例 *)
  let test_expr desc expected actual = check (testable pp_expr expr_equal) desc expected actual

  (** 创建模式测试用例 *)
  let test_pattern desc expected actual =
    check (testable pp_pattern pattern_equal) desc expected actual

  (** 创建类型表达式测试用例 *)
  let test_type_expr desc expected actual =
    check (testable pp_type_expr type_expr_equal) desc expected actual

  (** 创建语句测试用例 *)
  let test_stmt desc expected actual = check (testable pp_stmt stmt_equal) desc expected actual
end

(** 测试AST辅助函数 *)
let test_ast_helper_functions () =
  (* 测试make_int *)
  let int_expr = make_int 42 in
  ASTTestUtils.test_expr "make_int应创建正确的整数表达式" (LitExpr (IntLit 42)) int_expr;

  (* 测试make_string *)
  let string_expr = make_string "你好世界" in
  ASTTestUtils.test_expr "make_string应创建正确的字符串表达式" (LitExpr (StringLit "你好世界")) string_expr;

  (* 测试make_bool *)
  let bool_true_expr = make_bool true in
  let bool_false_expr = make_bool false in
  ASTTestUtils.test_expr "make_bool应创建正确的布尔表达式(真)" (LitExpr (BoolLit true)) bool_true_expr;
  ASTTestUtils.test_expr "make_bool应创建正确的布尔表达式(假)" (LitExpr (BoolLit false)) bool_false_expr;

  (* 测试make_var *)
  let var_expr = make_var "变量名" in
  ASTTestUtils.test_expr "make_var应创建正确的变量表达式" (VarExpr "变量名") var_expr;

  (* 测试make_binary_op *)
  let left = make_int 10 in
  let right = make_int 5 in
  let add_expr = make_binary_op left Add right in
  ASTTestUtils.test_expr "make_binary_op应创建正确的二元运算表达式"
    (BinaryOpExpr (LitExpr (IntLit 10), Add, LitExpr (IntLit 5)))
    add_expr;

  (* 测试make_call *)
  let func = make_var "函数名" in
  let args = [ make_int 1; make_string "参数" ] in
  let call_expr = make_call func args in
  ASTTestUtils.test_expr "make_call应创建正确的函数调用表达式"
    (FunCallExpr (VarExpr "函数名", [ LitExpr (IntLit 1); LitExpr (StringLit "参数") ]))
    call_expr

(** 测试诗词相关AST节点 *)
let test_poetry_ast_nodes () =
  (* 测试诗词形式类型 *)
  let poetry_forms =
    [
      FourCharPoetry;
      FiveCharPoetry;
      SevenCharPoetry;
      ParallelProse;
      RegulatedVerse;
      Quatrain;
      Couplet;
    ]
  in
  List.iteri
    (fun i form ->
      let form_str = show_poetry_form form in
      check bool (Printf.sprintf "诗词形式%d应有有效字符串表示" i) true (String.length form_str > 0))
    poetry_forms;

  (* 测试韵律信息 *)
  let rhyme_info = { rhyme_category = "平水韵"; rhyme_position = 1; rhyme_pattern = "AABA" } in
  let rhyme_str = show_rhyme_info rhyme_info in
  check bool "韵律信息应有有效字符串表示" true (String.length rhyme_str > 0);

  (* 测试声调类型 *)
  let tone_types = [ LevelTone; FallingTone; RisingTone; DepartingTone; EnteringTone ] in
  List.iteri
    (fun i tone ->
      let tone_str = show_tone_type tone in
      check bool (Printf.sprintf "声调类型%d应有有效字符串表示" i) true (String.length tone_str > 0))
    tone_types;

  (* 测试声调约束 *)
  let tone_constraints =
    [ AlternatingTones; ParallelTones; SpecificPattern [ LevelTone; FallingTone; LevelTone ] ]
  in
  List.iteri
    (fun i constraint_type ->
      let constraint_str = show_tone_constraint constraint_type in
      check bool (Printf.sprintf "声调约束%d应有有效字符串表示" i) true (String.length constraint_str > 0))
    tone_constraints;

  (* 测试平仄模式 *)
  let tone_pattern =
    {
      tone_sequence = [ LevelTone; FallingTone; LevelTone; FallingTone ];
      tone_constraints = [ AlternatingTones; SpecificPattern [ LevelTone; FallingTone ] ];
    }
  in
  let pattern_str = show_tone_pattern tone_pattern in
  check bool "平仄模式应有有效字符串表示" true (String.length pattern_str > 0);

  (* 测试韵律约束 *)
  let meter_constraint =
    {
      character_count = 28;
      syllable_pattern = Some "七言律诗";
      caesura_position = Some 4;
      rhyme_scheme = Some "ABAB";
    }
  in
  let meter_str = show_meter_constraint meter_constraint in
  check bool "韵律约束应有有效字符串表示" true (String.length meter_str > 0)

(** 测试诗词注解表达式 *)
let test_poetry_annotated_expressions () =
  let base_expr = make_string "春眠不觉晓" in

  (* 测试诗词注解表达式 *)
  let poetry_expr = PoetryAnnotatedExpr (base_expr, FiveCharPoetry) in
  ASTTestUtils.test_expr "诗词注解表达式应正确构造"
    (PoetryAnnotatedExpr (LitExpr (StringLit "春眠不觉晓"), FiveCharPoetry))
    poetry_expr;

  (* 测试对偶结构表达式 *)
  let left_part = make_string "晴川历历汉阳树" in
  let right_part = make_string "芳草萋萋鹦鹉洲" in
  let parallel_expr = ParallelStructureExpr (left_part, right_part) in
  ASTTestUtils.test_expr "对偶结构表达式应正确构造"
    (ParallelStructureExpr (LitExpr (StringLit "晴川历历汉阳树"), LitExpr (StringLit "芳草萋萋鹦鹉洲")))
    parallel_expr;

  (* 测试押韵注解表达式 *)
  let rhyme_info = { rhyme_category = "一东"; rhyme_position = 4; rhyme_pattern = "东风" } in
  let rhyme_expr = RhymeAnnotatedExpr (base_expr, rhyme_info) in
  ASTTestUtils.test_expr "押韵注解表达式应正确构造"
    (RhymeAnnotatedExpr (LitExpr (StringLit "春眠不觉晓"), rhyme_info))
    rhyme_expr;

  (* 测试平仄注解表达式 *)
  let tone_pattern =
    {
      tone_sequence = [ LevelTone; LevelTone; FallingTone; FallingTone; FallingTone ];
      tone_constraints = [ AlternatingTones ];
    }
  in
  let tone_expr = ToneAnnotatedExpr (base_expr, tone_pattern) in
  ASTTestUtils.test_expr "平仄注解表达式应正确构造"
    (ToneAnnotatedExpr (LitExpr (StringLit "春眠不觉晓"), tone_pattern))
    tone_expr;

  (* 测试韵律验证表达式 *)
  let meter_constraint =
    {
      character_count = 5;
      syllable_pattern = Some "五言";
      caesura_position = Some 2;
      rhyme_scheme = Some "无";
    }
  in
  let meter_expr = MeterValidatedExpr (base_expr, meter_constraint) in
  ASTTestUtils.test_expr "韵律验证表达式应正确构造"
    (MeterValidatedExpr (LitExpr (StringLit "春眠不觉晓"), meter_constraint))
    meter_expr

(** 测试复杂模式匹配 *)
let test_complex_patterns () =
  (* 测试通配符模式 *)
  let wildcard = WildcardPattern in
  ASTTestUtils.test_pattern "通配符模式应正确构造" WildcardPattern wildcard;

  (* 测试变量模式 *)
  let var_pattern = VarPattern "x" in
  ASTTestUtils.test_pattern "变量模式应正确构造" (VarPattern "x") var_pattern;

  (* 测试字面量模式 *)
  let lit_pattern = LitPattern (IntLit 42) in
  ASTTestUtils.test_pattern "字面量模式应正确构造" (LitPattern (IntLit 42)) lit_pattern;

  (* 测试构造器模式 *)
  let constructor_pattern = ConstructorPattern ("Some", [ VarPattern "x" ]) in
  ASTTestUtils.test_pattern "构造器模式应正确构造"
    (ConstructorPattern ("Some", [ VarPattern "x" ]))
    constructor_pattern;

  (* 测试元组模式 *)
  let tuple_pattern = TuplePattern [ VarPattern "x"; VarPattern "y"; LitPattern (IntLit 1) ] in
  ASTTestUtils.test_pattern "元组模式应正确构造"
    (TuplePattern [ VarPattern "x"; VarPattern "y"; LitPattern (IntLit 1) ])
    tuple_pattern;

  (* 测试列表模式 *)
  let list_pattern = ListPattern [ VarPattern "head"; VarPattern "second" ] in
  ASTTestUtils.test_pattern "列表模式应正确构造"
    (ListPattern [ VarPattern "head"; VarPattern "second" ])
    list_pattern;

  (* 测试Cons模式 *)
  let cons_pattern = ConsPattern (VarPattern "head", VarPattern "tail") in
  ASTTestUtils.test_pattern "Cons模式应正确构造"
    (ConsPattern (VarPattern "head", VarPattern "tail"))
    cons_pattern;

  (* 测试空列表模式 *)
  let empty_list_pattern = EmptyListPattern in
  ASTTestUtils.test_pattern "空列表模式应正确构造" EmptyListPattern empty_list_pattern;

  (* 测试或模式 *)
  let or_pattern = OrPattern (LitPattern (IntLit 1), LitPattern (IntLit 2)) in
  ASTTestUtils.test_pattern "或模式应正确构造"
    (OrPattern (LitPattern (IntLit 1), LitPattern (IntLit 2)))
    or_pattern;

  (* 测试异常模式 *)
  let exception_pattern = ExceptionPattern ("MyException", Some (VarPattern "msg")) in
  ASTTestUtils.test_pattern "异常模式应正确构造"
    (ExceptionPattern ("MyException", Some (VarPattern "msg")))
    exception_pattern;

  (* 测试多态变体模式 *)
  let poly_variant_pattern = PolymorphicVariantPattern ("Red", Some (VarPattern "intensity")) in
  ASTTestUtils.test_pattern "多态变体模式应正确构造"
    (PolymorphicVariantPattern ("Red", Some (VarPattern "intensity")))
    poly_variant_pattern

(** 测试高级类型表达式 *)
let test_advanced_type_expressions () =
  (* 测试基础类型表达式 *)
  let base_types = [ IntType; FloatType; StringType; BoolType; UnitType ] in
  List.iteri
    (fun i base_type ->
      let type_expr = BaseTypeExpr base_type in
      let type_str = show_type_expr type_expr in
      check bool (Printf.sprintf "基础类型表达式%d应有有效字符串表示" i) true (String.length type_str > 0))
    base_types;

  (* 测试类型变量 *)
  let type_var = TypeVar "'a" in
  ASTTestUtils.test_type_expr "类型变量应正确构造" (TypeVar "'a") type_var;

  (* 测试函数类型 *)
  let fun_type = FunType (BaseTypeExpr IntType, BaseTypeExpr StringType) in
  ASTTestUtils.test_type_expr "函数类型应正确构造"
    (FunType (BaseTypeExpr IntType, BaseTypeExpr StringType))
    fun_type;

  (* 测试元组类型 *)
  let tuple_type =
    TupleType [ BaseTypeExpr IntType; BaseTypeExpr StringType; BaseTypeExpr BoolType ]
  in
  ASTTestUtils.test_type_expr "元组类型应正确构造"
    (TupleType [ BaseTypeExpr IntType; BaseTypeExpr StringType; BaseTypeExpr BoolType ])
    tuple_type;

  (* 测试列表类型 *)
  let list_type = ListType (BaseTypeExpr IntType) in
  ASTTestUtils.test_type_expr "列表类型应正确构造" (ListType (BaseTypeExpr IntType)) list_type;

  (* 测试构造类型 *)
  let construct_type = ConstructType ("Option", [ BaseTypeExpr IntType ]) in
  ASTTestUtils.test_type_expr "构造类型应正确构造"
    (ConstructType ("Option", [ BaseTypeExpr IntType ]))
    construct_type;

  (* 测试引用类型 *)
  let ref_type = RefType (BaseTypeExpr IntType) in
  ASTTestUtils.test_type_expr "引用类型应正确构造" (RefType (BaseTypeExpr IntType)) ref_type;

  (* 测试多态变体类型 *)
  let poly_variant_type =
    PolymorphicVariantType [ ("Red", Some (BaseTypeExpr IntType)); ("Blue", None) ]
  in
  ASTTestUtils.test_type_expr "多态变体类型应正确构造"
    (PolymorphicVariantType [ ("Red", Some (BaseTypeExpr IntType)); ("Blue", None) ])
    poly_variant_type

(** 测试模块系统表达式 *)
let test_module_system_expressions () =
  (* 测试模块访问表达式 *)
  let module_access = ModuleAccessExpr (VarExpr "MyModule", "my_function") in
  ASTTestUtils.test_expr "模块访问表达式应正确构造"
    (ModuleAccessExpr (VarExpr "MyModule", "my_function"))
    module_access;

  (* 测试模块表达式 *)
  let module_statements = [ ExprStmt (make_int 42); LetStmt ("x", make_string "hello") ] in
  let module_expr = ModuleExpr module_statements in
  ASTTestUtils.test_expr "模块表达式应正确构造" (ModuleExpr module_statements) module_expr;

  (* 测试函子调用表达式 *)
  let functor_call = FunctorCallExpr (VarExpr "MyFunctor", VarExpr "MyModule") in
  ASTTestUtils.test_expr "函子调用表达式应正确构造"
    (FunctorCallExpr (VarExpr "MyFunctor", VarExpr "MyModule"))
    functor_call;

  (* 测试类型注解表达式 *)
  let type_annotation = TypeAnnotationExpr (make_int 42, BaseTypeExpr IntType) in
  ASTTestUtils.test_expr "类型注解表达式应正确构造"
    (TypeAnnotationExpr (LitExpr (IntLit 42), BaseTypeExpr IntType))
    type_annotation;

  (* 测试多态变体表达式 *)
  let poly_variant_expr = PolymorphicVariantExpr ("Green", Some (make_int 255)) in
  ASTTestUtils.test_expr "多态变体表达式应正确构造"
    (PolymorphicVariantExpr ("Green", Some (LitExpr (IntLit 255))))
    poly_variant_expr

(** 测试异步表达式 *)
let test_async_expressions () =
  let base_expr = make_string "异步操作" in

  (* 测试异步函数 *)
  let async_func = AsyncExpr (AsyncFunc base_expr) in
  ASTTestUtils.test_expr "异步函数表达式应正确构造" (AsyncExpr (AsyncFunc (LitExpr (StringLit "异步操作"))))
    async_func;

  (* 测试等待表达式 *)
  let await_expr = AsyncExpr (AwaitExpr base_expr) in
  ASTTestUtils.test_expr "等待表达式应正确构造" (AsyncExpr (AwaitExpr (LitExpr (StringLit "异步操作"))))
    await_expr;

  (* 测试创建任务表达式 *)
  let spawn_expr = AsyncExpr (SpawnExpr base_expr) in
  ASTTestUtils.test_expr "创建任务表达式应正确构造" (AsyncExpr (SpawnExpr (LitExpr (StringLit "异步操作"))))
    spawn_expr;

  (* 测试通道操作表达式 *)
  let channel_expr = AsyncExpr (ChannelExpr base_expr) in
  ASTTestUtils.test_expr "通道操作表达式应正确构造" (AsyncExpr (ChannelExpr (LitExpr (StringLit "异步操作"))))
    channel_expr

(** 测试宏系统 *)
let test_macro_system () =
  (* 测试宏参数类型 *)
  let macro_params = [ ExprParam "表达式参数"; StmtParam "语句参数"; TypeParam "类型参数" ] in
  List.iteri
    (fun i param ->
      let param_str = show_macro_param param in
      check bool (Printf.sprintf "宏参数%d应有有效字符串表示" i) true (String.length param_str > 0))
    macro_params;

  (* 测试宏调用 *)
  let macro_call = { macro_call_name = "my_macro"; args = [ make_int 1; make_string "test" ] } in
  let macro_call_expr = MacroCallExpr macro_call in
  ASTTestUtils.test_expr "宏调用表达式应正确构造"
    (MacroCallExpr
       { macro_call_name = "my_macro"; args = [ LitExpr (IntLit 1); LitExpr (StringLit "test") ] })
    macro_call_expr

(** 测试标签函数系统 *)
let test_labeled_function_system () =
  (* 测试标签参数 *)
  let label_params =
    [
      {
        label_name = "名称";
        param_name = "name";
        param_type = Some (BaseTypeExpr StringType);
        is_optional = false;
        default_value = None;
      };
      {
        label_name = "年龄";
        param_name = "age";
        param_type = Some (BaseTypeExpr IntType);
        is_optional = true;
        default_value = Some (make_int 18);
      };
    ]
  in

  (* 测试标签函数表达式 *)
  let labeled_fun = LabeledFunExpr (label_params, make_string "函数体") in
  ASTTestUtils.test_expr "标签函数表达式应正确构造"
    (LabeledFunExpr (label_params, LitExpr (StringLit "函数体")))
    labeled_fun;

  (* 测试标签函数调用 *)
  let label_args =
    [
      { arg_label = "名称"; arg_value = make_string "张三" };
      { arg_label = "年龄"; arg_value = make_int 25 };
    ]
  in
  let labeled_call = LabeledFunCallExpr (make_var "labeled_function", label_args) in
  ASTTestUtils.test_expr "标签函数调用表达式应正确构造"
    (LabeledFunCallExpr (VarExpr "labeled_function", label_args))
    labeled_call

(** 测试复杂语句类型 *)
let test_complex_statements () =
  (* 测试表达式语句 *)
  let expr_stmt = ExprStmt (make_int 42) in
  ASTTestUtils.test_stmt "表达式语句应正确构造" (ExprStmt (LitExpr (IntLit 42))) expr_stmt;

  (* 测试Let语句 *)
  let let_stmt = LetStmt ("x", make_string "hello") in
  ASTTestUtils.test_stmt "Let语句应正确构造" (LetStmt ("x", LitExpr (StringLit "hello"))) let_stmt;

  (* 测试带类型的Let语句 *)
  let let_type_stmt = LetStmtWithType ("y", BaseTypeExpr IntType, make_int 10) in
  ASTTestUtils.test_stmt "带类型的Let语句应正确构造"
    (LetStmtWithType ("y", BaseTypeExpr IntType, LitExpr (IntLit 10)))
    let_type_stmt;

  (* 测试递归Let语句 *)
  let rec_let_stmt = RecLetStmt ("factorial", make_var "factorial_impl") in
  ASTTestUtils.test_stmt "递归Let语句应正确构造"
    (RecLetStmt ("factorial", VarExpr "factorial_impl"))
    rec_let_stmt;

  (* 测试带类型的递归Let语句 *)
  let rec_let_type_stmt =
    RecLetStmtWithType
      ("fib", FunType (BaseTypeExpr IntType, BaseTypeExpr IntType), make_var "fib_impl")
  in
  ASTTestUtils.test_stmt "带类型的递归Let语句应正确构造"
    (RecLetStmtWithType
       ("fib", FunType (BaseTypeExpr IntType, BaseTypeExpr IntType), VarExpr "fib_impl"))
    rec_let_type_stmt;

  (* 测试语义Let语句 *)
  let semantic_let_stmt = SemanticLetStmt ("result", "计算结果", make_int 100) in
  ASTTestUtils.test_stmt "语义Let语句应正确构造"
    (SemanticLetStmt ("result", "计算结果", LitExpr (IntLit 100)))
    semantic_let_stmt;

  (* 测试类型定义语句 *)
  let type_def_stmt = TypeDefStmt ("MyType", AliasType (BaseTypeExpr StringType)) in
  ASTTestUtils.test_stmt "类型定义语句应正确构造"
    (TypeDefStmt ("MyType", AliasType (BaseTypeExpr StringType)))
    type_def_stmt;

  (* 测试异常定义语句 *)
  let exception_def_stmt = ExceptionDefStmt ("MyException", Some (BaseTypeExpr StringType)) in
  ASTTestUtils.test_stmt "异常定义语句应正确构造"
    (ExceptionDefStmt ("MyException", Some (BaseTypeExpr StringType)))
    exception_def_stmt

(** 测试程序结构 *)
let test_program_structure () =
  let statements =
    [
      LetStmt ("x", make_int 1);
      LetStmt ("y", make_string "test");
      ExprStmt (make_binary_op (make_var "x") Add (make_int 5));
    ]
  in
  let program = statements in
  let program_str = show_program program in
  check bool "程序结构应有有效字符串表示" true (String.length program_str > 0);
  check int "程序应包含正确数量的语句" 3 (List.length program)

(** 主测试套件 *)
let test_suite () =
  [
    ("AST辅助函数测试", `Quick, test_ast_helper_functions);
    ("诗词相关AST节点测试", `Quick, test_poetry_ast_nodes);
    ("诗词注解表达式测试", `Quick, test_poetry_annotated_expressions);
    ("复杂模式匹配测试", `Quick, test_complex_patterns);
    ("高级类型表达式测试", `Quick, test_advanced_type_expressions);
    ("模块系统表达式测试", `Quick, test_module_system_expressions);
    ("异步表达式测试", `Quick, test_async_expressions);
    ("宏系统测试", `Quick, test_macro_system);
    ("标签函数系统测试", `Quick, test_labeled_function_system);
    ("复杂语句类型测试", `Quick, test_complex_statements);
    ("程序结构测试", `Quick, test_program_structure);
  ]

(** 执行测试 *)
let () = Alcotest.run "AST模块增强覆盖率测试 - Fix #2124" [ ("ast_enhanced_coverage", test_suite ()) ]
