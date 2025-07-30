(** 安韵组数据模块接口 - 简化版本（技术债务清理）

    此模块接口定义简化的安韵组数据访问方法，保持向后兼容性。

    Author: Alpha, 主要工作代理 - 技术债务清理
    @version 2.0 - 简化版本，移除重复数据
    @since 2025-07-29 - Fix #1744 Poetry模块整合优化 *)

(** 重新导出类型定义以保持100%兼容性 *)
type rhyme_category = Poetry_core.Poetry_types.rhyme_category =
  | PingSheng
  | ZeSheng
  | ShangSheng
  | QuSheng
  | RuSheng

type rhyme_group = Poetry_core.Poetry_types.rhyme_group =
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

(** {1 安韵组数据接口} *)

val an_yun_ping_sheng : (string * rhyme_category * rhyme_group) list
(** 安韵组平声数据 - 所有安韵平声字符的完整列表 *)

val an_yun_basic_chars : (string * rhyme_category * rhyme_group) list
(** 安韵基础字组 - 向后兼容 *)

(** {2 统计信息} *)

val an_yun_char_count : int
(** 安韵组字符总数 *)

val an_yun_rhyme_type : rhyme_group
(** 安韵组音韵类型 *)

(** {2 数据访问方法} *)

val get_all_chars : unit -> (string * rhyme_category * rhyme_group) list
(** 获取安韵组所有字符 *)

val is_an_yun_char : string -> bool
(** 检查字符是否属于安韵组 *)

val get_char_list : unit -> string list
(** 获取安韵组字符列表（仅字符） *)
