(** 诗词艺术评估核心接口定义模块 - Issue #2135 整合实施
 *
 * 此文件为Issue #2000-A的核心接口定义模块，建立统一的艺术评估API架构。
 * 整合了以下功能的接口定义：
 * - 艺术评估引擎接口
 * - 评估器类型接口
 * - 数据访问器接口
 * - 评估标准接口
 *
 * 真正整合：合并功能 + 删除原文件
 * 
 * @consolidation_issue #2135 (子任务 #2000-A)
 * @author Whisky, PR Worker
 * @since 2025-08-03
 *)

open Poetry_core.Poetry_types

(** {1 核心评估接口定义} *)

(** 艺术评估维度类型 - 重新导出core类型保持一致性 *)
type evaluation_dimension = Poetry_core.Poetry_types.artistic_dimension

(** 评估结果类型 *)
type evaluation_result = {
  dimension: evaluation_dimension;
  score: float;
  feedback: string;
  suggestions: string list;
}

(** 查询结果类型 *)
type 'a query_result =
  | Found of 'a
  | NotFound
  | Error of string

(** 综合艺术评估结果 *)
type comprehensive_evaluation = {
  individual_scores: evaluation_result list;
  overall_score: float;
  grade: evaluation_grade;
  summary: string;
  improvement_suggestions: string list;
}

(** {1 评估引擎接口} *)

(** 艺术评估引擎签名 *)
module type ARTISTIC_EVALUATION_ENGINE = sig
  (** 评估文本的艺术性 *)
  val evaluate_artistic_quality : string -> comprehensive_evaluation query_result
  
  (** 按维度评估 *)
  val evaluate_by_dimension : string -> evaluation_dimension -> evaluation_result query_result
  
  (** 比较两个文本的艺术质量 *)
  val compare_artistic_quality : string -> string -> (evaluation_dimension * float * float) list query_result
  
  (** 获取改进建议 *)
  val get_improvement_suggestions : string -> evaluation_dimension list -> string list query_result
end

(** {1 评估器接口} *)

(** 单维度评估器签名 *)
module type DIMENSION_EVALUATOR = sig
  (** 评估器支持的维度 *)
  val supported_dimension : evaluation_dimension
  
  (** 评估文本在此维度的得分 *)
  val evaluate : string -> float query_result
  
  (** 生成评估反馈 *)
  val generate_feedback : string -> float -> string query_result
  
  (** 生成改进建议 *)
  val suggest_improvements : string -> float -> string list query_result
end

(** 形式评估器签名 *)
module type FORM_EVALUATOR = sig
  (** 支持的诗词形式 *)
  val supported_forms : poetry_form list
  
  (** 评估诗词形式规范性 *)
  val evaluate_form_compliance : poetry_form -> string list -> float query_result
  
  (** 识别诗词形式 *)
  val identify_form : string list -> poetry_form option query_result
end

(** {1 数据管理接口} *)

(** 艺术数据访问器签名 *)
module type ARTISTIC_DATA_ACCESSOR = sig
  (** 加载艺术评估数据 *)
  val load_evaluation_data : unit -> bool query_result
  
  (** 获取标准权重配置 *)
  val get_standard_weights : evaluation_dimension -> float query_result
  
  (** 获取维度评估标准 *)
  val get_dimension_criteria : evaluation_dimension -> string list query_result
  
  (** 验证评估条件 *)
  val validate_evaluation_criteria : evaluation_dimension -> string -> bool query_result
end

(** 评估标准管理器签名 *)
module type EVALUATION_STANDARDS = sig
  (** 艺术评估标准类型 - 引用自evaluation_types *)
  type artistic_standard = Artistic_evaluation_types.artistic_standard
  
  (** 获取指定形式的标准 *)
  val get_standard_for_form : poetry_form -> artistic_standard option query_result
  
  (** 评估是否符合标准 *)
  val evaluate_against_standard : string list -> artistic_standard -> (bool * float * string) query_result
  
  (** 列出所有可用标准 *)
  val list_available_standards : unit -> string list query_result
end

(** {1 缓存管理接口} *)

(** 评估缓存管理器签名 *)
module type EVALUATION_CACHE = sig
  (** 缓存评估结果 *)
  val cache_evaluation : string -> comprehensive_evaluation -> unit query_result
  
  (** 获取缓存的评估结果 *)
  val get_cached_evaluation : string -> comprehensive_evaluation option query_result
  
  (** 清除缓存 *)
  val clear_cache : unit -> unit query_result
  
  (** 缓存统计信息 *)
  val cache_statistics : unit -> (int * int * float) query_result (* 命中数, 总请求数, 命中率 *)
end

(** {1 报告生成接口} *)

(** 评估报告生成器签名 *)
module type EVALUATION_REPORTER = sig
  (** 生成详细报告 *)
  val generate_detailed_report : comprehensive_evaluation -> string query_result
  
  (** 生成简要报告 *)
  val generate_summary_report : comprehensive_evaluation -> string query_result
  
  (** 生成改进建议报告 *)
  val generate_improvement_report : comprehensive_evaluation -> string query_result
  
  (** 导出为JSON格式 *)
  val export_to_json : comprehensive_evaluation -> string query_result
end

(** {1 统一接口工厂} *)

(** 艺术评估系统工厂 *)
module type ARTISTIC_EVALUATION_FACTORY = sig
  (** 创建评估引擎 *)
  val create_evaluation_engine : unit -> (module ARTISTIC_EVALUATION_ENGINE) query_result
  
  (** 创建维度评估器 *)
  val create_dimension_evaluator : evaluation_dimension -> (module DIMENSION_EVALUATOR) query_result
  
  (** 创建形式评估器 *)
  val create_form_evaluator : poetry_form -> (module FORM_EVALUATOR) query_result
  
  (** 创建数据访问器 *)
  val create_data_accessor : unit -> (module ARTISTIC_DATA_ACCESSOR) query_result
  
  (** 创建标准管理器 *)
  val create_standards_manager : unit -> (module EVALUATION_STANDARDS) query_result
  
  (** 创建缓存管理器 *)
  val create_cache_manager : unit -> (module EVALUATION_CACHE) query_result
  
  (** 创建报告生成器 *)
  val create_reporter : unit -> (module EVALUATION_REPORTER) query_result
end

(** {1 工具函数接口} *)

(** 这些函数将在实现部分定义 *)

(** {1 向后兼容性接口} *)

(** 兼容性类型别名 *)
type legacy_evaluation_grade = evaluation_grade
type legacy_poetry_form = poetry_form

(** 兼容性函数别名 - 将在实现部分定义 *)

(** 兼容性模块别名声明 *)
module Legacy_Artistic_Types = struct
  include Poetry_core.Poetry_types
  let evaluation_dimensions = [
    RhymeHarmony; TonalBalance; Parallelism; Imagery;
    Rhythm; Elegance; CulturalDepth; EmotionalResonance
  ]
end

(** {1 实现工具函数} *)

let dimension_to_string = function
  | RhymeHarmony -> "韵律和谐"
  | TonalBalance -> "声调平衡"
  | Parallelism -> "对仗工整"
  | Imagery -> "意象深度"
  | Rhythm -> "节奏感"
  | Elegance -> "雅致程度"
  | ClassicalElegance -> "古典雅致"
  | ModernInnovation -> "现代创新"
  | CulturalDepth -> "文化深度"
  | EmotionalResonance -> "情感共鸣"
  | IntellectualDepth -> "理性深度"

let string_to_dimension = function
  | "韵律和谐" -> Some RhymeHarmony
  | "声调平衡" -> Some TonalBalance
  | "对仗工整" -> Some Parallelism
  | "意象深度" -> Some Imagery
  | "节奏感" -> Some Rhythm
  | "雅致程度" -> Some Elegance
  | "古典雅致" -> Some ClassicalElegance
  | "现代创新" -> Some ModernInnovation
  | "文化深度" -> Some CulturalDepth
  | "情感共鸣" -> Some EmotionalResonance
  | "理性深度" -> Some IntellectualDepth
  | _ -> None

let format_evaluation_result result =
  Printf.sprintf "%s: %.2f分 - %s" 
    (dimension_to_string result.dimension) 
    result.score 
    result.feedback

let format_comprehensive_evaluation eval =
  let individual_scores_str = 
    String.concat "\n" 
      (List.map format_evaluation_result eval.individual_scores) in
  Printf.sprintf "综合评估结果:\n%s\n\n总分: %.2f\n等级: %s\n总结: %s"
    individual_scores_str
    eval.overall_score
    (string_of_evaluation_grade eval.grade)
    eval.summary

let handle_query_result result on_found on_error on_not_found =
  match result with
  | Found value -> on_found value
  | Error msg -> on_error msg
  | NotFound -> on_not_found

(** 向后兼容性实现 *)
let legacy_grade_to_string = string_of_evaluation_grade
let legacy_form_to_string = poetry_form_to_string