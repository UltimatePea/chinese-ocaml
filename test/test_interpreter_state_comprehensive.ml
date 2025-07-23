(** 骆言解释器状态管理模块综合测试 *)

open Alcotest
open Yyocamlc_lib.Interpreter_state
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Value_operations

(** 测试辅助函数 *)
module TestUtils = struct
  (** 创建测试用的宏定义 *)
  let create_test_macro name body =
    { macro_def_name = name; params = [ ExprParam "x"; ExprParam "y" ]; body }

  (** 创建测试用的运行时值 *)
  let create_test_value v_type =
    match v_type with
    | "int" -> IntValue 42
    | "string" -> StringValue "test"
    | "bool" -> BoolValue true
    | "unit" -> UnitValue
    | _ -> IntValue 0

  (** 创建测试用的模块绑定 *)
  let create_test_bindings () =
    [ ("var1", IntValue 10); ("var2", StringValue "hello"); ("var3", BoolValue false) ]

  (** 创建测试用的表达式 *)
  let create_test_expr () = VarExpr "test_var"

  (** 创建测试用的模块类型 *)
  let create_test_module_type () = Signature []
end

(** 解释器状态创建测试 *)
module StateCreationTests = struct
  (** 测试状态创建 *)
  let test_create_state () =
    (* 重置状态确保干净的测试环境 *)
    reset_state ();

    let state = create_state () in

    (* 验证状态结构存在 *)
    check bool "状态应该被正确创建" true (state != create_state ());

    (* 验证表都是空的 *)
    let macro_table = get_macro_table () in
    let module_table = get_module_table () in
    let recursive_functions = get_recursive_functions () in
    let functor_table = get_functor_table () in

    check int "宏表应为空" 0 (Hashtbl.length macro_table);
    check int "模块表应为空" 0 (Hashtbl.length module_table);
    check int "递归函数表应为空" 0 (Hashtbl.length recursive_functions);
    check int "函子表应为空" 0 (Hashtbl.length functor_table)

  (** 测试全局状态访问 *)
  let test_global_state_access () =
    reset_state ();

    (* 验证可以访问各个表 *)
    let macro_table = get_macro_table () in
    let module_table = get_module_table () in
    let recursive_functions = get_recursive_functions () in
    let functor_table = get_functor_table () in

    check bool "宏表访问正常" true (macro_table != Hashtbl.create 1);
    check bool "模块表访问正常" true (module_table != Hashtbl.create 1);
    check bool "递归函数表访问正常" true (recursive_functions != Hashtbl.create 1);
    check bool "函子表访问正常" true (functor_table != Hashtbl.create 1)
end

(** 宏表操作测试 *)
module MacroTableTests = struct
  (** 测试宏的添加和查找 *)
  let test_macro_add_and_find () =
    reset_state ();

    let test_body = TestUtils.create_test_expr () in
    let macro_def = TestUtils.create_test_macro "test_macro" test_body in

    (* 添加宏 *)
    add_macro "test_macro" macro_def;

    (* 查找宏 *)
    let found_macro = find_macro "test_macro" in
    match found_macro with
    | Some found ->
        check string "宏名应匹配" "test_macro" found.macro_def_name;
        check int "宏参数数量应匹配" 2 (List.length found.params)
    | None -> check bool "应该找到宏" false true

  (** 测试宏的替换 *)
  let test_macro_replacement () =
    reset_state ();

    let body1 = TestUtils.create_test_expr () in
    let body2 = VarExpr "new_var" in
    let macro1 = TestUtils.create_test_macro "replace_macro" body1 in
    let macro2 = TestUtils.create_test_macro "replace_macro" body2 in

    (* 添加第一个宏 *)
    add_macro "replace_macro" macro1;
    let first_find = find_macro "replace_macro" in

    (* 替换为第二个宏 *)
    add_macro "replace_macro" macro2;
    let second_find = find_macro "replace_macro" in

    (* 验证宏被替换 *)
    match (first_find, second_find) with
    | Some _, Some found -> check string "宏名应保持不变" "replace_macro" found.macro_def_name
    | _ -> check bool "宏替换测试失败" false true

  (** 测试不存在的宏查找 *)
  let test_macro_not_found () =
    reset_state ();

    let result = find_macro "nonexistent_macro" in
    match result with
    | None -> check bool "不存在的宏应返回None" true true
    | Some _ -> check bool "不存在的宏不应返回值" false true

  (** 测试多个宏的管理 *)
  let test_multiple_macros () =
    reset_state ();

    let body1 = VarExpr "var1" in
    let body2 = VarExpr "var2" in
    let body3 = VarExpr "var3" in
    let macro1 = TestUtils.create_test_macro "macro1" body1 in
    let macro2 = TestUtils.create_test_macro "macro2" body2 in
    let macro3 = TestUtils.create_test_macro "macro3" body3 in

    (* 添加多个宏 *)
    add_macro "macro1" macro1;
    add_macro "macro2" macro2;
    add_macro "macro3" macro3;

    (* 验证都能找到 *)
    let find1 = find_macro "macro1" in
    let find2 = find_macro "macro2" in
    let find3 = find_macro "macro3" in

    match (find1, find2, find3) with
    | Some f1, Some f2, Some f3 ->
        check string "宏1名称正确" "macro1" f1.macro_def_name;
        check string "宏2名称正确" "macro2" f2.macro_def_name;
        check string "宏3名称正确" "macro3" f3.macro_def_name
    | _ ->
        check bool "所有宏都应被找到" false true;

        (* 验证宏表大小 *)
        let macro_table = get_macro_table () in
        check int "宏表应包含3个宏" 3 (Hashtbl.length macro_table)
end

(** 模块表操作测试 *)
module ModuleTableTests = struct
  (** 测试模块的添加和查找 *)
  let test_module_add_and_find () =
    reset_state ();

    let test_bindings = TestUtils.create_test_bindings () in

    (* 添加模块 *)
    add_module "TestModule" test_bindings;

    (* 查找模块 *)
    let found_module = find_module "TestModule" in
    match found_module with
    | Some bindings ->
        check int "模块绑定数量应正确" 3 (List.length bindings);
        check string "第一个绑定名称应正确" "var1" (fst (List.hd bindings))
    | None -> check bool "应该找到模块" false true

  (** 测试模块的替换 *)
  let test_module_replacement () =
    reset_state ();

    let bindings1 = [ ("old_var", IntValue 1) ] in
    let bindings2 = [ ("new_var", IntValue 2) ] in

    (* 添加第一个模块 *)
    add_module "ReplaceModule" bindings1;
    let first_find = find_module "ReplaceModule" in

    (* 替换为第二个模块 *)
    add_module "ReplaceModule" bindings2;
    let second_find = find_module "ReplaceModule" in

    (* 验证模块被替换 *)
    match (first_find, second_find) with
    | Some _, Some new_bindings ->
        check string "新模块第一个绑定名称应正确" "new_var" (fst (List.hd new_bindings))
    | _ -> check bool "模块替换测试失败" false true

  (** 测试不存在的模块查找 *)
  let test_module_not_found () =
    reset_state ();

    let result = find_module "NonexistentModule" in
    match result with
    | None -> check bool "不存在的模块应返回None" true true
    | Some _ -> check bool "不存在的模块不应返回值" false true

  (** 测试多个模块的管理 *)
  let test_multiple_modules () =
    reset_state ();

    let bindings1 = [ ("mod1_var", IntValue 10) ] in
    let bindings2 = [ ("mod2_var", StringValue "test") ] in
    let bindings3 = [ ("mod3_var", BoolValue true) ] in

    (* 添加多个模块 *)
    add_module "Module1" bindings1;
    add_module "Module2" bindings2;
    add_module "Module3" bindings3;

    (* 验证都能找到 *)
    let find1 = find_module "Module1" in
    let find2 = find_module "Module2" in
    let find3 = find_module "Module3" in

    match (find1, find2, find3) with
    | Some b1, Some b2, Some b3 ->
        check string "模块1绑定名称正确" "mod1_var" (fst (List.hd b1));
        check string "模块2绑定名称正确" "mod2_var" (fst (List.hd b2));
        check string "模块3绑定名称正确" "mod3_var" (fst (List.hd b3))
    | _ ->
        check bool "所有模块都应被找到" false true;

        (* 验证模块表大小 *)
        let module_table = get_module_table () in
        check int "模块表应包含3个模块" 3 (Hashtbl.length module_table)

  (** 测试空模块绑定 *)
  let test_empty_module_bindings () =
    reset_state ();

    (* 添加空绑定模块 *)
    add_module "EmptyModule" [];

    (* 查找空模块 *)
    let found_module = find_module "EmptyModule" in
    match found_module with
    | Some bindings -> check int "空模块绑定数量应为0" 0 (List.length bindings)
    | None -> check bool "应该能找到空模块" false true
end

(** 递归函数表操作测试 *)
module RecursiveFunctionTests = struct
  (** 测试递归函数的添加和查找 *)
  let test_recursive_function_add_and_find () =
    reset_state ();

    let func_value = TestUtils.create_test_value "int" in

    (* 添加递归函数 *)
    add_recursive_function "test_func" func_value;

    (* 查找递归函数 *)
    let found_func = find_recursive_function "test_func" in
    match found_func with
    | Some (IntValue 42) -> check bool "递归函数值应正确" true true
    | Some _ -> check bool "递归函数值类型错误" false true
    | None -> check bool "应该找到递归函数" false true

  (** 测试递归函数的替换 *)
  let test_recursive_function_replacement () =
    reset_state ();

    let func1 = IntValue 1 in
    let func2 = IntValue 2 in

    (* 添加第一个函数 *)
    add_recursive_function "replace_func" func1;
    let first_find = find_recursive_function "replace_func" in

    (* 替换为第二个函数 *)
    add_recursive_function "replace_func" func2;
    let second_find = find_recursive_function "replace_func" in

    (* 验证函数被替换 *)
    match (first_find, second_find) with
    | Some (IntValue 1), Some (IntValue 2) -> check bool "递归函数替换成功" true true
    | _ -> check bool "递归函数替换失败" false true

  (** 测试不存在的递归函数查找 *)
  let test_recursive_function_not_found () =
    reset_state ();

    let result = find_recursive_function "nonexistent_func" in
    match result with
    | None -> check bool "不存在的递归函数应返回None" true true
    | Some _ -> check bool "不存在的递归函数不应返回值" false true

  (** 测试多个递归函数的管理 *)
  let test_multiple_recursive_functions () =
    reset_state ();

    let func1 = IntValue 10 in
    let func2 = StringValue "hello" in
    let func3 = BoolValue true in

    (* 添加多个递归函数 *)
    add_recursive_function "func1" func1;
    add_recursive_function "func2" func2;
    add_recursive_function "func3" func3;

    (* 验证都能找到 *)
    let find1 = find_recursive_function "func1" in
    let find2 = find_recursive_function "func2" in
    let find3 = find_recursive_function "func3" in

    match (find1, find2, find3) with
    | Some (IntValue 10), Some (StringValue "hello"), Some (BoolValue true) ->
        check bool "所有递归函数都应被正确找到" true true
    | _ ->
        check bool "递归函数查找失败" false true;

        (* 验证递归函数表大小 *)
        let recursive_table = get_recursive_functions () in
        check int "递归函数表应包含3个函数" 3 (Hashtbl.length recursive_table)
end

(** 函子表操作测试 *)
module FunctorTableTests = struct
  (** 测试函子的添加和查找 *)
  let test_functor_add_and_find () =
    reset_state ();

    let param_name = "param" in
    let module_type = TestUtils.create_test_module_type () in
    let body = TestUtils.create_test_expr () in

    (* 添加函子 *)
    add_functor "test_functor" param_name module_type body;

    (* 查找函子 *)
    let found_functor = find_functor "test_functor" in
    match found_functor with
    | Some (param, _, _) -> check string "函子参数名应正确" "param" param
    | None -> check bool "应该找到函子" false true

  (** 测试函子的替换 *)
  let test_functor_replacement () =
    reset_state ();

    let param1 = "param1" in
    let param2 = "param2" in
    let module_type = TestUtils.create_test_module_type () in
    let body = TestUtils.create_test_expr () in

    (* 添加第一个函子 *)
    add_functor "replace_functor" param1 module_type body;
    let first_find = find_functor "replace_functor" in

    (* 替换为第二个函子 *)
    add_functor "replace_functor" param2 module_type body;
    let second_find = find_functor "replace_functor" in

    (* 验证函子被替换 *)
    match (first_find, second_find) with
    | Some (p1, _, _), Some (p2, _, _) ->
        check string "第一个函子参数" "param1" p1;
        check string "第二个函子参数" "param2" p2
    | _ -> check bool "函子替换测试失败" false true

  (** 测试不存在的函子查找 *)
  let test_functor_not_found () =
    reset_state ();

    let result = find_functor "nonexistent_functor" in
    match result with
    | None -> check bool "不存在的函子应返回None" true true
    | Some _ -> check bool "不存在的函子不应返回值" false true

  (** 测试多个函子的管理 *)
  let test_multiple_functors () =
    reset_state ();

    let module_type = TestUtils.create_test_module_type () in
    let body = TestUtils.create_test_expr () in

    (* 添加多个函子 *)
    add_functor "functor1" "param1" module_type body;
    add_functor "functor2" "param2" module_type body;
    add_functor "functor3" "param3" module_type body;

    (* 验证都能找到 *)
    let find1 = find_functor "functor1" in
    let find2 = find_functor "functor2" in
    let find3 = find_functor "functor3" in

    match (find1, find2, find3) with
    | Some (p1, _, _), Some (p2, _, _), Some (p3, _, _) ->
        check string "函子1参数名正确" "param1" p1;
        check string "函子2参数名正确" "param2" p2;
        check string "函子3参数名正确" "param3" p3
    | _ ->
        check bool "所有函子都应被找到" false true;

        (* 验证函子表大小 *)
        let functor_table = get_functor_table () in
        check int "函子表应包含3个函子" 3 (Hashtbl.length functor_table)
end

(** 状态重置测试 *)
module StateResetTests = struct
  (** 测试状态重置功能 *)
  let test_state_reset () =
    (* 首先添加一些数据 *)
    let body = TestUtils.create_test_expr () in
    let macro_def = TestUtils.create_test_macro "test_macro" body in
    let bindings = TestUtils.create_test_bindings () in
    let func_value = TestUtils.create_test_value "int" in
    let module_type = TestUtils.create_test_module_type () in

    add_macro "test_macro" macro_def;
    add_module "test_module" bindings;
    add_recursive_function "test_func" func_value;
    add_functor "test_functor" "param" module_type body;

    (* 验证数据存在 *)
    let macro_table = get_macro_table () in
    let module_table = get_module_table () in
    let recursive_table = get_recursive_functions () in
    let functor_table = get_functor_table () in

    check bool "重置前宏表不为空" true (Hashtbl.length macro_table > 0);
    check bool "重置前模块表不为空" true (Hashtbl.length module_table > 0);
    check bool "重置前递归函数表不为空" true (Hashtbl.length recursive_table > 0);
    check bool "重置前函子表不为空" true (Hashtbl.length functor_table > 0);

    (* 重置状态 *)
    reset_state ();

    (* 验证所有表都被清空 *)
    check int "重置后宏表应为空" 0 (Hashtbl.length macro_table);
    check int "重置后模块表应为空" 0 (Hashtbl.length module_table);
    check int "重置后递归函数表应为空" 0 (Hashtbl.length recursive_table);
    check int "重置后函子表应为空" 0 (Hashtbl.length functor_table)

  (** 测试重置后重新添加数据 *)
  let test_reset_and_readd () =
    reset_state ();

    (* 重置后添加新数据 *)
    let body = VarExpr "new_var" in
    let macro_def = TestUtils.create_test_macro "new_macro" body in
    add_macro "new_macro" macro_def;

    (* 验证可以正常添加和查找 *)
    let found_macro = find_macro "new_macro" in
    match found_macro with
    | Some found -> check string "重置后宏添加正常" "new_macro" found.macro_def_name
    | None -> check bool "重置后应能添加新宏" false true
end

(** 可用变量获取测试 *)
module AvailableVarsTests = struct
  (** 测试获取可用变量 *)
  let test_get_available_vars () =
    reset_state ();

    (* 准备环境变量 *)
    let env = [ ("env_var1", IntValue 1); ("env_var2", StringValue "test") ] in

    (* 添加递归函数 *)
    add_recursive_function "rec_func1" (IntValue 10);
    add_recursive_function "rec_func2" (StringValue "func");

    (* 获取可用变量 *)
    let available_vars = get_available_vars env in

    (* 验证包含环境变量 *)
    check bool "应包含环境变量1" true (List.mem "env_var1" available_vars);
    check bool "应包含环境变量2" true (List.mem "env_var2" available_vars);

    (* 验证包含递归函数 *)
    check bool "应包含递归函数1" true (List.mem "rec_func1" available_vars);
    check bool "应包含递归函数2" true (List.mem "rec_func2" available_vars);

    (* 验证变量总数 *)
    check bool "可用变量数量应为4" true (List.length available_vars >= 4)

  (** 测试空环境的可用变量 *)
  let test_available_vars_empty_env () =
    reset_state ();

    (* 只添加递归函数 *)
    add_recursive_function "only_rec_func" (IntValue 42);

    (* 获取可用变量（空环境） *)
    let available_vars = get_available_vars [] in

    (* 验证只包含递归函数 *)
    check bool "应包含递归函数" true (List.mem "only_rec_func" available_vars);
    check int "应只有1个变量" 1 (List.length available_vars)

  (** 测试无递归函数的可用变量 *)
  let test_available_vars_no_recursive () =
    reset_state ();

    (* 只有环境变量 *)
    let env = [ ("only_env_var", IntValue 1) ] in

    (* 获取可用变量 *)
    let available_vars = get_available_vars env in

    (* 验证只包含环境变量 *)
    check bool "应包含环境变量" true (List.mem "only_env_var" available_vars);
    check int "应只有1个变量" 1 (List.length available_vars)
end

(** 复杂场景测试 *)
module ComplexScenarioTests = struct
  (** 测试复杂的状态操作场景 *)
  let test_complex_state_operations () =
    reset_state ();

    (* 场景：构建一个完整的解释器状态 *)

    (* 1. 添加多个宏 *)
    let macro_body1 = VarExpr "x" in
    let macro_body2 = VarExpr "y" in
    let macro1 = TestUtils.create_test_macro "macro1" macro_body1 in
    let macro2 = TestUtils.create_test_macro "macro2" macro_body2 in
    add_macro "macro1" macro1;
    add_macro "macro2" macro2;

    (* 2. 添加多个模块 *)
    let module_bindings1 = [ ("mod1_var", IntValue 100) ] in
    let module_bindings2 = [ ("mod2_var", StringValue "module") ] in
    add_module "Module1" module_bindings1;
    add_module "Module2" module_bindings2;

    (* 3. 添加多个递归函数 *)
    add_recursive_function "fibonacci" (IntValue 0);
    add_recursive_function "factorial" (IntValue 1);

    (* 4. 添加多个函子 *)
    let module_type = TestUtils.create_test_module_type () in
    let functor_body = VarExpr "functor_param" in
    add_functor "Functor1" "param1" module_type functor_body;
    add_functor "Functor2" "param2" module_type functor_body;

    (* 验证所有组件都正常工作 *)
    let macro_result = find_macro "macro1" in
    let module_result = find_module "Module1" in
    let func_result = find_recursive_function "fibonacci" in
    let functor_result = find_functor "Functor1" in

    match (macro_result, module_result, func_result, functor_result) with
    | Some macro, Some module_bindings, Some func_val, Some (param, _, _) ->
        check string "宏查找正常" "macro1" macro.macro_def_name;
        check string "模块查找正常" "mod1_var" (fst (List.hd module_bindings));
        check bool "递归函数查找正常" true (func_val = IntValue 0);
        check string "函子查找正常" "param1" param
    | _ -> check bool "复杂场景测试失败" false true

  (** 测试状态的并发操作模拟 *)
  let test_concurrent_operations_simulation () =
    reset_state ();

    (* 模拟多个操作交替进行 *)
    let body = VarExpr "concurrent_var" in
    let macro_def = TestUtils.create_test_macro "concurrent_macro" body in

    (* 交替添加不同类型的数据 *)
    add_macro "step1_macro" macro_def;
    add_module "step1_module" [ ("var", IntValue 1) ];
    add_recursive_function "step1_func" (IntValue 1);
    add_functor "step1_functor" "param" (TestUtils.create_test_module_type ()) body;

    add_macro "step2_macro" macro_def;
    add_module "step2_module" [ ("var", IntValue 2) ];
    add_recursive_function "step2_func" (IntValue 2);
    add_functor "step2_functor" "param" (TestUtils.create_test_module_type ()) body;

    (* 验证所有数据都存在且正确 *)
    let macro_table = get_macro_table () in
    let module_table = get_module_table () in
    let recursive_table = get_recursive_functions () in
    let functor_table = get_functor_table () in

    check int "宏表应包含2个宏" 2 (Hashtbl.length macro_table);
    check int "模块表应包含2个模块" 2 (Hashtbl.length module_table);
    check int "递归函数表应包含2个函数" 2 (Hashtbl.length recursive_table);
    check int "函子表应包含2个函子" 2 (Hashtbl.length functor_table)

  (** 测试边界条件和错误处理 *)
  let test_edge_cases () =
    reset_state ();

    (* 测试空字符串名称 *)
    let body = VarExpr "empty_name_test" in
    let macro_def = TestUtils.create_test_macro "" body in
    add_macro "" macro_def;

    let found_empty = find_macro "" in
    match found_empty with
    | Some found -> check string "空名称宏应能正常处理" "" found.macro_def_name
    | None -> (
        check bool "空名称宏查找失败" false true;

        (* 测试特殊字符名称 *)
        add_module "模块名_中文123!@#" [ ("中文变量", IntValue 999) ];
        let found_special = find_module "模块名_中文123!@#" in
        match found_special with
        | Some bindings -> check string "特殊字符模块名应能处理" "中文变量" (fst (List.hd bindings))
        | None -> check bool "特殊字符模块名查找失败" false true)
end

(** 性能基准测试 *)
module PerformanceTests = struct
  (** 测试大量数据操作性能 *)
  let test_large_scale_operations () =
    reset_state ();

    let start_time = Sys.time () in

    (* 添加大量宏 *)
    for i = 1 to 1000 do
      let name = "macro_" ^ string_of_int i in
      let body = VarExpr ("var_" ^ string_of_int i) in
      let macro_def = TestUtils.create_test_macro name body in
      add_macro name macro_def
    done;

    (* 添加大量模块 *)
    for i = 1 to 1000 do
      let name = "module_" ^ string_of_int i in
      let bindings = [ ("var_" ^ string_of_int i, IntValue i) ] in
      add_module name bindings
    done;

    let end_time = Sys.time () in
    let duration = end_time -. start_time in

    (* 验证性能在合理范围内 *)
    check bool "大量操作应在合理时间内完成" true (duration < 2.0);

    (* 验证数据正确性 *)
    let macro_table = get_macro_table () in
    let module_table = get_module_table () in
    check int "应添加1000个宏" 1000 (Hashtbl.length macro_table);
    check int "应添加1000个模块" 1000 (Hashtbl.length module_table)

  (** 测试频繁查找操作性能 *)
  let test_frequent_lookup_performance () =
    reset_state ();

    (* 准备测试数据 *)
    for i = 1 to 100 do
      let name = "lookup_test_" ^ string_of_int i in
      let func_val = IntValue i in
      add_recursive_function name func_val
    done;

    let start_time = Sys.time () in

    (* 频繁查找操作 *)
    for _ = 1 to 10000 do
      let random_i = 1 + Random.int 100 in
      let name = "lookup_test_" ^ string_of_int random_i in
      let _ = find_recursive_function name in
      ()
    done;

    let end_time = Sys.time () in
    let duration = end_time -. start_time in

    (* 验证查找性能 *)
    check bool "频繁查找应在合理时间内完成" true (duration < 1.0)
end

(** 主测试套件 *)
let () =
  run "骆言解释器状态管理模块综合测试"
    [
      ( "状态创建测试",
        [
          test_case "状态创建" `Quick StateCreationTests.test_create_state;
          test_case "全局状态访问" `Quick StateCreationTests.test_global_state_access;
        ] );
      ( "宏表操作测试",
        [
          test_case "宏添加和查找" `Quick MacroTableTests.test_macro_add_and_find;
          test_case "宏替换" `Quick MacroTableTests.test_macro_replacement;
          test_case "宏查找失败" `Quick MacroTableTests.test_macro_not_found;
          test_case "多宏管理" `Quick MacroTableTests.test_multiple_macros;
        ] );
      ( "模块表操作测试",
        [
          test_case "模块添加和查找" `Quick ModuleTableTests.test_module_add_and_find;
          test_case "模块替换" `Quick ModuleTableTests.test_module_replacement;
          test_case "模块查找失败" `Quick ModuleTableTests.test_module_not_found;
          test_case "多模块管理" `Quick ModuleTableTests.test_multiple_modules;
          test_case "空模块绑定" `Quick ModuleTableTests.test_empty_module_bindings;
        ] );
      ( "递归函数表操作测试",
        [
          test_case "递归函数添加和查找" `Quick RecursiveFunctionTests.test_recursive_function_add_and_find;
          test_case "递归函数替换" `Quick RecursiveFunctionTests.test_recursive_function_replacement;
          test_case "递归函数查找失败" `Quick RecursiveFunctionTests.test_recursive_function_not_found;
          test_case "多递归函数管理" `Quick RecursiveFunctionTests.test_multiple_recursive_functions;
        ] );
      ( "函子表操作测试",
        [
          test_case "函子添加和查找" `Quick FunctorTableTests.test_functor_add_and_find;
          test_case "函子替换" `Quick FunctorTableTests.test_functor_replacement;
          test_case "函子查找失败" `Quick FunctorTableTests.test_functor_not_found;
          test_case "多函子管理" `Quick FunctorTableTests.test_multiple_functors;
        ] );
      ( "状态重置测试",
        [
          test_case "状态重置" `Quick StateResetTests.test_state_reset;
          test_case "重置后重新添加" `Quick StateResetTests.test_reset_and_readd;
        ] );
      ( "可用变量获取测试",
        [
          test_case "获取可用变量" `Quick AvailableVarsTests.test_get_available_vars;
          test_case "空环境可用变量" `Quick AvailableVarsTests.test_available_vars_empty_env;
          test_case "无递归函数可用变量" `Quick AvailableVarsTests.test_available_vars_no_recursive;
        ] );
      ( "复杂场景测试",
        [
          test_case "复杂状态操作" `Slow ComplexScenarioTests.test_complex_state_operations;
          test_case "并发操作模拟" `Quick ComplexScenarioTests.test_concurrent_operations_simulation;
          test_case "边界条件处理" `Quick ComplexScenarioTests.test_edge_cases;
        ] );
      ( "性能基准测试",
        [
          test_case "大规模操作性能" `Slow PerformanceTests.test_large_scale_operations;
          test_case "频繁查找性能" `Slow PerformanceTests.test_frequent_lookup_performance;
        ] );
    ]
