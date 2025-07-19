(** 统一Token映射器接口 - 替代所有分散的token转换逻辑 *)

open Lexer_tokens

(** 数据类型，用于传递token值 *)
type value_data = 
  | Int of int
  | Float of float
  | String of string
  | Bool of bool

(** 统一token映射结果类型 *)
type mapping_result = 
  | Success of token
  | NotFound of string
  | ConversionError of string * string

(** 主要的统一token映射函数 *)
val map_token : string -> value_data option -> mapping_result

(** 便利的token映射函数 *)
val map_int_token : int -> mapping_result
val map_float_token : float -> mapping_result
val map_string_token : string -> mapping_result
val map_bool_token : bool -> mapping_result
val map_chinese_number_token : string -> mapping_result
val map_quoted_identifier_token : string -> mapping_result
val map_special_identifier_token : string -> mapping_result
val map_keyword_token : string -> mapping_result
val map_operator_token : string -> mapping_result

(** 批量映射tokens *)
val map_tokens : (string * value_data option) list -> (string * mapping_result) list

(** 验证映射结果 *)
val validate_mapping_result : mapping_result -> unit
val validate_mapping_results : (string * mapping_result) list -> unit

(** 性能测试 *)
val performance_test : int -> unit

(** 显示所有支持的映射 *)
val show_supported_mappings : unit -> unit