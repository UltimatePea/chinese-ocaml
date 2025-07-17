(** 骆言C代码生成器上下文模块接口 - Chinese Programming Language C Code Generator Context Module Interface *)

(** 代码生成配置 *)
type codegen_config = {
  c_output_file : string;
  include_debug : bool;
  optimize : bool;
  runtime_path : string;
}

(** 代码生成上下文 *)
type codegen_context = {
  config : codegen_config;
  mutable next_var_id : int;
  mutable next_label_id : int;
  mutable includes : string list;
  mutable global_vars : string list;
  mutable functions : string list;
}

(** 创建代码生成上下文 *)
val create_context : codegen_config -> codegen_context

(** 生成唯一变量名 *)
val gen_var_name : codegen_context -> string -> string

(** 生成唯一标签名 *)
val gen_label_name : codegen_context -> string -> string

(** 转义标识符名称 *)
val escape_identifier : string -> string

(** 将骆言类型转换为C类型 *)
val c_type_of_luoyan_type : Types.typ -> string