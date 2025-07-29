(** 声调数据加载器兼容层接口 - Phase 2.2: 向后兼容性保证
    
    此模块提供与原始tone_data_loader完全一致的接口，内部使用
    unified_data_loader_comprehensive实现，确保100%向后兼容性。
    
    @author Alpha, 技术债务清理专员
    @version 2.2 - Phase 2.2 兼容层
    @since 2025-07-29
    @fix_issue #1732 *)

(** {1 兼容性错误类型} *)

(** 声调数据错误类型 *)
type tone_data_error =
  | FileNotFound of string  (** 文件未找到 *)
  | ParseError of string  (** JSON解析错误 *)
  | InvalidData of string  (** 数据格式无效 *)

exception ToneDataError of tone_data_error
(** 声调数据错误异常 *)

(** {1 错误处理} *)

val format_error : tone_data_error -> string
(** 格式化错误信息 *)

(** {1 数据加载接口} *)

val get_ping_sheng_chars : unit -> string list
(** 获取平声字符列表 *)

val get_shang_sheng_chars : unit -> string list
(** 获取上声字符列表 *)

val get_qu_sheng_chars : unit -> string list
(** 获取去声字符列表 *)

val get_ru_sheng_chars : unit -> string list
(** 获取入声字符列表 *)

val get_all_tone_data : unit -> string list * string list * string list * string list
(** 获取所有声调数据
    @return (平声, 上声, 去声, 入声) 四元组 *)

(** {1 缓存和管理接口} *)

val reload_tone_data : unit -> string list * string list * string list * string list
(** 重新加载数据（清除缓存） *)

val validate_data : unit -> bool
(** 验证数据完整性
    @return 数据是否有效 *)

(** {1 内部接口} *)

val load_tone_data_from_json : unit -> string list * string list * string list * string list
(** 从JSON文件加载声调数据（可能抛出异常） *)

val safe_load_tone_data : unit -> string list * string list * string list * string list
(** 安全加载函数（带降级机制） *)