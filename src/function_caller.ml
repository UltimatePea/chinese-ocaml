(** 骆言解释器函数调用模块 - Chinese Programming Language Interpreter Function Caller *)

open Ast
open Value_operations
open Error_recovery
open Interpreter_utils
open String_formatter

(** 调用函数 *)
let call_function func_val arg_vals eval_expr_func =
  match func_val with
  | BuiltinFunctionValue f -> f arg_vals
  | FunctionValue (param_list, body, closure_env) ->
      let param_count = List.length param_list in
      let arg_count = List.length arg_vals in

      if param_count = arg_count then
        (* 参数数量匹配，正常执行 *)
        let new_env =
          List.fold_left2
            (fun acc_env param_name arg_val -> bind_var acc_env param_name arg_val)
            closure_env param_list arg_vals
        in
        eval_expr_func new_env body
      else
        let config = Error_recovery.get_recovery_config () in
        if config.enabled && config.parameter_adaptation then (
          if
            (* 参数数量不匹配，但启用了错误恢复和参数适配 *)
            arg_count < param_count
          then (
            (* 参数不足，用默认值填充 *)
            let missing_count = param_count - arg_count in
            let default_vals = List.init missing_count (fun _ -> IntValue 0) in
            (* 性能优化：使用 List.rev_append 替代 @ 操作 *)
            let adapted_args = List.rev_append arg_vals default_vals in
            Error_recovery.log_recovery_type "parameter_adaptation"
              (ErrorMessages.format_missing_params_filled param_count arg_count missing_count);
            let new_env =
              List.fold_left2
                (fun acc_env param_name arg_val -> bind_var acc_env param_name arg_val)
                closure_env param_list adapted_args
            in
            eval_expr_func new_env body)
          else
            (* 参数过多，忽略多余的参数 *)
            let extra_count = arg_count - param_count in
            let rec take n lst =
              if n <= 0 then [] else match lst with [] -> [] | h :: t -> h :: take (n - 1) t
            in
            let truncated_args = take param_count arg_vals in
            Error_recovery.log_recovery_type "parameter_adaptation"
              (ErrorMessages.format_extra_params_ignored param_count arg_count extra_count);
            let new_env =
              List.fold_left2
                (fun acc_env param_name arg_val -> bind_var acc_env param_name arg_val)
                closure_env param_list truncated_args
            in
            eval_expr_func new_env body)
        else raise (RuntimeError "函数参数数量不匹配")
  | _ -> raise (RuntimeError "尝试调用非函数值")

(** 调用标签函数 *)
let call_labeled_function func_val label_args caller_env eval_expr_func =
  match func_val with
  | LabeledFunctionValue (label_params, body, closure_env) ->
      (* 性能优化：创建标签到参数的哈希表映射，避免重复线性搜索 *)
      let label_to_param = Hashtbl.create (List.length label_params) in
      List.iter
        (fun label_param -> Hashtbl.replace label_to_param label_param.label_name label_param)
        label_params;

      (* 创建参数名到值的映射 *)
      let param_bindings = Hashtbl.create (List.length label_params) in

      (* 处理传入的标签参数 - 使用哈希表查找优化性能 *)
      List.iter
        (fun label_arg ->
          match Hashtbl.find_opt label_to_param label_arg.arg_label with
          | Some param ->
              let arg_value = eval_expr_func caller_env label_arg.arg_value in
              Hashtbl.replace param_bindings param.param_name arg_value
          | None -> raise (RuntimeError ("未知的标签参数: " ^ label_arg.arg_label)))
        label_args;

      (* 处理默认值和检查必需参数 *)
      let final_env =
        List.fold_left
          (fun acc_env label_param ->
            let param_name = label_param.param_name in
            let param_value =
              if Hashtbl.mem param_bindings param_name then Hashtbl.find param_bindings param_name
              else if label_param.is_optional then
                (* 可选参数，使用默认值 *)
                match label_param.default_value with
                | Some default_expr -> eval_expr_func closure_env default_expr
                | None -> UnitValue (* 没有默认值的可选参数使用Unit *)
              else
                (* 必需参数，但没有提供 *)
                raise (RuntimeError ("缺少必需的标签参数: " ^ label_param.label_name))
            in
            bind_var acc_env param_name param_value)
          closure_env label_params
      in

      (* 在绑定了所有参数的环境中执行函数体 *)
      eval_expr_func final_env body
  | _ -> raise (RuntimeError "尝试调用标签函数，但值不是标签函数")

(** 处理递归let语句的通用逻辑 *)
let handle_recursive_let env func_name expr =
  let func_val =
    match expr with
    | FunExpr (param_list, body) ->
        (* Create function with current environment *)
        let func_value = FunctionValue (param_list, body, env) in
        (* Store in global recursive functions table for self-reference *)
        Interpreter_state.add_recursive_function func_name func_value;
        func_value
    | FunExprWithType (param_list, _return_type, body) ->
        (* Handle typed function expressions *)
        let param_names = List.map fst param_list in
        let func_value = FunctionValue (param_names, body, env) in
        Interpreter_state.add_recursive_function func_name func_value;
        func_value
    | LabeledFunExpr (label_params, body) ->
        (* Handle labeled function expressions *)
        let func_value = LabeledFunctionValue (label_params, body, env) in
        Interpreter_state.add_recursive_function func_name func_value;
        func_value
    | _ -> raise (RuntimeError "递归让语句期望函数表达式")
  in
  let new_env = bind_var env func_name func_val in
  (new_env, func_val)
