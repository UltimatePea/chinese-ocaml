(** 骆言C代码生成器模式匹配模块 - C Code Generator Patterns Module *)

open Ast
open C_codegen_context

(** 生成字面量模式检查代码 *)
let gen_literal_pattern_check expr_var = function
  | IntLit i -> Printf.sprintf "luoyan_equals(%s, luoyan_int(%d))" expr_var i
  | StringLit s ->
      Printf.sprintf "luoyan_equals(%s, luoyan_string(\"%s\"))" expr_var (String.escaped s)
  | BoolLit b ->
      Printf.sprintf "luoyan_equals(%s, luoyan_bool(%s))" expr_var (if b then "true" else "false")
  | UnitLit -> Printf.sprintf "luoyan_equals(%s, luoyan_unit())" expr_var
  | FloatLit f -> Printf.sprintf "luoyan_equals(%s, luoyan_float(%g))" expr_var f

(** 生成变量模式检查代码 *)
let gen_var_pattern_check expr_var var_name =
  let escaped_var = escape_identifier var_name in
  Printf.sprintf "luoyan_bind_var(\"%s\", %s)" escaped_var expr_var

(** 生成模式检查代码 - 简化版本 *)
let gen_pattern_check _ctx expr_var pattern =
  match pattern with
  | LitPattern lit -> gen_literal_pattern_check expr_var lit
  | VarPattern name -> gen_var_pattern_check expr_var name
  | WildcardPattern -> "1" (* Always matches *)
  | _ -> Printf.sprintf "luoyan_pattern_match(%s)" expr_var (* 简化其他模式 *)
