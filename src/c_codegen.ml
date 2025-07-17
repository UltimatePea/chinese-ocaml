(** 骆言C代码生成器 - Chinese Programming Language C Code Generator - 重构版本 *)

(* 重新导出所有模块的功能 *)
module Context = C_codegen_context
module Expressions = C_codegen_expressions
module Statements = C_codegen_statements

(* 重新导出主要类型 *)
type codegen_config = Context.codegen_config
type codegen_context = Context.codegen_context

(* 重新导出主要函数 *)
let create_context = Context.create_context
let gen_var_name = Context.gen_var_name
let gen_label_name = Context.gen_label_name
let escape_identifier = Context.escape_identifier
let c_type_of_luoyan_type = Context.c_type_of_luoyan_type

let gen_expr = Expressions.gen_expr
let gen_stmt = Statements.gen_stmt
let gen_program = Statements.gen_program
let generate_c_code = Statements.generate_c_code
let compile_to_c = Statements.compile_to_c