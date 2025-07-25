(** 骆言基础值操作模块 - Chinese Programming Language Basic Value Operations Module *)

open Value_types
open Error_recovery
open Utils.Base_formatter

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
              with Not_found -> raise (RuntimeError (Printf.sprintf "未定义的变量: %s" var)))
          | None ->
              raise
                (RuntimeError
                   (Printf.sprintf "未定义的变量: %s (可用变量: %s)" var (String.concat ", " available_vars)))
        else raise (RuntimeError (Printf.sprintf "未定义的变量: %s" var)))
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

(** 获取环境中的所有可用变量名 - 用于拼写纠正 *)
and get_available_vars env = 
  List.map fst env

(** 基础类型值转换为字符串 *)
let basic_value_to_string value =
  match value with
  | IntValue n -> string_of_int n
  | FloatValue f -> string_of_float f
  | StringValue s -> s
  | BoolValue b -> if b then "真" else "假"
  | UnitValue -> "()"
  | _ -> "basic_value_to_string: 不是基础类型"

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
      let s = basic_value_to_string value in
      let value_type =
        match value with
        | IntValue _ -> "整数"
        | FloatValue _ -> "浮点数"
        | BoolValue _ -> "布尔值"
        | _ -> "值"
      in
      log_recovery_type "type_conversion" (value_to_string_conversion_pattern value_type s);
      Some s

(** 初始化模块日志器 *)
let () = Logger_init_helpers.replace_init_no_logger "ValueBasicOps"