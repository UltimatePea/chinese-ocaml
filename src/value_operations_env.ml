(** 骆言值操作环境管理模块 - Value Operations Environment Management Module
    
    技术债务改进：大型模块重构优化 Phase 2.2 - value_operations.ml 完整模块化
    本模块负责运行时环境的管理操作，从 value_operations.ml 中提取
    
    重构目标：
    1. 专门处理运行时环境的变量绑定、查找和管理
    2. 支持模块访问和嵌套查找
    3. 集成拼写纠正和错误恢复机制
    4. 提供清晰的环境操作接口
    
    @author 骆言AI代理
    @version 2.2 - 完整模块化第二阶段  
    @since 2025-07-24 Fix #1048
*)

open Value_types
open Error_recovery
open Utils.Base_formatter

(** 初始化模块日志器 *)
let () = Logger_init_helpers.replace_init_no_logger "ValueOperationsEnv"

(** 获取环境中的所有可用变量名 - 用于拼写纠正 *)
let get_available_vars env = 
  List.map fst env

(** 在环境中查找变量 - 支持模块访问和拼写纠正 *)
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

(** 在环境中查找变量（可选版本） *)
let lookup_var_opt env name =
  try Some (lookup_var env name)
  with RuntimeError _ -> None

(** 检查环境中是否定义了变量 *)
let is_defined env name =
  match lookup_var_opt env name with
  | Some _ -> true
  | None -> false

(** 获取环境的大小（变量数量） *)
let env_size env = List.length env

(** 合并两个环境，优先使用第一个环境的绑定 *)
let merge_env env1 env2 =
  let combined = env1 @ env2 in
  (* 移除重复的绑定，保留第一次出现的 *)
  let rec remove_duplicates acc = function
    | [] -> List.rev acc
    | (name, value) :: rest ->
        if List.mem_assoc name acc then
          remove_duplicates acc rest
        else
          remove_duplicates ((name, value) :: acc) rest
  in
  remove_duplicates [] combined

(** 过滤环境，只保留满足条件的绑定 *)
let filter_env predicate env =
  List.filter predicate env

(** 映射环境的值，保持变量名不变 *)
let map_env_values f env =
  List.map (fun (name, value) -> (name, f value)) env

(** 从环境中移除指定的变量 *)
let remove_var env var_name =
  List.filter (fun (name, _) -> name <> var_name) env

(** 批量绑定变量到环境 *)
let bind_vars env bindings =
  List.fold_left (fun acc_env (name, value) -> bind_var acc_env name value) env bindings

(** 环境转换为关联列表（别名，用于兼容性） *)
let env_to_assoc_list env = env

(** 从关联列表创建环境 *)
let env_from_assoc_list assoc_list = assoc_list

(** 打印环境内容（用于调试） *)
let print_env env =
  List.iter (fun (name, _) ->
    Printf.printf "  %s: %s\n" name (string_of_value_type (List.assoc name env))
  ) env

(** 获取环境的字符串表示 *)
let string_of_env env =
  let buffer = Buffer.create 128 in
  Buffer.add_string buffer "环境 {\n";
  List.iter (fun (name, value) ->
    Buffer.add_string buffer ("  " ^ name ^ ": " ^ string_of_value_type value ^ "\n")
  ) env;
  Buffer.add_string buffer "}";
  Buffer.contents buffer