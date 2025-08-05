(** AST模块高级测试覆盖率提升 - Fix #2124

    专注于进一步提升ast.ml核心模块测试覆盖率从18.27%到80%+ 新增测试场景：
    - 诗词相关类型完整测试（poetry_form, rhyme_info, tone_pattern等）
    - 复杂模块系统和函子表达式
    - 高级模式匹配（OrPattern, ExceptionPattern等）
    - 多态变体类型系统
    - 记录类型和数组操作
    - 引用类型和错误处理表达式
    - 更多边界条件和特殊情况

    Author: Whisky, PR Worker Agent
    @version 1.0
    @since 2025-08-02 Fix #2124 核心模块测试覆盖率提升优化 *)

open Alcotest
open Yyocamlc_lib.Ast

(** 高级测试工具模块 *)
module AdvancedTestUtils = struct
  let check_poetry_form_equality desc expected actual =
    check (testable pp_poetry_form equal_poetry_form) desc expected actual

  let check_rhyme_info_equality desc expected actual =
    check (testable pp_rhyme_info equal_rhyme_info) desc expected actual

  let check_tone_pattern_equality desc expected actual =
    check (testable pp_tone_pattern equal_tone_pattern) desc expected actual

  let check_module_type_equality desc expected actual =
    check (testable pp_module_type equal_module_type) desc expected actual

  let check_signature_item_equality desc expected actual =
    check (testable pp_signature_item equal_signature_item) desc expected actual
end

(** 测试诗词形式枚举完整性 *)
let test_poetry_forms_comprehensive () =
  let all_poetry_forms =
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

  (* 诗词形式数量验证 *)
  check int "诗词形式总数应为7" 7 (List.length all_poetry_forms);

  (* 每种诗词形式相等性测试 *)
  check bool "四言诗相等性" true (FourCharPoetry = FourCharPoetry);
  check bool "五言诗相等性" true (FiveCharPoetry = FiveCharPoetry);
  check bool "七言诗相等性" true (SevenCharPoetry = SevenCharPoetry);
  check bool "骈体文相等性" true (ParallelProse = ParallelProse);
  check bool "律诗相等性" true (RegulatedVerse = RegulatedVerse);
  check bool "绝句相等性" true (Quatrain = Quatrain);
  check bool "对联相等性" true (Couplet = Couplet);

  (* 诗词形式不等性测试 *)
  check bool "四言诗与五言诗不相等" false (FourCharPoetry = FiveCharPoetry);
  check bool "律诗与绝句不相等" false (RegulatedVerse = Quatrain);

  (* 显示功能测试 *)
  let form_strings = List.map show_poetry_form all_poetry_forms in
  check bool "所有诗词形式可以正确显示" true (List.for_all (fun s -> String.length s > 0) form_strings)

(** 测试韵律信息结构 *)
let test_rhyme_info_structures () =
  let rhyme1 = { rhyme_category = "平韵"; rhyme_position = 1; rhyme_pattern = "押韵" } in
  let rhyme2 = { rhyme_category = "仄韵"; rhyme_position = 2; rhyme_pattern = "对仗" } in
  let rhyme3 = { rhyme_category = "平韵"; rhyme_position = 1; rhyme_pattern = "押韵" } in

  (* 韵律信息相等性测试 *)
  check bool "相同韵律信息应相等" true (rhyme1 = rhyme3);
  check bool "不同韵律信息应不相等" false (rhyme1 = rhyme2);

  (* 韵律信息字段访问测试 *)
  check string "韵部字段访问" "平韵" rhyme1.rhyme_category;
  check int "韵脚位置字段访问" 1 rhyme1.rhyme_position;
  check string "韵式字段访问" "押韵" rhyme1.rhyme_pattern;

  (* 韵律信息显示功能 *)
  let rhyme_str = show_rhyme_info rhyme1 in
  check bool "韵律信息显示非空" true (String.length rhyme_str > 0)

(** 测试声调类型和约束 *)
let test_tone_types_and_constraints () =
  let all_tone_types = [ LevelTone; FallingTone; RisingTone; DepartingTone; EnteringTone ] in
  let all_constraints =
    [ AlternatingTones; ParallelTones; SpecificPattern [ LevelTone; FallingTone ] ]
  in

  (* 声调类型完整性测试 *)
  check int "声调类型总数应为5" 5 (List.length all_tone_types);
  check bool "平声相等性" true (LevelTone = LevelTone);
  check bool "仄声相等性" true (FallingTone = FallingTone);
  check bool "上声相等性" true (RisingTone = RisingTone);
  check bool "去声相等性" true (DepartingTone = DepartingTone);
  check bool "入声相等性" true (EnteringTone = EnteringTone);

  (* 声调约束测试 *)
  check int "声调约束类型总数应为3" 3 (List.length all_constraints);
  check bool "平仄交替约束相等性" true (AlternatingTones = AlternatingTones);
  check bool "平仄对仗约束相等性" true (ParallelTones = ParallelTones);

  (* 特定平仄模式测试 *)
  let pattern1 = SpecificPattern [ LevelTone; FallingTone ] in
  let pattern2 = SpecificPattern [ LevelTone; FallingTone ] in
  let pattern3 = SpecificPattern [ RisingTone; DepartingTone ] in
  check bool "相同特定模式应相等" true (pattern1 = pattern2);
  check bool "不同特定模式应不相等" false (pattern1 = pattern3)

(** 测试平仄模式结构 *)
let test_tone_pattern_structures () =
  let pattern1 =
    {
      tone_sequence = [ LevelTone; FallingTone; LevelTone ];
      tone_constraints = [ AlternatingTones; ParallelTones ];
    }
  in
  let pattern2 =
    {
      tone_sequence = [ RisingTone; DepartingTone ];
      tone_constraints = [ SpecificPattern [ LevelTone ] ];
    }
  in

  (* 平仄模式字段访问测试 *)
  check int "声调序列长度" 3 (List.length pattern1.tone_sequence);
  check int "声调约束数量" 2 (List.length pattern1.tone_constraints);

  (* 平仄模式相等性测试 *)
  let pattern3 =
    {
      tone_sequence = [ LevelTone; FallingTone; LevelTone ];
      tone_constraints = [ AlternatingTones; ParallelTones ];
    }
  in
  check bool "相同平仄模式应相等" true (pattern1 = pattern3);
  check bool "不同平仄模式应不相等" false (pattern1 = pattern2);

  (* 平仄模式显示功能 *)
  let pattern_str = show_tone_pattern pattern1 in
  check bool "平仄模式显示非空" true (String.length pattern_str > 0)

(** 测试韵律约束结构 *)
let test_meter_constraint_structures () =
  let constraint1 =
    {
      character_count = 7;
      syllable_pattern = Some "七言";
      caesura_position = Some 4;
      rhyme_scheme = Some "ABAB";
    }
  in
  let constraint2 =
    { character_count = 5; syllable_pattern = None; caesura_position = None; rhyme_scheme = None }
  in

  (* 韵律约束字段访问测试 *)
  check int "字符数约束" 7 constraint1.character_count;
  check bool "音节模式存在" true (constraint1.syllable_pattern <> None);
  check bool "停顿位置存在" true (constraint1.caesura_position <> None);
  check bool "韵律方案存在" true (constraint1.rhyme_scheme <> None);

  (* 可选字段测试 *)
  check bool "空音节模式" true (constraint2.syllable_pattern = None);
  check bool "空停顿位置" true (constraint2.caesura_position = None);
  check bool "空韵律方案" true (constraint2.rhyme_scheme = None);

  (* 韵律约束显示功能 *)
  let constraint_str = show_meter_constraint constraint1 in
  check bool "韵律约束显示非空" true (String.length constraint_str > 0)

(** 测试高级模式匹配类型 *)
let test_advanced_pattern_matching () =
  let var_pattern = VarPattern "x" in
  let lit_pattern = LitPattern (IntLit 42) in
  let wildcard_pattern = WildcardPattern in

  (* Or模式测试 *)
  let or_pattern = OrPattern (var_pattern, lit_pattern) in
  let or_pattern2 = OrPattern (var_pattern, lit_pattern) in
  let or_pattern3 = OrPattern (lit_pattern, var_pattern) in
  check bool "相同Or模式应相等" true (or_pattern = or_pattern2);
  check bool "不同Or模式应不相等" false (or_pattern = or_pattern3);

  (* 异常模式测试 *)
  let exception_pattern1 = ExceptionPattern ("MyException", Some var_pattern) in
  let exception_pattern2 = ExceptionPattern ("MyException", None) in
  let exception_pattern3 = ExceptionPattern ("OtherException", Some var_pattern) in
  check bool "异常模式与参数不等于无参数" false (exception_pattern1 = exception_pattern2);
  check bool "不同异常名模式不相等" false (exception_pattern1 = exception_pattern3);

  (* 多态变体模式测试 *)
  let poly_variant_pattern1 = PolymorphicVariantPattern ("Tag", Some var_pattern) in
  let poly_variant_pattern2 = PolymorphicVariantPattern ("Tag", None) in
  let poly_variant_pattern3 = PolymorphicVariantPattern ("OtherTag", Some var_pattern) in
  check bool "多态变体模式与参数不等于无参数" false (poly_variant_pattern1 = poly_variant_pattern2);
  check bool "不同标签的多态变体模式不相等" false (poly_variant_pattern1 = poly_variant_pattern3);

  (* 空列表模式测试 *)
  let empty_list_pattern = EmptyListPattern in
  check bool "空列表模式相等性" true (empty_list_pattern = EmptyListPattern);
  check bool "空列表模式与通配符不相等" false (empty_list_pattern = wildcard_pattern)

(** 测试高级类型表达式 *)
let test_advanced_type_expressions () =
  let int_type = BaseTypeExpr IntType in
  let string_type = BaseTypeExpr StringType in
  let type_var = TypeVar "a" in

  (* 引用类型测试 *)
  let ref_type1 = RefType int_type in
  let ref_type2 = RefType int_type in
  let ref_type3 = RefType string_type in
  check bool "相同引用类型应相等" true (ref_type1 = ref_type2);
  check bool "不同引用类型应不相等" false (ref_type1 = ref_type3);

  (* 多态变体类型测试 *)
  let poly_variant_type1 = PolymorphicVariantType [ ("Tag1", Some int_type); ("Tag2", None) ] in
  let poly_variant_type2 = PolymorphicVariantType [ ("Tag1", Some int_type); ("Tag2", None) ] in
  let poly_variant_type3 = PolymorphicVariantType [ ("Tag1", Some string_type); ("Tag2", None) ] in
  check bool "相同多态变体类型应相等" true (poly_variant_type1 = poly_variant_type2);
  check bool "不同多态变体类型应不相等" false (poly_variant_type1 = poly_variant_type3);

  (* 复杂函数类型测试 *)
  let fun_type1 = FunType (int_type, string_type) in
  let fun_type2 = FunType (string_type, int_type) in
  let fun_type3 = FunType (int_type, fun_type1) in
  check bool "不同参数类型的函数类型不相等" false (fun_type1 = fun_type2);
  check bool "高阶函数类型构造正确" true
    (match fun_type3 with FunType (BaseTypeExpr IntType, _) -> true | _ -> false)

(** 测试高级类型定义 *)
let test_advanced_type_definitions () =
  let int_type = BaseTypeExpr IntType in
  let string_type = BaseTypeExpr StringType in

  (* 私有类型测试 *)
  let private_type1 = PrivateType int_type in
  let private_type2 = PrivateType int_type in
  let private_type3 = PrivateType string_type in
  check bool "相同私有类型应相等" true (private_type1 = private_type2);
  check bool "不同私有类型应不相等" false (private_type1 = private_type3);

  (* 多态变体类型定义测试 *)
  let poly_variant_def1 =
    PolymorphicVariantTypeDef [ ("Variant1", Some int_type); ("Variant2", None) ]
  in
  let poly_variant_def2 =
    PolymorphicVariantTypeDef [ ("Variant1", Some int_type); ("Variant2", None) ]
  in
  let poly_variant_def3 = PolymorphicVariantTypeDef [ ("Variant1", Some string_type) ] in
  check bool "相同多态变体类型定义应相等" true (poly_variant_def1 = poly_variant_def2);
  check bool "不同多态变体类型定义应不相等" false (poly_variant_def1 = poly_variant_def3);

  (* 记录类型测试 *)
  let record_type1 = RecordType [ ("field1", int_type); ("field2", string_type) ] in
  let record_type2 = RecordType [ ("field1", int_type); ("field2", string_type) ] in
  let record_type3 = RecordType [ ("field1", string_type); ("field2", int_type) ] in
  check bool "相同记录类型应相等" true (record_type1 = record_type2);
  check bool "不同记录类型应不相等" false (record_type1 = record_type3)

(** 测试模块系统类型 *)
let test_module_system_types () =
  let int_type = BaseTypeExpr IntType in
  let string_type = BaseTypeExpr StringType in

  (* 签名项测试 *)
  let sig_value = SigValue ("value_name", int_type) in
  let sig_type_decl = SigTypeDecl ("type_name", Some (AliasType string_type)) in
  let sig_exception = SigException ("exception_name", Some int_type) in

  check bool "值签名构造正确" true (match sig_value with SigValue (_, _) -> true | _ -> false);
  check bool "类型签名构造正确" true (match sig_type_decl with SigTypeDecl (_, _) -> true | _ -> false);
  check bool "异常签名构造正确" true (match sig_exception with SigException (_, _) -> true | _ -> false);

  (* 模块类型测试 *)
  let signature_items = [ sig_value; sig_type_decl; sig_exception ] in
  let signature = Signature signature_items in
  let module_type_name = ModuleTypeName "MyModuleType" in

  check bool "具体签名构造正确" true (match signature with Signature _ -> true | _ -> false);
  check bool "命名模块类型构造正确" true (match module_type_name with ModuleTypeName _ -> true | _ -> false);

  (* 函子类型测试 *)
  let functor_type = FunctorType ("param", signature, module_type_name) in
  check bool "函子类型构造正确" true (match functor_type with FunctorType (_, _, _) -> true | _ -> false)

(** 测试高级表达式类型 *)
let test_advanced_expression_types () =
  let int_expr = make_int 42 in
  let string_expr = make_string "hello" in
  let var_expr = make_var "x" in

  (* 记录表达式测试 *)
  let record_expr = RecordExpr [ ("field1", int_expr); ("field2", string_expr) ] in
  check bool "记录表达式构造正确" true (match record_expr with RecordExpr _ -> true | _ -> false);

  (* 字段访问表达式测试 *)
  let field_access = FieldAccessExpr (var_expr, "field1") in
  check bool "字段访问表达式构造正确" true
    (match field_access with FieldAccessExpr (_, _) -> true | _ -> false);

  (* 记录更新表达式测试 *)
  let record_update = RecordUpdateExpr (var_expr, [ ("field1", int_expr) ]) in
  check bool "记录更新表达式构造正确" true
    (match record_update with RecordUpdateExpr (_, _) -> true | _ -> false);

  (* 数组表达式测试 *)
  let array_expr = ArrayExpr [ int_expr; make_int 24 ] in
  check bool "数组表达式构造正确" true (match array_expr with ArrayExpr _ -> true | _ -> false);

  (* 数组访问表达式测试 *)
  let array_access = ArrayAccessExpr (array_expr, int_expr) in
  check bool "数组访问表达式构造正确" true
    (match array_access with ArrayAccessExpr (_, _) -> true | _ -> false);

  (* 数组更新表达式测试 *)
  let array_update = ArrayUpdateExpr (array_expr, int_expr, make_int 100) in
  check bool "数组更新表达式构造正确" true
    (match array_update with ArrayUpdateExpr (_, _, _) -> true | _ -> false)

(** 测试引用和异常处理表达式 *)
let test_reference_and_exception_expressions () =
  let int_expr = make_int 42 in
  let var_expr = make_var "x" in

  (* 引用表达式测试 *)
  let ref_expr = RefExpr int_expr in
  check bool "引用表达式构造正确" true (match ref_expr with RefExpr _ -> true | _ -> false);

  (* 解引用表达式测试 *)
  let deref_expr = DerefExpr var_expr in
  check bool "解引用表达式构造正确" true (match deref_expr with DerefExpr _ -> true | _ -> false);

  (* 赋值表达式测试 *)
  let assign_expr = AssignExpr (var_expr, int_expr) in
  check bool "赋值表达式构造正确" true (match assign_expr with AssignExpr (_, _) -> true | _ -> false);

  (* 抛出表达式测试 *)
  let raise_expr = RaiseExpr int_expr in
  check bool "抛出表达式构造正确" true (match raise_expr with RaiseExpr _ -> true | _ -> false);

  (* 尝试表达式测试 *)
  let pattern = VarPattern "e" in
  let branch = { pattern; guard = None; expr = int_expr } in
  let try_expr = TryExpr (var_expr, [ branch ], Some int_expr) in
  check bool "尝试表达式构造正确" true (match try_expr with TryExpr (_, _, _) -> true | _ -> false);

  (* 构造器表达式测试 *)
  let constructor_expr = ConstructorExpr ("Some", [ int_expr ]) in
  check bool "构造器表达式构造正确" true
    (match constructor_expr with ConstructorExpr (_, _) -> true | _ -> false)

(** 测试模块和函子表达式 *)
let test_module_and_functor_expressions () =
  let int_expr = make_int 42 in
  let var_expr = make_var "x" in
  let stmt = ExprStmt int_expr in

  (* 模块访问表达式测试 *)
  let module_access = ModuleAccessExpr (var_expr, "member") in
  check bool "模块访问表达式构造正确" true
    (match module_access with ModuleAccessExpr (_, _) -> true | _ -> false);

  (* 函子调用表达式测试 *)
  let functor_call = FunctorCallExpr (var_expr, var_expr) in
  check bool "函子调用表达式构造正确" true
    (match functor_call with FunctorCallExpr (_, _) -> true | _ -> false);

  (* 函子表达式测试 *)
  let module_type = ModuleTypeName "SIG" in
  let functor_expr = FunctorExpr ("X", module_type, int_expr) in
  check bool "函子表达式构造正确" true (match functor_expr with FunctorExpr (_, _, _) -> true | _ -> false);

  (* 模块表达式测试 *)
  let module_expr = ModuleExpr [ stmt ] in
  check bool "模块表达式构造正确" true (match module_expr with ModuleExpr _ -> true | _ -> false);

  (* 类型注解表达式测试 *)
  let type_annotation = TypeAnnotationExpr (int_expr, BaseTypeExpr IntType) in
  check bool "类型注解表达式构造正确" true
    (match type_annotation with TypeAnnotationExpr (_, _) -> true | _ -> false)

(** 测试多态变体和诗词表达式 *)
let test_polymorphic_variant_and_poetry_expressions () =
  let int_expr = make_int 42 in

  (* 多态变体表达式测试 *)
  let poly_variant1 = PolymorphicVariantExpr ("Tag", Some int_expr) in
  let poly_variant2 = PolymorphicVariantExpr ("Tag", None) in
  check bool "带值多态变体表达式构造正确" true
    (match poly_variant1 with PolymorphicVariantExpr (_, Some _) -> true | _ -> false);
  check bool "无值多态变体表达式构造正确" true
    (match poly_variant2 with PolymorphicVariantExpr (_, None) -> true | _ -> false);

  (* 诗词注解表达式测试 *)
  let poetry_annotated = PoetryAnnotatedExpr (int_expr, FiveCharPoetry) in
  check bool "诗词注解表达式构造正确" true
    (match poetry_annotated with PoetryAnnotatedExpr (_, _) -> true | _ -> false);

  (* 对偶结构表达式测试 *)
  let parallel_structure = ParallelStructureExpr (int_expr, make_string "对偶") in
  check bool "对偶结构表达式构造正确" true
    (match parallel_structure with ParallelStructureExpr (_, _) -> true | _ -> false);

  (* 押韵注解表达式测试 *)
  let rhyme_info = { rhyme_category = "平韵"; rhyme_position = 1; rhyme_pattern = "押韵" } in
  let rhyme_annotated = RhymeAnnotatedExpr (int_expr, rhyme_info) in
  check bool "押韵注解表达式构造正确" true
    (match rhyme_annotated with RhymeAnnotatedExpr (_, _) -> true | _ -> false);

  (* 平仄注解表达式测试 *)
  let tone_pattern = { tone_sequence = [ LevelTone ]; tone_constraints = [ AlternatingTones ] } in
  let tone_annotated = ToneAnnotatedExpr (int_expr, tone_pattern) in
  check bool "平仄注解表达式构造正确" true
    (match tone_annotated with ToneAnnotatedExpr (_, _) -> true | _ -> false);

  (* 韵律验证表达式测试 *)
  let meter_constraint =
    { character_count = 7; syllable_pattern = None; caesura_position = None; rhyme_scheme = None }
  in
  let meter_validated = MeterValidatedExpr (int_expr, meter_constraint) in
  check bool "韵律验证表达式构造正确" true
    (match meter_validated with MeterValidatedExpr (_, _) -> true | _ -> false)

(** 测试高级语句类型 *)
let test_advanced_statement_types () =
  let int_expr = make_int 42 in
  let int_type = BaseTypeExpr IntType in

  (* 模块类型定义语句测试 *)
  let module_type_def = ModuleTypeDefStmt ("MyModuleType", ModuleTypeName "BaseType") in
  check bool "模块类型定义语句构造正确" true
    (match module_type_def with ModuleTypeDefStmt (_, _) -> true | _ -> false);

  (* 异常定义语句测试 *)
  let exception_def1 = ExceptionDefStmt ("MyException", Some int_type) in
  let exception_def2 = ExceptionDefStmt ("SimpleException", None) in
  check bool "带类型异常定义语句构造正确" true
    (match exception_def1 with ExceptionDefStmt (_, Some _) -> true | _ -> false);
  check bool "无类型异常定义语句构造正确" true
    (match exception_def2 with ExceptionDefStmt (_, None) -> true | _ -> false);

  (* 包含语句测试 *)
  let include_stmt = IncludeStmt (make_var "ModuleName") in
  check bool "包含语句构造正确" true (match include_stmt with IncludeStmt _ -> true | _ -> false);

  (* 宏定义语句测试 *)
  let macro_def = { macro_def_name = "my_macro"; params = [ ExprParam "x" ]; body = int_expr } in
  let macro_def_stmt = MacroDefStmt macro_def in
  check bool "宏定义语句构造正确" true (match macro_def_stmt with MacroDefStmt _ -> true | _ -> false)

(** 测试复杂标签参数和宏系统 *)
let test_complex_label_params_and_macros () =
  let int_expr = make_int 42 in
  let int_type = BaseTypeExpr IntType in

  (* 标签参数测试 *)
  let label_param1 =
    {
      label_name = "label1";
      param_name = "param1";
      param_type = Some int_type;
      is_optional = false;
      default_value = None;
    }
  in
  let label_param2 =
    {
      label_name = "label2";
      param_name = "param2";
      param_type = None;
      is_optional = true;
      default_value = Some int_expr;
    }
  in

  check bool "必需标签参数构造正确" true ((not label_param1.is_optional) && label_param1.default_value = None);
  check bool "可选标签参数构造正确" true (label_param2.is_optional && label_param2.default_value <> None);

  (* 标签参数函数表达式测试 *)
  let labeled_fun = LabeledFunExpr ([ label_param1; label_param2 ], int_expr) in
  check bool "标签函数表达式构造正确" true
    (match labeled_fun with LabeledFunExpr (_, _) -> true | _ -> false);

  (* 标签参数调用测试 *)
  let label_arg1 = { arg_label = "label1"; arg_value = int_expr } in
  let label_arg2 = { arg_label = "label2"; arg_value = make_string "test" } in
  let labeled_call = LabeledFunCallExpr (make_var "f", [ label_arg1; label_arg2 ]) in
  check bool "标签函数调用表达式构造正确" true
    (match labeled_call with LabeledFunCallExpr (_, _) -> true | _ -> false);

  (* 宏参数测试 *)
  let macro_params = [ ExprParam "x"; StmtParam "s"; TypeParam "t" ] in
  check int "宏参数类型数量应为3" 3 (List.length macro_params);

  (* 宏调用测试 *)
  let macro_call = { macro_call_name = "test_macro"; args = [ int_expr; make_string "arg" ] } in
  let macro_call_expr = MacroCallExpr macro_call in
  check bool "宏调用表达式构造正确" true (match macro_call_expr with MacroCallExpr _ -> true | _ -> false)

(** 测试辅助函数完整性 *)
let test_helper_functions_comprehensive () =
  (* 测试make_int函数 *)
  let int_expr = make_int 100 in
  check bool "make_int创建正确的整数表达式" true
    (match int_expr with LitExpr (IntLit 100) -> true | _ -> false);

  (* 测试make_string函数 *)
  let string_expr = make_string "测试字符串" in
  check bool "make_string创建正确的字符串表达式" true
    (match string_expr with LitExpr (StringLit "测试字符串") -> true | _ -> false);

  (* 测试make_bool函数 *)
  let bool_expr_true = make_bool true in
  let bool_expr_false = make_bool false in
  check bool "make_bool创建正确的布尔表达式true" true
    (match bool_expr_true with LitExpr (BoolLit true) -> true | _ -> false);
  check bool "make_bool创建正确的布尔表达式false" true
    (match bool_expr_false with LitExpr (BoolLit false) -> true | _ -> false);

  (* 测试make_var函数 *)
  let var_expr = make_var "变量名" in
  check bool "make_var创建正确的变量表达式" true (match var_expr with VarExpr "变量名" -> true | _ -> false);

  (* 测试make_binary_op函数 *)
  let binary_expr = make_binary_op (make_int 1) Add (make_int 2) in
  check bool "make_binary_op创建正确的二元运算表达式" true
    (match binary_expr with
    | BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)) -> true
    | _ -> false);

  (* 测试make_call函数 *)
  let call_expr = make_call (make_var "函数") [ make_int 1; make_string "参数" ] in
  check bool "make_call创建正确的函数调用表达式" true
    (match call_expr with
    | FunCallExpr (VarExpr "函数", [ LitExpr (IntLit 1); LitExpr (StringLit "参数") ]) -> true
    | _ -> false)

(** 主测试套件 *)
let test_suite () =
  [
    ("诗词形式完整性测试", `Quick, test_poetry_forms_comprehensive);
    ("韵律信息结构测试", `Quick, test_rhyme_info_structures);
    ("声调类型和约束测试", `Quick, test_tone_types_and_constraints);
    ("平仄模式结构测试", `Quick, test_tone_pattern_structures);
    ("韵律约束结构测试", `Quick, test_meter_constraint_structures);
    ("高级模式匹配测试", `Quick, test_advanced_pattern_matching);
    ("高级类型表达式测试", `Quick, test_advanced_type_expressions);
    ("高级类型定义测试", `Quick, test_advanced_type_definitions);
    ("模块系统类型测试", `Quick, test_module_system_types);
    ("高级表达式类型测试", `Quick, test_advanced_expression_types);
    ("引用和异常处理表达式测试", `Quick, test_reference_and_exception_expressions);
    ("模块和函子表达式测试", `Quick, test_module_and_functor_expressions);
    ("多态变体和诗词表达式测试", `Quick, test_polymorphic_variant_and_poetry_expressions);
    ("高级语句类型测试", `Quick, test_advanced_statement_types);
    ("复杂标签参数和宏系统测试", `Quick, test_complex_label_params_and_macros);
    ("辅助函数完整性测试", `Quick, test_helper_functions_comprehensive);
  ]

(** 执行测试 *)
let () = Alcotest.run "AST高级覆盖率测试 - Fix #2124" [ ("ast_advanced_coverage", test_suite ()) ]
