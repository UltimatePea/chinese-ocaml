(** 格律引擎核心类型定义接口

    定义了格律检查引擎的所有公共类型。

    @author Alpha, 主要开发代理
    @version 1.0
    @since 2025-07-30 *)

(** {1 核心类型定义} *)

(** 韵组类型 - 简化定义 *)
type rhyme_group = string

(** 韵类别类型 - 简化定义 *)
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
  form : poetry_form;
  required_lines : int;
  line_lengths : int list;
  rhyme_scheme : Poetry_rhyme.Rhyme_types.rhyme_group option list;
  tonal_pattern : Poetry_rhyme.Rhyme_types.tone_category list list;
  parallelism_requirements : (int * int) list;
}
(** 格律模式定义 *)

(** {1 检查结果类型} *)

type meter_check_result = {
  pattern : meter_pattern;
  verse_count : int;
  line_length_compliance : bool list;
  rhyme_compliance : bool list;
  tonal_compliance : bool list;
  parallelism_compliance : bool list;
  overall_compliance : float;
  violations : string list;
  suggestions : string list;
}
(** 格律检查结果 *)

type form_recognition_result = {
  detected_form : poetry_form;
  confidence : float;
  reasons : string list;
  alternatives : (poetry_form * float) list;
}
(** 诗体识别结果 *)

(** {1 引擎状态类型} *)

type meter_engine_state = {
  rhythm_analyzer : (string, Poetry_rhyme.Rhyme_types.query_result) Hashtbl.t;  (** 韵律分析器缓存 *)
  artistic_evaluator : Poetry_artistic.Artistic_core.engine_state;  (** 艺术性评价器状态 *)
  cache_enabled : bool;  (** 是否启用缓存 *)
  cached_results : (string, meter_check_result) Hashtbl.t;  (** 结果缓存 *)
  performance_stats : (string * float) list;  (** 性能统计记录 *)
}
(** 格律引擎状态 *)

(** {1 辅助类型} *)

(** 检查类型枚举 *)
type check_type = LineCount | LineLength | Rhyme | Tonal | Parallelism

(** 违规严重程度 *)
type violation_severity = Minor | Moderate | Severe

type violation_detail = {
  check_type : check_type;
  severity : violation_severity;
  line_number : int option;
  description : string;
  suggestion : string option;
}
(** 违规详情 *)
