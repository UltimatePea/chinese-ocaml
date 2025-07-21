(** 外化数据加载器接口 - 重构版本（改进版）

    本模块是外化数据加载器的改进重构版本， 作为协调器，使用已经模块化的组件来提供统一的数据访问接口。 重构目标：减少代码重复，使用现有的模块化结构。

    @author 骆言技术债务清理团队
    @version 2.0 - 重构版本（改进版）
    @since 2025-07-20 *)

(** 外化数据错误类型 *)
type externalized_data_error =
  | FileNotFound of string
  | ParseError of string * string
  | ValidationError of string

exception ExternalizedDataError of externalized_data_error
(** 外化数据异常 *)

val format_error : externalized_data_error -> string
(** 格式化错误信息
    @param error 错误类型
    @return 格式化的错误消息字符串 *)

val get_nature_nouns_refactored : unit -> string list
(** 获取改进的基础自然名词列表 提供降级机制，当模块化系统加载失败时使用默认数据
    @return 自然名词字符串列表 *)

val get_geography_politics_nouns_refactored : unit -> string list
(** 获取改进的地理政治名词列表
    @return 地理政治名词字符串列表 *)

val get_person_relation_nouns_refactored : unit -> string list
(** 获取改进的人物关系名词列表
    @return 人物关系名词字符串列表 *)

val get_social_status_nouns_refactored : unit -> string list
(** 获取改进的社会地位名词列表
    @return 社会地位名词字符串列表 *)

val get_tools_objects_nouns_refactored : unit -> string list
(** 获取改进的工具物品名词列表
    @return 工具物品名词字符串列表 *)

val get_building_place_nouns_refactored : unit -> string list
(** 获取改进的建筑场所名词列表
    @return 建筑场所名词字符串列表 *)

val validate_data_integrity_refactored : unit -> bool
(** 验证改进后的数据完整性 检查所有数据模块是否正确加载（改进版本）
    @return 验证结果，成功时返回true *)

type loading_statistics = {
  loaded_modules : int;
  failed_modules : int;
  total_entries : int;
  load_time_ms : float;
}
(** 获取数据加载统计信息 提供加载性能和状态的统计
    @return 统计信息记录 *)

val get_loading_statistics : unit -> loading_statistics
