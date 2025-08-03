(** 韵律模块统一类型定义
    
    本模块整合了所有韵律相关的类型定义，统一了原本分散在多个文件中的类型。
    这是Issue #1999韵律模块整合的核心类型基础。
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施
    
    整合来源:
    - Poetry_core.Rhyme_core_types
    - 各个rhyme_data模块的类型定义
    - 统一了重复和冲突的类型定义
    
    @since 2025-08-03 *)

(** {1 基础韵律类型} *)

(** 声调类型 - 基于传统四声系统 *)
type tone_category = 
  | PingSheng    (** 平声：第一、二声 *)
  | ShangSheng   (** 上声：第三声 *)
  | QuSheng      (** 去声：第四声 *)
  | RuSheng      (** 入声：古代汉语特有 *)

(** 韵组枚举 - 基于《平水韵》韵组体系 *)
type rhyme_group = 
  | AnRhyme      (** 安韵：山、间、关等 *)
  | SiRhyme      (** 思韵：思、师、时等 *)
  | TianRhyme    (** 天韵：天、年、先等 *)
  | WangRhyme    (** 王韵：王、香、方等 *)
  | QuRhyme      (** 去韵：去、数、路等 *)
  | YuRhyme      (** 鱼韵：鱼、书、居等 *)
  | HuaRhyme     (** 花韵：花、家、霞等 *)
  | FengRhyme    (** 风韵：风、东、中等 *)
  | YueRhyme     (** 月韵：月、雪、节等 *)
  | JiangRhyme   (** 江韵：江、窗、床等 *)
  | HuiRhyme     (** 灰韵：灰、开、来等 *)
  | UnknownRhyme (** 未知韵组 *)

(** 韵律字符信息 - 整合了原有的多种字符表示 *)
type rhyme_character = {
  character: string;              (** 字符本身 *)
  tone: tone_category;            (** 声调类别 *)
  rhyme_group: rhyme_group;       (** 所属韵组 *)
  variants: string list;          (** 异体字变体列表 *)
  usage_frequency: float;         (** 使用频率 0.0-1.0 *)
  is_common: bool;                (** 是否为常用字 *)
  pinyin: string option;          (** 拼音（可选） *)
}

(** 韵组数据结构 - 统一的韵组信息表示 *)
type rhyme_group_data = {
  group_id: rhyme_group;          (** 韵组标识 *)
  group_name: string;             (** 韵组名称 *)
  description: string;            (** 韵组描述 *)
  ping_sheng_chars: string list;  (** 平声字符列表 *)
  ze_sheng_chars: string list;    (** 仄声字符列表 *)
  all_characters: rhyme_character list; (** 完整字符数据 *)
  example_poems: string list;     (** 示例诗句 *)
}

(** 韵律查询结果 *)
type query_result = 
  | Found of rhyme_character      (** 找到匹配 *)
  | NotFound of string           (** 未找到，返回查询字符 *)
  | MultipleMatches of rhyme_character list (** 多个匹配（异体字等） *)

(** 韵律统计信息 *)
type rhyme_statistics = {
  total_characters: int;          (** 总字符数 *)
  total_groups: int;              (** 总韵组数 *)
  ping_sheng_count: int;          (** 平声字符数 *)
  ze_sheng_count: int;            (** 仄声字符数（上去入） *)
  group_distribution: (rhyme_group * int) list; (** 各韵组字符分布 *)
  most_frequent_group: rhyme_group; (** 字符最多的韵组 *)
  least_frequent_group: rhyme_group; (** 字符最少的韵组 *)
}

(** {1 辅助类型和函数} *)

(** 韵组到字符串的映射 *)
let string_of_rhyme_group = function
  | AnRhyme -> "安韵"
  | SiRhyme -> "思韵"
  | TianRhyme -> "天韵"
  | WangRhyme -> "王韵"
  | QuRhyme -> "去韵"
  | YuRhyme -> "鱼韵"
  | HuaRhyme -> "花韵"
  | FengRhyme -> "风韵"
  | YueRhyme -> "月韵"
  | JiangRhyme -> "江韵"
  | HuiRhyme -> "灰韵"
  | UnknownRhyme -> "未知韵组"

(** 声调到字符串的映射 *)
let string_of_tone_category = function
  | PingSheng -> "平声"
  | ShangSheng -> "上声"
  | QuSheng -> "去声"
  | RuSheng -> "入声"

(** 判断是否为仄声 *)
let is_ze_sheng = function
  | ShangSheng | QuSheng | RuSheng -> true
  | PingSheng -> false

(** 获取所有韵组列表 *)
let all_rhyme_groups = [
  AnRhyme; SiRhyme; TianRhyme; WangRhyme; QuRhyme; 
  YuRhyme; HuaRhyme; FengRhyme; YueRhyme; JiangRhyme; HuiRhyme
]

(** 获取所有声调类别 *)
let all_tone_categories = [PingSheng; ShangSheng; QuSheng; RuSheng]

(** 创建韵律字符的辅助函数 *)
let make_rhyme_character ?(variants=[]) ?(usage_freq=1.0) ?(is_common=true) 
                         ?(pinyin=None) char tone group =
  {
    character = char;
    tone = tone;
    rhyme_group = group;
    variants = variants;
    usage_frequency = usage_freq;
    is_common = is_common;
    pinyin = pinyin;
  }

(** 创建简单平声字符 *)
let make_ping_char char group = 
  make_rhyme_character char PingSheng group

(** 创建简单仄声字符（默认为去声） *)
let make_ze_char char group = 
  make_rhyme_character char QuSheng group