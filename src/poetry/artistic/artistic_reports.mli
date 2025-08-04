(** 诗词艺术评估报告生成模块接口
 *
 * 此模块提供全面的评估报告生成功能，支持多种格式和样式的报告输出。
 * 包括详细分析报告、简要摘要、可视化图表支持等。
 *
 * 主要功能：
 * - 多格式报告生成
 * - 自定义报告模板
 * - 数据可视化支持
 * - 批量报告处理
 * - 报告样式管理
 * - 导出功能集成
 *
 * @author Whisky, PR Worker
 *)

(** {1 报告类型定义} *)

(** 报告格式类型 *)
type report_format = 
  | TextReport      (** 纯文本报告 *)
  | HtmlReport      (** HTML格式报告 *)
  | JsonReport      (** JSON格式报告 *)
  | XmlReport       (** XML格式报告 *)
  | MarkdownReport  (** Markdown格式报告 *)

(** 报告详细程度 *)
type report_detail_level = 
  | Brief           (** 简要报告 *)
  | Standard        (** 标准报告 *)
  | Detailed        (** 详细报告 *)
  | Comprehensive   (** 全面报告 *)

(** 报告配置 *)
type report_config = {
  format : report_format;                     (** 报告格式 *)
  detail_level : report_detail_level;         (** 详细程度 *)
  include_charts : bool;                      (** 是否包含图表 *)
  include_metadata : bool;                    (** 是否包含元数据 *)
  custom_sections : string list;             (** 自定义章节 *)
  template_name : string option;             (** 模板名称 *)
}

(** 报告章节 *)
type report_section = {
  title : string;                (** 章节标题 *)
  content : string;              (** 章节内容 *)
  subsections : report_section list; (** 子章节 *)
  metadata : (string * string) list; (** 章节元数据 *)
}

(** 完整报告 *)
type complete_report = {
  title : string;                    (** 报告标题 *)
  summary : string;                  (** 报告摘要 *)
  sections : report_section list;    (** 报告章节 *)
  generated_at : float;              (** 生成时间 *)
  config : report_config;            (** 生成配置 *)
  statistics : (string * string) list; (** 统计信息 *)
}

(** {1 基础报告生成} *)

(** 生成评估报告
    @param evaluation_result 评估结果
    @param config 报告配置
    @return 完整报告 *)
val generate_evaluation_report : 
  Artistic_core.artistic_evaluation -> report_config -> complete_report

(** 生成简要摘要
    @param evaluation_result 评估结果
    @return 摘要字符串 *)
val generate_brief_summary : Artistic_core.artistic_evaluation -> string

(** 生成详细分析
    @param evaluation_result 评估结果
    @return 详细分析报告 *)
val generate_detailed_analysis : Artistic_core.artistic_evaluation -> complete_report

(** {1 格式化输出} *)

(** 格式化为文本
    @param report 完整报告
    @return 文本格式字符串 *)
val format_as_text : complete_report -> string

(** 格式化为HTML
    @param report 完整报告
    @return HTML格式字符串 *)
val format_as_html : complete_report -> string

(** 格式化为JSON
    @param report 完整报告
    @return JSON格式字符串 *)
val format_as_json : complete_report -> string

(** 格式化为Markdown
    @param report 完整报告
    @return Markdown格式字符串 *)
val format_as_markdown : complete_report -> string

(** {1 专门报告类型} *)

(** 生成维度分析报告
    @param dimension_scores 维度评分列表
    @param config 报告配置
    @return 维度分析报告 *)
val generate_dimension_analysis_report : 
  Artistic_core.dimension_score list -> report_config -> complete_report

(** 生成比较报告
    @param evaluations 多个评估结果
    @param config 报告配置
    @return 比较分析报告 *)
val generate_comparison_report : 
  Artistic_core.artistic_evaluation list -> report_config -> complete_report

(** 生成趋势报告
    @param historical_data 历史数据
    @param config 报告配置
    @return 趋势分析报告 *)
val generate_trend_report : 
  (float * Artistic_core.artistic_evaluation) list -> report_config -> complete_report

(** {1 模板管理} *)

(** 注册报告模板
    @param template_name 模板名称
    @param template_content 模板内容 *)
val register_report_template : string -> string -> unit

(** 获取报告模板
    @param template_name 模板名称
    @return 模板内容选项 *)
val get_report_template : string -> string option

(** 应用模板
    @param template_name 模板名称
    @param data 数据变量
    @return 应用模板后的内容 *)
val apply_report_template : string -> (string * string) list -> string

(** 列出可用模板
    @return 模板名称列表 *)
val list_available_templates : unit -> string list

(** {1 图表与可视化} *)

(** 生成评分雷达图数据
    @param dimension_scores 维度评分
    @return 雷达图数据 *)
val generate_radar_chart_data : Artistic_core.dimension_score list -> (string * float) list

(** 生成趋势图数据
    @param historical_scores 历史评分
    @return 趋势图数据 *)
val generate_trend_chart_data : (float * float) list -> (string * float) list

(** 生成分布图数据
    @param scores 评分列表
    @return 分布图数据 *)
val generate_distribution_chart_data : float list -> (string * int) list

(** {1 批量报告处理} *)

(** 批量生成报告
    @param evaluations 评估结果列表
    @param config 报告配置
    @return 报告列表 *)
val batch_generate_reports : 
  Artistic_core.artistic_evaluation list -> report_config -> complete_report list

(** 合并多个报告
    @param reports 报告列表
    @param merge_config 合并配置
    @return 合并后的报告 *)
val merge_reports : complete_report list -> report_config -> complete_report

(** {1 报告统计与分析} *)

(** 分析报告质量
    @param report 报告
    @return 质量分析结果 *)
val analyze_report_quality : complete_report -> (string * float) list

(** 计算报告统计信息
    @param report 报告
    @return 统计信息 *)
val calculate_report_statistics : complete_report -> (string * string) list

(** {1 导出与保存} *)

(** 导出报告到文件
    @param report 报告
    @param filename 文件名
    @param format 导出格式
    @return 是否成功 *)
val export_report_to_file : complete_report -> string -> report_format -> bool

(** 保存报告配置
    @param config 报告配置
    @param config_name 配置名称 *)
val save_report_config : report_config -> string -> unit

(** 加载报告配置
    @param config_name 配置名称
    @return 报告配置选项 *)
val load_report_config : string -> report_config option

(** {1 报告样式管理} *)

(** 设置报告样式
    @param style_name 样式名称
    @param style_config 样式配置 *)
val set_report_style : string -> (string * string) list -> unit

(** 获取报告样式
    @param style_name 样式名称
    @return 样式配置选项 *)
val get_report_style : string -> (string * string) list option

(** 应用报告样式
    @param report 原始报告
    @param style_name 样式名称
    @return 应用样式后的报告 *)
val apply_report_style : complete_report -> string -> complete_report