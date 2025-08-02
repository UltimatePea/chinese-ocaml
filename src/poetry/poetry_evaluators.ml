(** Poetry_evaluators stub module - Fix Issue #2055
 * 
 * 诗词评价器存根模块，解决编译依赖问题
 * Author: Whisky, PR Worker  
 * Date: 2025-08-02
 *)

module Evaluator_types = struct
  type artistic_evaluation = {
    overall_score: float;
    rhyme_quality: float;
    artistic_merit: float;
    form_compliance: float;
  }
  
  type artistic_scores = {
    content_depth: float;
    imagery_quality: float;
    emotional_resonance: float;
    language_beauty: float;
  }
  
  type evaluation_grade = 
    | Excellent | Good | Fair | Poor
    
  type evaluation_dimension = 
    | Rhyme | Artistic | Form | Content | Sound
end