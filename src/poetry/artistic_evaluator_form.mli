(* 诗词形式评价器模块接口 *)

open Artistic_evaluator_types

(* 对仗评价器 *)
module ParallelismEvaluator : EVALUATOR

(* 节奏评价器 *)
module RhythmEvaluator : EVALUATOR

(* 雅致评价器 *)
module EleganceEvaluator : EVALUATOR