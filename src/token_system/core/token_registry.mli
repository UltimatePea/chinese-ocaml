(** 骆言编译器 - 统一Token注册表接口
    
    提供Token注册、查找、管理的核心功能。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Token_types

(** {1 注册表类型定义} *)

(** Token注册表统计信息 *)
type registry_stats = {
  total_tokens : int;        (** 总Token数量 *)
  literal_tokens : int;      (** 字面量Token数量 *)
  keyword_tokens : int;      (** 关键字Token数量 *)
  operator_tokens : int;     (** 操作符Token数量 *)
  delimiter_tokens : int;    (** 分隔符Token数量 *)
}

(** Token查找结果 *)
type lookup_result =
  | Found of token           (** 找到唯一Token *)
  | NotFound                 (** 未找到 *)
  | Ambiguous of token list  (** 找到多个匹配的Token *)

(** {1 注册表管理} *)

(** 注册Token到注册表
    @param token 要注册的token
    @param chinese_text 对应的中文文本
    @param aliases 别名列表 *)
val register_token : token -> string -> string list -> unit

(** 批量注册Token
    @param token_list (token, 中文文本, 别名列表) 的列表 *)
val register_tokens : (token * string * string list) list -> unit

(** 初始化默认Token注册
    注册编译器核心的基础Token集合 *)
val initialize_default_tokens : unit -> unit

(** {1 Token查找} *)

(** 根据中文文本查找Token
    @param text 中文文本或别名
    @return 查找结果 *)
val lookup_token_by_text : string -> lookup_result

(** 根据Token获取对应的中文文本
    @param token 要查找的token
    @return 对应的中文文本，如果未注册则返回None *)
val get_token_text : token -> string option

(** {1 注册表查询} *)

(** 检查Token是否已注册
    @param token 要检查的token
    @return 如果已注册返回true，否则返回false *)
val is_registered : token -> bool

(** 获取所有已注册的Token
    @return 所有已注册的token列表 *)
val get_all_tokens : unit -> token list

(** 根据类别获取Token列表
    @param category Token类别
    @return 该类别下的所有token *)
val get_tokens_by_category : token_category -> token list

(** 获取注册表统计信息
    @return 当前注册表的统计信息 *)
val get_stats : unit -> registry_stats

(** {1 注册表维护} *)

(** 清空注册表
    清除所有已注册的Token，通常用于测试或重新初始化 *)
val clear_registry : unit -> unit