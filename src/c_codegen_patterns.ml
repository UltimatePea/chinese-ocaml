(** 骆言C代码生成器模式匹配模块 - C Code Generator Patterns Module *)

open Ast
open C_codegen_context

(** 生成字面量模式检查代码 *)
let gen_literal_pattern_check expr_var = function
  | IntLit i ->
      String_formatter.CCodegen.format_equality_check expr_var
        (String_formatter.CCodegen.format_int_literal i)
  | StringLit s ->
      String_formatter.CCodegen.format_equality_check expr_var
        (String_formatter.CCodegen.format_string_literal s)
  | BoolLit b ->
      String_formatter.CCodegen.format_equality_check expr_var
        (String_formatter.CCodegen.format_bool_literal b)
  | UnitLit ->
      String_formatter.CCodegen.format_equality_check expr_var
        (String_formatter.CCodegen.format_unit_literal ())
  | FloatLit f ->
      String_formatter.CCodegen.format_equality_check expr_var
        (String_formatter.CCodegen.format_float_literal f)

(** 生成变量模式检查代码 *)
let gen_var_pattern_check expr_var var_name =
  let escaped_var = escape_identifier var_name in
  String_formatter.CCodegen.format_var_binding escaped_var expr_var

(** 生成模式检查代码 - 简化版本 *)
let gen_pattern_check _ctx expr_var pattern =
  match pattern with
  | LitPattern lit -> gen_literal_pattern_check expr_var lit
  | VarPattern name -> gen_var_pattern_check expr_var name
  | WildcardPattern -> "1" (* Always matches *)
  | ConstructorPattern (constructor_name, _) ->
      let escaped_constructor = escape_identifier constructor_name in
      Formatter_codegen.CCodegen.luoyan_match_constructor expr_var escaped_constructor
  | _ -> String_formatter.CCodegen.format_pattern_match expr_var (* 简化其他模式 *)
