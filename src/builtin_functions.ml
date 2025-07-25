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

(** 性能优化：使用哈希表缓存内置函数，从O(n)线性搜索优化至O(1)常数时间查找 *)
let builtin_functions_hash = lazy (
  let hash_table = Hashtbl.create (List.length builtin_functions) in
  List.iter (fun (name, value) -> Hashtbl.replace hash_table name value) builtin_functions;
  hash_table
)

(** 调用内置函数 - 性能优化版本使用哈希表查找 *)
let call_builtin_function name args =
  try
    let func_value = Hashtbl.find (Lazy.force builtin_functions_hash) name in
    match func_value with BuiltinFunctionValue f -> f args | _ -> raise (RuntimeError "只支持内置函数调用")
  with Not_found -> raise (RuntimeError ("未知的内置函数: " ^ name))

(** 检查是否为内置函数 - 性能优化版本使用哈希表查找 *)
let is_builtin_function name = Hashtbl.mem (Lazy.force builtin_functions_hash) name

(** 获取所有内置函数名称列表 *)
let get_builtin_function_names () = List.map fst builtin_functions
