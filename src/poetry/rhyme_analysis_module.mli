(** 韵律分析模块接口 - 统一分析接口
    
    此模块提供统一的韵律分析功能，支持技术债务清理过程中的回归测试。
    作为过渡模块，将现有的分析功能封装为统一接口。
    
    Author: Alpha, 主要工作代理
    @version 1.0 - 技术债务清理版本
    @since 2025-07-28 - Fix #1576 技术债务清理 *)

open Rhyme_types
open Rhyme_integration_module

(** 查找字符の韵组
    @param char 要分析的字符
    @return 韵组 *)
val find_rhyme_group : string -> rhyme_group

(** 分析字符的韵律信息
    @param char 要分析的字符
    @return 韵律信息，如果找不到则返回None *)
val analyze_character : string -> character_analysis option

(** 检查两个字符是否押韵
    @param char1 第一个字符
    @param char2 第二个字符
    @return 是否押韵 *)
val check_rhyme_match : string -> string -> bool

(** 获取韵组包含的字符列表
    @param group 韵组
    @return 字符列表 *)
val get_group_characters : rhyme_group -> string list

(** 验证字符列表的韵律一致性
    @param chars 字符列表
    @return 是否一致 *)
val validate_consistency : string list -> bool