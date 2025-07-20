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