(* 数据加载器类型定义模块接口 *)

(** 数据加载器的错误类型 *)
type data_error =
  | FileNotFound of string
  | ParseError of string * string
  | ValidationError of string * string

(** 数据加载结果 *)
type 'a data_result = Success of 'a | Error of data_error

type 'a cache_entry = { data : 'a; timestamp : float }
(** 缓存条目类型 *)
