(** 骆言语义分析表达式 - Chinese Programming Language Semantic Expressions *)

open Ast
open Types
open Semantic_context
open Semantic_types
open Error_utils

(** 初始化模块日志器 *)
let[@warning "-32"] (log_info, log_error) = Logger_utils.init_info_error_loggers "SemanticExpressions"

(** 语义错误异常 *)
exception SemanticError of string

(** 分析表达式 *)
let rec analyze_expression context expr =
  let env = build_type_env context.scope_stack in

  try
    let _, inferred_type = infer_type env expr in

    (* 额外的语义检查 *)
    let context1 = check_expression_semantics context expr in
    (context1, Some inferred_type)
  with
  | TypeError msg ->
      let error_msg = "类型错误: " ^ msg in
      ({ context with error_list = error_msg :: context.error_list }, None)
  | SemanticError msg -> ({ context with error_list = msg :: context.error_list }, None)

(** 检查表达式语义 *)
and check_expression_semantics context expr =
  match expr with
  | LitExpr _ | VarExpr _ | BinaryOpExpr _ | UnaryOpExpr _ | OrElseExpr _ ->
      check_basic_expressions context expr
  | CondExpr _ | MatchExpr _ | TryExpr _ ->
      check_control_flow_expressions context expr
  | FunExpr _ | FunCallExpr _ | FunExprWithType _ | LabeledFunExpr _ | LabeledFunCallExpr _ ->
      check_function_expressions context expr
  | TupleExpr _ | ListExpr _ | RefExpr _ | DerefExpr _ | ArrayExpr _ | ArrayAccessExpr _ ->
      check_data_expressions context expr
  | _ -> fail_unsupported_expression GeneralExpression

(** 检查基本表达式语义 *)
and check_basic_expressions context expr =
  match expr with
  | LitExpr _ -> context
  | VarExpr var_name -> (
      match lookup_symbol context.scope_stack var_name with
      | Some _ -> context
      | None -> { context with error_list = ("未定义的变量: " ^ var_name) :: context.error_list })
  | BinaryOpExpr (left_expr, _op, right_expr) ->
      let context1 = check_expression_semantics context left_expr in
      check_expression_semantics context1 right_expr
  | UnaryOpExpr (_op, expr) -> check_expression_semantics context expr
  | OrElseExpr (primary_expr, default_expr) ->
      let context_after_primary = check_expression_semantics context primary_expr in
      check_expression_semantics context_after_primary default_expr
  | _ -> fail_unsupported_expression BasicExpression

(** 检查控制流表达式语义 *)
and check_control_flow_expressions context expr =
  match expr with
  | CondExpr (cond, then_branch, else_branch) ->
      let context1 = check_expression_semantics context cond in
      let context2 = check_expression_semantics context1 then_branch in
      check_expression_semantics context2 else_branch
  | MatchExpr (expr, branch_list) ->
      let context1 = check_expression_semantics context expr in
      let _ =
        List.map
          (fun branch ->
            let context2 = enter_scope context1 in
            let context3 = check_pattern_semantics context2 branch.pattern in
            let context4 = check_expression_semantics context3 branch.expr in
            let context5 =
              match branch.guard with
              | None -> context4
              | Some guard_expr -> check_expression_semantics context4 guard_expr
            in
            exit_scope context5)
          branch_list
      in
      context1
  | TryExpr (try_expr, catch_branches, finally_opt) ->
      let context' = check_expression_semantics context try_expr in
      let context'' =
        List.fold_left
          (fun ctx branch ->
            let ctx' = check_pattern_semantics ctx branch.pattern in
            let ctx'' = check_expression_semantics ctx' branch.expr in
            match branch.guard with
            | None -> ctx''
            | Some guard_expr -> check_expression_semantics ctx'' guard_expr)
          context' catch_branches
      in
      (match finally_opt with
      | Some finally_expr -> check_expression_semantics context'' finally_expr
      | None -> context'')
  | _ -> fail_unsupported_expression ControlFlowExpression

(** 检查函数表达式语义 *)
and check_function_expressions context expr =
  match expr with
  | FunExpr (param_list, body) ->
      let context1 = enter_scope context in
      let context2 =
        List.fold_left
          (fun acc_context param_name -> add_symbol acc_context param_name (new_type_var ()) false)
          context1 param_list
      in
      let context3 = check_expression_semantics context2 body in
      exit_scope context3
  | FunCallExpr (func_expr, arg_list) ->
      let context1 = check_expression_semantics context func_expr in
      List.fold_left check_expression_semantics context1 arg_list
  | FunExprWithType (param_list, _return_type, body) ->
      let context_with_params =
        List.fold_left
          (fun acc_context (param_name, _) -> add_symbol acc_context param_name (new_type_var ()) false)
          context param_list
      in
      check_expression_semantics context_with_params body
  | LabeledFunExpr (label_params, body) ->
      let context1 = enter_scope context in
      let context2 =
        List.fold_left
          (fun acc_context label_param ->
            let param_context =
              add_symbol acc_context label_param.param_name (new_type_var ()) false
            in
            match label_param.default_value with
            | Some default_expr -> check_expression_semantics param_context default_expr
            | None -> param_context)
          context1 label_params
      in
      let context3 = check_expression_semantics context2 body in
      exit_scope context3
  | LabeledFunCallExpr (func_expr, label_args) ->
      let context1 = check_expression_semantics context func_expr in
      List.fold_left
        (fun acc_context label_arg -> check_expression_semantics acc_context label_arg.arg_value)
        context1 label_args
  | _ -> fail_unsupported_expression FunctionExpression

(** 检查数据表达式语义 *)
and check_data_expressions context expr =
  match expr with
  | TupleExpr expr_list ->
      List.fold_left check_expression_semantics context expr_list
  | ListExpr expr_list ->
      List.fold_left check_expression_semantics context expr_list
  | RefExpr expr -> check_expression_semantics context expr
  | DerefExpr expr -> check_expression_semantics context expr
  | ArrayExpr expr_list ->
      List.fold_left check_expression_semantics context expr_list
  | ArrayAccessExpr (array_expr, index_expr) ->
      let context1 = check_expression_semantics context array_expr in
      check_expression_semantics context1 index_expr
  | _ -> fail_unsupported_expression DataExpression

(** 检查模式语义 *)
and check_pattern_semantics context pattern =
  match pattern with
  | WildcardPattern -> context
  | VarPattern var_name ->
      add_symbol context var_name (new_type_var ()) false
  | LitPattern _ -> context
  | TuplePattern pattern_list ->
      List.fold_left check_pattern_semantics context pattern_list
  | ListPattern pattern_list ->
      List.fold_left check_pattern_semantics context pattern_list
  | ConstructorPattern (constructor_name, sub_pattern_list) ->
      let context1 = 
        match lookup_symbol context.scope_stack constructor_name with
        | Some _ -> context
        | None -> { context with error_list = ("未定义的构造器: " ^ constructor_name) :: context.error_list }
      in
      List.fold_left check_pattern_semantics context1 sub_pattern_list
  | OrPattern (pattern1, pattern2) ->
      let context1 = check_pattern_semantics context pattern1 in
      check_pattern_semantics context1 pattern2
  | EmptyListPattern -> context
  | ConsPattern (head_pattern, tail_pattern) ->
      let context1 = check_pattern_semantics context head_pattern in
      check_pattern_semantics context1 tail_pattern
  | _ -> context