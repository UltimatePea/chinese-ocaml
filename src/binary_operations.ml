(** 骆言解释器二元运算模块 - Chinese Programming Language Interpreter Binary Operations *)

open Ast
open Value_operations
open Error_recovery
open Unified_errors

(** 执行整数算术运算 *)
let execute_int_arithmetic_op op a b =
  match op with
  | Add -> Ok (IntValue (a + b))
  | Sub -> Ok (IntValue (a - b))
  | Mul -> Ok (IntValue (a * b))
  | Div -> if b = 0 then Error (RuntimeError "除零错误") else Ok (IntValue (a / b))
  | Mod -> if b = 0 then Error (RuntimeError "取模零错误") else Ok (IntValue (a mod b))
  | _ -> Error (RuntimeError "非算术运算")

(** 执行浮点算术运算 *)
let execute_float_arithmetic_op op a b =
  match op with
  | Add -> Ok (FloatValue (a +. b))
  | Sub -> Ok (FloatValue (a -. b))
  | Mul -> Ok (FloatValue (a *. b))
  | Div -> Ok (FloatValue (a /. b))
  | _ -> Error (RuntimeError "非算术运算")

(** 执行字符串运算 *)
let execute_string_op op a b =
  match op with
  | Add | Concat -> Ok (StringValue (a ^ b))
  | _ -> Error (RuntimeError "非字符串运算")

(** 执行比较运算 *)
let execute_comparison_op op left_val right_val =
  match op with
  | Eq -> Ok (BoolValue (left_val = right_val))
  | Neq -> Ok (BoolValue (left_val <> right_val))
  | Lt -> (
      match (left_val, right_val) with
      | IntValue a, IntValue b -> Ok (BoolValue (a < b))
      | FloatValue a, FloatValue b -> Ok (BoolValue (a < b))
      | _ -> Error (RuntimeError "不支持的比较类型"))
  | Le -> (
      match (left_val, right_val) with
      | IntValue a, IntValue b -> Ok (BoolValue (a <= b))
      | FloatValue a, FloatValue b -> Ok (BoolValue (a <= b))
      | _ -> Error (RuntimeError "不支持的比较类型"))
  | Gt -> (
      match (left_val, right_val) with
      | IntValue a, IntValue b -> Ok (BoolValue (a > b))
      | FloatValue a, FloatValue b -> Ok (BoolValue (a > b))
      | _ -> Error (RuntimeError "不支持的比较类型"))
  | Ge -> (
      match (left_val, right_val) with
      | IntValue a, IntValue b -> Ok (BoolValue (a >= b))
      | FloatValue a, FloatValue b -> Ok (BoolValue (a >= b))
      | _ -> Error (RuntimeError "不支持的比较类型"))
  | _ -> Error (RuntimeError "非比较运算")

(** 执行逻辑运算 *)
let execute_logical_op op a b =
  match op with
  | And -> Ok (BoolValue (value_to_bool a && value_to_bool b))
  | Or -> Ok (BoolValue (value_to_bool a || value_to_bool b))
  | _ -> Error (RuntimeError "非逻辑运算")

(** 尝试类型转换并执行运算 *)
let try_with_conversion op left_val right_val =
  let config = Error_recovery.get_recovery_config () in
  if not (config.enabled && config.type_conversion) then
    Error (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))
  else
    match op with
    | Add | Sub | Mul | Div | Mod -> (
        (* 尝试整数转换 *)
        match (Value_operations.try_to_int left_val, Value_operations.try_to_int right_val) with
        | Some a, Some b -> execute_int_arithmetic_op op a b
        | _ -> (
            (* 尝试浮点转换 *)
            match (Value_operations.try_to_float left_val, Value_operations.try_to_float right_val) with
            | Some a, Some b -> execute_float_arithmetic_op op a b
            | _ ->
                (* 加法尝试字符串连接 *)
                if op = Add then
                  match (Value_operations.try_to_string left_val, Value_operations.try_to_string right_val) with
                  | Some a, Some b -> execute_string_op op a b
                  | _ -> Error (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))
                else
                  Error (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))))
    | Lt | Le | Gt | Ge -> (
        (* 比较运算的类型转换 *)
        match (Value_operations.try_to_float left_val, Value_operations.try_to_float right_val) with
        | Some a, Some b -> execute_comparison_op op (FloatValue a) (FloatValue b)
        | _ -> Error (RuntimeError ("不支持的比较运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val)))
    | _ -> Error (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))

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
  | _ -> Error (RuntimeError ("不支持的一元运算: " ^ value_to_string value))

(** 一元运算实现 - 向后兼容接口 *)
let execute_unary_op op value =
  match execute_unary_op_internal op value with
  | Ok result -> result
  | Error error -> raise (unified_error_to_exception error)
