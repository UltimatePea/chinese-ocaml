(** 简化的Token映射器 - 避免循环依赖的简单实现 *)

(** {1 类型定义} *)

(** 简化的token类型，避免依赖主要的lexer_tokens *)
type simple_token =
  | IntToken of int
  | StringToken of string
  | KeywordToken of string
  | OperatorToken of string
  | UnknownToken of string

type mapping_entry = { name : string; category : string; description : string }
(** Token映射条目 *)

(** {1 映射数据} *)

val token_mappings : mapping_entry list
(** 简单的token映射表 *)

(** {1 映射操作} *)

val find_mapping : string -> mapping_entry option
(** 查找token映射 *)

val convert_token : string -> int option -> string option -> simple_token
(** 简单的token转换 *)

(** {1 统计信息} *)

val get_stats : unit -> string
(** 获取统计信息 *)

(** {1 测试功能} *)

val test_mapping : unit -> unit
(** 测试函数 *)
