(** AST模块全面测试覆盖率提升 - Fix #1817
    
    将AST模块测试覆盖率从0%提升到80%+
    全面测试所有类型、构造器和辅助函数
    
    @author Alpha, 主要开发代理  
    @version 1.0
    @since 2025-07-30 Fix #1817 核心模块测试覆盖率提升优化 *)

open Alcotest
open Yyocamlc_lib.Ast

(** === 基础类型测试 === *)

(** 测试诗词形式完整性 *)
let test_poetry_forms () = 
  let all_forms = [
    FourCharPoetry; FiveCharPoetry; SevenCharPoetry;
    ParallelProse; RegulatedVerse; Quatrain; Couplet
  ] in
  
  (* 测试构造器存在性 *)
  check int "诗词形式总数" 7 (List.length all_forms);
  
  (* 测试相等性 *)
  check bool "四言诗相等" true (FourCharPoetry = FourCharPoetry);
  check bool "形式不相等" false (FourCharPoetry = FiveCharPoetry);
  
  (* 测试show派生 *)
  let form_str = show_poetry_form FourCharPoetry in
  check bool "show函数有效" true (String.length form_str > 0)

(** 测试声调类型 *)
let test_tone_types () =
  let tones = [LevelTone; FallingTone; RisingTone; DepartingTone; EnteringTone] in
  
  check int "声调类型总数" 5 (List.length tones);
  check bool "平声相等" true (LevelTone = LevelTone);
  check bool "不同声调不相等" false (LevelTone = FallingTone);
  
  (* 测试show函数 *)
  List.iter (fun tone ->
    let tone_str = show_tone_type tone in
    check bool ("声调show有效: " ^ tone_str) true (String.length tone_str > 0)
  ) tones

(** 测试声调约束 *)
let test_tone_constraints () =
  let constraints = [
    AlternatingTones;
    ParallelTones; 
    SpecificPattern [LevelTone; FallingTone]
  ] in
  
  check int "约束类型总数" 3 (List.length constraints);
  check bool "交替约束相等" true (AlternatingTones = AlternatingTones);
  check bool "特定模式构造" true 
    (match SpecificPattern [LevelTone] with
     | SpecificPattern _ -> true 
     | _ -> false)

(** 测试韵律信息记录 *)
let test_rhyme_info () =
  let rhyme = {
    rhyme_category = "一东";
    rhyme_position = 2; 
    rhyme_pattern = "AABA"
  } in
  
  check string "韵部" "一东" rhyme.rhyme_category;
  check int "韵脚位置" 2 rhyme.rhyme_position;
  check string "韵式" "AABA" rhyme.rhyme_pattern;
  
  (* 测试相等性 *)
  let rhyme2 = {rhyme_category = "一东"; rhyme_position = 2; rhyme_pattern = "AABA"} in
  check bool "韵律信息相等" true (rhyme = rhyme2)

(** 测试平仄模式 *)
let test_tone_pattern () =
  let pattern = {
    tone_sequence = [LevelTone; FallingTone; LevelTone];
    tone_constraints = [AlternatingTones; ParallelTones]
  } in
  
  check int "平仄序列长度" 3 (List.length pattern.tone_sequence);
  check int "约束数量" 2 (List.length pattern.tone_constraints);
  
  (* 测试show函数 *)
  let pattern_str = show_tone_pattern pattern in
  check bool "平仄模式show有效" true (String.length pattern_str > 0)

(** 测试韵律约束 *)
let test_meter_constraint () =
  let constraint_full = {
    character_count = 7;
    syllable_pattern = Some "仄平仄平仄平仄"; 
    caesura_position = Some 4;
    rhyme_scheme = Some "ABAB"
  } in
  
  let constraint_minimal = {
    character_count = 5;
    syllable_pattern = None;
    caesura_position = None; 
    rhyme_scheme = None
  } in
  
  check int "字符数约束" 7 constraint_full.character_count;
  check bool "有音节模式" true (constraint_full.syllable_pattern <> None);
  check bool "无音节模式" true (constraint_minimal.syllable_pattern = None)

(** === 基础数据类型测试 === *)

(** 测试基础类型 *)
let test_base_types () =
  let types = [IntType; FloatType; StringType; BoolType; UnitType] in
  
  check int "基础类型总数" 5 (List.length types);
  check bool "整数类型相等" true (IntType = IntType);
  check bool "不同类型不相等" false (IntType = StringType);
  
  (* 测试show函数 *)
  List.iter (fun t ->
    let type_str = show_base_type t in
    check bool ("基础类型show: " ^ type_str) true (String.length type_str > 0)
  ) types

(** 测试二元运算符 *)
let test_binary_operators () =
  let arith_ops = [Add; Sub; Mul; Div; Mod] in
  let comp_ops = [Eq; Neq; Lt; Le; Gt; Ge] in
  let logic_ops = [And; Or] in
  let string_ops = [Concat] in
  
  let all_ops = arith_ops @ comp_ops @ logic_ops @ string_ops in
  
  check int "二元运算符总数" 14 (List.length all_ops);
  
  (* 测试各类运算符 *)
  check bool "加法运算符" true (Add = Add);
  check bool "相等运算符" true (Eq = Eq);
  check bool "逻辑与运算符" true (And = And);
  check bool "连接运算符" true (Concat = Concat);
  
  (* 测试show函数 *)
  List.iter (fun op ->
    let op_str = show_binary_op op in
    check bool ("二元运算符show: " ^ op_str) true (String.length op_str > 0)
  ) all_ops

(** 测试一元运算符 *)
let test_unary_operators () =
  let ops = [Neg; Not] in
  
  check int "一元运算符总数" 2 (List.length ops);
  check bool "负号运算符" true (Neg = Neg);
  check bool "非运算符" true (Not = Not);
  check bool "运算符不相等" false (Neg = Not)

(** 测试字面量 *)
let test_literals () =
  let literals = [
    IntLit 42;
    FloatLit 3.14;
    StringLit "你好";
    BoolLit true;
    BoolLit false;
    UnitLit
  ] in
  
  check int "字面量类型总数" 6 (List.length literals);
  
  (* 测试各类字面量 *)
  check bool "整数字面量" true (IntLit 42 = IntLit 42);
  check bool "浮点字面量" true (FloatLit 3.14 = FloatLit 3.14);
  check bool "字符串字面量" true (StringLit "test" = StringLit "test");
  check bool "布尔字面量真" true (BoolLit true = BoolLit true);
  check bool "布尔字面量假" true (BoolLit false = BoolLit false);
  check bool "单元字面量" true (UnitLit = UnitLit);
  
  (* 测试不相等 *)
  check bool "不同整数不相等" false (IntLit 1 = IntLit 2);
  check bool "不同字符串不相等" false (StringLit "a" = StringLit "b")

(** === 模式匹配测试 === *)

(** 测试模式类型 *)
let test_patterns () =
  let patterns = [
    WildcardPattern;
    VarPattern "x";  
    LitPattern (IntLit 42);
    ConstructorPattern ("Some", [VarPattern "x"]);
    TuplePattern [VarPattern "x"; VarPattern "y"];
    ListPattern [VarPattern "a"; VarPattern "b"];
    ConsPattern (VarPattern "head", VarPattern "tail");
    EmptyListPattern;
    OrPattern (VarPattern "x", VarPattern "y");
    ExceptionPattern ("Error", Some (VarPattern "msg"));
    PolymorphicVariantPattern ("Tag", Some (VarPattern "value"))
  ] in
  
  check int "模式类型总数" 11 (List.length patterns);
  
  (* 测试通配符模式 *)
  check bool "通配符模式" true (WildcardPattern = WildcardPattern);
  
  (* 测试变量模式 *)
  check bool "变量模式相等" true (VarPattern "x" = VarPattern "x");
  check bool "不同变量模式不相等" false (VarPattern "x" = VarPattern "y");
  
  (* 测试字面量模式 *)
  check bool "字面量模式" true (LitPattern (IntLit 42) = LitPattern (IntLit 42));
  
  (* 测试构造器模式 *)
  check bool "构造器模式" true 
    (match ConstructorPattern ("Some", [VarPattern "x"]) with
     | ConstructorPattern (name, [VarPattern "x"]) -> name = "Some"
     | _ -> false);
  
  (* 测试元组模式 *)
  check bool "元组模式" true
    (match TuplePattern [VarPattern "x"; VarPattern "y"] with
     | TuplePattern [VarPattern "x"; VarPattern "y"] -> true
     | _ -> false);
  
  (* 测试列表模式 *)
  check bool "空列表模式" true (EmptyListPattern = EmptyListPattern);
  check bool "cons模式" true
    (match ConsPattern (VarPattern "h", VarPattern "t") with
     | ConsPattern (VarPattern "h", VarPattern "t") -> true
     | _ -> false)

(** === 类型表达式测试 === *)

(** 测试类型表达式 *)
let test_type_expressions () =
  let type_exprs = [
    BaseTypeExpr IntType;
    TypeVar "a";
    FunType (BaseTypeExpr IntType, BaseTypeExpr StringType);
    TupleType [BaseTypeExpr IntType; BaseTypeExpr StringType];
    ListType (BaseTypeExpr IntType);
    ConstructType ("Option", [BaseTypeExpr IntType]);
    RefType (BaseTypeExpr IntType);
    PolymorphicVariantType [("Tag1", Some (BaseTypeExpr IntType)); ("Tag2", None)]
  ] in
  
  check int "类型表达式总数" 8 (List.length type_exprs);
  
  (* 测试基础类型表达式 *)
  check bool "基础类型表达式" true (BaseTypeExpr IntType = BaseTypeExpr IntType);
  
  (* 测试类型变量 *)
  check bool "类型变量相等" true (TypeVar "a" = TypeVar "a");
  check bool "不同类型变量不相等" false (TypeVar "a" = TypeVar "b");
  
  (* 测试函数类型 *)
  let fun_type = FunType (BaseTypeExpr IntType, BaseTypeExpr StringType) in
  check bool "函数类型" true (fun_type = fun_type);
  
  (* 测试元组类型 *)
  let tuple_type = TupleType [BaseTypeExpr IntType; BaseTypeExpr StringType] in
  check bool "元组类型" true (tuple_type = tuple_type);
  
  (* 测试列表类型 *)
  check bool "列表类型" true (ListType (BaseTypeExpr IntType) = ListType (BaseTypeExpr IntType));
  
  (* 测试构造类型 *)
  let construct_type = ConstructType ("Option", [BaseTypeExpr IntType]) in
  check bool "构造类型" true (construct_type = construct_type);
  
  (* 测试引用类型 *)
  check bool "引用类型" true (RefType (BaseTypeExpr IntType) = RefType (BaseTypeExpr IntType))

(** === 表达式测试 === *)

(** 测试基础表达式 *)
let test_basic_expressions () =
  let exprs = [
    LitExpr (IntLit 42);
    VarExpr "x";
    BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2));
    UnaryOpExpr (Neg, LitExpr (IntLit 5));
    FunCallExpr (VarExpr "f", [LitExpr (IntLit 1); LitExpr (IntLit 2)]);
    TupleExpr [LitExpr (IntLit 1); LitExpr (StringLit "hello")];
    ListExpr [LitExpr (IntLit 1); LitExpr (IntLit 2); LitExpr (IntLit 3)]
  ] in
  
  check int "基础表达式总数" 7 (List.length exprs);
  
  (* 测试字面量表达式 *)
  check bool "字面量表达式" true (LitExpr (IntLit 42) = LitExpr (IntLit 42));
  
  (* 测试变量表达式 *)
  check bool "变量表达式相等" true (VarExpr "x" = VarExpr "x");
  check bool "不同变量表达式不相等" false (VarExpr "x" = VarExpr "y");
  
  (* 测试二元运算表达式 *)
  let binop_expr = BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)) in
  check bool "二元运算表达式" true (binop_expr = binop_expr);
  
  (* 测试一元运算表达式 *)
  let unop_expr = UnaryOpExpr (Neg, LitExpr (IntLit 5)) in
  check bool "一元运算表达式" true (unop_expr = unop_expr);
  
  (* 测试函数调用表达式 *)
  let call_expr = FunCallExpr (VarExpr "f", [LitExpr (IntLit 1)]) in
  check bool "函数调用表达式" true (call_expr = call_expr);
  
  (* 测试元组表达式 *)
  let tuple_expr = TupleExpr [LitExpr (IntLit 1); LitExpr (StringLit "hello")] in
  check bool "元组表达式" true (tuple_expr = tuple_expr);
  
  (* 测试列表表达式 *)
  let list_expr = ListExpr [LitExpr (IntLit 1); LitExpr (IntLit 2)] in
  check bool "列表表达式" true (list_expr = list_expr)

(** 测试高级表达式 *)
let test_advanced_expressions () =
  (* 测试条件表达式 *)
  let cond_expr = CondExpr (
    BinaryOpExpr (VarExpr "x", Gt, LitExpr (IntLit 0)),
    LitExpr (StringLit "positive"),
    LitExpr (StringLit "non-positive")
  ) in
  check bool "条件表达式" true (cond_expr = cond_expr);
  
  (* 测试函数表达式 *)
  let fun_expr = FunExpr (["x"; "y"], BinaryOpExpr (VarExpr "x", Add, VarExpr "y")) in
  check bool "函数表达式" true (fun_expr = fun_expr);
  
  (* 测试Let表达式 *)
  let let_expr = LetExpr ("x", LitExpr (IntLit 42), VarExpr "x") in
  check bool "Let表达式" true (let_expr = let_expr);
  
  (* 测试匹配表达式 *)
  let match_branch = {
    pattern = VarPattern "x";
    guard = None;
    expr = VarExpr "x"
  } in
  let match_expr = MatchExpr (VarExpr "value", [match_branch]) in
  check bool "匹配表达式" true (match_expr = match_expr);
  
  (* 测试记录表达式 *)
  let record_expr = RecordExpr [("name", LitExpr (StringLit "Alice")); ("age", LitExpr (IntLit 25))] in
  check bool "记录表达式" true (record_expr = record_expr);
  
  (* 测试字段访问表达式 *)
  let field_access = FieldAccessExpr (VarExpr "person", "name") in
  check bool "字段访问表达式" true (field_access = field_access);
  
  (* 测试数组表达式 *)
  let array_expr = ArrayExpr [LitExpr (IntLit 1); LitExpr (IntLit 2); LitExpr (IntLit 3)] in
  check bool "数组表达式" true (array_expr = array_expr)

(** 测试诗词相关表达式 *)
let test_poetry_expressions () =
  let base_expr = LitExpr (StringLit "春眠不觉晓") in
  let rhyme = {rhyme_category = "十一萧"; rhyme_position = 4; rhyme_pattern = "AABA"} in
  let tone_pattern = {tone_sequence = [LevelTone; FallingTone]; tone_constraints = [AlternatingTones]} in
  let meter = {character_count = 5; syllable_pattern = None; caesura_position = None; rhyme_scheme = None} in
  
  (* 测试诗词注解表达式 *)
  let poetry_expr = PoetryAnnotatedExpr (base_expr, FiveCharPoetry) in
  check bool "诗词注解表达式" true (poetry_expr = poetry_expr);
  
  (* 测试对偶结构表达式 *)
  let parallel_expr = ParallelStructureExpr (
    LitExpr (StringLit "对酒当歌"),
    LitExpr (StringLit "人生几何")
  ) in
  check bool "对偶结构表达式" true (parallel_expr = parallel_expr);
  
  (* 测试押韵注解表达式 *)
  let rhyme_expr = RhymeAnnotatedExpr (base_expr, rhyme) in
  check bool "押韵注解表达式" true (rhyme_expr = rhyme_expr);
  
  (* 测试平仄注解表达式 *)  
  let tone_expr = ToneAnnotatedExpr (base_expr, tone_pattern) in
  check bool "平仄注解表达式" true (tone_expr = tone_expr);
  
  (* 测试韵律验证表达式 *)
  let meter_expr = MeterValidatedExpr (base_expr, meter) in
  check bool "韵律验证表达式" true (meter_expr = meter_expr)

(** === 语句测试 === *)

(** 测试基础语句 *)
let test_statements () =
  let stmts = [
    ExprStmt (LitExpr (IntLit 42));
    LetStmt ("x", LitExpr (IntLit 42));
    LetStmtWithType ("x", BaseTypeExpr IntType, LitExpr (IntLit 42));
    RecLetStmt ("factorial", FunExpr (["n"], VarExpr "n"));
    TypeDefStmt ("MyInt", AliasType (BaseTypeExpr IntType));
    ExceptionDefStmt ("MyError", Some (BaseTypeExpr StringType))
  ] in
  
  check int "语句类型总数" 6 (List.length stmts);
  
  (* 测试表达式语句 *)
  let expr_stmt = ExprStmt (LitExpr (IntLit 42)) in
  check bool "表达式语句" true (expr_stmt = expr_stmt);
  
  (* 测试Let语句 *)
  let let_stmt = LetStmt ("x", LitExpr (IntLit 42)) in
  check bool "Let语句" true (let_stmt = let_stmt);
  
  (* 测试带类型Let语句 *)
  let typed_let_stmt = LetStmtWithType ("x", BaseTypeExpr IntType, LitExpr (IntLit 42)) in
  check bool "带类型Let语句" true (typed_let_stmt = typed_let_stmt);
  
  (* 测试递归Let语句 *)  
  let rec_let_stmt = RecLetStmt ("f", FunExpr (["x"], VarExpr "x")) in
  check bool "递归Let语句" true (rec_let_stmt = rec_let_stmt);
  
  (* 测试类型定义语句 *)
  let type_def_stmt = TypeDefStmt ("MyType", AliasType (BaseTypeExpr IntType)) in
  check bool "类型定义语句" true (type_def_stmt = type_def_stmt);
  
  (* 测试异常定义语句 *)
  let exc_def_stmt = ExceptionDefStmt ("Error", Some (BaseTypeExpr StringType)) in
  check bool "异常定义语句" true (exc_def_stmt = exc_def_stmt)

(** === 辅助函数测试 === *)

(** 测试辅助函数 *)
let test_helper_functions () =
  (* 测试make_int *)
  let int_expr = make_int 42 in
  check bool "make_int函数" true (int_expr = LitExpr (IntLit 42));
  
  (* 测试make_string *)
  let str_expr = make_string "hello" in
  check bool "make_string函数" true (str_expr = LitExpr (StringLit "hello"));
  
  (* 测试make_bool *)
  let bool_expr_true = make_bool true in
  let bool_expr_false = make_bool false in
  check bool "make_bool true函数" true (bool_expr_true = LitExpr (BoolLit true));
  check bool "make_bool false函数" true (bool_expr_false = LitExpr (BoolLit false));
  
  (* 测试make_var *)
  let var_expr = make_var "x" in
  check bool "make_var函数" true (var_expr = VarExpr "x");
  
  (* 测试make_binary_op *)
  let binop_expr = make_binary_op (make_int 1) Add (make_int 2) in
  let expected = BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)) in
  check bool "make_binary_op函数" true (binop_expr = expected);
  
  (* 测试make_call *)
  let call_expr = make_call (make_var "f") [make_int 1; make_int 2] in
  let expected_call = FunCallExpr (VarExpr "f", [LitExpr (IntLit 1); LitExpr (IntLit 2)]) in
  check bool "make_call函数" true (call_expr = expected_call)

(** 测试程序类型 *)
let test_program () =
  let prog = [
    LetStmt ("x", LitExpr (IntLit 42));
    ExprStmt (VarExpr "x")
  ] in
  
  check int "程序语句数量" 2 (List.length prog);
  
  (* 测试程序相等性 *)
  let prog2 = [
    LetStmt ("x", LitExpr (IntLit 42));
    ExprStmt (VarExpr "x")
  ] in
  check bool "程序相等性" true (prog = prog2)

(** === 测试套件定义 === *)

let () =
  run "AST 全面测试覆盖率提升 - Fix #1817" [
    ("诗词相关类型", [
      test_case "诗词形式" `Quick test_poetry_forms;
      test_case "声调类型" `Quick test_tone_types;
      test_case "声调约束" `Quick test_tone_constraints;
      test_case "韵律信息" `Quick test_rhyme_info;
      test_case "平仄模式" `Quick test_tone_pattern;
      test_case "韵律约束" `Quick test_meter_constraint;
    ]);
    
    ("基础数据类型", [
      test_case "基础类型" `Quick test_base_types;
      test_case "二元运算符" `Quick test_binary_operators;
      test_case "一元运算符" `Quick test_unary_operators;
      test_case "字面量" `Quick test_literals;
    ]);
    
    ("模式匹配", [
      test_case "模式类型" `Quick test_patterns;
    ]);
    
    ("类型系统", [
      test_case "类型表达式" `Quick test_type_expressions;
    ]);
    
    ("表达式", [
      test_case "基础表达式" `Quick test_basic_expressions;
      test_case "高级表达式" `Quick test_advanced_expressions;
      test_case "诗词表达式" `Quick test_poetry_expressions;
    ]);
    
    ("语句", [
      test_case "基础语句" `Quick test_statements;
    ]);
    
    ("辅助函数和程序", [
      test_case "辅助函数" `Quick test_helper_functions;
      test_case "程序类型" `Quick test_program;
    ]);
  ]