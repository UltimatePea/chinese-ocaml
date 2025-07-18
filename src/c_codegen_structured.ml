(** 骆言C代码生成器结构化数据模块 - C Code Generator Structured Data Module *)

open Ast
open C_codegen_context
open Error_utils

(** 初始化模块日志器 *)
let[@warning "-32"] log_info = Logger_utils.init_info_logger "CCodegenStructured"

(** 生成元组表达式代码 *)
let gen_tuple_expr gen_expr_fn ctx exprs =
  let expr_codes = List.map (gen_expr_fn ctx) exprs in
  let tuple_size = List.length exprs in
  Printf.sprintf "luoyan_tuple(%d, %s)" tuple_size (String.concat ", " expr_codes)

(** 生成记录表达式代码 *)
let gen_record_expr gen_expr_fn ctx fields =
  let gen_field (name, expr) =
    let expr_code = gen_expr_fn ctx expr in
    Printf.sprintf "{\"%s\", %s}" (escape_identifier name) expr_code
  in
  let field_codes = List.map gen_field fields in
  Printf.sprintf "luoyan_record(%d, (luoyan_field_t[]){%s})" (List.length fields) (String.concat ", " field_codes)

(** 生成记录字段访问表达式代码 *)
let gen_record_access_expr gen_expr_fn ctx record_expr field_name =
  let record_code = gen_expr_fn ctx record_expr in
  let escaped_field = escape_identifier field_name in
  Printf.sprintf "luoyan_record_get(%s, \"%s\")" record_code escaped_field

(** 生成结构化数据表达式代码 *)
let gen_structured_data gen_expr_fn ctx expr =
  match expr with
  | TupleExpr exprs -> gen_tuple_expr gen_expr_fn ctx exprs
  | RecordExpr fields -> gen_record_expr gen_expr_fn ctx fields
  | FieldAccessExpr (record_expr, field_name) -> gen_record_access_expr gen_expr_fn ctx record_expr field_name
  | _ -> fail_unsupported_expression_with_function "gen_structured_data" StructuredData