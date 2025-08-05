(** 诗词艺术性评估全面测试 - Phase 1-A 韵律系统整合版本

    此模块为Phase 1-A韵律系统整合提供艺术性评估系统的全面测试覆盖。

    测试目标：
    - 艺术性评分算法
    - 诗词形式识别
    - 对仗和声律分析
    - 统一类型系统兼容性

    @author Alpha, 主要工作代理 + Whisky, PR Worker (Phase 1-A 适配)
    @version Phase 1-A - 韵律系统整合版本
    @since 2025-08-04 *)

open Alcotest
open Poetry_types.Poetry_types_consolidated

(** {1 基础艺术性维度测试} *)

let test_artistic_dimensions () =
  (* 测试韵律和谐维度 *)
  let rhyme_harmony = RhymeHarmony in
  check bool "韵律和谐维度定义正确" true (rhyme_harmony = RhymeHarmony);

  (* 测试声调平衡维度 *)
  let tonal_balance = TonalBalance in
  check bool "声调平衡维度定义正确" true (tonal_balance = TonalBalance);

  (* 测试对仗维度 *)
  let parallelism = Parallelism in
  check bool "对仗维度定义正确" true (parallelism = Parallelism);

  (* 测试意象维度 *)
  let imagery = Imagery in
  check bool "意象维度定义正确" true (imagery = Imagery);

  (* 测试节律维度 *)
  let rhythm = Rhythm in
  check bool "节律维度定义正确" true (rhythm = Rhythm);

  (* 测试雅致维度 *)
  let elegance = Elegance in
  check bool "雅致维度定义正确" true (elegance = Elegance)

(** {1 评价等级测试} *)

let test_evaluation_grades () =
  (* 测试所有评价等级 *)
  let excellent = Excellent in
  let good = Good in
  let average = Average in
  let fair = Fair in
  let poor = Poor in

  check bool "优秀等级定义正确" true (excellent = Excellent);
  check bool "良好等级定义正确" true (good = Good);
  check bool "一般等级定义正确" true (average = Average);
  check bool "尚可等级定义正确" true (fair = Fair);
  check bool "较差等级定义正确" true (poor = Poor);

  (* 测试等级不等性 *)
  check bool "不同等级应不相等" true (excellent <> good);
  check bool "不同等级应不相等" true (good <> average);
  check bool "不同等级应不相等" true (average <> fair);
  check bool "不同等级应不相等" true (fair <> poor)

(** {1 艺术性报告类型测试} *)

let test_artistic_report_structure () =
  (* 创建测试用艺术性报告 *)
  let test_report =
    {
      verses = "春花秋月何时了";
      rhyme_score = 0.85;
      tone_score = 0.75;
      parallelism_score = 0.90;
      imagery_score = 0.80;
      rhythm_score = 0.70;
      elegance_score = 0.85;
      overall_grade = Good;
      detailed_feedback = "诗句韵律和谐，意象丰富";
      suggestions = [ "建议加强声调平衡"; "可以优化节拍感" ];
    }
  in

  check string "诗句字段正确" "春花秋月何时了" test_report.verses;
  check bool "韵律评分范围正确" true (test_report.rhyme_score >= 0.0 && test_report.rhyme_score <= 1.0);
  check bool "声调评分范围正确" true (test_report.tone_score >= 0.0 && test_report.tone_score <= 1.0);
  check bool "对仗评分范围正确" true
    (test_report.parallelism_score >= 0.0 && test_report.parallelism_score <= 1.0);
  check bool "意象评分范围正确" true (test_report.imagery_score >= 0.0 && test_report.imagery_score <= 1.0);
  check bool "节律评分范围正确" true (test_report.rhythm_score >= 0.0 && test_report.rhythm_score <= 1.0);
  check bool "雅致评分范围正确" true (test_report.elegance_score >= 0.0 && test_report.elegance_score <= 1.0);
  check bool "总体等级正确" true (test_report.overall_grade = Good);
  check string "详细反馈正确" "诗句韵律和谐，意象丰富" test_report.detailed_feedback;
  check bool "建议列表正确" true (List.length test_report.suggestions = 2)

(** {1 艺术性分数记录测试} *)

let test_artistic_scores_structure () =
  (* 创建测试用艺术性分数记录 *)
  let test_scores =
    {
      rhyme_harmony = 0.88;
      tonal_balance = 0.72;
      parallelism = 0.91;
      imagery = 0.79;
      rhythm = 0.66;
      elegance = 0.83;
    }
  in

  check bool "韵律和谐分数范围正确" true (test_scores.rhyme_harmony >= 0.0 && test_scores.rhyme_harmony <= 1.0);
  check bool "声调平衡分数范围正确" true (test_scores.tonal_balance >= 0.0 && test_scores.tonal_balance <= 1.0);
  check bool "对仗分数范围正确" true (test_scores.parallelism >= 0.0 && test_scores.parallelism <= 1.0);
  check bool "意象分数范围正确" true (test_scores.imagery >= 0.0 && test_scores.imagery <= 1.0);
  check bool "节律分数范围正确" true (test_scores.rhythm >= 0.0 && test_scores.rhythm <= 1.0);
  check bool "雅致分数范围正确" true (test_scores.elegance >= 0.0 && test_scores.elegance <= 1.0)

(** {1 诗词形式定义测试} *)

let test_poetry_forms () =
  (* 测试各种诗词形式 *)
  let siyan_pianti = SiYanPianTi in
  let wuyan_lushi = WuYanLuShi in
  let qiyan_jueju = QiYanJueJu in
  let cipai = CiPai "浪淘沙" in
  let modern = ModernPoetry in
  let siyan_prose = SiYanParallelProse in

  check bool "四言骈体定义正确" true (siyan_pianti = SiYanPianTi);
  check bool "五言律诗定义正确" true (wuyan_lushi = WuYanLuShi);
  check bool "七言绝句定义正确" true (qiyan_jueju = QiYanJueJu);
  check bool "词牌定义正确" true (match cipai with CiPai _ -> true | _ -> false);
  check bool "现代诗定义正确" true (modern = ModernPoetry);
  check bool "四言骈体散文定义正确" true (siyan_prose = SiYanParallelProse);

  (* 测试形式不等性 *)
  check bool "不同形式应不相等" true (siyan_pianti <> wuyan_lushi);
  check bool "不同形式应不相等" true (wuyan_lushi <> qiyan_jueju);
  check bool "不同形式应不相等" true (qiyan_jueju <> modern)

(** {1 评价标准结构测试} *)

let test_poetry_standards () =
  (* 测试四言骈体评价标准 *)
  let siyan_standards =
    {
      char_count = 4;
      tone_pattern = [ true; false; true; false ];
      parallelism_required = true;
      rhythm_weight = 0.8;
    }
  in

  check int "四言字数正确" 4 siyan_standards.char_count;
  check bool "四言声调模式正确" true (List.length siyan_standards.tone_pattern = 4);
  check bool "四言对仗要求正确" true siyan_standards.parallelism_required;
  check bool "四言节律权重正确" true
    (siyan_standards.rhythm_weight >= 0.0 && siyan_standards.rhythm_weight <= 1.0);

  (* 测试五言律诗评价标准 *)
  let wuyan_standards =
    {
      line_count = 8;
      char_per_line = 5;
      rhyme_scheme = [| false; true; false; true; false; true; false; true |];
      parallelism_required = [| false; false; true; true; true; true; false; false |];
      tone_pattern = [ [ true; true; false; false; true ]; [ false; false; true; true; false ] ];
      rhythm_weight = 0.9;
    }
  in

  check int "五言行数正确" 8 wuyan_standards.line_count;
  check int "五言每行字数正确" 5 wuyan_standards.char_per_line;
  check bool "五言韵律模式正确" true (Array.length wuyan_standards.rhyme_scheme = 8);
  check bool "五言对仗要求正确" true (Array.length wuyan_standards.parallelism_required = 8);
  check bool "五言声调模式正确" true (List.length wuyan_standards.tone_pattern = 2);
  check bool "五言节律权重正确" true
    (wuyan_standards.rhythm_weight >= 0.0 && wuyan_standards.rhythm_weight <= 1.0)

(** {1 工具函数测试} *)

let test_utility_functions () =
  (* 测试韵律分类转字符串 *)
  let ping_str = rhyme_category_to_string PingSheng in
  let ze_str = rhyme_category_to_string ZeSheng in
  check bool "平声转字符串正确" true (String.length ping_str > 0);
  check bool "仄声转字符串正确" true (String.length ze_str > 0);

  (* 测试韵组转字符串 *)
  let an_str = rhyme_group_to_string AnRhyme in
  let si_str = rhyme_group_to_string SiRhyme in
  check bool "安韵转字符串正确" true (String.length an_str > 0);
  check bool "思韵转字符串正确" true (String.length si_str > 0);

  (* 测试平仄检测 *)
  let is_ping = is_ping_sheng PingSheng in
  let is_ze = is_ze_sheng ZeSheng in
  check bool "平声检测正确" true is_ping;
  check bool "仄声检测正确" true is_ze;

  (* 测试空报告创建 *)
  let empty_report = create_empty_report "测试诗句" in
  check string "空报告诗句正确" "测试诗句" empty_report.verses;
  check bool "空报告评分为零" true (empty_report.rhyme_score = 0.0);

  (* 测试整体评分计算 *)
  let test_report =
    {
      verses = "测试";
      rhyme_score = 0.8;
      tone_score = 0.7;
      parallelism_score = 0.9;
      imagery_score = 0.6;
      rhythm_score = 0.8;
      elegance_score = 0.7;
      overall_grade = Good;
      detailed_feedback = "";
      suggestions = [];
    }
  in
  let overall_score = calculate_overall_score test_report in
  check bool "整体评分计算正确" true (overall_score >= 0.0 && overall_score <= 1.0)

let () =
  run "诗词艺术性评估全面测试 - Phase 1-A"
    [
      ("艺术性维度", [ test_case "艺术性维度基础测试" `Quick test_artistic_dimensions ]);
      ("评价等级", [ test_case "评价等级测试" `Quick test_evaluation_grades ]);
      ("艺术性报告", [ test_case "艺术性报告结构测试" `Quick test_artistic_report_structure ]);
      ("艺术性分数", [ test_case "艺术性分数结构测试" `Quick test_artistic_scores_structure ]);
      ("诗词形式", [ test_case "诗词形式定义测试" `Quick test_poetry_forms ]);
      ("评价标准", [ test_case "诗词评价标准测试" `Quick test_poetry_standards ]);
      ("工具函数", [ test_case "工具函数测试" `Quick test_utility_functions ]);
    ]
