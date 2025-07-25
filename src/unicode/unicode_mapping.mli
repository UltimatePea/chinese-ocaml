(** Unicode字符映射和查找功能接口

    本模块提供Unicode字符映射表管理和字符查找功能， 支持按名称、字符和类别进行查找操作。

    主要功能：
    - 字符映射表管理
    - 字符名称与字符的双向映射
    - 字符与UTF-8三元组的映射
    - 按类别过滤和查找字符
    - 向后兼容性支持 *)

(** 字符映射表管理模块 - 性能优化版 *)
module CharMap : sig
  (** {2 向后兼容接口} *)

  val name_to_char_map : (string * string) list
  (** 字符名称到字符的映射表 格式：[(名称, 字符); ...]
      @deprecated 建议使用 find_char_by_name 函数以获得更好的性能 *)

  val name_to_triple_map : (string * Unicode_types.utf8_triple) list
  (** 字符名称到UTF-8三元组的映射表 格式：[(名称, 三元组); ...]
      @deprecated 建议使用 find_triple_by_name 函数以获得更好的性能 *)

  val char_to_triple_map : (string * Unicode_types.utf8_triple) list
  (** 字符到UTF-8三元组的映射表 格式：[(字符, 三元组); ...]
      @deprecated 建议使用 find_triple_by_char 函数以获得更好的性能 *)

  (** {2 高性能查找接口} *)

  val find_char_by_name : string -> string option
  (** [find_char_by_name name] 高性能字符名称查找 (O(1) 哈希表查找)
      @param name 字符名称
      @return 对应的Unicode字符，找不到时返回None *)

  val find_triple_by_name : string -> Unicode_types.utf8_triple option
  (** [find_triple_by_name name] 高性能字符名称到三元组查找 (O(1) 哈希表查找)
      @param name 字符名称
      @return 对应的UTF-8三元组，找不到时返回None *)

  val find_triple_by_char : string -> Unicode_types.utf8_triple option
  (** [find_triple_by_char char_str] 高性能字符到三元组查找 (O(1) 哈希表查找)
      @param char_str Unicode字符
      @return 对应的UTF-8三元组，找不到时返回None *)
end

(** Legacy兼容性查找模块 *)
module Legacy : sig
  (** {2 类别过滤功能} *)

  val filter_by_category : string -> Unicode_types.utf8_char_def list
  (** [filter_by_category category] 过滤指定类别的字符定义
      @param category 字符类别（如 "quote", "string", "punctuation", "number"）
      @return 匹配该类别的字符定义列表 *)

  val get_chars_by_category : string -> string list
  (** [get_chars_by_category category] 获取指定类别的字符列表
      @param category 字符类别
      @return 该类别下的所有字符 *)

  val get_names_by_category : string -> string list
  (** [get_names_by_category category] 获取指定类别的字符名称列表
      @param category 字符类别
      @return 该类别下的所有字符名称 *)

  (** {2 查找功能} *)

  val find_triple_by_char : string -> Unicode_types.utf8_triple option
  (** [find_triple_by_char char_str] 查找字符对应的UTF-8三元组
      @param char_str Unicode字符
      @return 对应的UTF-8三元组，找不到时返回None *)

  val find_char_by_name : string -> string option
  (** [find_char_by_name name] 查找名称对应的字符
      @param name 字符名称
      @return 对应的Unicode字符，找不到时返回None *)

  (** {2 向后兼容功能} *)

  val get_char_bytes : string -> int * int * int
  (** [get_char_bytes char_name] 获取字符的字节组合
      @param char_name 字符名称
      @return 字节三元组 (byte1, byte2, byte3)，失败时返回 (0, 0, 0) *)

  val is_char_category : string -> string -> bool
  (** [is_char_category char_str category] 检查字符是否属于指定类别 (带缓存优化)
      @param char_str Unicode字符
      @param category 字符类别
      @return 如果字符属于指定类别则返回true，否则返回false *)
end

(** 性能优化版本的高级查找模块 *)
module Optimized : sig
  type mapping_stats = {
    total_definitions : int;  (** 总字符定义数量 *)
    hash_table_size : int;  (** 哈希表大小 *)
    cache_size : int;  (** 缓存当前使用量 *)
  }

  val batch_find_chars_by_names : string list -> (string * string) list
  (** [batch_find_chars_by_names names] 批量字符查找，利用哈希表的高效性
      @param names 字符名称列表
      @return 成功找到的(名称, 字符)对列表 *)

  val get_mapping_stats : unit -> mapping_stats
  (** [get_mapping_stats ()] 获取字符映射统计信息，用于性能分析
      @return 映射统计信息记录 *)
end

(** 性能监控和调试模块 *)
module Performance : sig
  type perf_stats = {
    total_queries : int;  (** 总查询次数 *)
    cache_hit_rate : float;  (** 缓存命中率 *)
    cache_hits : int;  (** 缓存命中次数 *)
    cache_misses : int;  (** 缓存未命中次数 *)
  }

  val increment_query : unit -> unit
  (** [increment_query ()] 增加查询计数器 *)

  val increment_cache_hit : unit -> unit
  (** [increment_cache_hit ()] 增加缓存命中计数器 *)

  val increment_cache_miss : unit -> unit
  (** [increment_cache_miss ()] 增加缓存未命中计数器 *)

  val get_stats : unit -> perf_stats
  (** [get_stats ()] 获取性能统计信息
      @return 性能统计信息记录 *)

  val reset_stats : unit -> unit
  (** [reset_stats ()] 重置所有性能统计计数器 *)
end
