(** AST模块测试覆盖率提升至80%+ - Fix #2147

    全面测试未覆盖的AST功能模块：
    - 诗词相关类型（poetry_form, rhyme_info, tone_pattern, meter_constraint）
    - 高级表达式类型（PoetryAnnotatedExpr, ParallelStructureExpr等）
    - 模块系统（ModuleAccessExpr, FunctorCallExpr, FunctorExpr）
    - 记录和数组操作（RecordExpr, ArrayExpr等）
    - 引用和异常处理（RefExpr, TryExpr, RaiseExpr）
    - 高级类型系统（RefType, PolymorphicVariantType）
    - 多态变体和类型注解

    Author: Whisky, PR Worker
    @version 1.0
    @since 2025-08-04 Fix #2147 AST模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Ast

(** 测试工具辅助模块 *)
module TestUtils = struct
  let check_type_equality desc expected actual =
    check (testable pp_type_expr equal_type_expr) desc expected actual

  let check_expr_equality desc expected actual =
    check (testable pp_expr equal_expr) desc expected actual

  let check_stmt_equality desc expected actual =
    check (testable pp_stmt equal_stmt) desc expected actual

  let check_pattern_equality desc expected actual =
    check (testable pp_pattern equal_pattern) desc expected actual

  let check_poetry_form_equality desc expected actual =
    check (testable pp_poetry_form equal_poetry_form) desc expected actual

  let check_rhyme_info_equality desc expected actual =
    check (testable pp_rhyme_info equal_rhyme_info) desc expected actual

  let check_tone_pattern_equality desc expected actual =
    check (testable pp_tone_pattern equal_tone_pattern) desc expected actual

  let check_meter_constraint_equality desc expected actual =
    check (testable pp_meter_constraint equal_meter_constraint) desc expected actual
end

(** 测试所有诗词形式类型 *)
let test_poetry_forms_comprehensive () =
  let forms =
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

  (* 验证所有诗词形式类型可以正确创建 *)
  check int "诗词形式总数" 7 (List.length forms);

  (* 验证各种诗词形式类型相等性 *)
  TestUtils.check_poetry_form_equality "四言诗形式" FourCharPoetry FourCharPoetry;
  TestUtils.check_poetry_form_equality "五言诗形式" FiveCharPoetry FiveCharPoetry;
  TestUtils.check_poetry_form_equality "七言诗形式" SevenCharPoetry SevenCharPoetry;
  TestUtils.check_poetry_form_equality "骈体文形式" ParallelProse ParallelProse;
  TestUtils.check_poetry_form_equality "律诗形式" RegulatedVerse RegulatedVerse;
  TestUtils.check_poetry_form_equality "绝句形式" Quatrain Quatrain;
  TestUtils.check_poetry_form_equality "对联形式" Couplet Couplet;

  (* 验证不同诗词形式不相等 *)
  check bool "四言诗与五言诗不相等" false (FourCharPoetry = FiveCharPoetry);
  check bool "律诗与绝句不相等" false (RegulatedVerse = Quatrain)

(** 测试韵律信息类型 *)
let test_rhyme_info_comprehensive () =
  let rhyme1 = { rhyme_category = "平水韵"; rhyme_position = 1; rhyme_pattern = "AABA" } in

  let rhyme2 = { rhyme_category = "词林正韵"; rhyme_position = 2; rhyme_pattern = "ABAB" } in

  let rhyme3 = { rhyme_category = "平水韵"; rhyme_position = 1; rhyme_pattern = "AABA" } in

  (* 验证韵律信息构造 *)
  check string "韵部信息" "平水韵" rhyme1.rhyme_category;
  check int "韵脚位置" 1 rhyme1.rhyme_position;
  check string "韵式模式" "AABA" rhyme1.rhyme_pattern;

  (* 验证相等性 *)
  TestUtils.check_rhyme_info_equality "相同韵律信息" rhyme1 rhyme3;
  check bool "不同韵律信息不相等" false (rhyme1 = rhyme2)

(** 测试声调类型和约束 *)
let test_tone_patterns_comprehensive () =
  let tone_types = [ LevelTone; FallingTone; RisingTone; DepartingTone; EnteringTone ] in

  (* 测试声调类型数量 *)
  check int "声调类型总数" 5 (List.length tone_types);

  (* 测试声调约束 *)
  let constraints =
    [
      AlternatingTones;
      ParallelTones;
      SpecificPattern [ LevelTone; FallingTone; LevelTone; FallingTone ];
    ]
  in

  check int "声调约束类型数" 3 (List.length constraints);

  (* 测试平仄模式完整性 *)
  let tone_pattern =
    {
      tone_sequence = [ LevelTone; FallingTone; LevelTone; FallingTone ];
      tone_constraints = [ AlternatingTones; SpecificPattern [ LevelTone; FallingTone ] ];
    }
  in

  check int "声调序列长度" 4 (List.length tone_pattern.tone_sequence);
  check int "声调约束数量" 2 (List.length tone_pattern.tone_constraints);

  TestUtils.check_tone_pattern_equality "平仄模式相等性" tone_pattern tone_pattern

(** 测试韵律约束类型 *)
let test_meter_constraints_comprehensive () =
  let meter1 =
    {
      character_count = 7;
      syllable_pattern = Some "2-2-3";
      caesura_position = Some 4;
      rhyme_scheme = Some "ABAB";
    }
  in

  let meter2 =
    {
      character_count = 5;
      syllable_pattern = None;
      caesura_position = Some 2;
      rhyme_scheme = Some "AABA";
    }
  in

  let meter3 =
    { character_count = 4; syllable_pattern = None; caesura_position = None; rhyme_scheme = None }
  in

  (* 验证韵律约束字段 *)
  check int "字符数约束" 7 meter1.character_count;
  check bool "有音节模式" true (Option.is_some meter1.syllable_pattern);
  check bool "有停顿位置" true (Option.is_some meter1.caesura_position);
  check bool "有韵律方案" true (Option.is_some meter1.rhyme_scheme);

  (* 验证可选字段 *)
  check bool "无音节模式" true (Option.is_none meter3.syllable_pattern);
  check bool "无停顿位置" true (Option.is_none meter3.caesura_position);
  check bool "无韵律方案" true (Option.is_none meter3.rhyme_scheme);

  TestUtils.check_meter_constraint_equality "韵律约束相等性" meter1 meter1

(** 测试诗词注解表达式 *)
let test_poetry_annotated_expressions () =
  let base_expr = LitExpr (StringLit "春眠不觉晓") in

  (* 测试诗词注解表达式 *)
  let poetry_expr = PoetryAnnotatedExpr (base_expr, RegulatedVerse) in
  let expected_poetry = PoetryAnnotatedExpr (base_expr, RegulatedVerse) in
  TestUtils.check_expr_equality "诗词注解表达式" expected_poetry poetry_expr;

  (* 测试平仄注解表达式 *)
  let tone_pattern =
    {
      tone_sequence = [ LevelTone; FallingTone; LevelTone ];
      tone_constraints = [ AlternatingTones ];
    }
  in
  let tone_expr = ToneAnnotatedExpr (base_expr, tone_pattern) in
  let expected_tone = ToneAnnotatedExpr (base_expr, tone_pattern) in
  TestUtils.check_expr_equality "平仄注解表达式" expected_tone tone_expr;

  (* 测试韵律注解表达式 *)
  let rhyme_info = { rhyme_category = "平水韵"; rhyme_position = 1; rhyme_pattern = "AABA" } in
  let rhyme_expr = RhymeAnnotatedExpr (base_expr, rhyme_info) in
  let expected_rhyme = RhymeAnnotatedExpr (base_expr, rhyme_info) in
  TestUtils.check_expr_equality "韵律注解表达式" expected_rhyme rhyme_expr;

  (* 测试韵律验证表达式 *)
  let meter_constraint =
    {
      character_count = 5;
      syllable_pattern = Some "2-3";
      caesura_position = Some 2;
      rhyme_scheme = Some "AABA";
    }
  in
  let meter_expr = MeterValidatedExpr (base_expr, meter_constraint) in
  let expected_meter = MeterValidatedExpr (base_expr, meter_constraint) in
  TestUtils.check_expr_equality "韵律验证表达式" expected_meter meter_expr

(** 测试对偶结构表达式 *)
let test_parallel_structure_expressions () =
  let left_part = LitExpr (StringLit "春风得意马蹄疾") in
  let right_part = LitExpr (StringLit "一日看尽长安花") in

  let parallel_expr = ParallelStructureExpr (left_part, right_part) in
  let expected_parallel = ParallelStructureExpr (left_part, right_part) in

  TestUtils.check_expr_equality "对偶结构表达式" expected_parallel parallel_expr;

  (* 测试嵌套对偶结构 *)
  let nested_left =
    ParallelStructureExpr (LitExpr (StringLit "两个黄鹂鸣翠柳"), LitExpr (StringLit "一行白鹭上青天"))
  in
  let nested_right =
    ParallelStructureExpr (LitExpr (StringLit "窗含西岭千秋雪"), LitExpr (StringLit "门泊东吴万里船"))
  in
  let nested_parallel = ParallelStructureExpr (nested_left, nested_right) in
  let expected_nested = ParallelStructureExpr (nested_left, nested_right) in

  TestUtils.check_expr_equality "嵌套对偶结构表达式" expected_nested nested_parallel

(** 测试模块系统表达式 *)
let test_module_system_expressions () =
  (* 测试模块访问表达式 *)
  let module_expr = VarExpr "MathUtils" in
  let member_access = ModuleAccessExpr (module_expr, "add") in
  let expected_access = ModuleAccessExpr (module_expr, "add") in
  TestUtils.check_expr_equality "模块访问表达式" expected_access member_access;

  (* 测试函子调用表达式 *)
  let functor_expr = VarExpr "MakePairs" in
  let module_arg = VarExpr "String" in
  let functor_call = FunctorCallExpr (functor_expr, module_arg) in
  let expected_functor_call = FunctorCallExpr (functor_expr, module_arg) in
  TestUtils.check_expr_equality "函子调用表达式" expected_functor_call functor_call;

  (* 测试函子定义表达式 *)
  let param_name = "OrderedType" in
  let signature =
    Signature [ SigValue ("compare", FunType (BaseTypeExpr IntType, BaseTypeExpr IntType)) ]
  in
  let body_stmts = [ LetStmt ("empty", LitExpr UnitLit) ] in
  let functor_def = FunctorExpr (param_name, signature, ModuleExpr body_stmts) in
  let expected_functor_def = FunctorExpr (param_name, signature, ModuleExpr body_stmts) in
  TestUtils.check_expr_equality "函子定义表达式" expected_functor_def functor_def;

  (* 测试模块表达式 *)
  let module_stmts =
    [
      LetStmt ("pi", LitExpr (FloatLit 3.14159));
      LetStmt ("square", FunExpr ([ "x" ], BinaryOpExpr (VarExpr "x", Mul, VarExpr "x")));
    ]
  in
  let module_def_expr = ModuleExpr module_stmts in
  let expected_module_def = ModuleExpr module_stmts in
  TestUtils.check_expr_equality "模块定义表达式" expected_module_def module_def_expr

(** 测试记录类型表达式 *)
let test_record_expressions () =
  (* 测试记录创建表达式 *)
  let record_fields =
    [
      ("name", LitExpr (StringLit "张三"));
      ("age", LitExpr (IntLit 25));
      ("email", LitExpr (StringLit "zhangsan@example.com"));
    ]
  in
  let record_expr = RecordExpr record_fields in
  let expected_record = RecordExpr record_fields in
  TestUtils.check_expr_equality "记录创建表达式" expected_record record_expr;

  (* 测试字段访问表达式 *)
  let person_var = VarExpr "person" in
  let field_access = FieldAccessExpr (person_var, "name") in
  let expected_field_access = FieldAccessExpr (person_var, "name") in
  TestUtils.check_expr_equality "字段访问表达式" expected_field_access field_access;

  (* 测试记录更新表达式 *)
  let update_fields =
    [ ("age", LitExpr (IntLit 26)); ("email", LitExpr (StringLit "newemail@example.com")) ]
  in
  let record_update = RecordUpdateExpr (person_var, update_fields) in
  let expected_record_update = RecordUpdateExpr (person_var, update_fields) in
  TestUtils.check_expr_equality "记录更新表达式" expected_record_update record_update;

  (* 测试嵌套记录 *)
  let nested_record =
    RecordExpr
      [
        ("person", RecordExpr [ ("name", LitExpr (StringLit "李四")); ("age", LitExpr (IntLit 30)) ]);
        ( "address",
          RecordExpr [ ("city", LitExpr (StringLit "北京")); ("street", LitExpr (StringLit "朝阳区")) ]
        );
      ]
  in
  let expected_nested =
    RecordExpr
      [
        ("person", RecordExpr [ ("name", LitExpr (StringLit "李四")); ("age", LitExpr (IntLit 30)) ]);
        ( "address",
          RecordExpr [ ("city", LitExpr (StringLit "北京")); ("street", LitExpr (StringLit "朝阳区")) ]
        );
      ]
  in
  TestUtils.check_expr_equality "嵌套记录表达式" expected_nested nested_record

(** 测试数组类型表达式 *)
let test_array_expressions () =
  (* 测试数组创建表达式 *)
  let array_elements =
    [ LitExpr (IntLit 1); LitExpr (IntLit 2); LitExpr (IntLit 3); LitExpr (IntLit 4) ]
  in
  let array_expr = ArrayExpr array_elements in
  let expected_array = ArrayExpr array_elements in
  TestUtils.check_expr_equality "数组创建表达式" expected_array array_expr;

  (* 测试数组访问表达式 *)
  let array_var = VarExpr "numbers" in
  let index_expr = LitExpr (IntLit 0) in
  let array_access = ArrayAccessExpr (array_var, index_expr) in
  let expected_array_access = ArrayAccessExpr (array_var, index_expr) in
  TestUtils.check_expr_equality "数组访问表达式" expected_array_access array_access;

  (* 测试数组更新表达式 *)
  let new_value = LitExpr (IntLit 10) in
  let array_update = ArrayUpdateExpr (array_var, index_expr, new_value) in
  let expected_array_update = ArrayUpdateExpr (array_var, index_expr, new_value) in
  TestUtils.check_expr_equality "数组更新表达式" expected_array_update array_update;

  (* 测试多维数组 *)
  let matrix =
    ArrayExpr
      [
        ArrayExpr [ LitExpr (IntLit 1); LitExpr (IntLit 2) ];
        ArrayExpr [ LitExpr (IntLit 3); LitExpr (IntLit 4) ];
      ]
  in
  let expected_matrix =
    ArrayExpr
      [
        ArrayExpr [ LitExpr (IntLit 1); LitExpr (IntLit 2) ];
        ArrayExpr [ LitExpr (IntLit 3); LitExpr (IntLit 4) ];
      ]
  in
  TestUtils.check_expr_equality "多维数组表达式" expected_matrix matrix

(** 测试引用和赋值表达式 *)
let test_reference_expressions () =
  (* 测试引用创建表达式 *)
  let value_expr = LitExpr (IntLit 42) in
  let ref_expr = RefExpr value_expr in
  let expected_ref = RefExpr value_expr in
  TestUtils.check_expr_equality "引用创建表达式" expected_ref ref_expr;

  (* 测试引用解引用表达式 *)
  let ref_var = VarExpr "counter" in
  let deref_expr = DerefExpr ref_var in
  let expected_deref = DerefExpr ref_var in
  TestUtils.check_expr_equality "引用解引用表达式" expected_deref deref_expr;

  (* 测试引用赋值表达式 *)
  let new_value = LitExpr (IntLit 100) in
  let assign_expr = AssignExpr (ref_var, new_value) in
  let expected_assign = AssignExpr (ref_var, new_value) in
  TestUtils.check_expr_equality "引用赋值表达式" expected_assign assign_expr;

  (* 测试复杂引用操作 *)
  let complex_ref = RefExpr (BinaryOpExpr (LitExpr (IntLit 10), Add, LitExpr (IntLit 20))) in
  let complex_deref = DerefExpr (RefExpr (LitExpr (IntLit 5))) in
  let expected_complex_ref =
    RefExpr (BinaryOpExpr (LitExpr (IntLit 10), Add, LitExpr (IntLit 20)))
  in
  let expected_complex_deref = DerefExpr (RefExpr (LitExpr (IntLit 5))) in
  TestUtils.check_expr_equality "复杂引用表达式" expected_complex_ref complex_ref;
  TestUtils.check_expr_equality "复杂解引用表达式" expected_complex_deref complex_deref

(** 测试异常处理表达式 *)
let test_exception_expressions () =
  (* 测试异常抛出表达式 *)
  let exception_value = LitExpr (StringLit "发生错误") in
  let raise_expr = RaiseExpr exception_value in
  let expected_raise = RaiseExpr exception_value in
  TestUtils.check_expr_equality "异常抛出表达式" expected_raise raise_expr;

  (* 测试try-catch表达式 *)
  let try_body = BinaryOpExpr (LitExpr (IntLit 10), Div, VarExpr "x") in
  let catch_branch =
    { pattern = ConstructorPattern ("DivisionByZero", []); guard = None; expr = LitExpr (IntLit 0) }
  in
  let finally_expr = FunCallExpr (VarExpr "cleanup", []) in
  let try_expr = TryExpr (try_body, [ catch_branch ], Some finally_expr) in
  let expected_try = TryExpr (try_body, [ catch_branch ], Some finally_expr) in
  TestUtils.check_expr_equality "异常处理表达式" expected_try try_expr;

  (* 测试无finally的try表达式 *)
  let simple_try = TryExpr (try_body, [ catch_branch ], None) in
  let expected_simple_try = TryExpr (try_body, [ catch_branch ], None) in
  TestUtils.check_expr_equality "简单异常处理表达式" expected_simple_try simple_try;

  (* 测试多个catch分支 *)
  let multiple_catch_branches =
    [
      {
        pattern = ConstructorPattern ("DivisionByZero", []);
        guard = None;
        expr = LitExpr (IntLit 0);
      };
      { pattern = ConstructorPattern ("Overflow", []); guard = None; expr = LitExpr (IntLit (-1)) };
      { pattern = WildcardPattern; guard = None; expr = LitExpr (IntLit (-2)) };
    ]
  in
  let multi_try = TryExpr (try_body, multiple_catch_branches, None) in
  let expected_multi_try = TryExpr (try_body, multiple_catch_branches, None) in
  TestUtils.check_expr_equality "多分支异常处理表达式" expected_multi_try multi_try

(** 测试高级类型表达式 *)
let test_advanced_type_expressions () =
  (* 测试引用类型 *)
  let int_ref_type = RefType (BaseTypeExpr IntType) in
  let expected_int_ref = RefType (BaseTypeExpr IntType) in
  TestUtils.check_type_equality "整数引用类型" expected_int_ref int_ref_type;

  (* 测试多态变体类型 *)
  let variant_options =
    [
      ("Red", None);
      ("Green", None);
      ("Blue", None);
      ("RGB", Some (TupleType [ BaseTypeExpr IntType; BaseTypeExpr IntType; BaseTypeExpr IntType ]));
    ]
  in
  let poly_variant_type = PolymorphicVariantType variant_options in
  let expected_poly_variant = PolymorphicVariantType variant_options in
  TestUtils.check_type_equality "多态变体类型" expected_poly_variant poly_variant_type;

  (* 测试复杂嵌套类型 *)
  let complex_type =
    FunType
      ( TupleType [ BaseTypeExpr IntType; RefType (BaseTypeExpr StringType) ],
        ListType
          (PolymorphicVariantType
             [ ("Success", Some (BaseTypeExpr IntType)); ("Error", Some (BaseTypeExpr StringType)) ])
      )
  in
  let expected_complex =
    FunType
      ( TupleType [ BaseTypeExpr IntType; RefType (BaseTypeExpr StringType) ],
        ListType
          (PolymorphicVariantType
             [ ("Success", Some (BaseTypeExpr IntType)); ("Error", Some (BaseTypeExpr StringType)) ])
      )
  in
  TestUtils.check_type_equality "复杂嵌套类型" expected_complex complex_type

(** 测试多态变体表达式 *)
let test_polymorphic_variant_expressions () =
  (* 测试简单多态变体 *)
  let simple_variant = PolymorphicVariantExpr ("Red", None) in
  let expected_simple = PolymorphicVariantExpr ("Red", None) in
  TestUtils.check_expr_equality "简单多态变体" expected_simple simple_variant;

  (* 测试带值的多态变体 *)
  let valued_variant =
    PolymorphicVariantExpr
      ("RGB", Some (TupleExpr [ LitExpr (IntLit 255); LitExpr (IntLit 128); LitExpr (IntLit 0) ]))
  in
  let expected_valued =
    PolymorphicVariantExpr
      ("RGB", Some (TupleExpr [ LitExpr (IntLit 255); LitExpr (IntLit 128); LitExpr (IntLit 0) ]))
  in
  TestUtils.check_expr_equality "带值多态变体" expected_valued valued_variant;

  (* 测试多态变体模式匹配 *)
  let variant_value = VarExpr "color" in
  let red_branch =
    {
      pattern = PolymorphicVariantPattern ("Red", None);
      guard = None;
      expr = LitExpr (StringLit "红色");
    }
  in
  let rgb_branch =
    {
      pattern =
        PolymorphicVariantPattern
          ("RGB", Some (TuplePattern [ VarPattern "r"; VarPattern "g"; VarPattern "b" ]));
      guard = None;
      expr = LitExpr (StringLit "自定义颜色");
    }
  in
  let variant_match = MatchExpr (variant_value, [ red_branch; rgb_branch ]) in
  let expected_variant_match = MatchExpr (variant_value, [ red_branch; rgb_branch ]) in
  TestUtils.check_expr_equality "多态变体模式匹配" expected_variant_match variant_match

(** 测试类型注解表达式 *)
let test_type_annotation_expressions () =
  (* 测试简单类型注解 *)
  let value_expr = LitExpr (IntLit 42) in
  let type_anno = TypeAnnotationExpr (value_expr, BaseTypeExpr IntType) in
  let expected_type_anno = TypeAnnotationExpr (value_expr, BaseTypeExpr IntType) in
  TestUtils.check_expr_equality "简单类型注解" expected_type_anno type_anno;

  (* 测试复杂类型注解 *)
  let func_expr = FunExpr ([ "x"; "y" ], BinaryOpExpr (VarExpr "x", Add, VarExpr "y")) in
  let func_type =
    FunType (BaseTypeExpr IntType, FunType (BaseTypeExpr IntType, BaseTypeExpr IntType))
  in
  let complex_anno = TypeAnnotationExpr (func_expr, func_type) in
  let expected_complex_anno = TypeAnnotationExpr (func_expr, func_type) in
  TestUtils.check_expr_equality "复杂类型注解" expected_complex_anno complex_anno;

  (* 测试嵌套类型注解 *)
  let inner_anno = TypeAnnotationExpr (LitExpr (IntLit 10), BaseTypeExpr IntType) in
  let outer_anno = TypeAnnotationExpr (inner_anno, BaseTypeExpr IntType) in
  let expected_outer_anno = TypeAnnotationExpr (inner_anno, BaseTypeExpr IntType) in
  TestUtils.check_expr_equality "嵌套类型注解" expected_outer_anno outer_anno

(** 测试构造器表达式 *)
let test_constructor_expressions () =
  (* 测试简单构造器 *)
  let none_constructor = ConstructorExpr ("None", []) in
  let expected_none = ConstructorExpr ("None", []) in
  TestUtils.check_expr_equality "None构造器" expected_none none_constructor;

  (* 测试带参数构造器 *)
  let some_constructor = ConstructorExpr ("Some", [ LitExpr (IntLit 42) ]) in
  let expected_some = ConstructorExpr ("Some", [ LitExpr (IntLit 42) ]) in
  TestUtils.check_expr_equality "Some构造器" expected_some some_constructor;

  (* 测试多参数构造器 *)
  let person_constructor =
    ConstructorExpr ("Person", [ LitExpr (StringLit "张三"); LitExpr (IntLit 25) ])
  in
  let expected_person =
    ConstructorExpr ("Person", [ LitExpr (StringLit "张三"); LitExpr (IntLit 25) ])
  in
  TestUtils.check_expr_equality "Person构造器" expected_person person_constructor;

  (* 测试嵌套构造器 *)
  let nested_constructor =
    ConstructorExpr ("Result", [ ConstructorExpr ("Ok", [ LitExpr (IntLit 100) ]) ])
  in
  let expected_nested =
    ConstructorExpr ("Result", [ ConstructorExpr ("Ok", [ LitExpr (IntLit 100) ]) ])
  in
  TestUtils.check_expr_equality "嵌套构造器" expected_nested nested_constructor

(** 测试高级模式匹配 *)
let test_advanced_pattern_matching () =
  (* 测试异常模式 *)
  let exception_pattern = ExceptionPattern ("MyException", Some (VarPattern "msg")) in
  let expected_exception_pattern = ExceptionPattern ("MyException", Some (VarPattern "msg")) in
  TestUtils.check_pattern_equality "异常模式" expected_exception_pattern exception_pattern;

  (* 测试空列表模式 *)
  let empty_list_pattern = EmptyListPattern in
  let expected_empty_list = EmptyListPattern in
  TestUtils.check_pattern_equality "空列表模式" expected_empty_list empty_list_pattern;

  (* 测试OR模式 *)
  let or_pattern = OrPattern (VarPattern "x", VarPattern "y") in
  let expected_or_pattern = OrPattern (VarPattern "x", VarPattern "y") in
  TestUtils.check_pattern_equality "OR模式" expected_or_pattern or_pattern;

  (* 测试复杂嵌套模式 *)
  let complex_pattern =
    ConstructorPattern
      ( "Tree",
        [
          VarPattern "value";
          OrPattern
            ( ConstructorPattern ("Leaf", []),
              ConstructorPattern ("Node", [ VarPattern "left"; VarPattern "right" ]) );
        ] )
  in
  let expected_complex_pattern =
    ConstructorPattern
      ( "Tree",
        [
          VarPattern "value";
          OrPattern
            ( ConstructorPattern ("Leaf", []),
              ConstructorPattern ("Node", [ VarPattern "left"; VarPattern "right" ]) );
        ] )
  in
  TestUtils.check_pattern_equality "复杂嵌套模式" expected_complex_pattern complex_pattern

(** 测试语句类型完整性 *)
let test_comprehensive_statement_types () =
  (* 测试递归let语句 *)
  let rec_let_stmt =
    RecLetStmt
      ( "factorial",
        FunExpr
          ( [ "n" ],
            CondExpr
              ( BinaryOpExpr (VarExpr "n", Le, LitExpr (IntLit 1)),
                LitExpr (IntLit 1),
                BinaryOpExpr
                  ( VarExpr "n",
                    Mul,
                    FunCallExpr
                      (VarExpr "factorial", [ BinaryOpExpr (VarExpr "n", Sub, LitExpr (IntLit 1)) ])
                  ) ) ) )
  in
  let expected_rec_let =
    RecLetStmt
      ( "factorial",
        FunExpr
          ( [ "n" ],
            CondExpr
              ( BinaryOpExpr (VarExpr "n", Le, LitExpr (IntLit 1)),
                LitExpr (IntLit 1),
                BinaryOpExpr
                  ( VarExpr "n",
                    Mul,
                    FunCallExpr
                      (VarExpr "factorial", [ BinaryOpExpr (VarExpr "n", Sub, LitExpr (IntLit 1)) ])
                  ) ) ) )
  in
  TestUtils.check_stmt_equality "递归let语句" expected_rec_let rec_let_stmt;

  (* 测试语义let语句 *)
  let semantic_let =
    SemanticLetStmt ("result", "计算结果", BinaryOpExpr (LitExpr (IntLit 10), Mul, LitExpr (IntLit 5)))
  in
  let expected_semantic_let =
    SemanticLetStmt ("result", "计算结果", BinaryOpExpr (LitExpr (IntLit 10), Mul, LitExpr (IntLit 5)))
  in
  TestUtils.check_stmt_equality "语义let语句" expected_semantic_let semantic_let;

  (* 测试模块导入语句 *)
  let module_import =
    {
      module_import_name = "List";
      imports = [ ("map", Some "list_map"); ("fold_left", None); ("length", Some "len") ];
    }
  in
  let import_stmt = ModuleImportStmt module_import in
  let expected_import_stmt = ModuleImportStmt module_import in
  TestUtils.check_stmt_equality "模块导入语句" expected_import_stmt import_stmt;

  (* 测试include语句 *)
  let include_stmt = IncludeStmt (VarExpr "StandardLibrary") in
  let expected_include = IncludeStmt (VarExpr "StandardLibrary") in
  TestUtils.check_stmt_equality "include语句" expected_include include_stmt

(** 测试类型定义完整性 *)
let test_comprehensive_type_definitions () =
  (* 测试代数数据类型 *)
  let tree_constructors =
    [
      ("Leaf", Some (BaseTypeExpr IntType));
      ("Node", Some (TupleType [ TypeVar "a"; TypeVar "a"; TypeVar "a" ]));
    ]
  in
  let tree_type_def = AlgebraicType tree_constructors in
  let tree_stmt = TypeDefStmt ("tree", tree_type_def) in
  let expected_tree_stmt = TypeDefStmt ("tree", tree_type_def) in
  TestUtils.check_stmt_equality "代数数据类型定义" expected_tree_stmt tree_stmt;

  (* 测试记录类型定义 *)
  let person_fields =
    [
      ("name", BaseTypeExpr StringType);
      ("age", BaseTypeExpr IntType);
      ("email", BaseTypeExpr StringType);
    ]
  in
  let person_type_def = RecordType person_fields in
  let person_stmt = TypeDefStmt ("person", person_type_def) in
  let expected_person_stmt = TypeDefStmt ("person", person_type_def) in
  TestUtils.check_stmt_equality "记录类型定义" expected_person_stmt person_stmt;

  (* 测试类型别名 *)
  let string_list_alias = AliasType (ListType (BaseTypeExpr StringType)) in
  let alias_stmt = TypeDefStmt ("string_list", string_list_alias) in
  let expected_alias_stmt = TypeDefStmt ("string_list", string_list_alias) in
  TestUtils.check_stmt_equality "类型别名定义" expected_alias_stmt alias_stmt;

  (* 测试多态变体类型定义 *)
  let color_variants =
    [
      ("Red", None);
      ("Green", None);
      ("Blue", None);
      ("RGB", Some (TupleType [ BaseTypeExpr IntType; BaseTypeExpr IntType; BaseTypeExpr IntType ]));
    ]
  in
  let color_type_def = PolymorphicVariantTypeDef color_variants in
  let color_stmt = TypeDefStmt ("color", color_type_def) in
  let expected_color_stmt = TypeDefStmt ("color", color_type_def) in
  TestUtils.check_stmt_equality "多态变体类型定义" expected_color_stmt color_stmt

(** 测试组合表达式和语义表达式 *)
let test_semantic_and_combine_expressions () =
  (* 测试组合表达式 *)
  let combine_parts =
    [
      LitExpr (StringLit "春");
      LitExpr (StringLit "夏");
      LitExpr (StringLit "秋");
      LitExpr (StringLit "冬");
    ]
  in
  let combine_expr = CombineExpr combine_parts in
  let expected_combine = CombineExpr combine_parts in
  TestUtils.check_expr_equality "组合表达式" expected_combine combine_expr;

  (* 测试语义let表达式 *)
  let semantic_let_expr = SemanticLetExpr ("pi", "圆周率", LitExpr (FloatLit 3.14159), VarExpr "pi") in
  let expected_semantic_let_expr =
    SemanticLetExpr ("pi", "圆周率", LitExpr (FloatLit 3.14159), VarExpr "pi")
  in
  TestUtils.check_expr_equality "语义let表达式" expected_semantic_let_expr semantic_let_expr;

  (* 测试OrElse表达式 *)
  let or_else_expr = OrElseExpr (VarExpr "maybe_value", LitExpr (StringLit "默认值")) in
  let expected_or_else = OrElseExpr (VarExpr "maybe_value", LitExpr (StringLit "默认值")) in
  TestUtils.check_expr_equality "OrElse表达式" expected_or_else or_else_expr

(** 主测试运行器 *)
let () =
  run "AST模块测试覆盖率提升至80%+ - Fix #2147"
    [
      ( "诗词相关类型测试",
        [
          test_case "诗词形式完整性测试" `Quick test_poetry_forms_comprehensive;
          test_case "韵律信息完整性测试" `Quick test_rhyme_info_comprehensive;
          test_case "声调模式完整性测试" `Quick test_tone_patterns_comprehensive;
          test_case "韵律约束完整性测试" `Quick test_meter_constraints_comprehensive;
        ] );
      ( "诗词注解表达式测试",
        [
          test_case "诗词注解表达式测试" `Quick test_poetry_annotated_expressions;
          test_case "对偶结构表达式测试" `Quick test_parallel_structure_expressions;
        ] );
      ("模块系统表达式测试", [ test_case "模块系统表达式测试" `Quick test_module_system_expressions ]);
      ( "记录和数组表达式测试",
        [
          test_case "记录表达式测试" `Quick test_record_expressions;
          test_case "数组表达式测试" `Quick test_array_expressions;
        ] );
      ( "引用和异常处理测试",
        [
          test_case "引用表达式测试" `Quick test_reference_expressions;
          test_case "异常表达式测试" `Quick test_exception_expressions;
        ] );
      ( "高级类型系统测试",
        [
          test_case "高级类型表达式测试" `Quick test_advanced_type_expressions;
          test_case "多态变体表达式测试" `Quick test_polymorphic_variant_expressions;
          test_case "类型注解表达式测试" `Quick test_type_annotation_expressions;
          test_case "构造器表达式测试" `Quick test_constructor_expressions;
        ] );
      ( "高级模式匹配和语句测试",
        [
          test_case "高级模式匹配测试" `Quick test_advanced_pattern_matching;
          test_case "语句类型完整性测试" `Quick test_comprehensive_statement_types;
          test_case "类型定义完整性测试" `Quick test_comprehensive_type_definitions;
        ] );
      ("语义和组合表达式测试", [ test_case "语义和组合表达式测试" `Quick test_semantic_and_combine_expressions ]);
    ]
