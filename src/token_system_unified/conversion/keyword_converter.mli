(** 骆言编译器 - 关键字转换器接口
    
    专门处理各类关键字Token的转换。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Yyocamlc_lib.Token_types
open Token_converter

(** {1 关键字映射类型} *)

type keyword_mapping = {
  chinese_text : string;  (** 中文文本 *)
  english_alias : string option;  (** 英文别名 *)
  token : token;  (** 对应的Token *)
  category : string;  (** 关键字类别 *)
}
(** 关键字映射结构 *)

(** {1 关键字转换器} *)

val keyword_converter : (module CONVERTER)
(** 统一关键字转换器 实现CONVERTER接口的关键字转换器实例 *)

(** {1 查询功能} *)

val get_all_keyword_mappings : unit -> keyword_mapping list
(** 获取所有关键字映射
    @return 所有关键字映射列表 *)

val get_keywords_by_category : string -> token list
(** 根据类别获取关键字Token
    @param category 关键字类别
    @return 该类别下的所有关键字Token *)

val get_supported_categories : unit -> string list
(** 获取所有支持的关键字类别
    @return 所有类别名称列表，按字母顺序排序 *)

val is_keyword_token : token -> bool
(** 检查是否为关键字Token
    @param token 要检查的token
    @return 如果是关键字返回true *)

val get_keyword_stats : unit -> (string * int) list
(** 获取关键字统计信息
    @return (类别名称, 数量) 列表，包含总数 *)
