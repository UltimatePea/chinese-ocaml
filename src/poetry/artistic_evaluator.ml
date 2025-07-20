(* 诗词艺术性评价器主接口模块
   
   承古典诗学传统，建现代评价体系。整合各专门模块，
   提供统一的诗词艺术性评价接口。
   
   此模块为重构后的主接口，保持与原有API的完全兼容性。 *)

(* 重新导出核心类型，保持API兼容性 *)
include Artistic_evaluator_types

(* 重新导出上下文管理功能 *)
module Context = Artistic_evaluator_context

(* 重新导出各类评价器 *)
module Sound = Artistic_evaluator_sound
module Form = Artistic_evaluator_form  
module Content = Artistic_evaluator_content

(* 重新导出综合评价器 *)
include Artistic_evaluator_comprehensive

(* 为保持向后兼容，提供原有接口的别名 *)
let create_evaluation_context = Context.create_evaluation_context
let get_char_tone = Context.get_char_tone

(* 重新导出主要评价器模块，保持原有调用方式 *)
module RhymeEvaluator = Sound.RhymeEvaluator
module ToneEvaluator = Sound.ToneEvaluator
module ParallelismEvaluator = Form.ParallelismEvaluator
module ImageryEvaluator = Content.ImageryEvaluator
module RhythmEvaluator = Form.RhythmEvaluator  
module EleganceEvaluator = Form.EleganceEvaluator