(** 韵律集成模块 - 综合分析功能

    此模块整合统一韵律API的各种功能，提供综合性的韵律分析能力。 作为技术债务清理的一部分，统一各种分析接口。

    Author: Alpha, 主要工作代理
    @version 1.0 - 技术债务清理版本
    @since 2025-07-28 - Fix #1576 技术债务清理 *)

open Poetry_core.Poetry_types

type character_analysis = {
  character : string;
  rhyme_category : rhyme_category;
  rhyme_group : rhyme_group;
  rhyme_description : string;
  rhyming_characters : string list;
}
(** 单个字符的韵律分析结果 *)

type comprehensive_analysis_result = {
  text : string;
  character_analyses : character_analysis list;
  rhyme_pattern : (rhyme_category * int) list * (rhyme_group * int) list;
  rhyme_quality_score : float;
  rhyme_scheme : (int * rhyme_group) list;
  overall_consistency : bool;
}
(** 综合韵律分析结果 *)

(** 分析单个字符的韵律信息 *)
let analyze_character char =
  let char_str = String.make 1 char in
  let category = Rhyme_api_core.detect_rhyme_category char_str in
  let group = Rhyme_api_core.detect_rhyme_group char_str in
  let description = Rhyme_api_core.get_rhyme_description char_str in
  let rhyming_chars = Rhyme_api_core.find_rhyming_characters char_str in
  {
    character = char_str;
    rhyme_category = category;
    rhyme_group = group;
    rhyme_description = description;
    rhyming_characters = rhyming_chars;
  }

(** 综合分析文本的韵律特征 *)
let comprehensive_analysis text =
  if String.length text = 0 then
    {
      text = "";
      character_analyses = [];
      rhyme_pattern = ([], []);
      rhyme_quality_score = 0.0;
      rhyme_scheme = [];
      overall_consistency = false;
    }
  else
    let chars = List.init (String.length text) (String.get text) in
    let char_analyses = List.map analyze_character chars in
    let rhyme_pattern = Rhyme_api_core.analyze_rhyme_pattern text in
    let quality_score = Rhyme_api_core.evaluate_rhyme_quality text in

    (* 分析押韵方案 - 简化版本 *)
    let rhyme_scheme = List.mapi (fun i analysis -> (i + 1, analysis.rhyme_group)) char_analyses in

    (* 检查整体一致性 *)
    let char_strings = List.map (fun analysis -> analysis.character) char_analyses in
    let consistency = Rhyme_api_core.validate_rhyme_consistency char_strings in

    {
      text;
      character_analyses = char_analyses;
      rhyme_pattern;
      rhyme_quality_score = quality_score;
      rhyme_scheme;
      overall_consistency = consistency;
    }
