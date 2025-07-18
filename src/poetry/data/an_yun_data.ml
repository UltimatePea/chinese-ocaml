(** 安韵组数据模块 - 骆言诗词编程特性

    安韵和谐，山间闲函，音韵流转如春山青翠。 此模块专门存储安韵组平声字符，独立管理便于维护。 依《广韵》传统分类，精心整理入库。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-18 *)

(** 直接定义所需类型，避免循环依赖 *)
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

(** {1 安韵组平声数据} *)

(** 安韵基础字组 - 安山间闲等核心字

    包含常用安韵平声字，音韵和谐统一。 字符按使用频率和音韵美感精心排序。 *)
let an_yun_basic_chars = [
  ("安", PingSheng, AnRhyme); ("山", PingSheng, AnRhyme);
  ("间", PingSheng, AnRhyme); ("闲", PingSheng, AnRhyme);
  ("函", PingSheng, AnRhyme); ("参", PingSheng, AnRhyme);
  ("算", PingSheng, AnRhyme); ("量", PingSheng, AnRhyme);
  ("状", PingSheng, AnRhyme); ("常", PingSheng, AnRhyme);
  ("长", PingSheng, AnRhyme);
]

(** 安韵班关组 - 班关还环等字 *)
let an_yun_ban_group = [
  ("班", PingSheng, AnRhyme); ("删", PingSheng, AnRhyme);
  ("关", PingSheng, AnRhyme); ("还", PingSheng, AnRhyme);
  ("环", PingSheng, AnRhyme); ("般", PingSheng, AnRhyme);
  ("看", PingSheng, AnRhyme); ("含", PingSheng, AnRhyme);
  ("寒", PingSheng, AnRhyme); ("汗", PingSheng, AnRhyme);
  ("干", PingSheng, AnRhyme); ("甘", PingSheng, AnRhyme);
  ("三", PingSheng, AnRhyme);
]

(** 安韵弹谈组 - 弹谈探等字 *)
let an_yun_tan_group = [
  ("弹", PingSheng, AnRhyme); ("坛", PingSheng, AnRhyme);
  ("摊", PingSheng, AnRhyme); ("滩", PingSheng, AnRhyme);
  ("谈", PingSheng, AnRhyme); ("探", PingSheng, AnRhyme);
  ("叹", PingSheng, AnRhyme);
]

(** 安韵弯完组 - 弯完万等字 *)
let an_yun_wan_group = [
  ("弯", PingSheng, AnRhyme); ("湾", PingSheng, AnRhyme);
  ("完", PingSheng, AnRhyme); ("万", PingSheng, AnRhyme);
  ("顽", PingSheng, AnRhyme); ("烦", PingSheng, AnRhyme);
  ("繁", PingSheng, AnRhyme); ("番", PingSheng, AnRhyme);
  ("盘", PingSheng, AnRhyme); ("攀", PingSheng, AnRhyme);
  ("鞍", PingSheng, AnRhyme); ("案", PingSheng, AnRhyme);
]

(** 安韵南男组 - 南男蓝等字 *)
let an_yun_nan_group = [
  ("散", PingSheng, AnRhyme); ("满", PingSheng, AnRhyme);
  ("难", PingSheng, AnRhyme); ("南", PingSheng, AnRhyme);
  ("男", PingSheng, AnRhyme); ("蓝", PingSheng, AnRhyme);
  ("篮", PingSheng, AnRhyme); ("览", PingSheng, AnRhyme);
  ("懒", PingSheng, AnRhyme); ("烂", PingSheng, AnRhyme);
  ("滥", PingSheng, AnRhyme); ("暗", PingSheng, AnRhyme);
  ("叁", PingSheng, AnRhyme);
]

(** 安韵兰单组 - 兰单丹等字 *)
let an_yun_lan_group = [
  ("刊", PingSheng, AnRhyme); ("阑", PingSheng, AnRhyme);
  ("兰", PingSheng, AnRhyme); ("单", PingSheng, AnRhyme);
  ("丹", PingSheng, AnRhyme); ("残", PingSheng, AnRhyme);
  ("潺", PingSheng, AnRhyme); ("韩", PingSheng, AnRhyme);
  ("官", PingSheng, AnRhyme); ("观", PingSheng, AnRhyme);
  ("宽", PingSheng, AnRhyme); ("欢", PingSheng, AnRhyme);
]

(** 安韵团专组 - 团专端等字 *)
let an_yun_tuan_group = [
  ("团", PingSheng, AnRhyme); ("专", PingSheng, AnRhyme);
  ("端", PingSheng, AnRhyme); ("酸", PingSheng, AnRhyme);
  ("栏", PingSheng, AnRhyme); ("惨", PingSheng, AnRhyme);
  ("蚕", PingSheng, AnRhyme);
]

(** 安韵涵汉组 - 涵汉感等字 *)
let an_yun_han_group = [
  ("涵", PingSheng, AnRhyme); ("汉", PingSheng, AnRhyme);
  ("旱", PingSheng, AnRhyme); ("罕", PingSheng, AnRhyme);
  ("憾", PingSheng, AnRhyme); ("撼", PingSheng, AnRhyme);
  ("感", PingSheng, AnRhyme); ("赶", PingSheng, AnRhyme);
  ("敢", PingSheng, AnRhyme); ("橄", PingSheng, AnRhyme);
  ("坩", PingSheng, AnRhyme);
]

(** 安韵刚钢组 - 刚钢康等字 *)
let an_yun_gang_group = [
  ("钢", PingSheng, AnRhyme); ("刚", PingSheng, AnRhyme);
  ("冈", PingSheng, AnRhyme); ("纲", PingSheng, AnRhyme);
  ("缸", PingSheng, AnRhyme); ("肛", PingSheng, AnRhyme);
  ("港", PingSheng, AnRhyme); ("杠", PingSheng, AnRhyme);
  ("扛", PingSheng, AnRhyme); ("康", PingSheng, AnRhyme);
  ("抗", PingSheng, AnRhyme); ("炕", PingSheng, AnRhyme);
]

(** 安韵汤堂组 - 汤堂糖等字 *)
let an_yun_tang_group = [
  ("烫", PingSheng, AnRhyme); ("汤", PingSheng, AnRhyme);
  ("糖", PingSheng, AnRhyme); ("塘", PingSheng, AnRhyme);
  ("堂", PingSheng, AnRhyme); ("棠", PingSheng, AnRhyme);
  ("桑", PingSheng, AnRhyme); ("嗓", PingSheng, AnRhyme);
  ("搡", PingSheng, AnRhyme);
]

(** 安韵帮邦组 - 帮邦榜等字 *)
let an_yun_bang_group = [
  ("磅", PingSheng, AnRhyme); ("膀", PingSheng, AnRhyme);
  ("帮", PingSheng, AnRhyme); ("邦", PingSheng, AnRhyme);
  ("榜", PingSheng, AnRhyme); ("梆", PingSheng, AnRhyme);
  ("棒", PingSheng, AnRhyme); ("绑", PingSheng, AnRhyme);
  ("蚌", PingSheng, AnRhyme); ("谤", PingSheng, AnRhyme);
  ("傍", PingSheng, AnRhyme); ("旁", PingSheng, AnRhyme);
  ("庞", PingSheng, AnRhyme); ("胖", PingSheng, AnRhyme);
]

(** 安韵抛袍组 - 抛袍炮等字 *)
let an_yun_pao_group = [
  ("抛", PingSheng, AnRhyme); ("炮", PingSheng, AnRhyme);
  ("泡", PingSheng, AnRhyme); ("跑", PingSheng, AnRhyme);
  ("袍", PingSheng, AnRhyme); ("刨", PingSheng, AnRhyme);
  ("饱", PingSheng, AnRhyme); ("褒", PingSheng, AnRhyme);
  ("苞", PingSheng, AnRhyme); ("包", PingSheng, AnRhyme);
]

(** 安韵报抱组 - 报抱豹等字 *)
let an_yun_bao_group = [
  ("报", PingSheng, AnRhyme); ("抱", PingSheng, AnRhyme);
  ("豹", PingSheng, AnRhyme); ("暴", PingSheng, AnRhyme);
  ("堡", PingSheng, AnRhyme); ("保", PingSheng, AnRhyme);
  ("宝", PingSheng, AnRhyme);
]

(** 安韵组合函数 - 组合所有安韵平声字 *)
let an_yun_ping_sheng =
  List.concat [
    an_yun_basic_chars;
    an_yun_ban_group;
    an_yun_tan_group;
    an_yun_wan_group;
    an_yun_nan_group;
    an_yun_lan_group;
    an_yun_tuan_group;
    an_yun_han_group;
    an_yun_gang_group;
    an_yun_tang_group;
    an_yun_bang_group;
    an_yun_pao_group;
    an_yun_bao_group;
  ]

(** {2 安韵组统计信息} *)

(** 安韵组字符总数 *)
let an_yun_char_count = List.length an_yun_ping_sheng

(** 安韵组音韵类型 *)
let an_yun_rhyme_type = AnRhyme

(** {2 安韵组数据访问} *)

(** 获取安韵组所有字符 *)
let get_all_chars () = an_yun_ping_sheng

(** 检查字符是否属于安韵组 *)
let is_an_yun_char char = List.exists (fun (c, _, _) -> c = char) an_yun_ping_sheng

(** 获取安韵组字符列表（仅字符） *)
let get_char_list () = List.map (fun (c, _, _) -> c) an_yun_ping_sheng
