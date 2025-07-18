(** 骆言C代码生成器集合模块 - C Code Generator Collections Module *)

open Ast
open C_codegen_context
open Error_utils

(** 初始化模块日志器 *)
let[@warning "-32"] log_info = Logger_utils.init_info_logger "CCodegenCollections"

(** 生成列表表达式代码 *)
let gen_list_expr gen_expr_fn ctx exprs =
  let rec build_list = function
    | [] -> "luoyan_list_empty()"
    | e :: rest ->
        let elem_code = gen_expr_fn ctx e in
        let rest_code = build_list rest in
        Printf.sprintf "luoyan_list_cons(%s, %s)" elem_code rest_code
  in
  build_list exprs

(** 生成数组表达式代码 *)
let gen_array_expr gen_expr_fn ctx exprs =
  let expr_codes = List.map (gen_expr_fn ctx) exprs in
  let array_size = List.length exprs in
  Printf.sprintf "luoyan_array(%d, %s)" array_size (String.concat ", " expr_codes)

(** 生成数组访问表达式代码 *)
let gen_array_access_expr gen_expr_fn ctx array_expr index_expr =
  let array_code = gen_expr_fn ctx array_expr in
  let index_code = gen_expr_fn ctx index_expr in
  Printf.sprintf "luoyan_array_get(%s, %s)" array_code index_code

(** 生成集合和数组操作表达式代码 *)
let gen_collections gen_expr_fn ctx expr =
  match expr with
  | ListExpr exprs -> gen_list_expr gen_expr_fn ctx exprs
  | ArrayExpr exprs -> gen_array_expr gen_expr_fn ctx exprs
  | ArrayAccessExpr (array_expr, index_expr) ->
      gen_array_access_expr gen_expr_fn ctx array_expr index_expr
  | _ -> fail_unsupported_expression_with_function "gen_collections" Collections
