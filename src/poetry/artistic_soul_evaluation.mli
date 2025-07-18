(* 诗词编程艺术灵魂评价模块接口 *)

(* 艺术灵魂的核心维度 *)
type artistic_soul_dimension = {
  technical_mastery : float; (* 技术精通度 *)
  literary_beauty : float; (* 文学美感 *)
  cultural_depth : float; (* 文化深度 *)
  emotional_resonance : float; (* 情感共鸣 *)
  philosophical_wisdom : float; (* 哲理智慧 *)
  poetic_spirit : float; (* 诗意精神 *)
}

(* 灵魂评价等级 *)
type soul_grade =
  | TranscendentSoul (* 超凡入圣 *)
  | EnlightenedSoul (* 通达智慧 *)
  | CultivatedSoul (* 涵养有度 *)
  | DevelopingSoul (* 渐入佳境 *)
  | TechnicalSoul (* 技术为主 *)
  | LackingSoul (* 缺乏灵魂 *)

(* 文学意象深度分析 *)
type imagery_analysis = {
  natural_imagery : string list; (* 自然意象 *)
  cultural_imagery : string list; (* 文化意象 *)
  philosophical_imagery : string list; (* 哲理意象 *)
  emotional_imagery : string list; (* 情感意象 *)
  technical_metaphors : string list; (* 技术比喻 *)
  poetic_connections : string list; (* 诗意联系 *)
}

(* 文化内涵分析 *)
type cultural_analysis = {
  classical_references : string list; (* 古典引用 *)
  philosophical_concepts : string list; (* 哲学概念 *)
  literary_techniques : string list; (* 文学技巧 *)
  cultural_symbols : string list; (* 文化符号 *)
  historical_allusions : string list; (* 历史典故 *)
}

(* 灵魂评价报告 *)
type soul_evaluation_report = {
  code_text : string;
  soul_dimensions : artistic_soul_dimension;
  soul_grade : soul_grade;
  imagery_analysis : imagery_analysis;
  cultural_analysis : cultural_analysis;
  improvement_suggestions : string list;
}

(* 核心评价函数 *)

val evaluate_artistic_soul : string -> artistic_soul_dimension
(** 综合评价代码的艺术灵魂 *)

val determine_soul_grade : artistic_soul_dimension -> soul_grade
(** 确定灵魂等级 *)

val generate_soul_evaluation_report : string -> soul_evaluation_report
(** 生成完整的灵魂评价报告 *)

val generate_soul_improvement_suggestions : artistic_soul_dimension -> string list
(** 生成提升建议 *)

val poetic_soul_critique : string -> string -> string
(** 诗意评价函数 - 用古典文学的方式评价代码 *)

(* 各维度评价函数 *)

val evaluate_technical_mastery : string -> float
(** 评价技术掌握度 *)

val evaluate_literary_beauty : string -> float
(** 评价文学美感 *)

val evaluate_cultural_depth : string -> float
(** 评价文化深度 *)

val evaluate_emotional_resonance : string -> float
(** 评价情感共鸣 *)

val evaluate_philosophical_wisdom : string -> float
(** 评价哲理智慧 *)

val evaluate_poetic_spirit : string -> float
(** 评价诗意精神 *)
