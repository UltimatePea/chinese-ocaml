(** 韵律API核心模块 - 兼容性层 (Phase 2.2 重构)

    此模块现在作为 unified_rhyme_engine.ml 的兼容性层，保持所有现有API完全不变。
    原有的核心API函数现在通过统一韵律引擎提供，实现更好的性能和维护性。

    Author: Alpha, 主要工作代理
    @version 2.0 - Phase 2.2 引擎整合兼容层
    @since 2025-07-30 - Fix #1755 核心引擎统一 *)

(** {1 兼容性重导出} *)

(** 所有功能现在通过统一韵律引擎提供 *)
module Engine = Unified_rhyme_engine

(** {2 核心API函数重导出} *)

(** 查找字符的韵律信息 - 兼容性接口 *)
let find_rhyme_info = Engine.find_rhyme_info

(** 检测字符的韵类 - 兼容性接口 *)
let detect_rhyme_category = Engine.detect_rhyme_category

(** 检测字符的韵组 - 兼容性接口 *)
let detect_rhyme_group = Engine.detect_rhyme_group

(** 获取韵组包含的所有字符 - 兼容性接口 *)
let get_rhyme_characters = Engine.get_rhyme_characters

(** 附加兼容性函数 *)
let generate_rhyme_report = Engine.generate_rhyme_report
let detect_rhyme_category_by_string = Engine.detect_rhyme_category_by_string
let find_rhyming_characters = Engine.find_rhyming_characters
let check_rhyme = Engine.check_rhyme