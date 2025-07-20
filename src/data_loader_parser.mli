(* 数据加载器JSON解析模块接口 *)

(** 解析字符串数组 *)
val parse_string_array : string -> string list

(** 解析键值对数组 - 用于词性数据 *)
val parse_word_class_pairs : string -> (string * string) list

(** 解析简单的键值对 JSON 对象 *)
val parse_simple_object : string -> (string * string) list

(** 去除空白字符 *)
val trim_whitespace : string -> string