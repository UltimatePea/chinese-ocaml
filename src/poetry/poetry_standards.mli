(** 骆言诗词格律标准定义模块接口 *)

open Artistic_types

(** 预定义的标准 *)
val siyan_standards : siyan_artistic_standards
val wuyan_lushi_standards : wuyan_lushi_standards
val qiyan_jueju_standards : qiyan_jueju_standards

(** 根据诗词形式获取对应的评价标准 *)
val get_standards_for_form : poetry_form -> 
  [`SiYan of siyan_artistic_standards | `WuYan of wuyan_lushi_standards | `QiYan of qiyan_jueju_standards] option

(** 标准验证器 *)
module StandardsValidator : sig
  val validate_siyan_format : string list -> bool
  val validate_wuyan_lushi_format : string list -> bool
  val validate_qiyan_jueju_format : string list -> bool
  val validate_format : poetry_form -> string list -> bool
end

(** 标准配置工具 *)
module StandardsConfig : sig
  val get_default_rhythm_weight : poetry_form -> float
  val get_expected_line_count : poetry_form -> int option
  val get_expected_chars_per_line : poetry_form -> int option
  val requires_parallelism : poetry_form -> bool
end

(** 标准创建器 *)
module StandardsBuilder : sig
  val create_siyan_standards : 
    char_count:int -> tone_pattern:bool list -> parallelism_required:bool -> rhythm_weight:float -> 
    siyan_artistic_standards
  
  val create_wuyan_lushi_standards :
    line_count:int -> char_per_line:int -> rhyme_scheme:bool array -> 
    parallelism_required:bool array -> tone_pattern:bool list list -> rhythm_weight:float ->
    wuyan_lushi_standards
  
  val create_qiyan_jueju_standards :
    line_count:int -> char_per_line:int -> rhyme_scheme:bool array -> 
    parallelism_required:bool array -> tone_pattern:bool list list -> rhythm_weight:float ->
    qiyan_jueju_standards
end

(** 标准比较器 *)
module StandardsComparator : sig
  val compare_siyan_standards : siyan_artistic_standards -> siyan_artistic_standards -> float
  val get_strictness_score : poetry_form -> float
end