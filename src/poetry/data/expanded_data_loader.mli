(** 扩展诗词数据加载器接口 - 重构为统一加载器兼容层

    此模块现在作为Unified_data_loader的兼容层，保持原有API不变，
    但内部使用统一的数据加载核心。

    @author Alpha, 技术债务清理专员 - Poetry模块整合Phase 1
    @version 3.0 - 统一加载器兼容层接口
    @since 2025-07-29
    @fix_issue #1729 *)

(** {1 兼容性类型定义} *)

(** 数据加载错误类型 - 保持向后兼容 *)
type data_load_error =
  | FileNotFound of string
  | ParseError of string * string
  | ValidationError of string

exception DataLoadError of data_load_error

(** 格式化错误信息 *)
val format_error : data_load_error -> string

(** {1 兼容性加载函数} *)

(** 将文件读取异常转换为数据加载异常 *)
val convert_file_error : (unit -> 'a) -> 'a

(** 安全加载名词数据 - 返回字符串列表元组 *)
val safe_load_nouns :
  unit ->
  string list * string list * string list * string list * string list *
  string list * string list * string list * string list * string list

(** 安全加载动词数据 *)
val safe_load_verbs :
  unit ->
  string list * string list * string list * string list * string list *
  string list * string list * string list * string list * string list * string list

(** 安全加载形容词数据 *)
val safe_load_adjectives :
  unit ->
  string list * string list * string list * string list * string list *
  string list * string list * string list * string list * string list *
  string list * string list

(** 安全加载副词数据 *)
val safe_load_adverbs :
  unit -> string list * string list * string list

(** 安全加载数词量词数据 *)
val safe_load_numerals_classifiers :
  unit -> string list * string list * string list

(** 安全加载功能词数据 *)
val safe_load_function_words :
  unit -> string list * string list * string list * string list * string list

(** {1 新增高级接口} *)

(** 批量加载所有词类数据 *)
val load_all_word_classes : unit -> Yojson.Safe.t option

(** 获取缓存状态信息 *)
val get_cache_info : unit -> string

(** 清理所有缓存 *)
val clear_all_cache : unit -> unit

(** 预热常用数据缓存 *)
val warm_common_cache : unit -> unit

(** {1 向后兼容性模块} *)

module Compatibility : sig
  val load_nouns : unit -> string list * string list * string list * string list * string list * string list * string list * string list * string list * string list
  val load_verbs : unit -> string list * string list * string list * string list * string list * string list * string list * string list * string list * string list * string list
  val load_adjectives : unit -> string list * string list * string list * string list * string list * string list * string list * string list * string list * string list * string list * string list
  val load_adverbs : unit -> string list * string list * string list
  val load_numerals_classifiers : unit -> string list * string list * string list
  val load_function_words : unit -> string list * string list * string list * string list * string list
end