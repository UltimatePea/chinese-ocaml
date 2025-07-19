(** 骆言内置集合操作函数模块 - Chinese Programming Language Builtin Collection Functions *)

open Value_operations
open Builtin_error

(** 长度函数 - 使用公共工具函数 *)
let length_function args =
  let value = check_single_arg args "长度" in
  Builtin_shared_utils.get_length_value value

(** 连接函数 *)
let concat_function args =
  let lst1 = expect_list (check_single_arg args "连接") "连接" in
  BuiltinFunctionValue
    (fun lst2_args ->
      let lst2 = expect_list (check_single_arg lst2_args "连接") "连接" in
      ListValue (lst1 @ lst2))

(** 过滤函数 *)
let filter_function args =
  let pred_func = expect_builtin_function (check_single_arg args "过滤") "过滤" in
  BuiltinFunctionValue
    (fun lst_args ->
      let lst = expect_list (check_single_arg lst_args "过滤") "过滤" in
      let filtered =
        List.filter
          (fun elem ->
            match pred_func [ elem ] with BoolValue b -> b | _ -> runtime_error "过滤谓词必须返回布尔值")
          lst
      in
      ListValue filtered)

(** 映射函数 *)
let map_function args =
  let map_func = expect_builtin_function (check_single_arg args "映射") "映射" in
  BuiltinFunctionValue
    (fun lst_args ->
      let lst = expect_list (check_single_arg lst_args "映射") "映射" in
      let mapped = List.map (fun elem -> map_func [ elem ]) lst in
      ListValue mapped)

(** 折叠函数 *)
let fold_function args =
  let fold_func = expect_builtin_function (check_single_arg args "折叠") "折叠" in
  BuiltinFunctionValue
    (fun init_args ->
      let initial_value = check_single_arg init_args "折叠初始值" in
      BuiltinFunctionValue
        (fun lst_args ->
          let lst = expect_list (check_single_arg lst_args "折叠") "折叠" in
          List.fold_left (fun acc elem -> fold_func [ acc; elem ]) initial_value lst))

(** 排序函数 *)
let sort_function args =
  let lst = expect_list (check_single_arg args "排序") "排序" in
  let sorted =
    List.sort
      (fun a b ->
        match (a, b) with
        | IntValue i1, IntValue i2 -> compare i1 i2
        | FloatValue f1, FloatValue f2 -> compare f1 f2
        | StringValue s1, StringValue s2 -> compare s1 s2
        | _ -> 0)
      lst
  in
  ListValue sorted

(** 反转函数 - 使用公共工具函数 *)
let reverse_function args =
  let value = check_single_arg args "反转" in
  match value with
  | ListValue lst -> ListValue (List.rev lst)
  | StringValue s -> StringValue (Builtin_shared_utils.reverse_string s)
  | _ -> runtime_error "反转函数期望一个列表或字符串参数"

(** 包含函数 *)
let contains_function args =
  let search_val = check_single_arg args "包含" in
  BuiltinFunctionValue
    (fun collection_args ->
      let collection = check_single_arg collection_args "包含" in
      match collection with
      | ListValue lst -> BoolValue (List.mem search_val lst)
      | StringValue str -> (
          match search_val with
          | StringValue substr -> BoolValue (String.contains str (String.get substr 0))
          | _ -> BoolValue false)
      | _ -> runtime_error "包含函数期望一个列表或字符串参数")

(** 集合函数表 *)
let collection_functions =
  [
    ("长度", BuiltinFunctionValue length_function);
    ("连接", BuiltinFunctionValue concat_function);
    ("过滤", BuiltinFunctionValue filter_function);
    ("映射", BuiltinFunctionValue map_function);
    ("折叠", BuiltinFunctionValue fold_function);
    ("排序", BuiltinFunctionValue sort_function);
    ("反转", BuiltinFunctionValue reverse_function);
    ("包含", BuiltinFunctionValue contains_function);
  ]
