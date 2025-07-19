(** 骆言解释器二元运算模块 - Chinese Programming Language Interpreter Binary Operations *)

open Ast
open Value_operations
open Error_recovery

(** 执行整数算术运算 *)
let execute_int_arithmetic_op op a b =
  match op with
  | Add -> IntValue (a + b)
  | Sub -> IntValue (a - b)
  | Mul -> IntValue (a * b)
  | Div -> if b = 0 then raise (RuntimeError "除零错误") else IntValue (a / b)
  | Mod -> if b = 0 then raise (RuntimeError "取模零错误") else IntValue (a mod b)
  | _ -> failwith "非算术运算"

(** 执行浮点算术运算 *)
let execute_float_arithmetic_op op a b =
  match op with
  | Add -> FloatValue (a +. b)
  | Sub -> FloatValue (a -. b)
  | Mul -> FloatValue (a *. b)
  | Div -> FloatValue (a /. b)
  | _ -> failwith "非算术运算"

(** 执行字符串运算 *)
let execute_string_op op a b =
  match op with
  | Add | Concat -> StringValue (a ^ b)
  | _ -> failwith "非字符串运算"

(** 执行比较运算 *)
let execute_comparison_op op left_val right_val =
  match op with
  | Eq -> BoolValue (left_val = right_val)
  | Neq -> BoolValue (left_val <> right_val)
  | Lt -> (
      match (left_val, right_val) with
      | IntValue a, IntValue b -> BoolValue (a < b)
      | FloatValue a, FloatValue b -> BoolValue (a < b)
      | _ -> failwith "不支持的比较类型")
  | Le -> (
      match (left_val, right_val) with
      | IntValue a, IntValue b -> BoolValue (a <= b)
      | FloatValue a, FloatValue b -> BoolValue (a <= b)
      | _ -> failwith "不支持的比较类型")
  | Gt -> (
      match (left_val, right_val) with
      | IntValue a, IntValue b -> BoolValue (a > b)
      | FloatValue a, FloatValue b -> BoolValue (a > b)
      | _ -> failwith "不支持的比较类型")
  | Ge -> (
      match (left_val, right_val) with
      | IntValue a, IntValue b -> BoolValue (a >= b)
      | FloatValue a, FloatValue b -> BoolValue (a >= b)
      | _ -> failwith "不支持的比较类型")
  | _ -> failwith "非比较运算"

(** 执行逻辑运算 *)
let execute_logical_op op a b =
  match op with
  | And -> BoolValue (value_to_bool a && value_to_bool b)
  | Or -> BoolValue (value_to_bool a || value_to_bool b)
  | _ -> failwith "非逻辑运算"

(** 尝试类型转换并执行运算 *)
let try_with_conversion op left_val right_val =
  let config = Error_recovery.get_recovery_config () in
  if not (config.enabled && config.type_conversion) then
    raise (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))
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
                  | _ -> raise (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))
                else
                  raise (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))))
    | Lt | Le | Gt | Ge -> (
        (* 比较运算的类型转换 *)
        match (Value_operations.try_to_float left_val, Value_operations.try_to_float right_val) with
        | Some a, Some b -> execute_comparison_op op (FloatValue a) (FloatValue b)
        | _ -> raise (RuntimeError ("不支持的比较运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val)))
    | _ -> raise (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))

(** 二元运算实现 - 重构：分离操作类型，提升可维护性 *)
let execute_binary_op op left_val right_val =
  try
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
  with
  | Failure _ -> try_with_conversion op left_val right_val

(** 一元运算实现 *)
let execute_unary_op op value =
  match (op, value) with
  | Neg, IntValue n -> IntValue (-n)
  | Neg, FloatValue f -> FloatValue (-.f)
  | Not, v -> BoolValue (not (value_to_bool v))
  | _ -> raise (RuntimeError ("不支持的一元运算: " ^ value_to_string value))
