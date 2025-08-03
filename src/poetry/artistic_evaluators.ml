(** 向后兼容性层 - 重新导出 poetry_artistic 库中的函数
 * 
 * 此文件提供向后兼容性，使现有代码能够继续使用 Artistic_evaluators 模块，
 * 而实际实现已移至 src/poetry/artistic/ 子库中。
 * 
 * Author: Whisky, PR Worker - Fix #2000 Delta Review Response
 *)

(* 重新导出主要的评估函数 *)
include Poetry_artistic.Artistic_evaluators

(* 兼容性别名 *)
let evaluate_poem_artistic = comprehensive_artistic_evaluation_legacy