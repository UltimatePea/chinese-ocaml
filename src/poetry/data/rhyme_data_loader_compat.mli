(** 韵律数据加载器兼容层接口 - Phase 2.2: 向后兼容性保证
    
    此模块提供与原始rhyme_data_loader完全一致的接口，内部使用
    unified_data_loader_comprehensive实现，确保100%向后兼容性。
    
    @author Alpha, 技术债务清理专员  
    @version 2.2 - Phase 2.2 兼容层
    @since 2025-07-29
    @fix_issue #1732 *)

(** {1 兼容性类型定义} *)

(* 使用Poetry_core的统一类型定义 *)
type rhyme_category = Poetry_core.Poetry_types.rhyme_category
type rhyme_group = Poetry_core.Poetry_types.rhyme_group

(** 韵律数据加载错误类型 *)
type rhyme_data_load_error =
  | RhymeFileNotFound of string
  | RhymeParseError of string * string
  | RhymeValidationError of string

exception RhymeDataLoadError of rhyme_data_load_error
(** 韵律数据加载异常 *)

(** {1 错误处理} *)

val format_rhyme_error : rhyme_data_load_error -> string
(** 格式化韵律数据错误信息 *)

(** {1 韵律数据加载接口} *)

val load_ping_sheng_rhymes : unit -> (string * rhyme_category * rhyme_group) list
(** 加载平声韵数据
    @return 平声韵字符列表，每个元素为 (字符, 韵类, 韵组) *)

val load_ze_sheng_rhymes : unit -> (string * rhyme_category * rhyme_group) list
(** 加载仄声韵数据
    @return 仄声韵字符列表，每个元素为 (字符, 韵类, 韵组) *)

val load_complete_rhyme_database : unit -> (string * rhyme_category * rhyme_group) list
(** 加载完整韵律数据库
    @return 完整韵律数据库，包含所有韵组的字符 *)

val safe_load_rhyme_database : unit -> (string * rhyme_category * rhyme_group) list
(** 安全加载韵律数据 - 带错误处理，失败时返回空列表并打印警告
    @return 韵律数据库字符列表 *)

(** {1 数据查询和统计} *)

val get_rhyme_char_count : (string * rhyme_category * rhyme_group) list -> int
(** 获取韵律数据库字符统计
    @param database 韵律数据库
    @return 字符总数 *)

val is_char_in_rhyme_database : string -> (string * rhyme_category * rhyme_group) list -> bool
(** 检查字符是否在韵律数据库中
    @param char 要检查的字符
    @param database 韵律数据库
    @return 是否在数据库中 *)

val get_char_list : (string * rhyme_category * rhyme_group) list -> string list
(** 获取韵律数据库中的字符列表
    @param database 韵律数据库
    @return 纯字符列表 *)