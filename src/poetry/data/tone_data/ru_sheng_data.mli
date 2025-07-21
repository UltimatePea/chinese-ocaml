(** 入声字符数据模块接口 - 第二阶段技术债务重构版本
 
    数据外化重构版本的公共接口，提供懒加载的入声字符数据访问，
    同时保持与原始模块的向后兼容性。
    
    修复 Issue #801 - 技术债务改进第二阶段：超长函数重构和数据外化
 
    @author 骆言诗词编程团队
    @version 2.0 (数据外化重构版)
    @since 2025-07-21 - 技术债务改进第二阶段 *)

(** {1 数据加载异常} *)

exception Ru_sheng_data_error of string

(** {1 懒加载数据} *)

(** 入声字符数据列表 (懒加载) *)
val ru_sheng_chars : string list Lazy.t

(** {1 兼容性接口函数} *)

(** 获取入声字符列表 *)
val get_ru_sheng_chars : unit -> string list

(** 检查字符是否为入声 *)
val is_ru_sheng : string -> bool

(** {1 扩展功能} *)

(** 获取入声字符数量 *)
val get_ru_sheng_count : unit -> int

(** 获取数据元信息 *)
val get_metadata : unit -> string * string * string * string

(** {1 调试和验证函数} *)

(** 验证数据完整性 *)
val validate_data : unit -> unit