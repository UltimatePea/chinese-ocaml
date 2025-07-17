(** 骆言数据结构表达式求值模块 - Chinese Programming Language Data Structure Expression Evaluator *)

open Ast
open Value_operations
open Unified_errors

(** 记录表达式求值 *)
let eval_record_expr env fields eval_expr_func =
  to_result (fun () ->
    let eval_field (name, expr) = 
      let value = match eval_expr_func env expr with
        | Result.Ok v -> v
        | Result.Error e -> raise (error_to_exception e)
      in
      (name, value)
    in
    RecordValue (List.map eval_field fields)
  )

(** 字段访问表达式求值 *)
let eval_field_access env record_expr field_name eval_expr_func =
  match eval_expr_func env record_expr with
  | Result.Ok (RecordValue fields) ->
      (match List.assoc_opt field_name fields with
      | Some value -> Result.Ok value
      | None -> make_runtime_error ("记录没有字段: " ^ field_name) (Some (create_eval_position 20)))
  | Result.Ok _ ->
      make_runtime_error "期望记录类型" (Some (create_eval_position 22))
  | Result.Error e -> Result.Error e

(** 元组表达式求值 *)
let eval_tuple_expr env exprs eval_expr_func =
  let eval_results = List.map (eval_expr_func env) exprs in
  match ResultOps.all eval_results with
  | Result.Ok values -> Result.Ok (TupleValue values)
  | Result.Error e -> Result.Error e

(** 数组表达式求值 *)
let eval_array_expr env elements eval_expr_func =
  let eval_results = List.map (eval_expr_func env) elements in
  match ResultOps.all eval_results with
  | Result.Ok values -> Result.Ok (ArrayValue (Array.of_list values))
  | Result.Error e -> Result.Error e

(** 记录更新表达式求值 *)
let eval_record_update env record_expr updates eval_expr_func =
  match eval_expr_func env record_expr with
  | Result.Ok (RecordValue fields) ->
      to_result (fun () ->
        let update_field (name, value) fields =
          if List.mem_assoc name fields then 
            (name, value) :: List.remove_assoc name fields
          else 
            raise (RuntimeError ("记录没有字段: " ^ name))
        in
        let eval_update (name, expr) = 
          let value = match eval_expr_func env expr with
            | Result.Ok v -> v
            | Result.Error e -> raise (error_to_exception e)
          in
          (name, value)
        in
        let evaluated_updates = List.map eval_update updates in
        let new_fields = List.fold_right update_field evaluated_updates fields in
        RecordValue new_fields
      )
  | Result.Ok _ ->
      make_runtime_error "期望记录类型" None
  | Result.Error e -> Result.Error e

(** 数组访问表达式求值 *)
let eval_array_access env array_expr index_expr eval_expr_func =
  match eval_expr_func env array_expr with
  | Result.Ok (ArrayValue arr) ->
      (match eval_expr_func env index_expr with
      | Result.Ok (IntValue idx) ->
          if idx >= 0 && idx < Array.length arr then 
            Result.Ok arr.(idx)
          else
            make_runtime_error 
              (Printf.sprintf "数组索引越界: %d (数组长度: %d)" idx (Array.length arr))
              (Some (create_eval_position 58))
      | Result.Ok _ ->
          make_runtime_error "数组索引必须是整数" (Some (create_eval_position 60))
      | Result.Error e -> Result.Error e)
  | Result.Ok _ ->
      make_runtime_error "期望数组类型" (Some (create_eval_position 62))
  | Result.Error e -> Result.Error e

(** 数组更新表达式求值 *)
let eval_array_update env array_expr index_expr value_expr eval_expr_func =
  match eval_expr_func env array_expr with
  | Result.Ok (ArrayValue arr) ->
      (match eval_expr_func env index_expr with
      | Result.Ok (IntValue idx) ->
          if idx >= 0 && idx < Array.length arr then
            (match eval_expr_func env value_expr with
            | Result.Ok new_value ->
                arr.(idx) <- new_value;
                Result.Ok UnitValue
            | Result.Error e -> Result.Error e)
          else
            make_runtime_error 
              (Printf.sprintf "数组索引越界: %d (数组长度: %d)" idx (Array.length arr))
              None
      | Result.Ok _ ->
          make_runtime_error "数组索引必须是整数" None
      | Result.Error e -> Result.Error e)
  | Result.Ok _ ->
      make_runtime_error "期望数组类型" None
  | Result.Error e -> Result.Error e

(** 列表表达式求值 *)
let eval_list_expr env expr_list eval_expr_func =
  let eval_results = List.map (eval_expr_func env) expr_list in
  match ResultOps.all eval_results with
  | Result.Ok values -> Result.Ok (ListValue values)
  | Result.Error e -> Result.Error e

(** 数据结构表达式求值 - 记录、数组、元组 *)
let eval_data_structure_expr env expr eval_expr_func =
  match expr with
  | RecordExpr fields ->
      eval_record_expr env fields eval_expr_func
  | FieldAccessExpr (record_expr, field_name) ->
      eval_field_access env record_expr field_name eval_expr_func
  | TupleExpr exprs ->
      eval_tuple_expr env exprs eval_expr_func
  | ArrayExpr elements ->
      eval_array_expr env elements eval_expr_func
  | RecordUpdateExpr (record_expr, updates) ->
      eval_record_update env record_expr updates eval_expr_func
  | ArrayAccessExpr (array_expr, index_expr) ->
      eval_array_access env array_expr index_expr eval_expr_func
  | ArrayUpdateExpr (array_expr, index_expr, value_expr) ->
      eval_array_update env array_expr index_expr value_expr eval_expr_func
  | ListExpr expr_list ->
      eval_list_expr env expr_list eval_expr_func
  | _ -> 
      make_runtime_error "不支持的数据结构表达式类型" None