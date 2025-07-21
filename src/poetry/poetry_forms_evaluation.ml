(** 不同诗词形式评价模块 - 针对特定诗词体裁的评价函数 *)

(* 重新导出各专门模块的功能以保持向后兼容 *)

(* 导出评价框架相关功能 *)
module EvaluationFramework = Evaluation_framework

(* 导出所有具体评价函数 *)
let evaluate_wuyan_lushi = Form_evaluators.evaluate_wuyan_lushi
let evaluate_qiyan_jueju = Form_evaluators.evaluate_qiyan_jueju
let evaluate_siyan_pianti = Form_evaluators.evaluate_siyan_pianti
let evaluate_cipai = Form_evaluators.evaluate_cipai
let evaluate_modern_poetry = Form_evaluators.evaluate_modern_poetry
let evaluate_siyan_parallel_prose = Form_evaluators.evaluate_siyan_parallel_prose

(* 导出诗词形式分发功能 *)
let evaluate_poetry_by_form = Poetry_form_dispatch.evaluate_poetry_by_form
