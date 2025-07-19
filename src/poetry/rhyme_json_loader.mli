(** 韵律JSON数据加载器接口
    
    此模块负责从外部JSON文件加载韵律数据，提供缓存和降级机制。
    
    @author 骆言诗词编程团队 
    @version 1.0
    @since 2025-07-19 *)

(** 韵类定义 *)
type rhyme_category =
  | PingSheng
  | ZeSheng  
  | ShangSheng
  | QuSheng
  | RuSheng

(** 韵组定义 *)
type rhyme_group =
  | AnRhyme
  | SiRhyme
  | TianRhyme
  | WangRhyme
  | QuRhyme
  | YuRhyme
  | HuaRhyme
  | FengRhyme
  | YueRhyme
  | XueRhyme
  | JiangRhyme
  | HuiRhyme
  | UnknownRhyme

(** {1 异常定义} *)

exception Json_parse_error of string
(** JSON解析错误异常 *)

exception Rhyme_data_not_found of string
(** 韵律数据未找到异常 *)

(** {1 数据类型} *)

type rhyme_group_data = {
  category: string;
  characters: string list;
}
(** 韵组数据类型 *)

type rhyme_data_file = {
  rhyme_groups: (string * rhyme_group_data) list;
  metadata: (string * string) list;
}
(** 韵律数据文件类型 *)

(** {1 数据加载接口} *)

val get_rhyme_data : ?force_reload:bool -> unit -> rhyme_data_file option
(** 获取韵律数据，支持强制重载
    @param force_reload 是否强制重新加载数据
    @return 韵律数据，失败时返回None *)

val get_all_rhyme_groups : unit -> (string * rhyme_group_data) list
(** 获取所有韵组数据 *)

val get_rhyme_group_characters : string -> string list
(** 获取指定韵组的字符列表
    @param group_name 韵组名称
    @return 字符列表 *)

val get_rhyme_group_category : string -> rhyme_category
(** 获取指定韵组的韵类
    @param group_name 韵组名称  
    @return 韵类 *)

(** {1 向后兼容接口} *)

val get_rhyme_mappings : unit -> (string * (rhyme_category * rhyme_group)) list
(** 获取韵律映射表，格式为 (字符 -> (韵类, 韵组))
    @return 韵律映射列表 *)

(** {1 统计和调试} *)

val get_data_statistics : unit -> (int * int) option
(** 获取数据统计信息
    @return (韵组数量, 字符数量) 或 None *)

val print_statistics : unit -> unit
(** 打印韵律数据统计信息 *)

(** {1 降级机制} *)

val use_fallback_data : unit -> unit
(** 使用降级数据 - 当JSON文件无法读取时的备选方案 *)