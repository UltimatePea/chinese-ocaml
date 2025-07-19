(** 风韵组数据模块接口 - 骆言诗词编程特性
    
    风送中东，秋风萧瑟意无穷。风韵组提供壮阔豪放的韵律字符数据，
    依《平水韵》传统分类，属平声韵，为诗词创作提供标准的韵律支持。 *)

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
val feng_yun_basic_chars : (string * rhyme_category * rhyme_group) list

(** 风韵充冲组 - 充冲虫崇等字 *)
val feng_yun_chong_group : (string * rhyme_category * rhyme_group) list

(** 风韵松宋组 - 松宋颂等字 *)
val feng_yun_song_group : (string * rhyme_category * rhyme_group) list

(** 风韵同童组 - 同童通等字 *)
val feng_yun_tong_group : (string * rhyme_category * rhyme_group) list

(** 风韵迭叠组 - 迭叠蝶等字 *)
val feng_yun_die_group : (string * rhyme_category * rhyme_group) list

(** 风韵年念组 - 年念捻等字 *)
val feng_yun_nian_group : (string * rhyme_category * rhyme_group) list

(** 风韵连恋组 - 连恋莲等字 *)
val feng_yun_lian_group : (string * rhyme_category * rhyme_group) list

(** 风韵猎烈组 - 猎烈列等字 *)
val feng_yun_lie_group : (string * rhyme_category * rhyme_group) list

(** 风韵厉励组 - 厉励礼李等字 *)
val feng_yun_li_group : (string * rhyme_category * rhyme_group) list

(** 风韵鱼类字组 - 各种鱼类名称 *)
val feng_yun_fish_group : (string * rhyme_category * rhyme_group) list

(** {1 风韵组数据合成} *)

(** 风韵组平声韵数据 - 完整的风韵平声韵数据 *)
val feng_yun_ping_sheng : (string * rhyme_category * rhyme_group) list

(** {1 公共接口} *)

(** 获取风韵组的所有数据
    
    @return 风韵组的完整韵律数据列表 *)
val get_all_data : unit -> (string * rhyme_category * rhyme_group) list

(** 获取风韵组字符数量统计
    
    @return 风韵组包含的字符总数 *)
val get_char_count : unit -> int