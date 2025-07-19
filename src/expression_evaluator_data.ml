(** 骆言数据结构表达式求值模块 - Chinese Programming Language Data Structure Expression Evaluator *)

open Ast
open Value_operations
open Unified_errors

type eval_expr_func = runtime_env -> expr -> runtime_value
(** 评估函数类型 *)

(** 数据结构表达式求值 - 记录、数组、元组 *)
let eval_data_structure_expr env eval_expr_func = function
  | RecordExpr fields ->
      let eval_field (name, expr) = (name, eval_expr_func env expr) in
      RecordValue (List.map eval_field fields)
  | FieldAccessExpr (record_expr, field_name) -> (
      let record_val = eval_expr_func env record_expr in
      match record_val with
      | RecordValue fields -> (
          try List.assoc field_name fields
          with Not_found ->
            raise (unified_error_to_exception (RuntimeError (Printf.sprintf "记录没有字段: %s" field_name))))
      | _ ->
          raise (unified_error_to_exception (RuntimeError "期望记录类型")))
  | TupleExpr exprs ->
      let values = List.map (eval_expr_func env) exprs in
      TupleValue values
  | ArrayExpr elements ->
      let values = List.map (eval_expr_func env) elements in
      ArrayValue (Array.of_list values)
  | RecordUpdateExpr (record_expr, updates) -> (
      let record_val = eval_expr_func env record_expr in
      match record_val with
      | RecordValue fields ->
          let update_field (name, value) fields =
            if List.mem_assoc name fields then (name, value) :: List.remove_assoc name fields
            else
              raise (unified_error_to_exception (RuntimeError (Printf.sprintf "记录没有字段: %s" name)))
          in
          let eval_update (name, expr) = (name, eval_expr_func env expr) in
          let evaluated_updates = List.map eval_update updates in
          let new_fields = List.fold_right update_field evaluated_updates fields in
          RecordValue new_fields
      | _ ->
          raise (unified_error_to_exception (RuntimeError "期望记录类型")))
  | ArrayAccessExpr (array_expr, index_expr) -> (
      let array_val = eval_expr_func env array_expr in
      let index_val = eval_expr_func env index_expr in
      match (array_val, index_val) with
      | ArrayValue arr, IntValue idx ->
          if idx >= 0 && idx < Array.length arr then arr.(idx)
          else
            raise (unified_error_to_exception (RuntimeError (Printf.sprintf "数组索引越界: %d (数组长度: %d)" idx (Array.length arr))))
      | ArrayValue _, _ ->
          raise (unified_error_to_exception (RuntimeError "数组索引必须是整数"))
      | _ ->
          raise (unified_error_to_exception (RuntimeError "期望数组类型")))
  | ArrayUpdateExpr (array_expr, index_expr, value_expr) -> (
      let array_val = eval_expr_func env array_expr in
      let index_val = eval_expr_func env index_expr in
      let new_value = eval_expr_func env value_expr in
      match (array_val, index_val) with
      | ArrayValue arr, IntValue idx ->
          if idx >= 0 && idx < Array.length arr then (
            arr.(idx) <- new_value;
            UnitValue)
          else
            raise (unified_error_to_exception (RuntimeError (Printf.sprintf "数组索引越界: %d (数组长度: %d)" idx (Array.length arr))))
      | ArrayValue _, _ ->
          raise (unified_error_to_exception (RuntimeError "数组索引必须是整数"))
      | _ ->
          raise (unified_error_to_exception (RuntimeError "期望数组类型")))
  | ListExpr expr_list ->
      let values = List.map (eval_expr_func env) expr_list in
      ListValue values
  | _ ->
      raise (unified_error_to_exception (RuntimeError "不支持的数据结构表达式类型"))
