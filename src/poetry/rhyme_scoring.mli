(* 韵律评分系统模块接口 - 骆言诗词编程特性
   专司韵律质量之评定，衡量诗词之工拙。
   此接口定义韵律评分相关函数的类型签名。
*)

(* 检测押韵质量：评估韵脚的和谐程度 *)
val evaluate_rhyme_quality : string list -> float

(* 韵律丰富度评分：评估韵律的多样性 *)
val evaluate_rhyme_diversity : string list -> float

(* 韵律规整度评分：评估韵律的规整程度 *)
val evaluate_rhyme_regularity : string list -> float

(* 韵律协调度评分：评估韵律的协调程度 *)
val evaluate_rhyme_harmony : string list -> float

(* 韵律完整度评分：评估韵律的完整程度 *)
val evaluate_rhyme_completeness : string list -> float

(* 韵律评分详细报告类型 *)
type rhyme_score_report = {
  overall_quality : float;
  diversity_score : float;
  regularity_score : float;
  harmony_score : float;
  completeness_score : float;
  consistency_score : float;
  verse_count : int;
  rhymed_count : int;
  pattern_type : string option;
}

(* 生成综合韵律评分报告：对诗词进行全面的韵律评估 *)
val generate_comprehensive_score : string list -> rhyme_score_report

(* 评分等级定义 *)
type score_grade =
  | Excellent (* 优秀 - 90分以上 *)
  | Good (* 良好 - 80-90分 *)
  | Average (* 一般 - 70-80分 *)
  | Poor (* 较差 - 60-70分 *)
  | VeryPoor (* 很差 - 60分以下 *)

(* 将评分转换为等级 *)
val score_to_grade : float -> score_grade

(* 等级转换为字符串 *)
val grade_to_string : score_grade -> string

(* 生成评分建议：根据评分结果提供改进建议 *)
val generate_improvement_suggestions : rhyme_score_report -> string list

(* 快速韵律质量检查：提供快速的韵律质量评估 *)
val quick_quality_check : string list -> float * string

(* 韵律质量比较：比较两组诗词的韵律质量 *)
val compare_rhyme_quality : string list -> string list -> int
