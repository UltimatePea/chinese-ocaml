(** 韵律高级分析模块接口

    提供高级的韵律分析功能，包括文本韵律模式分析、统计信息生成等。 *)

open Rhyme_types

(** {1 高级韵律分析函数} *)

val analyze_rhyme_pattern : string -> (rhyme_category * int) list * (rhyme_group * int) list
(** 分析文本的韵律模式 *)

val get_rhyme_stats : unit -> (string * int) list
(** 获取韵律数据统计信息 *)

val analyze_poem_line_structure :
  string -> (string * (rhyme_category * rhyme_group) option * string) list
(** 分析诗句的韵律结构 *)

val detect_poem_rhyme_scheme : string list -> (int * rhyme_group) list
(** 检测诗句间的押韵关系 *)

val evaluate_rhyme_quality : string -> float
(** 评估文本的韵律质量 *)

val suggest_rhyming_chars : string -> string list -> string list
(** 建议押韵字符 *)
