(** 格律引擎核心类型定义
    
    此模块定义了格律检查引擎使用的所有核心数据类型。
    从原 meter_engine.ml 中提取，遵循单一职责原则。
    
    @author Alpha, 主要开发代理
    @version 1.0 
    @since 2025-07-30
    @refactor_from meter_engine.ml (解决issue #1775技术债务) *)

(* 简化类型定义 - Poetry_core已整合到统一模块 *)

(** {1 基础类型定义} *)
type rhyme_group = string
type rhyme_category = string

(** {1 诗体类型定义} *)

(** 诗体类型 *)
type poetry_form =
  | LuShi of int  (** 律诗 (5言/7言) *)
  | JueJu of int  (** 绝句 (5言/7言) *)
  | Ci of string  (** 词 (词牌名) *)
  | Qu of string  (** 曲 (曲牌名) *)
  | GuTi  (** 古体诗 *)
  | ZiYou  (** 自由体 *)

type meter_pattern = {
  form : poetry_form;  (** 诗体形式 *)
  required_lines : int;  (** 要求行数 *)
  line_lengths : int list;  (** 各行字数要求 *)
  rhyme_scheme : rhyme_group option list;  (** 韵式要求 *)
  tonal_pattern : rhyme_category list list;  (** 平仄模式 *)
  parallelism_requirements : (int * int) list;  (** 对仗要求 (行号对) *)
}
(** 格律模式定义 *)

(** {1 检查结果类型} *)

type meter_check_result = {
  pattern : meter_pattern;  (** 使用的格律模式 *)
  verse_count : int;  (** 实际诗句数 *)
  line_length_compliance : bool list;  (** 各行字数符合度 *)
  rhyme_compliance : bool list;  (** 各行韵律符合度 *)
  tonal_compliance : bool list;  (** 各行平仄符合度 *)
  parallelism_compliance : bool list;  (** 对仗符合度 *)
  overall_compliance : float;  (** 整体符合度 *)
  violations : string list;  (** 违规项列表 *)
  suggestions : string list;  (** 改进建议 *)
}
(** 格律检查结果 *)

type form_recognition_result = {
  detected_form : poetry_form;  (** 检测到的诗体 *)
  confidence : float;  (** 识别置信度 *)
  reasons : string list;  (** 识别依据 *)
  alternatives : (poetry_form * float) list;  (** 备选诗体 *)
}
(** 诗体识别结果 *)

(** {1 引擎状态类型} *)

type meter_engine_state = {
  rhythm_analyzer : (string, Poetry_rhyme.Rhyme_types.query_result) Hashtbl.t;  (** 韵律分析器缓存 *)
  artistic_evaluator : Poetry_artistic.Artistic_evaluators.engine_state;  (** 艺术性评价器状态 *)
  cache_enabled : bool;  (** 是否启用缓存 *)
  cached_results : (string, meter_check_result) Hashtbl.t;  (** 结果缓存 *)
  performance_stats : (string * float) list;  (** 性能统计记录 *)
}
(** 格律引擎状态 *)

and performance_stats = {
  mutable total_checks : int;  (** 总检查次数 *)
  mutable cache_hits : int;  (** 缓存命中次数 *)
  mutable avg_check_time : float;  (** 平均检查时间 *)
}
(** 性能统计数据 *)

(** {1 辅助类型} *)

(** 检查类型枚举 *)
type check_type = LineCount | LineLength | Rhyme | Tonal | Parallelism

(** 违规严重程度 *)
type violation_severity = Minor  (** 轻微违规 *) | Moderate  (** 中等违规 *) | Severe  (** 严重违规 *)

type violation_detail = {
  check_type : check_type;
  severity : violation_severity;
  line_number : int option;
  description : string;
  suggestion : string option;
}
(** 违规详情 *)
