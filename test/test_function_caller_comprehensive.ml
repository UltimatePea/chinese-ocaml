(** 骆言解释器函数调用引擎综合测试 - Chinese Programming Language Function Caller Comprehensive Tests *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Function_caller
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
let bool_lit b = LitExpr (BoolLit b)

(** 1. 内置函数调用测试套件 *)
let test_builtin_function_call () =
  (* 测试内置函数调用 *)
  let env = create_test_env () in
  let builtin_func = BuiltinFunctionValue (function
    | [IntValue a; IntValue b] -> IntValue (a + b)
    | _ -> raise (RuntimeError "参数类型错误")) in
  let args = [IntValue 10; IntValue 20] in
  let result = call_function builtin_func args simple_eval_expr in
  match result with
  | IntValue 30 -> ()
  | _ -> failwith "内置函数调用失败"

let test_builtin_function_string () =
  (* 测试字符串内置函数调用 *)
  let env = create_test_env () in
  let string_func = BuiltinFunctionValue (function
    | [StringValue s1; StringValue s2] -> StringValue (s1 ^ s2)
    | _ -> raise (RuntimeError "参数类型错误")) in
  let args = [StringValue "前缀"; StringValue "后缀"] in
  let result = call_function string_func args simple_eval_expr in
  match result with
  | StringValue "前缀后缀" -> ()
  | _ -> failwith "字符串内置函数调用失败"

let test_builtin_function_no_args () =
  (* 测试无参数内置函数调用 *)
  let env = create_test_env () in
  let no_arg_func = BuiltinFunctionValue (function
    | [] -> IntValue 42
    | _ -> raise (RuntimeError "此函数不需要参数")) in
  let args = [] in
  let result = call_function no_arg_func args simple_eval_expr in
  match result with
  | IntValue 42 -> ()
  | _ -> failwith "无参数内置函数调用失败"

(** 2. 用户定义函数调用测试套件 *)
let test_user_function_call () =
  (* 测试用户定义函数调用 *)
  let env = create_test_env () in
  let func_body = BinaryOpExpr (var "x", Add, var "y") in
  let user_func = FunctionValue (["x"; "y"], func_body, env) in
  let args = [IntValue 15; IntValue 25] in
  let result = call_function user_func args simple_eval_expr in
  match result with
  | IntValue 40 -> ()
  | _ -> failwith "用户定义函数调用失败"

let test_user_function_single_param () =
  (* 测试单参数用户函数调用 *)
  let env = create_test_env () in
  let func_body = BinaryOpExpr (var "n", Mul, int_lit 2) in
  let user_func = FunctionValue (["n"], func_body, env) in
  let args = [IntValue 7] in
  let result = call_function user_func args simple_eval_expr in
  match result with  
  | IntValue 14 -> ()
  | _ -> failwith "单参数用户函数调用失败"

let test_user_function_complex_body () =
  (* 测试复杂函数体的用户函数调用 *)
  let env = create_test_env () in
  let func_body = CondExpr (
    BinaryOpExpr (var "x", Gt, int_lit 0),
    var "x",
    BinaryOpExpr (int_lit 0, Sub, var "x")
  ) in
  let user_func = FunctionValue (["x"], func_body, env) in
  
  (* 测试正数 *)
  let result1 = call_function user_func [IntValue 5] simple_eval_expr in
  (match result1 with
   | IntValue 5 -> ()
   | _ -> failwith "复杂函数体正数测试失败");
  
  (* 测试负数 *)
  let result2 = call_function user_func [IntValue (-3)] simple_eval_expr in
  (match result2 with
   | IntValue 3 -> ()
   | _ -> failwith "复杂函数体负数测试失败")

(** 3. 函数参数数量匹配测试套件 *)
let test_parameter_count_match () =
  (* 测试参数数量完全匹配 *)
  let env = create_test_env () in
  let func_body = BinaryOpExpr (var "a", Mul, var "b") in
  let user_func = FunctionValue (["a"; "b"], func_body, env) in
  let args = [IntValue 6; IntValue 7] in
  let result = call_function user_func args simple_eval_expr in
  match result with
  | IntValue 42 -> ()
  | _ -> failwith "参数数量匹配测试失败"

let test_parameter_count_mismatch_error () =
  (* 测试参数数量不匹配错误（在错误恢复关闭时） *)
  let env = create_test_env () in
  let func_body = var "x" in
  let user_func = FunctionValue (["x"], func_body, env) in
  let args = [IntValue 1; IntValue 2] in  (* 参数过多 *)
  
  (* 确保错误恢复关闭 *)
  Yyocamlc_lib.Error_recovery.disable_recovery ();
  
  try
    let _ = call_function user_func args simple_eval_expr in
    failwith "参数数量不匹配应该产生错误"
  with
  | RuntimeError _ -> ()  (* 预期错误 *)
  | _ -> failwith "应该产生运行时错误"

(** 4. 函数参数错误恢复测试套件 *)
let test_parameter_shortage_recovery () =
  (* 测试参数不足时的错误恢复 *)
  let env = create_test_env () in
  let func_body = BinaryOpExpr (var "a", Add, var "b") in
  let user_func = FunctionValue (["a"; "b"], func_body, env) in
  let args = [IntValue 10] in  (* 缺少一个参数 *)
  
  (* 启用错误恢复 *)
  Yyocamlc_lib.Error_recovery.enable_recovery ();
  
  let result = call_function user_func args simple_eval_expr in
  match result with
  | IntValue 10 -> ()  (* 10 + 0(默认值) = 10 *)
  | _ -> failwith "参数不足错误恢复失败"

let test_parameter_excess_recovery () =
  (* 测试参数过多时的错误恢复 *)
  let env = create_test_env () in
  let func_body = var "x" in
  let user_func = FunctionValue (["x"], func_body, env) in
  let args = [IntValue 42; IntValue 100; IntValue 200] in  (* 参数过多 *)
  
  (* 启用错误恢复 *)
  Yyocamlc_lib.Error_recovery.enable_recovery ();
  
  let result = call_function user_func args simple_eval_expr in
  match result with
  | IntValue 42 -> ()  (* 只使用第一个参数 *)
  | _ -> failwith "参数过多错误恢复失败"

(** 5. 闭包环境测试套件 *)
let test_closure_environment () =
  (* 测试闭包环境捕获 *)
  let closure_env = bind_var (create_test_env ()) "外部变量" (IntValue 100) in
  let func_body = BinaryOpExpr (var "外部变量", Add, var "参数") in
  let closure_func = FunctionValue (["参数"], func_body, closure_env) in
  let args = [IntValue 50] in
  let result = call_function closure_func args simple_eval_expr in
  match result with
  | IntValue 150 -> ()
  | _ -> failwith "闭包环境测试失败"

let test_nested_closure () =
  (* 测试嵌套闭包 *)
  let outer_env = bind_var (create_test_env ()) "外层值" (IntValue 10) in
  let inner_env = bind_var outer_env "内层值" (IntValue 20) in
  let func_body = BinaryOpExpr (
    BinaryOpExpr (var "外层值", Add, var "内层值"),
    Add, var "参数"
  ) in
  let nested_func = FunctionValue (["参数"], func_body, inner_env) in
  let args = [IntValue 5] in
  let result = call_function nested_func args simple_eval_expr in
  match result with
  | IntValue 35 -> ()  (* 10 + 20 + 5 = 35 *)
  | _ -> failwith "嵌套闭包测试失败"

(** 6. 标签函数调用测试套件 *)
let test_labeled_function_call () =
  (* 测试标签函数调用 *)
  let env = create_test_env () in
  let label_params = [
    { label_name = "长度"; param_name = "长度"; param_type = None; is_optional = false; default_value = None };
    { label_name = "宽度"; param_name = "宽度"; param_type = None; is_optional = false; default_value = None };
  ] in
  let func_body = BinaryOpExpr (var "长度", Mul, var "宽度") in
  let labeled_func = LabeledFunctionValue (label_params, func_body, env) in
  let label_args = [
    { arg_label = "长度"; arg_value = int_lit 8 };
    { arg_label = "宽度"; arg_value = int_lit 6 };
  ] in
  let result = call_labeled_function labeled_func label_args env simple_eval_expr in
  match result with
  | IntValue 48 -> ()
  | _ -> failwith "标签函数调用失败"

let test_labeled_function_optional_param () =
  (* 测试带可选参数的标签函数调用 *)
  let env = create_test_env () in
  let label_params = [
    { label_name = "基础值"; param_name = "基础值"; param_type = None; is_optional = false; default_value = None };
    { label_name = "增量"; param_name = "增量"; param_type = None; is_optional = true; default_value = Some (int_lit 1) };
  ] in
  let func_body = BinaryOpExpr (var "基础值", Add, var "增量") in
  let labeled_func = LabeledFunctionValue (label_params, func_body, env) in
  let label_args = [
    { arg_label = "基础值"; arg_value = int_lit 10 };
    (* 省略可选参数 *)
  ] in
  let result = call_labeled_function labeled_func label_args env simple_eval_expr in
  match result with
  | IntValue 11 -> ()  (* 10 + 1(默认值) = 11 *)
  | _ -> failwith "带可选参数的标签函数调用失败"

let test_labeled_function_missing_required () =
  (* 测试标签函数缺少必需参数的错误 *)
  let env = create_test_env () in
  let label_params = [
    { label_name = "必需参数"; param_name = "必需参数"; param_type = None; is_optional = false; default_value = None };
  ] in
  let func_body = var "必需参数" in
  let labeled_func = LabeledFunctionValue (label_params, func_body, env) in
  let label_args = [] in  (* 不提供任何参数 *)
  
  try
    let _ = call_labeled_function labeled_func label_args env simple_eval_expr in
    failwith "缺少必需参数应该产生错误"
  with
  | RuntimeError _ -> ()  (* 预期错误 *)
  | _ -> failwith "应该产生运行时错误"

(** 7. 递归函数处理测试套件 *)
let test_recursive_function_handling () =
  (* 测试递归函数处理 *)
  let env = create_test_env () in
  let func_expr = FunExpr (["n"], 
    CondExpr (BinaryOpExpr (var "n", Le, int_lit 1),
            int_lit 1,
            BinaryOpExpr (var "n", Mul, 
                     FunCallExpr (var "阶乘", [BinaryOpExpr (var "n", Sub, int_lit 1)])))) in
  let new_env, func_val = handle_recursive_let env "阶乘" func_expr in
  
  (* 验证函数已正确绑定 *)
  match lookup_var new_env "阶乘" with
  | FunctionValue _ -> ()
  | _ -> failwith "递归函数处理失败"

let test_recursive_function_with_type () =
  (* 测试带类型的递归函数处理 *)
  let env = create_test_env () in
  let param_list = [("x", Some (BaseTypeExpr IntType))] in
  let func_expr = FunExprWithType (param_list, Some (BaseTypeExpr IntType), var "x") in
  let new_env, func_val = handle_recursive_let env "身份函数" func_expr in
  
  (* 验证函数已正确绑定 *)
  match lookup_var new_env "身份函数" with
  | FunctionValue _ -> ()
  | _ -> failwith "带类型递归函数处理失败"

let test_recursive_labeled_function () =
  (* 测试递归标签函数处理 *)
  let env = create_test_env () in
  let label_params = [
    { label_name = "值"; param_name = "值"; param_type = None; is_optional = false; default_value = None };
  ] in
  let func_expr = LabeledFunExpr (label_params, var "值") in
  let new_env, func_val = handle_recursive_let env "标签函数" func_expr in
  
  (* 验证函数已正确绑定 *)
  match lookup_var new_env "标签函数" with
  | LabeledFunctionValue _ -> ()
  | _ -> failwith "递归标签函数处理失败"

(** 8. 错误处理测试套件 *)
let test_non_function_call_error () =
  (* 测试调用非函数值的错误 *)
  let non_func = IntValue 42 in
  let args = [IntValue 1] in
  
  try
    let _ = call_function non_func args simple_eval_expr in
    failwith "调用非函数值应该产生错误"
  with
  | RuntimeError _ -> ()  (* 预期错误 *)
  | _ -> failwith "应该产生运行时错误"

let test_labeled_function_wrong_type_error () =
  (* 测试标签函数类型错误 *)
  let non_labeled_func = IntValue 42 in
  let label_args = [] in
  let env = create_test_env () in
  
  try
    let _ = call_labeled_function non_labeled_func label_args env simple_eval_expr in
    failwith "调用非标签函数应该产生错误"
  with
  | RuntimeError _ -> ()  (* 预期错误 *)
  | _ -> failwith "应该产生运行时错误"

let test_recursive_non_function_error () =
  (* 测试递归let非函数表达式错误 *)
  let env = create_test_env () in
  let non_func_expr = int_lit 42 in  (* 不是函数表达式 *)
  
  try
    let _ = handle_recursive_let env "非函数" non_func_expr in
    failwith "递归let非函数表达式应该产生错误"
  with
  | RuntimeError _ -> ()  (* 预期错误 *)
  | _ -> failwith "应该产生运行时错误"

(** 9. 函数参数求值测试套件 *)
let test_function_argument_evaluation () =
  (* 测试函数参数在调用时正确求值 *)
  let env = bind_var (create_test_env ()) "变量" (IntValue 5) in
  let func_body = BinaryOpExpr (var "x", Mul, int_lit 2) in
  let user_func = FunctionValue (["x"], func_body, env) in
  
  (* 参数是表达式，需要求值 *)
  let arg_expr = BinaryOpExpr (var "变量", Add, int_lit 3) in
  let arg_value = simple_eval_expr env arg_expr in
  let args = [arg_value] in
  
  let result = call_function user_func args simple_eval_expr in
  match result with
  | IntValue 16 -> ()  (* (5 + 3) * 2 = 16 *)
  | _ -> failwith "函数参数求值测试失败"

(** 测试套件汇总 *)
let function_caller_tests = [
  (* 内置函数调用测试 *)
  ("内置函数调用_加法", `Quick, test_builtin_function_call);
  ("内置函数调用_字符串", `Quick, test_builtin_function_string);
  ("内置函数调用_无参数", `Quick, test_builtin_function_no_args);
  
  (* 用户定义函数调用测试 *)
  ("用户函数调用_双参数", `Quick, test_user_function_call);
  ("用户函数调用_单参数", `Quick, test_user_function_single_param);
  ("用户函数调用_复杂函数体", `Quick, test_user_function_complex_body);
  
  (* 参数数量匹配测试 *)
  ("参数数量匹配_正确", `Quick, test_parameter_count_match);
  ("参数数量匹配_错误处理", `Quick, test_parameter_count_mismatch_error);
  
  (* 参数错误恢复测试 *)
  ("参数错误恢复_参数不足", `Quick, test_parameter_shortage_recovery);
  ("参数错误恢复_参数过多", `Quick, test_parameter_excess_recovery);
  
  (* 闭包环境测试 *)
  ("闭包环境_基础", `Quick, test_closure_environment);
  ("闭包环境_嵌套", `Quick, test_nested_closure);
  
  (* 标签函数调用测试 *)
  ("标签函数调用_基础", `Quick, test_labeled_function_call);
  ("标签函数调用_可选参数", `Quick, test_labeled_function_optional_param);
  ("标签函数调用_缺少必需参数", `Quick, test_labeled_function_missing_required);
  
  (* 递归函数处理测试 *)
  ("递归函数处理_基础", `Quick, test_recursive_function_handling);
  ("递归函数处理_带类型", `Quick, test_recursive_function_with_type);
  ("递归函数处理_标签函数", `Quick, test_recursive_labeled_function);
  
  (* 错误处理测试 *)
  ("错误处理_非函数调用", `Quick, test_non_function_call_error);
  ("错误处理_标签函数类型错误", `Quick, test_labeled_function_wrong_type_error);
  ("错误处理_递归非函数", `Quick, test_recursive_non_function_error);
  
  (* 函数参数求值测试 *)
  ("函数参数求值_表达式参数", `Quick, test_function_argument_evaluation);
]

(** 主测试运行函数 *)
let () = run "骆言函数调用引擎综合测试" [ ("函数调用引擎", function_caller_tests) ]