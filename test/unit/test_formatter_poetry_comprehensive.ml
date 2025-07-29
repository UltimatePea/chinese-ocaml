(** 骆言编译器诗词格式化模块全面测试 - Stage 2.2: Specialized formatter tests
    
    本测试文件针对formatter_poetry.ml提供全面的测试覆盖率，特别关注：
    - PoetryFormatting模块的完整测试
    - ClassicalFormatting模块的测试
    - AncientStyleFormatting模块的测试
    - PoetryAnalysisTools模块的测试
    
    Author: Alpha, 主工作代理
    Fix #1692 - 测试覆盖率提升计划第二阶段
    @since 2025-07-29 *)

open Alcotest
open Yyocamlc_lib.Formatter_poetry

(** 帮助函数：检查字符串是否包含子字符串 *)
let contains_substring s sub =
  try
    let _ = Str.search_forward (Str.regexp_string sub) s 0 in
    true
  with Not_found -> false

(** 帮助函数：检查字符串是否是有效的格式化结果 *)
let is_valid_format result = String.length result > 0

(** 测试PoetryFormatting模块 *)
module Test_PoetryFormatting = struct
  (** 测试诗词评价报告 *)
  let test_evaluation_report () =
    let result = PoetryFormatting.evaluation_report "春晓" "优秀" 8.5 in
    check bool "评价报告包含诗题" true (contains_substring result "春晓");
    check bool "评价报告包含总评" true (contains_substring result "优秀");
    check bool "评价报告包含分数" true (contains_substring result "8.5");
    
    let zero_score = PoetryFormatting.evaluation_report "测试诗" "不及格" 0.0 in
    check bool "零分报告包含零分" true (contains_substring zero_score "0")

  (** 测试韵组格式化 *)
  let test_rhyme_group () =
    let result = PoetryFormatting.rhyme_group "东" in
    check bool "韵组格式化包含韵组名" true (contains_substring result "东");
    check bool "韵组格式化包含平声" true (contains_substring result "平声");
    check bool "韵组格式化包含韵字" true (contains_substring result "韵");
    
    let empty_group = PoetryFormatting.rhyme_group "" in
    check bool "空韵组格式化有效" true (is_valid_format empty_group)

  (** 测试字调错误 *)
  let test_tone_error () =
    let result = PoetryFormatting.tone_error 3 "春" "仄声" in
    check bool "字调错误包含位置" true (contains_substring result "3");
    check bool "字调错误包含字符" true (contains_substring result "春");
    check bool "字调错误包含需要的声调" true (contains_substring result "仄声");
    
    let first_char = PoetryFormatting.tone_error 1 "天" "平声" in
    check bool "第一字错误格式化正确" true (contains_substring first_char "第1字")

  (** 测试诗句分析 *)
  let test_verse_analysis () =
    let result = PoetryFormatting.verse_analysis 1 "春眠不觉晓" "晓" "尧豪" in
    check bool "诗句分析包含句号" true (contains_substring result "第1句");
    check bool "诗句分析包含诗句" true (contains_substring result "春眠不觉晓");
    check bool "诗句分析包含韵脚" true (contains_substring result "晓");
    check bool "诗句分析包含韵组" true (contains_substring result "尧豪");
    
    let second_verse = PoetryFormatting.verse_analysis 2 "处处闻啼鸟" "鸟" "尧豪" in
    check bool "第二句分析正确" true (contains_substring second_verse "第2句")

  (** 测试诗词结构分析 *)
  let test_poetry_structure_analysis () =
    let result = PoetryFormatting.poetry_structure_analysis "律诗" 8 8 in
    check bool "结构分析包含诗体类型" true (contains_substring result "律诗");
    check bool "结构分析包含期望句数" true (contains_substring result "8");
    check bool "结构分析包含实际句数" true (contains_substring result "实际8句");
    
    let irregular = PoetryFormatting.poetry_structure_analysis "绝句" 4 6 in
    check bool "不规则结构分析包含期望4句" true (contains_substring irregular "期望4句");
    check bool "不规则结构分析包含实际6句" true (contains_substring irregular "实际6句")

  (** 测试Phase 3C 新增格式化函数 *)
  let test_phase3c_formatting () =
    let length_info = PoetryFormatting.format_text_length_info 256 in
    check bool "文本长度信息包含长度" true (contains_substring length_info "256");
    check bool "文本长度信息包含字符单位" true (contains_substring length_info "字符");
    
    let category_count = PoetryFormatting.format_category_count "五言" 120 in
    check bool "分类统计包含分类名" true (contains_substring category_count "五言");
    check bool "分类统计包含计数" true (contains_substring category_count "120");
    
    let rhyme_count = PoetryFormatting.format_rhyme_group_count "东冬" 45 in
    check bool "韵组统计包含组名" true (contains_substring rhyme_count "东冬");
    check bool "韵组统计包含计数" true (contains_substring rhyme_count "45");
    
    let char_error = PoetryFormatting.format_character_lookup_error "诗" "数据库连接失败" in
    check bool "字符查找错误包含字符" true (contains_substring char_error "诗");
    check bool "字符查找错误包含错误信息" true (contains_substring char_error "数据库连接失败")

  (** 测试数据统计和报告 *)
  let test_data_statistics_and_reports () =
    let rhyme_stats = PoetryFormatting.format_rhyme_data_stats 30 8000 in
    check bool "韵律数据统计包含系列数" true (contains_substring rhyme_stats "30个系列");
    check bool "韵律数据统计包含字符数" true (contains_substring rhyme_stats "8000个字符");
    
    let detailed_report = PoetryFormatting.format_evaluation_detailed_report "静夜思" "优秀" 9.2 "意境深远，技法纯熟" in
    check bool "详细评价报告包含诗题" true (contains_substring detailed_report "静夜思");
    check bool "详细评价报告包含总评" true (contains_substring detailed_report "优秀");
    check bool "详细评价报告包含分数" true (contains_substring detailed_report "9.2");
    check bool "详细评价报告包含详情" true (contains_substring detailed_report "意境深远");
    
    let dimension_score = PoetryFormatting.format_dimension_score "韵律" 8.8 in
    check bool "评分维度包含维度名" true (contains_substring dimension_score "韵律");
    check bool "评分维度包含分数" true (contains_substring dimension_score "8.8");
    
    let validation_error = PoetryFormatting.format_rhyme_validation_error 3 "韵律不合" in
    check bool "韵律验证错误包含计数" true (contains_substring validation_error "3");
    check bool "韵律验证错误包含错误类型" true (contains_substring validation_error "韵律不合")

  (** 测试缓存和数据管理 *)
  let test_cache_and_data_management () =
    let cache_error = PoetryFormatting.format_cache_duplicate_error "春" 5 in
    check bool "缓存重复错误包含字符" true (contains_substring cache_error "春");
    check bool "缓存重复错误包含次数" true (contains_substring cache_error "5次");
    
    let loading_error = PoetryFormatting.format_data_loading_error "韵律数据库" "连接超时" in
    check bool "数据加载错误包含上下文" true (contains_substring loading_error "韵律数据库");
    check bool "数据加载错误包含错误信息" true (contains_substring loading_error "连接超时");
    
    let group_not_found = PoetryFormatting.format_group_not_found_error "灰韵" in
    check bool "字符组未找到错误包含组名" true (contains_substring group_not_found "灰韵");
    
    let json_error = PoetryFormatting.format_json_parse_error "韵律解析" "格式错误" in
    check bool "JSON解析错误包含操作名" true (contains_substring json_error "韵律解析");
    check bool "JSON解析错误包含错误信息" true (contains_substring json_error "格式错误")

  (** 测试灰韵组数据和完整性验证 *)
  let test_hui_rhyme_and_integrity () =
    let hui_stats = PoetryFormatting.format_hui_rhyme_stats "v2.1" 3000 15 "唐宋韵律数据集" in
    check bool "灰韵组统计包含版本" true (contains_substring hui_stats "v2.1");
    check bool "灰韵组统计包含总字符数" true (contains_substring hui_stats "3000");
    check bool "灰韵组统计包含系列数" true (contains_substring hui_stats "15");
    check bool "灰韵组统计包含描述" true (contains_substring hui_stats "唐宋韵律数据集");
    
    let integrity_success = PoetryFormatting.format_data_integrity_success 2500 in
    check bool "完整性验证成功包含计数" true (contains_substring integrity_success "2500");
    check bool "完整性验证成功包含成功标识" true (contains_substring integrity_success "✅");
    
    let integrity_failure = PoetryFormatting.format_data_integrity_failure 1000 950 in
    check bool "完整性验证失败包含期望值" true (contains_substring integrity_failure "1000");
    check bool "完整性验证失败包含实际值" true (contains_substring integrity_failure "950");
    check bool "完整性验证失败包含失败标识" true (contains_substring integrity_failure "❌");
    
    let integrity_exception = PoetryFormatting.format_data_integrity_exception "数据文件损坏" in
    check bool "完整性验证异常包含异常信息" true (contains_substring integrity_exception "数据文件损坏");
    check bool "完整性验证异常包含异常标识" true (contains_substring integrity_exception "❌")
end

(** 测试ClassicalFormatting模块 *)
module Test_ClassicalFormatting = struct
  (** 测试律诗格式化 *)
  let test_format_regulated_verse () =
    let verses = ["春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少"] in
    let result = ClassicalFormatting.format_regulated_verse "春晓" "孟浩然" verses in
    check bool "律诗格式化包含诗题" true (contains_substring result "春晓");
    check bool "律诗格式化包含作者" true (contains_substring result "孟浩然");
    check bool "律诗格式化包含第一句" true (contains_substring result "春眠不觉晓");
    check bool "律诗格式化包含句号标记" true (contains_substring result "1. ");
    
    let empty_verses = ClassicalFormatting.format_regulated_verse "空诗" "佚名" [] in
    check bool "空诗句律诗格式化包含标题" true (contains_substring empty_verses "空诗")

  (** 测试绝句格式化 *)
  let test_format_quatrain () =
    let verses = ["白日依山尽"; "黄河入海流"; "欲穷千里目"; "更上一层楼"] in
    let result = ClassicalFormatting.format_quatrain "登鹳雀楼" "王之涣" verses in
    check bool "绝句格式化包含诗题" true (contains_substring result "登鹳雀楼");
    check bool "绝句格式化包含绝句标识" true (contains_substring result "绝句");
    check bool "绝句格式化包含作者" true (contains_substring result "王之涣");
    check bool "绝句格式化包含第一句" true (contains_substring result "白日依山尽");
    check bool "绝句格式化包含第四句" true (contains_substring result "更上一层楼")

  (** 测试词牌格式化 *)
  let test_format_ci_poem () =
    let stanzas = [["明月几时有"; "把酒问青天"]; ["不知天上宫阙"; "今夕是何年"]] in
    let result = ClassicalFormatting.format_ci_poem "水调歌头" "明月几时有" "苏轼" stanzas in
    check bool "词牌格式化包含词牌名" true (contains_substring result "水调歌头");
    check bool "词牌格式化包含词题" true (contains_substring result "明月几时有");
    check bool "词牌格式化包含作者" true (contains_substring result "苏轼");
    check bool "词牌格式化包含第一阙" true (contains_substring result "第1阙");
    check bool "词牌格式化包含第二阙" true (contains_substring result "第2阙");
    check bool "词牌格式化包含词句" true (contains_substring result "明月几时有");
    
    let single_stanza = ClassicalFormatting.format_ci_poem "如梦令" "昨夜雨疏风骤" "李清照" [["昨夜雨疏风骤"]] in
    check bool "单阙词格式化包含第一阙" true (contains_substring single_stanza "第1阙")

  (** 测试韵律分析格式化 *)
  let test_format_prosody_analysis () =
    let verses = ["春眠不觉晓"; "处处闻啼鸟"] in
    let result = ClassicalFormatting.format_prosody_analysis verses "AABA" "平平仄仄仄" in
    check bool "韵律分析包含韵律标识" true (contains_substring result "韵律");
    check bool "韵律分析包含韵式" true (contains_substring result "AABA");
    check bool "韵律分析包含平仄标识" true (contains_substring result "平仄");
    check bool "韵律分析包含平仄模式" true (contains_substring result "平平仄仄仄");
    check bool "韵律分析包含第一句" true (contains_substring result "第1句");
    check bool "韵律分析包含诗句内容" true (contains_substring result "春眠不觉晓")

  (** 测试对仗分析 *)
  let test_format_parallelism_analysis () =
    let couplets = [("两个黄鹂鸣翠柳", "一行白鹭上青天"); ("窗含西岭千秋雪", "门泊东吴万里船")] in
    let result = ClassicalFormatting.format_parallelism_analysis couplets in
    check bool "对仗分析包含对仗标识" true (contains_substring result "对仗分析");
    check bool "对仗分析包含第一联" true (contains_substring result "第1联");
    check bool "对仗分析包含出句标识" true (contains_substring result "出句");
    check bool "对仗分析包含对句标识" true (contains_substring result "对句");
    check bool "对仗分析包含出句内容" true (contains_substring result "两个黄鹂鸣翠柳");
    check bool "对仗分析包含对句内容" true (contains_substring result "一行白鹭上青天");
    check bool "对仗分析包含第二联" true (contains_substring result "第2联");
    
    let empty_couplets = ClassicalFormatting.format_parallelism_analysis [] in
    check bool "空对仗分析包含标题" true (contains_substring empty_couplets "对仗分析")
end

(** 测试AncientStyleFormatting模块 *)
module Test_AncientStyleFormatting = struct
  (** 测试文言文格式化 *)
  let test_format_classical_chinese () =
    let annotations = ["学而时习之：学了知识要经常复习"; "不亦说乎：不是很快乐吗"] in
    let result = AncientStyleFormatting.format_classical_chinese "论语·学而" "学而时习之，不亦说乎？" annotations in
    check bool "文言文格式化包含标题" true (contains_substring result "论语·学而");
    check bool "文言文格式化包含正文" true (contains_substring result "学而时习之");
    check bool "文言文格式化包含注释标识" true (contains_substring result "注释");
    check bool "文言文格式化包含第一条注释" true (contains_substring result "学而时习之：学了知识要经常复习");
    check bool "文言文格式化包含注释编号" true (contains_substring result "1. ");
    
    let no_annotations = AncientStyleFormatting.format_classical_chinese "简短文" "天下大势" [] in
    check bool "无注释文言文包含标题" true (contains_substring no_annotations "简短文");
    check bool "无注释文言文包含正文" true (contains_substring no_annotations "天下大势");
    check bool "无注释文言文不包含注释标识" false (contains_substring no_annotations "注释")

  (** 测试古体诗格式化 *)
  let test_format_ancient_verse () =
    let verses = ["君不见黄河之水天上来"; "奔流到海不复回"] in
    let style_notes = ["乐府体"; "七言歌行"] in
    let result = AncientStyleFormatting.format_ancient_verse "将进酒" verses style_notes in
    check bool "古体诗格式化包含诗题" true (contains_substring result "将进酒");
    check bool "古体诗格式化包含古体诗标识" true (contains_substring result "古体诗");
    check bool "古体诗格式化包含诗句" true (contains_substring result "君不见黄河之水天上来");
    check bool "古体诗格式化包含体式注" true (contains_substring result "体式注");
    check bool "古体诗格式化包含乐府体注释" true (contains_substring result "乐府体");
    check bool "古体诗格式化包含句号编号" true (contains_substring result "1. ");
    
    let no_style_notes = AncientStyleFormatting.format_ancient_verse "简短古诗" ["天地玄黄"] [] in
    check bool "无体式注古诗包含诗题" true (contains_substring no_style_notes "简短古诗");
    check bool "无体式注古诗不包含体式注" false (contains_substring no_style_notes "体式注")

  (** 测试骈体文格式化 *)
  let test_format_parallel_prose () =
    let paragraphs = ["落霞与孤鹜齐飞，秋水共长天一色。"; "渔舟唱晚，响穷彭蠡之滨；雁阵惊寒，声断衡阳之浦。"] in
    let result = AncientStyleFormatting.format_parallel_prose "滕王阁序" paragraphs in
    check bool "骈体文格式化包含标题" true (contains_substring result "滕王阁序");
    check bool "骈体文格式化包含骈体文标识" true (contains_substring result "骈体文");
    check bool "骈体文格式化包含第一段内容" true (contains_substring result "落霞与孤鹜齐飞");
    check bool "骈体文格式化包含段落编号" true (contains_substring result "第1段");
    check bool "骈体文格式化包含第二段" true (contains_substring result "第2段");
    
    let single_paragraph = AncientStyleFormatting.format_parallel_prose "短骈文" ["天下文章"] in
    check bool "单段骈体文包含第一段标识" true (contains_substring single_paragraph "第1段")

  (** 测试辞赋格式化 *)
  let test_format_fu_poem () =
    let sections = [("序", "仰观宇宙之大，俯察品类之盛"); ("正文", "登高而招，臂非加长也，而见者远")] in
    let result = AncientStyleFormatting.format_fu_poem "登高赋" "作者佚名" sections in
    check bool "辞赋格式化包含标题" true (contains_substring result "登高赋");
    check bool "辞赋格式化包含辞赋标识" true (contains_substring result "辞赋");
    check bool "辞赋格式化包含作者" true (contains_substring result "作者佚名");
    check bool "辞赋格式化包含序部分" true (contains_substring result "序:");
    check bool "辞赋格式化包含序内容" true (contains_substring result "仰观宇宙之大");
    check bool "辞赋格式化包含正文部分" true (contains_substring result "正文:");
    check bool "辞赋格式化包含正文内容" true (contains_substring result "登高而招");
    
    let empty_sections = AncientStyleFormatting.format_fu_poem "空赋" "佚名" [] in
    check bool "空段落辞赋包含标题" true (contains_substring empty_sections "空赋")
end

(** 测试PoetryAnalysisTools模块 *)
module Test_PoetryAnalysisTools = struct
  (** 测试字符频率统计 *)
  let test_format_character_frequency () =
    let chars_with_counts = [("春", 3); ("花", 2); ("秋", 1); ("月", 4)] in
    let result = PoetryAnalysisTools.format_character_frequency chars_with_counts in
    check bool "字符频率统计包含标题" true (contains_substring result "字符频率统计");
    check bool "字符频率统计包含月字" true (contains_substring result "月");
    check bool "字符频率统计包含频次" true (contains_substring result "4次");
    check bool "字符频率统计包含春字" true (contains_substring result "春");
    check bool "字符频率统计包含正确排序" true (contains_substring result "月: 4次");
    
    let empty_chars = PoetryAnalysisTools.format_character_frequency [] in
    check bool "空字符频率统计包含标题" true (contains_substring empty_chars "字符频率统计")

  (** 测试韵律模式分析 *)
  let test_format_rhyme_pattern_analysis () =
    let patterns = ["平仄仄平平仄仄"; "仄平平仄仄平平"; "平仄平平仄仄平"] in
    let result = PoetryAnalysisTools.format_rhyme_pattern_analysis patterns in
    check bool "韵律模式分析包含标题" true (contains_substring result "韵律模式分析");
    check bool "韵律模式分析包含第一个模式" true (contains_substring result "平仄仄平平仄仄");
    check bool "韵律模式分析包含编号" true (contains_substring result "1. ");
    check bool "韵律模式分析包含第三个模式" true (contains_substring result "3. ");
    
    let single_pattern = PoetryAnalysisTools.format_rhyme_pattern_analysis ["平平仄仄平"] in
    check bool "单模式分析包含编号1" true (contains_substring single_pattern "1. ")

  (** 测试声律检查报告 *)
  let test_format_prosody_check_report () =
    let violations = ["第3字应为仄声"; "第7字韵律不合"] in
    let corrections = ["将'春'改为'夜'"; "将'明'改为'暗'"] in
    let result = PoetryAnalysisTools.format_prosody_check_report violations corrections in
    check bool "声律检查报告包含违例标题" true (contains_substring result "声律违例");
    check bool "声律检查报告包含第一个违例" true (contains_substring result "第3字应为仄声");
    check bool "声律检查报告包含修正建议标题" true (contains_substring result "修正建议");
    check bool "声律检查报告包含第一个建议" true (contains_substring result "将'春'改为'夜'");
    
    let no_violations = PoetryAnalysisTools.format_prosody_check_report [] [] in
    check bool "无违例报告包含无违例标识" true (contains_substring no_violations "无违例");
    
    let violations_only = PoetryAnalysisTools.format_prosody_check_report ["韵律错误"] [] in
    check bool "仅违例报告包含违例内容" true (contains_substring violations_only "韵律错误");
    check bool "仅违例报告不包含修正标题" false (contains_substring violations_only "修正建议")

  (** 测试风格分析报告 *)
  let test_format_style_analysis_report () =
    let style_features = ["用词华丽"; "意境深远"; "对仗工整"] in
    let similarity_scores = [("李白", 0.85); ("杜甫", 0.72); ("王维", 0.63)] in
    let result = PoetryAnalysisTools.format_style_analysis_report "静夜思" style_features similarity_scores in
    check bool "风格分析报告包含诗题" true (contains_substring result "静夜思");
    check bool "风格分析报告包含风格分析标题" true (contains_substring result "风格分析报告");
    check bool "风格分析报告包含风格特征标题" true (contains_substring result "风格特征");
    check bool "风格分析报告包含第一个特征" true (contains_substring result "用词华丽");
    check bool "风格分析报告包含相似度评分标题" true (contains_substring result "相似度评分");
    check bool "风格分析报告包含李白评分" true (contains_substring result "李白");
    check bool "风格分析报告包含具体分数" true (contains_substring result "0.85");
    
    let minimal_report = PoetryAnalysisTools.format_style_analysis_report "简诗" [] [] in
    check bool "最小风格报告包含诗题" true (contains_substring minimal_report "简诗")

  (** 测试主题词汇分析 *)
  let test_format_thematic_vocabulary_analysis () =
    let themes = [("自然", ["山"; "水"; "花"; "鸟"]); ("情感", ["愁"; "喜"; "思"; "恋"])] in
    let result = PoetryAnalysisTools.format_thematic_vocabulary_analysis themes in
    check bool "主题词汇分析包含标题" true (contains_substring result "主题词汇分析");
    check bool "主题词汇分析包含自然主题" true (contains_substring result "自然");
    check bool "主题词汇分析包含自然词汇" true (contains_substring result "山");
    check bool "主题词汇分析使用中文分隔符" true (contains_substring result "山、水、花、鸟");
    check bool "主题词汇分析包含情感主题" true (contains_substring result "情感");
    check bool "主题词汇分析包含情感词汇" true (contains_substring result "愁、喜、思、恋");
    
    let empty_themes = PoetryAnalysisTools.format_thematic_vocabulary_analysis [] in
    check bool "空主题分析包含标题" true (contains_substring empty_themes "主题词汇分析")
end

let () =
  run "骆言诗词格式化模块全面测试"
    [
      ( "诗词格式化基础",
        [
          test_case "诗词评价报告" `Quick Test_PoetryFormatting.test_evaluation_report;
          test_case "韵组格式化" `Quick Test_PoetryFormatting.test_rhyme_group;
          test_case "字调错误" `Quick Test_PoetryFormatting.test_tone_error;
          test_case "诗句分析" `Quick Test_PoetryFormatting.test_verse_analysis;
          test_case "诗词结构分析" `Quick Test_PoetryFormatting.test_poetry_structure_analysis;
          test_case "Phase 3C 新增格式化函数" `Quick Test_PoetryFormatting.test_phase3c_formatting;
          test_case "数据统计和报告" `Quick Test_PoetryFormatting.test_data_statistics_and_reports;
          test_case "缓存和数据管理" `Quick Test_PoetryFormatting.test_cache_and_data_management;
          test_case "灰韵组数据和完整性验证" `Quick Test_PoetryFormatting.test_hui_rhyme_and_integrity;
        ] );
      ( "古典格式化",
        [
          test_case "律诗格式化" `Quick Test_ClassicalFormatting.test_format_regulated_verse;
          test_case "绝句格式化" `Quick Test_ClassicalFormatting.test_format_quatrain;
          test_case "词牌格式化" `Quick Test_ClassicalFormatting.test_format_ci_poem;
          test_case "韵律分析格式化" `Quick Test_ClassicalFormatting.test_format_prosody_analysis;
          test_case "对仗分析" `Quick Test_ClassicalFormatting.test_format_parallelism_analysis;
        ] );
      ( "古雅体格式化",
        [
          test_case "文言文格式化" `Quick Test_AncientStyleFormatting.test_format_classical_chinese;
          test_case "古体诗格式化" `Quick Test_AncientStyleFormatting.test_format_ancient_verse;
          test_case "骈体文格式化" `Quick Test_AncientStyleFormatting.test_format_parallel_prose;
          test_case "辞赋格式化" `Quick Test_AncientStyleFormatting.test_format_fu_poem;
        ] );
      ( "诗词分析工具",
        [
          test_case "字符频率统计" `Quick Test_PoetryAnalysisTools.test_format_character_frequency;
          test_case "韵律模式分析" `Quick Test_PoetryAnalysisTools.test_format_rhyme_pattern_analysis;
          test_case "声律检查报告" `Quick Test_PoetryAnalysisTools.test_format_prosody_check_report;
          test_case "风格分析报告" `Quick Test_PoetryAnalysisTools.test_format_style_analysis_report;
          test_case "主题词汇分析" `Quick Test_PoetryAnalysisTools.test_format_thematic_vocabulary_analysis;
        ] );
    ]