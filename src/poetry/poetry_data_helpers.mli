(** 骆言诗词统一数据辅助模块接口 - 韵律工具和辅助模块整合
 *
 * Issue #2015: 韵律工具和辅助模块整合
 * 统一数据辅助模块的公共接口定义
 *
 * Author: Whisky, PR Worker
 * @since 2025-08-01
 * @version 1.0 - 初始整合版本
 *)

open Poetry_core.Poetry_types

(** {1 韵律数据构造辅助函数} *)

(** === 基础韵字符组构造器 === *)

(** 创建平声韵字符组 *)
val make_ping_sheng_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list

(** 创建上声韵字符组 *)
val make_shang_sheng_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list

(** 创建去声韵字符组 *)
val make_qu_sheng_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list

(** 创建入声韵字符组 *)
val make_ru_sheng_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list

(** 创建仄声韵字符组 *)
val make_ze_sheng_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list

(** 创建混合声调韵字符组 *)
val make_mixed_tone_group : rhyme_group -> (string * rhyme_category) list -> (string * rhyme_category * rhyme_group) list

(** === 批量韵组构造器 === *)

(** 创建多个平声韵组 *)
val make_multiple_ping_sheng_groups : rhyme_group -> string list list -> (string * rhyme_category * rhyme_group) list

(** === 常用韵组预设 === *)

(** 诗词常用韵组构造器 *)
module Poetry_group_builder : sig
  (** 创建诗词核心韵组 *)
  val make_poetry_core : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list

  (** 创建方位韵组 *)
  val make_direction_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list

  (** 创建自然韵组 *)
  val make_nature_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list

  (** 创建情感韵组 *)
  val make_emotion_group : rhyme_group -> string list -> (string * rhyme_category * rhyme_group) list
end

(** === 韵组合并工具 === *)

(** 合并多个韵组为单一列表 *)
val merge_rhyme_groups : (string * rhyme_category * rhyme_group) list list -> (string * rhyme_category * rhyme_group) list

(** 按韵部分组韵字 *)
val group_by_rhyme : (string * rhyme_category * rhyme_group) list -> (rhyme_group * (string * rhyme_category) list) list

(** === 韵律验证工具 === *)

(** 验证韵组一致性 *)
val validate_rhyme_group : (string * rhyme_category * rhyme_group) list -> bool

(** 检查重复字符 *)
val check_duplicate_chars : (string * rhyme_category * rhyme_group) list -> string list

(** {1 核心韵律数据辅助函数} *)

(** 创建韵律数据条目的辅助函数 *)
val make_entry : string -> rhyme_category -> rhyme_group -> ?variants:string list -> ?frequency:float -> unit -> rhyme_data_entry

(** 创建某个韵组字符列表的辅助函数 *)
val make_group_entries : rhyme_category -> rhyme_group -> string list -> rhyme_data_entry list

(** {1 文件系统辅助工具} *)

(** === 路径处理 === *)

(** 构建文件路径 *)
val build_filepath : string -> string

(** === 文件内容读取 === *)

(** 读取文件内容 *)
val read_file_content : string -> string

(** === 文件存在性检查 === *)

(** 检查文件是否存在，如果不存在则发出警告 *)
val file_exists_or_warn : string -> bool

(** === 安全文件操作 === *)

(** 安全读取文件内容，包含错误处理 *)
val safe_read_file : string -> string option

(** === 文件信息 === *)

(** 获取文件大小 *)
val get_file_size : string -> int

(** 检查文件是否为普通文件 *)
val is_regular_file : string -> bool

(** {1 数据加载辅助工具} *)

(** === 数据解析辅助 === *)

(** 安全解析JSON内容 *)
val safe_parse_json : string -> Yojson.Safe.t option

(** 从JSON中提取字符串列表 *)
val extract_string_list_from_json : Yojson.Safe.t -> string -> string list

(** 从JSON中提取韵组数据 *)
val extract_rhyme_group_from_json : Yojson.Safe.t -> (string list * string * string) option

(** === 批量数据处理 === *)

(** 批量读取多个数据文件 *)
val batch_read_files : string list -> (string * string) list

(** 批量验证数据文件 *)
val validate_data_files : string list -> string list * string list

(** {1 韵律数据特定工具} *)

(** === 韵律数据标准化 === *)

(** 标准化韵字符格式 *)
val normalize_rhyme_char : string -> string

(** 标准化韵组数据 *)
val normalize_rhyme_group_data : (string * rhyme_category * rhyme_group) list -> (string * rhyme_category * rhyme_group) list

(** === 韵律数据统计工具 === *)

(** 统计韵组分布 *)
val count_rhyme_groups : (string * rhyme_category * rhyme_group) list -> (rhyme_group * int) list

(** 统计声调分布 *)
val count_tone_distribution : (string * rhyme_category * rhyme_group) list -> (rhyme_category * int) list

(** {1 数据完整性验证} *)

(** === 数据一致性检查 === *)

(** 检查韵律数据完整性 *)
val validate_rhyme_data_integrity : (string * rhyme_category * rhyme_group) list -> string list

(** 验证文件路径安全性 *)
val validate_file_path : string -> bool

(** {1 缓存友好的数据操作} *)

(** === 高效数据查找 === *)

(** 构建韵字符查找表 *)
val build_char_lookup_table : (string * rhyme_category * rhyme_group) list -> (string, rhyme_category * rhyme_group) Hashtbl.t

(** 构建韵组字符表 *)
val build_group_char_table : (string * rhyme_category * rhyme_group) list -> (rhyme_group, string list) Hashtbl.t