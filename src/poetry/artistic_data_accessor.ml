(* 艺术数据访问器 - 模块化重构后的统一接口 *)

(** Author: Alpha, 主要工作代理
    重构说明: 将592行巨型模块拆分为8个专门模块，保持100%向后兼容 *)

(** 导入所有专门模块 *)
open Artistic_core_types
open Artistic_data_parser
open Artistic_query_engine  
open Artistic_evaluation_engine
open Artistic_analysis_engine
open Artistic_template_manager
open Artistic_legacy_compat
open Artistic_data_registry

(** {1 类型重导出 - 保持API兼容性} *)

type word_category = Artistic_core_types.word_category =
  | Imagery | Elegant | Metaphor | Emotion | Nature | Classical

type evaluation_dimension = Artistic_core_types.evaluation_dimension =
  | RhymeHarmony | TonalBalance | Parallelism | ImageryDepth 
  | FormBeauty | ContentDepth | MoodContext

type word_info = Artistic_core_types.word_info = {
  word : string;
  category : word_category;
  frequency : int;
  artistic_value : float;
  synonyms : string list;
  contexts : string list;
  examples : string list;
}

type evaluation_standard = Artistic_core_types.evaluation_standard = {
  dimension : evaluation_dimension;
  name : string;
  description : string;
  weight : float;
  min_score : float;
  max_score : float;
  criteria : (string * float) list;
}

type artistic_template = Artistic_core_types.artistic_template = {
  name : string;
  category : word_category;
  pattern : string;
  examples : string list;
  effectiveness : float;
}

type 'a query_result = 'a Artistic_core_types.query_result =
  | Found of 'a | NotFound | QueryError of string

(** {1 初始化接口} *)
let initialize = Artistic_data_registry.initialize
let is_initialized = Artistic_data_registry.is_initialized
let register_custom_word_source = Artistic_data_registry.register_custom_word_source

(** {1 基础查询接口} *)
let get_word_info = Artistic_query_engine.get_word_info
let get_words_by_category = Artistic_query_engine.get_words_by_category
let search_words_by_pattern = Artistic_query_engine.search_words_by_pattern
let get_high_value_words = Artistic_query_engine.get_high_value_words

(** {1 意象词汇接口} *)
let get_imagery_keywords = Artistic_legacy_compat.get_imagery_keywords
let get_nature_imagery = Artistic_analysis_engine.get_nature_imagery
let get_seasonal_imagery = Artistic_analysis_engine.get_seasonal_imagery
let suggest_imagery_for_theme = Artistic_analysis_engine.suggest_imagery_for_theme

(** {1 雅致词汇接口} *)
let get_elegant_words = Artistic_legacy_compat.get_elegant_words
let get_classical_expressions = Artistic_legacy_compat.get_classical_expressions
let get_formal_particles = Artistic_legacy_compat.get_formal_particles
let assess_word_elegance = Artistic_evaluation_engine.assess_word_elegance

(** {1 评价标准接口} *)
let get_evaluation_standards = Artistic_query_engine.get_evaluation_standards
let get_all_evaluation_dimensions = Artistic_core_types.get_all_evaluation_dimensions
let get_standard_weights = Artistic_evaluation_engine.get_standard_weights
let validate_evaluation_criteria = Artistic_evaluation_engine.validate_evaluation_criteria

(** {1 艺术模板接口} *)
let get_artistic_templates = Artistic_template_manager.get_templates
let suggest_template_for_context = Artistic_template_manager.suggest_template_for_context
let evaluate_template_effectiveness = Artistic_template_manager.evaluate_template_effectiveness

(** {1 分析功能接口} *)
let analyze_text_artistic_elements = Artistic_analysis_engine.analyze_text_artistic_elements
let suggest_improvements = Artistic_evaluation_engine.suggest_improvements
let calculate_artistic_score = Artistic_evaluation_engine.calculate_artistic_score
let compare_artistic_quality = Artistic_evaluation_engine.compare_artistic_quality

(** {1 统计分析接口} *)
let get_word_category_statistics = Artistic_query_engine.get_word_category_statistics
let get_popular_words = Artistic_analysis_engine.get_popular_words
let get_artistic_trends = Artistic_analysis_engine.get_artistic_trends

(** {1 兼容性接口} *)
let load_imagery_data = Artistic_legacy_compat.load_imagery_data
let load_elegant_data = Artistic_legacy_compat.load_elegant_data
let check_word_availability = Artistic_legacy_compat.check_word_availability

(** {1 诊断接口} *)
let format_query_error = Artistic_data_registry.format_query_error
let validate_data_integrity = Artistic_data_registry.validate_data_integrity
let get_cache_status = Artistic_data_registry.get_cache_status
let diagnose_performance = Artistic_data_registry.diagnose_performance