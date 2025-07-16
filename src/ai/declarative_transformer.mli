(** 声明式编程风格转换器接口 - Declarative Programming Style Transformer Interface *)

type transformation_suggestion = {
  original_code : string; (* 原始代码 *)
  transformed_code : string; (* 转换后代码 *)
  transformation_type : string; (* 转换类型 *)
  confidence : float; (* 置信度 0.0-1.0 *)
  explanation : string; (* 转换说明 *)
  category : string; (* 转换分类 *)
}
(** 转换建议类型 *)

type imperative_pattern = {
  name : string; (* 模式名称 *)
  keywords : string list; (* 关键识别词 *)
  pattern_regex : string; (* 模式正则表达式 *)
  declarative_template : string; (* 声明式模板 *)
  description : string; (* 模式描述 *)
  examples : (string * string) list; (* 转换示例：(命令式, 声明式) *)
}
(** 命令式模式类型 *)

val analyze_and_suggest : string -> transformation_suggestion list
(** 识别并建议转换 *)

val apply_transformation : string -> transformation_suggestion -> string
(** 应用转换建议 *)

val analyze_code_block : string list -> transformation_suggestion list
(** 批量分析代码 *)

val format_suggestion : transformation_suggestion -> string
(** 格式化转换建议 *)

val format_suggestions : transformation_suggestion list -> string
(** 批量格式化建议 *)

val generate_transformation_report : transformation_suggestion list -> string
(** 生成转换报告 *)

val intelligent_analysis : string -> string
(** 智能代码分析 *)

val detect_declarative_opportunities : string -> string list
(** 检测特定的声明式模式机会 *)

