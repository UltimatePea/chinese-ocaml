(** 诗词艺术评估统一API入口
    
    此模块提供单一的API入口点，包装所有现有的艺术评估功能。
    保持所有现有算法逻辑不变，仅提供统一的接口访问方式。
    
    Author: Whisky, PR Worker  
    Issue: #2135 - 统一API入口而非算法重写
*)

open Artistic_core_interfaces

(** {1 统一评估API} *)

(** 核心评估功能 - 直接使用现有模块 *)
module ArtisticEvaluation = ArtisticEvaluationAPI

(** 数据访问API - 直接使用现有数据访问功能 *)
module ArtisticData = ArtisticDataAPI

(** 评估引擎API - 直接使用现有引擎功能 *)
module ArtisticEngine = ArtisticEngineAPI

(** {1 向后兼容性API} *)

(** 为现有代码提供直接访问接口 - 保持所有算法复杂度 *)
let evaluate_rhyme_harmony = ArtisticEvaluation.evaluate_rhyme_harmony
let evaluate_tonal_balance = ArtisticEvaluation.evaluate_tonal_balance
let evaluate_parallelism = ArtisticEvaluation.evaluate_parallelism
let evaluate_imagery = ArtisticEvaluation.evaluate_imagery
let evaluate_rhythm = ArtisticEvaluation.evaluate_rhythm
let evaluate_elegance = ArtisticEvaluation.evaluate_elegance
let determine_overall_grade = ArtisticEvaluation.determine_overall_grade

(** 诗词形式评估兼容性接口 *)
let evaluate_poem_artistic = ArtisticEvaluation.evaluate_poem_artistic
let evaluate_siyan_parallel_prose = ArtisticEvaluation.evaluate_siyan_parallel_prose
let evaluate_wuyan_lushi = ArtisticEvaluation.evaluate_wuyan_lushi
let evaluate_qiyan_jueju = ArtisticEvaluation.evaluate_qiyan_jueju
let evaluate_poetry_by_form = ArtisticEvaluation.evaluate_poetry_by_form

(** 数据访问兼容性接口 *)
let initialize = ArtisticData.initialize
let is_initialized = ArtisticData.is_initialized
let get_word_info = ArtisticData.get_word_info
let get_words_by_category = ArtisticData.get_words_by_category  
let assess_word_elegance = ArtisticData.assess_word_elegance
let get_evaluation_standards = ArtisticData.get_evaluation_standards
let get_all_evaluation_dimensions = ArtisticData.get_all_evaluation_dimensions

(** 引擎兼容性接口 *)
let get_standard_weights = ArtisticEngine.get_standard_weights
let calculate_artistic_score = ArtisticEngine.calculate_artistic_score
let suggest_improvements = ArtisticEngine.suggest_improvements
let validate_evaluation_criteria = ArtisticEngine.validate_evaluation_criteria