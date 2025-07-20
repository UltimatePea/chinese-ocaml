(** Token注册器 - 代码生成和转换功能接口 *)

open Token_registry_core

val generate_token_code_by_category : token_mapping_entry -> string
(** 根据分类生成Token代码 *)

val generate_token_converter : unit -> string
(** 生成token转换函数 *)