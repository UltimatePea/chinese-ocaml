(** 骆言内置函数模块 - Chinese Programming Language Builtin Functions Module *)

open Value_operations

(** 内置函数表类型 *)
type builtin_function_table = (string * runtime_value) list


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
                        match pred_func with
                        | BuiltinFunctionValue f -> (
                            match f [ elem ] with
                            | BoolValue b -> b
                            | _ -> raise (RuntimeError "过滤谓词必须返回布尔值"))
                        | _ -> raise (RuntimeError "高阶函数不支持用户定义函数"))
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
                  let mapped = List.map (fun elem -> 
                    match map_func with
                    | BuiltinFunctionValue f -> f [ elem ]
                    | _ -> raise (RuntimeError "高阶函数不支持用户定义函数")) lst in
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
                          (fun acc elem -> 
                            match fold_func with
                            | BuiltinFunctionValue f -> f [ acc; elem ]
                            | _ -> raise (RuntimeError "高阶函数不支持用户定义函数"))
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
    ("零", BuiltinFunctionValue (function | [] -> IntValue 0 | _ -> raise (RuntimeError "零不需要参数")));
    ("一", BuiltinFunctionValue (function | [] -> IntValue 1 | _ -> raise (RuntimeError "一不需要参数")));
    ("二", BuiltinFunctionValue (function | [] -> IntValue 2 | _ -> raise (RuntimeError "二不需要参数")));
    ("三", BuiltinFunctionValue (function | [] -> IntValue 3 | _ -> raise (RuntimeError "三不需要参数")));
    ("四", BuiltinFunctionValue (function | [] -> IntValue 4 | _ -> raise (RuntimeError "四不需要参数")));
    ("五", BuiltinFunctionValue (function | [] -> IntValue 5 | _ -> raise (RuntimeError "五不需要参数")));
    ("六", BuiltinFunctionValue (function | [] -> IntValue 6 | _ -> raise (RuntimeError "六不需要参数")));
    ("七", BuiltinFunctionValue (function | [] -> IntValue 7 | _ -> raise (RuntimeError "七不需要参数")));
    ("八", BuiltinFunctionValue (function | [] -> IntValue 8 | _ -> raise (RuntimeError "八不需要参数")));
    ("九", BuiltinFunctionValue (function | [] -> IntValue 9 | _ -> raise (RuntimeError "九不需要参数")));
  ]

(** 调用内置函数 *)
let call_builtin_function name args =
  try
    let (_, func_value) = List.find (fun (n, _) -> n = name) builtin_functions in
    match func_value with
    | BuiltinFunctionValue f -> f args
    | _ -> raise (RuntimeError "只支持内置函数调用")
  with
  | Not_found -> raise (RuntimeError ("未知的内置函数: " ^ name))

(** 检查是否为内置函数 *)
let is_builtin_function name =
  List.exists (fun (n, _) -> n = name) builtin_functions

(** 获取所有内置函数名称列表 *)
let get_builtin_function_names () =
  List.map fst builtin_functions