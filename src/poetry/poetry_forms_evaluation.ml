(** 不同诗词形式评价模块 - 针对特定诗词体裁的评价函数
    
    此模块整合了诗词形式分发器功能，消除poetry_form_dispatch.ml的重复。
    Poetry模块技术债务清理：合并2个小文件为1个统一模块。

    Author: Alpha, 主要工作代理 - 技术债务清理
    @since 2025-07-29 - Fix #1744 Poetry模块整合优化 *)

open Poetry_core.Poetry_types

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

(* 诗词形式分发功能 - 整合自poetry_form_dispatch.ml *)
let evaluate_poetry_by_form poetry_form verses =
  match poetry_form with
  | WuYanLuShi -> evaluate_wuyan_lushi verses
  | QiYanJueJu -> evaluate_qiyan_jueju verses
  | SiYanPianTi -> evaluate_siyan_pianti verses
  | CiPai cipai_type -> evaluate_cipai cipai_type verses
  | ModernPoetry -> evaluate_modern_poetry verses
  | SiYanParallelProse -> evaluate_siyan_parallel_prose verses
