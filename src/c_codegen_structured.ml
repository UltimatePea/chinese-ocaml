(** 骆言C代码生成器结构化数据模块 - C Code Generator Structured Data Module *)

open Ast
open C_codegen_context
open Error_utils

(* 使用统一字符串工具模块 *)
module String_formatting = Utils_formatting.String_utils.Formatting

(** 生成元组表达式代码 *)
let gen_tuple_expr gen_expr_fn ctx exprs =
  let expr_codes = List.map (gen_expr_fn ctx) exprs in
  let tuple_size = List.length exprs in
  String_formatting.format_function_call "luoyan_tuple" [string_of_int tuple_size; String.concat ", " expr_codes]

(** 生成记录表达式代码 *)
let gen_record_expr gen_expr_fn ctx fields =
  let gen_field (name, expr) =
    let expr_code = gen_expr_fn ctx expr in
    Printf.sprintf "{\"%s\", %s}" (escape_identifier name) expr_code
  in
  let field_codes = List.map gen_field fields in
  Printf.sprintf "luoyan_record(%d, (luoyan_field_t[]){%s})" (List.length fields)
    (String.concat ", " field_codes)

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
  | FieldAccessExpr (record_expr, field_name) ->
      gen_record_access_expr gen_expr_fn ctx record_expr field_name
  | RecordUpdateExpr (record_expr, updates) ->
      let record_code = gen_expr_fn ctx record_expr in
      let gen_update (field_name, expr) =
        let expr_code = gen_expr_fn ctx expr in
        Printf.sprintf "{\"%s\", %s}" (escape_identifier field_name) expr_code
      in
      let update_codes = List.map gen_update updates in
      Printf.sprintf "luoyan_record_update(%s, %d, (luoyan_field_t[]){%s})" 
        record_code (List.length updates) (String.concat ", " update_codes)
  | ConstructorExpr (constructor_name, args) ->
      let arg_codes = List.map (gen_expr_fn ctx) args in
      Printf.sprintf "luoyan_constructor(\"%s\", %d, %s)" 
        (escape_identifier constructor_name) (List.length args) 
        (match arg_codes with 
         | [] -> "NULL" 
         | _ -> Printf.sprintf "(luoyan_value_t[]){%s}" (String.concat ", " arg_codes))
  | _ -> fail_unsupported_expression_with_function "gen_structured_data" StructuredData
