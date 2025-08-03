(** 诗词艺术评估统一类型系统
    
    此模块整合现有类型定义，提供统一的类型接口。
    所有类型定义都是对现有模块的重新导出，保持100%兼容性。
    
    Author: Whisky, PR Worker
    Issue: #2135 - 类型系统统一
*)

(** {1 核心类型重新导出} *)

(* 从 Poetry_core.Types 导入所有艺术评估相关类型 *)
include Poetry_core.Types

(** {1 额外类型从 Artistic_core_types} *)

(* 从 Poetry.Artistic_core_types 导入特定的数据访问类型 *)
type word_category = Poetry.Artistic_core_types.word_category =
  | Imagery
  | Elegant  
  | Metaphor
  | Emotion
  | Nature
  | Classical

type evaluation_dimension = Poetry.Artistic_core_types.evaluation_dimension =
  | RhymeHarmony
  | TonalBalance
  | Parallelism
  | ImageryDepth
  | FormBeauty
  | ContentDepth
  | MoodContext

type word_info = Poetry.Artistic_core_types.word_info = {
  word : string;
  category : word_category;
  frequency : int;
  artistic_value : float;
  synonyms : string list;
  contexts : string list;
  examples : string list;
}

type evaluation_standard = Poetry.Artistic_core_types.evaluation_standard = {
  dimension : evaluation_dimension;
  name : string;
  description : string;
  weight : float;
  min_score : float;
  max_score : float;
  criteria : (string * float) list;
}

type artistic_template = Poetry.Artistic_core_types.artistic_template = {
  name : string;
  category : word_category;
  pattern : string;
  examples : string list;
  effectiveness : float;
}

type 'a query_result = 'a Poetry.Artistic_core_types.query_result =
  | Found of 'a
  | NotFound
  | QueryError of string

(** {1 类型转换函数} *)

(* 重新导出现有的转换函数 *)
let word_category_from_string = Poetry.Artistic_core_types.word_category_from_string
let evaluation_dimension_from_string = Poetry.Artistic_core_types.evaluation_dimension_from_string
let get_all_evaluation_dimensions = Poetry.Artistic_core_types.get_all_evaluation_dimensions

(* 从 Poetry_core.Types 导入的转换函数 *)
let grade_to_string = string_of_evaluation_grade
let form_to_string = poetry_form_to_string