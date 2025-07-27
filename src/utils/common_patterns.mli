(** 通用模式工具模块接口 - 消除代码重复的核心工具集
    
    Phase 7 技术债务清理 - 代码重复消除
    
    @author Beta, 代码审查代理
    @version 1.0 
    @since 2025-07-27 - Fix #1429 *)

(** ======================================================================== 
    错误处理和上下文管理工具
    ======================================================================== *)

(** 错误上下文类型 *)
type error_context = {
  module_name : string;
  function_name : string;
  operation : string option;
}

(** 创建错误上下文 *)
val make_error_context : 
  ?operation:string option -> 
  module_name:string -> 
  function_name:string -> 
  unit -> error_context

(** 格式化上下文错误消息 *)
val format_contextual_error : error_context -> string -> string

(** 带上下文的参数验证 *)
val validate_with_context : 
  ('a -> 'b) -> error_context -> 'a -> ('b, string) result

(** 安全操作包装器 *)
val safe_operation : 
  ?context:error_context option ->
  error_handler:(string -> string) ->
  (unit -> 'a) -> ('a, string) result

(** ======================================================================== 
    通用Token处理工具
    ======================================================================== *)

(** 通用token匹配器 *)
val match_token_with_handlers : 
  'token -> 
  (('token -> bool) * ('token -> 'result)) list ->
  default:('token -> 'result) -> 
  'result

(** Token到字符串转换 *)
val token_to_string_with_mapping : 
  ('token * string) list -> 
  'token -> 
  default_formatter:('token -> string) -> 
  string

(** 安全的token查找 *)
val safe_token_lookup : 
  ('key, 'value) Hashtbl.t -> 
  'key -> 
  default:'value option -> 
  'value option

(** Result类型的token处理 *)
val safe_token_operation : 
  ('token -> 'result) -> 
  'token -> 
  ('result, string) result

(** ======================================================================== 
    数据加载工具
    ======================================================================== *)

(** 通用字符组加载器 *)
val load_character_groups : 
  (string -> 'data list) -> 
  string list -> 
  'data list list

(** JSON文件安全解析 *)
val safe_json_parse : string -> (Yojson.Basic.t, string) result

(** 带回退的数据文件查找 *)
val find_data_file_with_candidates : string list -> string option

(** 延迟初始化数据加载器 *)
val create_lazy_data_loader : (unit -> 'data) -> (unit -> 'data)

(** ======================================================================== 
    List处理工具
    ======================================================================== *)

(** 安全的List.map *)
val safe_map_with_context : 
  ('item -> 'result) -> 
  error_context -> 
  'item list -> 
  ('result list, string) result

(** 累积器模式实现 *)
val collect_with_accumulator : 
  ('item -> 'result option) -> 
  'result list -> 
  'item list -> 
  'result list

(** 数据组装工具 *)
val assemble_data_groups : 
  'group list -> 
  ('group -> 'data list) -> 
  'data list

(** 安全的列表索引访问 *)
val safe_list_nth : 'a list -> int -> default:'a -> 'a

(** ======================================================================== 
    String处理工具
    ======================================================================== *)

(** 安全的字符串连接 *)
val safe_string_concat : string -> string list -> string

(** 位置信息类型 *)
type source_position = { filename : string; line : int; column : int }

(** 位置信息格式化 *)
val format_position : ?include_file:bool -> source_position -> string

(** 调试消息格式化 *)
val format_debug_message : string -> string -> string

(** 参数错误消息格式化 *)
val format_param_error : string -> int -> int -> string

(** ======================================================================== 
    Parser通用工具
    ======================================================================== *)

(** 通用表达式解析分发器 *)
val parse_by_token_type : 
  (('token -> bool) * ('token -> 'state -> ('result, string) result)) list ->
  ('token -> 'state -> ('result, string) result) ->
  'token -> 'state -> ('result, string) result

(** 简化的参数收集函数 *)
val collect_with_terminator : 
  ('token -> bool) -> 
  ('state -> ('expr * 'state, string) result) ->
  ('state -> 'token * source_position) ->
  'state -> 
  (('expr list * 'state), string) result

(** 简化的状态推进验证 *)
val validate_and_advance : 
  ('state -> 'token * source_position) ->
  ('state -> 'state) ->
  ('token -> bool) -> 
  'state -> 
  ('state, string) result

(** ======================================================================== 
    统一的printf模式
    ======================================================================== *)

(** 错误消息打印 *)
val print_error : error_context -> string -> unit

(** 调试信息打印 *)
val print_debug_info : ?prefix:string -> string -> unit

(** 警告信息打印 *)
val print_warning : ?prefix:string -> string -> unit

(** 进度报告 *)
val print_progress : string -> string -> unit