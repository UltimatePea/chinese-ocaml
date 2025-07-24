(** 骆言高级值操作模块 - Chinese Programming Language Advanced Value Operations Module *)

open Value_types
open Value_basic_ops
open Ast

(** 列表值转换为字符串的辅助函数 *)
let list_value_to_string value_to_string lst =
  let buffer = Buffer.create 64 in
  Buffer.add_char buffer '[';
  (match lst with
   | [] -> ()
   | first :: rest ->
       Buffer.add_string buffer (value_to_string first);
       List.iter (fun v ->
         Buffer.add_string buffer "; ";
         Buffer.add_string buffer (value_to_string v)
       ) rest);
  Buffer.add_char buffer ']';
  Buffer.contents buffer

(** 数组值转换为字符串的辅助函数 *)
let array_value_to_string value_to_string arr =
  let buffer = Buffer.create 64 in
  Buffer.add_string buffer "[|";
  let arr_list = Array.to_list arr in
  (match arr_list with
   | [] -> ()
   | first :: rest ->
       Buffer.add_string buffer (value_to_string first);
       List.iter (fun v ->
         Buffer.add_string buffer "; ";
         Buffer.add_string buffer (value_to_string v)
       ) rest);
  Buffer.add_string buffer "|]";
  Buffer.contents buffer

(** 元组值转换为字符串的辅助函数 *)
let tuple_value_to_string value_to_string values =
  let buffer = Buffer.create 64 in
  Buffer.add_char buffer '(';
  (match values with
   | [] -> ()
   | first :: rest ->
       Buffer.add_string buffer (value_to_string first);
       List.iter (fun v ->
         Buffer.add_string buffer ", ";
         Buffer.add_string buffer (value_to_string v)
       ) rest);
  Buffer.add_char buffer ')';
  Buffer.contents buffer

(** 记录值转换为字符串的辅助函数 *)
let record_value_to_string value_to_string fields =
  let buffer = Buffer.create 128 in
  Buffer.add_char buffer '{';
  (match fields with
   | [] -> ()
   | (first_name, first_value) :: rest ->
       Buffer.add_string buffer first_name;
       Buffer.add_string buffer " = ";
       Buffer.add_string buffer (value_to_string first_value);
       List.iter (fun (name, value) ->
         Buffer.add_string buffer "; ";
         Buffer.add_string buffer name;
         Buffer.add_string buffer " = ";
         Buffer.add_string buffer (value_to_string value)
       ) rest);
  Buffer.add_char buffer '}';
  Buffer.contents buffer

(** 引用值转换为字符串的辅助函数 *)
let ref_value_to_string value_to_string r =
  let buffer = Buffer.create 32 in
  Buffer.add_string buffer "引用(";
  Buffer.add_string buffer (value_to_string !r);
  Buffer.add_char buffer ')';
  Buffer.contents buffer

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
      let buffer = Buffer.create 64 in
      Buffer.add_string buffer name;
      Buffer.add_char buffer '(';
      (match args with
       | [] -> ()
       | first :: rest ->
           Buffer.add_string buffer (value_to_string first);
           List.iter (fun arg ->
             Buffer.add_string buffer ", ";
             Buffer.add_string buffer (value_to_string arg)
           ) rest);
      Buffer.add_char buffer ')';
      Buffer.contents buffer
  | ExceptionValue (name, None) -> name
  | ExceptionValue (name, Some payload) -> 
      let buffer = Buffer.create 32 in
      Buffer.add_string buffer name;
      Buffer.add_char buffer '(';
      Buffer.add_string buffer (value_to_string payload);
      Buffer.add_char buffer ')';
      Buffer.contents buffer
  | PolymorphicVariantValue (tag_name, None) -> 
      let buffer = Buffer.create 16 in
      Buffer.add_string buffer "「";
      Buffer.add_string buffer tag_name;
      Buffer.add_string buffer "」";
      Buffer.contents buffer
  | PolymorphicVariantValue (tag_name, Some value) ->
      let buffer = Buffer.create 32 in
      Buffer.add_string buffer "「";
      Buffer.add_string buffer tag_name;
      Buffer.add_string buffer "」(";
      Buffer.add_string buffer (value_to_string value);
      Buffer.add_char buffer ')';
      Buffer.contents buffer
  | _ -> "constructor_value_to_string: 不是构造器类型"

(** 模块类型值转换为字符串 *)
let module_value_to_string value =
  match value with
  | ModuleValue bindings -> 
      let buffer = Buffer.create 64 in
      Buffer.add_string buffer "<模块: ";
      (match bindings with
       | [] -> ()
       | (first_name, _) :: rest ->
           Buffer.add_string buffer first_name;
           List.iter (fun (name, _) ->
             Buffer.add_string buffer ", ";
             Buffer.add_string buffer name
           ) rest);
      Buffer.add_char buffer '>';
      Buffer.contents buffer
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

(** 基础类型值相等性比较的辅助函数 *)
let compare_basic_values v1 v2 =
  match (v1, v2) with
  | IntValue n1, IntValue n2 -> n1 = n2
  | FloatValue f1, FloatValue f2 -> Float.equal f1 f2
  | StringValue s1, StringValue s2 -> String.equal s1 s2
  | BoolValue b1, BoolValue b2 -> Bool.equal b1 b2
  | UnitValue, UnitValue -> true
  | _ -> false

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
  compare_basic_values v1 v2 ||
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
let () = Logger_utils.init_no_logger "ValueAdvancedOps"