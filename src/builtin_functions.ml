(** 骆言内置函数模块 - Chinese Programming Language Builtin Functions Module *)

open Value_operations

(** 内置函数表类型 *)
type builtin_function_table = (string * (runtime_value list -> runtime_value)) list

(** 递归声明调用函数，用于支持高阶函数 *)
let call_function func_val arg_vals =
  match func_val with
  | BuiltinFunctionValue f -> f arg_vals
  | FunctionValue (param_list, body, closure_env) ->
      let param_count = List.length param_list in
      let arg_count = List.length arg_vals in
      
      if param_count = arg_count then
        (* 参数数量匹配，正常执行 *)
        let new_env =
          List.fold_left2
            (fun acc_env param_name arg_val -> bind_var acc_env param_name arg_val)
            closure_env param_list arg_vals
        in
        (* 这里需要调用解释器的eval_expr函数，暂时抛出异常 *)
        raise (RuntimeError "内置函数模块中不能直接执行用户函数")
      else 
        raise (RuntimeError "函数参数数量不匹配")
  | _ -> raise (RuntimeError "尝试调用非函数值")

(** 内置函数实现 *)
let builtin_functions =
  [
    ( "打印",
      BuiltinFunctionValue
        (function
        | [ StringValue s ] ->
            print_endline s;
            UnitValue
        | [ value ] ->
            print_endline (value_to_string value);
            UnitValue
        | _ -> raise (RuntimeError "打印函数期望一个参数")) );
    ( "读取",
      BuiltinFunctionValue
        (function
        | [ UnitValue ] -> StringValue (read_line ())
        | [] -> StringValue (read_line ())
        | _ -> raise (RuntimeError "读取函数不需要参数")) );
    ( "长度",
      BuiltinFunctionValue
        (function
        | [ StringValue s ] -> IntValue (String.length s)
        | [ ListValue lst ] -> IntValue (List.length lst)
        | _ -> raise (RuntimeError "长度函数期望一个字符串或列表参数")) );
    ( "连接",
      BuiltinFunctionValue
        (function
        | [ ListValue lst1 ] ->
            (* Return a function that takes the second list *)
            BuiltinFunctionValue
              (function
              | [ ListValue lst2 ] -> ListValue (lst1 @ lst2)
              | _ -> raise (RuntimeError "连接函数期望第二个列表参数"))
        | _ -> raise (RuntimeError "连接函数期望第一个列表参数")) );
    ( "过滤",
      BuiltinFunctionValue
        (function
        | [ pred_func ] ->
            (* Return a function that takes a list *)
            BuiltinFunctionValue
              (function
              | [ ListValue lst ] ->
                  let filtered =
                    List.filter
                      (fun elem ->
                        match call_function pred_func [ elem ] with
                        | BoolValue b -> b
                        | _ -> raise (RuntimeError "过滤谓词必须返回布尔值"))
                      lst
                  in
                  ListValue filtered
              | _ -> raise (RuntimeError "过滤函数期望一个列表参数"))
        | _ -> raise (RuntimeError "过滤函数期望一个谓词函数")) );
    (* AI友好的数据处理函数 *)
    ( "映射",
      BuiltinFunctionValue
        (function
        | [ map_func ] ->
            BuiltinFunctionValue
              (function
              | [ ListValue lst ] ->
                  let mapped = List.map (fun elem -> call_function map_func [ elem ]) lst in
                  ListValue mapped
              | _ -> raise (RuntimeError "映射函数期望一个列表参数"))
        | _ -> raise (RuntimeError "映射函数期望一个映射函数")) );
    ( "折叠",
      BuiltinFunctionValue
        (function
        | [ fold_func ] ->
            BuiltinFunctionValue
              (function
              | [ initial_value ] ->
                  BuiltinFunctionValue
                    (function
                    | [ ListValue lst ] ->
                        List.fold_left
                          (fun acc elem -> call_function fold_func [ acc; elem ])
                          initial_value lst
                    | _ -> raise (RuntimeError "折叠函数期望一个列表参数"))
              | _ -> raise (RuntimeError "折叠函数期望一个初始值"))
        | _ -> raise (RuntimeError "折叠函数期望一个折叠函数")) );
    ( "范围",
      BuiltinFunctionValue
        (function
        | [ IntValue start; IntValue end_val ] ->
            let rec range s e acc =
              if s > e then ListValue (List.rev acc) else range (s + 1) e (IntValue s :: acc)
            in
            range start end_val []
        | _ -> raise (RuntimeError "范围函数期望两个整数参数（起始和结束）")) );
    ( "排序",
      BuiltinFunctionValue
        (function
        | [ ListValue lst ] ->
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
        | _ -> raise (RuntimeError "排序函数期望一个列表参数")) );
    ( "反转",
      BuiltinFunctionValue
        (function
        | [ ListValue lst ] -> ListValue (List.rev lst)
        | [ StringValue s ] ->
            let chars = List.of_seq (String.to_seq s) in
            let reversed_chars = List.rev chars in
            StringValue (String.of_seq (List.to_seq reversed_chars))
        | _ -> raise (RuntimeError "反转函数期望一个列表或字符串参数")) );
    ( "包含",
      BuiltinFunctionValue
        (function
        | [ search_val ] ->
            BuiltinFunctionValue
              (function
              | [ ListValue lst ] -> BoolValue (List.mem search_val lst)
              | [ StringValue str ] -> (
                  match search_val with
                  | StringValue substr -> BoolValue (String.contains str (String.get substr 0))
                  | _ -> BoolValue false)
              | _ -> raise (RuntimeError "包含函数期望一个列表或字符串参数"))
        | _ -> raise (RuntimeError "包含函数期望一个搜索值")) );
    ( "求和",
      BuiltinFunctionValue
        (function
        | [ ListValue lst ] ->
            let sum =
              List.fold_left
                (fun acc elem ->
                  match (acc, elem) with
                  | IntValue a, IntValue b -> IntValue (a + b)
                  | FloatValue a, FloatValue b -> FloatValue (a +. b)
                  | IntValue a, FloatValue b -> FloatValue (float_of_int a +. b)
                  | FloatValue a, IntValue b -> FloatValue (a +. float_of_int b)
                  | _ -> raise (RuntimeError "求和函数只能用于数字列表"))
                (IntValue 0) lst
            in
            sum
        | _ -> raise (RuntimeError "求和函数期望一个数字列表参数")) );
    ( "最大值",
      BuiltinFunctionValue
        (function
        | [ ListValue lst ] -> (
            match lst with
            | [] -> raise (RuntimeError "不能对空列表求最大值")
            | first :: rest ->
                List.fold_left
                  (fun acc elem ->
                    match (acc, elem) with
                    | IntValue a, IntValue b -> IntValue (max a b)
                    | FloatValue a, FloatValue b -> FloatValue (max a b)
                    | IntValue a, FloatValue b -> FloatValue (max (float_of_int a) b)
                    | FloatValue a, IntValue b -> FloatValue (max a (float_of_int b))
                    | _ -> raise (RuntimeError "最大值函数只能用于数字列表"))
                  first rest)
        | _ -> raise (RuntimeError "最大值函数期望一个非空数字列表参数")) );
    ( "最小值",
      BuiltinFunctionValue
        (function
        | [ ListValue lst ] -> (
            match lst with
            | [] -> raise (RuntimeError "不能对空列表求最小值")
            | first :: rest ->
                List.fold_left
                  (fun acc elem ->
                    match (acc, elem) with
                    | IntValue a, IntValue b -> IntValue (min a b)
                    | FloatValue a, FloatValue b -> FloatValue (min a b)
                    | IntValue a, FloatValue b -> FloatValue (min (float_of_int a) b)
                    | FloatValue a, IntValue b -> FloatValue (min a (float_of_int b))
                    | _ -> raise (RuntimeError "最小值函数只能用于数字列表"))
                  first rest)
        | _ -> raise (RuntimeError "最小值函数期望一个非空数字列表参数")) );
    (* 中文数字常量 *)
    ("零", IntValue 0);
    ("一", IntValue 1);
    ("二", IntValue 2);
    ("三", IntValue 3);
    ("四", IntValue 4);
    ("五", IntValue 5);
    ("六", IntValue 6);
    ("七", IntValue 7);
    ("八", IntValue 8);
    ("九", IntValue 9);
  ]

(** 调用内置函数 *)
let call_builtin_function name args =
  try
    let (_, func_value) = List.find (fun (n, _) -> n = name) builtin_functions in
    call_function func_value args
  with
  | Not_found -> raise (RuntimeError ("未知的内置函数: " ^ name))

(** 检查是否为内置函数 *)
let is_builtin_function name =
  List.exists (fun (n, _) -> n = name) builtin_functions

(** 获取所有内置函数名称列表 *)
let get_builtin_function_names () =
  List.map fst builtin_functions