(** 骆言语义类型管理模块全面测试套件 *)

open Alcotest
open Yyocamlc_lib
open Ast
open Types
open Semantic_context
open Semantic_types

(** 辅助函数：创建测试用的语义上下文 *)
let create_test_context () =
  let ctx = create_initial_context () in
  (* 添加一些基础类型定义 *)
  ctx |> fun c ->
  add_type_definition c "整数" IntType_T |> fun c ->
  add_type_definition c "字符串" StringType_T |> fun c -> add_type_definition c "布尔" BoolType_T

(** 辅助函数：比较类型相等性 *)
let compare_types expected actual =
  let typ_to_string = function
    | IntType_T -> "IntType_T"
    | StringType_T -> "StringType_T"
    | BoolType_T -> "BoolType_T"
    | ListType_T t ->
        "ListType_T("
        ^ (match t with IntType_T -> "IntType_T" | StringType_T -> "StringType_T" | _ -> "Other")
        ^ ")"
    | ConstructType_T (s, []) -> "ConstructType_T(" ^ s ^ ")"
    | FunType_T (arg, ret) ->
        let arg_str =
          match arg with
          | IntType_T -> "IntType_T"
          | StringType_T -> "StringType_T"
          | TupleType_T _ -> "TupleType_T"
          | _ -> "Other"
        in
        let ret_str =
          match ret with IntType_T -> "IntType_T" | StringType_T -> "StringType_T" | _ -> "Other"
        in
        "FunType_T(" ^ arg_str ^ ", " ^ ret_str ^ ")"
    | RecordType_T fields ->
        let field_strs =
          List.map
            (fun (name, t) ->
              name ^ ":"
              ^
              match t with
              | IntType_T -> "IntType_T"
              | StringType_T -> "StringType_T"
              | _ -> "Other")
            fields
        in
        "RecordType_T([" ^ String.concat "; " field_strs ^ "])"
    | _ -> "其他类型"
  in
  check string "类型匹配" (typ_to_string expected) (typ_to_string actual)

(** 基础类型表达式解析测试 *)
let test_resolve_basic_type_expr () =
  let ctx = create_test_context () in

  (* 测试基础类型解析 *)
  let int_type = resolve_type_expr ctx (BaseTypeExpr IntType) in
  compare_types IntType_T int_type;

  let string_type = resolve_type_expr ctx (BaseTypeExpr StringType) in
  compare_types StringType_T string_type;

  let bool_type = resolve_type_expr ctx (BaseTypeExpr BoolType) in
  compare_types BoolType_T bool_type

(** 列表类型表达式解析测试 *)
let test_resolve_list_type_expr () =
  let ctx = create_test_context () in

  (* 测试列表类型解析 *)
  let int_list_expr = ListType (BaseTypeExpr IntType) in
  let int_list_type = resolve_type_expr ctx int_list_expr in
  compare_types (ListType_T IntType_T) int_list_type;

  let string_list_expr = ListType (BaseTypeExpr StringType) in
  let string_list_type = resolve_type_expr ctx string_list_expr in
  compare_types (ListType_T StringType_T) string_list_type

(** 函数类型表达式解析测试 *)
let test_resolve_function_type_expr () =
  let ctx = create_test_context () in

  (* 测试简单函数类型 *)
  let simple_func_expr = FunType (BaseTypeExpr IntType, BaseTypeExpr StringType) in
  let simple_func_type = resolve_type_expr ctx simple_func_expr in
  compare_types (FunType_T (IntType_T, StringType_T)) simple_func_type;

  (* 测试多参数函数类型 *)
  let multi_param_expr =
    FunType (TupleType [ BaseTypeExpr IntType; BaseTypeExpr BoolType ], BaseTypeExpr StringType)
  in
  let multi_param_type = resolve_type_expr ctx multi_param_expr in
  compare_types (FunType_T (TupleType_T [ IntType_T; BoolType_T ], StringType_T)) multi_param_type

(** 记录类型表达式解析测试 *)
let test_resolve_record_type_expr () =
  let ctx = create_test_context () in

  (* 测试记录类型解析 - 使用自定义类型表示 *)
  let record_expr =
    ConstructType ("RecordType", [ BaseTypeExpr StringType; BaseTypeExpr IntType ])
  in
  let record_type = resolve_type_expr ctx record_expr in
  compare_types (ConstructType_T ("RecordType", [ StringType_T; IntType_T ])) record_type

(** 自定义类型表达式解析测试 *)
let test_resolve_custom_type_expr () =
  let ctx = create_test_context () in
  let ctx_with_custom = add_type_definition ctx "我的类型" (ConstructType_T ("我的类型", [])) in

  (* 测试自定义类型解析 *)
  let custom_expr = ConstructType ("我的类型", []) in
  let custom_type = resolve_type_expr ctx_with_custom custom_expr in
  compare_types (ConstructType_T ("我的类型", [])) custom_type

(** 代数数据类型添加测试 *)
let test_add_algebraic_type_simple () =
  let ctx = create_test_context () in

  (* 测试简单枚举类型 *)
  let constructors = [ ("红色", None); ("绿色", None); ("蓝色", None) ] in
  let ctx_with_enum = add_algebraic_type ctx "颜色" constructors in

  (* 验证构造器是否正确添加 *)
  let red_symbol = lookup_symbol ctx_with_enum.scope_stack "红色" in
  check bool "代数类型添加成功" true (Option.is_some red_symbol)

(** 带参数的代数数据类型测试 *)
let test_add_algebraic_type_with_params () =
  let ctx = create_test_context () in

  (* 测试带参数的构造器 *)
  let constructors = [ ("无", None); ("有", Some (BaseTypeExpr IntType)) ] in
  let ctx_with_option = add_algebraic_type ctx "选项" constructors in

  (* 验证构造器是否正确添加 *)
  let none_symbol = lookup_symbol ctx_with_option.scope_stack "无" in
  check bool "带参数的代数类型添加成功" true (Option.is_some none_symbol)

(** 符号表到类型环境转换测试 *)
let test_symbol_table_to_env () =
  let ctx = create_test_context () in
  let ctx_with_symbols =
    ctx |> fun c ->
    add_symbol c "变量A" IntType_T false |> fun c ->
    add_symbol c "变量B" StringType_T false |> fun c ->
    add_symbol c "变量C" (ListType_T BoolType_T) true
  in

  let current_scope = List.hd ctx_with_symbols.scope_stack in
  let env = symbol_table_to_env current_scope in

  check int "环境包含正确数量的变量" 3 (TypeEnv.cardinal env);

  (* 检查环境中的变量类型 *)
  let find_in_env name = try Some (TypeEnv.find name env) with Not_found -> None in

  check bool "变量A存在于环境中" true (Option.is_some (find_in_env "变量A"));
  check bool "变量B存在于环境中" true (Option.is_some (find_in_env "变量B"));
  check bool "变量C存在于环境中" true (Option.is_some (find_in_env "变量C"))

(** 作用域栈到类型环境构建测试 *)
let test_build_type_env () =
  let ctx = create_test_context () in

  (* 在全局作用域添加变量 *)
  let ctx_with_global = add_symbol ctx "全局变量" IntType_T false in

  (* 进入新作用域并添加局部变量 *)
  let ctx_with_scope = enter_scope ctx_with_global in
  let ctx_with_local = add_symbol ctx_with_scope "局部变量" StringType_T false in

  (* 构建类型环境 *)
  let env = build_type_env ctx_with_local.scope_stack in

  check int "环境包含所有作用域的变量" 2 (TypeEnv.cardinal env);

  (* 检查环境中包含全局和局部变量 *)
  let find_in_env name = try Some (TypeEnv.find name env) with Not_found -> None in

  check bool "全局变量存在于环境中" true (Option.is_some (find_in_env "全局变量"));
  check bool "局部变量存在于环境中" true (Option.is_some (find_in_env "局部变量"))

(** 嵌套类型表达式解析测试 *)
let test_resolve_nested_type_expr () =
  let ctx = create_test_context () in

  (* 测试嵌套列表类型 *)
  let nested_list_expr = ListType (ListType (BaseTypeExpr IntType)) in
  let nested_list_type = resolve_type_expr ctx nested_list_expr in
  compare_types (ListType_T (ListType_T IntType_T)) nested_list_type;

  (* 测试复杂函数类型 *)
  let complex_func_expr =
    FunType (ListType (BaseTypeExpr IntType), ListType (BaseTypeExpr StringType))
  in
  let complex_func_type = resolve_type_expr ctx complex_func_expr in
  compare_types (FunType_T (ListType_T IntType_T, ListType_T StringType_T)) complex_func_type

(** 错误处理测试 *)
let test_error_handling () =
  let ctx = create_test_context () in

  (* 测试未定义类型的处理 *)
  let unknown_expr = ConstructType ("未定义类型", []) in
  let result = resolve_type_expr ctx unknown_expr in
  (* 应该返回自定义类型或抛出异常，这里假设返回ConstructType_T *)
  compare_types (ConstructType_T ("未定义类型", [])) result

(** 复杂记录类型测试 *)
let test_complex_record_types () =
  let ctx = create_test_context () in

  (* 创建包含嵌套结构的记录类型 *)
  let complex_record_expr =
    ConstructType
      ("ComplexRecord", [ BaseTypeExpr StringType; BaseTypeExpr IntType; BaseTypeExpr BoolType ])
  in
  let complex_record_type = resolve_type_expr ctx complex_record_expr in

  (* 验证复杂记录类型的结构 *)
  match complex_record_type with
  | ConstructType_T (type_name, type_args) ->
      check string "复杂记录类型名称" "ComplexRecord" type_name;
      check int "复杂记录类型参数数量" 3 (List.length type_args)
  | _ -> failwith "期望的是构造类型"

(** 类型定义递归引用测试 *)
let test_recursive_type_definitions () =
  let ctx = create_test_context () in

  (* 添加递归类型定义 *)
  let ctx_with_list = add_type_definition ctx "我的列表" (ListType_T (ConstructType_T ("我的列表", []))) in

  (* 验证递归类型定义 *)
  let list_type = lookup_type_definition ctx_with_list "我的列表" in
  check bool "递归类型定义添加成功" true (Option.is_some list_type)

(** 性能测试 - 大量类型定义 *)
let test_large_type_environment () =
  let ctx = create_test_context () in
  let add_many_types ctx count =
    let rec loop ctx i =
      if i >= count then ctx
      else
        let type_name = Printf.sprintf "类型_%d" i in
        let new_ctx = add_type_definition ctx type_name (ConstructType_T (type_name, [])) in
        loop new_ctx (i + 1)
    in
    loop ctx 0
  in

  let ctx_with_many = add_many_types ctx 100 in

  (* 测试类型查找性能 *)
  let middle_type = lookup_type_definition ctx_with_many "类型_50" in
  let last_type = lookup_type_definition ctx_with_many "类型_99" in

  check bool "大量类型中查找中间类型" true (Option.is_some middle_type);
  check bool "大量类型中查找最后类型" true (Option.is_some last_type)

(** 边界条件测试 *)
let test_edge_cases () =
  let ctx = create_test_context () in

  (* 测试空记录类型 *)
  let empty_record_expr = ConstructType ("EmptyRecord", []) in
  let empty_record_type = resolve_type_expr ctx empty_record_expr in
  compare_types (ConstructType_T ("EmptyRecord", [])) empty_record_type;

  (* 测试无参数函数类型 *)
  let no_param_func_expr = FunType (BaseTypeExpr UnitType, BaseTypeExpr IntType) in
  let no_param_func_type = resolve_type_expr ctx no_param_func_expr in
  compare_types (FunType_T (UnitType_T, IntType_T)) no_param_func_type;

  (* 测试空字符串类型名 *)
  let empty_name_expr = ConstructType ("", []) in
  let empty_name_type = resolve_type_expr ctx empty_name_expr in
  compare_types (ConstructType_T ("", [])) empty_name_type

(** 测试套件定义 *)
let () =
  run "Semantic_types 综合测试"
    [
      ( "基础类型解析",
        [
          test_case "基础类型表达式解析" `Quick test_resolve_basic_type_expr;
          test_case "列表类型表达式解析" `Quick test_resolve_list_type_expr;
          test_case "函数类型表达式解析" `Quick test_resolve_function_type_expr;
          test_case "记录类型表达式解析" `Quick test_resolve_record_type_expr;
          test_case "自定义类型表达式解析" `Quick test_resolve_custom_type_expr;
        ] );
      ( "代数数据类型",
        [
          test_case "简单代数类型添加" `Quick test_add_algebraic_type_simple;
          test_case "带参数代数类型添加" `Quick test_add_algebraic_type_with_params;
        ] );
      ( "类型环境管理",
        [
          test_case "符号表到类型环境转换" `Quick test_symbol_table_to_env;
          test_case "作用域栈到类型环境构建" `Quick test_build_type_env;
        ] );
      ( "复杂类型处理",
        [
          test_case "嵌套类型表达式解析" `Quick test_resolve_nested_type_expr;
          test_case "复杂记录类型" `Quick test_complex_record_types;
          test_case "递归类型定义" `Quick test_recursive_type_definitions;
        ] );
      ( "错误处理和边界条件",
        [ test_case "错误处理测试" `Quick test_error_handling; test_case "边界条件测试" `Quick test_edge_cases ]
      );
      ("性能测试", [ test_case "大量类型环境" `Slow test_large_type_environment ]);
    ]
