(** 骆言值操作模块 - Chinese Programming Language Value Operations Module *)

open Ast
open Error_recovery
open Utils.Base_formatter

(** 运行时值类型 *)
type runtime_value =
  | IntValue of int
  | FloatValue of float
  | StringValue of string
  | BoolValue of bool
  | UnitValue
  | ListValue of runtime_value list
  | RecordValue of (string * runtime_value) list (* 记录值：字段名和值的列表 *)
  | ArrayValue of runtime_value array (* 可变数组 *)
  | FunctionValue of string list * expr * runtime_env (* 参数列表, 函数体, 闭包环境 *)
  | BuiltinFunctionValue of (runtime_value list -> runtime_value)
  | LabeledFunctionValue of label_param list * expr * runtime_env (* 标签函数值：标签参数列表, 函数体, 闭包环境 *)
  | ExceptionValue of string * runtime_value option (* 异常值：异常名称和可选的携带值 *)
  | RefValue of runtime_value ref (* 引用值：可变引用 *)
  | ConstructorValue of string * runtime_value list (* 构造器值：构造器名和参数列表 *)
  | ModuleValue of (string * runtime_value) list (* 模块值：导出的绑定列表 *)
  | PolymorphicVariantValue of string * runtime_value option (* 多态变体值：标签和可选值 *)
  | TupleValue of runtime_value list (* 元组值：元素列表 *)

and runtime_env = (string * runtime_value) list
(** 运行时环境 *)

type env = runtime_env
(** 环境类型 *)

exception RuntimeError of string
(** 运行时错误异常 *)

exception ExceptionRaised of runtime_value
(** 异常抛出 *)

(** 抛出的异常 *)

(** 初始化模块日志器 *)
let () = Logger_utils.init_no_logger "ValueOperations"

(** 空环境 *)
let empty_env = []

(** 在环境中绑定变量 *)
let bind_var env var_name value = (var_name, value) :: env

(** 在环境中查找变量 *)
let rec lookup_var env name =
  match String.split_on_char '.' name with
  | [] -> raise (RuntimeError "空变量名")
  | [ var ] -> (
      try List.assoc var env
      with Not_found ->
        if
          (* 尝试拼写纠正 *)
          (get_recovery_config ()).spell_correction
        then
          let available_vars = get_available_vars env in
          match find_closest_var var available_vars with
          | Some corrected_var -> (
              log_recovery_type "spell_correction" (variable_correction_pattern var corrected_var);
              try List.assoc corrected_var env
              with Not_found -> raise (RuntimeError ("未定义的变量: " ^ var)))
          | None ->
              raise
                (RuntimeError
                   ("未定义的变量: " ^ var ^ " (可用变量: " ^ String.concat ", " available_vars ^ ")"))
        else raise (RuntimeError ("未定义的变量: " ^ var)))
  | mod_name :: member_path -> (
      (* 模块访问：尝试从环境中查找模块并访问其成员 *)
      match List.assoc_opt mod_name env with
      | Some (ModuleValue module_bindings) -> (
          (* 递归处理嵌套模块访问 *)
          match member_path with
          | [] ->
              (* 应该不会到达这里，因为原始解析应该保证至少有一个成员 *)
              raise (RuntimeError "模块访问路径为空")
          | [ member_name ] -> (
              (* 简单成员访问 *)
              match List.assoc_opt member_name module_bindings with
              | Some value -> value
              | None -> raise (RuntimeError ("模块中未找到成员: " ^ member_name)))
          | _ ->
              (* 嵌套访问：递归调用，将路径重新组合成字符串 *)
              lookup_var module_bindings (String.concat "." member_path))
      | Some _ -> raise (RuntimeError (mod_name ^ " 不是模块类型"))
      | None -> raise (RuntimeError ("未定义的模块: " ^ mod_name)))

(** 基础类型值转换为字符串 *)
let basic_value_to_string value =
  match value with
  | IntValue n -> string_of_int n
  | FloatValue f -> string_of_float f
  | StringValue s -> s
  | BoolValue b -> if b then "真" else "假"
  | UnitValue -> "()"
  | _ -> "basic_value_to_string: 不是基础类型"

(** 容器类型值转换为字符串 *)
let container_value_to_string value_to_string value =
  match value with
  | ListValue lst -> 
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
  | ArrayValue arr ->
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
  | TupleValue values -> 
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
  | RecordValue fields ->
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
  | RefValue r -> 
      let buffer = Buffer.create 32 in
      Buffer.add_string buffer "引用(";
      Buffer.add_string buffer (value_to_string !r);
      Buffer.add_char buffer ')';
      Buffer.contents buffer
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

(** 运行时值相等性比较 *)
let rec runtime_value_equal v1 v2 =
  match (v1, v2) with
  | IntValue n1, IntValue n2 -> n1 = n2
  | FloatValue f1, FloatValue f2 -> Float.equal f1 f2
  | StringValue s1, StringValue s2 -> String.equal s1 s2
  | BoolValue b1, BoolValue b2 -> Bool.equal b1 b2
  | UnitValue, UnitValue -> true
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
  | ModuleValue m1, ModuleValue m2 ->
      List.length m1 = List.length m2
      && List.for_all
           (fun (k, v) ->
             match List.assoc_opt k m2 with Some v2 -> runtime_value_equal v v2 | None -> false)
           m1
  | FunctionValue _, FunctionValue _ -> false (* 函数不可比较 *)
  | BuiltinFunctionValue _, BuiltinFunctionValue _ -> false (* 内置函数不可比较 *)
  | LabeledFunctionValue _, LabeledFunctionValue _ -> false (* 标签函数不可比较 *)
  | _ -> false

(** 运行时值打印函数 *)
let runtime_value_pp fmt value = Format.fprintf fmt "%s" (value_to_string value)

(** Alcotest ValueModule - 用于测试 *)
module ValueModule = struct
  type t = runtime_value

  let equal = runtime_value_equal
  let pp = runtime_value_pp
end
