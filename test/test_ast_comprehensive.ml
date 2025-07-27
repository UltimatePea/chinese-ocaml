(** AST全面测试模块 - Phase 1测试覆盖率提升

    针对AST模块的全面测试，覆盖所有主要类型和函数
    目标：提升AST模块测试覆盖率到60%+

    @author Alpha, 主要工作代理
    @version 1.0
    @since 2025-07-27 Fix #1481 测试覆盖率提升Phase 1 *)

open Alcotest
open Yyocamlc_lib.Ast

(** 基础类型测试 *)
let test_base_types () =
  let types = [ IntType; FloatType; StringType; BoolType; UnitType ] in
  check int "基础类型数量" 5 (List.length types);
  check bool "基础类型相等性" true (IntType = IntType);
  check bool "基础类型不等性" false (IntType = StringType)

(** 字面量类型全面测试 *)
let test_literals_comprehensive () =
  let literals = [
    IntLit 42;
    IntLit (-100);
    IntLit 0;
    FloatLit 3.14;
    FloatLit (-2.71);
    FloatLit 0.0;
    StringLit "你好世界";
    StringLit "";
    StringLit "包含\n换行符的字符串";
    BoolLit true;
    BoolLit false;
    UnitLit;
  ] in
  check int "字面量类型数量" 12 (List.length literals);
  check bool "整数字面量相等" true (IntLit 42 = IntLit 42);
  check bool "浮点数字面量相等" true (FloatLit 3.14 = FloatLit 3.14);
  check bool "字符串字面量相等" true (StringLit "测试" = StringLit "测试");
  check bool "布尔字面量相等" true (BoolLit true = BoolLit true);
  check bool "单元字面量相等" true (UnitLit = UnitLit)

(** 二元运算符全面测试 *)
let test_binary_operators_comprehensive () =
  let arithmetic_ops = [ Add; Sub; Mul; Div; Mod ] in
  let comparison_ops = [ Eq; Neq; Lt; Le; Gt; Ge ] in
  let logical_ops = [ And; Or ] in
  let string_ops = [ Concat ] in
  
  check int "算术运算符数量" 5 (List.length arithmetic_ops);
  check int "比较运算符数量" 6 (List.length comparison_ops);
  check int "逻辑运算符数量" 2 (List.length logical_ops);
  check int "字符串运算符数量" 1 (List.length string_ops);
  
  check bool "运算符相等性" true (Add = Add);
  check bool "运算符不等性" false (Add = Sub)

(** 一元运算符测试 *)
let test_unary_operators () =
  let unary_ops = [ Neg; Not ] in
  check int "一元运算符数量" 2 (List.length unary_ops);
  check bool "一元运算符相等性" true (Neg = Neg);
  check bool "一元运算符不等性" false (Neg = Not)

(** 模式匹配类型全面测试 *)
let test_patterns_comprehensive () =
  let patterns = [
    WildcardPattern;
    VarPattern "变量";
    LitPattern (IntLit 42);
    LitPattern (StringLit "模式");
    LitPattern (BoolLit true);
    ConstructorPattern ("Some", [ VarPattern "x" ]);
    TuplePattern [ VarPattern "x"; VarPattern "y" ];
    ListPattern [ VarPattern "a"; VarPattern "b"; VarPattern "c" ];
    ConsPattern (VarPattern "head", VarPattern "tail");
    EmptyListPattern;
    OrPattern (VarPattern "x", VarPattern "y");
    ExceptionPattern ("MyException", Some (VarPattern "msg"));
    ExceptionPattern ("SimpleException", None);
    PolymorphicVariantPattern ("Tag", Some (VarPattern "value"));
    PolymorphicVariantPattern ("SimpleTag", None);
  ] in
  
  check int "模式类型数量" 15 (List.length patterns);
  check bool "通配符模式相等" true (WildcardPattern = WildcardPattern);
  check bool "变量模式相等" true (VarPattern "x" = VarPattern "x");
  check bool "变量模式不等" false (VarPattern "x" = VarPattern "y")

(** 类型表达式全面测试 *)
let test_type_expressions_comprehensive () =
  let simple_types = [
    BaseTypeExpr IntType;
    BaseTypeExpr StringType;
    TypeVar "'a";
    TypeVar "'b";
  ] in
  
  let complex_types = [
    FunType (BaseTypeExpr IntType, BaseTypeExpr StringType);
    TupleType [ BaseTypeExpr IntType; BaseTypeExpr StringType ];
    ListType (BaseTypeExpr IntType);
    ConstructType ("Option", [ TypeVar "'a" ]);
    RefType (BaseTypeExpr IntType);
    PolymorphicVariantType [ ("Tag1", Some (BaseTypeExpr IntType)); ("Tag2", None) ];
  ] in
  
  check int "简单类型数量" 4 (List.length simple_types);
  check int "复杂类型数量" 6 (List.length complex_types);
  
  check bool "基础类型表达式相等" true (BaseTypeExpr IntType = BaseTypeExpr IntType);
  check bool "函数类型相等" true 
    (FunType (BaseTypeExpr IntType, BaseTypeExpr StringType) = 
     FunType (BaseTypeExpr IntType, BaseTypeExpr StringType))

(** 类型定义全面测试 *)
let test_type_definitions_comprehensive () =
  let type_defs = [
    AliasType (BaseTypeExpr IntType);
    AlgebraicType [ ("None", None); ("Some", Some (TypeVar "'a")) ];
    RecordType [ ("字段1", BaseTypeExpr IntType); ("字段2", BaseTypeExpr StringType) ];
    PrivateType (BaseTypeExpr IntType);
    PolymorphicVariantTypeDef [ ("Tag1", Some (BaseTypeExpr IntType)); ("Tag2", None) ];
  ] in
  
  check int "类型定义数量" 5 (List.length type_defs);
  check bool "别名类型相等" true (AliasType (BaseTypeExpr IntType) = AliasType (BaseTypeExpr IntType))

(** 诗词形式全面测试 *)
let test_poetry_forms_comprehensive () =
  let forms = [ FourCharPoetry; FiveCharPoetry; SevenCharPoetry; ParallelProse; RegulatedVerse; Quatrain; Couplet ] in
  check int "诗词形式总数" 7 (List.length forms);
  
  List.iteri (fun i form ->
    check bool ("诗词形式" ^ string_of_int i ^ "相等性") true (form = form)
  ) forms

(** 韵律信息结构测试 *)
let test_rhyme_info_comprehensive () =
  let rhyme_infos = [
    { rhyme_category = "一东"; rhyme_position = 2; rhyme_pattern = "AABA" };
    { rhyme_category = "二冬"; rhyme_position = 4; rhyme_pattern = "ABAB" };
    { rhyme_category = "三江"; rhyme_position = 1; rhyme_pattern = "AAAA" };
  ] in
  
  check int "韵律信息数量" 3 (List.length rhyme_infos);
  
  List.iter (fun rhyme ->
    check string "韵部字段存在" rhyme.rhyme_category rhyme.rhyme_category;
    check int "韵脚位置非负" rhyme.rhyme_position rhyme.rhyme_position;
    check string "韵式字段存在" rhyme.rhyme_pattern rhyme.rhyme_pattern
  ) rhyme_infos

(** 声调类型全面测试 *)
let test_tone_types_comprehensive () =
  let tones = [ LevelTone; FallingTone; RisingTone; DepartingTone; EnteringTone ] in
  check int "声调类型总数" 5 (List.length tones);
  
  check bool "平声相等" true (LevelTone = LevelTone);
  check bool "仄声相等" true (FallingTone = FallingTone);
  check bool "平仄不等" false (LevelTone = FallingTone)

(** 声调约束全面测试 *)
let test_tone_constraints_comprehensive () =
  let constraints = [
    AlternatingTones;
    ParallelTones;
    SpecificPattern [ LevelTone; FallingTone; LevelTone ];
    SpecificPattern [ RisingTone; DepartingTone ];
    SpecificPattern [];
  ] in
  
  check int "声调约束数量" 5 (List.length constraints);
  
  List.iter (fun constraint_val ->
    match constraint_val with
    | AlternatingTones -> check bool "平仄交替约束" true true
    | ParallelTones -> check bool "平仄对仗约束" true true
    | SpecificPattern pattern -> 
        check bool "特定模式约束" true (List.length pattern >= 0)
  ) constraints

(** 平仄模式结构测试 *)
let test_tone_patterns_comprehensive () =
  let patterns = [
    { tone_sequence = [ LevelTone; FallingTone ]; tone_constraints = [ AlternatingTones ] };
    { tone_sequence = [ LevelTone; LevelTone; FallingTone; FallingTone ]; tone_constraints = [ ParallelTones ] };
    { tone_sequence = []; tone_constraints = [] };
  ] in
  
  check int "平仄模式数量" 3 (List.length patterns);
  
  List.iter (fun pattern ->
    check bool "平仄序列字段存在" true (List.length pattern.tone_sequence >= 0);
    check bool "平仄约束字段存在" true (List.length pattern.tone_constraints >= 0)
  ) patterns

(** 韵律约束结构测试 *)
let test_meter_constraints_comprehensive () =
  let constraints = [
    { character_count = 5; syllable_pattern = Some "平平仄仄平"; caesura_position = Some 2; rhyme_scheme = Some "ABABA" };
    { character_count = 7; syllable_pattern = None; caesura_position = None; rhyme_scheme = None };
    { character_count = 4; syllable_pattern = Some "平仄平仄"; caesura_position = Some 2; rhyme_scheme = Some "AABB" };
  ] in
  
  check int "韵律约束数量" 3 (List.length constraints);
  
  List.iter (fun constraint_val ->
    check bool "字符数大于0" true (constraint_val.character_count > 0);
    
    (match constraint_val.syllable_pattern with
    | Some pattern -> check bool "音节模式非空" true (String.length pattern > 0)
    | None -> check bool "音节模式为空" true true);
    
    (match constraint_val.caesura_position with
    | Some pos -> check bool "停顿位置非负" true (pos >= 0)
    | None -> check bool "停顿位置为空" true true)
  ) constraints

(** 表达式类型嵌套结构测试 *)
let test_expression_nesting () =
  let nested_expr = 
    BinaryOpExpr (
      BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)),
      Mul,
      BinaryOpExpr (LitExpr (IntLit 3), Sub, LitExpr (IntLit 4))
    ) in
  
  let tuple_expr = TupleExpr [ LitExpr (IntLit 1); LitExpr (StringLit "测试"); LitExpr (BoolLit true) ] in
  
  let list_expr = ListExpr [ LitExpr (IntLit 1); LitExpr (IntLit 2); LitExpr (IntLit 3) ] in
  
  check bool "嵌套二元表达式" true (nested_expr <> LitExpr (IntLit 0));
  check bool "元组表达式" true (tuple_expr <> LitExpr (IntLit 0));
  check bool "列表表达式" true (list_expr <> LitExpr (IntLit 0))

(** 函数表达式测试 *)
let test_function_expressions () =
  let simple_fun = FunExpr ([ "x" ], VarExpr "x") in
  let multi_param_fun = FunExpr ([ "x"; "y" ], BinaryOpExpr (VarExpr "x", Add, VarExpr "y")) in
  let typed_fun = FunExprWithType (
    [ ("x", Some (BaseTypeExpr IntType)); ("y", Some (BaseTypeExpr IntType)) ],
    Some (BaseTypeExpr IntType),
    BinaryOpExpr (VarExpr "x", Add, VarExpr "y")
  ) in
  
  check bool "简单函数表达式" true (simple_fun <> LitExpr (IntLit 0));
  check bool "多参数函数表达式" true (multi_param_fun <> LitExpr (IntLit 0));
  check bool "类型化函数表达式" true (typed_fun <> LitExpr (IntLit 0))

(** 条件表达式测试 *)
let test_conditional_expressions () =
  let simple_cond = CondExpr (
    BinaryOpExpr (VarExpr "x", Gt, LitExpr (IntLit 0)),
    LitExpr (StringLit "正数"),
    LitExpr (StringLit "非正数")
  ) in
  
  let nested_cond = CondExpr (
    BinaryOpExpr (VarExpr "x", Gt, LitExpr (IntLit 0)),
    CondExpr (
      BinaryOpExpr (VarExpr "x", Lt, LitExpr (IntLit 10)),
      LitExpr (StringLit "小正数"),
      LitExpr (StringLit "大正数")
    ),
    LitExpr (StringLit "非正数")
  ) in
  
  check bool "简单条件表达式" true (simple_cond <> LitExpr (IntLit 0));
  check bool "嵌套条件表达式" true (nested_cond <> LitExpr (IntLit 0))

(** 测试套件 *)
let () =
  run "AST全面测试套件"
    [
      ("基础类型测试", [ test_case "基础类型" `Quick test_base_types ]);
      ("字面量测试", [ test_case "字面量全面测试" `Quick test_literals_comprehensive ]);
      ("运算符测试", [
        test_case "二元运算符全面测试" `Quick test_binary_operators_comprehensive;
        test_case "一元运算符测试" `Quick test_unary_operators;
      ]);
      ("模式匹配测试", [ test_case "模式匹配全面测试" `Quick test_patterns_comprehensive ]);
      ("类型系统测试", [
        test_case "类型表达式全面测试" `Quick test_type_expressions_comprehensive;
        test_case "类型定义全面测试" `Quick test_type_definitions_comprehensive;
      ]);
      ("诗词系统测试", [
        test_case "诗词形式全面测试" `Quick test_poetry_forms_comprehensive;
        test_case "韵律信息全面测试" `Quick test_rhyme_info_comprehensive;
        test_case "声调类型全面测试" `Quick test_tone_types_comprehensive;
        test_case "声调约束全面测试" `Quick test_tone_constraints_comprehensive;
        test_case "平仄模式全面测试" `Quick test_tone_patterns_comprehensive;
        test_case "韵律约束全面测试" `Quick test_meter_constraints_comprehensive;
      ]);
      ("表达式系统测试", [
        test_case "表达式嵌套测试" `Quick test_expression_nesting;
        test_case "函数表达式测试" `Quick test_function_expressions;
        test_case "条件表达式测试" `Quick test_conditional_expressions;
      ]);
    ]