(** 诗词形式分发器模块 - 根据诗词形式选择相应的评价函数 *)

open Artistic_types
open Form_evaluators

(** 根据诗词形式选择相应的评价函数 *)
let evaluate_poetry_by_form poetry_form verses =
  match poetry_form with
  | WuYanLuShi -> evaluate_wuyan_lushi verses
  | QiYanJueJu -> evaluate_qiyan_jueju verses
  | SiYanPianTi -> evaluate_siyan_pianti verses
  | CiPai cipai_type -> evaluate_cipai cipai_type verses
  | ModernPoetry -> evaluate_modern_poetry verses
  | SiYanParallelProse -> evaluate_siyan_parallel_prose verses