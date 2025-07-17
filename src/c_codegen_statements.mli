(** 骆言C代码生成器语句模块接口 - Chinese Programming Language C Code Generator Statement Module Interface *)

open Ast
open C_codegen_context

(** 生成语句代码 *)
val gen_stmt : codegen_context -> stmt -> string

(** 生成程序代码 *)
val gen_program : codegen_context -> program -> string

(** 生成完整的C代码 *)
val generate_c_code : codegen_config -> program -> string

(** 编译为C代码 *)
val compile_to_c : codegen_config -> program -> (unit, Compiler_errors.compiler_error) result