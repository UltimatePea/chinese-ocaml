(** 诗词艺术数据管理统一模块接口
 *
 * 此模块整合了数据加载、访问、解析、注册和模板管理等功能，
 * 提供统一的数据管理接口。
 *
 * 主要功能：
 * - 多源数据加载（文件、数据库、内存）
 * - 数据条目管理（增删改查）
 * - 模板系统支持
 * - 数据查询与搜索
 * - 数据完整性验证
 * - 批量操作支持
 * - 数据备份与恢复
 *
 * @author Whisky, PR Worker
 *)

(** {1 核心数据类型} *)

(** 数据源类型 *)
type data_source =
  | FileSource of string                      (** 文件数据源 *)
  | DatabaseSource of string                  (** 数据库数据源 *)
  | MemorySource of (string * string) list   (** 内存数据源 *)

(** 数据条目 *)
type data_entry = {
  id : string;                          (** 唯一标识符 *)
  content : string;                     (** 内容 *)
  metadata : (string * string) list;    (** 元数据 *)
  created_at : float;                   (** 创建时间 *)
  updated_at : float;                   (** 更新时间 *)
}

(** 数据注册表 *)
type data_registry = {
  entries : (string, data_entry) Hashtbl.t;   (** 数据条目表 *)
  mutable sources : data_source list;         (** 数据源列表 *)
  templates : (string, string) Hashtbl.t;     (** 模板表 *)
}

(** 全局数据注册表 *)
val global_registry : data_registry

(** {1 数据加载功能} *)

(** 从文件加载数据
    @param filename 文件名
    @return 文件内容选项 *)
val load_from_file : string -> string option

(** 解析数据内容
    @param content 原始内容
    @return 解析后的键值对列表 *)
val parse_data_content : string -> (string * string) list

(** 加载数据源
    @param source 数据源
    @return 加载的键值对列表 *)
val load_data_source : data_source -> (string * string) list

(** {1 数据条目管理} *)

(** 获取数据条目
    @param id 条目ID
    @return 数据条目选项 *)
val get_data_entry : string -> data_entry option

(** 设置数据条目
    @param id 条目ID
    @param content 内容
    @param metadata 元数据 *)
val set_data_entry : string -> string -> (string * string) list -> unit

(** 删除数据条目
    @param id 条目ID *)
val remove_data_entry : string -> unit

(** 列出所有条目ID
    @return 条目ID列表 *)
val list_entry_ids : unit -> string list

(** 查询满足条件的条目
    @param predicate 查询谓词
    @return 匹配的数据条目列表 *)
val query_entries : (data_entry -> bool) -> data_entry list

(** {1 模板系统} *)

(** 注册模板
    @param template_id 模板ID
    @param template_content 模板内容 *)
val register_template : string -> string -> unit

(** 获取模板
    @param template_id 模板ID
    @return 模板内容选项 *)
val get_template : string -> string option

(** 应用模板
    @param template_id 模板ID
    @param variables 变量映射
    @return 应用模板后的内容 *)
val apply_template : string -> (string * string) list -> string

(** 列出所有模板
    @return 模板ID列表 *)
val list_templates : unit -> string list

(** {1 数据源管理} *)

(** 添加数据源
    @param source 要添加的数据源 *)
val add_data_source : data_source -> unit

(** 初始化注册表 *)
val initialize_registry : unit -> unit

(** 重新加载所有数据源 *)
val reload_all_sources : unit -> unit

(** {1 数据导出功能} *)

(** 导出数据为字符串
    @return 导出的数据字符串 *)
val export_data_to_string : unit -> string

(** 导出模板为字符串
    @return 导出的模板字符串 *)
val export_templates_to_string : unit -> string

(** {1 统计与监控} *)

(** 获取注册表统计信息
    @return 统计信息键值对列表 *)
val get_registry_stats : unit -> (string * string) list

(** 验证数据完整性
    @return 发现的问题列表 *)
val validate_data_integrity : unit -> string list

(** {1 批量操作} *)

(** 批量设置数据
    @param data_list (ID, 内容, 元数据) 的列表 *)
val batch_set_data : (string * string * (string * string) list) list -> unit

(** 搜索数据
    @param query 搜索查询
    @return 匹配的数据条目列表 *)
val search_data : string -> data_entry list

(** {1 备份与恢复} *)

(** 备份数据
    @return 备份数据字符串 *)
val backup_data : unit -> string

(** 恢复数据
    @param backup_data 备份数据字符串
    @return 是否恢复成功 *)
val restore_data : string -> bool