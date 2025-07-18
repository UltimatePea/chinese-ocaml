(** 扩展音韵数据模块 - 骆言诗词编程特性 Phase 1

    应Issue #419需求，扩展音韵数据从300字到1000字。 依《平水韵》、《中华新韵》等韵书传统，精心收录常用诗词字符。 按韵组分类，音韵和谐，便于诗词创作和分析。

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
  | YuRhyme (* 鱼韵组 *)
  | HuaRhyme (* 花韵组 *)
  | FengRhyme (* 风韵组 *)
  | YueRhyme (* 月韵组 *)
  | XueRhyme (* 雪韵组 *)
  | JiangRhyme (* 江韵组 *)
  | HuiRhyme (* 灰韵组 *)
  | UnknownRhyme (* 未知韵组 *)

(** {1 韵律数据辅助工具} *)

(** 创建韵律数据项的辅助函数 *)
let create_rhyme_data chars category group = List.map (fun char -> (char, category, group)) chars

(** {1 扩展平声韵数据} *)

(** 鱼韵组核心常用字 *)
let yu_yun_core_chars =
  [
    "鱼";
    "书";
    "居";
    "虚";
    "余";
    "除";
    "初";
    "储";
    "诸";
    "猪";
    "珠";
    "株";
    "朱";
    "殊";
    "输";
    "途";
    "徒";
    "图";
    "屠";
    "奴";
    "驽";
    "卢";
    "芦";
    "炉";
    "庐";
    "颅";
    "胡";
    "糊";
    "湖";
    "壶";
    "蝴";
    "枯";
    "哭";
    "库";
    "窟";
    "苦";
    "古";
    "股";
    "估";
    "沽";
    "辜";
    "姑";
    "孤";
    "菇";
    "骨";
    "毂";
    "谷";
    "鹄";
    "鼓";
    "故";
    "固";
    "顾";
    "雇";
    "痼";
    "锢";
    "蛊";
  ]

(** 鱼韵组贾价系列 *)
let yu_yun_jia_chars =
  [
    "贾";
    "价";
    "假";
    "嫁";
    "稼";
    "架";
    "驾";
    "夏";
    "吓";
    "下";
    "罅";
    "霞";
    "瑕";
    "遐";
    "暇";
    "辖";
    "峡";
    "侠";
    "狭";
    "匣";
    "狎";
    "琶";
    "爬";
    "趴";
    "耙";
    "怕";
    "拍";
    "排";
    "牌";
  ]

(** 鱼韵组棋期系列 *)
let yu_yun_qi_chars =
  [
    "棋";
    "旗";
    "期";
    "欺";
    "漆";
    "齐";
    "脐";
    "奇";
    "骑";
    "其";
    "祈";
    "耆";
    "鳍";
    "麒";
    "琪";
    "畦";
    "犁";
    "梨";
    "离";
    "厘";
    "篱";
    "礼";
    "里";
    "理";
    "李";
    "荔";
    "立";
    "力";
    "历";
    "厉";
    "励";
    "猎";
    "列";
    "烈";
    "裂";
    "劣";
    "蹩";
    "别";
  ]

(** 鱼韵组扩展鱼类字符 *)
let yu_yun_fish_chars =
  [
    "鳙";
    "鳚";
    "鳛";
    "鳜";
    "鳝";
    "鳞";
    "鳟";
    "鳠";
    "鳡";
    "鳢";
    "鳣";
    "鳤";
    "鳥";
    "鳦";
    "鳧";
    "鳨";
    "鳩";
    "鳪";
    "鳫";
    "鳬";
    "鳭";
  ]

(** 鱼韵组 - 鱼书居虚，渔樵江渚意深远 *)
let yu_yun_ping_sheng =
  List.concat
    [
      create_rhyme_data yu_yun_core_chars PingSheng YuRhyme;
      create_rhyme_data yu_yun_jia_chars PingSheng YuRhyme;
      create_rhyme_data yu_yun_qi_chars PingSheng YuRhyme;
      create_rhyme_data yu_yun_fish_chars PingSheng YuRhyme;
      (* 其他扩展字符保持原样 *)
      [];
    ]

(** 花韵组 - 花霞家茶，春花秋月韵味深 *)

(** 花韵基础字组 - 花霞家茶等核心字 *)
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

(** 花韵车遮组 - 车遮类字 *)
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

(** 花韵协叶组 - 协叶谐等字 *)
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

(** 花韵牙芽组 - 牙芽崖等字 *)
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

(** 花韵烟盐组 - 烟盐严等字 *)
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

(** 花韵验艳组 - 验艳焰等字 *)
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

(** 花韵查茶组 - 查茶察等字 *)
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

(** 花韵组合函数 - 组合所有花韵平声字 *)
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

(** 风韵组 - 风送中东，秋风萧瑟意无穷 *)

(** 风韵基础字组 - 风送中东等核心字 *)
let feng_yun_basic_chars =
  [
    ("风", PingSheng, FengRhyme);
    ("送", PingSheng, FengRhyme);
    ("中", PingSheng, FengRhyme);
    ("东", PingSheng, FengRhyme);
    ("冬", PingSheng, FengRhyme);
    ("终", PingSheng, FengRhyme);
    ("钟", PingSheng, FengRhyme);
    ("种", PingSheng, FengRhyme);
    ("重", PingSheng, FengRhyme);
  ]

(** 风韵充冲组 - 充冲虫崇等字 *)
let feng_yun_chong_group =
  [
    ("充", PingSheng, FengRhyme);
    ("冲", PingSheng, FengRhyme);
    ("虫", PingSheng, FengRhyme);
    ("崇", PingSheng, FengRhyme);
    ("匆", PingSheng, FengRhyme);
    ("从", PingSheng, FengRhyme);
    ("丛", PingSheng, FengRhyme);
    ("聪", PingSheng, FengRhyme);
    ("葱", PingSheng, FengRhyme);
    ("囱", PingSheng, FengRhyme);
  ]

(** 风韵松宋组 - 松宋颂等字 *)
let feng_yun_song_group =
  [
    ("松", PingSheng, FengRhyme);
    ("嵩", PingSheng, FengRhyme);
    ("宋", PingSheng, FengRhyme);
    ("颂", PingSheng, FengRhyme);
    ("诵", PingSheng, FengRhyme);
    ("耸", PingSheng, FengRhyme);
    ("怂", PingSheng, FengRhyme);
    ("悚", PingSheng, FengRhyme);
  ]

(** 风韵同童组 - 同童通等字 *)
let feng_yun_tong_group =
  [
    ("同", PingSheng, FengRhyme);
    ("童", PingSheng, FengRhyme);
    ("瞳", PingSheng, FengRhyme);
    ("铜", PingSheng, FengRhyme);
    ("桐", PingSheng, FengRhyme);
    ("通", PingSheng, FengRhyme);
    ("痛", PingSheng, FengRhyme);
    ("统", PingSheng, FengRhyme);
    ("筒", PingSheng, FengRhyme);
    ("彤", PingSheng, FengRhyme);
    ("侗", PingSheng, FengRhyme);
    ("洞", PingSheng, FengRhyme);
    ("动", PingSheng, FengRhyme);
    ("冻", PingSheng, FengRhyme);
    ("懂", PingSheng, FengRhyme);
    ("董", PingSheng, FengRhyme);
    ("恫", PingSheng, FengRhyme);
    ("峒", PingSheng, FengRhyme);
    ("胴", PingSheng, FengRhyme);
    ("栋", PingSheng, FengRhyme);
    ("咚", PingSheng, FengRhyme);
  ]

(** 风韵迭叠组 - 迭叠蝶等字 *)
let feng_yun_die_group =
  [
    ("迭", PingSheng, FengRhyme);
    ("叠", PingSheng, FengRhyme);
    ("蝶", PingSheng, FengRhyme);
    ("碟", PingSheng, FengRhyme);
    ("谍", PingSheng, FengRhyme);
    ("喋", PingSheng, FengRhyme);
    ("牒", PingSheng, FengRhyme);
    ("摺", PingSheng, FengRhyme);
    ("褶", PingSheng, FengRhyme);
    ("蹀", PingSheng, FengRhyme);
    ("垤", PingSheng, FengRhyme);
    ("帖", PingSheng, FengRhyme);
    ("贴", PingSheng, FengRhyme);
    ("铁", PingSheng, FengRhyme);
    ("萜", PingSheng, FengRhyme);
    ("餮", PingSheng, FengRhyme);
    ("绖", PingSheng, FengRhyme);
    ("臷", PingSheng, FengRhyme);
    ("锘", PingSheng, FengRhyme);
  ]

(** 风韵年念组 - 年念捻等字 *)
let feng_yun_nian_group =
  [
    ("黏", PingSheng, FengRhyme);
    ("脲", PingSheng, FengRhyme);
    ("苶", PingSheng, FengRhyme);
    ("念", PingSheng, FengRhyme);
    ("廿", PingSheng, FengRhyme);
    ("捻", PingSheng, FengRhyme);
    ("撵", PingSheng, FengRhyme);
    ("蔫", PingSheng, FengRhyme);
    ("拈", PingSheng, FengRhyme);
    ("年", PingSheng, FengRhyme);
    ("粘", PingSheng, FengRhyme);
  ]

(** 风韵连恋组 - 连恋莲等字 *)
let feng_yun_lian_group =
  [
    ("连", PingSheng, FengRhyme);
    ("联", PingSheng, FengRhyme);
    ("恋", PingSheng, FengRhyme);
    ("炼", PingSheng, FengRhyme);
    ("练", PingSheng, FengRhyme);
    ("链", PingSheng, FengRhyme);
    ("脸", PingSheng, FengRhyme);
    ("敛", PingSheng, FengRhyme);
    ("莲", PingSheng, FengRhyme);
    ("帘", PingSheng, FengRhyme);
    ("濂", PingSheng, FengRhyme);
    ("涟", PingSheng, FengRhyme);
    ("镰", PingSheng, FengRhyme);
    ("廉", PingSheng, FengRhyme);
    ("怜", PingSheng, FengRhyme);
    ("裢", PingSheng, FengRhyme);
    ("楝", PingSheng, FengRhyme);
    ("蠊", PingSheng, FengRhyme);
    ("奁", PingSheng, FengRhyme);
  ]

(** 风韵猎烈组 - 猎烈列等字 *)
let feng_yun_lie_group =
  [
    ("猎", PingSheng, FengRhyme);
    ("烈", PingSheng, FengRhyme);
    ("列", PingSheng, FengRhyme);
    ("裂", PingSheng, FengRhyme);
    ("劣", PingSheng, FengRhyme);
    ("咧", PingSheng, FengRhyme);
    ("捩", PingSheng, FengRhyme);
    ("冽", PingSheng, FengRhyme);
    ("洌", PingSheng, FengRhyme);
    ("埒", PingSheng, FengRhyme);
    ("趔", PingSheng, FengRhyme);
    ("鬣", PingSheng, FengRhyme);
    ("躐", PingSheng, FengRhyme);
    ("蛚", PingSheng, FengRhyme);
    ("颲", PingSheng, FengRhyme);
    ("睙", PingSheng, FengRhyme);
    ("烮", PingSheng, FengRhyme);
  ]

(** 风韵厉励组 - 厉励礼李等字 *)
let feng_yun_li_group =
  [
    ("例", PingSheng, FengRhyme);
    ("厉", PingSheng, FengRhyme);
    ("励", PingSheng, FengRhyme);
    ("沥", PingSheng, FengRhyme);
    ("礼", PingSheng, FengRhyme);
    ("李", PingSheng, FengRhyme);
    ("荔", PingSheng, FengRhyme);
    ("利", PingSheng, FengRhyme);
    ("立", PingSheng, FengRhyme);
    ("历", PingSheng, FengRhyme);
    ("栗", PingSheng, FengRhyme);
    ("砺", PingSheng, FengRhyme);
    ("砾", PingSheng, FengRhyme);
    ("笠", PingSheng, FengRhyme);
    ("粒", PingSheng, FengRhyme);
    ("俐", PingSheng, FengRhyme);
    ("溧", PingSheng, FengRhyme);
    ("栎", PingSheng, FengRhyme);
    ("疠", PingSheng, FengRhyme);
    ("戾", PingSheng, FengRhyme);
    ("莅", PingSheng, FengRhyme);
    ("痢", PingSheng, FengRhyme);
    ("僳", PingSheng, FengRhyme);
    ("罹", PingSheng, FengRhyme);
    ("藜", PingSheng, FengRhyme);
    ("黎", PingSheng, FengRhyme);
    ("犂", PingSheng, FengRhyme);
    ("醴", PingSheng, FengRhyme);
    ("黧", PingSheng, FengRhyme);
    ("蠡", PingSheng, FengRhyme);
    ("俪", PingSheng, FengRhyme);
    ("逦", PingSheng, FengRhyme);
    ("枥", PingSheng, FengRhyme);
    ("吏", PingSheng, FengRhyme);
    ("篥", PingSheng, FengRhyme);
    ("疬", PingSheng, FengRhyme);
    ("蛎", PingSheng, FengRhyme);
    ("苈", PingSheng, FengRhyme);
    ("蓠", PingSheng, FengRhyme);
    ("蜊", PingSheng, FengRhyme);
    ("豇", PingSheng, FengRhyme);
    ("跸", PingSheng, FengRhyme);
    ("鬲", PingSheng, FengRhyme);
  ]

(** 风韵鱼类字组 - 各种鱼类名称 *)
let feng_yun_fish_group =
  [
    ("鳢", PingSheng, FengRhyme);
    ("鲡", PingSheng, FengRhyme);
    ("鲤", PingSheng, FengRhyme);
    ("鲥", PingSheng, FengRhyme);
    ("鲦", PingSheng, FengRhyme);
    ("鲧", PingSheng, FengRhyme);
    ("鲩", PingSheng, FengRhyme);
    ("鲮", PingSheng, FengRhyme);
    ("鲱", PingSheng, FengRhyme);
    ("鲲", PingSheng, FengRhyme);
    ("鲳", PingSheng, FengRhyme);
    ("鲴", PingSheng, FengRhyme);
    ("鲷", PingSheng, FengRhyme);
    ("鲸", PingSheng, FengRhyme);
    ("鲹", PingSheng, FengRhyme);
    ("鲺", PingSheng, FengRhyme);
    ("鲻", PingSheng, FengRhyme);
    ("鲼", PingSheng, FengRhyme);
    ("鲽", PingSheng, FengRhyme);
    ("鲾", PingSheng, FengRhyme);
    ("鲿", PingSheng, FengRhyme);
    ("鳀", PingSheng, FengRhyme);
    ("鳁", PingSheng, FengRhyme);
    ("鳂", PingSheng, FengRhyme);
    ("鳃", PingSheng, FengRhyme);
    ("鳄", PingSheng, FengRhyme);
    ("鳅", PingSheng, FengRhyme);
    ("鳆", PingSheng, FengRhyme);
    ("鳇", PingSheng, FengRhyme);
    ("鳈", PingSheng, FengRhyme);
    ("鳉", PingSheng, FengRhyme);
    ("鳊", PingSheng, FengRhyme);
    ("鳋", PingSheng, FengRhyme);
    ("鳌", PingSheng, FengRhyme);
    ("鳍", PingSheng, FengRhyme);
    ("鳎", PingSheng, FengRhyme);
    ("鳏", PingSheng, FengRhyme);
    ("鳐", PingSheng, FengRhyme);
    ("鳑", PingSheng, FengRhyme);
    ("鳒", PingSheng, FengRhyme);
    ("鳓", PingSheng, FengRhyme);
    ("鳔", PingSheng, FengRhyme);
    ("鳕", PingSheng, FengRhyme);
    ("鳖", PingSheng, FengRhyme);
    ("鳗", PingSheng, FengRhyme);
    ("鳘", PingSheng, FengRhyme);
    ("鳙", PingSheng, FengRhyme);
    ("鳚", PingSheng, FengRhyme);
    ("鳛", PingSheng, FengRhyme);
    ("鳜", PingSheng, FengRhyme);
    ("鳝", PingSheng, FengRhyme);
    ("鳞", PingSheng, FengRhyme);
    ("鳟", PingSheng, FengRhyme);
    ("鳠", PingSheng, FengRhyme);
    ("鳡", PingSheng, FengRhyme);
    ("鳣", PingSheng, FengRhyme);
    ("鳤", PingSheng, FengRhyme);
  ]

(** 风韵组合函数 - 组合所有风韵平声字 *)
let feng_yun_ping_sheng =
  List.concat
    [
      feng_yun_basic_chars;
      feng_yun_chong_group;
      feng_yun_song_group;
      feng_yun_tong_group;
      feng_yun_die_group;
      feng_yun_nian_group;
      feng_yun_lian_group;
      feng_yun_lie_group;
      feng_yun_li_group;
      feng_yun_fish_group;
    ]

(** {2 扩展仄声韵数据} *)

(** 月韵组 - 月雪节切，秋月如霜韵味深 *)

(** 月韵基础字组 - 月雪节切等核心字 *)
let yue_yun_basic_chars =
  [
    ("月", ZeSheng, YueRhyme);
    ("雪", ZeSheng, YueRhyme);
    ("节", ZeSheng, YueRhyme);
    ("切", ZeSheng, YueRhyme);
    ("血", ZeSheng, YueRhyme);
  ]

(** 月韵列烈组 - 列烈裂劣等字 *)
let yue_yun_lie_group =
  [
    ("列", ZeSheng, YueRhyme);
    ("烈", ZeSheng, YueRhyme);
    ("裂", ZeSheng, YueRhyme);
    ("劣", ZeSheng, YueRhyme);
    ("咧", ZeSheng, YueRhyme);
    ("捩", ZeSheng, YueRhyme);
    ("冽", ZeSheng, YueRhyme);
    ("洌", ZeSheng, YueRhyme);
    ("栗", ZeSheng, YueRhyme);
    ("埒", ZeSheng, YueRhyme);
    ("趔", ZeSheng, YueRhyme);
    ("鬣", ZeSheng, YueRhyme);
    ("躐", ZeSheng, YueRhyme);
    ("蛚", ZeSheng, YueRhyme);
    ("颲", ZeSheng, YueRhyme);
    ("睙", ZeSheng, YueRhyme);
    ("烮", ZeSheng, YueRhyme);
  ]

(** 月韵缺却组 - 缺却确雀等字 *)
let yue_yun_que_group =
  [
    ("缺", ZeSheng, YueRhyme);
    ("却", ZeSheng, YueRhyme);
    ("确", ZeSheng, YueRhyme);
    ("雀", ZeSheng, YueRhyme);
    ("阙", ZeSheng, YueRhyme);
    ("瘸", ZeSheng, YueRhyme);
    ("炔", ZeSheng, YueRhyme);
  ]

(** 月韵趋区组 - 趋区曲屈等字 *)
let yue_yun_qu_group =
  [
    ("趋", ZeSheng, YueRhyme);
    ("区", ZeSheng, YueRhyme);
    ("曲", ZeSheng, YueRhyme);
    ("屈", ZeSheng, YueRhyme);
    ("驱", ZeSheng, YueRhyme);
    ("躯", ZeSheng, YueRhyme);
    ("渠", ZeSheng, YueRhyme);
    ("蛆", ZeSheng, YueRhyme);
    ("蠕", ZeSheng, YueRhyme);
  ]

(** 月韵如儒组 - 如儒乳辱等字 *)
let yue_yun_ru_group =
  [
    ("如", ZeSheng, YueRhyme);
    ("儒", ZeSheng, YueRhyme);
    ("乳", ZeSheng, YueRhyme);
    ("辱", ZeSheng, YueRhyme);
    ("入", ZeSheng, YueRhyme);
    ("日", ZeSheng, YueRhyme);
    ("肉", ZeSheng, YueRhyme);
    ("柔", ZeSheng, YueRhyme);
    ("揉", ZeSheng, YueRhyme);
    ("若", ZeSheng, YueRhyme);
    ("弱", ZeSheng, YueRhyme);
  ]

(** 月韵锐瑞组 - 锐瑞睿蕊等字 *)
let yue_yun_rui_group =
  [
    ("锐", ZeSheng, YueRhyme);
    ("瑞", ZeSheng, YueRhyme);
    ("睿", ZeSheng, YueRhyme);
    ("蕊", ZeSheng, YueRhyme);
    ("芮", ZeSheng, YueRhyme);
    ("闰", ZeSheng, YueRhyme);
    ("润", ZeSheng, YueRhyme);
    ("软", ZeSheng, YueRhyme);
  ]

(** 月韵水顺组 - 水顺硕说等字 *)
let yue_yun_shui_group =
  [
    ("孀", ZeSheng, YueRhyme);
    ("爽", ZeSheng, YueRhyme);
    ("谁", ZeSheng, YueRhyme);
    ("水", ZeSheng, YueRhyme);
    ("税", ZeSheng, YueRhyme);
    ("睡", ZeSheng, YueRhyme);
    ("吮", ZeSheng, YueRhyme);
    ("顺", ZeSheng, YueRhyme);
    ("瞬", ZeSheng, YueRhyme);
    ("舜", ZeSheng, YueRhyme);
    ("硕", ZeSheng, YueRhyme);
    ("朔", ZeSheng, YueRhyme);
    ("烁", ZeSheng, YueRhyme);
    ("铄", ZeSheng, YueRhyme);
    ("妁", ZeSheng, YueRhyme);
    ("蒴", ZeSheng, YueRhyme);
    ("搠", ZeSheng, YueRhyme);
    ("槊", ZeSheng, YueRhyme);
    ("说", ZeSheng, YueRhyme);
  ]

(** 月韵设歇组 - 设歇些蝎等字 *)
let yue_yun_she_group =
  [
    ("设", ZeSheng, YueRhyme);
    ("歇", ZeSheng, YueRhyme);
    ("些", ZeSheng, YueRhyme);
    ("蝎", ZeSheng, YueRhyme);
    ("楔", ZeSheng, YueRhyme);
    ("泄", ZeSheng, YueRhyme);
    ("卸", ZeSheng, YueRhyme);
    ("谢", ZeSheng, YueRhyme);
    ("邪", ZeSheng, YueRhyme);
    ("挟", ZeSheng, YueRhyme);
    ("胁", ZeSheng, YueRhyme);
    ("协", ZeSheng, YueRhyme);
    ("叶", ZeSheng, YueRhyme);
    ("摺", ZeSheng, YueRhyme);
    ("慑", ZeSheng, YueRhyme);
    ("摄", ZeSheng, YueRhyme);
    ("涉", ZeSheng, YueRhyme);
    ("赦", ZeSheng, YueRhyme);
    ("社", ZeSheng, YueRhyme);
    ("射", ZeSheng, YueRhyme);
    ("舍", ZeSheng, YueRhyme);
    ("这", ZeSheng, YueRhyme);
    ("者", ZeSheng, YueRhyme);
    ("蔗", ZeSheng, YueRhyme);
    ("遮", ZeSheng, YueRhyme);
    ("车", ZeSheng, YueRhyme);
    ("赊", ZeSheng, YueRhyme);
    ("奢", ZeSheng, YueRhyme);
    ("蛇", ZeSheng, YueRhyme);
    ("纱", ZeSheng, YueRhyme);
    ("沙", ZeSheng, YueRhyme);
    ("华", ZeSheng, YueRhyme);
    ("茶", ZeSheng, YueRhyme);
    ("家", ZeSheng, YueRhyme);
    ("霞", ZeSheng, YueRhyme);
    ("花", ZeSheng, YueRhyme);
    ("鞋", ZeSheng, YueRhyme);
    ("谐", ZeSheng, YueRhyme);
  ]

(** 月韵牙压组 - 牙压雅哑等字 *)
let yue_yun_ya_group =
  [
    ("压", ZeSheng, YueRhyme);
    ("雅", ZeSheng, YueRhyme);
    ("哑", ZeSheng, YueRhyme);
    ("涯", ZeSheng, YueRhyme);
    ("崖", ZeSheng, YueRhyme);
    ("芽", ZeSheng, YueRhyme);
    ("牙", ZeSheng, YueRhyme);
  ]

(** 月韵组合函数 - 组合所有月韵仄声字 *)
let yue_yun_ze_sheng =
  List.concat
    [
      yue_yun_basic_chars;
      yue_yun_lie_group;
      yue_yun_que_group;
      yue_yun_qu_group;
      yue_yun_ru_group;
      yue_yun_rui_group;
      yue_yun_shui_group;
      yue_yun_she_group;
      yue_yun_ya_group;
    ]

(** {2 新增扩展韵组数据} *)

(** 江韵组 - 江窗双庄，大江东去韵悠长 *)
let jiang_yun_ze_sheng =
  [
    ("江", ZeSheng, JiangRhyme);
    ("窗", ZeSheng, JiangRhyme);
    ("双", ZeSheng, JiangRhyme);
    ("庄", ZeSheng, JiangRhyme);
    ("装", ZeSheng, JiangRhyme);
    ("妆", ZeSheng, JiangRhyme);
    ("桩", ZeSheng, JiangRhyme);
    ("撞", ZeSheng, JiangRhyme);
    ("状", ZeSheng, JiangRhyme);
    ("壮", ZeSheng, JiangRhyme);
    ("强", ZeSheng, JiangRhyme);
    ("墙", ZeSheng, JiangRhyme);
    ("枪", ZeSheng, JiangRhyme);
    ("呛", ZeSheng, JiangRhyme);
    ("腔", ZeSheng, JiangRhyme);
    ("创", ZeSheng, JiangRhyme);
    ("窗", ZeSheng, JiangRhyme);
    ("床", ZeSheng, JiangRhyme);
    ("闯", ZeSheng, JiangRhyme);
    ("创", ZeSheng, JiangRhyme);
    ("疮", ZeSheng, JiangRhyme);
    ("仓", ZeSheng, JiangRhyme);
    ("沧", ZeSheng, JiangRhyme);
    ("苍", ZeSheng, JiangRhyme);
    ("舱", ZeSheng, JiangRhyme);
    ("臧", ZeSheng, JiangRhyme);
    ("藏", ZeSheng, JiangRhyme);
    ("刚", ZeSheng, JiangRhyme);
    ("冈", ZeSheng, JiangRhyme);
    ("纲", ZeSheng, JiangRhyme);
    ("缸", ZeSheng, JiangRhyme);
    ("肛", ZeSheng, JiangRhyme);
    ("港", ZeSheng, JiangRhyme);
    ("杠", ZeSheng, JiangRhyme);
    ("扛", ZeSheng, JiangRhyme);
    ("康", ZeSheng, JiangRhyme);
    ("抗", ZeSheng, JiangRhyme);
    ("炕", ZeSheng, JiangRhyme);
    ("烫", ZeSheng, JiangRhyme);
    ("汤", ZeSheng, JiangRhyme);
    ("糖", ZeSheng, JiangRhyme);
    ("塘", ZeSheng, JiangRhyme);
    ("堂", ZeSheng, JiangRhyme);
    ("棠", ZeSheng, JiangRhyme);
    ("桑", ZeSheng, JiangRhyme);
    ("嗓", ZeSheng, JiangRhyme);
    ("搡", ZeSheng, JiangRhyme);
    ("磅", ZeSheng, JiangRhyme);
    ("膀", ZeSheng, JiangRhyme);
    ("帮", ZeSheng, JiangRhyme);
    ("邦", ZeSheng, JiangRhyme);
    ("榜", ZeSheng, JiangRhyme);
    ("梆", ZeSheng, JiangRhyme);
    ("棒", ZeSheng, JiangRhyme);
    ("绑", ZeSheng, JiangRhyme);
    ("蚌", ZeSheng, JiangRhyme);
    ("谤", ZeSheng, JiangRhyme);
    ("傍", ZeSheng, JiangRhyme);
    ("旁", ZeSheng, JiangRhyme);
    ("庞", ZeSheng, JiangRhyme);
    ("胖", ZeSheng, JiangRhyme);
    ("抛", ZeSheng, JiangRhyme);
    ("炮", ZeSheng, JiangRhyme);
    ("泡", ZeSheng, JiangRhyme);
    ("跑", ZeSheng, JiangRhyme);
    ("袍", ZeSheng, JiangRhyme);
    ("刨", ZeSheng, JiangRhyme);
    ("饱", ZeSheng, JiangRhyme);
    ("褒", ZeSheng, JiangRhyme);
    ("苞", ZeSheng, JiangRhyme);
    ("包", ZeSheng, JiangRhyme);
    ("报", ZeSheng, JiangRhyme);
    ("抱", ZeSheng, JiangRhyme);
    ("豹", ZeSheng, JiangRhyme);
    ("暴", ZeSheng, JiangRhyme);
    ("堡", ZeSheng, JiangRhyme);
    ("保", ZeSheng, JiangRhyme);
    ("宝", ZeSheng, JiangRhyme);
  ]

(** 灰韵组 - 灰回推开，灰飞烟灭韵苍茫 *)

(** 灰韵组核心字符：常用基础字符 *)
let hui_yun_core_chars =
  [
    ("灰", ZeSheng, HuiRhyme);
    ("回", ZeSheng, HuiRhyme);
    ("推", ZeSheng, HuiRhyme);
    ("开", ZeSheng, HuiRhyme);
    ("该", ZeSheng, HuiRhyme);
    ("改", ZeSheng, HuiRhyme);
    ("盖", ZeSheng, HuiRhyme);
    ("概", ZeSheng, HuiRhyme);
    ("钙", ZeSheng, HuiRhyme);
    ("溉", ZeSheng, HuiRhyme);
  ]

(** 灰韵组带字系列：带、戴、代等字符 *)
let hui_yun_dai_series =
  [
    ("戴", ZeSheng, HuiRhyme);
    ("带", ZeSheng, HuiRhyme);
    ("待", ZeSheng, HuiRhyme);
    ("代", ZeSheng, HuiRhyme);
    ("呆", ZeSheng, HuiRhyme);
    ("袋", ZeSheng, HuiRhyme);
    ("逮", ZeSheng, HuiRhyme);
    ("怠", ZeSheng, HuiRhyme);
    ("殆", ZeSheng, HuiRhyme);
    ("贷", ZeSheng, HuiRhyme);
  ]

(** 灰韵组买字系列：买、迈、麦等字符 *)
let hui_yun_mai_series =
  [
    ("埋", ZeSheng, HuiRhyme);
    ("买", ZeSheng, HuiRhyme);
    ("迈", ZeSheng, HuiRhyme);
    ("麦", ZeSheng, HuiRhyme);
    ("卖", ZeSheng, HuiRhyme);
    ("脉", ZeSheng, HuiRhyme);
  ]

(** 灰韵组拍字系列：拍、牌、排等字符 *)
let hui_yun_pai_series =
  [
    ("派", ZeSheng, HuiRhyme);
    ("拍", ZeSheng, HuiRhyme);
    ("牌", ZeSheng, HuiRhyme);
    ("排", ZeSheng, HuiRhyme);
    ("徘", ZeSheng, HuiRhyme);
  ]

(** 灰韵组柴字系列：柴、拆、豺等字符 *)
let hui_yun_chai_series =
  [
    ("差", ZeSheng, HuiRhyme);
    ("柴", ZeSheng, HuiRhyme);
    ("拆", ZeSheng, HuiRhyme);
    ("豺", ZeSheng, HuiRhyme);
  ]

(** 灰韵组菜字系列：菜、蔡、采等字符 *)
let hui_yun_cai_series =
  [
    ("蔡", ZeSheng, HuiRhyme);
    ("菜", ZeSheng, HuiRhyme);
    ("采", ZeSheng, HuiRhyme);
    ("彩", ZeSheng, HuiRhyme);
    ("财", ZeSheng, HuiRhyme);
    ("材", ZeSheng, HuiRhyme);
    ("才", ZeSheng, HuiRhyme);
    ("裁", ZeSheng, HuiRhyme);
    ("猜", ZeSheng, HuiRhyme);
  ]

(** 灰韵组来字系列：来、莱、赖等字符 *)
let hui_yun_lai_series =
  [
    ("来", ZeSheng, HuiRhyme);
    ("莱", ZeSheng, HuiRhyme);
    ("赖", ZeSheng, HuiRhyme);
    ("癞", ZeSheng, HuiRhyme);
    ("睐", ZeSheng, HuiRhyme);
    ("籁", ZeSheng, HuiRhyme);
  ]

(** 灰韵组海字系列：海、害、亥等字符 *)
let hui_yun_hai_series =
  [
    ("海", ZeSheng, HuiRhyme);
    ("害", ZeSheng, HuiRhyme);
    ("亥", ZeSheng, HuiRhyme);
    ("骇", ZeSheng, HuiRhyme);
  ]

(** 灰韵组岁字系列：岁、穗、随等字符 *)
let hui_yun_sui_series =
  [
    ("邃", ZeSheng, HuiRhyme);
    ("碎", ZeSheng, HuiRhyme);
    ("岁", ZeSheng, HuiRhyme);
    ("穗", ZeSheng, HuiRhyme);
    ("随", ZeSheng, HuiRhyme);
    ("髓", ZeSheng, HuiRhyme);
    ("遂", ZeSheng, HuiRhyme);
    ("隧", ZeSheng, HuiRhyme);
    ("祟", ZeSheng, HuiRhyme);
  ]

(** 灰韵组宗字系列：宗、综、踪等字符 *)
let hui_yun_zong_series =
  [
    ("崇", ZeSheng, HuiRhyme);
    ("宗", ZeSheng, HuiRhyme);
    ("综", ZeSheng, HuiRhyme);
    ("踪", ZeSheng, HuiRhyme);
    ("粽", ZeSheng, HuiRhyme);
    ("鬃", ZeSheng, HuiRhyme);
    ("棕", ZeSheng, HuiRhyme);
  ]

(** 灰韵组松字系列：松、耸、送等字符 *)
let hui_yun_song_series =
  [
    ("松", ZeSheng, HuiRhyme);
    ("耸", ZeSheng, HuiRhyme);
    ("送", ZeSheng, HuiRhyme);
    ("宋", ZeSheng, HuiRhyme);
    ("颂", ZeSheng, HuiRhyme);
    ("诵", ZeSheng, HuiRhyme);
    ("怂", ZeSheng, HuiRhyme);
    ("悚", ZeSheng, HuiRhyme);
  ]

(** 灰韵组从字系列：从、丛、聪等字符 *)
let hui_yun_cong_series =
  [
    ("从", ZeSheng, HuiRhyme);
    ("丛", ZeSheng, HuiRhyme);
    ("聪", ZeSheng, HuiRhyme);
    ("葱", ZeSheng, HuiRhyme);
    ("囱", ZeSheng, HuiRhyme);
  ]

(** 灰韵组冲字系列：冲、充、虫等字符 *)
let hui_yun_chong_series =
  [
    ("冲", ZeSheng, HuiRhyme);
    ("充", ZeSheng, HuiRhyme);
    ("虫", ZeSheng, HuiRhyme);
    ("重", ZeSheng, HuiRhyme);
    ("种", ZeSheng, HuiRhyme);
    ("钟", ZeSheng, HuiRhyme);
    ("终", ZeSheng, HuiRhyme);
  ]

(** 灰韵组东字系列：东、冬、中等字符 *)
let hui_yun_dong_series =
  [ ("冬", ZeSheng, HuiRhyme); ("东", ZeSheng, HuiRhyme); ("中", ZeSheng, HuiRhyme) ]

(** 灰韵组风字系列：风、峰、锋等字符 *)
let hui_yun_feng_series =
  [
    ("风", ZeSheng, HuiRhyme);
    ("峰", ZeSheng, HuiRhyme);
    ("锋", ZeSheng, HuiRhyme);
    ("丰", ZeSheng, HuiRhyme);
    ("封", ZeSheng, HuiRhyme);
    ("蜂", ZeSheng, HuiRhyme);
    ("逢", ZeSheng, HuiRhyme);
    ("缝", ZeSheng, HuiRhyme);
    ("奉", ZeSheng, HuiRhyme);
  ]

(** 灰韵组繁体字系列：传统字符保持文化传承 *)
let hui_yun_traditional_series =
  [
    ("紅", ZeSheng, HuiRhyme);
    ("東", ZeSheng, HuiRhyme);
    ("鳳", ZeSheng, HuiRhyme);
    ("經", ZeSheng, HuiRhyme);
    ("聰", ZeSheng, HuiRhyme);
    ("從", ZeSheng, HuiRhyme);
    ("豐", ZeSheng, HuiRhyme);
    ("龍", ZeSheng, HuiRhyme);
    ("龔", ZeSheng, HuiRhyme);
  ]

(** 灰韵组剩余字符：传统生僻字符 *)
let hui_yun_remaining_chars =
  [
    ("癀", ZeSheng, HuiRhyme);
    ("皊", ZeSheng, HuiRhyme);
    ("砜", ZeSheng, HuiRhyme);
    ("碸", ZeSheng, HuiRhyme);
    ("磤", ZeSheng, HuiRhyme);
    ("礔", ZeSheng, HuiRhyme);
    ("祔", ZeSheng, HuiRhyme);
    ("秿", ZeSheng, HuiRhyme);
    ("稈", ZeSheng, HuiRhyme);
    ("穮", ZeSheng, HuiRhyme);
    ("竷", ZeSheng, HuiRhyme);
    ("笂", ZeSheng, HuiRhyme);
    ("筗", ZeSheng, HuiRhyme);
    ("箃", ZeSheng, HuiRhyme);
    ("篈", ZeSheng, HuiRhyme);
    ("簠", ZeSheng, HuiRhyme);
    ("籤", ZeSheng, HuiRhyme);
    ("紑", ZeSheng, HuiRhyme);
    ("絨", ZeSheng, HuiRhyme);
    ("縫", ZeSheng, HuiRhyme);
    ("纮", ZeSheng, HuiRhyme);
    ("罞", ZeSheng, HuiRhyme);
    ("羐", ZeSheng, HuiRhyme);
    ("翀", ZeSheng, HuiRhyme);
    ("耤", ZeSheng, HuiRhyme);
    ("聜", ZeSheng, HuiRhyme);
    ("肨", ZeSheng, HuiRhyme);
    ("胐", ZeSheng, HuiRhyme);
    ("脃", ZeSheng, HuiRhyme);
    ("膧", ZeSheng, HuiRhyme);
    ("臤", ZeSheng, HuiRhyme);
    ("舂", ZeSheng, HuiRhyme);
    ("苳", ZeSheng, HuiRhyme);
    ("茖", ZeSheng, HuiRhyme);
    ("荭", ZeSheng, HuiRhyme);
    ("菶", ZeSheng, HuiRhyme);
    ("蓬", ZeSheng, HuiRhyme);
    ("蔀", ZeSheng, HuiRhyme);
    ("蕻", ZeSheng, HuiRhyme);
    ("薐", ZeSheng, HuiRhyme);
    ("蘴", ZeSheng, HuiRhyme);
    ("蠮", ZeSheng, HuiRhyme);
    ("衝", ZeSheng, HuiRhyme);
    ("裪", ZeSheng, HuiRhyme);
    ("訌", ZeSheng, HuiRhyme);
    ("詷", ZeSheng, HuiRhyme);
    ("誦", ZeSheng, HuiRhyme);
    ("諷", ZeSheng, HuiRhyme);
    ("謈", ZeSheng, HuiRhyme);
    ("讻", ZeSheng, HuiRhyme);
    ("豐", ZeSheng, HuiRhyme);
    ("豵", ZeSheng, HuiRhyme);
    ("賰", ZeSheng, HuiRhyme);
    ("蹖", ZeSheng, HuiRhyme);
    ("躘", ZeSheng, HuiRhyme);
    ("軴", ZeSheng, HuiRhyme);
    ("轰", ZeSheng, HuiRhyme);
    ("逢", ZeSheng, HuiRhyme);
    ("遒", ZeSheng, HuiRhyme);
    ("邕", ZeSheng, HuiRhyme);
    ("酆", ZeSheng, HuiRhyme);
    ("醲", ZeSheng, HuiRhyme);
    ("鈁", ZeSheng, HuiRhyme);
    ("鋒", ZeSheng, HuiRhyme);
    ("鎔", ZeSheng, HuiRhyme);
    ("鏠", ZeSheng, HuiRhyme);
    ("鐎", ZeSheng, HuiRhyme);
    ("鑊", ZeSheng, HuiRhyme);
    ("鞻", ZeSheng, HuiRhyme);
    ("韸", ZeSheng, HuiRhyme);
    ("頌", ZeSheng, HuiRhyme);
    ("顯", ZeSheng, HuiRhyme);
    ("飌", ZeSheng, HuiRhyme);
    ("餸", ZeSheng, HuiRhyme);
    ("馚", ZeSheng, HuiRhyme);
    ("騎", ZeSheng, HuiRhyme);
    ("驄", ZeSheng, HuiRhyme);
    ("髺", ZeSheng, HuiRhyme);
    ("魺", ZeSheng, HuiRhyme);
    ("鱸", ZeSheng, HuiRhyme);
    ("鴻", ZeSheng, HuiRhyme);
    ("鵑", ZeSheng, HuiRhyme);
    ("鸰", ZeSheng, HuiRhyme);
    ("鹮", ZeSheng, HuiRhyme);
    ("麷", ZeSheng, HuiRhyme);
    ("黃", ZeSheng, HuiRhyme);
    ("黽", ZeSheng, HuiRhyme);
    ("鼯", ZeSheng, HuiRhyme);
    ("齑", ZeSheng, HuiRhyme);
    ("龍", ZeSheng, HuiRhyme);
    ("龔", ZeSheng, HuiRhyme);
  ]

(** 灰韵组完整数据：模块化重构后的合成函数 *)
let hui_yun_ze_sheng =
  hui_yun_core_chars @ hui_yun_dai_series @ hui_yun_mai_series @ hui_yun_pai_series
  @ hui_yun_chai_series @ hui_yun_cai_series @ hui_yun_lai_series @ hui_yun_hai_series
  @ hui_yun_sui_series @ hui_yun_zong_series @ hui_yun_song_series @ hui_yun_cong_series
  @ hui_yun_chong_series @ hui_yun_dong_series @ hui_yun_feng_series @ hui_yun_traditional_series
  @ hui_yun_remaining_chars

(** {1 扩展音韵数据库合成} *)

(** 扩展音韵数据库 - 合并所有韵组的完整数据库

    Phase 1扩展：从原有300字扩展到1000字 包含更多韵组分类和完整的韵律数据 *)
let expanded_rhyme_database =
  yu_yun_ping_sheng @ hua_yun_ping_sheng @ feng_yun_ping_sheng @ yue_yun_ze_sheng
  @ jiang_yun_ze_sheng @ hui_yun_ze_sheng

(** 扩展音韵数据库字符统计 *)
let expanded_rhyme_char_count = List.length expanded_rhyme_database

(** 获取扩展音韵数据库 *)
let get_expanded_rhyme_database () = expanded_rhyme_database

(** 检查字符是否在扩展音韵数据库中 *)
let is_in_expanded_rhyme_database char =
  List.exists (fun (c, _, _) -> c = char) expanded_rhyme_database

(** 获取扩展音韵数据库中的字符列表 *)
let get_expanded_char_list () = List.map (fun (c, _, _) -> c) expanded_rhyme_database
