(** 骆言编译器Unicode字符处理常量模块 - 性能优化版本接口
    
    本模块在统一版本基础上增加了性能优化：
    - 使用哈希表进行O(1)字符查找
    - 缓存JSON数据加载
    - 优化字符检查函数
    
    @version 1.1 - Phase 2: 性能优化（哈希表查找）
    @since 2025-07-25
*)

(** 包含统一版本的所有功能 *)
include module type of Unicode_constants_unified

(** 性能优化模块 - 使用哈希表提升查找效率 *)
module OptimizedLookup : sig
  (** O(1)查找：根据字符名称查找字符 *)
  val find_char_by_name_fast : string -> string option
  
  (** O(1)查找：根据字符查找字节三元组 *)
  val find_bytes_by_char_fast : string -> byte_triple option
  
  (** O(1)查找：根据字符名称查找字节三元组 *)
  val find_bytes_by_name_fast : string -> byte_triple option
  
  (** O(1)查找：根据类别查找字符定义列表 *)
  val find_definitions_by_category_fast : string -> char_definition list option
  
  (** 获取所有已知字符名称 *)
  val get_all_char_names : unit -> string list
  
  (** 获取所有已知字符 *)
  val get_all_chars : unit -> string list
  
  (** 获取所有类别 *)
  val get_all_categories : unit -> string list
end

(** 缓存数据加载模块 *)
module CachedData : sig
  (** 获取缓存的字符定义 *)
  val get_char_definitions : unit -> char_definition list
  
  (** 预热缓存 - 强制初始化所有懒惰值 *)
  val warm_cache : unit -> unit
end

(** 快速字符检查函数 *)
module FastChecks : sig
  (** 快速检查是否可能是中文标点符号（基于第一个字节） *)
  val is_likely_chinese_punctuation : int -> bool
  
  (** 快速检查字节三元组是否为已知的中文字符 *)
  val is_known_chinese_char_bytes : byte_triple -> bool
  
  (** 快速检查字符串是否为已知的中文字符 *)
  val is_known_chinese_char : string -> bool
  
  (** 快速批量检查字符列表 *)
  val check_char_list : string list -> (string * bool) list
end

(** 统计和分析模块 *)
module Statistics : sig
  (** 获取字符定义统计信息 *)
  val get_char_statistics : unit -> (int * (string, int) Hashtbl.t)
  
  (** 打印统计信息 *)
  val print_statistics : unit -> unit
  
  (** 获取查找表性能信息 *)
  val get_lookup_performance_info : unit -> (int * int * int * int)
end

(** 高级API模块 - 提供更便捷的接口 *)
module AdvancedAPI : sig
  
  type exported_char_info = {
    name: string;
    char: string; 
    bytes: byte_triple;
    category: string;
    bytes_hex: string;
  }
  
  (** 智能字符查找结果类型 *)
  type smart_find_result = 
    [ `FoundByName of string * byte_triple option
    | `FoundByChar of string * byte_triple option ]
  
  (** 智能字符查找 - 自动判断输入类型 *)
  val smart_find : string -> smart_find_result option
  
  (** 批量字符查找 *)
  val batch_find : string list -> (string * smart_find_result option) list
  
  (** 按类别获取所有字符信息 *)
  val get_category_info : string -> (string list * string list * int) option
  
  (** 导出完整的字符映射表 *)
  val export_char_mapping : unit -> (string, exported_char_info) Hashtbl.t
end

(** 向后兼容的优化接口 *)
module OptimizedLegacyAPI : sig
  (** 替代原来的get_char_bytes_by_name，使用哈希表优化 *)
  val get_char_bytes_by_name : string -> byte_triple
  
  (** 替代原来的get_char_bytes_by_char，使用哈希表优化 *)
  val get_char_bytes_by_char : string -> byte_triple
  
  (** 优化版的字符定义查找 *)
  val find_definition_by_char : string -> char_definition option
  
  (** 优化版的字符定义查找 *)
  val find_definition_by_name : string -> char_definition option
end