(** 安韵组数据模块接口 - 骆言诗词编程特性
    
    安韵和谐，山间闲函，音韵流转如春山青翠。
    此模块接口定义安韵组数据访问方法。
    
    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-18
*)

(** 韵律分类类型定义 *)
type rhyme_category =
  | PingSheng (* 平声韵 *)
  | ZeSheng (* 仄声韵 *)
  | ShangSheng (* 上声韵 *)
  | QuSheng (* 去声韵 *)
  | RuSheng (* 入声韵 *)

type rhyme_group =
  | AnRhyme (* 安韵组 *)
  | SiRhyme (* 思韵组 *)
  | TianRhyme (* 天韵组 *)
  | WangRhyme (* 望韵组 *)
  | QuRhyme (* 去韵组 *)
  | UnknownRhyme (* 未知韵组 *)

(** {1 安韵组数据接口} *)

(** 安韵组平声数据 - 所有安韵平声字符的完整列表 *)
val an_yun_ping_sheng : (string * rhyme_category * rhyme_group) list

(** {2 统计信息} *)

(** 安韵组字符总数 *)
val an_yun_char_count : int

(** 安韵组音韵类型 *)  
val an_yun_rhyme_type : rhyme_group

(** {2 数据访问方法} *)

(** 获取安韵组所有字符 *)
val get_all_chars : unit -> (string * rhyme_category * rhyme_group) list

(** 检查字符是否属于安韵组 *)
val is_an_yun_char : string -> bool

(** 获取安韵组字符列表（仅字符） *)
val get_char_list : unit -> string list