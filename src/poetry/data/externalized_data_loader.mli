(** 外化数据加载器接口 - 重构版本
    
    本模块作为协调器，使用已经模块化的组件来提供统一的数据访问接口。
    重构目标：减少代码重复，使用现有的模块化结构。
    
    @author 骆言技术债务清理团队
    @version 2.0 - 重构版本
    @since 2025-07-20 *)

(** 外化数据错误类型 *)
type externalized_data_error =
  | FileNotFound of string
  | ParseError of string * string
  | ValidationError of string

(** 外化数据异常 *)
exception ExternalizedDataError of externalized_data_error

(** 格式化错误信息
    @param error 错误类型
    @return 格式化的错误消息字符串 *)
val format_error : externalized_data_error -> string

(** 获取基础自然名词列表
    提供降级机制，当模块化系统加载失败时使用默认数据
    @return 自然名词字符串列表 *)
val get_nature_nouns : unit -> string list

(** 获取地理政治名词列表
    @return 地理政治名词字符串列表 *)
val get_geography_politics_nouns : unit -> string list

(** 获取人物关系名词列表
    @return 人物关系名词字符串列表 *)
val get_person_relation_nouns : unit -> string list

(** 获取社会地位名词列表
    @return 社会地位名词字符串列表 *)
val get_social_status_nouns : unit -> string list

(** 获取工具物品名词列表
    @return 工具物品名词字符串列表 *)
val get_tools_objects_nouns : unit -> string list

(** 获取建筑场所名词列表
    @return 建筑场所名词字符串列表 *)
val get_building_place_nouns : unit -> string list

(** 验证数据完整性
    检查所有数据模块是否正确加载
    @return 验证结果，成功时返回true *)
val validate_data_integrity : unit -> bool

(** 兼容性接口 - 支持旧代码 *)

(** 获取自然名词列表（兼容旧接口）
    @return 自然名词字符串列表 *)
val get_nature_nouns_list : unit -> string list

(** 获取量词列表（兼容旧接口）
    @return 量词字符串列表 *)
val get_measuring_classifiers_list : unit -> string list

(** 获取工具物品列表（兼容旧接口）
    @return 工具物品字符串列表 *)
val get_tools_objects_list : unit -> string list

(** 获取平声字符列表（兼容旧接口）
    @return 平声字符字符串列表 *)
val get_ping_sheng_list : unit -> string list

(** 获取上声字符列表（兼容旧接口）
    @return 上声字符字符串列表 *)
val get_shang_sheng_list : unit -> string list

(** 获取去声字符列表（兼容旧接口）
    @return 去声字符字符串列表 *)
val get_qu_sheng_list : unit -> string list

(** 获取入声字符列表（兼容旧接口）
    @return 入声字符字符串列表 *)
val get_ru_sheng_list : unit -> string list

(** 统一数据加载接口 *)

(** 所有诗词数据的统一类型 *)
type all_poetry_data = {
  nature_nouns : string list;
  classifiers : string list;
  tools_objects : string list;
  ping_sheng : string list;
  shang_sheng : string list;
  qu_sheng : string list;
  ru_sheng : string list;
}

(** 加载所有诗词数据的统一接口
    @return 包含所有数据的结构 *)
val load_all_data : unit -> all_poetry_data