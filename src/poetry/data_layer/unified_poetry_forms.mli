(** 骆言诗词统一诗体格式模块接口 - Poetry模块整合优化 Fix #1707
    
    此模块接口定义了统一的诗词形式规范和格律检查功能。
    提供完整的诗体识别、格律验证和评价服务。
    
    Author: Alpha, 主要工作代理 *)

open Unified_data_types

(** {1 诗词格式规范} *)

(** 格律要求 *)
type metrical_requirement = {
  line_count : int;                    (** 行数要求 *)
  chars_per_line : int option;         (** 每行字数(None表示不限) *)
  rhyme_scheme : bool list;            (** 押韵模式(true表示押韵行) *)
  tone_pattern : bool list list option; (** 平仄格律(None表示不限) *)
  parallelism_pairs : (int * int) list; (** 对仗句对 *)
}

(** 诗词形式规范 *)
type poetry_form_spec = {
  form_name : poetry_form;             (** 诗体名称 *)
  chinese_name : string;               (** 中文名称 *)
  description : string;                (** 形式描述 *)
  historical_origin : string;          (** 历史源流 *)
  metrical_req : metrical_requirement; (** 格律要求 *)
  artistic_weights : (artistic_dimension * float) list; (** 艺术评价权重 *)
  example_poems : string list;         (** 典型范例 *)
  evaluation_criteria : string list;   (** 评价准则 *)
}

(** 格律验证结果 *)
type metrical_check_result = {
  is_valid : bool;                     (** 是否符合格律 *)
  violations : string list;            (** 违反的规则 *)
  score : float;                       (** 格律符合度评分 *)
  suggestions : string list;           (** 改进建议 *)
}

(** {1 诗体规范访问} *)

val get_all_supported_forms : unit -> poetry_form_spec list
(** 获取所有支持的诗体 *)

val find_form_spec : poetry_form -> poetry_form_spec option
(** 查找诗体规范 *)

val get_form_chinese_name : poetry_form -> string
(** 获取诗体中文名称 *)

val get_form_description : poetry_form -> string
(** 获取诗体描述 *)

(** {1 格律检查功能} *)

val check_metrical_rules : string list -> poetry_form_spec -> metrical_check_result
(** 综合格律检查 *)

val check_line_count : string list -> poetry_form_spec -> bool * string list
(** 检查行数是否符合要求 *)

val check_chars_per_line : string list -> poetry_form_spec -> bool * string list
(** 检查每行字数是否符合要求 *)

val check_rhyme_scheme : string list -> poetry_form_spec -> bool * string list
(** 检查押韵模式 *)

val check_parallelism : string list -> poetry_form_spec -> bool * string list
(** 检查对仗要求 *)

(** {1 诗体识别功能} *)

val identify_poetry_form : string list -> poetry_form_spec option
(** 根据特征自动识别诗体 *)

(** {1 诗体评价功能} *)

val calculate_weighted_artistic_score : poetry_form_spec -> (artistic_dimension * float) list -> float
(** 根据诗体计算加权评分 *)

val generate_form_specific_suggestions : poetry_form_spec -> metrical_check_result -> string list
(** 生成诗体特定的评价建议 *)

(** {1 向后兼容接口} *)

(** 兼容旧版本的诗体标准 *)
type legacy_poetry_standards = {
  wuyan_lushi : metrical_requirement;
  qiyan_jueju : metrical_requirement;
  siyan_pianti : metrical_requirement;
}

val legacy_standards : legacy_poetry_standards
(** 兼容旧版本的标准 *)

val legacy_check_metrical_compliance : string list -> poetry_form -> metrical_check_result
(** 兼容旧版本的格律检查函数 *)