(** 简化的Token映射器 - 避免循环依赖的简单实现 *)

(** {1 类型定义} *)

(** 简化的token类型，避免依赖主要的lexer_tokens *)
type simple_token =
  | IntToken of int
  | StringToken of string  
  | KeywordToken of string
  | OperatorToken of string
  | UnknownToken of string

(** Token映射条目 *)
type mapping_entry = {
  name : string;
  category : string;
  description : string;
}

(** {1 映射数据} *)

(** 简单的token映射表 *)
val token_mappings : mapping_entry list

(** {1 映射操作} *)

(** 查找token映射 *)
val find_mapping : string -> mapping_entry option

(** 简单的token转换 *)
val convert_token : string -> int option -> string option -> simple_token

(** {1 统计信息} *)

(** 获取统计信息 *)
val get_stats : unit -> string

(** {1 测试功能} *)

(** 测试函数 *)
val test_mapping : unit -> unit