(** 韵律引擎模块 - 统一引擎接口
    
    此模块提供统一的韵律引擎功能，支持技术债务清理过程中的回归测试。
    作为过渡模块，将现有的引擎功能封装为统一接口。
    
    Author: Alpha, 主要工作代理
    @version 1.0 - 技术债务清理版本
    @since 2025-07-28 - Fix #1576 技术债务清理 *)

open Poetry_core.Rhyme_core_types

(** 检查两个字符是否押韵 *)
let check_rhyme_match char1 char2 =
  Unified_rhyme_api.check_rhyme char1 char2

(** 分析文本的韵律模式 *)
let analyze_pattern text =
  Unified_rhyme_api.analyze_rhyme_pattern text

(** 评估韵律质量 *)
let evaluate_quality text =
  Unified_rhyme_api.evaluate_rhyme_quality text

(** 检测押韵方案 *)
let detect_scheme lines =
  Unified_rhyme_api.detect_poem_rhyme_scheme lines

(** 建议押韵字符 *)
let suggest_rhyming_chars reference_char exclude_chars =
  Unified_rhyme_api.suggest_rhyming_chars reference_char exclude_chars