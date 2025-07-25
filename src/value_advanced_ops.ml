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
  Formatting.format_ocaml_record 
    ~key_formatter:(fun x -> x) 
    ~value_formatter:value_to_string 
    fields

(** 引用值转换为字符串的辅助函数 *)
let ref_value_to_string value_to_string r =
  "引用(" ^ (value_to_string !r) ^ ")"

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
      Formatting.format_constructor ~name ~formatter:value_to_string [payload]
  | PolymorphicVariantValue (tag_name, None) -> 
      "「" ^ tag_name ^ "」"
  | PolymorphicVariantValue (tag_name, Some value) ->
      let formatted_tag = "「" ^ tag_name ^ "」" in
      Formatting.format_constructor ~name:formatted_tag ~formatter:value_to_string [value]
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

(** 使用来自value_operations_basic.ml的函数，消除代码重复 *)

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

(** 运行时值相等性比较 - 重构版本，使用分类比较函数 *)
and runtime_value_equal v1 v2 =
  equals_basic_values v1 v2 ||
  compare_container_values v1 v2 ||
  compare_constructor_values v1 v2 ||
  compare_module_values v1 v2 ||
  compare_function_values v1 v2

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