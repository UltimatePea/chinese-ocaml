(** 数据加载器模块接口 - 骆言项目 Phase 10 技术债务清理
    
    提供从外部数据文件加载配置数据的统一接口。
    支持缓存、错误处理和数据验证功能。
    
    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-19 *)

(** 数据加载器的错误类型 *)
type data_error =
  | FileNotFound of string  (** 文件未找到 *)
  | ParseError of string * string  (** 解析错误: 文件名 * 错误信息 *)
  | ValidationError of string * string  (** 验证错误: 数据类型 * 错误详情 *)

(** 数据加载结果 *)
type 'a data_result = 
  | Success of 'a
  | Error of data_error

(** {1 数据加载接口} *)

(** 加载字符串列表数据
    
    @param use_cache 是否使用缓存，默认为true
    @param relative_path 相对于data/目录的文件路径
    @return 加载结果，成功时返回字符串列表 *)
val load_string_list : ?use_cache:bool -> string -> string list data_result

(** 加载词性数据对
    
    @param use_cache 是否使用缓存，默认为true  
    @param relative_path 相对于data/目录的文件路径
    @return 加载结果，成功时返回(词, 词性)对的列表 *)
val load_word_class_pairs : ?use_cache:bool -> string -> (string * string) list data_result

(** 带降级机制的数据加载
    
    如果数据文件加载失败，自动使用提供的默认数据
    
    @param loader 数据加载函数
    @param relative_path 数据文件相对路径
    @param fallback_data 默认数据
    @return 加载的数据或默认数据 *)
val load_with_fallback : (string -> 'a data_result) -> string -> 'a -> 'a

(** {1 数据验证接口} *)

(** 验证字符串列表数据
    
    检查列表中的每个字符串是否为有效的中文字符
    
    @param data 待验证的字符串列表
    @return 验证结果 *)
val validate_string_list : string list -> string list data_result

(** 验证词性数据对
    
    检查词性名称是否为有效的词性类型
    
    @param data 待验证的(词, 词性)对列表
    @return 验证结果 *)
val validate_word_class_pairs : (string * string) list -> (string * string) list data_result

(** {1 错误处理接口} *)

(** 处理错误结果
    
    将data_result转换为直接的值，失败时抛出异常
    
    @param result 数据加载结果
    @return 成功时返回数据，失败时抛出异常 *)
val handle_error : 'a data_result -> 'a

(** {1 缓存管理接口} *)

(** 清空所有缓存数据 *)
val clear_cache : unit -> unit

(** {1 统计信息接口} *)

(** 打印数据加载器的统计信息
    
    包括加载次数、缓存命中率等信息 *)
val print_stats : unit -> unit