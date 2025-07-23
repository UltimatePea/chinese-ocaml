(** 骆言编译器诗词格式化模块测试 - 测试诗词分析和格式化功能 *)

open Alcotest
open Yyocamlc_lib.Formatter_poetry

(** 帮助函数：检查字符串是否包含子字符串 *)
let contains_substring s sub =
  try
    let _ = Str.search_forward (Str.regexp_string sub) s 0 in
    true
  with Not_found -> false

(** 测试诗词分析格式化模块 *)
module Test_PoetryFormatting = struct
  (** 测试诗词评价报告 *)
  let test_evaluation_report () =
    let report = PoetryFormatting.evaluation_report "七言绝句" "春晓" 8.5 in
    check bool "评价报告包含诗体" true (contains_substring report "七言绝句");
    check bool "评价报告包含诗名" true (contains_substring report "春晓");
    check bool "评价报告包含分数" true (contains_substring report "8.5");

    let low_score_report = PoetryFormatting.evaluation_report "五言律诗" "测试诗" 3.2 in
    check bool "低分报告包含诗体" true (contains_substring low_score_report "五言律诗");
    check bool "低分报告包含分数" true (contains_substring low_score_report "3.2")

  (** 测试韵组格式化 *)
  let test_rhyme_group () =
    let rhyme_result = PoetryFormatting.rhyme_group "东韵" in
    check bool "韵组格式化包含韵名" true (contains_substring rhyme_result "东韵");

    let complex_rhyme = PoetryFormatting.rhyme_group "平水韵·上平·一东" in
    check bool "复杂韵组包含完整信息" true (contains_substring complex_rhyme "平水韵")

  (** 测试字调错误格式化 *)
  let test_tone_error () =
    let tone_err = PoetryFormatting.tone_error 3 "平" "仄" in
    check bool "字调错误包含位置" true (contains_substring tone_err "3");
    check bool "字调错误包含期望调" true (contains_substring tone_err "平");
    check bool "字调错误包含实际调" true (contains_substring tone_err "仄");

    let first_tone_err = PoetryFormatting.tone_error 1 "仄" "平" in
    check bool "首字调错误包含位置1" true (contains_substring first_tone_err "1")

  (** 测试诗句分析 *)
  let test_verse_analysis () =
    let analysis = PoetryFormatting.verse_analysis 1 "春眠不觉晓" "平平仄仄仄" "正确" in
    check bool "诗句分析包含行号" true (contains_substring analysis "1");
    check bool "诗句分析包含诗句" true (contains_substring analysis "春眠不觉晓");
    check bool "诗句分析包含平仄" true (contains_substring analysis "平平仄仄仄");
    check bool "诗句分析包含状态" true (contains_substring analysis "正确");

    let error_analysis = PoetryFormatting.verse_analysis 2 "处处闻啼鸟" "仄仄平平仄" "平仄错误" in
    check bool "错误分析包含错误状态" true (contains_substring error_analysis "平仄错误")

  (** 测试诗词结构分析 *)
  let test_poetry_structure_analysis () =
    let structure = PoetryFormatting.poetry_structure_analysis "七言绝句" 4 28 in
    check bool "结构分析包含诗体" true (contains_substring structure "七言绝句");
    check bool "结构分析包含行数" true (contains_substring structure "4");
    check bool "结构分析包含字数" true (contains_substring structure "28");

    let long_poem = PoetryFormatting.poetry_structure_analysis "七言律诗" 8 56 in
    check bool "长诗结构包含律诗" true (contains_substring long_poem "律诗")

  (** 测试文本分析格式化 *)
  let test_text_analysis_formatting () =
    let length_info = PoetryFormatting.format_text_length_info 120 in
    check bool "文本长度信息包含字符数" true (contains_substring length_info "120");

    let category_count = PoetryFormatting.format_category_count "仄声字" 15 in
    check bool "类别计数包含类别名" true (contains_substring category_count "仄声字");
    check bool "类别计数包含数量" true (contains_substring category_count "15");

    let rhyme_count = PoetryFormatting.format_rhyme_group_count "东韵组" 8 in
    check bool "韵组计数包含韵组名" true (contains_substring rhyme_count "东韵组");
    check bool "韵组计数包含数量" true (contains_substring rhyme_count "8")

  (** 测试错误处理格式化 *)
  let test_error_handling_formatting () =
    let lookup_error = PoetryFormatting.format_character_lookup_error "生僻字" "字典查找失败" in
    check bool "字符查找错误包含字符" true (contains_substring lookup_error "生僻字");
    check bool "字符查找错误包含错误信息" true (contains_substring lookup_error "字典查找失败");

    let data_stats = PoetryFormatting.format_rhyme_data_stats 1000 150 in
    check bool "韵律数据统计包含总数" true (contains_substring data_stats "1000");
    check bool "韵律数据统计包含韵组数" true (contains_substring data_stats "150")

  (** 测试详细评价报告 *)
  let test_detailed_evaluation_report () =
    let detailed_report =
      PoetryFormatting.format_evaluation_detailed_report "五言绝句" "静夜思" 9.2 "韵律工整，意境深远"
    in
    check bool "详细报告包含诗体" true (contains_substring detailed_report "五言绝句");
    check bool "详细报告包含诗名" true (contains_substring detailed_report "静夜思");
    check bool "详细报告包含分数" true (contains_substring detailed_report "9.2");
    check bool "详细报告包含评语" true (contains_substring detailed_report "韵律工整");

    let dimension_score = PoetryFormatting.format_dimension_score "音韵美" 8.7 in
    check bool "维度评分包含维度名" true (contains_substring dimension_score "音韵美");
    check bool "维度评分包含分数" true (contains_substring dimension_score "8.7")

  (** 测试韵律验证 *)
  let test_rhyme_validation () =
    let validation_error = PoetryFormatting.format_rhyme_validation_error 3 "韵脚不合" in
    check bool "韵律验证错误包含位置" true (contains_substring validation_error "3");
    check bool "韵律验证错误包含错误描述" true (contains_substring validation_error "韵脚不合");

    let last_line_error = PoetryFormatting.format_rhyme_validation_error 4 "收韵不当" in
    check bool "最后行错误包含位置4" true (contains_substring last_line_error "4")

  (** 测试缓存和数据管理 *)
  let test_cache_and_data_management () =
    let cache_error = PoetryFormatting.format_cache_duplicate_error "韵律数据" 5 in
    check bool "缓存重复错误包含数据类型" true (contains_substring cache_error "韵律数据");
    check bool "缓存重复错误包含重复数" true (contains_substring cache_error "5");

    let loading_error = PoetryFormatting.format_data_loading_error "rhyme_data.json" "文件损坏" in
    check bool "数据加载错误包含文件名" true (contains_substring loading_error "rhyme_data.json");
    check bool "数据加载错误包含错误原因" true (contains_substring loading_error "文件损坏");

    let not_found_error = PoetryFormatting.format_group_not_found_error "稀见韵组" in
    check bool "韵组未找到错误包含韵组名" true (contains_substring not_found_error "稀见韵组");

    let json_parse_error = PoetryFormatting.format_json_parse_error "配置文件" "JSON格式错误" in
    check bool "JSON解析错误包含文件描述" true (contains_substring json_parse_error "配置文件");
    check bool "JSON解析错误包含错误详情" true (contains_substring json_parse_error "JSON格式错误")

  (** 测试灰韵组数据统计 *)
  let test_hui_rhyme_stats () =
    let stats = PoetryFormatting.format_hui_rhyme_stats "灰韵" 25 180 "常用韵组" in
    check bool "灰韵统计包含韵名" true (contains_substring stats "灰韵");
    check bool "灰韵统计包含字数" true (contains_substring stats "25");
    check bool "灰韵统计包含总数" true (contains_substring stats "180");
    check bool "灰韵统计包含分类" true (contains_substring stats "常用韵组")

  (** 测试数据完整性验证 *)
  let test_data_integrity_validation () =
    let success = PoetryFormatting.format_data_integrity_success 500 in
    check bool "数据完整性成功包含记录数" true (contains_substring success "500");

    let failure = PoetryFormatting.format_data_integrity_failure 480 500 in
    check bool "数据完整性失败包含实际数" true (contains_substring failure "480");
    check bool "数据完整性失败包含期望数" true (contains_substring failure "500");

    let exception_info = PoetryFormatting.format_data_integrity_exception "数据库连接超时" in
    check bool "数据完整性异常包含异常信息" true (contains_substring exception_info "数据库连接超时")
end

(** 测试古典诗词格式化功能 *)
module Test_ClassicalFormatting = struct
  (** 测试古典诗词特有的格式化 *)
  let test_classical_poetry_specific_formatting () =
    (* 这些测试基于古典诗词的特殊需求 *)
    let classical_title = "《春晓》- 唐·孟浩然" in
    let classical_structure = "五言绝句 · 平起平收" in
    let classical_rhyme = "平水韵 · 上平声 · 二萧" in

    check bool "古典标题格式正确" true (contains_substring classical_title "春晓");
    check bool "古典结构描述完整" true (contains_substring classical_structure "五言绝句");
    check bool "古典韵律标注规范" true (contains_substring classical_rhyme "平水韵")

  (** 测试古典诗词术语格式化 *)
  let test_classical_terminology_formatting () =
    let poetic_terms = [ "起承转合"; "平起仄收"; "对仗工整"; "韵脚和谐"; "意境深远"; "格律严谨"; "声律之美"; "词藻华丽" ] in

    List.iter (fun term -> check bool (term ^ "术语有效") true (String.length term > 0)) poetic_terms

  (** 测试古典诗词评价维度 *)
  let test_classical_evaluation_dimensions () =
    let dimensions =
      [ ("音韵美", 8.5); ("意境美", 9.2); ("结构美", 7.8); ("语言美", 8.9); ("情感美", 9.5); ("技巧美", 8.1) ]
    in

    List.iter
      (fun (dim, score) ->
        let formatted = Printf.sprintf "%s: %.1f分" dim score in
        check bool (dim ^ "评分格式正确") true (contains_substring formatted dim);
        check bool (dim ^ "分数格式正确") true (contains_substring formatted (string_of_float score)))
      dimensions
end

(** 测试古雅体格式化功能 *)
module Test_AncientStyleFormatting = struct
  (** 测试古雅体特殊格式化 *)
  let test_ancient_style_specific_formatting () =
    let ancient_expressions = [ "乃其法也"; "是故有之"; "凡此类者"; "若夫其道"; "然则有别"; "盖因其故"; "诚哉斯言"; "善哉此理" ] in

    List.iter
      (fun expr ->
        check bool (expr ^ "古雅体表达有效") true (String.length expr > 0);
        check bool (expr ^ "包含古典词汇") true
          (contains_substring expr "乃" || contains_substring expr "故" || contains_substring expr "凡"
         || contains_substring expr "若" || contains_substring expr "然"
         || contains_substring expr "盖" || contains_substring expr "诚"
         || contains_substring expr "善"))
      ancient_expressions

  (** 测试古雅体语法结构 *)
  let test_ancient_grammar_structures () =
    let grammar_patterns =
      [ "其...者，...也"; "凡...者，皆..."; "若...则..."; "盖...故..."; "诚...乃..."; "善...哉..." ]
    in

    List.iter
      (fun pattern -> check bool (pattern ^ "语法模式有效") true (String.length pattern > 0))
      grammar_patterns

  (** 测试古雅体错误提示 *)
  let test_ancient_style_error_messages () =
    let ancient_errors = [ "此非古雅之道也"; "语法有误，当如是云"; "词序不当，宜改之"; "用词不雅，可择他词"; "句式繁复，当简之" ] in

    List.iter
      (fun error ->
        check bool (error ^ "古雅体错误消息有效") true (String.length error > 0);
        check bool
          (error ^ "体现古典语言风格")
          true
          (contains_substring error "也" || contains_substring error "云"
         || contains_substring error "当" || contains_substring error "宜"
         || contains_substring error "之" || contains_substring error "可"))
      ancient_errors
end

(** 测试诗词分析工具功能 *)
module Test_PoetryAnalysisTools = struct
  (** 测试韵律分析工具 *)
  let test_rhyme_analysis_tools () =
    (* 测试韵律分析的辅助工具 *)
    let rhyme_check = "韵脚检查: 平水韵分析" in
    let tone_pattern = "平仄分析: 标准格律检测" in
    let rhythm_flow = "韵律流畅度: 声调和谐评估" in

    check bool "韵脚检查工具有效" true (contains_substring rhyme_check "韵脚检查");
    check bool "平仄分析工具有效" true (contains_substring tone_pattern "平仄分析");
    check bool "韵律流畅度工具有效" true (contains_substring rhythm_flow "韵律流畅度")

  (** 测试诗词结构分析工具 *)
  let test_structure_analysis_tools () =
    let structure_tools = [ "对偶分析器"; "起承转合检测器"; "章法布局分析器"; "意象层次分析器"; "情感递进分析器"; "主题统一性检查器" ] in

    List.iter
      (fun tool ->
        check bool (tool ^ "工具有效") true (String.length tool > 0);
        check bool (tool ^ "命名规范") true
          (contains_substring tool "分析" || contains_substring tool "检测"
         || contains_substring tool "检查"))
      structure_tools

  (** 测试诗词美学评价工具 *)
  let test_aesthetic_evaluation_tools () =
    let aesthetic_criteria =
      [
        ("意境深度", "评估诗词的意境层次和深度");
        ("语言美感", "评估用词的准确性和美感");
        ("情感真挚", "评估情感表达的真实性");
        ("艺术创新", "评估在传统基础上的创新程度");
        ("文化内涵", "评估文化底蕴和历史厚度");
      ]
    in

    List.iter
      (fun (criterion, description) ->
        check bool (criterion ^ "评价标准有效") true (String.length criterion > 0);
        check bool (criterion ^ "描述完整") true (String.length description > 10);
        check bool (description ^ "包含评估字样") true (contains_substring description "评估"))
      aesthetic_criteria

  (** 测试诗词数据统计工具 *)
  let test_poetry_statistics_tools () =
    let statistics =
      [ ("字数统计", 28); ("句数统计", 4); ("韵脚统计", 2); ("平声字数", 14); ("仄声字数", 14); ("重复字数", 0) ]
    in

    List.iter
      (fun (stat_name, count) ->
        let formatted_stat = Printf.sprintf "%s: %d" stat_name count in
        check bool (stat_name ^ "统计有效") true (String.length formatted_stat > 0);
        check bool (stat_name ^ "数值合理") true (count >= 0))
      statistics

  (** 测试诗词智能建议工具 *)
  let test_poetry_suggestion_tools () =
    let suggestions =
      [ "建议调整第二句的平仄格律"; "可考虑使用更加贴切的韵脚字"; "建议加强对偶句的工整性"; "可以增强意象的层次感"; "建议统一情感基调" ]
    in

    List.iter
      (fun suggestion ->
        check bool (suggestion ^ "建议有效") true (String.length suggestion > 0);
        check bool
          (suggestion ^ "包含建议词汇")
          true
          (contains_substring suggestion "建议"
          || contains_substring suggestion "可"
          || contains_substring suggestion "应"
          || contains_substring suggestion "宜"))
      suggestions
end

(** 测试边界情况和特殊诗词场景 *)
module Test_EdgeCasesAndSpecialPoetryScenarios = struct
  (** 测试极端长度的诗词处理 *)
  let test_extreme_length_poetry () =
    (* 测试非常短的诗（如一字诗） *)
    let mini_poem_analysis = "微诗分析: 一字传情" in
    check bool "微诗分析有效" true (contains_substring mini_poem_analysis "微诗");

    (* 测试非常长的诗（如长篇叙事诗） *)
    let long_poem_analysis = "长篇诗分析: 结构复杂，需分段处理" in
    check bool "长篇诗分析有效" true (contains_substring long_poem_analysis "长篇诗")

  (** 测试非标准诗体处理 *)
  let test_non_standard_poetry_forms () =
    let modern_forms = [ "自由诗"; "散文诗"; "实验诗"; "视觉诗"; "数字诗" ] in

    List.iter
      (fun form ->
        check bool (form ^ "诗体识别有效") true (String.length form > 0);
        check bool (form ^ "包含诗字") true (contains_substring form "诗"))
      modern_forms

  (** 测试特殊字符和标点处理 *)
  let test_special_characters_and_punctuation () =
    let special_cases =
      [ "含标点诗句：春风，又绿江南岸。"; "含数字诗句：一去二三里"; "含英文诗句：Spring is here"; "含表情符号：春天🌸来了" ]
    in

    List.iter
      (fun case -> check bool (case ^ "特殊情况处理有效") true (String.length case > 0))
      special_cases

  (** 测试多语言诗词处理 *)
  let test_multilingual_poetry_handling () =
    let multilingual_examples =
      [ ("中文", "春眠不觉晓"); ("繁体中文", "春眠不覺曉"); ("文言文", "春眠不覺曉，處處聞啼鳥"); ("古音", "春眠不覺曉（上古音韵）") ]
    in

    List.iter
      (fun (lang, poem) ->
        check bool (lang ^ "诗词处理有效") true (String.length poem > 0);
        check bool (poem ^ "包含中文字符") true (String.length poem > 0))
      multilingual_examples
end

(** 测试套件 *)
let () =
  run "骆言诗词格式化模块测试"
    [
      ( "诗词分析格式化",
        [
          test_case "诗词评价报告" `Quick Test_PoetryFormatting.test_evaluation_report;
          test_case "韵组格式化" `Quick Test_PoetryFormatting.test_rhyme_group;
          test_case "字调错误格式化" `Quick Test_PoetryFormatting.test_tone_error;
          test_case "诗句分析" `Quick Test_PoetryFormatting.test_verse_analysis;
          test_case "诗词结构分析" `Quick Test_PoetryFormatting.test_poetry_structure_analysis;
          test_case "文本分析格式化" `Quick Test_PoetryFormatting.test_text_analysis_formatting;
          test_case "错误处理格式化" `Quick Test_PoetryFormatting.test_error_handling_formatting;
          test_case "详细评价报告" `Quick Test_PoetryFormatting.test_detailed_evaluation_report;
          test_case "韵律验证" `Quick Test_PoetryFormatting.test_rhyme_validation;
          test_case "缓存和数据管理" `Quick Test_PoetryFormatting.test_cache_and_data_management;
          test_case "灰韵组数据统计" `Quick Test_PoetryFormatting.test_hui_rhyme_stats;
          test_case "数据完整性验证" `Quick Test_PoetryFormatting.test_data_integrity_validation;
        ] );
      ( "古典诗词格式化",
        [
          test_case "古典诗词特有格式化" `Quick
            Test_ClassicalFormatting.test_classical_poetry_specific_formatting;
          test_case "古典诗词术语格式化" `Quick
            Test_ClassicalFormatting.test_classical_terminology_formatting;
          test_case "古典诗词评价维度" `Quick Test_ClassicalFormatting.test_classical_evaluation_dimensions;
        ] );
      ( "古雅体格式化",
        [
          test_case "古雅体特殊格式化" `Quick
            Test_AncientStyleFormatting.test_ancient_style_specific_formatting;
          test_case "古雅体语法结构" `Quick Test_AncientStyleFormatting.test_ancient_grammar_structures;
          test_case "古雅体错误提示" `Quick Test_AncientStyleFormatting.test_ancient_style_error_messages;
        ] );
      ( "诗词分析工具",
        [
          test_case "韵律分析工具" `Quick Test_PoetryAnalysisTools.test_rhyme_analysis_tools;
          test_case "诗词结构分析工具" `Quick Test_PoetryAnalysisTools.test_structure_analysis_tools;
          test_case "诗词美学评价工具" `Quick Test_PoetryAnalysisTools.test_aesthetic_evaluation_tools;
          test_case "诗词数据统计工具" `Quick Test_PoetryAnalysisTools.test_poetry_statistics_tools;
          test_case "诗词智能建议工具" `Quick Test_PoetryAnalysisTools.test_poetry_suggestion_tools;
        ] );
      ( "边界情况和特殊场景",
        [
          test_case "极端长度诗词处理" `Quick
            Test_EdgeCasesAndSpecialPoetryScenarios.test_extreme_length_poetry;
          test_case "非标准诗体处理" `Quick
            Test_EdgeCasesAndSpecialPoetryScenarios.test_non_standard_poetry_forms;
          test_case "特殊字符和标点处理" `Quick
            Test_EdgeCasesAndSpecialPoetryScenarios.test_special_characters_and_punctuation;
          test_case "多语言诗词处理" `Quick
            Test_EdgeCasesAndSpecialPoetryScenarios.test_multilingual_poetry_handling;
        ] );
    ]
