(** 骆言内置函数模块 - Chinese Programming Language Builtin Functions Module - 模块化重构版本 *)

open Value_operations

type builtin_function_table = (string * runtime_value) list
(** 内置函数表类型 *)

(** 重构后的模块化内置函数实现 *)
let builtin_functions =
  List.concat
    [
      Builtin_io.io_functions;
      Builtin_collections.collection_functions;
      Builtin_math.math_functions;
      Builtin_string.string_functions;
      Builtin_array.array_functions;
      Builtin_types.type_conversion_functions;
      Builtin_utils.utility_functions;
      Builtin_constants.chinese_number_constants;
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

(** 获取内置函数数量统计 *)
let[@warning "-32"] get_builtin_function_stats () =
  let io_count = List.length Builtin_io.io_functions in
  let collection_count = List.length Builtin_collections.collection_functions in
  let math_count = List.length Builtin_math.math_functions in
  let string_count = List.length Builtin_string.string_functions in
  let array_count = List.length Builtin_array.array_functions in
  let type_count = List.length Builtin_types.type_conversion_functions in
  let util_count = List.length Builtin_utils.utility_functions in
  let const_count = List.length Builtin_constants.chinese_number_constants in
  Printf.sprintf
    "内置函数统计: I/O(%d), 集合(%d), 数学(%d), 字符串(%d), 数组(%d), 类型转换(%d), 工具(%d), 常量(%d), 总计(%d)" io_count
    collection_count math_count string_count array_count type_count util_count const_count
    (List.length builtin_functions)
