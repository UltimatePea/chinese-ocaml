(** 月韵组数据模块 - 骆言诗词编程特性
    
    月雪节切，秋月如霜韵味深。月韵组包含"月、雪、节、切"等字符，
    依《平水韵》传统分类，属仄声韵，意境清雅深远，为诗词创作提供含蓄深沉的韵律选择。
    
    @author 骆言诗词编程团队
    @version 1.0  
    @since 2025-07-19 - Phase 14.3 模块化重构 *)

(** 使用统一的韵律类型定义 - 保持与主模块兼容 *)
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

(** {1 月韵组核心字符数据} *)

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

(** {1 月韵组数据合成} *)

(** 月韵组仄声韵数据 - 完整的月韵仄声韵数据 *)
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

(** {1 公共接口} *)

(** 获取月韵组的所有数据
    
    @return 月韵组的完整韵律数据列表 *)
let get_all_data () = yue_yun_ze_sheng

(** 获取月韵组字符数量统计
    
    @return 月韵组包含的字符总数 *)
let get_char_count () = List.length yue_yun_ze_sheng

(** 导出数据供外部模块使用 *)
let () = ()