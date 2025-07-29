(** 韵律集成模块接口 - 综合分析功能

    此模块整合统一韵律API的各种功能，提供综合性的韵律分析能力。 作为技术债务清理的一部分，统一各种分析接口。

    Author: Alpha, 主要工作代理
    @version 1.0 - 技术债务清理版本
    @since 2025-07-28 - Fix #1576 技术债务清理 *)

open Poetry_core.Poetry_types

type character_analysis = {
  character : string;  (** 字符本身 *)
  rhyme_category : rhyme_category;  (** 韵类 *)
  rhyme_group : rhyme_group;  (** 韵组 *)
  rhyme_description : string;  (** 韵律描述 *)
  rhyming_characters : string list;  (** 押韵字符列表 *)
}
(** 单个字符的韵律分析结果 *)

type comprehensive_analysis_result = {
  text : string;  (** 原始文本 *)
  character_analyses : character_analysis list;  (** 字符分析列表 *)
  rhyme_pattern : (rhyme_category * int) list * (rhyme_group * int) list;  (** 韵律模式 *)
  rhyme_quality_score : float;  (** 韵律质量评分 *)
  rhyme_scheme : (int * rhyme_group) list;  (** 押韵方案 *)
  overall_consistency : bool;  (** 整体一致性 *)
}
(** 综合韵律分析结果 *)

val analyze_character : char -> character_analysis
(** 分析单个字符的韵律信息
    @param char 要分析的字符
    @return 字符的韵律分析结果 *)

val comprehensive_analysis : string -> comprehensive_analysis_result
(** 综合分析文本的韵律特征
    @param text 要分析的文本
    @return 综合韵律分析结果 *)
