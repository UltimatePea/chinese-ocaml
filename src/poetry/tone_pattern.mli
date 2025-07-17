(* 平仄检测模块接口 - 骆言诗词编程特性 *)

(* 声调类型 *)
type tone_type =
  | LevelTone (* 平声 *)
  | FallingTone (* 仄声 *)
  | RisingTone (* 上声 *)
  | DepartingTone (* 去声 *)
  | EnteringTone (* 入声 *)

(* 声调分析报告类型 *)
type tone_analysis_report = {
  verse : string;
  tone_sequence : tone_type list;
  simple_pattern : bool list;
  pattern_match : bool;
  suggestions : string list;
}

(* 检测字符的声调 *)
val detect_tone : char -> tone_type

(* 检测字符是否为平声 *)
val is_level_tone : char -> bool

(* 检测字符是否为仄声 *)
val is_oblique_tone : char -> bool

(* 分析字符串的声调序列 *)
val analyze_tone_sequence : string -> tone_type list

(* 分析简化平仄模式 *)
val analyze_simple_tone_pattern : string -> bool list

(* 验证平仄模式 *)
val validate_tone_pattern : string -> bool list -> bool

(* 验证七言绝句的平仄 *)
val validate_qijue_tone_pattern : string list -> bool

(* 验证五言律诗的平仄 *)
val validate_wuyan_tone_pattern : string list -> bool

(* 验证四言骈体的平仄 *)
val validate_siyan_tone_pattern : string list -> bool

(* 生成声调分析报告 *)
val generate_tone_report : string -> bool list -> tone_analysis_report

(* 建议平仄改进 *)
val suggest_tone_improvements : string -> bool list -> string list

(* 获取适合的字符建议 *)
val get_tone_character_suggestions : tone_type -> string list
