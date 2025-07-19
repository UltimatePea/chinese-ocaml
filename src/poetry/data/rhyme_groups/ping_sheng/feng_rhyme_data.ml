(** 风韵组数据模块 - 骆言诗词编程特性
    
    风送中东，秋风萧瑟意无穷。风韵组包含"风、送、中、东"等字符，
    依《平水韵》传统分类，属平声韵，意境壮阔豪放，为诗词创作提供飘逸豪迈的韵律选择。
    
    @author 骆言诗词编程团队
    @version 1.0  
    @since 2025-07-19 - Phase 14.3 模块化重构 *)

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

(** {1 风韵组核心字符数据} *)

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

(** {1 风韵组数据合成} *)

(** 风韵组平声韵数据 - 完整的风韵平声韵数据 *)
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

(** {1 公共接口} *)

(** 获取风韵组的所有数据
    
    @return 风韵组的完整韵律数据列表 *)
let get_all_data () = feng_yun_ping_sheng

(** 获取风韵组字符数量统计
    
    @return 风韵组包含的字符总数 *)
let get_char_count () = List.length feng_yun_ping_sheng

(** 导出数据供外部模块使用 *)
let () = ()