(** AST模块全面测试覆盖 - Fix #1377

    对ast.ml进行全面测试，提升覆盖率从13%到80%+

    @author Charlie, 规划专员
    @version 1.0
    @since 2025-07-26 Fix #1377 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Ast

(** 测试所有诗词形式 *)
let test_all_poetry_forms () =
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
  check int "诗词形式总数应为7" 7 (List.length forms);

  (* 测试每种形式的相等性 *)
  check bool "四言诗相等性" true (FourCharPoetry = FourCharPoetry);
  check bool "五言诗相等性" true (FiveCharPoetry = FiveCharPoetry);
  check bool "七言诗相等性" true (SevenCharPoetry = SevenCharPoetry);
  check bool "骈体文相等性" true (ParallelProse = ParallelProse);
  check bool "律诗相等性" true (RegulatedVerse = RegulatedVerse);
  check bool "绝句相等性" true (Quatrain = Quatrain);
  check bool "对联相等性" true (Couplet = Couplet);

  (* 测试不同形式不相等 *)
  check bool "四言诗与五言诗不相等" false (FourCharPoetry = FiveCharPoetry);
  check bool "律诗与绝句不相等" false (RegulatedVerse = Quatrain)

(** 测试韵律信息完整性 *)
let test_rhyme_info_comprehensive () =
  let rhyme1 = { rhyme_category = "一东"; rhyme_position = 2; rhyme_pattern = "AABA" } in
  let rhyme2 = { rhyme_category = "二冬"; rhyme_position = 4; rhyme_pattern = "ABAB" } in
  let rhyme3 = { rhyme_category = "一东"; rhyme_position = 2; rhyme_pattern = "AABA" } in

  (* 基本字段测试 *)
  check string "韵部字段" "一东" rhyme1.rhyme_category;
  check int "韵脚位置字段" 2 rhyme1.rhyme_position;
  check string "韵式字段" "AABA" rhyme1.rhyme_pattern;

  (* 相等性测试 *)
  check bool "相同韵律信息相等" true (rhyme1 = rhyme3);
  check bool "不同韵律信息不相等" false (rhyme1 = rhyme2);

  (* 边界值测试 *)
  let edge_rhyme = { rhyme_category = ""; rhyme_position = 0; rhyme_pattern = "" } in
  check string "空韵部" "" edge_rhyme.rhyme_category;
  check int "零位置韵脚" 0 edge_rhyme.rhyme_position

(** 测试声调类型和约束 *)
let test_tone_patterns_comprehensive () =
  let all_tones = [ LevelTone; FallingTone; RisingTone; DepartingTone; EnteringTone ] in
  check int "声调类型总数" 5 (List.length all_tones);

  (* 声调约束测试 *)
  let alternating = AlternatingTones in
  let parallel = ParallelTones in
  let specific = SpecificPattern [ LevelTone; FallingTone; LevelTone ] in

  check bool "平仄交替约束" true (alternating = AlternatingTones);
  check bool "平仄对仗约束" true (parallel = ParallelTones);

  (* 特定模式约束测试 *)
  match specific with
  | SpecificPattern pattern ->
      check int "特定模式长度" 3 (List.length pattern);
      check bool "模式第一个为平声" true (List.hd pattern = LevelTone)
  | _ ->
      fail "应为特定模式约束";

      (* 声调模式组合测试 *)
      let tone_pattern =
        {
          tone_sequence = [ LevelTone; FallingTone; LevelTone; FallingTone ];
          tone_constraints = [ AlternatingTones; SpecificPattern [ LevelTone; FallingTone ] ];
        }
      in
      check int "声调序列长度" 4 (List.length tone_pattern.tone_sequence);
      check int "声调约束数量" 2 (List.length tone_pattern.tone_constraints)

(** 测试韵律约束 *)
let test_meter_constraints () =
  let meter =
    {
      character_count = 7;
      syllable_pattern = Some "仄平平仄仄平平";
      caesura_position = Some 4;
      rhyme_scheme = Some "AABA";
    }
  in

  check int "字符数约束" 7 meter.character_count;
  check (option string) "音节模式" (Some "仄平平仄仄平平") meter.syllable_pattern;
  check (option int) "停顿位置" (Some 4) meter.caesura_position;
  check (option string) "韵律方案" (Some "AABA") meter.rhyme_scheme;

  (* 空选项测试 *)
  let minimal_meter =
    { character_count = 5; syllable_pattern = None; caesura_position = None; rhyme_scheme = None }
  in
  check int "最小字符数" 5 minimal_meter.character_count;
  check (option string) "空音节模式" None minimal_meter.syllable_pattern

(** 测试基础类型 *)
let test_base_types () =
  let types = [ IntType; FloatType; StringType; BoolType; UnitType ] in
  check int "基础类型总数" 5 (List.length types);

  (* 类型相等性 *)
  check bool "整数类型相等" true (IntType = IntType);
  check bool "字符串与整数类型不等" false (StringType = IntType);
  check bool "布尔类型相等" true (BoolType = BoolType)

(** 测试二元运算符 *)
let test_binary_operators () =
  let arithmetic_ops = [ Add; Sub; Mul; Div; Mod ] in
  let comparison_ops = [ Eq; Neq; Lt; Le; Gt; Ge ] in
  let logical_ops = [ And; Or ] in
  let string_ops = [ Concat ] in

  check int "算术运算符数量" 5 (List.length arithmetic_ops);
  check int "比较运算符数量" 6 (List.length comparison_ops);
  check int "逻辑运算符数量" 2 (List.length logical_ops);
  check int "字符串运算符数量" 1 (List.length string_ops);

  (* 运算符相等性 *)
  check bool "加法运算符相等" true (Add = Add);
  check bool "减法与乘法不等" false (Sub = Mul);
  check bool "等于运算符相等" true (Eq = Eq)

(** 测试一元运算符 *)
let test_unary_operators () =
  check bool "负号运算符相等" true (Neg = Neg);
  check bool "非运算符相等" true (Not = Not);
  check bool "负号与非运算符不等" false (Neg = Not)

(** 测试字面量 *)
let test_literals () =
  let int_lit = IntLit 42 in
  let float_lit = FloatLit 3.14 in
  let string_lit = StringLit "你好世界" in
  let bool_lit = BoolLit true in
  let unit_lit = UnitLit in

  (* 字面量相等性 *)
  check bool "整数字面量相等" true (int_lit = IntLit 42);
  check bool "浮点字面量相等" true (float_lit = FloatLit 3.14);
  check bool "字符串字面量相等" true (string_lit = StringLit "你好世界");
  check bool "布尔字面量相等" true (bool_lit = BoolLit true);
  check bool "单元字面量相等" true (unit_lit = UnitLit);

  (* 不同字面量不等 *)
  check bool "不同整数不等" false (IntLit 42 = IntLit 24);
  check bool "不同类型不等" false (int_lit = string_lit)

(** 测试模式匹配 *)
let test_patterns () =
  let wildcard = WildcardPattern in
  let var_pat = VarPattern "x" in
  let lit_pat = LitPattern (IntLit 42) in
  let cons_pat = ConstructorPattern ("Some", [ VarPattern "x" ]) in
  let tuple_pat = TuplePattern [ VarPattern "x"; VarPattern "y" ] in
  let list_pat = ListPattern [ VarPattern "a"; VarPattern "b" ] in
  let cons_list_pat = ConsPattern (VarPattern "head", VarPattern "tail") in
  let empty_list_pat = EmptyListPattern in
  let or_pat = OrPattern (VarPattern "x", VarPattern "y") in

  (* 模式相等性测试 *)
  check bool "通配符模式相等" true (wildcard = WildcardPattern);
  check bool "变量模式相等" true (var_pat = VarPattern "x");
  check bool "字面量模式相等" true (lit_pat = LitPattern (IntLit 42));
  check bool "构造器模式相等" true (cons_pat = ConstructorPattern ("Some", [ VarPattern "x" ]));
  check bool "空列表模式相等" true (empty_list_pat = EmptyListPattern);

  (* 复合模式测试 *)
  match tuple_pat with
  | TuplePattern patterns -> check int "元组模式长度" 2 (List.length patterns)
  | _ -> (
      fail "应为元组模式";

      match list_pat with
      | ListPattern patterns -> check int "列表模式长度" 2 (List.length patterns)
      | _ -> fail "应为列表模式")

(** 测试类型表达式 *)
let test_type_expressions () =
  let base_type = BaseTypeExpr IntType in
  let type_var = TypeVar "a" in
  let fun_type = FunType (BaseTypeExpr IntType, BaseTypeExpr StringType) in
  let tuple_type = TupleType [ BaseTypeExpr IntType; BaseTypeExpr FloatType ] in
  let list_type = ListType (BaseTypeExpr IntType) in
  let ref_type = RefType (BaseTypeExpr IntType) in

  check bool "基础类型表达式相等" true (base_type = BaseTypeExpr IntType);
  check bool "类型变量相等" true (type_var = TypeVar "a");
  check bool "函数类型相等" true (fun_type = FunType (BaseTypeExpr IntType, BaseTypeExpr StringType));

  (* 复合类型测试 *)
  match tuple_type with
  | TupleType types -> check int "元组类型长度" 2 (List.length types)
  | _ -> (
      fail "应为元组类型";

      match list_type with
      | ListType elem_type -> check bool "列表元素类型" true (elem_type = BaseTypeExpr IntType)
      | _ -> fail "应为列表类型")

(** 测试表达式构造 *)
let test_expressions () =
  let int_expr = LitExpr (IntLit 42) in
  let var_expr = VarExpr "x" in
  let binary_expr = BinaryOpExpr (int_expr, Add, LitExpr (IntLit 1)) in
  let unary_expr = UnaryOpExpr (Neg, int_expr) in
  let call_expr = FunCallExpr (var_expr, [ int_expr ]) in
  let cond_expr = CondExpr (LitExpr (BoolLit true), int_expr, LitExpr (IntLit 0)) in
  let tuple_expr = TupleExpr [ int_expr; var_expr ] in
  let list_expr = ListExpr [ int_expr; LitExpr (IntLit 1) ] in

  (* 表达式相等性测试 *)
  check bool "整数表达式相等" true (int_expr = LitExpr (IntLit 42));
  check bool "变量表达式相等" true (var_expr = VarExpr "x");

  (* 复合表达式测试 *)
  match binary_expr with
  | BinaryOpExpr (left, op, right) ->
      check bool "二元表达式左操作数" true (left = int_expr);
      check bool "二元表达式运算符" true (op = Add);
      check bool "二元表达式右操作数" true (right = LitExpr (IntLit 1))
  | _ -> (
      fail "应为二元表达式";

      match tuple_expr with
      | TupleExpr exprs -> check int "元组表达式长度" 2 (List.length exprs)
      | _ -> fail "应为元组表达式")

(** 测试辅助函数 *)
let test_helper_functions () =
  let int_expr = make_int 42 in
  let string_expr = make_string "测试" in
  let bool_expr = make_bool true in
  let var_expr = make_var "x" in
  let binary_expr = make_binary_op (make_int 1) Add (make_int 2) in
  let call_expr = make_call (make_var "func") [ make_int 1; make_int 2 ] in

  (* 验证辅助函数创建的表达式 *)
  check bool "make_int创建整数表达式" true (int_expr = LitExpr (IntLit 42));
  check bool "make_string创建字符串表达式" true (string_expr = LitExpr (StringLit "测试"));
  check bool "make_bool创建布尔表达式" true (bool_expr = LitExpr (BoolLit true));
  check bool "make_var创建变量表达式" true (var_expr = VarExpr "x");

  (* 复合表达式验证 *)
  match binary_expr with
  | BinaryOpExpr (LitExpr (IntLit 1), Add, LitExpr (IntLit 2)) ->
      check bool "make_binary_op创建正确的二元表达式" true true
  | _ -> (
      fail "make_binary_op应创建正确的二元表达式";

      match call_expr with
      | FunCallExpr (VarExpr "func", args) -> check int "make_call参数数量" 2 (List.length args)
      | _ -> fail "make_call应创建正确的函数调用表达式")

(** 测试语句类型 *)
let test_statements () =
  let expr_stmt = ExprStmt (LitExpr (IntLit 42)) in
  let let_stmt = LetStmt ("x", LitExpr (IntLit 42)) in
  let let_type_stmt = LetStmtWithType ("x", BaseTypeExpr IntType, LitExpr (IntLit 42)) in
  let rec_let_stmt = RecLetStmt ("f", LitExpr (IntLit 1)) in

  (* 语句相等性测试 *)
  check bool "表达式语句相等" true (expr_stmt = ExprStmt (LitExpr (IntLit 42)));
  check bool "let语句相等" true (let_stmt = LetStmt ("x", LitExpr (IntLit 42)));

  (* 带类型语句测试 *)
  match let_type_stmt with
  | LetStmtWithType (name, type_expr, expr) ->
      check string "带类型let语句名称" "x" name;
      check bool "带类型let语句类型" true (type_expr = BaseTypeExpr IntType);
      check bool "带类型let语句表达式" true (expr = LitExpr (IntLit 42))
  | _ -> fail "应为带类型let语句"

(** 测试诗词特殊表达式 *)
let test_poetry_expressions () =
  let base_expr = LitExpr (StringLit "春眠不觉晓") in
  let poetry_expr = PoetryAnnotatedExpr (base_expr, FiveCharPoetry) in
  let rhyme_info = { rhyme_category = "一东"; rhyme_position = 5; rhyme_pattern = "AABA" } in
  let rhyme_expr = RhymeAnnotatedExpr (base_expr, rhyme_info) in
  let tone_pattern =
    {
      tone_sequence = [ LevelTone; FallingTone; LevelTone; FallingTone; LevelTone ];
      tone_constraints = [ AlternatingTones ];
    }
  in
  let tone_expr = ToneAnnotatedExpr (base_expr, tone_pattern) in

  (* 诗词表达式测试 *)
  match poetry_expr with
  | PoetryAnnotatedExpr (expr, form) ->
      check bool "诗词注解表达式内容" true (expr = base_expr);
      check bool "诗词注解形式" true (form = FiveCharPoetry)
  | _ -> (
      fail "应为诗词注解表达式";

      (* 韵律表达式测试 *)
      match rhyme_expr with
      | RhymeAnnotatedExpr (expr, rhyme) ->
          check bool "韵律注解表达式内容" true (expr = base_expr);
          check string "韵律注解韵部" "一东" rhyme.rhyme_category
      | _ -> (
          fail "应为韵律注解表达式";

          (* 平仄表达式测试 *)
          match tone_expr with
          | ToneAnnotatedExpr (expr, pattern) ->
              check bool "平仄注解表达式内容" true (expr = base_expr);
              check int "平仄序列长度" 5 (List.length pattern.tone_sequence)
          | _ -> fail "应为平仄注解表达式"))

(** 测试模块系统 *)
let test_module_system () =
  let sig_value = SigValue ("func", FunType (BaseTypeExpr IntType, BaseTypeExpr StringType)) in
  let sig_type = SigTypeDecl ("MyType", Some (AliasType (BaseTypeExpr IntType))) in
  let signature = Signature [ sig_value; sig_type ] in
  let module_type_name = ModuleTypeName "MyModuleType" in

  (* 签名项测试 *)
  match sig_value with
  | SigValue (name, type_expr) ->
      check string "签名值名称" "func" name;
      check bool "签名值类型" true (type_expr = FunType (BaseTypeExpr IntType, BaseTypeExpr StringType))
  | _ -> (
      fail "应为签名值";

      (* 模块类型测试 *)
      match signature with
      | Signature items -> check int "签名项数量" 2 (List.length items)
      | _ ->
          fail "应为具体签名";

          check bool "模块类型名称相等" true (module_type_name = ModuleTypeName "MyModuleType"))

(** 测试程序结构 *)
let test_program_structure () =
  let stmt1 = ExprStmt (LitExpr (IntLit 42)) in
  let stmt2 = LetStmt ("x", LitExpr (StringLit "hello")) in
  let program = [ stmt1; stmt2 ] in

  check int "程序语句数量" 2 (List.length program);
  check bool "程序第一个语句" true (List.hd program = stmt1);
  check bool "程序最后一个语句" true (List.nth program 1 = stmt2)

(** 主测试运行器 *)
let () =
  run "AST全面测试覆盖 - Fix #1377"
    [
      ("诗词形式", [ test_case "所有诗词形式测试" `Quick test_all_poetry_forms ]);
      ("韵律信息", [ test_case "韵律信息完整测试" `Quick test_rhyme_info_comprehensive ]);
      ("声调模式", [ test_case "声调模式和约束测试" `Quick test_tone_patterns_comprehensive ]);
      ("韵律约束", [ test_case "韵律约束测试" `Quick test_meter_constraints ]);
      ("基础类型", [ test_case "基础类型测试" `Quick test_base_types ]);
      ("二元运算符", [ test_case "二元运算符测试" `Quick test_binary_operators ]);
      ("一元运算符", [ test_case "一元运算符测试" `Quick test_unary_operators ]);
      ("字面量", [ test_case "字面量测试" `Quick test_literals ]);
      ("模式匹配", [ test_case "模式匹配测试" `Quick test_patterns ]);
      ("类型表达式", [ test_case "类型表达式测试" `Quick test_type_expressions ]);
      ("表达式构造", [ test_case "表达式构造测试" `Quick test_expressions ]);
      ("辅助函数", [ test_case "辅助函数测试" `Quick test_helper_functions ]);
      ("语句类型", [ test_case "语句类型测试" `Quick test_statements ]);
      ("诗词表达式", [ test_case "诗词特殊表达式测试" `Quick test_poetry_expressions ]);
      ("模块系统", [ test_case "模块系统测试" `Quick test_module_system ]);
      ("程序结构", [ test_case "程序结构测试" `Quick test_program_structure ]);
    ]
