(* 诗词声律评价器模块接口 *)

open Artistic_evaluator_types

(* 韵律评价器 *)
module RhymeEvaluator : EVALUATOR

(* 声调评价器 *)
module ToneEvaluator : EVALUATOR
