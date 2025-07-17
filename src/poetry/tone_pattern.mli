(** 平仄检测模块接口 - 骆言诗词编程特性

    本模块提供了古典诗词编程中的平仄检测功能，包括声调分析、平仄模式验证、
    不同诗体的平仄规则检查等核心功能。支持七言绝句、五言律诗、四言骈体等传统诗体。
 *)

(** 引用声调数据模块中的类型定义

    声调类型现在定义在Tone_data模块中，提供更好的模块化结构。
 *)
open Tone_data

(** 声调分析报告类型

    包含单个诗句的完整声调分析信息，包括原诗句、声调序列、简化平仄模式、
    模式匹配结果以及改进建议。
 *)
type tone_analysis_report = {
  verse : string;
  tone_sequence : tone_type list;
  simple_pattern : bool list;
  pattern_match : bool;
  suggestions : string list;
}

(** 检测字符的声调

    根据中古汉语声调系统，检测字符的声调类型。

    @param char 要检测的字符
    @return 字符的声调类型
 *)
val detect_tone : char -> tone_type

(** 检测字符是否为平声

    判断字符是否为平声字。

    @param char 要检测的字符
    @return 是否为平声
 *)
val is_level_tone : char -> bool

(** 检测字符是否为仄声

    判断字符是否为仄声字（包括上声、去声、入声）。

    @param char 要检测的字符
    @return 是否为仄声
 *)
val is_oblique_tone : char -> bool

(** 分析字符串的声调序列

    对诗句中的每个字符进行声调分析，返回声调序列。

    @param string 诗句字符串
    @return 声调序列
 *)
val analyze_tone_sequence : string -> tone_type list

(** 分析简化平仄模式

    将诗句的声调序列简化为平仄模式（true表示平声，false表示仄声）。

    @param string 诗句字符串
    @return 平仄模式列表
 *)
val analyze_simple_tone_pattern : string -> bool list

(** 验证平仄模式

    检查诗句的平仄模式是否符合指定的模式。

    @param string 诗句字符串
    @param bool list 目标平仄模式
    @return 是否匹配
 *)
val validate_tone_pattern : string -> bool list -> bool

(** 验证七言绝句的平仄

    检查四句七言绝句的平仄是否符合传统规则。

    @param string list 四句七言绝句
    @return 是否符合平仄规则
 *)
val validate_qijue_tone_pattern : string list -> bool

(** 验证五言律诗的平仄

    检查八句五言律诗的平仄是否符合传统规则。

    @param string list 八句五言律诗
    @return 是否符合平仄规则
 *)
val validate_wuyan_tone_pattern : string list -> bool

(** 验证四言骈体的平仄

    检查四言骈体的平仄是否符合传统规则。

    @param string list 四言骈体诗句
    @return 是否符合平仄规则
 *)
val validate_siyan_tone_pattern : string list -> bool

(** 生成声调分析报告

    为单个诗句生成完整的声调分析报告。

    @param string 诗句字符串
    @param bool list 目标平仄模式
    @return 声调分析报告
 *)
val generate_tone_report : string -> bool list -> tone_analysis_report

(** 建议平仄改进

    根据诗句的平仄模式和目标模式，提供改进建议。

    @param string 诗句字符串
    @param bool list 目标平仄模式
    @return 改进建议列表
 *)
val suggest_tone_improvements : string -> bool list -> string list

(** 获取适合的字符建议

    根据指定的声调类型，建议可用的字符列表。

    @param tone_type 声调类型
    @return 字符建议列表
 *)
val get_tone_character_suggestions : tone_type -> string list
