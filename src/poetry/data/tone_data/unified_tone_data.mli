(** 统一声调数据模块接口 - 合并四声数据
    
    提供统一的声调数据访问接口，整合平声、上声、去声、入声的所有功能。
    保持向后兼容性，同时提供新的统一API。
    
    Author: Alpha, 主要工作代理 - Poetry模块重构Phase 1
    Fix #1765 - Poetry韵律数据重复整合优化 *)

(** {1 平声数据接口} *)

(** 获取平声字符列表 *)
val get_ping_sheng_chars : unit -> string list

(** 检查字符是否为平声 *)
val is_ping_sheng : string -> bool

(** 平声字符数量 *)
val count_ping_sheng : unit -> int

(** {1 上声数据接口} *)

(** 获取上声字符列表 *)
val get_shang_sheng_chars : unit -> string list

(** 检查字符是否为上声 *)
val is_shang_sheng : string -> bool

(** 上声字符数量 *)
val count_shang_sheng : unit -> int

(** {1 去声数据接口} *)

(** 获取去声字符列表 *)
val get_qu_sheng_chars : unit -> string list

(** 检查字符是否为去声 *)
val is_qu_sheng : string -> bool

(** 去声字符数量 *)
val count_qu_sheng : unit -> int

(** {1 入声数据接口} *)

(** 获取入声字符列表 *)
val get_ru_sheng_chars : unit -> string list

(** 检查字符是否为入声 *)
val is_ru_sheng : string -> bool

(** 入声字符数量 *)
val count_ru_sheng : unit -> int

(** {1 统一声调API} *)

(** 声调类型 *)
type tone_type = Ping | Shang | Qu | Ru

(** 获取指定声调的字符列表 *)
val get_chars_by_tone : tone_type -> string list

(** 检查字符的声调类型 *)
val get_tone_type : string -> tone_type option

(** 获取所有声调的字符统计 *)
val get_tone_statistics : unit -> (string * int) list

(** 验证统一声调数据的完整性 *)
val validate_unified_data : unit -> bool