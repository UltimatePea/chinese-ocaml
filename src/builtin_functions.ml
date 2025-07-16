(** 骆言内置函数模块 - Chinese Programming Language Builtin Functions Module *)

open Value_operations

type builtin_function_table = (string * runtime_value) list
(** 内置函数表类型 *)

(** 内置函数实现 *)
let builtin_functions =
  [
    ( "打印",
      BuiltinFunctionValue
        (function
        | [ StringValue s ] ->
            Logger.print_user_output s;
            UnitValue
        | [ value ] ->
            Logger.print_user_output (value_to_string value);
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
                  let mapped =
                    List.map
                      (fun elem ->
                        match map_func with
                        | BuiltinFunctionValue f -> f [ elem ]
                        | _ -> raise (RuntimeError "高阶函数不支持用户定义函数"))
                      lst
                  in
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
    (* 文件输入输出函数 *)
    ( "读取文件",
      BuiltinFunctionValue
        (function
        | [ StringValue filename ] -> (
            try
              let ic = open_in filename in
              let content = really_input_string ic (in_channel_length ic) in
              close_in ic;
              StringValue content
            with Sys_error _ -> raise (RuntimeError ("无法读取文件: " ^ filename)))
        | _ -> raise (RuntimeError "读取文件函数期望一个文件名参数")) );
    ( "写入文件",
      BuiltinFunctionValue
        (function
        | [ StringValue filename ] ->
            (* Return a function that takes the content *)
            BuiltinFunctionValue
              (function
              | [ StringValue content ] -> (
                  try
                    let oc = open_out filename in
                    output_string oc content;
                    close_out oc;
                    UnitValue
                  with Sys_error _ -> raise (RuntimeError ("无法写入文件: " ^ filename)))
              | _ -> raise (RuntimeError "写入文件函数期望文件内容参数"))
        | _ -> raise (RuntimeError "写入文件函数期望文件名参数")) );
    ( "文件存在",
      BuiltinFunctionValue
        (function
        | [ StringValue filename ] -> BoolValue (Sys.file_exists filename)
        | _ -> raise (RuntimeError "文件存在函数期望一个文件名参数")) );
    ( "列出目录",
      BuiltinFunctionValue
        (function
        | [ StringValue dirname ] -> (
            try
              let files = Sys.readdir dirname in
              let file_list = Array.to_list files |> List.map (fun f -> StringValue f) in
              ListValue file_list
            with Sys_error _ -> raise (RuntimeError ("无法列出目录: " ^ dirname)))
        | _ -> raise (RuntimeError "列出目录函数期望一个目录名参数")) );
    ( "字符串连接",
      BuiltinFunctionValue
        (function
        | [ StringValue s1 ] ->
            BuiltinFunctionValue
              (function
              | [ StringValue s2 ] -> StringValue (s1 ^ s2)
              | _ -> raise (RuntimeError "字符串连接函数期望第二个字符串参数"))
        | _ -> raise (RuntimeError "字符串连接函数期望第一个字符串参数")) );
    ( "字符串包含",
      BuiltinFunctionValue
        (function
        | [ StringValue haystack ] ->
            BuiltinFunctionValue
              (function
              | [ StringValue needle ] ->
                  BoolValue (String.contains_from haystack 0 (String.get needle 0))
              | _ -> raise (RuntimeError "字符串包含函数期望第二个字符串参数"))
        | _ -> raise (RuntimeError "字符串包含函数期望第一个字符串参数")) );
    ( "字符串分割",
      BuiltinFunctionValue
        (function
        | [ StringValue str ] ->
            BuiltinFunctionValue
              (function
              | [ StringValue sep ] ->
                  let parts = String.split_on_char (String.get sep 0) str in
                  ListValue (List.map (fun s -> StringValue s) parts)
              | _ -> raise (RuntimeError "字符串分割函数期望分隔符参数"))
        | _ -> raise (RuntimeError "字符串分割函数期望字符串参数")) );
    ( "字符串匹配",
      BuiltinFunctionValue
        (function
        | [ StringValue str ] ->
            BuiltinFunctionValue
              (function
              | [ StringValue pattern ] ->
                  (* Simple pattern matching - check if string contains pattern *)
                  let regex = Str.regexp pattern in
                  BoolValue (Str.string_match regex str 0)
              | _ -> raise (RuntimeError "字符串匹配函数期望模式参数"))
        | _ -> raise (RuntimeError "字符串匹配函数期望字符串参数")) );
    (* 中文数字常量 *)
    ("零", BuiltinFunctionValue (function [] -> IntValue 0 | _ -> raise (RuntimeError "零不需要参数")));
    ("一", BuiltinFunctionValue (function [] -> IntValue 1 | _ -> raise (RuntimeError "一不需要参数")));
    ("二", BuiltinFunctionValue (function [] -> IntValue 2 | _ -> raise (RuntimeError "二不需要参数")));
    ("三", BuiltinFunctionValue (function [] -> IntValue 3 | _ -> raise (RuntimeError "三不需要参数")));
    ("四", BuiltinFunctionValue (function [] -> IntValue 4 | _ -> raise (RuntimeError "四不需要参数")));
    ("五", BuiltinFunctionValue (function [] -> IntValue 5 | _ -> raise (RuntimeError "五不需要参数")));
    ("六", BuiltinFunctionValue (function [] -> IntValue 6 | _ -> raise (RuntimeError "六不需要参数")));
    ("七", BuiltinFunctionValue (function [] -> IntValue 7 | _ -> raise (RuntimeError "七不需要参数")));
    ("八", BuiltinFunctionValue (function [] -> IntValue 8 | _ -> raise (RuntimeError "八不需要参数")));
    ("九", BuiltinFunctionValue (function [] -> IntValue 9 | _ -> raise (RuntimeError "九不需要参数")));
    (* 数据类型转换函数 *)
    ( "整数转字符串",
      BuiltinFunctionValue
        (function
        | [ IntValue n ] -> StringValue (string_of_int n)
        | _ -> raise (RuntimeError "整数转字符串函数期望一个整数参数")) );
    (* 文件过滤函数 *)
    ( "过滤ly文件",
      BuiltinFunctionValue
        (function
        | [ ListValue files ] ->
            let filtered =
              List.filter
                (fun file ->
                  match file with
                  | StringValue filename ->
                      String.length filename >= 3
                      && String.sub filename (String.length filename - 3) 3 = ".ly"
                  | _ -> false)
                files
            in
            ListValue filtered
        | _ -> raise (RuntimeError "过滤ly文件函数期望一个文件列表参数")) );
    (* 字符串处理函数 - 用于移除注释和字符串 *)
    ( "移除井号注释",
      BuiltinFunctionValue
        (function
        | [ StringValue line ] ->
            let index = try String.index line '#' with Not_found -> String.length line in
            StringValue (String.sub line 0 index)
        | _ -> raise (RuntimeError "移除井号注释函数期望一个字符串参数")) );
    ( "移除双斜杠注释",
      BuiltinFunctionValue
        (function
        | [ StringValue line ] ->
            let rec find_index i =
              if i >= String.length line - 1 then String.length line
              else if String.get line i = '/' && String.get line (i + 1) = '/' then i
              else find_index (i + 1)
            in
            let index = find_index 0 in
            StringValue (String.sub line 0 index)
        | _ -> raise (RuntimeError "移除双斜杠注释函数期望一个字符串参数")) );
    ( "移除块注释",
      BuiltinFunctionValue
        (function
        | [ StringValue line ] ->
            (* 简单实现：移除块注释 *)
            let result = ref "" in
            let i = ref 0 in
            let len = String.length line in
            while !i < len do
              if !i < len - 1 && String.get line !i = '(' && String.get line (!i + 1) = '*' then (
                (* 跳过到结束符 *)
                i := !i + 2;
                let rec skip () =
                  if !i < len - 1 && String.get line !i = '*' && String.get line (!i + 1) = ')' then
                    i := !i + 2
                  else if !i < len then (
                    i := !i + 1;
                    skip ())
                in
                skip ())
              else (
                result := !result ^ String.make 1 (String.get line !i);
                i := !i + 1)
            done;
            StringValue !result
        | _ -> raise (RuntimeError "移除块注释函数期望一个字符串参数")) );
    ( "移除骆言字符串",
      BuiltinFunctionValue
        (function
        | [ StringValue line ] ->
            (* 移除骆言字符串内容 *)
            let result = ref "" in
            let i = ref 0 in
            let len = String.length line in
            while !i < len do
              (* 检查是否为骆言字符串开始标记 *)
              if
                !i + 2 < len
                && String.get line !i = '\xe3'
                && String.get line (!i + 1) = '\x80'
                && String.get line (!i + 2) = '\x8e'
              then (
                (* 跳过开始标记 *)
                i := !i + 3;
                (* 查找结束标记 *)
                let rec skip () =
                  if
                    !i + 2 < len
                    && String.get line !i = '\xe3'
                    && String.get line (!i + 1) = '\x80'
                    && String.get line (!i + 2) = '\x8f'
                  then i := !i + 3
                  else if !i < len then (
                    i := !i + 1;
                    skip ())
                in
                skip ())
              else (
                result := !result ^ String.make 1 (String.get line !i);
                i := !i + 1)
            done;
            StringValue !result
        | _ -> raise (RuntimeError "移除骆言字符串函数期望一个字符串参数")) );
    ( "移除英文字符串",
      BuiltinFunctionValue
        (function
        | [ StringValue line ] ->
            (* 移除 "..." 和 '...' 字符串 *)
            let result = ref "" in
            let i = ref 0 in
            let len = String.length line in
            while !i < len do
              let c = String.get line !i in
              if c = '"' || c = '\'' then (
                (* 跳过到匹配的引号 *)
                let quote = c in
                i := !i + 1;
                let rec skip () =
                  if !i < len && String.get line !i = quote then i := !i + 1
                  else if !i < len then (
                    i := !i + 1;
                    skip ())
                in
                skip ())
              else (
                result := !result ^ String.make 1 c;
                i := !i + 1)
            done;
            StringValue !result
        | _ -> raise (RuntimeError "移除英文字符串函数期望一个字符串参数")) );
    (* 数组操作函数 *)
    ( "创建数组",
      BuiltinFunctionValue
        (function
        | [ IntValue size; initial_value ] ->
            if size < 0 then raise (RuntimeError "数组大小不能为负数")
            else
              let array = Array.make size initial_value in
              ArrayValue array
        | _ -> raise (RuntimeError "创建数组函数期望两个参数：数组大小和初始值")) );
    ( "数组长度",
      BuiltinFunctionValue
        (function
        | [ ArrayValue arr ] -> IntValue (Array.length arr)
        | _ -> raise (RuntimeError "数组长度函数期望一个数组参数")) );
    ( "复制数组",
      BuiltinFunctionValue
        (function
        | [ ArrayValue arr ] -> ArrayValue (Array.copy arr)
        | _ -> raise (RuntimeError "复制数组函数期望一个数组参数")) );
  ]

(** 调用内置函数 *)
let call_builtin_function name args =
  try
    let _, func_value = List.find (fun (n, _) -> n = name) builtin_functions in
    match func_value with BuiltinFunctionValue f -> f args | _ -> raise (RuntimeError "只支持内置函数调用")
  with Not_found -> raise (RuntimeError ("未知的内置函数: " ^ name))

(** 检查是否为内置函数 *)
let is_builtin_function name = List.exists (fun (n, _) -> n = name) builtin_functions

(** 获取所有内置函数名称列表 *)
let get_builtin_function_names () = List.map fst builtin_functions
