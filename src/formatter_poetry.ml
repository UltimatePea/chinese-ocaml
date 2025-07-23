(** 骆言编译器诗词格式化模块
    
    本模块专注于诗词分析和格式化功能，从unified_formatter.ml中拆分出来。
    提供统一的诗词格式化接口，消除Printf.sprintf依赖。
    
    重构目的：大型模块细化 - Fix #893
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-22 *)

(* 引入基础格式化器，实现零Printf.sprintf依赖 *)
open Utils.Base_formatter

(** 诗词分析格式化 - Phase 3C 扩展 *)
module PoetryFormatting = struct
  (** 诗词评价报告 *)
  let evaluation_report title overall_grade score = 
    concat_strings [ "《"; title; "》评价报告：\n总评："; overall_grade; "（"; float_to_string score; "分）" ]
  
  (** 韵组格式化 *)
  let rhyme_group rhyme_group = concat_strings [ "平声 "; rhyme_group; "韵" ]
  
  (** 字调错误 *)
  let tone_error position char_str needed_tone = 
    concat_strings [ "第"; int_to_string position; "字'"; char_str; "'应为"; needed_tone ]
  
  (** 诗句分析 *)
  let verse_analysis verse_num verse ending_str rhyme_group = 
    concat_strings [ "第"; int_to_string verse_num; "句："; verse; "，韵脚："; ending_str; "，韵组："; rhyme_group ]
  
  (** 诗词结构分析 *)
  let poetry_structure_analysis poem_type expected_lines actual_lines = 
    concat_strings [ 
      poem_type; "结构分析：期望"; int_to_string expected_lines; 
      "句，实际"; int_to_string actual_lines; "句" 
    ]

  (** Phase 3C 新增格式化函数 *)
  
  (** 文本长度信息格式化 *)
  let format_text_length_info length =
    concat_strings [ "文本长度: "; int_to_string length; " 字符\n" ]
  
  (** 分类统计项格式化 *)
  let format_category_count category_name count =
    concat_strings [ "  "; category_name; ": "; int_to_string count; "\n" ]
  
  (** 韵组统计项格式化 *)
  let format_rhyme_group_count group_name count =
    concat_strings [ "  "; group_name; ": "; int_to_string count; "\n" ]
  
  (** 字符查找错误格式化 *)
  let format_character_lookup_error char error_msg =
    concat_strings [ "查找字符「"; char; "」韵律信息时出错: "; error_msg ]
  
  (** 韵律数据统计格式化 *)
  let format_rhyme_data_stats series_count char_count =
    concat_strings [ "韵律数据统计: "; int_to_string series_count; "个系列, "; int_to_string char_count; "个字符" ]
  
  (** 诗词评价详细报告格式化 *)
  let format_evaluation_detailed_report title overall_grade score details =
    concat_strings [ "《"; title; "》评价报告：\n总评："; overall_grade; "（"; float_to_string score; "分）\n详细评分：\n"; details ]
  
  (** 评分维度格式化 *)
  let format_dimension_score dim_name score =
    concat_strings [ "- "; dim_name; "："; float_to_string score; "分" ]
  
  (** 韵律验证错误格式化 *)
  let format_rhyme_validation_error count error_type =
    concat_strings [ "存在 "; int_to_string count; " 个"; error_type ]
  
  (** 缓存管理错误格式化 *)
  let format_cache_duplicate_error char count =
    concat_strings [ "重复字符: "; char; " (出现"; int_to_string count; "次)" ]
  
  (** 数据加载错误格式化 *)
  let format_data_loading_error context error_msg =
    concat_strings [ context; ": "; error_msg ]
  
  (** 字符组查找错误格式化 *)
  let format_group_not_found_error group_name =
    concat_strings [ "字符组 '"; group_name; "' 不存在" ]
  
  (** JSON解析错误格式化 *)
  let format_json_parse_error operation error_msg =
    concat_strings [ operation; ": "; error_msg ]
  
  (** 灰韵组数据统计格式化 *)
  let format_hui_rhyme_stats version total_chars series_count description =
    concat_strings [ 
      "灰韵组数据统计:\n- 版本: "; version; "\n- 总字符数: "; int_to_string total_chars; 
      "\n- 系列数: "; int_to_string series_count; "\n- 描述: "; description
    ]
  
  (** 数据完整性验证格式化 *)
  let format_data_integrity_success count =
    concat_strings [ "✅ 数据完整性验证通过: "; int_to_string count; "个字符" ]
  
  let format_data_integrity_failure expected actual =
    concat_strings [ "❌ 数据完整性验证失败: 期望"; int_to_string expected; "个字符，实际"; int_to_string actual; "个字符" ]
  
  let format_data_integrity_exception error_msg =
    concat_strings [ "❌ 数据完整性验证异常: "; error_msg ]
end

(** 古典诗词格式化 *)
module ClassicalFormatting = struct
  (** 律诗格式化 *)
  let format_regulated_verse poem_title author verses =
    let header = concat_strings [ "《"; poem_title; "》 - "; author ] in
    let formatted_verses = List.mapi (fun i verse -> 
      concat_strings [ int_to_string (i + 1); ". "; verse ]) verses in
    join_with_separator "\n" (header :: formatted_verses)

  (** 绝句格式化 *)
  let format_quatrain poem_title author verses =
    let header = concat_strings [ "《"; poem_title; "》 绝句 - "; author ] in
    let formatted_verses = List.mapi (fun i verse -> 
      concat_strings [ int_to_string (i + 1); ". "; verse ]) verses in
    join_with_separator "\n" (header :: formatted_verses)

  (** 词牌格式化 *)
  let format_ci_poem ci_pai_name poem_title author stanzas =
    let header = concat_strings [ "《"; poem_title; "》 "; ci_pai_name; " - "; author ] in
    let formatted_stanzas = List.mapi (fun i stanza ->
      let stanza_header = concat_strings [ "第"; int_to_string (i + 1); "阙:" ] in
      let formatted_lines = List.map (fun line -> concat_strings [ "  "; line ]) stanza in
      join_with_separator "\n" (stanza_header :: formatted_lines)) stanzas in
    join_with_separator "\n\n" (header :: formatted_stanzas)

  (** 韵律分析格式化 *)
  let format_prosody_analysis verses rhyme_scheme tone_pattern =
    let rhyme_info = concat_strings [ "韵律: "; rhyme_scheme ] in
    let tone_info = concat_strings [ "平仄: "; tone_pattern ] in
    let verse_analysis = List.mapi (fun i verse ->
      concat_strings [ "第"; int_to_string (i + 1); "句: "; verse ]) verses in
    join_with_separator "\n" (rhyme_info :: tone_info :: verse_analysis)

  (** 对仗分析 *)
  let format_parallelism_analysis couplets =
    let header = "对仗分析:" in
    let formatted_couplets = List.mapi (fun i (line1, line2) ->
      concat_strings [ 
        "第"; int_to_string (i + 1); "联:\n";
        "  出句: "; line1; "\n";
        "  对句: "; line2
      ]) couplets in
    join_with_separator "\n\n" (header :: formatted_couplets)
end

(** 古雅体格式化 *)
module AncientStyleFormatting = struct
  (** 文言文格式化 *)
  let format_classical_chinese title content annotations =
    let header = concat_strings [ "《"; title; "》" ] in
    let main_text = content in
    if List.length annotations > 0 then
      let annotation_section = "注释:" in
      let formatted_annotations = List.mapi (fun i note ->
        concat_strings [ int_to_string (i + 1); ". "; note ]) annotations in
      join_with_separator "\n" (header :: main_text :: annotation_section :: formatted_annotations)
    else
      join_with_separator "\n" [header; main_text]

  (** 古体诗格式化 *)
  let format_ancient_verse poem_title verses style_notes =
    let header = concat_strings [ "《"; poem_title; "》 古体诗" ] in
    let numbered_verses = List.mapi (fun i verse ->
      concat_strings [ int_to_string (i + 1); ". "; verse ]) verses in
    let style_section = if List.length style_notes > 0 then
      ["体式注:"] @ List.map (fun note -> concat_strings [ "- "; note ]) style_notes
    else [] in
    join_with_separator "\n" (header :: numbered_verses @ style_section)

  (** 骈体文格式化 *)
  let format_parallel_prose title paragraphs =
    let header = concat_strings [ "《"; title; "》 骈体文" ] in
    let formatted_paragraphs = List.mapi (fun i para ->
      concat_strings [ "第"; int_to_string (i + 1); "段:\n"; para ]) paragraphs in
    join_with_separator "\n\n" (header :: formatted_paragraphs)

  (** 辞赋格式化 *)
  let format_fu_poem title author sections =
    let header = concat_strings [ "《"; title; "》 辞赋 - "; author ] in
    let formatted_sections = List.map (fun (section_name, content) ->
      concat_strings [ section_name; ":\n"; content ]) sections in
    join_with_separator "\n\n" (header :: formatted_sections)
end

(** 诗词分析工具 *)
module PoetryAnalysisTools = struct
  (** 字符统计 *)
  let format_character_frequency chars_with_counts =
    let header = "字符频率统计:" in
    let sorted_chars = List.sort (fun (_, c1) (_, c2) -> compare c2 c1) chars_with_counts in
    let formatted_items = List.map (fun (char, count) ->
      concat_strings [ "  "; char; ": "; int_to_string count; "次" ]) sorted_chars in
    join_with_separator "\n" (header :: formatted_items)

  (** 韵律模式分析 *)
  let format_rhyme_pattern_analysis patterns =
    let header = "韵律模式分析:" in
    let formatted_patterns = List.mapi (fun i pattern ->
      concat_strings [ int_to_string (i + 1); ". "; pattern ]) patterns in
    join_with_separator "\n" (header :: formatted_patterns)

  (** 声律检查报告 *)
  let format_prosody_check_report violations corrections =
    let violation_section = if List.length violations > 0 then
      let header = "声律违例:" in
      let formatted_violations = List.map (fun violation ->
        concat_strings [ "- "; violation ]) violations in
      header :: formatted_violations
    else ["声律检查: 无违例"] in
    
    let correction_section = if List.length corrections > 0 then
      let header = "修正建议:" in
      let formatted_corrections = List.map (fun correction ->
        concat_strings [ "- "; correction ]) corrections in
      header :: formatted_corrections
    else [] in
    
    join_with_separator "\n" (violation_section @ correction_section)

  (** 风格分析报告 *)
  let format_style_analysis_report poem_title style_features similarity_scores =
    let header = concat_strings [ "《"; poem_title; "》风格分析报告" ] in
    
    let features_section = "风格特征:" in
    let formatted_features = List.map (fun feature ->
      concat_strings [ "- "; feature ]) style_features in
    
    let similarity_section = "相似度评分:" in
    let formatted_similarities = List.map (fun (poet_name, score) ->
      concat_strings [ "- "; poet_name; ": "; float_to_string score ]) similarity_scores in
    
    join_with_separator "\n" (header :: features_section :: formatted_features @ 
                              similarity_section :: formatted_similarities)

  (** 主题词汇分析 *)
  let format_thematic_vocabulary_analysis themes =
    let header = "主题词汇分析:" in
    let formatted_themes = List.map (fun (theme_name, words) ->
      let word_list = join_with_separator "、" words in
      concat_strings [ "- "; theme_name; ": "; word_list ]) themes in
    join_with_separator "\n" (header :: formatted_themes)
end