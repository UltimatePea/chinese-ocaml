(** 骆言解释器二元运算模块 - Chinese Programming Language Interpreter Binary Operations *)

open Ast
open Value_operations
open Error_recovery

(** 二元运算实现 *)
let rec execute_binary_op op left_val right_val =
  match (op, left_val, right_val) with
  (* 算术运算 *)
  | Add, IntValue a, IntValue b -> IntValue (a + b)
  | Sub, IntValue a, IntValue b -> IntValue (a - b)
  | Mul, IntValue a, IntValue b -> IntValue (a * b)
  | Div, IntValue a, IntValue b -> if b = 0 then raise (RuntimeError "除零错误") else IntValue (a / b)
  | Mod, IntValue a, IntValue b -> if b = 0 then raise (RuntimeError "取模零错误") else IntValue (a mod b)
  | Add, FloatValue a, FloatValue b -> FloatValue (a +. b)
  | Sub, FloatValue a, FloatValue b -> FloatValue (a -. b)
  | Mul, FloatValue a, FloatValue b -> FloatValue (a *. b)
  | Div, FloatValue a, FloatValue b -> FloatValue (a /. b)
  (* 字符串连接 *)
  | Add, StringValue a, StringValue b -> StringValue (a ^ b)
  (* 字符串连接运算 *)
  | Concat, StringValue a, StringValue b -> StringValue (a ^ b)
  (* 比较运算 *)
  | Eq, a, b -> BoolValue (a = b)
  | Neq, a, b -> BoolValue (a <> b)
  | Lt, IntValue a, IntValue b -> BoolValue (a < b)
  | Le, IntValue a, IntValue b -> BoolValue (a <= b)
  | Gt, IntValue a, IntValue b -> BoolValue (a > b)
  | Ge, IntValue a, IntValue b -> BoolValue (a >= b)
  | Lt, FloatValue a, FloatValue b -> BoolValue (a < b)
  | Le, FloatValue a, FloatValue b -> BoolValue (a <= b)
  | Gt, FloatValue a, FloatValue b -> BoolValue (a > b)
  | Ge, FloatValue a, FloatValue b -> BoolValue (a >= b)
  (* 逻辑运算 *)
  | And, a, b -> BoolValue (value_to_bool a && value_to_bool b)
  | Or, a, b -> BoolValue (value_to_bool a || value_to_bool b)
  | _ ->
      (* 尝试自动类型转换 *)
      let config = Error_recovery.get_recovery_config () in
      if config.enabled && config.type_conversion then
        match op with
        | Add | Sub | Mul | Div | Mod -> (
            (* 尝试数值运算的类型转换 *)
            match (Value_operations.try_to_int left_val, Value_operations.try_to_int right_val) with
            | Some a, Some b -> execute_binary_op op (IntValue a) (IntValue b)
            | _ -> (
                match
                  (Value_operations.try_to_float left_val, Value_operations.try_to_float right_val)
                with
                | Some a, Some b -> execute_binary_op op (FloatValue a) (FloatValue b)
                | _ ->
                    (* 如果是加法，尝试字符串连接 *)
                    if op = Add then
                      match
                        ( Value_operations.try_to_string left_val,
                          Value_operations.try_to_string right_val )
                      with
                      | Some a, Some b -> execute_binary_op op (StringValue a) (StringValue b)
                      | _ ->
                          raise
                            (RuntimeError
                               ("不支持的二元运算: " ^ value_to_string left_val ^ " "
                              ^ value_to_string right_val))
                    else
                      raise
                        (RuntimeError
                           ("不支持的二元运算: " ^ value_to_string left_val ^ " "
                          ^ value_to_string right_val))))
        | Lt | Le | Gt | Ge -> (
            (* 比较运算的类型转换 *)
            match
              (Value_operations.try_to_float left_val, Value_operations.try_to_float right_val)
            with
            | Some a, Some b -> execute_binary_op op (FloatValue a) (FloatValue b)
            | _ ->
                raise
                  (RuntimeError
                     ("不支持的比较运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val)))
        | _ ->
            raise
              (RuntimeError
                 ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))
      else
        raise
          (RuntimeError ("不支持的二元运算: " ^ value_to_string left_val ^ " " ^ value_to_string right_val))

(** 一元运算实现 *)
let execute_unary_op op value =
  match (op, value) with
  | Neg, IntValue n -> IntValue (-n)
  | Neg, FloatValue f -> FloatValue (-.f)
  | Not, v -> BoolValue (not (value_to_bool v))
  | _ -> raise (RuntimeError ("不支持的一元运算: " ^ value_to_string value))
