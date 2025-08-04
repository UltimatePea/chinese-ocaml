(** 诗词艺术评估过滤器模块接口
 *
 * 此模块提供各种过滤器功能，用于筛选和过滤诗词评估相关的数据。
 * 包括内容过滤、质量过滤、类型过滤等多种过滤策略。
 *
 * 主要功能：
 * - 内容质量过滤
 * - 诗词类型过滤
 * - 评分阈值过滤
 * - 自定义过滤条件
 * - 组合过滤器支持
 * - 过滤结果统计
 *
 * @author Whisky, PR Worker
 *)

(** {1 过滤器类型定义} *)

(** 过滤条件类型 *)
type filter_condition = 
  | ScoreAbove of float        (** 评分高于阈值 *)
  | ScoreBelow of float        (** 评分低于阈值 *)
  | ScoreRange of float * float (** 评分在范围内 *)
  | ContentContains of string   (** 内容包含指定文本 *)
  | TypeEquals of string        (** 类型等于指定值 *)
  | CustomFilter of (string -> bool) (** 自定义过滤函数 *)

(** 过滤器组合方式 *)
type filter_operator = 
  | And  (** 逻辑与 *)
  | Or   (** 逻辑或 *)
  | Not  (** 逻辑非 *)

(** 复合过滤器 *)
type compound_filter = 
  | SimpleFilter of filter_condition
  | CombinedFilter of compound_filter * filter_operator * compound_filter

(** 过滤结果 *)
type filter_result = {
  passed : string list;      (** 通过过滤的项目 *)
  filtered_out : string list; (** 被过滤掉的项目 *)  
  total_count : int;         (** 总数量 *)
  pass_rate : float;         (** 通过率 *)
}

(** {1 基础过滤函数} *)

(** 应用过滤条件
    @param condition 过滤条件
    @param item 要过滤的项目
    @return 是否通过过滤 *)
val apply_filter_condition : filter_condition -> string -> bool

(** 应用复合过滤器
    @param filter 复合过滤器
    @param item 要过滤的项目
    @return 是否通过过滤 *)
val apply_compound_filter : compound_filter -> string -> bool

(** 过滤项目列表
    @param filter 过滤器
    @param items 项目列表
    @return 过滤结果 *)
val filter_items : compound_filter -> string list -> filter_result

(** {1 专门过滤器} *)

(** 质量过滤器：过滤低质量内容
    @param min_score 最低评分
    @param items 项目列表
    @return 过滤结果 *)
val quality_filter : float -> string list -> filter_result

(** 长度过滤器：根据内容长度过滤
    @param min_length 最小长度
    @param max_length 最大长度
    @param items 项目列表
    @return 过滤结果 *)
val length_filter : int -> int -> string list -> filter_result

(** 类型过滤器：根据诗词类型过滤
    @param poem_type 诗词类型
    @param items 项目列表
    @return 过滤结果 *)
val type_filter : string -> string list -> filter_result

(** 关键词过滤器：包含特定关键词的内容
    @param keywords 关键词列表
    @param items 项目列表
    @return 过滤结果 *)
val keyword_filter : string list -> string list -> filter_result

(** {1 高级过滤功能} *)

(** 创建评分范围过滤器
    @param min_score 最低评分
    @param max_score 最高评分
    @return 过滤条件 *)
val create_score_range_filter : float -> float -> filter_condition

(** 创建内容匹配过滤器
    @param pattern 匹配模式
    @return 过滤条件 *)
val create_content_match_filter : string -> filter_condition

(** 组合多个过滤器
    @param filters 过滤器列表
    @param operator 组合操作符
    @return 复合过滤器 *)
val combine_filters : compound_filter list -> filter_operator -> compound_filter

(** {1 过滤统计功能} *)

(** 统计过滤结果
    @param result 过滤结果
    @return 统计信息键值对列表 *)
val analyze_filter_result : filter_result -> (string * string) list

(** 计算过滤效果
    @param before_count 过滤前数量
    @param after_count 过滤后数量
    @return 过滤效果分析 *)
val calculate_filter_effectiveness : int -> int -> (string * float) list

(** {1 预定义过滤器} *)

(** 高质量内容过滤器 *)
val high_quality_filter : compound_filter

(** 标准长度过滤器 *)
val standard_length_filter : compound_filter

(** 经典诗词过滤器 *)
val classical_poetry_filter : compound_filter

(** {1 过滤器管理} *)

(** 注册自定义过滤器
    @param name 过滤器名称
    @param filter 过滤器定义 *)
val register_custom_filter : string -> compound_filter -> unit

(** 获取注册的过滤器
    @param name 过滤器名称
    @return 过滤器选项 *)
val get_registered_filter : string -> compound_filter option

(** 列出所有注册的过滤器
    @return 过滤器名称列表 *)
val list_registered_filters : unit -> string list