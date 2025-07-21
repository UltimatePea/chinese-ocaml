(** 花韵组数据模块 - 骆言诗词编程特性

    花霞家茶，春花秋月韵味深。花韵组包含"花、霞、家、茶"等字符， 依《平水韵》传统分类，音韵优美，适合描写自然美景和生活情趣。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-19 - Phase 14.2 模块化重构 *)

open Rhyme_group_types

(** {1 花韵组核心字符数据} *)

(** 花韵基础字组 - 花霞家茶等核心字

    包含最常用的花韵字符，如"花、霞、家、茶"等。 这些字符常用于描写自然景色和日常生活，韵律和谐。 *)
let hua_yun_basic_chars =
  [
    ("花", PingSheng, HuaRhyme);
    ("霞", PingSheng, HuaRhyme);
    ("家", PingSheng, HuaRhyme);
    ("茶", PingSheng, HuaRhyme);
    ("华", PingSheng, HuaRhyme);
    ("沙", PingSheng, HuaRhyme);
    ("纱", PingSheng, HuaRhyme);
    ("蛇", PingSheng, HuaRhyme);
    ("奢", PingSheng, HuaRhyme);
    ("赊", PingSheng, HuaRhyme);
  ]

(** 花韵车遮组 - 车遮类字

    包含"车、遮、蔗、者"等字符，多用于叙述和状物， 为诗词表达提供丰富的动作和状态描述。 *)
let hua_yun_che_group =
  [
    ("车", PingSheng, HuaRhyme);
    ("遮", PingSheng, HuaRhyme);
    ("蔗", PingSheng, HuaRhyme);
    ("者", PingSheng, HuaRhyme);
    ("这", PingSheng, HuaRhyme);
    ("舍", PingSheng, HuaRhyme);
    ("射", PingSheng, HuaRhyme);
    ("设", PingSheng, HuaRhyme);
    ("社", PingSheng, HuaRhyme);
    ("赦", PingSheng, HuaRhyme);
    ("涉", PingSheng, HuaRhyme);
    ("摄", PingSheng, HuaRhyme);
    ("慑", PingSheng, HuaRhyme);
    ("摺", PingSheng, HuaRhyme);
  ]

(** 花韵协叶组 - 协叶谐等字

    包含"叶、协、胁、挟"等字符，涵盖合作、和谐等语义， 常用于表达团结协作或自然和谐的意境。 *)
let hua_yun_xie_group =
  [
    ("叶", PingSheng, HuaRhyme);
    ("协", PingSheng, HuaRhyme);
    ("胁", PingSheng, HuaRhyme);
    ("挟", PingSheng, HuaRhyme);
    ("谐", PingSheng, HuaRhyme);
    ("鞋", PingSheng, HuaRhyme);
    ("些", PingSheng, HuaRhyme);
    ("歇", PingSheng, HuaRhyme);
    ("楔", PingSheng, HuaRhyme);
    ("蝎", PingSheng, HuaRhyme);
    ("邪", PingSheng, HuaRhyme);
  ]

(** 花韵牙芽组 - 牙芽崖等字

    包含"牙、芽、崖、涯"等字符，多与生长、边界相关， 适合描写自然生长和地理边界的诗意表达。 *)
let hua_yun_ya_group =
  [
    ("牙", PingSheng, HuaRhyme);
    ("芽", PingSheng, HuaRhyme);
    ("崖", PingSheng, HuaRhyme);
    ("涯", PingSheng, HuaRhyme);
    ("哑", PingSheng, HuaRhyme);
    ("雅", PingSheng, HuaRhyme);
    ("压", PingSheng, HuaRhyme);
    ("鸭", PingSheng, HuaRhyme);
    ("咽", PingSheng, HuaRhyme);
  ]

(** 花韵烟盐组 - 烟盐严等字

    包含"烟、盐、严、颜"等字符，涵盖了朦胧美感和严肃庄重， 为诗词创作提供多样的情感色彩。 *)
let hua_yun_yan_group =
  [
    ("烟", PingSheng, HuaRhyme);
    ("盐", PingSheng, HuaRhyme);
    ("严", PingSheng, HuaRhyme);
    ("颜", PingSheng, HuaRhyme);
    ("研", PingSheng, HuaRhyme);
    ("延", PingSheng, HuaRhyme);
    ("言", PingSheng, HuaRhyme);
    ("岩", PingSheng, HuaRhyme);
    ("檐", PingSheng, HuaRhyme);
    ("炎", PingSheng, HuaRhyme);
    ("淹", PingSheng, HuaRhyme);
    ("腌", PingSheng, HuaRhyme);
    ("阎", PingSheng, HuaRhyme);
    ("铅", PingSheng, HuaRhyme);
    ("妍", PingSheng, HuaRhyme);
    ("蜒", PingSheng, HuaRhyme);
    ("筵", PingSheng, HuaRhyme);
    ("湮", PingSheng, HuaRhyme);
    ("胭", PingSheng, HuaRhyme);
    ("嫣", PingSheng, HuaRhyme);
    ("殷", PingSheng, HuaRhyme);
    ("阉", PingSheng, HuaRhyme);
    ("菸", PingSheng, HuaRhyme);
  ]

(** 花韵验艳组 - 验艳焰等字

    包含"验、艳、焰、宴"等字符，多与验证、美丽、光亮相关， 适合表达华丽绚烂和庄重场合的诗意。 *)
let hua_yun_yan_second_group =
  [
    ("验", PingSheng, HuaRhyme);
    ("艳", PingSheng, HuaRhyme);
    ("焰", PingSheng, HuaRhyme);
    ("宴", PingSheng, HuaRhyme);
    ("雁", PingSheng, HuaRhyme);
    ("晏", PingSheng, HuaRhyme);
    ("彦", PingSheng, HuaRhyme);
    ("谚", PingSheng, HuaRhyme);
    ("堰", PingSheng, HuaRhyme);
    ("砚", PingSheng, HuaRhyme);
    ("唁", PingSheng, HuaRhyme);
    ("燕", PingSheng, HuaRhyme);
    ("厌", PingSheng, HuaRhyme);
    ("掩", PingSheng, HuaRhyme);
    ("眼", PingSheng, HuaRhyme);
    ("演", PingSheng, HuaRhyme);
    ("衍", PingSheng, HuaRhyme);
    ("奄", PingSheng, HuaRhyme);
    ("俺", PingSheng, HuaRhyme);
    ("偃", PingSheng, HuaRhyme);
    ("魇", PingSheng, HuaRhyme);
    ("鼹", PingSheng, HuaRhyme);
    ("琰", PingSheng, HuaRhyme);
    ("罨", PingSheng, HuaRhyme);
    ("兖", PingSheng, HuaRhyme);
    ("郾", PingSheng, HuaRhyme);
  ]

(** 花韵查茶组 - 查茶察等字

    包含"姹、杈、楂、槎"等字符，涵盖查验、观察等行为， 为诗词创作提供动态的表现手法。 *)
let hua_yun_cha_group =
  [
    ("姹", PingSheng, HuaRhyme);
    ("杈", PingSheng, HuaRhyme);
    ("楂", PingSheng, HuaRhyme);
    ("槎", PingSheng, HuaRhyme);
    ("茬", PingSheng, HuaRhyme);
    ("碴", PingSheng, HuaRhyme);
    ("嗏", PingSheng, HuaRhyme);
    ("插", PingSheng, HuaRhyme);
    ("查", PingSheng, HuaRhyme);
    ("察", PingSheng, HuaRhyme);
    ("搽", PingSheng, HuaRhyme);
    ("锸", PingSheng, HuaRhyme);
    ("馇", PingSheng, HuaRhyme);
    ("诧", PingSheng, HuaRhyme);
    ("岔", PingSheng, HuaRhyme);
    ("汊", PingSheng, HuaRhyme);
    ("衩", PingSheng, HuaRhyme);
    ("喳", PingSheng, HuaRhyme);
    ("嚓", PingSheng, HuaRhyme);
    ("咤", PingSheng, HuaRhyme);
    ("叉", PingSheng, HuaRhyme);
    ("差", PingSheng, HuaRhyme);
    ("偛", PingSheng, HuaRhyme);
    ("侘", PingSheng, HuaRhyme);
    ("刹", PingSheng, HuaRhyme);
    ("垞", PingSheng, HuaRhyme);
  ]

(** {1 花韵组数据合成} *)

(** 花韵组平声韵数据

    合并所有花韵组字符，生成完整的花韵平声韵数据。 包含基础字组、车遮组、协叶组、牙芽组、烟盐组、验艳组和查茶组。

    @return 花韵组的完整平声韵数据列表 *)
let hua_yun_ping_sheng =
  List.concat
    [
      hua_yun_basic_chars;
      hua_yun_che_group;
      hua_yun_xie_group;
      hua_yun_ya_group;
      hua_yun_yan_group;
      hua_yun_yan_second_group;
      hua_yun_cha_group;
    ]

(** {1 花韵组统计信息} *)

(** 获取花韵组字符总数 *)
let hua_yun_char_count = List.length hua_yun_ping_sheng

(** 获取花韵组基础字符数量 *)
let hua_yun_basic_count = List.length hua_yun_basic_chars

(** 获取花韵组车遮系列字符数量 *)
let hua_yun_che_count = List.length hua_yun_che_group

(** 获取花韵组协叶系列字符数量 *)
let hua_yun_xie_count = List.length hua_yun_xie_group

(** 获取花韵组牙芽系列字符数量 *)
let hua_yun_ya_count = List.length hua_yun_ya_group

(** 获取花韵组烟盐系列字符数量 *)
let hua_yun_yan_count = List.length hua_yun_yan_group

(** 获取花韵组验艳系列字符数量 *)
let hua_yun_yan_second_count = List.length hua_yun_yan_second_group

(** 获取花韵组查茶系列字符数量 *)
let hua_yun_cha_count = List.length hua_yun_cha_group
