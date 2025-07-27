(** Token处理统一工具模块接口 - 消除Token系统重复代码
    
    Phase 7 技术债务清理 - Token系统重复消除
    
    @author Beta, 代码审查代理
    @version 1.0
    @since 2025-07-27 - Fix #1429 *)

(** ======================================================================== 
    Token类型检查和验证工具
    ======================================================================== *)

(** Token验证结果 *)
type token_validation_result = 
  | ValidToken of string
  | InvalidToken of string
  | UnknownToken

(** 通用Token验证器类型 *)
type 'token token_validator = 'token -> token_validation_result

(** 创建Token类型错误 *)
val create_token_error : string -> string -> string

(** 安全的Token类型检查 *)
val safe_token_type_check : 
  'token token_validator -> 
  'token -> 
  Common_patterns.error_context -> 
  (string, string) result

(** 批量Token验证 *)
val validate_token_list : 
  'token token_validator list -> 
  'token list -> 
  Common_patterns.error_context -> 
  (string list, string) result

(** ======================================================================== 
    Token匹配和转换表工具
    ======================================================================== *)

(** Token匹配模式类型 *)
type 'token token_pattern = 'token -> bool

(** Token转换处理器类型 *)
type 'token token_handler = 'token -> string

(** Token匹配规则 *)
type 'token token_rule = 'token token_pattern * 'token token_handler

(** 创建Token匹配规则 *)
val make_token_rule : 'token token_pattern -> 'token token_handler -> 'token token_rule

(** 规则集合创建器 *)
val create_literal_token_rules : unit -> 'token token_rule list
val create_identifier_token_rules : unit -> 'token token_rule list
val create_keyword_token_rules : unit -> 'token token_rule list
val create_operator_token_rules : unit -> 'token token_rule list

(** 统一的Token转换器 *)
val convert_token_with_rules : 
  'token token_rule list -> 
  'token -> 
  default_handler:('token -> string) -> 
  string

(** 分类Token转换器 *)
val convert_token_by_category : 'token -> string

(** ======================================================================== 
    Token注册表和映射工具
    ======================================================================== *)

(** Token注册表类型 *)
type ('key, 'value) token_registry = ('key, 'value) Hashtbl.t

(** 创建Token注册表 *)
val create_token_registry : ?size:int -> unit -> ('key, 'value) token_registry

(** 批量注册Token映射 *)
val register_token_mappings : 
  ('key, 'value) token_registry -> 
  ('key * 'value) list -> 
  unit

(** 安全的Token查找 *)
val lookup_token_safe : 
  ('key, 'value) token_registry -> 
  'key -> 
  default:'value -> 
  context:Common_patterns.error_context -> 
  ('value, string) result

(** Token映射统计信息 *)
val get_registry_stats : ('key, 'value) token_registry -> string

(** 清理Token注册表 *)
val cleanup_token_registry : ('key, 'value) token_registry -> unit

(** ======================================================================== 
    Token分发和路由工具
    ======================================================================== *)

(** Token分发器类型 *)
type 'token token_dispatcher = {
  literal_handler : 'token -> string;
  identifier_handler : 'token -> string;
  keyword_handler : 'token -> string;
  operator_handler : 'token -> string;
  delimiter_handler : 'token -> string;
  unknown_handler : 'token -> string;
}

(** 创建默认Token分发器 *)
val create_default_dispatcher : unit -> 'token token_dispatcher

(** Token类型判断器 *)
type 'token token_classifier = {
  is_literal : 'token -> bool;
  is_identifier : 'token -> bool;
  is_keyword : 'token -> bool;
  is_operator : 'token -> bool;
  is_delimiter : 'token -> bool;
}

(** 使用分发器处理Token *)
val dispatch_token : 
  'token token_classifier -> 
  'token token_dispatcher -> 
  'token -> 
  string

(** ======================================================================== 
    Token转换性能优化工具
    ======================================================================== *)

(** Token转换缓存模块 *)
module TokenCache : sig
  type ('token, 'result) cache
  
  val create : ?size:int -> unit -> ('token, 'result) cache
  val get_or_compute : ('token, 'result) cache -> 'token -> compute:('token -> 'result) -> 'result
  val clear_cache : ('token, 'result) cache -> unit
  val cache_stats : ('token, 'result) cache -> string
end

(** 延迟Token映射加载器 *)
val create_lazy_token_mapping : (unit -> 'mapping) -> (unit -> 'mapping)

(** ======================================================================== 
    Token批处理工具
    ======================================================================== *)

(** 批量Token转换 *)
val batch_convert_tokens : ('token -> 'result) -> 'token list -> 'result list

(** 并行Token处理 *)
val parallel_token_processing : ('token -> 'result) -> 'token list -> 'result list

(** Token流处理器 *)
val process_token_stream : ('token -> 'result) -> 'token list -> 'result list

(** 有状态的Token处理器 *)
type ('state, 'token, 'result) token_processor_state = {
  current_state : 'state;
  process_token : 'state -> 'token -> ('state * 'result) option;
}

val process_tokens_with_state : 
  'state -> 
  ('state, 'token, 'result) token_processor_state -> 
  'token list -> 
  (('result list * 'state), string) result

(** ======================================================================== 
    Token错误恢复和回退机制
    ======================================================================== *)

(** Token错误恢复策略 *)
type token_recovery_strategy = 
  | SkipToken
  | UseDefault of string
  | RetryWithFallback of (unit -> string)

(** 错误恢复的Token处理 *)
val resilient_token_processing : 
  ('token -> string) -> 
  token_recovery_strategy -> 
  'token -> 
  (string, string) result