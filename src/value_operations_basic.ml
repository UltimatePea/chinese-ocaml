(** 骆言基础值操作模块 - Basic Value Operations Module
    
    技术债务改进：大型模块重构优化 Phase 2.2 - 基础值类型操作模块化
    处理基础值类型：IntValue, FloatValue, StringValue, BoolValue, UnitValue
    
    @author 骆言AI代理
    @version 2.2 - 基础值操作模块
    @since 2025-07-24 Fix #1046
*)

open Value_types

(** 初始化模块日志器 *)
let () = Logger_init_helpers.replace_init_no_logger "ValueOperationsBasic"

(** 基础值转换为字符串 - 错误处理标准化 *)
let string_of_basic_value = function
  | IntValue i -> Ok (string_of_int i)
  | FloatValue f -> Ok (string_of_float f)
  | StringValue s -> Ok s
  | BoolValue b -> Ok (if b then "真" else "假")
  | UnitValue -> Ok "()"
  | _ -> Error "类型错误：期望基础值类型 (IntValue, FloatValue, StringValue, BoolValue, UnitValue)"

(** 兼容性封装：保持向后兼容 *)
let string_of_basic_value_unsafe v =
  match string_of_basic_value v with
  | Ok s -> s
  | Error msg -> raise (RuntimeError msg)

(** 基础值相等性比较 - 错误处理标准化 *)
let compare_basic_values v1 v2 =
  match (v1, v2) with
  | (IntValue i1, IntValue i2) -> Ok (compare i1 i2)
  | (FloatValue f1, FloatValue f2) -> Ok (compare f1 f2)
  | (StringValue s1, StringValue s2) -> Ok (compare s1 s2)
  | (BoolValue b1, BoolValue b2) -> Ok (compare b1 b2)
  | (UnitValue, UnitValue) -> Ok 0
  | _ -> Error "类型错误：无法比较不同类型或非基础值类型"

(** 兼容性封装：保持向后兼容 *)
let compare_basic_values_unsafe v1 v2 =
  match compare_basic_values v1 v2 with
  | Ok result -> result
  | Error msg -> raise (RuntimeError msg)

(** 基础值相等性检查 *)
let equals_basic_values v1 v2 = 
  match compare_basic_values v1 v2 with
  | Ok 0 -> true
  | Ok _ -> false
  | Error _ -> false

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

(** {1 高级值比较操作} *)

(** 容器类型值相等性比较的辅助函数 *)
let rec compare_container_values v1 v2 =
  match (v1, v2) with
  | ListValue l1, ListValue l2 ->
      List.length l1 = List.length l2 && List.for_all2 runtime_value_equal l1 l2
  | ArrayValue a1, ArrayValue a2 ->
      Array.length a1 = Array.length a2 && Array.for_all2 runtime_value_equal a1 a2
  | TupleValue t1, TupleValue t2 ->
      List.length t1 = List.length t2 && List.for_all2 runtime_value_equal t1 t2
  | RecordValue r1, RecordValue r2 ->
      List.length r1 = List.length r2
      && List.for_all
           (fun (k, v) ->
             match List.assoc_opt k r2 with Some v2 -> runtime_value_equal v v2 | None -> false)
           r1
  | RefValue r1, RefValue r2 -> runtime_value_equal !r1 !r2
  | _ -> false

(** 构造器和异常类型值相等性比较的辅助函数 *)
and compare_constructor_values v1 v2 =
  match (v1, v2) with
  | ConstructorValue (name1, args1), ConstructorValue (name2, args2) ->
      String.equal name1 name2
      && List.length args1 = List.length args2
      && List.for_all2 runtime_value_equal args1 args2
  | ExceptionValue (name1, opt1), ExceptionValue (name2, opt2) -> (
      String.equal name1 name2
      &&
      match (opt1, opt2) with
      | None, None -> true
      | Some v1, Some v2 -> runtime_value_equal v1 v2
      | _ -> false)
  | PolymorphicVariantValue (tag1, opt1), PolymorphicVariantValue (tag2, opt2) -> (
      String.equal tag1 tag2
      &&
      match (opt1, opt2) with
      | None, None -> true
      | Some v1, Some v2 -> runtime_value_equal v1 v2
      | _ -> false)
  | _ -> false

(** 模块类型值相等性比较的辅助函数 *)
and compare_module_values v1 v2 =
  match (v1, v2) with
  | ModuleValue m1, ModuleValue m2 ->
      List.length m1 = List.length m2
      && List.for_all
           (fun (k, v) ->
             match List.assoc_opt k m2 with Some v2 -> runtime_value_equal v v2 | None -> false)
           m1
  | _ -> false

(** 函数类型值相等性比较的辅助函数（函数不可比较） *)
and compare_function_values v1 v2 =
  match (v1, v2) with
  | FunctionValue _, FunctionValue _ -> false (* 函数不可比较 *)
  | BuiltinFunctionValue _, BuiltinFunctionValue _ -> false (* 内置函数不可比较 *)
  | LabeledFunctionValue _, LabeledFunctionValue _ -> false (* 标签函数不可比较 *)
  | _ -> false

(** 运行时值相等性比较 - 统一版本，处理所有值类型 *)
and runtime_value_equal v1 v2 =
  equals_basic_values v1 v2 ||
  compare_container_values v1 v2 ||
  compare_constructor_values v1 v2 ||
  compare_module_values v1 v2 ||
  compare_function_values v1 v2