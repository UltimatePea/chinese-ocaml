(** 通用验证工具模块接口 - 消除项目中重复的验证模式 *)

(** 通用验证结果类型 *)
type 'a validation_result = Valid of 'a | Invalid of string

val ( >>= ) : 'a validation_result -> ('a -> 'b validation_result) -> 'b validation_result
(** 验证器组合器 *)

val return : 'a -> 'a validation_result

val validate_non_empty_string : string -> string validation_result
(** 基础验证函数 *)

val validate_non_empty_list : 'a list -> 'a list validation_result

val is_valid_chinese_char : string -> bool
(** 中文字符验证 *)

val validate_chinese_string : string -> string validation_result

val validate_in_range : int -> int -> int -> int validation_result
(** 范围验证 *)

val validate_non_negative : int -> int validation_result

val validate_all_elements : ('a -> 'b validation_result) -> 'a list -> 'b list validation_result
(** 列表验证工具 *)

val validate_list_with_predicate : ('a -> bool) -> string -> 'a list -> 'a list validation_result

val validate_key_value_pair : string * string -> (string * string) validation_result
(** 键值对验证 *)

val validate_key_value_pairs : (string * string) list -> (string * string) list validation_result

val combine_validators :
  ('a -> 'b validation_result) -> ('a -> 'c validation_result) -> 'a -> 'c validation_result
(** 组合验证器 *)

val optional_validator : ('a -> 'b validation_result) -> 'a option -> 'b option validation_result
(** 可选验证器 *)

val validation_result_to_option : 'a validation_result -> 'a option
(** 结果转换工具 *)

val validation_result_to_bool : 'a validation_result -> bool

val collect_validation_errors : ('a -> 'b validation_result) list -> 'a -> string list
(** 错误聚合 *)

val validate_batch : (('a -> 'b validation_result) * 'a) list -> 'b list validation_result
(** 批量验证 *)
