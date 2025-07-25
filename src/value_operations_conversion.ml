(** 骆言值操作类型转换模块 - Value Operations Type Conversion Module

    技术债务改进：大型模块重构优化 Phase 2.2 - value_operations.ml 完整模块化 本模块负责运行时值的类型转换和字符串化操作，从
    value_operations.ml 中提取

    重构目标： 1. 专门处理运行时值到字符串的转换 2. 提供类型间的转换函数（int, float, string, bool） 3. 支持复杂数据结构的字符串化显示 4.
    集成类型转换的错误恢复机制

    @author 骆言AI代理
    @version 2.2 - 完整模块化第二阶段
    @since 2025-07-24 Fix #1048 *)

open Value_types
open Error_recovery
open Utils.Base_formatter
open Utils.Buffer_formatting_utils

(** 初始化模块日志器 *)
let () = Logger_init_helpers.replace_init_no_logger "ValueOperationsConversion"

(** 基础类型值转换为字符串 *)
let basic_value_to_string value =
  match value with
  | IntValue n -> string_of_int n
  | FloatValue f -> string_of_float f
  | StringValue s -> s
  | BoolValue b -> if b then "真" else "假"
  | UnitValue -> "()"
  | _ -> "basic_value_to_string: 不是基础类型"

(** 列表值转换为字符串的辅助函数 *)
let list_value_to_string value_to_string lst =
  Formatting.format_ocaml_list ~formatter:value_to_string lst

(** 数组值转换为字符串的辅助函数 *)
let array_value_to_string value_to_string arr =
  let arr_list = Array.to_list arr in
  Formatting.format_ocaml_array ~formatter:value_to_string arr_list

(** 元组值转换为字符串的辅助函数 *)
let tuple_value_to_string value_to_string values =
  Formatting.format_ocaml_tuple ~formatter:value_to_string values

(** 记录值转换为字符串的辅助函数 *)
let record_value_to_string value_to_string fields =
  Formatting.format_ocaml_record ~key_formatter:(fun x -> x) ~value_formatter:value_to_string fields

(** 引用值转换为字符串的辅助函数 *)
let ref_value_to_string value_to_string r = "引用(" ^ value_to_string !r ^ ")"

(** 容器类型值转换为字符串 - 重构版本，使用分派函数 *)
let container_value_to_string value_to_string value =
  match value with
  | ListValue lst -> list_value_to_string value_to_string lst
  | ArrayValue arr -> array_value_to_string value_to_string arr
  | TupleValue values -> tuple_value_to_string value_to_string values
  | RecordValue fields -> record_value_to_string value_to_string fields
  | RefValue r -> ref_value_to_string value_to_string r
  | _ -> "container_value_to_string: 不是容器类型"

(** 函数类型值转换为字符串 *)
let function_value_to_string value =
  match value with
  | FunctionValue (_, _, _) -> "<函数>"
  | BuiltinFunctionValue _ -> "<内置函数>"
  | LabeledFunctionValue (_, _, _) -> "<标签函数>"
  | _ -> "function_value_to_string: 不是函数类型"

(** 构造器和异常类型值转换为字符串 *)
let constructor_value_to_string value_to_string value =
  match value with
  | ConstructorValue (name, args) ->
      Formatting.format_constructor ~name ~formatter:value_to_string args
  | ExceptionValue (name, None) -> name
  | ExceptionValue (name, Some payload) ->
      Formatting.format_constructor ~name ~formatter:value_to_string [ payload ]
  | PolymorphicVariantValue (tag_name, None) -> "「" ^ tag_name ^ "」"
  | PolymorphicVariantValue (tag_name, Some value) ->
      let formatted_tag = "「" ^ tag_name ^ "」" in
      Formatting.format_constructor ~name:formatted_tag ~formatter:value_to_string [ value ]
  | _ -> "constructor_value_to_string: 不是构造器类型"

(** 模块类型值转换为字符串 *)
let module_value_to_string value =
  match value with
  | ModuleValue bindings ->
      let names = List.map (fun (name, _) -> name) bindings in
      let formatted_names = String.concat ", " names in
      "<模块: " ^ formatted_names ^ ">"
  | _ -> "module_value_to_string: 不是模块类型"

(** 值转换为字符串 - 重构后的主函数 *)
let rec value_to_string value =
  match value with
  (* 基础类型 *)
  | IntValue _ | FloatValue _ | StringValue _ | BoolValue _ | UnitValue ->
      basic_value_to_string value
  (* 容器类型 *)
  | ListValue _ | ArrayValue _ | TupleValue _ | RecordValue _ | RefValue _ ->
      container_value_to_string value_to_string value
  (* 函数类型 *)
  | FunctionValue _ | BuiltinFunctionValue _ | LabeledFunctionValue _ ->
      function_value_to_string value
  (* 构造器和异常类型 *)
  | ConstructorValue _ | ExceptionValue _ | PolymorphicVariantValue _ ->
      constructor_value_to_string value_to_string value
  (* 模块类型 *)
  | ModuleValue _ -> module_value_to_string value

(** 值转换为布尔值 *)
let value_to_bool value =
  match value with
  | BoolValue b -> b
  | IntValue 0 -> false
  | IntValue _ -> true
  | StringValue "" -> false
  | StringValue _ -> true
  | UnitValue -> false
  | _ -> true

(** 尝试将值转换为整数 *)
let try_to_int value =
  match value with
  | IntValue n -> Some n
  | FloatValue f ->
      let int_val = int_of_float f in
      log_recovery_type "type_conversion" (float_to_int_conversion_pattern f int_val);
      Some int_val
  | StringValue s -> (
      try
        let n = int_of_string s in
        log_recovery_type "type_conversion" (string_to_int_conversion_pattern s n);
        Some n
      with _ -> None)
  | BoolValue b ->
      let n = if b then 1 else 0 in
      log_recovery_type "type_conversion" (bool_to_int_conversion_pattern b n);
      Some n
  | _ -> None

(** 尝试将值转换为浮点数 *)
let try_to_float value =
  match value with
  | FloatValue f -> Some f
  | IntValue n ->
      let f = float_of_int n in
      log_recovery_type "type_conversion" (int_to_float_conversion_pattern n f);
      Some f
  | StringValue s -> (
      try
        let f = float_of_string s in
        log_recovery_type "type_conversion" (string_to_float_conversion_pattern s f);
        Some f
      with _ -> None)
  | _ -> None

(** 尝试将值转换为字符串 *)
let try_to_string value =
  match value with
  | StringValue s -> Some s
  | _ ->
      let s = value_to_string value in
      let value_type =
        match value with
        | IntValue _ -> "整数"
        | FloatValue _ -> "浮点数"
        | BoolValue _ -> "布尔值"
        | _ -> "值"
      in
      log_recovery_type "type_conversion" (value_to_string_conversion_pattern value_type s);
      Some s

(** 强制转换为整数（不成功则抛出异常） *)
let force_to_int value =
  match try_to_int value with
  | Some n -> n
  | None -> raise (RuntimeError ("无法将值转换为整数: " ^ value_to_string value))

(** 强制转换为浮点数（不成功则抛出异常） *)
let force_to_float value =
  match try_to_float value with
  | Some f -> f
  | None -> raise (RuntimeError ("无法将值转换为浮点数: " ^ value_to_string value))

(** 强制转换为字符串（总是成功） *)
let force_to_string value =
  match try_to_string value with Some s -> s | None -> value_to_string value (* 这应该不会发生 *)

(** 检查值是否可以转换为整数 *)
let can_convert_to_int value = match try_to_int value with Some _ -> true | None -> false

(** 检查值是否可以转换为浮点数 *)
let can_convert_to_float value = match try_to_float value with Some _ -> true | None -> false

(** 检查值是否可以转换为字符串（总是可以） *)
let can_convert_to_string _value = true

(** 运行时值打印函数 *)
let runtime_value_pp fmt value = Format.fprintf fmt "%s" (value_to_string value)
