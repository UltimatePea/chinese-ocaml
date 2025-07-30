(** 音韵匹配算法模块 - 兼容性层 (Phase 2.2 重构)

    此模块现在作为 unified_rhyme_engine.ml 的兼容性层，保持所有现有API完全不变。 原有的音韵匹配算法现在通过统一韵律引擎提供，消除重复实现。

    Author: Alpha, 主要工作代理
    @version 2.0 - Phase 2.2 引擎整合兼容层
    @since 2025-07-30 - Fix #1755 核心引擎统一 *)

(** {1 兼容性重导出} *)

module Engine = Unified_rhyme_engine
(** 所有功能现在通过统一韵律引擎提供 *)

(** {2 音韵匹配函数重导出} *)

(** 寻韵察音：从数据库中查找字符的韵母信息 - 兼容性接口 *)
let find_rhyme_info char =
  let char_str = String.make 1 char in
  Engine.find_rhyme_info char_str

(** 辨音识韵：检测字符的韵母分类 - 兼容性接口 *)
let detect_rhyme_category char = Engine.detect_rhyme_category_char char

let detect_rhyme_category_by_string char_str = Engine.detect_rhyme_category_by_string char_str

(** 检测字符的韵组 - 兼容性接口 *)
let detect_rhyme_group char = Engine.detect_rhyme_group_char char

(** 检查韵律匹配 - 兼容性接口 *)
let check_rhyme_match char1 char2 =
  let str1 = String.make 1 char1 in
  let str2 = String.make 1 char2 in
  Engine.check_rhyme_match str1 str2

(** 检查两个字符是否押韵 - 兼容性接口别名 *)
let chars_rhyme = check_rhyme_match

(** 建议韵脚字符 - 兼容性接口 *)
let suggest_rhyme_characters group = Engine.get_rhyme_characters group
