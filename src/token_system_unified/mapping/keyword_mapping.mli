(** 骆言Token系统整合重构 - 关键字映射管理接口 *)

open Yyocamlc_lib.Token_types

(** 关键字映射模块 *)
module KeywordMapping : sig
  val lookup_chinese_keyword : string -> keyword_type option
  (** 查找中文关键字 *)

  val lookup_english_keyword : string -> keyword_type option
  (** 查找英文关键字 *)

  val lookup_keyword : string -> keyword_type option
  (** 通用关键字查找 *)

  val keyword_to_chinese : keyword_type -> string option
  (** 关键字转换为中文 *)

  val keyword_to_english : keyword_type -> string option
  (** 关键字转换为英文 *)

  val is_keyword : string -> bool
  (** 检查是否为关键字 *)

  val get_all_chinese_keywords : unit -> string list
  (** 获取所有中文关键字 *)

  val get_all_english_keywords : unit -> string list
  (** 获取所有英文关键字 *)

  val get_all_keywords : unit -> string list
  (** 获取所有关键字 *)

  val get_keywords_by_category : string -> string list
  (** 按类别获取关键字 *)

  val get_keyword_stats : unit -> string
  (** 关键字统计信息 *)
end

(** 关键字映射工厂 *)
module KeywordMappingFactory : sig
  type mapping_config = {
    include_chinese : bool;
    include_english : bool;
    case_sensitive : bool;
    custom_mappings : (string * keyword_type) list;
  }

  val default_config : mapping_config

  val create_mapping : mapping_config -> (string, keyword_type) Hashtbl.t
  (** 根据配置创建映射表 *)

  val create_lookup_function : mapping_config -> string -> keyword_type option
  (** 创建查找函数 *)
end
