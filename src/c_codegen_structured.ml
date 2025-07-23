(** 骆言C代码生成器结构化数据模块 - C Code Generator Structured Data Module *)

open Ast
open C_codegen_context
open Error_utils
open Utils.Base_formatter

(* 使用统一字符串工具模块 *)
module String_formatting = Utils_formatting.String_utils.Formatting

(** 生成元组表达式代码 *)
let gen_tuple_expr gen_expr_fn ctx exprs =
  let expr_codes = List.map (gen_expr_fn ctx) exprs in
  let tuple_size = List.length exprs in
  String_formatting.format_function_call "luoyan_tuple"
    [ string_of_int tuple_size; String.concat ", " expr_codes ]

(** 生成记录表达式代码 *)
let gen_record_expr gen_expr_fn ctx fields =
  let gen_field (name, expr) =
    let expr_code = gen_expr_fn ctx expr in
    c_record_field_pattern (escape_identifier name) expr_code
  in
  let field_codes = List.map gen_field fields in
  c_record_constructor_pattern (List.length fields) (String.concat ", " field_codes)

(** 生成记录字段访问表达式代码 *)
let gen_record_access_expr gen_expr_fn ctx record_expr field_name =
  let record_code = gen_expr_fn ctx record_expr in
  let escaped_field = escape_identifier field_name in
  c_record_get_pattern record_code escaped_field

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
        c_record_field_pattern (escape_identifier field_name) expr_code
      in
      let update_codes = List.map gen_update updates in
      c_record_update_pattern record_code (List.length updates) (String.concat ", " update_codes)
  | ConstructorExpr (constructor_name, args) ->
      let arg_codes = List.map (gen_expr_fn ctx) args in
      let args_str =
        match arg_codes with
        | [] -> "NULL"
        | _ -> c_value_array_pattern (String.concat ", " arg_codes)
      in
      c_constructor_pattern (escape_identifier constructor_name) (List.length args) args_str
  | _ -> fail_unsupported_expression_with_function "gen_structured_data" StructuredData
