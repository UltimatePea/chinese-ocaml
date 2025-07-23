(** 骆言解释器模式匹配引擎综合测试 - Chinese Programming Language Pattern Matcher Comprehensive Tests *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Pattern_matcher
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Interpreter_utils
open Yyocamlc_lib.Expression_evaluator

(** 测试辅助函数：创建基础环境 *)
let create_test_env () =
  let builtin_env = Yyocamlc_lib.Builtin_functions.builtin_functions in
  builtin_env @ []

(** 测试辅助函数：创建简单的求值函数 *)
let simple_eval_expr env expr = eval_expr env expr

(** 测试辅助函数：创建变量表达式 *)
let var name = VarExpr name

(** 测试辅助函数：创建整数字面量 *)
let int_lit n = LitExpr (IntLit n)

(** 测试辅助函数：创建字符串字面量 *)
let str_lit s = LitExpr (StringLit s)

(** 测试辅助函数：创建布尔字面量 *)
let _bool_lit b = LitExpr (BoolLit b)

(** 1. 基础模式匹配测试套件 *)
let test_wildcard_pattern () =
  (* 测试通配符模式匹配 *)
  let env = create_test_env () in
  let pattern = WildcardPattern in
  let value = IntValue 42 in
  let result = match_pattern pattern value env in
  match result with
  | Some _result_env -> ()
  | None -> failwith "通配符模式应该匹配任何值"

let test_variable_pattern () =
  (* 测试变量模式匹配 *)
  let env = create_test_env () in
  let pattern = VarPattern "绑定变量" in
  let value = StringValue "测试值" in
  let result = match_pattern pattern value env in
  match result with
  | Some result_env -> 
      (* 验证变量已正确绑定 *)
      (match lookup_var result_env "绑定变量" with
       | StringValue "测试值" -> ()
       | _ -> failwith "变量模式绑定失败")
  | None -> failwith "变量模式应该总是成功匹配"

let test_integer_literal_pattern () =
  (* 测试整数字面量模式匹配 *)
  let env = create_test_env () in
  let pattern = LitPattern (IntLit 100) in
  let value = IntValue 100 in
  let result = match_pattern pattern value env in
  match result with
  | Some _ -> ()
  | None -> failwith "整数字面量模式匹配失败"

let test_integer_literal_no_match () =
  (* 测试整数字面量不匹配 *)
  let env = create_test_env () in
  let pattern = LitPattern (IntLit 100) in
  let value = IntValue 200 in
  let result = match_pattern pattern value env in
  match result with
  | Some _ -> failwith "不同的整数值不应该匹配"
  | None -> ()

let test_string_literal_pattern () =
  (* 测试字符串字面量模式匹配 *)
  let env = create_test_env () in
  let pattern = LitPattern (StringLit "中文字符串") in
  let value = StringValue "中文字符串" in
  let result = match_pattern pattern value env in
  match result with
  | Some _ -> ()
  | None -> failwith "字符串字面量模式匹配失败"

let test_boolean_literal_pattern () =
  (* 测试布尔字面量模式匹配 *)
  let env = create_test_env () in
  let pattern = LitPattern (BoolLit true) in
  let value = BoolValue true in
  let result = match_pattern pattern value env in
  match result with
  | Some _ -> ()
  | None -> failwith "布尔字面量模式匹配失败"

let test_unit_literal_pattern () =
  (* 测试单元字面量模式匹配 *)
  let env = create_test_env () in
  let pattern = LitPattern UnitLit in
  let value = UnitValue in
  let result = match_pattern pattern value env in
  match result with
  | Some _ -> ()
  | None -> failwith "单元字面量模式匹配失败"

(** 2. 列表模式匹配测试套件 *)
let test_empty_list_pattern () =
  (* 测试空列表模式匹配 *)
  let env = create_test_env () in
  let pattern = EmptyListPattern in
  let value = ListValue [] in
  let result = match_pattern pattern value env in
  match result with
  | Some _ -> ()
  | None -> failwith "空列表模式匹配失败"

let test_empty_list_no_match () =
  (* 测试空列表不匹配非空列表 *)
  let env = create_test_env () in
  let pattern = EmptyListPattern in
  let value = ListValue [IntValue 1] in
  let result = match_pattern pattern value env in
  match result with
  | Some _ -> failwith "空列表模式不应该匹配非空列表"
  | None -> ()

let test_cons_pattern_simple () =
  (* 测试简单的cons模式匹配 *)
  let env = create_test_env () in
  let pattern = ConsPattern (VarPattern "头部", VarPattern "尾部") in
  let value = ListValue [IntValue 1; IntValue 2; IntValue 3] in
  let result = match_pattern pattern value env in
  match result with
  | Some result_env -> 
      (* 验证头部和尾部绑定 *)
      let head_binding = lookup_var result_env "头部" in
      let tail_binding = lookup_var result_env "尾部" in
      (match (head_binding, tail_binding) with
       | (IntValue 1, ListValue [IntValue 2; IntValue 3]) -> ()
       | _ -> failwith "cons模式头尾绑定错误")
  | None -> failwith "cons模式匹配失败"

let test_cons_pattern_nested () =
  (* 测试嵌套的cons模式匹配 *)
  let env = create_test_env () in
  let pattern = ConsPattern (VarPattern "第一", ConsPattern (VarPattern "第二", EmptyListPattern)) in
  let value = ListValue [StringValue "第一个"; StringValue "第二个"] in
  let result = match_pattern pattern value env in
  match result with
  | Some result_env -> 
      (* 验证嵌套绑定 *)
      let first_binding = lookup_var result_env "第一" in
      let second_binding = lookup_var result_env "第二" in
      (match (first_binding, second_binding) with
       | (StringValue "第一个", StringValue "第二个") -> ()
       | _ -> failwith "嵌套cons模式绑定错误")
  | None -> failwith "嵌套cons模式匹配失败"

(** 3. 构造器模式匹配测试套件 *)
let test_constructor_pattern_no_args () =
  (* 测试无参数构造器模式匹配 *)
  let env = create_test_env () in
  let pattern = ConstructorPattern ("成功", []) in
  let value = ConstructorValue ("成功", []) in
  let result = match_pattern pattern value env in
  match result with
  | Some _ -> ()
  | None -> failwith "无参数构造器模式匹配失败"

let test_constructor_pattern_with_args () =
  (* 测试带参数构造器模式匹配 *)
  let env = create_test_env () in
  let pattern = ConstructorPattern ("失败", [VarPattern "错误信息"]) in
  let value = ConstructorValue ("失败", [StringValue "文件不存在"]) in
  let result = match_pattern pattern value env in
  match result with
  | Some result_env -> 
      (* 验证参数绑定 *)
      (match lookup_var result_env "错误信息" with
       | StringValue "文件不存在" -> ()
       | _ -> failwith "构造器参数绑定错误")
  | None -> failwith "带参数构造器模式匹配失败"

let test_constructor_pattern_multiple_args () =
  (* 测试多参数构造器模式匹配 *)
  let env = create_test_env () in
  let pattern = ConstructorPattern ("坐标", [VarPattern "x"; VarPattern "y"]) in
  let value = ConstructorValue ("坐标", [IntValue 10; IntValue 20]) in
  let result = match_pattern pattern value env in
  match result with
  | Some result_env -> 
      (* 验证多个参数绑定 *)
      let x_binding = lookup_var result_env "x" in
      let y_binding = lookup_var result_env "y" in
      (match (x_binding, y_binding) with
       | (IntValue 10, IntValue 20) -> ()
       | _ -> failwith "多参数构造器绑定错误")
  | None -> failwith "多参数构造器模式匹配失败"

let test_constructor_name_mismatch () =
  (* 测试构造器名称不匹配 *)
  let env = create_test_env () in
  let pattern = ConstructorPattern ("成功", []) in
  let value = ConstructorValue ("失败", []) in
  let result = match_pattern pattern value env in
  match result with
  | Some _ -> failwith "不同名称的构造器不应该匹配"
  | None -> ()

(** 4. 异常模式匹配测试套件 *)
let test_exception_pattern_no_payload () =
  (* 测试无载荷异常模式匹配 *)
  let env = create_test_env () in
  let pattern = ConstructorPattern ("自定义异常", []) in
  let value = ExceptionValue ("自定义异常", None) in
  let result = match_pattern pattern value env in
  match result with
  | Some _ -> ()
  | None -> failwith "无载荷异常模式匹配失败"

let test_exception_pattern_with_payload () =
  (* 测试带载荷异常模式匹配 *)
  let env = create_test_env () in
  let pattern = ConstructorPattern ("运行时错误", [VarPattern "错误详情"]) in
  let value = ExceptionValue ("运行时错误", Some (StringValue "除零错误")) in
  let result = match_pattern pattern value env in
  match result with
  | Some result_env -> 
      (* 验证载荷绑定 *)
      (match lookup_var result_env "错误详情" with
       | StringValue "除零错误" -> ()
       | _ -> failwith "异常载荷绑定错误")
  | None -> failwith "带载荷异常模式匹配失败"

(** 5. 多态变体模式匹配测试套件 *)
let test_polymorphic_variant_no_value () =
  (* 测试无值多态变体模式匹配 *)
  let env = create_test_env () in
  let pattern = PolymorphicVariantPattern ("开始", None) in
  let value = PolymorphicVariantValue ("开始", None) in
  let result = match_pattern pattern value env in
  match result with
  | Some _ -> ()
  | None -> failwith "无值多态变体模式匹配失败"

let test_polymorphic_variant_with_value () =
  (* 测试带值多态变体模式匹配 *)
  let env = create_test_env () in
  let pattern = PolymorphicVariantPattern ("数据", Some (VarPattern "内容")) in
  let value = PolymorphicVariantValue ("数据", Some (IntValue 42)) in
  let result = match_pattern pattern value env in
  match result with
  | Some result_env -> 
      (* 验证值绑定 *)
      (match lookup_var result_env "内容" with
       | IntValue 42 -> ()
       | _ -> failwith "多态变体值绑定错误")
  | None -> failwith "带值多态变体模式匹配失败"

let test_polymorphic_variant_tag_mismatch () =
  (* 测试多态变体标签不匹配 *)
  let env = create_test_env () in
  let pattern = PolymorphicVariantPattern ("开始", None) in
  let value = PolymorphicVariantValue ("结束", None) in
  let result = match_pattern pattern value env in
  match result with
  | Some _ -> failwith "不同标签的多态变体不应该匹配"
  | None -> ()

(** 6. Guard条件测试套件 *)
let test_guard_evaluation_true () =
  (* 测试guard条件为真 *)
  let env = bind_var (create_test_env ()) "测试值" (IntValue 10) in
  let guard_expr = BinaryOpExpr (var "测试值", Gt, int_lit 5) in
  let branches = [
    { pattern = VarPattern "x"; guard = Some guard_expr; expr = str_lit "guard通过" };
    { pattern = VarPattern "x"; guard = None; expr = str_lit "无guard" };
  ] in
  let value = IntValue 10 in
  let result = execute_match env value branches simple_eval_expr in
  match result with
  | StringValue "guard通过" -> ()
  | _ -> failwith "guard条件应该为真，应该执行第一个分支"

let test_guard_evaluation_false () =
  (* 测试guard条件为假 *)
  let env = bind_var (create_test_env ()) "测试值" (IntValue 3) in
  let guard_expr = BinaryOpExpr (var "测试值", Gt, int_lit 5) in
  let branches = [
    { pattern = VarPattern "x"; guard = Some guard_expr; expr = str_lit "guard通过" };
    { pattern = VarPattern "x"; guard = None; expr = str_lit "无guard" };
  ] in
  let value = IntValue 3 in
  let result = execute_match env value branches simple_eval_expr in
  match result with
  | StringValue "无guard" -> ()
  | _ -> failwith "guard条件应该为假，应该执行第二个分支"

let test_guard_non_boolean_error () =
  (* 测试guard条件非布尔值错误 *)
  let env = create_test_env () in
  let guard_expr = int_lit 42 in  (* 返回整数而不是布尔值 *)
  let branches = [
    { pattern = VarPattern "x"; guard = Some guard_expr; expr = str_lit "不应该到达" };
  ] in
  let value = IntValue 10 in
  
  try
    let _ = execute_match env value branches simple_eval_expr in
    failwith "非布尔guard条件应该产生错误"
  with
  | RuntimeError _ -> ()  (* 预期错误 *)
  | _ -> failwith "应该产生运行时错误"

(** 7. 单个分支执行测试套件 *)
let test_single_branch_execution () =
  (* 测试单个分支执行 *)
  let env = create_test_env () in
  let branches = [{
    pattern = VarPattern "匹配值";
    guard = None;
    expr = BinaryOpExpr (var "匹配值", Add, int_lit 10);
  }] in
  let value = IntValue 5 in
  let result = execute_match env value branches simple_eval_expr in
  match result with
  | IntValue 15 -> ()
  | _ -> failwith "单个分支执行失败"

let test_single_branch_with_guard () =
  (* 测试带guard的单个分支执行 *)
  let env = create_test_env () in
  let branches = [{
    pattern = VarPattern "数值";
    guard = Some (BinaryOpExpr (var "数值", Gt, int_lit 0));
    expr = str_lit "正数";
  }] in
  let value = IntValue 5 in
  let result = execute_match env value branches simple_eval_expr in
  match result with
  | StringValue "正数" -> ()
  | _ -> failwith "带guard的分支执行失败"

let test_single_branch_guard_fail () =
  (* 测试guard失败的分支会跳到下一个分支 *)
  let env = create_test_env () in  
  let branches = [
    { pattern = VarPattern "数值"; guard = Some (BinaryOpExpr (var "数值", Gt, int_lit 10)); expr = str_lit "大数" };
    { pattern = VarPattern "数值"; guard = None; expr = str_lit "其他数" };
  ] in
  let value = IntValue 5 in
  let result = execute_match env value branches simple_eval_expr in
  match result with
  | StringValue "其他数" -> ()  (* guard失败，执行第二个分支 *)
  | _ -> failwith "guard失败的分支应该跳到下一个分支"

(** 8. 完整匹配执行测试套件 *)
let test_match_execution_first_branch () =
  (* 测试匹配执行选择第一个分支 *)
  let env = create_test_env () in
  let branches = [
    { pattern = LitPattern (IntLit 5); guard = None; expr = str_lit "匹配5" };
    { pattern = LitPattern (IntLit 10); guard = None; expr = str_lit "匹配10" };
  ] in
  let value = IntValue 5 in
  let result = execute_match env value branches simple_eval_expr in
  match result with
  | StringValue "匹配5" -> ()
  | _ -> failwith "应该匹配第一个分支"

let test_match_execution_second_branch () =
  (* 测试匹配执行选择第二个分支 *)
  let env = create_test_env () in
  let branches = [
    { pattern = LitPattern (IntLit 5); guard = None; expr = str_lit "匹配5" };
    { pattern = LitPattern (IntLit 10); guard = None; expr = str_lit "匹配10" };
  ] in
  let value = IntValue 10 in
  let result = execute_match env value branches simple_eval_expr in
  match result with
  | StringValue "匹配10" -> ()
  | _ -> failwith "应该匹配第二个分支"

let test_match_execution_no_match () =
  (* 测试没有匹配分支的错误 *)
  let env = create_test_env () in
  let branches = [
    { pattern = LitPattern (IntLit 5); guard = None; expr = str_lit "匹配5" };
    { pattern = LitPattern (IntLit 10); guard = None; expr = str_lit "匹配10" };
  ] in
  let value = IntValue 15 in
  
  try
    let _ = execute_match env value branches simple_eval_expr in
    failwith "没有匹配分支应该产生错误"
  with
  | RuntimeError _ -> ()  (* 预期错误 *)
  | _ -> failwith "应该产生运行时错误"

(** 9. 异常匹配执行测试套件 *)
let test_exception_match_execution () =
  (* 测试异常匹配执行 *)
  let env = create_test_env () in
  let catch_branches = [
    { pattern = ConstructorPattern ("类型错误", []); guard = None; expr = str_lit "处理类型错误" };
    { pattern = ConstructorPattern ("运行时错误", [VarPattern "信息"]); guard = None; 
      expr = BinaryOpExpr (str_lit "运行时错误: ", Add, var "信息") };
  ] in
  let exc_value = ExceptionValue ("运行时错误", Some (StringValue "除零")) in
  let result = execute_exception_match env exc_value catch_branches simple_eval_expr in
  match result with
  | StringValue "运行时错误: 除零" -> ()
  | _ -> failwith "异常匹配执行失败"

let test_exception_match_no_handler () =
  (* 测试没有匹配处理器的异常 *)
  let env = create_test_env () in
  let catch_branches = [
    { pattern = ConstructorPattern ("类型错误", []); guard = None; expr = str_lit "处理类型错误" };
  ] in
  let exc_value = ExceptionValue ("网络错误", None) in
  
  try
    let _ = execute_exception_match env exc_value catch_branches simple_eval_expr in
    failwith "没有匹配处理器应该重新抛出异常"
  with
  | ExceptionRaised _ -> ()  (* 预期异常 *)
  | _ -> failwith "应该重新抛出异常"

(** 10. 构造器注册测试套件 *)
let test_register_algebraic_constructors () =
  (* 测试代数类型构造器注册 *)
  let env = create_test_env () in
  let constructors = [("成功", None); ("失败", Some (BaseTypeExpr StringType))] in
  let type_def = AlgebraicType constructors in
  let new_env = Yyocamlc_lib.Pattern_matcher.register_constructors env type_def in
  
  (* 验证构造器已注册 *)
  match (lookup_var new_env "成功", lookup_var new_env "失败") with
  | (BuiltinFunctionValue _, BuiltinFunctionValue _) -> ()
  | _ -> failwith "代数类型构造器注册失败"

let test_register_polymorphic_variant_constructors () =
  (* 测试多态变体构造器注册 *)
  let env = create_test_env () in
  
  (* 首先测试基本的bind_var是否工作 *)
  let test_env = bind_var env "测试变量" (IntValue 42) in
  (match lookup_var test_env "测试变量" with
  | IntValue 42 -> ()
  | _ -> failwith "bind_var基本功能失败");
  
  let variants = [("开始", None); ("数据", Some (BaseTypeExpr IntType))] in
  let type_def = PolymorphicVariantTypeDef variants in
  
  (* 手动实现多态变体注册来测试 *)
  let manual_env = 
    let tag_func1 = BuiltinFunctionValue (fun args ->
      match args with
      | [] -> PolymorphicVariantValue ("开始", None)
      | [arg] -> PolymorphicVariantValue ("开始", Some arg)
      | _ -> raise (RuntimeError "参数错误")) in
    let tag_func2 = BuiltinFunctionValue (fun args ->
      match args with
      | [] -> PolymorphicVariantValue ("数据", None) 
      | [arg] -> PolymorphicVariantValue ("数据", Some arg)
      | _ -> raise (RuntimeError "参数错误")) in
    let env1 = bind_var env "开始" tag_func1 in
    bind_var env1 "数据" tag_func2
  in
  
  (* 验证手动注册是否工作 *)
  (match lookup_var manual_env "开始" with
  | BuiltinFunctionValue _ -> ()
  | _ -> failwith "手动多态变体注册失败");
  
  (* 现在测试register_constructors函数 - 使用Pattern_matcher的版本 *)
  let auto_env = Yyocamlc_lib.Pattern_matcher.register_constructors env type_def in
  let env_size_before = List.length env in
  let env_size_after = List.length auto_env in
  
  if env_size_after <= env_size_before then
    failwith ("register_constructors未增加环境大小: 之前=" ^ string_of_int env_size_before ^ " 之后=" ^ string_of_int env_size_after);
  
  (* 验证变体标签已注册 *)
  match (lookup_var auto_env "开始", lookup_var auto_env "数据") with
  | (BuiltinFunctionValue _, BuiltinFunctionValue _) -> ()
  | _ -> failwith "register_constructors多态变体注册失败"

(** 测试套件汇总 *)
let pattern_matcher_tests = [
  (* 基础模式匹配测试 *)
  ("基础模式_通配符", `Quick, test_wildcard_pattern);
  ("基础模式_变量", `Quick, test_variable_pattern);
  ("基础模式_整数字面量匹配", `Quick, test_integer_literal_pattern);
  ("基础模式_整数字面量不匹配", `Quick, test_integer_literal_no_match);
  ("基础模式_字符串字面量", `Quick, test_string_literal_pattern);
  ("基础模式_布尔字面量", `Quick, test_boolean_literal_pattern);
  ("基础模式_单元字面量", `Quick, test_unit_literal_pattern);
  
  (* 列表模式匹配测试 *)
  ("列表模式_空列表", `Quick, test_empty_list_pattern);
  ("列表模式_空列表不匹配", `Quick, test_empty_list_no_match);
  ("列表模式_简单cons", `Quick, test_cons_pattern_simple);
  ("列表模式_嵌套cons", `Quick, test_cons_pattern_nested);
  
  (* 构造器模式匹配测试 *)
  ("构造器模式_无参数", `Quick, test_constructor_pattern_no_args);
  ("构造器模式_带参数", `Quick, test_constructor_pattern_with_args);
  ("构造器模式_多参数", `Quick, test_constructor_pattern_multiple_args);
  ("构造器模式_名称不匹配", `Quick, test_constructor_name_mismatch);
  
  (* 异常模式匹配测试 *)
  ("异常模式_无载荷", `Quick, test_exception_pattern_no_payload);
  ("异常模式_带载荷", `Quick, test_exception_pattern_with_payload);
  
  (* 多态变体模式匹配测试 *)
  ("多态变体_无值", `Quick, test_polymorphic_variant_no_value);
  ("多态变体_带值", `Quick, test_polymorphic_variant_with_value);
  ("多态变体_标签不匹配", `Quick, test_polymorphic_variant_tag_mismatch);
  
  (* Guard条件测试 *)
  ("Guard条件_为真", `Quick, test_guard_evaluation_true);
  ("Guard条件_为假", `Quick, test_guard_evaluation_false);
  ("Guard条件_非布尔错误", `Quick, test_guard_non_boolean_error);
  
  (* 单个分支执行测试 *)
  ("单个分支_基础执行", `Quick, test_single_branch_execution);
  ("单个分支_带Guard", `Quick, test_single_branch_with_guard);
  ("单个分支_Guard失败", `Quick, test_single_branch_guard_fail);
  
  (* 完整匹配执行测试 *)
  ("匹配执行_第一分支", `Quick, test_match_execution_first_branch);
  ("匹配执行_第二分支", `Quick, test_match_execution_second_branch);
  ("匹配执行_无匹配", `Quick, test_match_execution_no_match);
  
  (* 异常匹配执行测试 *)
  ("异常匹配_正常处理", `Quick, test_exception_match_execution);
  ("异常匹配_无处理器", `Quick, test_exception_match_no_handler);
  
  (* 构造器注册测试 *)
  ("构造器注册_代数类型", `Quick, test_register_algebraic_constructors);
  ("构造器注册_多态变体", `Quick, test_register_polymorphic_variant_constructors);
]

(** 主测试运行函数 *)
let () = run "骆言模式匹配引擎综合测试" [ ("模式匹配引擎", pattern_matcher_tests) ]