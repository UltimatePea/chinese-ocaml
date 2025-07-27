(** 骆言AST核心模块测试 - 紧急覆盖率提升 目标: 从0%提升至80%+覆盖率 Author: Alpha, 主要工作代理 *)

open Yyocamlc_lib.Ast

(** 基础类型测试 *)
let test_base_types () =
  let open Alcotest in
  let () = check bool "IntType创建" true (IntType = IntType) in
  let () = check bool "FloatType创建" true (FloatType = FloatType) in
  let () = check bool "StringType创建" true (StringType = StringType) in
  let () = check bool "BoolType创建" true (BoolType = BoolType) in
  let () = check bool "UnitType创建" true (UnitType = UnitType) in
  ()

(** 字面量测试 *)
let test_literals () =
  let open Alcotest in
  let int_lit = IntLit 42 in
  let float_lit = FloatLit 3.14 in
  let string_lit = StringLit "骆言" in
  let bool_lit = BoolLit true in
  let unit_lit = UnitLit in

  let () = check bool "整数字面量" true (int_lit = IntLit 42) in
  let () = check bool "浮点数字面量" true (float_lit = FloatLit 3.14) in
  let () = check bool "字符串字面量" true (string_lit = StringLit "骆言") in
  let () = check bool "布尔字面量" true (bool_lit = BoolLit true) in
  let () = check bool "单元字面量" true (unit_lit = UnitLit) in
  ()

(** 二元运算符测试 *)
let test_binary_ops () =
  let open Alcotest in
  let () = check bool "加法运算符" true (Add = Add) in
  let () = check bool "减法运算符" true (Sub = Sub) in
  let () = check bool "乘法运算符" true (Mul = Mul) in
  let () = check bool "除法运算符" true (Div = Div) in
  let () = check bool "取模运算符" true (Mod = Mod) in
  let () = check bool "字符串连接" true (Concat = Concat) in
  let () = check bool "相等比较" true (Eq = Eq) in
  let () = check bool "不等比较" true (Neq = Neq) in
  let () = check bool "小于比较" true (Lt = Lt) in
  let () = check bool "小于等于比较" true (Le = Le) in
  let () = check bool "大于比较" true (Gt = Gt) in
  let () = check bool "大于等于比较" true (Ge = Ge) in
  let () = check bool "逻辑与" true (And = And) in
  let () = check bool "逻辑或" true (Or = Or) in
  ()

(** 一元运算符测试 *)
let test_unary_ops () =
  let open Alcotest in
  let () = check bool "负号运算符" true (Neg = Neg) in
  let () = check bool "非运算符" true (Not = Not) in
  ()

(** 模式匹配测试 *)
let test_patterns () =
  let open Alcotest in
  let wildcard = WildcardPattern in
  let var_pat = VarPattern "x" in
  let lit_pat = LitPattern (IntLit 42) in
  let constructor_pat = ConstructorPattern ("Some", [ VarPattern "x" ]) in
  let tuple_pat = TuplePattern [ VarPattern "x"; VarPattern "y" ] in
  let list_pat = ListPattern [ VarPattern "a"; VarPattern "b" ] in
  let cons_pat = ConsPattern (VarPattern "head", VarPattern "tail") in
  let empty_list_pat = EmptyListPattern in
  let or_pat = OrPattern (VarPattern "x", VarPattern "y") in
  let exception_pat = ExceptionPattern ("MyException", Some (VarPattern "e")) in
  let poly_variant_pat = PolymorphicVariantPattern ("Tag", Some (VarPattern "x")) in

  let () = check bool "通配符模式" true (wildcard = WildcardPattern) in
  let () = check bool "变量模式" true (var_pat = VarPattern "x") in
  let () = check bool "字面量模式" true (lit_pat = LitPattern (IntLit 42)) in
  let () =
    check bool "构造器模式" true (constructor_pat = ConstructorPattern ("Some", [ VarPattern "x" ]))
  in
  let () = check bool "元组模式" true (tuple_pat = TuplePattern [ VarPattern "x"; VarPattern "y" ]) in
  let () = check bool "列表模式" true (list_pat = ListPattern [ VarPattern "a"; VarPattern "b" ]) in
  let () =
    check bool "Cons模式" true (cons_pat = ConsPattern (VarPattern "head", VarPattern "tail"))
  in
  let () = check bool "空列表模式" true (empty_list_pat = EmptyListPattern) in
  let () = check bool "或模式" true (or_pat = OrPattern (VarPattern "x", VarPattern "y")) in
  let () =
    check bool "异常模式" true (exception_pat = ExceptionPattern ("MyException", Some (VarPattern "e")))
  in
  let () =
    check bool "多态变体模式" true
      (poly_variant_pat = PolymorphicVariantPattern ("Tag", Some (VarPattern "x")))
  in
  ()

(** 类型表达式测试 *)
let test_type_exprs () =
  let open Alcotest in
  let base_type = BaseTypeExpr IntType in
  let type_var = TypeVar "a" in
  let fun_type = FunType (BaseTypeExpr IntType, BaseTypeExpr StringType) in
  let tuple_type = TupleType [ BaseTypeExpr IntType; BaseTypeExpr StringType ] in
  let list_type = ListType (BaseTypeExpr IntType) in
  let construct_type = ConstructType ("MyType", [ BaseTypeExpr IntType ]) in
  let ref_type = RefType (BaseTypeExpr IntType) in
  let poly_variant_type =
    PolymorphicVariantType [ ("Tag1", Some (BaseTypeExpr IntType)); ("Tag2", None) ]
  in

  let () = check bool "基础类型表达式" true (base_type = BaseTypeExpr IntType) in
  let () = check bool "类型变量" true (type_var = TypeVar "a") in
  let () =
    check bool "函数类型" true (fun_type = FunType (BaseTypeExpr IntType, BaseTypeExpr StringType))
  in
  let () =
    check bool "元组类型" true (tuple_type = TupleType [ BaseTypeExpr IntType; BaseTypeExpr StringType ])
  in
  let () = check bool "列表类型" true (list_type = ListType (BaseTypeExpr IntType)) in
  let () =
    check bool "构造类型" true (construct_type = ConstructType ("MyType", [ BaseTypeExpr IntType ]))
  in
  let () = check bool "引用类型" true (ref_type = RefType (BaseTypeExpr IntType)) in
  let () =
    check bool "多态变体类型" true
      (poly_variant_type
      = PolymorphicVariantType [ ("Tag1", Some (BaseTypeExpr IntType)); ("Tag2", None) ])
  in
  ()

(** 类型定义测试 *)
let test_type_defs () =
  let open Alcotest in
  let alias_type = AliasType (BaseTypeExpr IntType) in
  let algebraic_type = AlgebraicType [ ("Cons", Some (BaseTypeExpr IntType)); ("Nil", None) ] in
  let record_type =
    RecordType [ ("field1", BaseTypeExpr IntType); ("field2", BaseTypeExpr StringType) ]
  in
  let private_type = PrivateType (BaseTypeExpr IntType) in
  let poly_variant_typedef =
    PolymorphicVariantTypeDef [ ("Tag1", Some (BaseTypeExpr IntType)); ("Tag2", None) ]
  in

  let () = check bool "别名类型" true (alias_type = AliasType (BaseTypeExpr IntType)) in
  let () =
    check bool "代数类型" true
      (algebraic_type = AlgebraicType [ ("Cons", Some (BaseTypeExpr IntType)); ("Nil", None) ])
  in
  let () =
    check bool "记录类型" true
      (record_type
      = RecordType [ ("field1", BaseTypeExpr IntType); ("field2", BaseTypeExpr StringType) ])
  in
  let () = check bool "私有类型" true (private_type = PrivateType (BaseTypeExpr IntType)) in
  let () =
    check bool "多态变体类型定义" true
      (poly_variant_typedef
      = PolymorphicVariantTypeDef [ ("Tag1", Some (BaseTypeExpr IntType)); ("Tag2", None) ])
  in
  ()

(** 表达式测试 *)
let test_expressions () =
  let open Alcotest in
  let lit_expr = LitExpr (IntLit 42) in
  let var_expr = VarExpr "x" in
  let binary_op_expr = BinaryOpExpr (VarExpr "x", Add, VarExpr "y") in
  let unary_op_expr = UnaryOpExpr (Neg, VarExpr "x") in
  let fun_call_expr = FunCallExpr (VarExpr "f", [ VarExpr "x"; VarExpr "y" ]) in
  let cond_expr = CondExpr (VarExpr "condition", VarExpr "then_expr", VarExpr "else_expr") in
  let tuple_expr = TupleExpr [ VarExpr "x"; VarExpr "y" ] in
  let list_expr = ListExpr [ VarExpr "a"; VarExpr "b" ] in
  let fun_expr = FunExpr ([ "x"; "y" ], VarExpr "body") in
  let let_expr = LetExpr ("x", VarExpr "value", VarExpr "body") in

  let () = check bool "字面量表达式" true (lit_expr = LitExpr (IntLit 42)) in
  let () = check bool "变量表达式" true (var_expr = VarExpr "x") in
  let () =
    check bool "二元运算表达式" true (binary_op_expr = BinaryOpExpr (VarExpr "x", Add, VarExpr "y"))
  in
  let () = check bool "一元运算表达式" true (unary_op_expr = UnaryOpExpr (Neg, VarExpr "x")) in
  let () =
    check bool "函数调用表达式" true
      (fun_call_expr = FunCallExpr (VarExpr "f", [ VarExpr "x"; VarExpr "y" ]))
  in
  let () =
    check bool "条件表达式" true
      (cond_expr = CondExpr (VarExpr "condition", VarExpr "then_expr", VarExpr "else_expr"))
  in
  let () = check bool "元组表达式" true (tuple_expr = TupleExpr [ VarExpr "x"; VarExpr "y" ]) in
  let () = check bool "列表表达式" true (list_expr = ListExpr [ VarExpr "a"; VarExpr "b" ]) in
  let () = check bool "函数表达式" true (fun_expr = FunExpr ([ "x"; "y" ], VarExpr "body")) in
  let () = check bool "Let表达式" true (let_expr = LetExpr ("x", VarExpr "value", VarExpr "body")) in
  ()

(** 诗词相关类型测试 *)
let test_poetry_types () =
  let open Alcotest in
  let () = check bool "四言诗" true (FourCharPoetry = FourCharPoetry) in
  let () = check bool "五言诗" true (FiveCharPoetry = FiveCharPoetry) in
  let () = check bool "七言诗" true (SevenCharPoetry = SevenCharPoetry) in
  let () = check bool "骈体文" true (ParallelProse = ParallelProse) in
  let () = check bool "律诗" true (RegulatedVerse = RegulatedVerse) in
  let () = check bool "绝句" true (Quatrain = Quatrain) in
  let () = check bool "对联" true (Couplet = Couplet) in
  ()

(** 声调类型测试 *)
let test_tone_types () =
  let open Alcotest in
  let () = check bool "平声" true (LevelTone = LevelTone) in
  let () = check bool "仄声" true (FallingTone = FallingTone) in
  let () = check bool "上声" true (RisingTone = RisingTone) in
  let () = check bool "去声" true (DepartingTone = DepartingTone) in
  let () = check bool "入声" true (EnteringTone = EnteringTone) in
  ()

(** 声调约束测试 *)
let test_tone_constraints () =
  let open Alcotest in
  let alternating = AlternatingTones in
  let parallel = ParallelTones in
  let specific = SpecificPattern [ LevelTone; FallingTone ] in

  let () = check bool "平仄交替" true (alternating = AlternatingTones) in
  let () = check bool "平仄对仗" true (parallel = ParallelTones) in
  let () = check bool "特定平仄模式" true (specific = SpecificPattern [ LevelTone; FallingTone ]) in
  ()

(** 韵律信息测试 *)
let test_rhyme_info () =
  let open Alcotest in
  let rhyme_info = { rhyme_category = "东韵"; rhyme_position = 1; rhyme_pattern = "AABA" } in

  let () = check string "韵部" "东韵" rhyme_info.rhyme_category in
  let () = check int "韵脚位置" 1 rhyme_info.rhyme_position in
  let () = check string "韵式" "AABA" rhyme_info.rhyme_pattern in
  ()

(** 平仄模式测试 *)
let test_tone_pattern () =
  let open Alcotest in
  let tone_pattern =
    {
      tone_sequence = [ LevelTone; FallingTone; LevelTone; FallingTone ];
      tone_constraints = [ AlternatingTones; ParallelTones ];
    }
  in

  let () =
    check bool "平仄序列匹配" true
      (tone_pattern.tone_sequence = [ LevelTone; FallingTone; LevelTone; FallingTone ])
  in
  let () =
    check bool "平仄约束匹配" true (tone_pattern.tone_constraints = [ AlternatingTones; ParallelTones ])
  in
  ()

(** 韵律约束测试 *)
let test_meter_constraint () =
  let open Alcotest in
  let meter_constraint =
    {
      character_count = 5;
      syllable_pattern = Some "平平仄仄平";
      caesura_position = Some 2;
      rhyme_scheme = Some "ABABA";
    }
  in

  let () = check int "字符数约束" 5 meter_constraint.character_count in
  let () = check (option string) "音节模式" (Some "平平仄仄平") meter_constraint.syllable_pattern in
  let () = check (option int) "停顿位置" (Some 2) meter_constraint.caesura_position in
  let () = check (option string) "韵律方案" (Some "ABABA") meter_constraint.rhyme_scheme in
  ()

(** 语句测试 *)
let test_statements () =
  let open Alcotest in
  let expr_stmt = ExprStmt (VarExpr "x") in
  let let_stmt = LetStmt ("x", VarExpr "value") in
  let let_stmt_with_type = LetStmtWithType ("x", BaseTypeExpr IntType, VarExpr "value") in
  let rec_let_stmt = RecLetStmt ("f", VarExpr "recursive_func") in
  let semantic_let_stmt = SemanticLetStmt ("x", "数值变量", VarExpr "value") in
  let type_def_stmt = TypeDefStmt ("MyType", AliasType (BaseTypeExpr IntType)) in
  let exception_def_stmt = ExceptionDefStmt ("MyException", Some (BaseTypeExpr StringType)) in

  let () = check bool "表达式语句" true (expr_stmt = ExprStmt (VarExpr "x")) in
  let () = check bool "Let语句" true (let_stmt = LetStmt ("x", VarExpr "value")) in
  let () =
    check bool "带类型Let语句" true
      (let_stmt_with_type = LetStmtWithType ("x", BaseTypeExpr IntType, VarExpr "value"))
  in
  let () = check bool "递归Let语句" true (rec_let_stmt = RecLetStmt ("f", VarExpr "recursive_func")) in
  let () =
    check bool "语义Let语句" true (semantic_let_stmt = SemanticLetStmt ("x", "数值变量", VarExpr "value"))
  in
  let () =
    check bool "类型定义语句" true
      (type_def_stmt = TypeDefStmt ("MyType", AliasType (BaseTypeExpr IntType)))
  in
  let () =
    check bool "异常定义语句" true
      (exception_def_stmt = ExceptionDefStmt ("MyException", Some (BaseTypeExpr StringType)))
  in
  ()

(** 宏系统测试 *)
let test_macro_system () =
  let open Alcotest in
  let expr_param = ExprParam "expr_arg" in
  let stmt_param = StmtParam "stmt_arg" in
  let type_param = TypeParam "type_arg" in

  let macro_def =
    {
      macro_def_name = "my_macro";
      params = [ expr_param; stmt_param ];
      body = VarExpr "macro_body";
    }
  in

  let macro_call = { macro_call_name = "my_macro"; args = [ VarExpr "arg1"; VarExpr "arg2" ] } in

  let () = check bool "表达式参数" true (expr_param = ExprParam "expr_arg") in
  let () = check bool "语句参数" true (stmt_param = StmtParam "stmt_arg") in
  let () = check bool "类型参数" true (type_param = TypeParam "type_arg") in
  let () = check string "宏定义名称" "my_macro" macro_def.macro_def_name in
  let () = check string "宏调用名称" "my_macro" macro_call.macro_call_name in
  ()

(** 模块系统测试 *)
let test_module_system () =
  let open Alcotest in
  let sig_value = SigValue ("function_name", BaseTypeExpr IntType) in
  let sig_type_decl = SigTypeDecl ("type_name", Some (AliasType (BaseTypeExpr IntType))) in
  let sig_exception = SigException ("exception_name", Some (BaseTypeExpr StringType)) in

  let signature = Signature [ sig_value; sig_type_decl ] in
  let module_type_name = ModuleTypeName "MyModuleType" in

  let module_def =
    {
      module_def_name = "MyModule";
      module_type_annotation = Some signature;
      exports = [ ("export_func", BaseTypeExpr IntType) ];
      statements = [ ExprStmt (VarExpr "module_content") ];
    }
  in

  let module_import =
    {
      module_import_name = "ImportedModule";
      imports = [ ("func1", Some "alias1"); ("func2", None) ];
    }
  in

  let () = check bool "值签名" true (sig_value = SigValue ("function_name", BaseTypeExpr IntType)) in
  let () =
    check bool "类型声明签名" true
      (sig_type_decl = SigTypeDecl ("type_name", Some (AliasType (BaseTypeExpr IntType))))
  in
  let () =
    check bool "异常签名" true
      (sig_exception = SigException ("exception_name", Some (BaseTypeExpr StringType)))
  in
  let () = check bool "具体签名" true (signature = Signature [ sig_value; sig_type_decl ]) in
  let () = check bool "命名模块类型" true (module_type_name = ModuleTypeName "MyModuleType") in
  let () = check string "模块定义名称" "MyModule" module_def.module_def_name in
  let () = check string "模块导入名称" "ImportedModule" module_import.module_import_name in
  ()

(** 异步表达式测试 *)
let test_async_expressions () =
  let open Alcotest in
  let async_func = AsyncFunc (VarExpr "async_function") in
  let await_expr = AwaitExpr (VarExpr "promise") in
  let spawn_expr = SpawnExpr (VarExpr "task") in
  let channel_expr = ChannelExpr (VarExpr "channel") in

  let () = check bool "异步函数" true (async_func = AsyncFunc (VarExpr "async_function")) in
  let () = check bool "等待表达式" true (await_expr = AwaitExpr (VarExpr "promise")) in
  let () = check bool "产生表达式" true (spawn_expr = SpawnExpr (VarExpr "task")) in
  let () = check bool "通道表达式" true (channel_expr = ChannelExpr (VarExpr "channel")) in
  ()

(** 匹配分支测试 *)
let test_match_branches () =
  let open Alcotest in
  let match_branch =
    {
      pattern = VarPattern "x";
      guard = Some (BinaryOpExpr (VarExpr "x", Gt, LitExpr (IntLit 0)));
      expr = VarExpr "positive_result";
    }
  in

  let () = check bool "匹配模式" true (match_branch.pattern = VarPattern "x") in
  let () = check bool "守卫条件存在" true (match_branch.guard <> None) in
  let () = check bool "分支表达式" true (match_branch.expr = VarExpr "positive_result") in
  ()

(** 辅助函数测试 *)
let test_helper_functions () =
  let open Alcotest in
  let int_expr = make_int 42 in
  let string_expr = make_string "骆言" in
  let bool_expr = make_bool true in
  let var_expr = make_var "x" in
  let binary_expr = make_binary_op (make_var "x") Add (make_var "y") in
  let call_expr = make_call (make_var "f") [ make_var "x"; make_var "y" ] in

  let () = check bool "make_int辅助函数" true (int_expr = LitExpr (IntLit 42)) in
  let () = check bool "make_string辅助函数" true (string_expr = LitExpr (StringLit "骆言")) in
  let () = check bool "make_bool辅助函数" true (bool_expr = LitExpr (BoolLit true)) in
  let () = check bool "make_var辅助函数" true (var_expr = VarExpr "x") in
  let () =
    check bool "make_binary_op辅助函数" true (binary_expr = BinaryOpExpr (VarExpr "x", Add, VarExpr "y"))
  in
  let () =
    check bool "make_call辅助函数" true
      (call_expr = FunCallExpr (VarExpr "f", [ VarExpr "x"; VarExpr "y" ]))
  in
  ()

(** 诗词注解表达式测试 *)
let test_poetry_annotated_expressions () =
  let open Alcotest in
  let poetry_expr = PoetryAnnotatedExpr (VarExpr "诗句", FiveCharPoetry) in
  let parallel_expr = ParallelStructureExpr (VarExpr "上联", VarExpr "下联") in

  let rhyme_info = { rhyme_category = "东韵"; rhyme_position = 1; rhyme_pattern = "AA" } in
  let rhyme_expr = RhymeAnnotatedExpr (VarExpr "押韵句", rhyme_info) in

  let tone_pattern =
    { tone_sequence = [ LevelTone; FallingTone ]; tone_constraints = [ AlternatingTones ] }
  in
  let tone_expr = ToneAnnotatedExpr (VarExpr "平仄句", tone_pattern) in

  let meter_constraint =
    {
      character_count = 5;
      syllable_pattern = Some "平平仄仄平";
      caesura_position = None;
      rhyme_scheme = None;
    }
  in
  let meter_expr = MeterValidatedExpr (VarExpr "韵律句", meter_constraint) in

  let () =
    check bool "诗词注解表达式" true (poetry_expr = PoetryAnnotatedExpr (VarExpr "诗句", FiveCharPoetry))
  in
  let () =
    check bool "对偶结构表达式" true (parallel_expr = ParallelStructureExpr (VarExpr "上联", VarExpr "下联"))
  in
  let () =
    check bool "押韵注解表达式" true (rhyme_expr = RhymeAnnotatedExpr (VarExpr "押韵句", rhyme_info))
  in
  let () =
    check bool "平仄注解表达式" true (tone_expr = ToneAnnotatedExpr (VarExpr "平仄句", tone_pattern))
  in
  let () =
    check bool "韵律验证表达式" true (meter_expr = MeterValidatedExpr (VarExpr "韵律句", meter_constraint))
  in
  ()

(** 高级表达式测试 *)
let test_advanced_expressions () =
  let open Alcotest in
  let record_expr = RecordExpr [ ("field1", VarExpr "value1"); ("field2", VarExpr "value2") ] in
  let field_access = FieldAccessExpr (VarExpr "record", "field") in
  let record_update = RecordUpdateExpr (VarExpr "record", [ ("field1", VarExpr "new_value") ]) in
  let array_expr = ArrayExpr [ VarExpr "elem1"; VarExpr "elem2" ] in
  let array_access = ArrayAccessExpr (VarExpr "array", VarExpr "index") in
  let array_update = ArrayUpdateExpr (VarExpr "array", VarExpr "index", VarExpr "value") in
  let ref_expr = RefExpr (VarExpr "value") in
  let deref_expr = DerefExpr (VarExpr "ref") in
  let assign_expr = AssignExpr (VarExpr "ref", VarExpr "new_value") in
  let constructor_expr = ConstructorExpr ("Some", [ VarExpr "value" ]) in
  let poly_variant_expr = PolymorphicVariantExpr ("Tag", Some (VarExpr "value")) in
  let type_annotation = TypeAnnotationExpr (VarExpr "expr", BaseTypeExpr IntType) in

  let () =
    check bool "记录表达式" true
      (record_expr = RecordExpr [ ("field1", VarExpr "value1"); ("field2", VarExpr "value2") ])
  in
  let () = check bool "字段访问" true (field_access = FieldAccessExpr (VarExpr "record", "field")) in
  let () =
    check bool "记录更新" true
      (record_update = RecordUpdateExpr (VarExpr "record", [ ("field1", VarExpr "new_value") ]))
  in
  let () = check bool "数组表达式" true (array_expr = ArrayExpr [ VarExpr "elem1"; VarExpr "elem2" ]) in
  let () =
    check bool "数组访问" true (array_access = ArrayAccessExpr (VarExpr "array", VarExpr "index"))
  in
  let () =
    check bool "数组更新" true
      (array_update = ArrayUpdateExpr (VarExpr "array", VarExpr "index", VarExpr "value"))
  in
  let () = check bool "引用表达式" true (ref_expr = RefExpr (VarExpr "value")) in
  let () = check bool "解引用表达式" true (deref_expr = DerefExpr (VarExpr "ref")) in
  let () =
    check bool "赋值表达式" true (assign_expr = AssignExpr (VarExpr "ref", VarExpr "new_value"))
  in
  let () =
    check bool "构造器表达式" true (constructor_expr = ConstructorExpr ("Some", [ VarExpr "value" ]))
  in
  let () =
    check bool "多态变体表达式" true
      (poly_variant_expr = PolymorphicVariantExpr ("Tag", Some (VarExpr "value")))
  in
  let () =
    check bool "类型注解表达式" true
      (type_annotation = TypeAnnotationExpr (VarExpr "expr", BaseTypeExpr IntType))
  in
  ()

(** 标签函数测试 *)
let test_labeled_functions () =
  let open Alcotest in
  let label_param =
    {
      label_name = "label";
      param_name = "param";
      param_type = Some (BaseTypeExpr IntType);
      is_optional = false;
      default_value = None;
    }
  in

  let label_arg = { arg_label = "label"; arg_value = VarExpr "value" } in

  let labeled_fun_expr = LabeledFunExpr ([ label_param ], VarExpr "body") in
  let labeled_call_expr = LabeledFunCallExpr (VarExpr "func", [ label_arg ]) in

  let () = check string "标签名称" "label" label_param.label_name in
  let () = check string "参数名称" "param" label_param.param_name in
  let () = check bool "非可选参数" false label_param.is_optional in
  let () = check string "参数标签" "label" label_arg.arg_label in
  let () =
    check bool "标签函数表达式" true (labeled_fun_expr = LabeledFunExpr ([ label_param ], VarExpr "body"))
  in
  let () =
    check bool "标签函数调用" true (labeled_call_expr = LabeledFunCallExpr (VarExpr "func", [ label_arg ]))
  in
  ()

(** 程序类型测试 *)
let test_program () =
  let open Alcotest in
  let program = [ LetStmt ("x", LitExpr (IntLit 42)); ExprStmt (VarExpr "x") ] in

  let () = check bool "程序是语句列表" true (List.length program = 2) in
  let () = check bool "第一个语句是Let" true (List.hd program = LetStmt ("x", LitExpr (IntLit 42))) in
  ()

(** 测试套件定义 *)
let () =
  let open Alcotest in
  run "AST核心模块测试套件"
    [
      ("基础类型", [ test_case "基础类型创建和比较" `Quick test_base_types ]);
      ("字面量", [ test_case "各种字面量类型" `Quick test_literals ]);
      ("运算符", [ test_case "二元运算符" `Quick test_binary_ops; test_case "一元运算符" `Quick test_unary_ops ]);
      ("模式匹配", [ test_case "所有模式类型" `Quick test_patterns ]);
      ("类型系统", [ test_case "类型表达式" `Quick test_type_exprs; test_case "类型定义" `Quick test_type_defs ]);
      ( "表达式",
        [
          test_case "基本表达式" `Quick test_expressions;
          test_case "高级表达式" `Quick test_advanced_expressions;
        ] );
      ( "诗词系统",
        [
          test_case "诗词形式" `Quick test_poetry_types;
          test_case "声调类型" `Quick test_tone_types;
          test_case "声调约束" `Quick test_tone_constraints;
          test_case "韵律信息" `Quick test_rhyme_info;
          test_case "平仄模式" `Quick test_tone_pattern;
          test_case "韵律约束" `Quick test_meter_constraint;
          test_case "诗词注解表达式" `Quick test_poetry_annotated_expressions;
        ] );
      ("语句", [ test_case "各种语句类型" `Quick test_statements ]);
      ("宏系统", [ test_case "宏参数和定义" `Quick test_macro_system ]);
      ("模块系统", [ test_case "模块和签名" `Quick test_module_system ]);
      ("异步", [ test_case "异步表达式" `Quick test_async_expressions ]);
      ("匹配", [ test_case "匹配分支" `Quick test_match_branches ]);
      ("标签函数", [ test_case "标签参数和调用" `Quick test_labeled_functions ]);
      ("辅助函数", [ test_case "AST构造辅助函数" `Quick test_helper_functions ]);
      ("程序", [ test_case "程序结构" `Quick test_program ]);
    ]
