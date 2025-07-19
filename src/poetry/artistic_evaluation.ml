(* 诗词艺术性评价模块 - 骆言诗词编程特性
   古之诗者，不仅求格律之正，更求意境之美。音韵和谐，对仗工整，方为佳作。
   此模块专司诗词艺术性评价，综合音韵、对仗、意境等因素，为诗词创作提供全面指导。
   既遵古制，又开新风，助力程序员书写诗意代码。

   注意：核心评价功能已重构到独立模块：
   - Artistic_evaluators: 核心评价算法
   - Poetry_forms_evaluation: 特定诗词形式评价  
   - Artistic_guidance: 指导建议生成
*)

(* 重新导出核心功能模块，保持向后兼容性 *)
module Evaluators = Artistic_evaluators
module FormsEvaluation = Poetry_forms_evaluation
module Guidance = Artistic_guidance

(* 兼容性导出：保持现有API接口不变 *)
let evaluate_rhyme_harmony = Artistic_evaluators.evaluate_rhyme_harmony
let evaluate_tonal_balance = Artistic_evaluators.evaluate_tonal_balance
let evaluate_parallelism = Artistic_evaluators.evaluate_parallelism
let evaluate_imagery = Artistic_evaluators.evaluate_imagery
let evaluate_rhythm = Artistic_evaluators.evaluate_rhythm
let evaluate_elegance = Artistic_evaluators.evaluate_elegance
let determine_overall_grade = Artistic_evaluators.determine_overall_grade
let generate_improvement_suggestions = Artistic_guidance.generate_improvement_suggestions
let comprehensive_artistic_evaluation = Artistic_guidance.comprehensive_artistic_evaluation
let poetic_critique = Artistic_guidance.poetic_critique
let poetic_aesthetics_guidance = Artistic_guidance.poetic_aesthetics_guidance
let evaluate_wuyan_lushi = Poetry_forms_evaluation.evaluate_wuyan_lushi
let evaluate_qiyan_jueju = Poetry_forms_evaluation.evaluate_qiyan_jueju
let evaluate_siyan_parallel_prose = Poetry_forms_evaluation.evaluate_siyan_parallel_prose
let evaluate_poetry_by_form = Poetry_forms_evaluation.evaluate_poetry_by_form

(* 模块初始化标记 *)
let () = ()
