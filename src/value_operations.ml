(** 骆言值操作模块 - Chinese Programming Language Value Operations Module *)

open Ast
open Error_recovery

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
  | LabeledFunctionValue of label_param list * expr * runtime_env  (* 标签函数值：标签参数列表, 函数体, 闭包环境 *)
  | ExceptionValue of string * runtime_value option  (* 异常值：异常名称和可选的携带值 *)
  | RefValue of runtime_value ref                (* 引用值：可变引用 *)
  | ConstructorValue of string * runtime_value list  (* 构造器值：构造器名和参数列表 *)
  | ModuleValue of (string * runtime_value) list (* 模块值：导出的绑定列表 *)
  | PolymorphicVariantValue of string * runtime_value option  (* 多态变体值：标签和可选值 *)

and runtime_env = (string * runtime_value) list
(** 运行时环境 *)

(** 环境类型 *)
type env = runtime_env

(** 运行时错误异常 *)
exception RuntimeError of string

(** 异常抛出 *)
exception ExceptionRaised of runtime_value

(** 抛出的异常 *)

(** 初始化模块日志器 *)
let (log_debug, log_info, _log_warn, log_error) = Logger.init_module_logger "ValueOperations"

(** 空环境 *)
let empty_env = []

(** 在环境中绑定变量 *)
let bind_var env var_name value = (var_name, value) :: env

(** 在环境中查找变量 *)
let lookup_var env name =
  match String.split_on_char '.' name with
  | [] -> raise (RuntimeError "空变量名")
  | [ var ] -> (
      try List.assoc var env
      with Not_found -> (
        (* 尝试拼写纠正 *)
        if (get_recovery_config ()).spell_correction then
          let available_vars = get_available_vars env in
          match find_closest_var var available_vars with
          | Some corrected_var -> (
              log_recovery_type "spell_correction"
                (Printf.sprintf "将变量名\"%s\"纠正为\"%s\"" var corrected_var);
              try List.assoc corrected_var env
              with Not_found -> raise (RuntimeError ("未定义的变量: " ^ var)))
          | None ->
              raise
                (RuntimeError
                   ("未定义的变量: " ^ var ^ " (可用变量: " ^ String.concat ", " available_vars ^ ")"))
        else raise (RuntimeError ("未定义的变量: " ^ var))))
  | mod_name :: _rest ->
      (* 模块访问：实际上需要与外部模块表交互，这里简化处理 *)
      raise (RuntimeError ("模块访问暂未实现: " ^ mod_name))

(** 值转换为字符串 *)
let rec value_to_string value =
  match value with
  | IntValue n -> string_of_int n
  | FloatValue f -> string_of_float f
  | StringValue s -> s
  | BoolValue b -> if b then "真" else "假"
  | UnitValue -> "()"
  | ListValue lst -> "[" ^ String.concat "; " (List.map value_to_string lst) ^ "]"
  | RecordValue fields ->
      "{"
      ^ String.concat "; "
          (List.map (fun (name, value) -> name ^ " = " ^ value_to_string value) fields)
      ^ "}"
  | ArrayValue arr ->
      "[|" ^ String.concat "; " (Array.to_list (Array.map value_to_string arr)) ^ "|]"
  | FunctionValue (_, _, _) -> "<函数>"
  | BuiltinFunctionValue _ -> "<内置函数>"
  | LabeledFunctionValue (_, _, _) -> "<标签函数>"
  | ExceptionValue (name, None) -> name
  | ExceptionValue (name, Some payload) -> name ^ "(" ^ value_to_string payload ^ ")"
  | RefValue r -> "引用(" ^ value_to_string !r ^ ")"
  | ConstructorValue (name, args) -> 
    name ^ "(" ^ String.concat ", " (List.map value_to_string args) ^ ")"
  | ModuleValue bindings ->
    "<模块: " ^ String.concat ", " (List.map fst bindings) ^ ">"
  | PolymorphicVariantValue (tag_name, None) ->
    "「" ^ tag_name ^ "」"
  | PolymorphicVariantValue (tag_name, Some value) ->
    "「" ^ tag_name ^ "」(" ^ value_to_string value ^ ")"

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
      log_recovery_type "type_conversion" (Printf.sprintf "将浮点数%.2f转换为整数%d" f (int_of_float f));
      Some (int_of_float f)
  | StringValue s -> (
      try
        let n = int_of_string s in
        log_recovery_type "type_conversion" (Printf.sprintf "将字符串\"%s\"转换为整数%d" s n);
        Some n
      with _ -> None)
  | BoolValue b ->
      let n = if b then 1 else 0 in
      log_recovery_type "type_conversion"
        (Printf.sprintf "将布尔值%s转换为整数%d" (if b then "真" else "假") n);
      Some n
  | _ -> None

(** 尝试将值转换为浮点数 *)
let try_to_float value =
  match value with
  | FloatValue f -> Some f
  | IntValue n ->
      let f = float_of_int n in
      log_recovery_type "type_conversion" (Printf.sprintf "将整数%d转换为浮点数%.2f" n f);
      Some f
  | StringValue s -> (
      try
        let f = float_of_string s in
        log_recovery_type "type_conversion" (Printf.sprintf "将字符串\"%s\"转换为浮点数%.2f" s f);
        Some f
      with _ -> None)
  | _ -> None

(** 尝试将值转换为字符串 *)
let try_to_string value =
  match value with
  | StringValue s -> Some s
  | _ ->
      let s = value_to_string value in
      log_recovery_type "type_conversion"
        (Printf.sprintf "将%s转换为字符串\"%s\""
           (match value with
           | IntValue _ -> "整数"
           | FloatValue _ -> "浮点数"
           | BoolValue _ -> "布尔值"
           | _ -> "值")
           s);
      Some s

(** 注册构造器函数 *)
let register_constructors env type_def =
  match type_def with
  | AlgebraicType constructors ->
    (* 为每个构造器创建构造器函数 *)
    List.fold_left (fun acc_env (constructor_name, _type_opt) ->
      let constructor_func = BuiltinFunctionValue (fun args ->
        ConstructorValue (constructor_name, args)
      ) in
      bind_var acc_env constructor_name constructor_func
    ) env constructors
  | _ -> env