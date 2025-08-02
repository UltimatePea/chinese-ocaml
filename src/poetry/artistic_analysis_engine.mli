(** 艺术数据分析功能模块接口
    
    提供诗词艺术元素的深度分析功能，包括：
    - 文本艺术元素分析
    - 意象词汇专用分析
    - 数据趋势分析
    
    @author 骆言项目团队
    @version 1.0 - 艺术分析引擎
    @since 2025-08-02 *)

open Artistic_core_types

(** {1 文本艺术元素分析} *)

(** 分析文本中的艺术元素
    @param text 待分析的文本
    @return 艺术元素分类及对应词汇列表的查询结果 *)
val analyze_text_artistic_elements : string -> (word_category * string list) list query_result

(** {1 意象词汇专用分析} *)

(** 获取自然意象词汇
    @return 自然主题相关词汇列表的查询结果 *)
val get_nature_imagery : unit -> string list query_result

(** 获取季节性意象词汇
    @param season 季节名称（春、夏、秋、冬）
    @return 对应季节的意象词汇列表的查询结果 *)
val get_seasonal_imagery : string -> string list query_result

(** 根据主题建议意象词汇
    @param theme 主题名称（如"离别"、"思乡"、"爱情"、"田园"）
    @return 建议的意象词汇列表的查询结果 *)
val suggest_imagery_for_theme : string -> string list query_result

(** {1 数据趋势分析} *)

(** 获取特定类别的热门词汇
    @param category 词汇类别
    @param limit 返回词汇数量限制
    @return 热门词汇及其频率的查询结果 *)
val get_popular_words : word_category -> int -> (string * int) list query_result

(** 获取艺术类别趋势数据
    @return 各艺术类别及其趋势指标的查询结果 *)
val get_artistic_trends : unit -> (word_category * float) list query_result