(** 骆言数据结构表达式求值模块 - Chinese Programming Language Data Structure Expression Evaluator *)

open Ast
open Value_operations
open Unified_errors

type eval_expr_func = runtime_env -> expr -> runtime_value
(** 评估函数类型 *)

(** 数据结构表达式求值器 - 重构为模块化设计 *)

(** 错误处理辅助模块 *)
module DataStructureErrorHandler = struct
  let runtime_error msg = unified_error_to_exception (RuntimeError msg)
  let field_not_found field = runtime_error (Printf.sprintf "记录没有字段: %s" field)
  let expect_record_type () = runtime_error "期望记录类型"
  let expect_array_type () = runtime_error "期望数组类型"
  let array_index_not_int () = runtime_error "数组索引必须是整数"

  let array_index_out_of_bounds idx len =
    runtime_error (Printf.sprintf "数组索引越界: %d (数组长度: %d)" idx len)
end

(** 记录表达式求值器 *)
module RecordEvaluator = struct
  let eval_record_expr env eval_expr_func fields =
    let eval_field (name, expr) = (name, eval_expr_func env expr) in
    RecordValue (List.map eval_field fields)

  let eval_field_access env eval_expr_func record_expr field_name =
    let record_val = eval_expr_func env record_expr in
    match record_val with
    | RecordValue fields -> (
        try List.assoc field_name fields
        with Not_found -> raise (DataStructureErrorHandler.field_not_found field_name))
    | _ -> raise (DataStructureErrorHandler.expect_record_type ())

  let eval_record_update env eval_expr_func record_expr updates =
    let record_val = eval_expr_func env record_expr in
    match record_val with
    | RecordValue fields ->
        let update_field (name, value) fields =
          if List.mem_assoc name fields then (name, value) :: List.remove_assoc name fields
          else raise (DataStructureErrorHandler.field_not_found name)
        in
        let eval_update (name, expr) = (name, eval_expr_func env expr) in
        let evaluated_updates = List.map eval_update updates in
        let new_fields = List.fold_right update_field evaluated_updates fields in
        RecordValue new_fields
    | _ -> raise (DataStructureErrorHandler.expect_record_type ())
end

(** 数组表达式求值器 *)
module ArrayEvaluator = struct
  let eval_array_expr env eval_expr_func elements =
    let values = List.map (eval_expr_func env) elements in
    ArrayValue (Array.of_list values)

  let validate_array_index arr idx =
    if idx >= 0 && idx < Array.length arr then ()
    else raise (DataStructureErrorHandler.array_index_out_of_bounds idx (Array.length arr))

  let eval_array_access env eval_expr_func array_expr index_expr =
    let array_val = eval_expr_func env array_expr in
    let index_val = eval_expr_func env index_expr in
    match (array_val, index_val) with
    | ArrayValue arr, IntValue idx ->
        validate_array_index arr idx;
        arr.(idx)
    | ArrayValue _, _ -> raise (DataStructureErrorHandler.array_index_not_int ())
    | _ -> raise (DataStructureErrorHandler.expect_array_type ())

  let eval_array_update env eval_expr_func array_expr index_expr value_expr =
    let array_val = eval_expr_func env array_expr in
    let index_val = eval_expr_func env index_expr in
    let new_value = eval_expr_func env value_expr in
    match (array_val, index_val) with
    | ArrayValue arr, IntValue idx ->
        validate_array_index arr idx;
        arr.(idx) <- new_value;
        UnitValue
    | ArrayValue _, _ -> raise (DataStructureErrorHandler.array_index_not_int ())
    | _ -> raise (DataStructureErrorHandler.expect_array_type ())
end

(** 其他数据结构求值器 *)
module OtherDataEvaluator = struct
  let eval_tuple_expr env eval_expr_func exprs =
    let values = List.map (eval_expr_func env) exprs in
    TupleValue values

  let eval_list_expr env eval_expr_func expr_list =
    let values = List.map (eval_expr_func env) expr_list in
    ListValue values
end

(** 主要的数据结构表达式求值函数 - 重构为简洁的模块化设计 *)
let eval_data_structure_expr env eval_expr_func = function
  | RecordExpr fields -> RecordEvaluator.eval_record_expr env eval_expr_func fields
  | FieldAccessExpr (record_expr, field_name) ->
      RecordEvaluator.eval_field_access env eval_expr_func record_expr field_name
  | RecordUpdateExpr (record_expr, updates) ->
      RecordEvaluator.eval_record_update env eval_expr_func record_expr updates
  | ArrayExpr elements -> ArrayEvaluator.eval_array_expr env eval_expr_func elements
  | ArrayAccessExpr (array_expr, index_expr) ->
      ArrayEvaluator.eval_array_access env eval_expr_func array_expr index_expr
  | ArrayUpdateExpr (array_expr, index_expr, value_expr) ->
      ArrayEvaluator.eval_array_update env eval_expr_func array_expr index_expr value_expr
  | TupleExpr exprs -> OtherDataEvaluator.eval_tuple_expr env eval_expr_func exprs
  | ListExpr expr_list -> OtherDataEvaluator.eval_list_expr env eval_expr_func expr_list
  | _ -> raise (DataStructureErrorHandler.runtime_error "不支持的数据结构表达式类型")
