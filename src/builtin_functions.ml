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
