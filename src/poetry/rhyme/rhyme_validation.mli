(** 韵律验证模块接口

    本模块整合了原本分散的韵律验证逻辑，提供统一的验证接口。

    Author: Whisky, PR Worker Issue: #1999 - Poetry韵律模块统一整合实施
    @since 2025-08-04 *)

open Rhyme_types

(** {1 基础验证函数} *)

val is_valid_rhyme_character : string -> bool
(** 验证字符是否为有效的韵律字符 *)

val validate_tone_category : string -> tone_category -> bool
(** 验证声调分类是否正确 *)

val validate_rhyme_group : string -> rhyme_group -> bool
(** 验证韵组分类是否正确 *)

(** {1 韵律匹配验证} *)

val validate_rhyme_match : string -> string -> bool
(** 验证两个字符是否押韵 *)

val validate_same_rhyme : string list -> bool
(** 验证字符列表是否同韵 *)

val validate_ping_ze_pattern : string list -> bool list -> bool
(** 验证平仄搭配是否合理，参数为 (字符列表, 期望平仄模式) *)

(** {1 数据完整性验证} *)

val validate_rhyme_data : unit -> string list
(** 验证韵组数据完整性，返回问题列表 *)

val validate_group_consistency : rhyme_group -> string list
(** 验证韵组内部一致性，返回问题列表 *)

(** {1 验证报告生成} *)

val generate_validation_report : unit -> string
(** 生成完整的验证报告 *)

(** {1 快速验证接口} *)

val quick_validate : unit -> bool
(** 快速验证所有数据是否正常 *)

val get_validation_error_count : unit -> int
(** 获取验证错误总数 *)
