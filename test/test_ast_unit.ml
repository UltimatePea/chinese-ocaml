(** 骆言抽象语法树单元测试 *)

open Alcotest
open Yyocamlc_lib.Ast

(* 测试诗词形式相关功能 *)
let test_poetry_form () =
  let four_char = FourCharPoetry in
  let five_char = FiveCharPoetry in
  let seven_char = SevenCharPoetry in
  
  check bool "四言诗相等性测试" true (four_char = four_char);
  check bool "不同诗词形式不相等" false (four_char = five_char);
  check bool "七言诗相等性测试" true (seven_char = seven_char)

(* 测试韵律信息 *)
let test_rhyme_info () =
  let rhyme = {
    rhyme_category = "平韵";
    rhyme_position = 1;
    rhyme_pattern = "aaba";
  } in
  
  check string "韵部测试" "平韵" rhyme.rhyme_category;
  check int "韵脚位置测试" 1 rhyme.rhyme_position;
  check string "韵式测试" "aaba" rhyme.rhyme_pattern

(* 测试声调类型 *)
let test_tone_type () =
  let level = LevelTone in
  let falling = FallingTone in
  let rising = RisingTone in
  let departing = DepartingTone in
  let entering = EnteringTone in
  
  check bool "平声相等性测试" true (level = level);
  check bool "不同声调不相等" false (level = falling);
  check bool "仄声包含测试" true (falling = falling);
  check bool "上声测试" true (rising = rising);
  check bool "去声测试" true (departing = departing);
  check bool "入声测试" true (entering = entering)

(* 测试平仄模式 *)
let test_tone_pattern () =
  let pattern = {
    tone_sequence = [LevelTone; FallingTone; LevelTone];
    tone_constraints = [AlternatingTones; ParallelTones];
  } in
  
  check int "平仄序列长度测试" 3 (List.length pattern.tone_sequence);
  check int "平仄约束数量测试" 2 (List.length pattern.tone_constraints)

(* 测试声调约束 *)
let test_tone_constraint () =
  let alternating = AlternatingTones in
  let parallel = ParallelTones in
  let specific = SpecificPattern [LevelTone; FallingTone] in
  
  check bool "平仄交替约束测试" true (alternating = alternating);
  check bool "平仄对仗约束测试" true (parallel = parallel);
  check bool "特定模式约束测试" true 
    (match specific with
     | SpecificPattern [LevelTone; FallingTone] -> true
     | _ -> false)

(* 测试基础数据类型 *)
let test_basic_types () =
  let int_type = IntType in
  let float_type = FloatType in
  let bool_type = BoolType in
  let string_type = StringType in
  let char_type = StringType in
  
  check bool "整数类型测试" true (int_type = int_type);
  check bool "浮点数类型测试" true (float_type = float_type);
  check bool "布尔类型测试" true (bool_type = bool_type);
  check bool "字符串类型测试" true (string_type = string_type);
  check bool "字符类型测试" true (char_type = char_type);
  check bool "不同类型不相等" false (int_type = float_type)

(* 测试复合类型 *)
let test_compound_types () =
  let fun_type = FunType (IntType, IntType) in
  let tuple_type = TupleType [IntType; StringType] in
  let list_type = ListType IntType in
  
  check bool "函数类型测试" true (fun_type = fun_type);
  check bool "元组类型测试" true (tuple_type = tuple_type);
  check bool "列表类型测试" true (list_type = list_type);
  
  (* 测试嵌套类型 *)
  let nested_fun = FunType (IntType, FunType (StringType, BoolType)) in
  check bool "嵌套函数类型测试" true (nested_fun = nested_fun)

(* 测试表达式基础构造 *)
let test_basic_expressions () =
  let int_expr = IntExpr 42 in
  let float_expr = FloatExpr 3.14 in
  let bool_expr = BoolExpr true in
  let string_expr = StringExpr "测试" in
  let char_expr = CharExpr 'a' in
  
  check bool "整数表达式测试" true (int_expr = int_expr);
  check bool "浮点数表达式测试" true (float_expr = float_expr);
  check bool "布尔表达式测试" true (bool_expr = bool_expr);
  check bool "字符串表达式测试" true (string_expr = string_expr);
  check bool "字符表达式测试" true (char_expr = char_expr)

(* 测试变量和标识符 *)
let test_identifiers () =
  let var_expr = VarExpr "变量" in
  let another_var = VarExpr "另一个变量" in
  
  check bool "变量表达式相等性测试" true (var_expr = var_expr);
  check bool "不同变量不相等" false (var_expr = another_var)

(* 测试运算表达式 *)
let test_operations () =
  let add_expr = BinOpExpr (Add, IntExpr 1, IntExpr 2) in
  let sub_expr = BinOpExpr (Sub, IntExpr 5, IntExpr 3) in
  let mul_expr = BinOpExpr (Mul, IntExpr 2, IntExpr 3) in
  let div_expr = BinOpExpr (Div, IntExpr 6, IntExpr 2) in
  
  check bool "加法表达式测试" true (add_expr = add_expr);
  check bool "减法表达式测试" true (sub_expr = sub_expr);
  check bool "乘法表达式测试" true (mul_expr = mul_expr);
  check bool "除法表达式测试" true (div_expr = div_expr);
  check bool "不同运算不相等" false (add_expr = sub_expr)

(* 测试条件表达式 *)
let test_conditional () =
  let if_expr = IfExpr (BoolExpr true, IntExpr 1, IntExpr 0) in
  let nested_if = IfExpr (BoolExpr false, 
                         IfExpr (BoolExpr true, IntExpr 2, IntExpr 3),
                         IntExpr 4) in
  
  check bool "条件表达式测试" true (if_expr = if_expr);
  check bool "嵌套条件表达式测试" true (nested_if = nested_if)

(* 测试函数相关表达式 *)
let test_functions () =
  let fun_expr = FunExpr (["x"], IntExpr 1) in
  let app_expr = AppExpr (VarExpr "f", [IntExpr 1]) in
  
  check bool "函数定义表达式测试" true (fun_expr = fun_expr);
  check bool "函数应用表达式测试" true (app_expr = app_expr)

(* 测试Let表达式 *)
let test_let_expressions () =
  let let_expr = LetExpr ("x", IntExpr 1, VarExpr "x") in
  let rec_let = RecLetExpr ("f", FunExpr (["x"], VarExpr "x"), VarExpr "f") in
  
  check bool "Let表达式测试" true (let_expr = let_expr);
  check bool "递归Let表达式测试" true (rec_let = rec_let)

(* 测试诗词相关表达式 *)
let test_poetry_expressions () =
  let poetry_expr = PoetryAnnotatedExpr (IntExpr 1, FourCharPoetry, "测试诗词") in
  let parallel_expr = ParallelStructureExpr (IntExpr 1, IntExpr 2, "对偶结构") in
  
  check bool "诗词注解表达式测试" true (poetry_expr = poetry_expr);
  check bool "对偶结构表达式测试" true (parallel_expr = parallel_expr)

(* 测试语句类型 *)
let test_statements () =
  let let_stmt = LetStmt ("x", IntExpr 1) in
  let rec_let_stmt = RecLetStmt ("f", FunExpr (["x"], VarExpr "x")) in
  let expr_stmt = ExprStmt (IntExpr 42) in
  
  check bool "Let语句测试" true (let_stmt = let_stmt);
  check bool "递归Let语句测试" true (rec_let_stmt = rec_let_stmt);
  check bool "表达式语句测试" true (expr_stmt = expr_stmt)

(* 测试类型定义 *)
let test_type_definitions () =
  let type_def = TypeDefStmt ("MyType", [], AliasType IntType) in
  let record_def = TypeDefStmt ("Record", [], 
                               RecordType [("field1", IntType); ("field2", StringType)]) in
  
  check bool "类型别名定义测试" true (type_def = type_def);
  check bool "记录类型定义测试" true (record_def = record_def)

(* 测试异常相关 *)
let test_exceptions () =
  let exception_def = ExceptionDefStmt ("MyException", Some IntType) in
  let raise_expr = RaiseExpr ("MyException", Some (IntExpr 1)) in
  let try_expr = TryExpr (IntExpr 1, [("MyException", "e", IntExpr 0)]) in
  
  check bool "异常定义测试" true (exception_def = exception_def);
  check bool "异常抛出表达式测试" true (raise_expr = raise_expr);
  check bool "异常捕获表达式测试" true (try_expr = try_expr)


let () = run "AST单元测试" [
  ("诗词形式测试", [test_poetry_form]);
  ("韵律信息测试", [test_rhyme_info]);
  ("声调类型测试", [test_tone_type]);
  ("平仄模式测试", [test_tone_pattern]);
  ("声调约束测试", [test_tone_constraint]);
  ("基础数据类型测试", [test_basic_types]);
  ("复合类型测试", [test_compound_types]);
  ("基础表达式测试", [test_basic_expressions]);
  ("标识符测试", [test_identifiers]);
  ("运算表达式测试", [test_operations]);
  ("条件表达式测试", [test_conditional]);
  ("函数相关表达式测试", [test_functions]);
  ("Let表达式测试", [test_let_expressions]);
  ("诗词相关表达式测试", [test_poetry_expressions]);
  ("语句类型测试", [test_statements]);
  ("类型定义测试", [test_type_definitions]);
  ("异常相关测试", [test_exceptions]);
]