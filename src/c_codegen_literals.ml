(** 骆言C代码生成器字面量模块 - C Code Generator Literals Module *)

open Ast
open C_codegen_context
open Error_utils

(** 初始化模块日志器 *)
let[@warning "-32"] log_info = Logger_utils.init_info_logger "CCodegenLiterals"

(** 生成基本字面量和变量表达式代码 *)
let gen_literal_and_vars _ctx expr =
  match expr with
  | LitExpr (IntLit i) -> Printf.sprintf "luoyan_int(%dL)" i
  | LitExpr (FloatLit f) -> Printf.sprintf "luoyan_float(%g)" f
  | LitExpr (StringLit s) ->
      (* 对于C代码生成，我们需要保持UTF-8字符串原样，只转义必要的字符 *)
      let escape_for_c str =
        let buf = Buffer.create (String.length str * 2) in
        String.iter
          (function
            | '"' -> Buffer.add_string buf "\\\""
            | '\\' -> Buffer.add_string buf "\\\\"
            | '\n' -> Buffer.add_string buf "\\n"
            | '\r' -> Buffer.add_string buf "\\r"
            | '\t' -> Buffer.add_string buf "\\t"
            | c -> Buffer.add_char buf c)
          str;
        Buffer.contents buf
      in
      Printf.sprintf "luoyan_string(\"%s\")" (escape_for_c s)
  | LitExpr (BoolLit b) -> Printf.sprintf "luoyan_bool(%s)" (if b then "true" else "false")
  | LitExpr UnitLit -> "luoyan_unit()"
  | VarExpr name ->
      let escaped_name = escape_identifier name in
      Printf.sprintf "luoyan_env_lookup(env, \"%s\")" escaped_name
  | _ -> fail_unsupported_expression_with_function "gen_literal_and_vars" LiteralAndVars
