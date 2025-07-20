(* 诗词评价上下文管理模块接口 *)

open Artistic_evaluator_types

(* 创建评价上下文 *)
val create_evaluation_context : string -> evaluation_context

(* 获取字符声调 *)
val get_char_tone : evaluation_context -> string -> Tone_data.tone_type option

(* 获取上下文基本信息 *)
val get_verse : evaluation_context -> string
val get_char_count : evaluation_context -> int
val get_char_list : evaluation_context -> string list