(** 音韵检测模块 - 骆言诗词编程特性

    盖古之诗者，音韵为要。声韵调谐，方称佳构。 此模块专司音韵检测分析，提供韵脚提取、声调分类、押韵检测等功能。 凡诗词编程，必先辨音识韵，方能把握诗律。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-17 *)

open Rhyme_types

(** {1 韵律摘要类型} *)

type verse_summary = {
  verse : string;  (** 标准化后的诗句字符串 *)
  ending_info : (char * rhyme_category * rhyme_group) option;  (** 韵脚信息 *)
  char_analysis : (char * rhyme_category * rhyme_group) list;  (** 字符分析列表 *)
  is_ping_sheng : bool;  (** 是否为平声韵 *)
  is_ze_sheng : bool;  (** 是否为仄声韵 *)
  char_count : int;  (** 字符数量 *)
}
(** 韵律摘要类型

    包含诗句完整韵律分析的记录类型。 *)

(** {1 基础检测函数} *)

val find_rhyme_info : char -> (rhyme_category * rhyme_group) option
(** 寻韵察音 - 从数据库中查找字符的韵母信息
    
    @param char 待查找的字符
    @return 韵母分类和韵组的选项值；找不到返回None
    
    @example [find_rhyme_info '山'] 返回 [Some (PingSheng, AnRhyme)]
*)

val find_rhyme_info_by_string : string -> (rhyme_category * rhyme_group) option
(** 按字符串查找韵母信息
    
    @param string 待查找的字符串（应为单个字符）
    @return 韵母分类和韵组的选项值；找不到返回None
    
    @example [find_rhyme_info_by_string "山"] 返回 [Some (PingSheng, AnRhyme)]
*)

val detect_rhyme_category : char -> rhyme_category
(** 辨音识韵 - 检测字符的韵母分类
    
    @param char 待检测的字符
    @return 字符的声调分类；找不到时默认返回平声
    
    @example [detect_rhyme_category '山'] 返回 [PingSheng]
*)

val detect_rhyme_category_by_string : string -> rhyme_category
(** 按字符串检测韵母分类

    @param string 待检测的字符串（应为单个字符）
    @return 字符的声调分类；找不到时默认返回平声 *)

val detect_rhyme_group : char -> rhyme_group
(** 归类成组 - 检测字符的韵组
    
    @param char 待检测的字符
    @return 字符所属的韵组；找不到时返回UnknownRhyme
    
    @example [detect_rhyme_group '山'] 返回 [AnRhyme]
*)

val detect_rhyme_group_by_string : string -> rhyme_group
(** 按字符串检测韵组

    @param string 待检测的字符串（应为单个字符）
    @return 字符所属的韵组；找不到时返回UnknownRhyme *)

(** {1 韵脚提取函数} *)

val extract_rhyme_ending : string -> char option
(** 提取韵脚 - 从字符串中提取韵脚字符
    
    @param string 输入字符串
    @return 句末字符作为韵脚；空字符串返回None
    
    @example [extract_rhyme_ending "春山月"] 返回 [Some '月']
*)

val extract_rhyme_ending_string : string -> string option
(** 提取韵脚字符串
    
    @param string 输入字符串
    @return 句末字符串作为韵脚；空字符串返回None
    
    @example [extract_rhyme_ending_string "春山月"] 返回 [Some "月"]
*)

val detect_verse_rhyme_info : string -> (char * rhyme_category * rhyme_group) option
(** 检测诗句的韵脚信息
    
    @param string 诗句字符串
    @return 韵脚字符及其韵母分类和韵组信息
    
    @example [detect_verse_rhyme_info "春山月"] 返回 [Some ('月', RuSheng, QuRhyme)]
*)

(** {1 韵类判断函数} *)

val is_ping_sheng_verse : string -> bool
(** 检测诗句是否为平声韵
    
    @param string 诗句字符串
    @return 韵脚为平声则返回true，否则返回false
    
    @example [is_ping_sheng_verse "春山"] 返回 [true]
*)

val is_ze_sheng_verse : string -> bool
(** 检测诗句是否为仄声韵
    
    仄声韵包括上声、去声、入声，与平声相对。
    
    @param string 诗句字符串
    @return 韵脚为仄声则返回true，否则返回false
    
    @example [is_ze_sheng_verse "春月"] 返回 [true]
*)

(** {1 押韵检测函数} *)

val same_rhyme_group : char -> char -> bool
(** 检测两个字符是否同韵组
    
    @param char1 第一个字符
    @param char2 第二个字符
    @return 属于同一韵组则返回true，否则返回false
    
    @example [same_rhyme_group '山' '间'] 返回 [true]
*)

val same_rhyme_group_string : string -> string -> bool
(** 检测两个字符串是否同韵组

    @param string1 第一个字符串
    @param string2 第二个字符串
    @return 属于同一韵组则返回true，否则返回false *)

val verses_rhyme : string -> string -> bool
(** 检测两个诗句是否押韵
    
    通过比较两个诗句的韵脚是否同韵组来判断是否押韵。
    
    @param verse1 第一个诗句
    @param verse2 第二个诗句
    @return 押韵则返回true，否则返回false
    
    @example [verses_rhyme "春山" "闲"] 返回 [true]
*)

(** {1 韵律分析函数} *)

val analyze_verse_chars : string -> (char * rhyme_category * rhyme_group) list
(** 分析诗句中所有字符的韵律信息
    
    @param string 诗句字符串
    @return 诗句中每个字符的韵律分析结果列表
    
    @example [analyze_verse_chars "春山"] 返回 [包含每个字符韵律信息的列表]
*)

val detect_verse_pattern : string -> (char * bool) list
(** 检测诗句的韵律模式
    
    @param string 诗句字符串
    @return 诗句中每个字符及其是否为平声的信息
    
    @example [detect_verse_pattern "春山"] 返回 [('春', true); ('山', true)]
*)

val generate_verse_summary : string -> verse_summary
(** 生成诗句的韵律摘要
    
    @param string 诗句字符串
    @return 包含诗句完整韵律分析的记录
    
    @example [generate_verse_summary "春山"] 返回包含完整韵律分析的记录
*)
