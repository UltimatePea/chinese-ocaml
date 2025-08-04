(** 诗词评价框架模块接口
 *
 * 此模块提供统一的诗词评价框架，整合各种评价器和评价标准，
 * 提供灵活、可扩展的评价体系。
 *
 * 主要功能：
 * - 统一评价框架
 * - 多评价器协调
 * - 评价流程管理
 * - 结果聚合处理
 * - 插件化评价器
 * - 评价质量保证
 *
 * @author Whisky, PR Worker
 *)

(** {1 评价框架类型定义} *)

(** 评价器注册信息 *)
type evaluator_registration = {
  evaluator_id : string;                (** 评价器ID *)
  name : string;                        (** 评价器名称 *)
  version : string;                     (** 版本号 *)
  description : string;                 (** 描述 *)
  supported_dimensions : string list;   (** 支持的评价维度 *)
  priority : int;                       (** 优先级 *)
  enabled : bool;                       (** 是否启用 *)
}

(** 评价任务 *)
type evaluation_task = {
  task_id : string;                     (** 任务ID *)
  poem_text : string;                   (** 诗词文本 *)
  requested_dimensions : string list;   (** 请求的评价维度 *)
  evaluation_standard : string option; (** 评价标准 *)
  custom_params : (string * string) list; (** 自定义参数 *)
  priority : int;                       (** 任务优先级 *)
  timeout : float option;               (** 任务超时时间 *)
}

(** 评价结果 *)
type framework_evaluation_result = {
  task_id : string;                     (** 任务ID *)
  poem_text : string;                   (** 原始诗词文本 *)
  overall_score : float;                (** 总体评分 *)
  dimension_results : (string * float * string) list; (** 维度结果（维度，分数，详情） *)
  evaluator_results : (string * string) list; (** 各评价器结果 *)
  execution_time : float;               (** 执行时间（毫秒） *)
  quality_indicators : (string * float) list; (** 质量指标 *)
  recommendations : string list;        (** 改进建议 *)
  metadata : (string * string) list;   (** 评价元数据 *)
}

(** 评价配置 *)
type evaluation_config = {
  enabled_evaluators : string list;    (** 启用的评价器列表 *)
  dimension_weights : (string * float) list; (** 维度权重 *)
  quality_thresholds : (string * float) list; (** 质量阈值 *)
  parallel_evaluation : bool;          (** 是否并行评价 *)
  cache_results : bool;                (** 是否缓存结果 *)
  detailed_feedback : bool;            (** 是否提供详细反馈 *)
}

(** {1 框架初始化与配置} *)

(** 初始化评价框架
    @param config 评价配置
    @return 初始化是否成功 *)
val initialize_framework : evaluation_config -> bool

(** 关闭评价框架 *)
val shutdown_framework : unit -> unit

(** 更新框架配置
    @param config 新配置
    @return 更新是否成功 *)
val update_framework_config : evaluation_config -> bool

(** 获取当前配置
    @return 当前评价配置 *)
val get_current_config : unit -> evaluation_config

(** {1 评价器管理} *)

(** 注册评价器
    @param registration 评价器注册信息
    @return 注册是否成功 *)
val register_evaluator : evaluator_registration -> bool

(** 注销评价器
    @param evaluator_id 评价器ID
    @return 注销是否成功 *)
val unregister_evaluator : string -> bool

(** 启用评价器
    @param evaluator_id 评价器ID
    @return 启用是否成功 *)
val enable_evaluator : string -> bool

(** 禁用评价器
    @param evaluator_id 评价器ID
    @return 禁用是否成功 *)
val disable_evaluator : string -> bool

(** 列出所有注册的评价器
    @return 评价器注册信息列表 *)
val list_registered_evaluators : unit -> evaluator_registration list

(** 获取评价器信息
    @param evaluator_id 评价器ID
    @return 评价器注册信息选项 *)
val get_evaluator_info : string -> evaluator_registration option

(** {1 评价任务管理} *)

(** 提交评价任务
    @param task 评价任务
    @return 任务是否成功提交 *)
val submit_evaluation_task : evaluation_task -> bool

(** 执行评价任务
    @param task 评价任务
    @return 评价结果 *)
val execute_evaluation_task : evaluation_task -> framework_evaluation_result

(** 批量执行评价任务
    @param tasks 评价任务列表
    @return 评价结果列表 *)
val batch_execute_tasks : evaluation_task list -> framework_evaluation_result list

(** 取消评价任务
    @param task_id 任务ID
    @return 取消是否成功 *)
val cancel_evaluation_task : string -> bool

(** 获取任务状态
    @param task_id 任务ID
    @return 任务状态信息 *)
val get_task_status : string -> (string * string) list

(** {1 评价结果处理} *)

(** 聚合评价结果
    @param partial_results 部分评价结果列表
    @param weights 权重配置
    @return 聚合后的评价结果 *)
val aggregate_evaluation_results : 
  (string * float * string) list -> (string * float) list -> framework_evaluation_result

(** 验证评价结果质量
    @param result 评价结果
    @return 质量验证报告 *)
val validate_result_quality : framework_evaluation_result -> (string * bool * string) list

(** 生成评价摘要
    @param result 评价结果
    @return 评价摘要字符串 *)
val generate_evaluation_summary : framework_evaluation_result -> string

(** 比较评价结果
    @param result1 第一个结果
    @param result2 第二个结果
    @return 比较分析报告 *)
val compare_evaluation_results : 
  framework_evaluation_result -> framework_evaluation_result -> (string * string) list

(** {1 评价标准管理} *)

(** 注册评价标准
    @param standard_name 标准名称
    @param standard_config 标准配置
    @return 注册是否成功 *)
val register_evaluation_standard : string -> (string * string) list -> bool

(** 应用评价标准
    @param standard_name 标准名称
    @param poem_text 诗词文本
    @return 评价结果 *)
val apply_evaluation_standard : string -> string -> framework_evaluation_result

(** 列出可用标准
    @return 标准名称列表 *)
val list_available_standards : unit -> string list

(** 获取标准详情
    @param standard_name 标准名称
    @return 标准配置选项 *)
val get_standard_details : string -> (string * string) list option

(** {1 评价流程控制} *)

(** 创建评价流水线
    @param pipeline_name 流水线名称
    @param evaluator_sequence 评价器序列
    @return 创建是否成功 *)
val create_evaluation_pipeline : string -> string list -> bool

(** 执行评价流水线
    @param pipeline_name 流水线名称
    @param poem_text 诗词文本
    @return 评价结果 *)
val execute_evaluation_pipeline : string -> string -> framework_evaluation_result

(** 删除评价流水线
    @param pipeline_name 流水线名称
    @return 删除是否成功 *)
val delete_evaluation_pipeline : string -> bool

(** 列出所有流水线
    @return 流水线名称列表 *)
val list_evaluation_pipelines : unit -> string list

(** {1 性能监控与优化} *)

(** 获取框架性能统计
    @return 性能统计信息 *)
val get_framework_performance_stats : unit -> (string * float) list

(** 优化评价器执行顺序
    @param dimension_priorities 维度优先级
    @return 优化后的执行顺序 *)
val optimize_evaluator_order : (string * int) list -> string list

(** 监控评价器性能
    @param evaluator_id 评价器ID
    @return 性能监控报告 *)
val monitor_evaluator_performance : string -> (string * float) list

(** 生成性能报告
    @param time_range 时间范围（秒）
    @return 性能报告 *)
val generate_performance_report : float -> string

(** {1 质量保证} *)

(** 设置质量检查规则
    @param rules 质量规则列表
    @return 设置是否成功 *)
val set_quality_assurance_rules : (string * (framework_evaluation_result -> bool)) list -> bool

(** 执行质量检查
    @param result 评价结果
    @return 质量检查报告 *)
val perform_quality_check : framework_evaluation_result -> (string * bool * string) list

(** 自动质量校准
    @param reference_results 参考评价结果列表
    @return 校准是否成功 *)
val auto_quality_calibration : framework_evaluation_result list -> bool

(** {1 插件化支持} *)

(** 加载评价器插件
    @param plugin_path 插件路径
    @return 加载是否成功 *)
val load_evaluator_plugin : string -> bool

(** 卸载评价器插件
    @param plugin_name 插件名称
    @return 卸载是否成功 *)
val unload_evaluator_plugin : string -> bool

(** 列出已加载插件
    @return 插件名称列表 *)
val list_loaded_plugins : unit -> string list

(** {1 结果导出与持久化} *)

(** 导出评价结果
    @param result 评价结果
    @param format 导出格式（"json", "xml", "csv"）
    @return 导出的数据字符串 *)
val export_evaluation_result : framework_evaluation_result -> string -> string

(** 保存评价结果
    @param result 评价结果
    @param storage_key 存储键
    @return 保存是否成功 *)
val save_evaluation_result : framework_evaluation_result -> string -> bool

(** 加载评价结果
    @param storage_key 存储键
    @return 评价结果选项 *)
val load_evaluation_result : string -> framework_evaluation_result option

(** 批量导出结果
    @param results 评价结果列表
    @param format 导出格式
    @return 导出的数据字符串 *)
val batch_export_results : framework_evaluation_result list -> string -> string