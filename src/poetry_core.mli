(** Poetry_core compatibility module interface - Fix #2055
 * 
 * 提供向后兼容的 Poetry_core 模块接口
 * Author: Whisky, PR Worker
 * Date: 2025-08-02
 *)

(** Poetry types module interface *)
module Poetry_types : sig
  (* 核心类型定义 *)
  type rhyme_category = 
    | PingSheng | ShangSheng | QuSheng | RuSheng
  
  type rhyme_group = 
    | Feng | Hua | Yu | Hui | Jiang | Yue | Other of string
  
  type rhyme_info = {
    category: rhyme_category;
    group: rhyme_group;
    tone_pattern: int option;
    char: string;
  }
  
  type poetry_form = 
    | WuYanLushi | QiYanLushi | WuYanJueju | QiYanJueju | Custom of string
  
  type evaluation_dimension = 
    | Rhyme | Artistic | Form | Content | Sound
  
  type evaluation_result = {
    overall_score: float;
    dimension_scores: (evaluation_dimension * float) list;
    rhyme_quality: float;
    artistic_quality: float;
    form_compliance: float;
    recommendations: string list;
  }
  
  (* 转换函数 *)
  val rhyme_category_to_string : rhyme_category -> string
  val rhyme_group_to_string : rhyme_group -> string
end

(** Rhyme Core API module interface *)
module Rhyme_core_api : sig
  val find_rhyme_info : string -> Poetry_types.rhyme_info option
  val detect_rhyme_category : string -> Poetry_types.rhyme_category
  val check_rhyme_match : string -> string -> bool
  val analyze_line_rhyme : string -> Poetry_types.rhyme_info list
end

(* 兼容函数 *)
val find_rhyme_info : string -> Poetry_types.rhyme_info option
val detect_rhyme_category : string -> Poetry_types.rhyme_category
val check_rhyme_match : string -> string -> bool
val evaluate_poem_basic : string list -> Poetry_types.evaluation_result