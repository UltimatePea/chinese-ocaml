(** 骆言诗词统一数据加载模块接口 - Poetry Module Integration Optimization
 *
 * 此模块整合了原有的poetry_data_loader.ml和artistic_data_loader.ml模块，
 * 消除代码重复，提供统一的数据加载接口。
 *
 * Author: Alpha, 主要工作代理 - Poetry模块整合优化 Issue #1707
 * @version 1.0 - 统一版本
 * @since 2025-07-29
 *)

(** {1 文件读取辅助函数} *)

(** 安全的文件读取函数
    @param filepath 文件路径
    @return 文件内容的Option类型，读取失败返回None *)
val read_file_safely : string -> string option

(** {1 JSON解析辅助函数} *)

(** 在JSON内容中查找指定类别的words数组
    @param content JSON文件内容字符串
    @param category_name 类别名称
    @return 找到的JSON数组字符串的Option类型 *)
val find_json_section : string -> string -> string option

(** 从JSON内容中安全提取指定类别的词汇
    @param content JSON文件内容字符串
    @param category_name 类别名称
    @return 词汇字符串列表 *)
val extract_words_from_category : string -> string -> string list

(** 支持的词汇数据类别列表 *)
val supported_categories : string list

(** {1 主要加载函数} *)

(** 从JSON文件加载词汇数组 - 统一版本
    @param filepath JSON文件路径
    @return 所有类别词汇的合并数组，失败时返回空数组 *)
val load_words_from_json_file : string -> string list

(** {1 预定义词汇数据} *)

(** 默认意象关键词 - 当外部数据文件不可用时的后备数据 *)
val default_imagery_keywords : string list

(** 默认雅致词汇 - 当外部数据文件不可用时的后备数据 *)
val default_elegant_words : string list

(** {1 延迟加载接口} *)

(** 延迟加载的意象关键词库 *)
val imagery_keywords : string list Lazy.t

(** 延迟加载的雅致词汇库 *)
val elegant_words : string list Lazy.t

(** {1 公共访问接口} *)

(** 获取意象关键词列表 *)
val get_imagery_keywords : unit -> string list

(** 获取雅致词汇列表 *)
val get_elegant_words : unit -> string list

(** 检查是否为意象关键词 *)
val is_imagery_keyword : string -> bool

(** 检查是否为雅致词汇 *)
val is_elegant_word : string -> bool

(** {1 向后兼容性接口} *)

(** Poetry_data_loader兼容接口 *)
module Poetry_data_loader_compat : sig
  val read_file_safely : string -> string option
  val find_json_section : string -> string -> string option
  val extract_words_from_category : string -> string -> string list
  val load_words_from_json_file : string -> string list
  val imagery_keywords : string list Lazy.t
  val elegant_words : string list Lazy.t
end

(** Artistic_data_loader兼容接口 *)
module Artistic_data_loader_compat : sig
  val read_file_safely : string -> string option
  val find_json_section : string -> string -> string option
  val extract_words_from_category : string -> string -> string list
  val load_words_from_json_file : string -> string list
  val default_imagery_keywords : string list
  val default_elegant_words : string list
  val imagery_keywords : string list Lazy.t
  val elegant_words : string list Lazy.t
  val get_imagery_keywords : unit -> string list
  val get_elegant_words : unit -> string list
end