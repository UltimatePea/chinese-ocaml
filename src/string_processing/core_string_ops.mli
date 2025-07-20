(** 核心字符串处理操作模块
    
    本模块包含了基础的字符串处理和代码解析功能，
    是从原始的超长模块中拆分出来的核心功能。
    
    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** {1 字符串处理框架} *)

(** [process_string_with_skip line skip_logic] 
    通用字符串处理模板，根据跳过逻辑处理字符串
    @param line 要处理的字符串
    @param skip_logic 跳过逻辑函数 (位置 -> 字符串 -> 长度 -> (是否跳过, 跳过长度))
    @return 处理后的字符串 *)
val process_string_with_skip : string -> (int -> string -> int -> bool * int) -> string

(** {1 跳过逻辑函数} *)

(** [block_comment_skip_logic i line len] 
    块注释跳过逻辑，处理 (* ... *) 注释 *)
val block_comment_skip_logic : int -> string -> int -> bool * int

(** [luoyan_string_skip_logic i line len] 
    骆言字符串跳过逻辑，处理中文字符串字面量 *)
val luoyan_string_skip_logic : int -> string -> int -> bool * int

(** [english_string_skip_logic i line len] 
    英文字符串跳过逻辑，处理 "..." 和 '...' 字符串 *)
val english_string_skip_logic : int -> string -> int -> bool * int

(** {1 注释处理函数} *)

(** [remove_double_slash_comment line] 
    移除双斜杠注释 (//) *)
val remove_double_slash_comment : string -> string

(** [remove_hash_comment line] 
    移除井号注释 (#) *)
val remove_hash_comment : string -> string

(** {1 重构后的字符串处理函数} *)

(** [remove_block_comments line] 
    移除块注释的快捷函数 *)
val remove_block_comments : string -> string

(** [remove_luoyan_strings line] 
    移除骆言字符串的快捷函数 *)
val remove_luoyan_strings : string -> string

(** [remove_english_strings line] 
    移除英文字符串的快捷函数 *)
val remove_english_strings : string -> string