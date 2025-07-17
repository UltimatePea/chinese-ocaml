(** 字符串处理工具函数模块
    提供通用的字符串处理功能，减少代码重复 *)

(** 字符串处理的通用模板
    @param line 待处理的字符串
    @param skip_logic 跳过逻辑函数，返回 (是否跳过, 跳过长度) *)
val process_string_with_skip : string -> (int -> string -> int -> bool * int) -> string

(** 移除块注释 (* ... *) *)
val remove_block_comments : string -> string

(** 移除骆言字符串 『...』 *)
val remove_luoyan_strings : string -> string

(** 移除英文字符串 "..." 和 '...' *)
val remove_english_strings : string -> string

(** 移除双斜杠注释 // *)
val remove_double_slash_comment : string -> string

(** 移除井号注释 # *)
val remove_hash_comment : string -> string