(** 数据查询管理器模块接口
 *
 * 此模块提供统一的数据查询接口，支持多种查询方式和条件组合，
 * 包括结构化查询、全文检索、模糊匹配等功能。
 *
 * 主要功能：
 * - 结构化查询支持
 * - 全文搜索引擎
 * - 复杂条件组合
 * - 查询结果缓存
 * - 查询性能优化
 * - 查询统计分析
 *
 * @author Whisky, PR Worker
 *)

(** {1 查询类型定义} *)

(** 查询条件 *)
type query_condition = 
  | Equals of string * string           (** 等于条件 *)
  | Contains of string * string         (** 包含条件 *)
  | StartsWith of string * string       (** 以...开始 *)
  | EndsWith of string * string         (** 以...结束 *)
  | Range of string * float * float     (** 范围条件 *)
  | GreaterThan of string * float       (** 大于条件 *)
  | LessThan of string * float          (** 小于条件 *)
  | In of string * string list          (** 在列表中 *)
  | Regex of string * string            (** 正则表达式匹配 *)
  | Custom of (string -> bool)          (** 自定义条件函数 *)

(** 查询操作符 *)
type query_operator = 
  | And   (** 逻辑与 *)
  | Or    (** 逻辑或 *)
  | Not   (** 逻辑非 *)

(** 复合查询 *)
type compound_query = 
  | SimpleQuery of query_condition
  | CompoundQuery of compound_query * query_operator * compound_query

(** 排序方式 *)
type sort_order = 
  | Ascending   (** 升序 *)
  | Descending  (** 降序 *)

(** 排序条件 *)
type sort_criteria = {
  field : string;           (** 排序字段 *)
  order : sort_order;       (** 排序方式 *)
}

(** 查询选项 *)
type query_options = {
  limit : int option;                   (** 结果数量限制 *)
  offset : int option;                  (** 结果偏移量 *)
  sort_by : sort_criteria list;        (** 排序条件 *)
  include_metadata : bool;              (** 是否包含元数据 *)
  cache_results : bool;                 (** 是否缓存结果 *)
  timeout : float option;               (** 查询超时时间（秒） *)
}

(** 查询结果 *)
type query_result = {
  items : (string * string * (string * string) list) list; (** (ID, 内容, 元数据) 列表 *)
  total_count : int;                    (** 总结果数 *)
  execution_time : float;               (** 执行时间（毫秒） *)
  cache_hit : bool;                     (** 是否命中缓存 *)
  query_metadata : (string * string) list; (** 查询元数据 *)
}

(** {1 基础查询操作} *)

(** 执行查询
    @param query 查询条件
    @param options 查询选项
    @return 查询结果 *)
val execute_query : compound_query -> query_options -> query_result

(** 简单查询
    @param field 字段名
    @param value 字段值
    @param options 查询选项
    @return 查询结果 *)
val simple_search : string -> string -> query_options -> query_result

(** 全文搜索
    @param text 搜索文本
    @param options 查询选项
    @return 查询结果 *)
val full_text_search : string -> query_options -> query_result

(** 模糊匹配查询
    @param pattern 匹配模式
    @param options 查询选项
    @return 查询结果 *)
val fuzzy_search : string -> query_options -> query_result

(** {1 复杂查询构建} *)

(** 创建等于条件
    @param field 字段名
    @param value 值
    @return 查询条件 *)
val create_equals_condition : string -> string -> query_condition

(** 创建包含条件
    @param field 字段名
    @param value 值
    @return 查询条件 *)
val create_contains_condition : string -> string -> query_condition

(** 创建范围条件
    @param field 字段名
    @param min_value 最小值
    @param max_value 最大值
    @return 查询条件 *)
val create_range_condition : string -> float -> float -> query_condition

(** 组合查询条件
    @param query1 第一个查询
    @param operator 操作符
    @param query2 第二个查询
    @return 复合查询 *)
val combine_queries : compound_query -> query_operator -> compound_query -> compound_query

(** {1 结果处理} *)

(** 分页查询结果
    @param result 原始结果
    @param page_size 页大小
    @param page_number 页号（从1开始）
    @return 分页后的结果 *)
val paginate_results : query_result -> int -> int -> query_result

(** 排序查询结果
    @param result 原始结果
    @param criteria 排序条件列表
    @return 排序后的结果 *)
val sort_results : query_result -> sort_criteria list -> query_result

(** 过滤查询结果
    @param result 原始结果
    @param filter_condition 过滤条件
    @return 过滤后的结果 *)
val filter_results : query_result -> query_condition -> query_result

(** {1 索引管理} *)

(** 创建字段索引
    @param field 字段名
    @return 创建是否成功 *)
val create_index : string -> bool

(** 删除字段索引
    @param field 字段名
    @return 删除是否成功 *)
val drop_index : string -> bool

(** 列出所有索引
    @return 索引字段列表 *)
val list_indexes : unit -> string list

(** 重建索引
    @param field 字段名选项（None表示重建所有索引）
    @return 重建是否成功 *)
val rebuild_index : string option -> bool

(** {1 查询优化} *)

(** 分析查询性能
    @param query 查询条件
    @return 性能分析报告 *)
val analyze_query_performance : compound_query -> (string * string) list

(** 优化查询
    @param query 原始查询
    @return 优化后的查询 *)
val optimize_query : compound_query -> compound_query

(** 获取查询执行计划
    @param query 查询条件
    @return 执行计划描述 *)
val get_execution_plan : compound_query -> string list

(** {1 查询缓存} *)

(** 启用查询缓存
    @param cache_size 缓存大小
    @param ttl 缓存TTL（秒） *)
val enable_query_cache : int -> float -> unit

(** 禁用查询缓存 *)
val disable_query_cache : unit -> unit

(** 清空查询缓存
    @return 清理的缓存条目数 *)
val clear_query_cache : unit -> int

(** 获取缓存统计
    @return 缓存统计信息 *)
val get_cache_stats : unit -> (string * int) list

(** {1 查询统计} *)

(** 记录查询统计
    @param query 查询条件
    @param execution_time 执行时间
    @param result_count 结果数量 *)
val record_query_stats : compound_query -> float -> int -> unit

(** 获取查询统计报告
    @return 统计报告 *)
val get_query_statistics : unit -> (string * string) list

(** 获取热门查询
    @param limit 返回数量限制
    @return 热门查询列表 *)
val get_popular_queries : int -> (string * int) list

(** {1 高级功能} *)

(** 保存查询模板
    @param template_name 模板名称
    @param query 查询条件
    @param options 查询选项 *)
val save_query_template : string -> compound_query -> query_options -> unit

(** 执行查询模板
    @param template_name 模板名称
    @param parameters 参数替换映射
    @return 查询结果 *)
val execute_query_template : string -> (string * string) list -> query_result

(** 列出查询模板
    @return 模板名称列表 *)
val list_query_templates : unit -> string list

(** 删除查询模板
    @param template_name 模板名称
    @return 删除是否成功 *)
val delete_query_template : string -> bool

(** {1 实时查询} *)

(** 订阅查询结果变化
    @param query 查询条件
    @param callback 变化回调函数
    @return 订阅ID *)
val subscribe_query_changes : compound_query -> (query_result -> unit) -> string

(** 取消查询订阅
    @param subscription_id 订阅ID
    @return 取消是否成功 *)
val unsubscribe_query_changes : string -> bool

(** 触发查询更新通知
    @param affected_fields 受影响的字段列表 *)
val notify_data_changes : string list -> unit