(** AST模块show/eq衍生函数测试覆盖率提升 - Fix #2147
    
    专门测试AST类型的show和equal派生函数，确保所有类型构造器被测试覆盖：
    - 测试所有类型的show函数输出
    - 测试所有类型的equal函数比较
    - 确保构造器函数被调用
    - 提高实际的代码覆盖率到80%+
    
    Author: Whisky, PR Worker  
    @version 1.0
    @since 2025-08-04 Fix #2147 AST模块测试覆盖率提升
*)

open Alcotest
open Yyocamlc_lib.Ast

(** 测试所有基础类型的show和eq函数 *)
let test_base_type_show_eq () =
  let types = [IntType; FloatType; StringType; BoolType; UnitType] in
  
  (* 测试每个类型的show函数 *)
  List.iter (fun typ ->
    let shown = show_base_type typ in
    check bool "base_type show不为空" true (String.length shown > 0)
  ) types;
  
  (* 测试equal函数 *)
  check bool "IntType相等" true (equal_base_type IntType IntType);
  check bool "FloatType相等" true (equal_base_type FloatType FloatType);
  check bool "StringType相等" true (equal_base_type StringType StringType);
  check bool "BoolType相等" true (equal_base_type BoolType BoolType);
  check bool "UnitType相等" true (equal_base_type UnitType UnitType);
  
  (* 测试不等情况 *)
  check bool "IntType与FloatType不等" false (equal_base_type IntType FloatType);
  check bool "StringType与BoolType不等" false (equal_base_type StringType BoolType)

(** 测试二元运算符的show和eq函数 *)
let test_binary_op_show_eq () =
  let ops = [Add; Sub; Mul; Div; Mod; Concat; Eq; Neq; Lt; Le; Gt; Ge; And; Or] in
  
  (* 测试每个运算符的show函数 *)
  List.iter (fun op ->
    let shown = show_binary_op op in
    check bool "binary_op show不为空" true (String.length shown > 0)
  ) ops;
  
  (* 测试equal函数 *)
  List.iter (fun op ->
    check bool "运算符自相等" true (equal_binary_op op op)
  ) ops;
  
  (* 测试不等情况 *)
  check bool "Add与Sub不等" false (equal_binary_op Add Sub);
  check bool "Eq与Lt不等" false (equal_binary_op Eq Lt)

(** 测试一元运算符的show和eq函数 *)
let test_unary_op_show_eq () =
  let ops = [Neg; Not] in
  
  (* 测试show函数 *)
  List.iter (fun op ->
    let shown = show_unary_op op in
    check bool "unary_op show不为空" true (String.length shown > 0)
  ) ops;
  
  (* 测试equal函数 *)
  check bool "Neg相等" true (equal_unary_op Neg Neg);
  check bool "Not相等" true (equal_unary_op Not Not);
  check bool "Neg与Not不等" false (equal_unary_op Neg Not)

(** 测试字面量的show和eq函数 *)
let test_literal_show_eq () =
  let literals = [
    IntLit 42;
    FloatLit 3.14;
    StringLit "测试字符串";
    BoolLit true;
    BoolLit false;
    UnitLit
  ] in
  
  (* 测试show函数 *)
  List.iter (fun lit ->
    let shown = show_literal lit in
    check bool "literal show不为空" true (String.length shown > 0)
  ) literals;
  
  (* 测试equal函数 *)
  check bool "IntLit相等" true (equal_literal (IntLit 42) (IntLit 42));
  check bool "FloatLit相等" true (equal_literal (FloatLit 3.14) (FloatLit 3.14));
  check bool "StringLit相等" true (equal_literal (StringLit "test") (StringLit "test"));
  check bool "BoolLit true相等" true (equal_literal (BoolLit true) (BoolLit true));
  check bool "BoolLit false相等" true (equal_literal (BoolLit false) (BoolLit false));
  check bool "UnitLit相等" true (equal_literal UnitLit UnitLit);
  
  (* 测试不等情况 *)
  check bool "不同IntLit不等" false (equal_literal (IntLit 42) (IntLit 43));
  check bool "不同StringLit不等" false (equal_literal (StringLit "a") (StringLit "b"))

(** 测试诗词形式的show和eq函数 *)
let test_poetry_form_show_eq () =
  let forms = [FourCharPoetry; FiveCharPoetry; SevenCharPoetry; ParallelProse; RegulatedVerse; Quatrain; Couplet] in
  
  (* 测试show函数 *)
  List.iter (fun form ->
    let shown = show_poetry_form form in
    check bool "poetry_form show不为空" true (String.length shown > 0)
  ) forms;
  
  (* 测试equal函数 *)
  List.iter (fun form ->
    check bool "诗词形式自相等" true (equal_poetry_form form form)
  ) forms;
  
  (* 测试不等情况 *)
  check bool "四言诗与五言诗不等" false (equal_poetry_form FourCharPoetry FiveCharPoetry)

(** 测试韵律信息的show和eq函数 *)
let test_rhyme_info_show_eq () =
  let rhyme1 = { rhyme_category = "平水韵"; rhyme_position = 1; rhyme_pattern = "AABA" } in
  let rhyme2 = { rhyme_category = "平水韵"; rhyme_position = 1; rhyme_pattern = "AABA" } in
  let rhyme3 = { rhyme_category = "词林正韵"; rhyme_position = 2; rhyme_pattern = "ABAB" } in
  
  (* 测试show函数 *)
  let shown = show_rhyme_info rhyme1 in
  check bool "rhyme_info show不为空" true (String.length shown > 0);
  
  (* 测试equal函数 *)
  check bool "相同韵律信息相等" true (equal_rhyme_info rhyme1 rhyme2);
  check bool "不同韵律信息不等" false (equal_rhyme_info rhyme1 rhyme3)

(** 测试声调类型的show和eq函数 *)
let test_tone_type_show_eq () =
  let tones = [LevelTone; FallingTone; RisingTone; DepartingTone; EnteringTone] in
  
  (* 测试show函数 *)
  List.iter (fun tone ->
    let shown = show_tone_type tone in
    check bool "tone_type show不为空" true (String.length shown > 0)
  ) tones;
  
  (* 测试equal函数 *)
  List.iter (fun tone ->
    check bool "声调自相等" true (equal_tone_type tone tone)
  ) tones;
  
  (* 测试不等情况 *)
  check bool "平声与仄声不等" false (equal_tone_type LevelTone FallingTone)

(** 测试声调约束的show和eq函数 *)
let test_tone_constraint_show_eq () =
  let constraints = [
    AlternatingTones;
    ParallelTones;
    SpecificPattern [LevelTone; FallingTone; LevelTone]
  ] in
  
  (* 测试show函数 *)
  List.iter (fun constraint_ ->
    let shown = show_tone_constraint constraint_ in
    check bool "tone_constraint show不为空" true (String.length shown > 0)
  ) constraints;
  
  (* 测试equal函数 *)
  List.iter (fun constraint_ ->
    check bool "声调约束自相等" true (equal_tone_constraint constraint_ constraint_)
  ) constraints;
  
  (* 测试不等情况 *)
  check bool "不同约束不等" false (equal_tone_constraint AlternatingTones ParallelTones)

(** 测试平仄模式的show和eq函数 *)
let test_tone_pattern_show_eq () =
  let pattern1 = {
    tone_sequence = [LevelTone; FallingTone; LevelTone; FallingTone];
    tone_constraints = [AlternatingTones]
  } in
  let pattern2 = {
    tone_sequence = [LevelTone; FallingTone; LevelTone; FallingTone];
    tone_constraints = [AlternatingTones]
  } in
  let pattern3 = {
    tone_sequence = [FallingTone; LevelTone];
    tone_constraints = [ParallelTones]
  } in
  
  (* 测试show函数 *)
  let shown = show_tone_pattern pattern1 in
  check bool "tone_pattern show不为空" true (String.length shown > 0);
  
  (* 测试equal函数 *)
  check bool "相同平仄模式相等" true (equal_tone_pattern pattern1 pattern2);
  check bool "不同平仄模式不等" false (equal_tone_pattern pattern1 pattern3)

(** 测试韵律约束的show和eq函数 *)
let test_meter_constraint_show_eq () =
  let meter1 = {
    character_count = 7;
    syllable_pattern = Some "2-2-3";
    caesura_position = Some 4;
    rhyme_scheme = Some "ABAB"
  } in
  let meter2 = {
    character_count = 7;
    syllable_pattern = Some "2-2-3";
    caesura_position = Some 4;
    rhyme_scheme = Some "ABAB"
  } in
  let meter3 = {
    character_count = 5;
    syllable_pattern = None;
    caesura_position = None;
    rhyme_scheme = None
  } in
  
  (* 测试show函数 *)
  let shown = show_meter_constraint meter1 in
  check bool "meter_constraint show不为空" true (String.length shown > 0);
  
  (* 测试equal函数 *)
  check bool "相同韵律约束相等" true (equal_meter_constraint meter1 meter2);
  check bool "不同韵律约束不等" false (equal_meter_constraint meter1 meter3)

(** 测试标识符的show和eq函数 *)
let test_identifier_show_eq () =
  let id1 = "变量名" in
  let id2 = "变量名" in
  let id3 = "另一个变量" in
  
  (* 测试show函数 *)
  let shown = show_identifier id1 in
  check bool "identifier show不为空" true (String.length shown > 0);
  
  (* 测试equal函数 *)
  check bool "相同标识符相等" true (equal_identifier id1 id2);
  check bool "不同标识符不等" false (equal_identifier id1 id3)

(** 测试模式的show和eq函数 *)
let test_pattern_show_eq () =
  let patterns = [
    WildcardPattern;
    VarPattern "x";
    LitPattern (IntLit 42);
    ConstructorPattern ("Some", [VarPattern "value"]);
    TuplePattern [VarPattern "x"; VarPattern "y"];
    ListPattern [VarPattern "a"; VarPattern "b"];
    ConsPattern (VarPattern "head", VarPattern "tail");
    EmptyListPattern;
    OrPattern (VarPattern "x", VarPattern "y");
    ExceptionPattern ("MyException", Some (VarPattern "msg"));
    PolymorphicVariantPattern ("Red", None)
  ] in
  
  (* 测试show函数 *)
  List.iter (fun pattern ->
    let shown = show_pattern pattern in
    check bool "pattern show不为空" true (String.length shown > 0)
  ) patterns;
  
  (* 测试equal函数 *)
  List.iter (fun pattern ->
    check bool "模式自相等" true (equal_pattern pattern pattern)
  ) patterns;
  
  (* 测试不等情况 *)
  check bool "通配符与变量模式不等" false (equal_pattern WildcardPattern (VarPattern "x"))

(** 测试类型表达式的show和eq函数 *)
let test_type_expr_show_eq () =
  let types = [
    BaseTypeExpr IntType;
    TypeVar "a";
    FunType (BaseTypeExpr IntType, BaseTypeExpr StringType);
    TupleType [BaseTypeExpr IntType; BaseTypeExpr StringType];
    ListType (BaseTypeExpr IntType);
    ConstructType ("MyType", []);
    RefType (BaseTypeExpr IntType);
    PolymorphicVariantType [("Red", None); ("Blue", Some (BaseTypeExpr IntType))]
  ] in
  
  (* 测试show函数 *)
  List.iter (fun typ ->
    let shown = show_type_expr typ in
    check bool "type_expr show不为空" true (String.length shown > 0)
  ) types;
  
  (* 测试equal函数 *)
  List.iter (fun typ ->
    check bool "类型表达式自相等" true (equal_type_expr typ typ)
  ) types;
  
  (* 测试不等情况 *)
  check bool "不同基础类型不等" false (equal_type_expr (BaseTypeExpr IntType) (BaseTypeExpr StringType))

(** 测试类型定义的show和eq函数 *)
let test_type_def_show_eq () =
  let type_defs = [
    AliasType (BaseTypeExpr IntType);
    AlgebraicType [("None", None); ("Some", Some (BaseTypeExpr IntType))];
    RecordType [("name", BaseTypeExpr StringType); ("age", BaseTypeExpr IntType)];
    PrivateType (BaseTypeExpr IntType);
    PolymorphicVariantTypeDef [("Red", None); ("Green", None)]
  ] in
  
  (* 测试show函数 *)
  List.iter (fun typedef ->
    let shown = show_type_def typedef in
    check bool "type_def show不为空" true (String.length shown > 0)
  ) type_defs;
  
  (* 测试equal函数 *)
  List.iter (fun typedef ->
    check bool "类型定义自相等" true (equal_type_def typedef typedef)
  ) type_defs

(** 测试宏系统的show和eq函数 *)
let test_macro_show_eq () =
  let macro_params = [ExprParam "x"; StmtParam "s"; TypeParam "t"] in
  let macro_call = { macro_call_name = "test_macro"; args = [LitExpr (IntLit 1)] } in
  let macro_def = { macro_def_name = "test_macro"; params = macro_params; body = VarExpr "x" } in
  
  (* 测试show函数 *)
  List.iter (fun param ->
    let shown = show_macro_param param in
    check bool "macro_param show不为空" true (String.length shown > 0)
  ) macro_params;
  
  let call_shown = show_macro_call macro_call in
  check bool "macro_call show不为空" true (String.length call_shown > 0);
  
  let def_shown = show_macro_def macro_def in
  check bool "macro_def show不为空" true (String.length def_shown > 0);
  
  (* 测试equal函数 *)
  List.iter (fun param ->
    check bool "宏参数自相等" true (equal_macro_param param param)
  ) macro_params;
  
  check bool "宏调用自相等" true (equal_macro_call macro_call macro_call);
  check bool "宏定义自相等" true (equal_macro_def macro_def macro_def)

(** 测试模块系统的show和eq函数 *)
let test_module_show_eq () =
  let sig_items = [
    SigValue ("add", FunType (BaseTypeExpr IntType, FunType (BaseTypeExpr IntType, BaseTypeExpr IntType)));
    SigTypeDecl ("mytype", Some (AliasType (BaseTypeExpr IntType)));
    SigException ("MyError", Some (BaseTypeExpr StringType))
  ] in
  
  let module_types = [
    Signature sig_items;
    ModuleTypeName "MyModuleType";
    FunctorType ("X", Signature [], Signature [])
  ] in
  
  let module_def = {
    module_def_name = "TestModule";
    module_type_annotation = None;
    exports = [];
    statements = []
  } in
  
  let module_import = {
    module_import_name = "List";
    imports = [("map", Some "list_map")]
  } in
  
  (* 测试show函数 *)
  List.iter (fun item ->
    let shown = show_signature_item item in
    check bool "signature_item show不为空" true (String.length shown > 0)
  ) sig_items;
  
  List.iter (fun mod_type ->
    let shown = show_module_type mod_type in
    check bool "module_type show不为空" true (String.length shown > 0)
  ) module_types;
  
  let def_shown = show_module_def module_def in
  check bool "module_def show不为空" true (String.length def_shown > 0);
  
  let import_shown = show_module_import module_import in
  check bool "module_import show不为空" true (String.length import_shown > 0);
  
  (* 测试equal函数 *)
  check bool "模块定义自相等" true (equal_module_def module_def module_def);
  check bool "模块导入自相等" true (equal_module_import module_import module_import)

(** 测试表达式系统的show和eq函数 *)
let test_expr_show_eq () =
  let simple_exprs = [
    LitExpr (IntLit 42);
    VarExpr "x";
    BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2));
    UnaryOpExpr (Neg, LitExpr (IntLit 5));
    TupleExpr [LitExpr (IntLit 1); LitExpr (StringLit "test")];
    ListExpr [LitExpr (IntLit 1); LitExpr (IntLit 2)];
    FunExpr (["x"], VarExpr "x");
    LetExpr ("x", LitExpr (IntLit 10), VarExpr "x")
  ] in
  
  (* 测试show函数 *)
  List.iter (fun expr ->
    let shown = show_expr expr in
    check bool "expr show不为空" true (String.length shown > 0)
  ) simple_exprs;
  
  (* 测试equal函数 *)
  List.iter (fun expr ->
    check bool "表达式自相等" true (equal_expr expr expr)
  ) simple_exprs

(** 测试语句系统的show和eq函数 *)
let test_stmt_show_eq () =
  let stmts = [
    ExprStmt (LitExpr (IntLit 42));
    LetStmt ("x", LitExpr (IntLit 10));
    LetStmtWithType ("y", BaseTypeExpr IntType, LitExpr (IntLit 20));
    RecLetStmt ("factorial", FunExpr (["n"], VarExpr "n"));
    SemanticLetStmt ("result", "计算结果", LitExpr (IntLit 100));
    TypeDefStmt ("mytype", AliasType (BaseTypeExpr IntType));
    ExceptionDefStmt ("MyError", Some (BaseTypeExpr StringType))
  ] in
  
  (* 测试show函数 *)
  List.iter (fun stmt ->
    let shown = show_stmt stmt in
    check bool "stmt show不为空" true (String.length shown > 0)
  ) stmts;
  
  (* 测试equal函数 *)
  List.iter (fun stmt ->
    check bool "语句自相等" true (equal_stmt stmt stmt)
  ) stmts

(** 测试程序的show和eq函数 *)
let test_program_show_eq () =
  let program = [
    LetStmt ("x", LitExpr (IntLit 42));
    ExprStmt (FunCallExpr (VarExpr "print", [VarExpr "x"]))
  ] in
  
  (* 测试show函数 *)
  let shown = show_program program in
  check bool "program show不为空" true (String.length shown > 0);
  
  (* 测试equal函数 *)
  check bool "程序自相等" true (equal_program program program)

(** 主测试运行器 *)
let () =
  run "AST模块show/eq衍生函数测试覆盖率提升 - Fix #2147"
    [
      ( "基础类型show/eq测试",
        [
          test_case "基础类型show/eq" `Quick test_base_type_show_eq;
          test_case "二元运算符show/eq" `Quick test_binary_op_show_eq;
          test_case "一元运算符show/eq" `Quick test_unary_op_show_eq;
          test_case "字面量show/eq" `Quick test_literal_show_eq;
          test_case "标识符show/eq" `Quick test_identifier_show_eq;
        ] );
      ( "诗词类型show/eq测试",
        [
          test_case "诗词形式show/eq" `Quick test_poetry_form_show_eq;
          test_case "韵律信息show/eq" `Quick test_rhyme_info_show_eq;
          test_case "声调类型show/eq" `Quick test_tone_type_show_eq;
          test_case "声调约束show/eq" `Quick test_tone_constraint_show_eq;
          test_case "平仄模式show/eq" `Quick test_tone_pattern_show_eq;
          test_case "韵律约束show/eq" `Quick test_meter_constraint_show_eq;
        ] );
      ( "模式和类型show/eq测试",
        [
          test_case "模式show/eq" `Quick test_pattern_show_eq;
          test_case "类型表达式show/eq" `Quick test_type_expr_show_eq;
          test_case "类型定义show/eq" `Quick test_type_def_show_eq;
        ] );
      ( "宏和模块系统show/eq测试",
        [
          test_case "宏系统show/eq" `Quick test_macro_show_eq;
          test_case "模块系统show/eq" `Quick test_module_show_eq;
        ] );
      ( "表达式和语句show/eq测试",
        [
          test_case "表达式show/eq" `Quick test_expr_show_eq;
          test_case "语句show/eq" `Quick test_stmt_show_eq;
          test_case "程序show/eq" `Quick test_program_show_eq;
        ] );
    ]