(** 骆言解释器二元运算模块 - Chinese Programming Language Interpreter Binary Operations *)

open Ast
open Value_operations
open Error_recovery
open Unified_errors
open Unified_formatter

(** 通用运算查找辅助函数 *)
let find_arithmetic_operation operations op =
  List.find_opt (fun (op_type, _) -> op_type = op) operations

(** 执行整数算术运算 - 重构：消除重复模式 *)
let execute_int_arithmetic_op op a b =
  let zero_check =
    match op with
    | Div -> Some (( = ) 0, ErrorMessages.invalid_operation "除零")
    | Mod -> Some (( = ) 0, ErrorMessages.invalid_operation "取模零")
    | _ -> None
  in
  let int_ops = [ (Add, ( + )); (Sub, ( - )); (Mul, ( * )); (Div, ( / )); (Mod, ( mod )) ] in
  match zero_check with
  | Some (check_func, error_msg) when check_func b -> Error (RuntimeError error_msg)
  | _ -> (
      match find_arithmetic_operation int_ops op with
      | Some (_, operation) -> Ok (IntValue (operation a b))
      | None -> Error (RuntimeError (ErrorMessages.invalid_operation "非算术运算")))

(** 执行浮点算术运算 - 重构：消除重复模式 *)
let execute_float_arithmetic_op op a b =
  let float_ops = [ (Add, ( +. )); (Sub, ( -. )); (Mul, ( *. )); (Div, ( /. )) ] in
  match find_arithmetic_operation float_ops op with
  | Some (_, operation) -> Ok (FloatValue (operation a b))
  | None -> Error (RuntimeError (ErrorMessages.invalid_operation "非算术运算"))

(** 执行字符串运算 - 重构：消除重复模式 *)
let execute_string_op op a b =
  let string_ops = [ (Add, ( ^ )); (Concat, ( ^ )) ] in
  match find_arithmetic_operation string_ops op with
  | Some (_, operation) -> Ok (StringValue (operation a b))
  | None -> Error (RuntimeError (ErrorMessages.invalid_operation "非字符串运算"))

(** 执行类型化比较运算 - 重构：消除重复模式 *)
let execute_typed_comparison op left_val right_val =
  let compare_values comp_func a b = Ok (BoolValue (comp_func a b)) in
  match (left_val, right_val) with
  | IntValue a, IntValue b -> (
      match op with
      | Lt -> compare_values ( < ) a b
      | Le -> compare_values ( <= ) a b
      | Gt -> compare_values ( > ) a b
      | Ge -> compare_values ( >= ) a b
      | _ -> Error (RuntimeError (ErrorMessages.invalid_operation "非类型化比较运算")))
  | FloatValue a, FloatValue b -> (
      match op with
      | Lt -> compare_values ( < ) a b
      | Le -> compare_values ( <= ) a b
      | Gt -> compare_values ( > ) a b
      | Ge -> compare_values ( >= ) a b
      | _ -> Error (RuntimeError (ErrorMessages.invalid_operation "非类型化比较运算")))
  | _ -> Error (RuntimeError (ErrorMessages.invalid_operation "不支持的比较类型"))

(** 执行比较运算 - 重构：统一相等性和类型化比较 *)
let execute_comparison_op op left_val right_val =
  match op with
  | Eq -> Ok (BoolValue (left_val = right_val))
  | Neq -> Ok (BoolValue (left_val <> right_val))
  | Lt | Le | Gt | Ge -> execute_typed_comparison op left_val right_val
  | _ -> Error (RuntimeError (ErrorMessages.invalid_operation "非比较运算"))

(** 执行逻辑运算 *)
let execute_logical_op op a b =
  match op with
  | And -> Ok (BoolValue (value_to_bool a && value_to_bool b))
  | Or -> Ok (BoolValue (value_to_bool a || value_to_bool b))
  | _ -> Error (RuntimeError (ErrorMessages.invalid_operation "非逻辑运算"))

(** 尝试算术运算类型转换 - 重构：减少嵌套层次 *)
let try_arithmetic_conversion op left_val right_val =
  (* 首先尝试整数转换 *)
  match (Value_operations.try_to_int left_val, Value_operations.try_to_int right_val) with
  | Some a, Some b -> execute_int_arithmetic_op op a b
  | _ -> (
      (* 其次尝试浮点转换 *)
      match (Value_operations.try_to_float left_val, Value_operations.try_to_float right_val) with
      | Some a, Some b -> execute_float_arithmetic_op op a b
      | _ ->
          (* 最后为加法尝试字符串连接 *)
          if op = Add then
            match
              (Value_operations.try_to_string left_val, Value_operations.try_to_string right_val)
            with
            | Some a, Some b -> execute_string_op op a b
            | _ ->
                Error
                  (RuntimeError
                     (ErrorMessages.invalid_operation
                        ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val)))
          else
            Error
              (RuntimeError
                 (ErrorMessages.invalid_operation
                    ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))))

(** 尝试比较运算类型转换 - 重构：提取独立函数 *)
let try_comparison_conversion op left_val right_val =
  match (Value_operations.try_to_float left_val, Value_operations.try_to_float right_val) with
  | Some a, Some b -> execute_comparison_op op (FloatValue a) (FloatValue b)
  | _ ->
      Error
        (RuntimeError
           (ErrorMessages.invalid_operation
              ("不支持的比较运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val)))

(** 尝试类型转换并执行运算 - 重构：消除深度嵌套 *)
let try_with_conversion op left_val right_val =
  let config = Error_recovery.get_recovery_config () in
  if not (config.enabled && config.type_conversion) then
    Error
      (RuntimeError
         (ErrorMessages.invalid_operation
            ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val)))
  else
    match op with
    | Add | Sub | Mul | Div | Mod -> try_arithmetic_conversion op left_val right_val
    | Lt | Le | Gt | Ge -> try_comparison_conversion op left_val right_val
    | _ ->
        Error
          (RuntimeError
             (ErrorMessages.invalid_operation
                ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val)))

(** 二元运算实现 - 重构：分离操作类型，提升可维护性 *)
let execute_binary_op_internal op left_val right_val =
  match (op, left_val, right_val) with
  (* 直接匹配的算术运算 *)
  | (Add | Sub | Mul | Div | Mod), IntValue a, IntValue b -> execute_int_arithmetic_op op a b
  | (Add | Sub | Mul | Div), FloatValue a, FloatValue b -> execute_float_arithmetic_op op a b
  (* 字符串运算 *)
  | (Add | Concat), StringValue a, StringValue b -> execute_string_op op a b
  (* 比较运算 *)
  | (Eq | Neq | Lt | Le | Gt | Ge), _, _ -> execute_comparison_op op left_val right_val
  (* 逻辑运算 *)
  | (And | Or), _, _ -> execute_logical_op op left_val right_val
  (* 需要类型转换的情况 *)
  | _ -> try_with_conversion op left_val right_val

(** 二元运算执行 - 向后兼容接口 *)
let execute_binary_op op left_val right_val =
  match execute_binary_op_internal op left_val right_val with
  | Ok result -> result
  | Error error -> raise (unified_error_to_exception error)

(** 一元运算实现 - 内部版本 *)
let execute_unary_op_internal op value =
  match (op, value) with
  | Neg, IntValue n -> Ok (IntValue (-n))
  | Neg, FloatValue f -> Ok (FloatValue (-.f))
  | Not, v -> Ok (BoolValue (not (value_to_bool v)))
  | _ ->
      Error (RuntimeError (ErrorMessages.invalid_operation ("不支持的一元运算: " ^ value_to_string value)))

(** 一元运算实现 - 向后兼容接口 *)
let execute_unary_op op value =
  match execute_unary_op_internal op value with
  | Ok result -> result
  | Error error -> raise (unified_error_to_exception error)
