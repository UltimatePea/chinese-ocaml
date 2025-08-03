(** 诗词艺术评估核心接口定义模块
    
    此模块提供标准化的艺术评估接口，作为现有模块的统一API层。
    保持所有现有的中文诗词处理算法不变，仅提供接口标准化。
    
    Author: Whisky, PR Worker
    Issue: #2135 - 接口标准化而非算法重写
*)

(** {1 类型导入} *)

(* 从现有模块导入所有类型，保持完整功能 *)
include Poetry_core.Types

(** {1 核心评估接口重新导出} *)

(** 直接重新导出现有的艺术评估函数，保持原始签名 *)
module ArtisticEvaluationAPI = struct
  (* 重新导出所有现有的评估函数，保持原始复杂的算法逻辑 *)
  let evaluate_rhyme_harmony = Poetry.Artistic_evaluators.evaluate_rhyme_harmony
  let evaluate_tonal_balance = Poetry.Artistic_evaluators.evaluate_tonal_balance
  let evaluate_parallelism = Poetry.Artistic_evaluators.evaluate_parallelism
  let evaluate_imagery = Poetry.Artistic_evaluators.evaluate_imagery
  let evaluate_rhythm = Poetry.Artistic_evaluators.evaluate_rhythm
  let evaluate_elegance = Poetry.Artistic_evaluators.evaluate_elegance
  let determine_overall_grade = Poetry.Artistic_evaluators.determine_overall_grade
  
  (* 重新导出诗词形式评估 *)
  let evaluate_poem_artistic = Poetry.Artistic_evaluators.evaluate_poem_artistic
  let evaluate_siyan_parallel_prose = Poetry.Artistic_evaluators.evaluate_siyan_parallel_prose
  let evaluate_wuyan_lushi = Poetry.Artistic_evaluators.evaluate_wuyan_lushi
  let evaluate_qiyan_jueju = Poetry.Artistic_evaluators.evaluate_qiyan_jueju
  let evaluate_poetry_by_form = Poetry.Artistic_evaluators.evaluate_poetry_by_form
end

(** {1 数据访问接口重新导出} *)

(** 直接重新导出现有的数据访问功能 *)
module ArtisticDataAPI = struct
  (* 重新导出所有现有的数据访问函数 *)
  let initialize = Poetry.Artistic_data_accessor.initialize
  let is_initialized = Poetry.Artistic_data_accessor.is_initialized
  let get_word_info = Poetry.Artistic_data_accessor.get_word_info
  let get_words_by_category = Poetry.Artistic_data_accessor.get_words_by_category
  let assess_word_elegance = Poetry.Artistic_data_accessor.assess_word_elegance
  let get_evaluation_standards = Poetry.Artistic_data_accessor.get_evaluation_standards
  let get_all_evaluation_dimensions = Poetry.Artistic_data_accessor.get_all_evaluation_dimensions
  let get_standard_weights = Poetry.Artistic_data_accessor.get_standard_weights
end

(** {1 评估引擎接口重新导出} *)

(** 直接重新导出现有的评估引擎功能 *)
module ArtisticEngineAPI = struct
  (* 重新导出所有现有的引擎函数 *)
  let get_standard_weights = Poetry.Artistic_evaluation_engine.get_standard_weights
  let calculate_artistic_score = Poetry.Artistic_evaluation_engine.calculate_artistic_score
  let suggest_improvements = Poetry.Artistic_evaluation_engine.suggest_improvements
  let validate_evaluation_criteria = Poetry.Artistic_evaluation_engine.validate_evaluation_criteria
end