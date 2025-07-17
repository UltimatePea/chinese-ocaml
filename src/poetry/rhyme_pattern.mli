(* 韵律模式识别模块接口 - 骆言诗词编程特性
   专司韵律模式之识别，辨析诗词之结构。
   此接口定义韵律模式识别相关函数的类型签名。
*)

(* 导入韵母类型定义 *)
open Rhyme_types

(* 提取韵脚：从字符串中提取韵脚字符 *)
val extract_rhyme_ending : string -> char option

(* 验证韵脚一致性：检查多句诗词的韵脚是否和谐 *)
val validate_rhyme_consistency : string list -> bool

(* 验证韵律方案：依传统诗词格律检验韵律 *)
val validate_rhyme_scheme : string list -> char list -> bool

(* 分析诗句的韵律信息：逐字分析，察其音韵 *)
val analyze_rhyme_pattern : string -> (char * rhyme_category * rhyme_group) list

(* 韵律分析报告类型 *)
type rhyme_analysis_report = {
  verse : string;
  rhyme_ending : char option;
  rhyme_group : rhyme_group;
  rhyme_category : rhyme_category;
  char_analysis : (char * rhyme_category * rhyme_group) list;
}

(* 生成韵律分析报告：为诗句提供全面的音韵分析 *)
val generate_rhyme_report : string -> rhyme_analysis_report

(* 整体韵律分析报告类型 *)
type poem_rhyme_analysis = {
  verses : string list;
  verse_reports : rhyme_analysis_report list;
  rhyme_groups : rhyme_group list;
  rhyme_categories : rhyme_category list;
  rhyme_quality : float;
  rhyme_consistency : bool;
}

(* 分析诗词整体韵律：分析整首诗的韵律结构 *)
val analyze_poem_rhyme : string list -> poem_rhyme_analysis

(* 韵律美化建议：为诗句提供音韵改进之建议 *)
val suggest_rhyme_improvements : string -> rhyme_group -> string list

(* 检测韵律模式：分析诗词的韵律结构模式 *)
val detect_rhyme_pattern : string list -> char list

(* 验证特定韵律模式：检查诗词是否符合特定韵律模式 *)
val validate_specific_pattern : string list -> char list -> bool

(* 常见韵律模式定义 *)
val common_patterns : (string * char list) list

(* 识别韵律模式类型：根据检测到的韵律模式识别诗词类型 *)
val identify_pattern_type : string list -> string option