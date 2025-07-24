(** 骆言基础值操作模块 - Basic Value Operations Module
    
    技术债务改进：大型模块重构优化 Phase 2.2 - 基础值类型操作模块化
    处理基础值类型：IntValue, FloatValue, StringValue, BoolValue, UnitValue
    
    @author 骆言AI代理
    @version 2.2 - 基础值操作模块
    @since 2025-07-24 Fix #1046
*)

open Value_types

(** 初始化模块日志器 *)
let () = Logger_utils.init_no_logger "ValueOperationsBasic"

(** 基础值转换为字符串 *)
let string_of_basic_value = function
  | IntValue i -> string_of_int i
  | FloatValue f -> string_of_float f
  | StringValue s -> s
  | BoolValue b -> if b then "真" else "假"
  | UnitValue -> "()"
  | _ -> failwith "非基础值类型"

(** 基础值相等性比较 *)
let compare_basic_values v1 v2 =
  match (v1, v2) with
  | (IntValue i1, IntValue i2) -> compare i1 i2
  | (FloatValue f1, FloatValue f2) -> compare f1 f2
  | (StringValue s1, StringValue s2) -> compare s1 s2
  | (BoolValue b1, BoolValue b2) -> compare b1 b2
  | (UnitValue, UnitValue) -> 0
  | _ -> failwith "类型不匹配的基础值比较"

(** 基础值相等性检查 *)
let equals_basic_values v1 v2 = 
  compare_basic_values v1 v2 = 0

(** 数值运算 - 加法 *)
let add_numeric_values v1 v2 =
  match (v1, v2) with
  | (IntValue i1, IntValue i2) -> IntValue (i1 + i2)
  | (FloatValue f1, FloatValue f2) -> FloatValue (f1 +. f2)
  | (IntValue i, FloatValue f) -> FloatValue (float_of_int i +. f)
  | (FloatValue f, IntValue i) -> FloatValue (f +. float_of_int i)
  | _ -> raise (RuntimeError "不支持的加法操作")

(** 数值运算 - 减法 *)
let subtract_numeric_values v1 v2 =
  match (v1, v2) with
  | (IntValue i1, IntValue i2) -> IntValue (i1 - i2)
  | (FloatValue f1, FloatValue f2) -> FloatValue (f1 -. f2)
  | (IntValue i, FloatValue f) -> FloatValue (float_of_int i -. f)
  | (FloatValue f, IntValue i) -> FloatValue (f -. float_of_int i)
  | _ -> raise (RuntimeError "不支持的减法操作")

(** 数值运算 - 乘法 *)
let multiply_numeric_values v1 v2 =
  match (v1, v2) with
  | (IntValue i1, IntValue i2) -> IntValue (i1 * i2)
  | (FloatValue f1, FloatValue f2) -> FloatValue (f1 *. f2)
  | (IntValue i, FloatValue f) -> FloatValue (float_of_int i *. f)
  | (FloatValue f, IntValue i) -> FloatValue (f *. float_of_int i)
  | _ -> raise (RuntimeError "不支持的乘法操作")

(** 数值运算 - 除法 *)
let divide_numeric_values v1 v2 =
  match (v1, v2) with
  | (IntValue i1, IntValue i2) -> 
      if i2 = 0 then raise (RuntimeError "除零错误")
      else IntValue (i1 / i2)
  | (FloatValue f1, FloatValue f2) -> 
      if f2 = 0.0 then raise (RuntimeError "除零错误")
      else FloatValue (f1 /. f2)
  | (IntValue i, FloatValue f) -> 
      if f = 0.0 then raise (RuntimeError "除零错误")
      else FloatValue (float_of_int i /. f)
  | (FloatValue f, IntValue i) -> 
      if i = 0 then raise (RuntimeError "除零错误")
      else FloatValue (f /. float_of_int i)
  | _ -> raise (RuntimeError "不支持的除法操作")

(** 数值运算 - 取模 *)
let modulo_numeric_values v1 v2 =
  match (v1, v2) with
  | (IntValue i1, IntValue i2) -> 
      if i2 = 0 then raise (RuntimeError "取模除零错误")
      else IntValue (i1 mod i2)
  | _ -> raise (RuntimeError "取模运算仅支持整数")

(** 数值比较 - 小于 *)
let less_than_numeric v1 v2 =
  match (v1, v2) with
  | (IntValue i1, IntValue i2) -> BoolValue (i1 < i2)
  | (FloatValue f1, FloatValue f2) -> BoolValue (f1 < f2)
  | (IntValue i, FloatValue f) -> BoolValue (float_of_int i < f)
  | (FloatValue f, IntValue i) -> BoolValue (f < float_of_int i)
  | _ -> raise (RuntimeError "不支持的数值比较")

(** 数值比较 - 小于等于 *)
let less_equal_numeric v1 v2 =
  match (v1, v2) with
  | (IntValue i1, IntValue i2) -> BoolValue (i1 <= i2)
  | (FloatValue f1, FloatValue f2) -> BoolValue (f1 <= f2)
  | (IntValue i, FloatValue f) -> BoolValue (float_of_int i <= f)
  | (FloatValue f, IntValue i) -> BoolValue (f <= float_of_int i)
  | _ -> raise (RuntimeError "不支持的数值比较")

(** 数值比较 - 大于 *)
let greater_than_numeric v1 v2 =
  match (v1, v2) with
  | (IntValue i1, IntValue i2) -> BoolValue (i1 > i2)
  | (FloatValue f1, FloatValue f2) -> BoolValue (f1 > f2)
  | (IntValue i, FloatValue f) -> BoolValue (float_of_int i > f)
  | (FloatValue f, IntValue i) -> BoolValue (f > float_of_int i)
  | _ -> raise (RuntimeError "不支持的数值比较")

(** 数值比较 - 大于等于 *)
let greater_equal_numeric v1 v2 =
  match (v1, v2) with
  | (IntValue i1, IntValue i2) -> BoolValue (i1 >= i2)
  | (FloatValue f1, FloatValue f2) -> BoolValue (f1 >= f2)
  | (IntValue i, FloatValue f) -> BoolValue (float_of_int i >= f)
  | (FloatValue f, IntValue i) -> BoolValue (f >= float_of_int i)
  | _ -> raise (RuntimeError "不支持的数值比较")

(** 字符串连接 *)
let concat_string_values v1 v2 =
  match (v1, v2) with
  | (StringValue s1, StringValue s2) -> StringValue (s1 ^ s2)
  | _ -> raise (RuntimeError "字符串连接需要两个字符串值")

(** 逻辑运算 - 与 *)
let logical_and v1 v2 =
  match (v1, v2) with
  | (BoolValue b1, BoolValue b2) -> BoolValue (b1 && b2)
  | _ -> raise (RuntimeError "逻辑与运算需要两个布尔值")

(** 逻辑运算 - 或 *)
let logical_or v1 v2 =
  match (v1, v2) with
  | (BoolValue b1, BoolValue b2) -> BoolValue (b1 || b2)
  | _ -> raise (RuntimeError "逻辑或运算需要两个布尔值")

(** 逻辑运算 - 非 *)
let logical_not v =
  match v with
  | BoolValue b -> BoolValue (not b)
  | _ -> raise (RuntimeError "逻辑非运算需要布尔值")

(** 类型转换 - 转为整数 *)
let to_int_value = function
  | IntValue i -> IntValue i
  | FloatValue f -> IntValue (int_of_float f)
  | StringValue s -> (
      try IntValue (int_of_string s)
      with Failure _ -> raise (RuntimeError ("无法将字符串 '" ^ s ^ "' 转换为整数")))
  | BoolValue true -> IntValue 1
  | BoolValue false -> IntValue 0
  | _ -> raise (RuntimeError "不支持的整数转换")

(** 类型转换 - 转为浮点数 *)
let to_float_value = function
  | IntValue i -> FloatValue (float_of_int i)
  | FloatValue f -> FloatValue f
  | StringValue s -> (
      try FloatValue (float_of_string s)
      with Failure _ -> raise (RuntimeError ("无法将字符串 '" ^ s ^ "' 转换为浮点数")))
  | _ -> raise (RuntimeError "不支持的浮点数转换")

(** 类型转换 - 转为字符串 *)
let to_string_value = function
  | IntValue i -> StringValue (string_of_int i)
  | FloatValue f -> StringValue (string_of_float f)
  | StringValue s -> StringValue s
  | BoolValue b -> StringValue (if b then "真" else "假")
  | UnitValue -> StringValue "()"
  | _ -> raise (RuntimeError "不支持的字符串转换")

(** 类型转换 - 转为布尔值 *)
let to_bool_value = function
  | BoolValue b -> BoolValue b
  | IntValue 0 -> BoolValue false
  | IntValue _ -> BoolValue true
  | FloatValue f -> BoolValue (f <> 0.0)
  | StringValue "" -> BoolValue false
  | StringValue _ -> BoolValue true
  | UnitValue -> BoolValue false
  | _ -> raise (RuntimeError "不支持的布尔值转换")