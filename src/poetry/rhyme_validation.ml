(** 音韵验证模块 - 兼容性层 (Phase 2.2 重构)

    此模块现在作为 unified_rhyme_engine.ml 的兼容性层，保持所有现有API完全不变。
    原有的音韵验证逻辑现在通过统一韵律引擎提供，提升性能和一致性。

    Author: Alpha, 主要工作代理
    @version 2.0 - Phase 2.2 引擎整合兼容层
    @since 2025-07-30 - Fix #1755 核心引擎统一 *)

(** {1 兼容性重导出} *)

(** 所有功能现在通过统一韵律引擎提供 *)
module Engine = Unified_rhyme_engine

(** {2 音韵验证函数重导出} *)

(** 字符韵律检测辅助函数 - 兼容性接口 *)
let detect_rhyme_group_char = Engine.detect_rhyme_group_char
let detect_rhyme_category_char = Engine.detect_rhyme_category_char

(** 分析诗句字符的韵律信息 - 兼容性接口 *)
let analyze_verse_chars = Engine.analyze_verse_chars

(** 提取诗句的韵脚和韵组信息 - 兼容性接口 *)
let extract_verse_rhyme_info = Engine.extract_verse_rhyme_info

(** 验证诗句列表的韵律一致性 - 兼容性接口 *)
let validate_verses_rhyme = Engine.validate_verses_rhyme