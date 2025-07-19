(** 参数验证DSL模块 - 消除内置函数中重复的参数验证模式 *)

open Value_operations
open String_processing_utils.ErrorMessageTemplates

(** 通用验证器类型 *)
type 'a validator = runtime_value -> 'a

(** 错误处理辅助函数 *)
let runtime_error msg = raise (RuntimeError msg)

(** 创建类型验证器的通用函数 *)
let create_type_validator (type_name: string) (extractor: runtime_value -> 'a option) : 'a validator =
  fun value ->
    match extractor value with
    | Some result -> result
    | None -> runtime_error (function_param_type_error "" type_name)

(** 基本类型提取器 - 重构为统一模式 *)
let extract_string = function StringValue s -> Some s | _ -> None
let extract_int = function IntValue i -> Some i | _ -> None  
let extract_float = function FloatValue f -> Some f | _ -> None
let extract_bool = function BoolValue b -> Some b | _ -> None
let extract_list = function ListValue lst -> Some lst | _ -> None
let extract_array = function ArrayValue arr -> Some arr | _ -> None
let extract_builtin_function = function BuiltinFunctionValue f -> Some f | _ -> None

(** 复合类型提取器 *)
let extract_number = function 
  | IntValue _ | FloatValue _ as v -> Some v 
  | _ -> None

let extract_string_or_list = function 
  | StringValue _ | ListValue _ as v -> Some v 
  | _ -> None

let extract_nonempty_list = function 
  | ListValue [] -> None
  | ListValue lst -> Some lst 
  | _ -> None

(** 预定义的类型验证器 *)
let validate_string = create_type_validator "字符串" extract_string
let validate_int = create_type_validator "整数" extract_int
let validate_float = create_type_validator "浮点数" extract_float
let validate_bool = create_type_validator "布尔值" extract_bool
let validate_list = create_type_validator "列表" extract_list
let validate_array = create_type_validator "数组" extract_array
let validate_builtin_function = create_type_validator "内置函数" extract_builtin_function
let validate_number = create_type_validator "数值" extract_number
let validate_string_or_list = create_type_validator "字符串或列表" extract_string_or_list

(** 特殊的非空列表验证器 *)
let validate_nonempty_list value =
  match extract_nonempty_list value with
  | Some lst -> lst
  | None -> 
    match value with
    | ListValue [] -> runtime_error "不能用于空列表"
    | _ -> runtime_error (function_param_type_error "" "非空列表")

(** 带函数名的验证器包装器 *)
let with_function_name (validator: 'a validator) (function_name: string) : 'a validator =
  fun value ->
    try validator value
    with RuntimeError _ ->
      (* 简化错误处理，直接返回通用错误消息 *)
      runtime_error (function_param_type_error function_name "参数类型错误")

(** 参数数量验证 *)
let validate_single (validator: 'a validator) function_name args =
  let arg = match args with 
    | [arg] -> arg 
    | _ -> runtime_error (function_single_param_error function_name) 
  in
  let wrapped_validator = with_function_name validator function_name in
  wrapped_validator arg

let validate_double (v1: 'a validator) (v2: 'b validator) function_name args =
  let arg1, arg2 = match args with
    | [arg1; arg2] -> (arg1, arg2)
    | _ -> runtime_error (function_double_param_error function_name)
  in
  let wrapped_v1 = with_function_name v1 function_name in
  let wrapped_v2 = with_function_name v2 function_name in
  (wrapped_v1 arg1, wrapped_v2 arg2)

let validate_triple (v1: 'a validator) (v2: 'b validator) (v3: 'c validator) function_name args =
  let arg1, arg2, arg3 = match args with
    | [arg1; arg2; arg3] -> (arg1, arg2, arg3)
    | _ -> runtime_error ("期望三个参数")
  in
  let wrapped_v1 = with_function_name v1 function_name in
  let wrapped_v2 = with_function_name v2 function_name in  
  let wrapped_v3 = with_function_name v3 function_name in
  (wrapped_v1 arg1, wrapped_v2 arg2, wrapped_v3 arg3)

let validate_no_args function_name args =
  match args with 
  | [] -> () 
  | _ -> runtime_error (function_no_param_error function_name)

(** 创建便捷的验证函数 *)
let expect_string = validate_string
let expect_int = validate_int  
let expect_float = validate_float
let expect_bool = validate_bool
let expect_list = validate_list
let expect_array = validate_array
let expect_builtin_function = validate_builtin_function
let expect_number = validate_number
let expect_string_or_list = validate_string_or_list
let expect_nonempty_list = validate_nonempty_list

(** 非负数验证器 *)
let validate_non_negative value =
  match extract_int value with
  | Some i when i >= 0 -> i
  | Some i -> runtime_error (Printf.sprintf "期望非负整数，获得: %d" i)
  | None -> runtime_error (function_param_type_error "" "非负整数")

let expect_non_negative = validate_non_negative