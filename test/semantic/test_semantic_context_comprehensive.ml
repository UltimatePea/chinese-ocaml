(** 骆言语义上下文模块全面测试套件 *)

open Alcotest
open Yyocamlc_lib
open Types
open Semantic_context

(** 基础符号表条目创建测试 *)
let test_create_symbol_entry () =
  let entry = create_symbol_entry "变量一" IntType_T in
  check string "symbol_name" "变量一" entry.symbol_name;
  check bool "is_mutable" false entry.is_mutable;
  check (option int) "definition_pos" (Some 0) (Some entry.definition_pos)

(** 初始语义上下文创建测试 *)
let test_create_initial_context () =
  let ctx = create_initial_context () in
  check
    (list (list (pair string string)))
    "scope_stack" [ [] ]
    (List.map
       (fun st -> SymbolTable.bindings st |> List.map (fun (k, v) -> (k, v.symbol_name)))
       ctx.scope_stack);
  check (option string) "current_function_return_type" None
    (match ctx.current_function_return_type with Some _ -> Some "有返回类型" | None -> None);
  check (list string) "error_list" [] ctx.error_list;
  check (list string) "macros" [] (List.map fst ctx.macros);
  let type_defs = TypeDefTable.bindings ctx.type_definitions in
  check (list string) "type_definitions" [] (List.map fst type_defs)

(** 作用域进入和退出测试 *)
let test_scope_operations () =
  let ctx = create_initial_context () in
  let ctx_with_scope = enter_scope ctx in
  let scope_count_after_enter = List.length ctx_with_scope.scope_stack in
  check int "enter_scope增加作用域" 2 scope_count_after_enter;

  let ctx_after_exit = exit_scope ctx_with_scope in
  let scope_count_after_exit = List.length ctx_after_exit.scope_stack in
  check int "exit_scope减少作用域" 1 scope_count_after_exit

(** 符号添加和查找测试 *)
let test_symbol_operations () =
  let ctx = create_initial_context () in
  let ctx_with_symbol = add_symbol ctx "测试变量" IntType_T false in

  (* 测试符号添加 *)
  let current_scope = List.hd ctx_with_symbol.scope_stack in
  let symbol_exists = SymbolTable.mem "测试变量" current_scope in
  check bool "符号添加成功" true symbol_exists;

  (* 测试符号查找 *)
  let found_symbol = lookup_symbol ctx_with_symbol.scope_stack "测试变量" in
  check bool "符号查找成功" true (Option.is_some found_symbol);

  match found_symbol with
  | Some entry ->
      check string "查找的符号名称" "测试变量" entry.symbol_name;
      check bool "查找的符号可变性" false entry.is_mutable
  | None -> failwith "符号查找失败"

(** 嵌套作用域符号查找测试 *)
let test_nested_scope_lookup () =
  let ctx = create_initial_context () in
  let ctx_with_global = add_symbol ctx "全局变量" IntType_T false in
  let ctx_with_scope = enter_scope ctx_with_global in
  let ctx_with_local = add_symbol ctx_with_scope "局部变量" StringType_T false in

  (* 在内层作用域查找全局变量 *)
  let global_found = lookup_symbol ctx_with_local.scope_stack "全局变量" in
  check bool "内层作用域可访问全局变量" true (Option.is_some global_found);

  (* 在内层作用域查找局部变量 *)
  let local_found = lookup_symbol ctx_with_local.scope_stack "局部变量" in
  check bool "内层作用域可访问局部变量" true (Option.is_some local_found);

  (* 退出内层作用域后查找局部变量 *)
  let ctx_after_exit = exit_scope ctx_with_local in
  let local_not_found = lookup_symbol ctx_after_exit.scope_stack "局部变量" in
  check bool "退出作用域后局部变量不可访问" true (Option.is_none local_not_found)

(** 类型定义添加和查找测试 *)
let test_type_definition_operations () =
  let ctx = create_initial_context () in
  let custom_type = ConstructType_T ("自定义类型", []) in
  let ctx_with_type = add_type_definition ctx "我的类型" custom_type in

  (* 测试类型定义查找 *)
  let found_type = lookup_type_definition ctx_with_type "我的类型" in
  check bool "类型定义查找成功" true (Option.is_some found_type);

  (* 测试不存在的类型定义查找 *)
  let not_found = lookup_type_definition ctx_with_type "不存在的类型" in
  check bool "不存在的类型定义返回None" true (Option.is_none not_found)

(** 符号表到环境转换测试 *)
let test_symbol_table_to_env () =
  let ctx = create_initial_context () in
  let ctx_with_symbols =
    ctx |> fun c ->
    add_symbol c "变量A" IntType_T false |> fun c ->
    add_symbol c "变量B" StringType_T false |> fun c -> add_symbol c "变量C" BoolType_T true
  in

  let current_scope = List.hd ctx_with_symbols.scope_stack in
  let env = symbol_table_to_env current_scope in

  check int "环境包含正确数量的符号" 3 (List.length env);

  (* 检查环境中包含预期的符号 *)
  let symbol_names = List.map fst env in
  check bool "环境包含变量A" true (List.mem "变量A" symbol_names);
  check bool "环境包含变量B" true (List.mem "变量B" symbol_names);
  check bool "环境包含变量C" true (List.mem "变量C" symbol_names)

(** 可变性标志测试 *)
let test_mutability_flag () =
  let ctx = create_initial_context () in
  let ctx_with_immutable = add_symbol ctx "不可变变量" IntType_T false in
  let ctx_with_mutable = add_symbol ctx_with_immutable "可变变量" StringType_T true in

  let immutable_symbol = lookup_symbol ctx_with_mutable.scope_stack "不可变变量" in
  let mutable_symbol = lookup_symbol ctx_with_mutable.scope_stack "可变变量" in

  match (immutable_symbol, mutable_symbol) with
  | Some im_entry, Some mut_entry ->
      check bool "不可变变量标志" false im_entry.is_mutable;
      check bool "可变变量标志" true mut_entry.is_mutable
  | _ -> failwith "符号查找失败"

(** 复杂类型处理测试 *)
let test_complex_types () =
  let ctx = create_initial_context () in
  let list_type = ListType_T IntType_T in
  let function_type = FunType_T (TupleType_T [ IntType_T; StringType_T ], BoolType_T) in
  let record_type = RecordType_T [ ("字段1", IntType_T); ("字段2", StringType_T) ] in

  let ctx_with_complex =
    ctx |> fun c ->
    add_symbol c "整数列表" list_type false |> fun c ->
    add_symbol c "测试函数" function_type false |> fun c -> add_symbol c "记录变量" record_type false
  in

  let list_symbol = lookup_symbol ctx_with_complex.scope_stack "整数列表" in
  let func_symbol = lookup_symbol ctx_with_complex.scope_stack "测试函数" in
  let record_symbol = lookup_symbol ctx_with_complex.scope_stack "记录变量" in

  check bool "列表类型符号查找成功" true (Option.is_some list_symbol);
  check bool "函数类型符号查找成功" true (Option.is_some func_symbol);
  check bool "记录类型符号查找成功" true (Option.is_some record_symbol)

(** 空作用域栈错误处理测试 *)
let test_empty_scope_error_handling () =
  let empty_scope_stack = [] in
  let result = lookup_symbol empty_scope_stack "任意变量" in
  check bool "空作用域栈查找返回None" true (Option.is_none result)

(** 边界条件测试 *)
let test_edge_cases () =
  let ctx = create_initial_context () in

  (* 测试空字符串符号名 *)
  let ctx_with_empty_name = add_symbol ctx "" IntType_T false in
  let empty_name_found = lookup_symbol ctx_with_empty_name.scope_stack "" in
  check bool "空字符串符号名可以添加和查找" true (Option.is_some empty_name_found);

  (* 测试中文特殊字符符号名 *)
  let special_name = "变量_with_中文_123" in
  let ctx_with_special = add_symbol ctx special_name StringType_T false in
  let special_found = lookup_symbol ctx_with_special.scope_stack special_name in
  check bool "特殊字符符号名可以添加和查找" true (Option.is_some special_found);

  (* 测试符号重定义 *)
  let ctx_with_redefined =
    ctx |> fun c ->
    add_symbol c "重定义测试" IntType_T false |> fun c -> add_symbol c "重定义测试" StringType_T true
  in
  let redefined_symbol = lookup_symbol ctx_with_redefined.scope_stack "重定义测试" in
  match redefined_symbol with
  | Some entry ->
      (* 检查符号确实存在，可能保持第一个定义 *)
      check bool "符号重定义后符号存在" true (entry.symbol_name = "重定义测试")
  | None -> failwith "重定义符号查找失败"

(** 性能相关测试 - 大量符号 *)
let test_large_symbol_table () =
  let ctx = create_initial_context () in
  let add_many_symbols ctx count =
    let rec loop ctx i =
      if i >= count then ctx
      else
        let symbol_name = Printf.sprintf "符号_%d" i in
        let new_ctx = add_symbol ctx symbol_name IntType_T false in
        loop new_ctx (i + 1)
    in
    loop ctx 0
  in

  let ctx_with_many = add_many_symbols ctx 1000 in
  let middle_symbol = lookup_symbol ctx_with_many.scope_stack "符号_500" in
  let last_symbol = lookup_symbol ctx_with_many.scope_stack "符号_999" in

  check bool "大量符号中查找中间符号" true (Option.is_some middle_symbol);
  check bool "大量符号中查找最后符号" true (Option.is_some last_symbol);

  let current_scope = List.hd ctx_with_many.scope_stack in
  let symbol_count = SymbolTable.cardinal current_scope in
  check int "符号表包含正确数量的符号" 1000 symbol_count

(** 测试套件定义 *)
let () =
  run "Semantic_context 综合测试"
    [
      ("基础符号表条目", [ test_case "创建符号表条目" `Quick test_create_symbol_entry ]);
      ("语义上下文初始化", [ test_case "创建初始上下文" `Quick test_create_initial_context ]);
      ( "作用域管理",
        [
          test_case "作用域进入和退出" `Quick test_scope_operations;
          test_case "嵌套作用域符号查找" `Quick test_nested_scope_lookup;
        ] );
      ( "符号管理",
        [
          test_case "符号添加和查找" `Quick test_symbol_operations;
          test_case "可变性标志测试" `Quick test_mutability_flag;
          test_case "复杂类型处理" `Quick test_complex_types;
        ] );
      ("类型定义管理", [ test_case "类型定义添加和查找" `Quick test_type_definition_operations ]);
      ("环境转换", [ test_case "符号表到环境转换" `Quick test_symbol_table_to_env ]);
      ( "错误处理和边界条件",
        [
          test_case "空作用域栈处理" `Quick test_empty_scope_error_handling;
          test_case "边界条件测试" `Quick test_edge_cases;
        ] );
      ("性能测试", [ test_case "大量符号处理" `Slow test_large_symbol_table ]);
    ]
