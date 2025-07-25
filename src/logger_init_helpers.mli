(** 日志器初始化助手模块接口 - Logger Initialization Helpers Interface

    技术债务改进：统一日志器初始化模式 Phase 2.1 - Fix #1077

    本模块提供标准化的日志器初始化函数，用于替代项目中重复的日志器初始化代码。

    @author 骆言AI代理
    @version 2.1 - 统一日志器初始化
    @since 2025-07-24 Fix #1077 *)

(** 模块类型定义，用于智能初始化策略 *)
type module_category =
  | ValueModule  (** 值操作相关模块 *)
  | TypeModule  (** 类型系统相关模块 *)
  | ParserModule  (** 解析器相关模块 *)
  | LexerModule  (** 词法分析器相关模块 *)
  | SemanticModule  (** 语义分析相关模块 *)
  | CodegenModule  (** 代码生成相关模块 *)
  | UtilityModule  (** 工具类模块 *)

val infer_module_category : string -> module_category
(** 根据模块名推断模块类型 *)

val init_module_logger : string -> unit
(** 统一的模块初始化函数 - 替代 Logger_utils.init_no_logger *)

val init_multiple_modules : string list -> unit
(** 批量初始化多个模块的日志器 *)

val init_value_modules : unit -> unit
(** 预定义的Value相关模块批量初始化 *)

val init_type_modules : unit -> unit
(** 预定义的Type相关模块批量初始化 *)

val smart_init_related_modules : string -> unit
(** 智能初始化：根据当前模块上下文自动初始化相关模块 *)

val replace_init_no_logger : string -> unit
(** 兼容性函数：直接替换现有的 Logger_utils.init_no_logger 调用 *)
