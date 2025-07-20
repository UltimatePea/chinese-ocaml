(* 数据加载器验证模块接口 *)

open Data_loader_types

(** 验证字符串列表 *)
val validate_string_list : string list -> string list data_result

(** 验证词性数据对 *)
val validate_word_class_pairs : (string * string) list -> (string * string) list data_result

(** 验证键值对数据 *)
val validate_key_value_pairs : (string * string) list -> (string * string) list data_result

(** 验证非空列表 *)
val validate_non_empty_list : 'a list -> 'a list data_result