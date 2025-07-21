(** 声调数据JSON加载器模块接口
    
    提供从JSON文件加载汉字声调数据的功能，替代原有的硬编码数据列表。
    支持缓存机制和降级处理，确保系统稳定性。
    
    @author 骆言技术债务清理团队
    @version 1.0 - JSON数据外化  
    @since 2025-07-21
*)

(** 声调数据错误类型 *)
type tone_data_error =
  | FileNotFound of string  (** 文件未找到 *)
  | ParseError of string    (** JSON解析错误 *)
  | InvalidData of string   (** 数据格式无效 *)

(** 声调数据错误异常 *)
exception ToneDataError of tone_data_error

(** 格式化错误信息 *)
val format_error : tone_data_error -> string

(** {1 数据加载接口} *)

(** 获取平声字符列表 *)
val get_ping_sheng_chars : unit -> string list

(** 获取上声字符列表 *)
val get_shang_sheng_chars : unit -> string list

(** 获取去声字符列表 *)
val get_qu_sheng_chars : unit -> string list

(** 获取入声字符列表 *)
val get_ru_sheng_chars : unit -> string list

(** 获取所有声调数据 
    @return (平声, 上声, 去声, 入声) 四元组 *)
val get_all_tone_data : unit -> string list * string list * string list * string list

(** {1 缓存和管理接口} *)

(** 重新加载数据（清除缓存） *)
val reload_tone_data : unit -> string list * string list * string list * string list

(** 验证数据完整性
    @return 数据是否有效 *)
val validate_data : unit -> bool

(** {1 内部接口} *)

(** 从JSON文件加载声调数据（可能抛出异常） *)
val load_tone_data_from_json : unit -> string list * string list * string list * string list

(** 安全加载函数（带降级机制） *)
val safe_load_tone_data : unit -> string list * string list * string list * string list