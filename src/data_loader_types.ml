(* 数据加载器类型定义模块
   
   定义数据加载器所需的基础类型和数据结构。 *)

(** 数据加载器的错误类型 *)
type data_error =
  | FileNotFound of string
  | ParseError of string * string  (** 文件名 * 错误信息 *)
  | ValidationError of string * string  (** 数据类型 * 错误详情 *)

(** 数据加载结果 *)
type 'a data_result = Success of 'a | Error of data_error

type 'a cache_entry = { data : 'a; timestamp : float }
(** 缓存条目类型 *)
