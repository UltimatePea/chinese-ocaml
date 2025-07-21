(** 骆言C代码生成器模式匹配模块 - C Code Generator Patterns Module *)

open Ast
open C_codegen_context
open String_formatter

(** 生成字面量模式检查代码 *)
let gen_literal_pattern_check expr_var = function
  | IntLit i -> CCodegen.format_equality_check expr_var (CCodegen.format_int_literal i)
  | StringLit s -> CCodegen.format_equality_check expr_var (CCodegen.format_string_literal s)
  | BoolLit b -> CCodegen.format_equality_check expr_var (CCodegen.format_bool_literal b)
  | UnitLit -> CCodegen.format_equality_check expr_var (CCodegen.format_unit_literal ())
  | FloatLit f -> CCodegen.format_equality_check expr_var (CCodegen.format_float_literal f)

(** 生成变量模式检查代码 *)
let gen_var_pattern_check expr_var var_name =
  let escaped_var = escape_identifier var_name in
  CCodegen.format_var_binding escaped_var expr_var

(** 生成模式检查代码 - 简化版本 *)
let gen_pattern_check _ctx expr_var pattern =
  match pattern with
  | LitPattern lit -> gen_literal_pattern_check expr_var lit
  | VarPattern name -> gen_var_pattern_check expr_var name
  | WildcardPattern -> "1" (* Always matches *)
  | ConstructorPattern (constructor_name, _) ->
      let escaped_constructor = escape_identifier constructor_name in
      Printf.sprintf "luoyan_match_constructor(%s, \"%s\")" expr_var escaped_constructor
  | _ -> CCodegen.format_pattern_match expr_var (* 简化其他模式 *)
