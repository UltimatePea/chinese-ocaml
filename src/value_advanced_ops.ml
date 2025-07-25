(** 骆言高级值操作模块 - Chinese Programming Language Advanced Value Operations Module *)

open Value_types
open Value_operations_basic
open Ast
open Utils.Buffer_formatting_utils

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
      string_of_basic_value_unsafe value
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

(** 注册构造器函数 *)
let register_constructors env type_def =
  match type_def with
  | AlgebraicType constructors ->
      (* 为每个构造器创建构造器函数 *)
      List.fold_left
        (fun acc_env (constructor_name, _type_opt) ->
          let constructor_func =
            BuiltinFunctionValue (fun args -> ConstructorValue (constructor_name, args))
          in
          bind_var acc_env constructor_name constructor_func)
        env constructors
  | _ -> env

open Value_operations_basic
(** 使用来自value_operations_basic.ml的函数，消除代码重复 *)

(** 运行时值打印函数 *)
let runtime_value_pp fmt value = Format.fprintf fmt "%s" (value_to_string value)

(** Alcotest ValueModule - 用于测试 *)
module ValueModule = struct
  type t = runtime_value

  let equal = runtime_value_equal
  let pp = runtime_value_pp
end

(** 初始化模块日志器 *)
let () = Logger_init_helpers.replace_init_no_logger "ValueAdvancedOps"
