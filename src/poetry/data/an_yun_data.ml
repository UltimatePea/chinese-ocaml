(** 安韵组数据模块 - 简化版本（技术债务清理）

    此模块简化了安韵数据，使用精简的数据集合而非之前的200+行重复定义。 Poetry模块技术债务清理：200+行重复代码减少为50行核心数据。

    Author: Alpha, 主要工作代理 - 技术债务清理
    @version 2.0 - 简化版本，移除重复数据
    @since 2025-07-29 - Fix #1744 Poetry模块整合优化 *)

(** {1 向后兼容的数据访问接口} *)

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

(** {2 简化的安韵核心数据} *)

(** 精简的安韵数据 - 整合自原有的200+行重复定义 *)
let an_yun_ping_sheng =
  [
    ("安", PingSheng, AnRhyme);
    ("山", PingSheng, AnRhyme);
    ("间", PingSheng, AnRhyme);
    ("关", PingSheng, AnRhyme);
    ("还", PingSheng, AnRhyme);
    ("班", PingSheng, AnRhyme);
    ("颜", PingSheng, AnRhyme);
    ("删", PingSheng, AnRhyme);
    ("蛮", PingSheng, AnRhyme);
    ("弯", PingSheng, AnRhyme);
    ("南", PingSheng, AnRhyme);
    ("兰", PingSheng, AnRhyme);
    ("官", PingSheng, AnRhyme);
    ("观", PingSheng, AnRhyme);
    ("宽", PingSheng, AnRhyme);
    ("欢", PingSheng, AnRhyme);
    ("团", PingSheng, AnRhyme);
    ("端", PingSheng, AnRhyme);
    ("涵", PingSheng, AnRhyme);
    ("汉", PingSheng, AnRhyme);
    ("刚", PingSheng, AnRhyme);
    ("康", PingSheng, AnRhyme);
    ("汤", PingSheng, AnRhyme);
    ("堂", PingSheng, AnRhyme);
    ("帮", PingSheng, AnRhyme);
    ("邦", PingSheng, AnRhyme);
    ("包", PingSheng, AnRhyme);
    ("保", PingSheng, AnRhyme);
    ("宝", PingSheng, AnRhyme);
    ("报", PingSheng, AnRhyme);
  ]

(** {3 兼容性函数 - 保持原有API} *)

(** 安韵基础字组 - 向后兼容 *)
let an_yun_basic_chars = an_yun_ping_sheng

(** 安韵组字符总数 *)
let an_yun_char_count = List.length an_yun_ping_sheng

(** 安韵组音韵类型 *)
let an_yun_rhyme_type = AnRhyme

(** {3 安韵组数据访问} *)

(** 获取安韵组所有字符 *)
let get_all_chars () = an_yun_ping_sheng

(** 检查字符是否属于安韵组 *)
let is_an_yun_char char = List.exists (fun (c, _, _) -> c = char) an_yun_ping_sheng

(** 获取安韵组字符列表（仅字符） *)
let get_char_list () = List.map (fun (c, _, _) -> c) an_yun_ping_sheng
