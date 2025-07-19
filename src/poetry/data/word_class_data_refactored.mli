(** 重构后的词性数据模块接口 - 演示数据外化重构
    
    展示如何通过数据加载器从外部JSON文件加载数据，
    实现数据与代码的分离，提高可维护性。
    
    @author 骆言技术债务清理团队 - Phase 10
    @version 1.0
    @since 2025-07-19 
    @updated 2025-07-19 Phase 12: 使用统一词性类型定义 *)

(** 使用统一的词性类型定义，消除重复 *)
open Word_class_types

(** {1 类型转换函数} *)

(** 将字符串转换为词性类型 *)
val string_to_word_class : string -> word_class

(* word_class_to_string 现在在 Word_class_types 模块中提供 *)

(** {1 重构后的数据接口} *)

(** 人物关系名词数据 - 从外部JSON文件加载
    
    这是原 person_relation_nouns 的重构版本，
    数据从 data/poetry/person_relation_nouns.json 加载 *)
val person_relation_nouns : (string * word_class) list

(** 获取人物关系名词数据 - 函数式接口 *)
val get_person_relation_nouns : unit -> (string * word_class) list

(** {1 延迟加载数据模块} *)

(** 延迟加载的数据集合 *)
module LazyData : sig
  (** 获取人物关系名词数据 - 延迟加载 *)
  val get_person_relations : unit -> (string * word_class) list
end

(** {1 工具函数} *)

(** 检查字符是否在指定数据列表中 *)
val is_in_database : string -> (string * word_class) list -> bool

(** 在指定数据列表中查找字符的词性 *)
val find_word_class_in_data : string -> (string * word_class) list -> word_class option

(** 从指定数据列表中按词性获取字符列表 *)
val get_chars_by_class_from_data : word_class -> (string * word_class) list -> string list

(** {1 统计和分析功能} *)

(** 获取数据集的统计信息
    
    @param data_list 词性数据列表
    @return (总字符数, 词性分布列表) *)
val get_data_stats : (string * word_class) list -> int * (string * int) list

(** 打印数据集统计信息 *)
val print_data_stats : string -> (string * word_class) list -> unit

(** {1 重构演示功能} *)

(** 演示数据外化重构的优势和效果 *)
val demonstrate_refactoring_benefits : unit -> unit

(** 检查重构后的向后兼容性 *)
val check_backward_compatibility : unit -> unit