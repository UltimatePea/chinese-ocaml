(** 韵律数据JSON加载器接口 - 骆言诗词编程特性技术债务重构

    此模块提供统一的JSON韵律数据加载接口，替代硬编码数据结构。 支持缓存、错误处理和向后兼容的API。

    @author 骆言诗词编程团队
    @version 2.0
    @since 2025-07-20 - 技术债务重构 Fix #724 *)

(** {1 韵律类型定义} *)

(** 韵律类别 *)
type rhyme_category =
  | PingSheng  (** 平声韵 *)
  | ZeSheng  (** 仄声韵 *)
  | ShangSheng  (** 上声韵 *)
  | QuSheng  (** 去声韵 *)
  | RuSheng  (** 入声韵 *)

(** 韵律组别 *)
type rhyme_group =
  | AnRhyme  (** 安韵组 *)
  | SiRhyme  (** 思韵组 *)
  | TianRhyme  (** 天韵组 *)
  | WangRhyme  (** 望韵组 *)
  | QuRhyme  (** 去韵组 *)
  | YuRhyme  (** 鱼韵组 *)
  | HuaRhyme  (** 花韵组 *)
  | FengRhyme  (** 风韵组 *)
  | YueRhyme  (** 月韵组 *)
  | XueRhyme  (** 雪韵组 *)
  | JiangRhyme  (** 江韵组 *)
  | HuiRhyme  (** 灰韵组 *)
  | UnknownRhyme  (** 未知韵组 *)

type rhyme_char_data = {
  char : string;  (** 字符 *)
  category : rhyme_category;  (** 韵律类别 *)
  group : rhyme_group;  (** 韵律组别 *)
}
(** 字符韵律数据 *)

type rhyme_series = {
  name : string;  (** 系列名称 *)
  description : string;  (** 系列描述 *)
  characters : rhyme_char_data list;  (** 字符列表 *)
}
(** 韵律数据系列 *)

type rhyme_metadata = {
  name : string;  (** 数据名称 *)
  description : string;  (** 数据描述 *)
  author : string;  (** 作者 *)
  version : string;  (** 版本 *)
  total_characters : int;  (** 字符总数 *)
  rhyme_category : rhyme_category;  (** 主要韵律类别 *)
  rhyme_group : rhyme_group;  (** 主要韵律组别 *)
}
(** 韵律数据元信息 *)

type rhyme_data = {
  metadata : rhyme_metadata;  (** 元信息 *)
  series : rhyme_series list;  (** 数据系列列表 *)
  all_characters : rhyme_char_data list;  (** 所有字符数据 *)
}
(** 完整韵律数据 *)

(** {1 数据加载接口} *)

val load_rhyme_data_from_json :
  string -> (rhyme_data, Yyocamlc_lib.Unified_errors.unified_error) result
(** 从JSON文件加载韵律数据
    @param file_path JSON文件路径
    @return 解析后的韵律数据，或错误信息 *)

(** {1 兼容性接口} *)

val get_hui_rhyme_data :
  unit -> (rhyme_char_data list, Yyocamlc_lib.Unified_errors.unified_error) result
(** 获取灰韵组数据 - 向后兼容接口
    @return 灰韵组所有字符数据列表，或错误信息 *)

val get_hui_rhyme_count : unit -> (int, Yyocamlc_lib.Unified_errors.unified_error) result
(** 获取灰韵组字符数量 - 向后兼容接口
    @return 字符总数，或错误信息 *)

val is_hui_rhyme_char : string -> (bool, Yyocamlc_lib.Unified_errors.unified_error) result
(** 检查字符是否属于灰韵组 - 向后兼容接口
    @param char 要检查的字符
    @return 如果字符属于灰韵组则返回true，或错误信息 *)

val get_hui_rhyme_chars : unit -> (string list, Yyocamlc_lib.Unified_errors.unified_error) result
(** 获取所有灰韵组字符列表 - 向后兼容接口
    @return 字符字符串列表，或错误信息 *)

(** {1 缓存管理} *)

val reset_cache : unit -> unit
(** 重置数据缓存 - 用于测试和重新加载 *)

(** {1 调试和统计} *)

val get_statistics : unit -> string
(** 获取数据统计信息
    @return 统计信息字符串 *)
