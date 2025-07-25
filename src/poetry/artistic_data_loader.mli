(** 骆言诗词艺术性评价数据加载模块接口 *)

(** {1 文件读取函数} *)

val read_file_safely : string -> string option
(** 安全的文件读取函数
    @param filepath 文件路径
    @return 文件内容的Option类型，读取失败返回None *)

(** {1 JSON解析函数} *)

val find_json_section : string -> string -> string option
(** 在JSON内容中查找指定类别的words数组
    @param content JSON文件内容字符串
    @param category_name 类别名称
    @return 找到的JSON数组字符串的Option类型 *)

val extract_words_from_category : string -> string -> string list
(** 从JSON内容中安全提取指定类别的词汇
    @param content JSON文件内容字符串
    @param category_name 类别名称
    @return 词汇字符串列表 *)

val supported_categories : string list
(** 支持的词汇数据类别列表 *)

(** {1 主要加载函数} *)

val load_words_from_json_file : string -> string list
(** 从JSON文件加载词汇数组
    @param filepath JSON文件路径
    @return 所有类别词汇的合并数组，失败时返回空数组 *)

(** {1 预定义词汇数据} *)

val default_imagery_keywords : string list
(** 默认意象关键词 - 当外部数据文件不可用时的后备数据 *)

val default_elegant_words : string list
(** 默认雅致词汇 - 当外部数据文件不可用时的后备数据 *)

(** {1 访问接口} *)

val get_imagery_keywords : unit -> string list
(** 获取意象关键词列表 *)

val get_elegant_words : unit -> string list
(** 获取雅致词汇列表 *)
