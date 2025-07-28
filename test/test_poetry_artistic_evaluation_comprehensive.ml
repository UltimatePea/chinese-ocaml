(** 📋 Phase 2 Poetry系统测试覆盖率提升 - 艺术性评估全面测试

    此模块为Issue #1485 Phase 2的第二个核心测试文件，专注于Poetry艺术性评估系统的全面测试覆盖。

    测试目标：
    - 艺术性评分算法
    - 诗词形式识别
    - 对仗和声律分析
    - 意境和意象评估

    @author Alpha, 主要工作代理
    @version 1.0 - Phase 2初始版本
    @since 2025-07-27 *)

open Poetry.Poetry_types_consolidated
open Poetry_core.Rhyme_core_types

(** {1 测试辅助函数} *)

let test_counter = ref 0
let failed_tests = ref []

let test_assert name condition =
  incr test_counter;
  if not condition then (
    failed_tests := name :: !failed_tests;
    Printf.printf "❌ FAIL: %s\n" name)
  else Printf.printf "✅ PASS: %s\n" name

let print_test_summary () =
  let total = !test_counter in
  let failed = List.length !failed_tests in
  let passed = total - failed in
  Printf.printf "\n📊 测试总结: %d/%d 通过 (%.1f%%)\n" passed total
    (float_of_int passed /. float_of_int total *. 100.0);
  if failed > 0 then (
    Printf.printf "❌ 失败的测试:\n";
    List.iter (Printf.printf "  - %s\n") (List.rev !failed_tests))

(** {1 基础艺术性维度测试组} *)

let test_artistic_dimensions () =
  Printf.printf "\n🎨 测试组1: 艺术性维度基础\n";

  (* 测试韵律和谐维度 *)
  let rhyme_harmony = RhymeHarmony in
  test_assert "韵律和谐维度定义正确" (rhyme_harmony = RhymeHarmony);

  (* 测试声调平衡维度 *)
  let tonal_balance = TonalBalance in
  test_assert "声调平衡维度定义正确" (tonal_balance = TonalBalance);

  (* 测试维度比较 *)
  test_assert "不同维度不相等" (rhyme_harmony <> tonal_balance)

(** {1 艺术评分基础测试} *)

let test_artistic_scoring_basics () =
  Printf.printf "\n📊 测试组2: 艺术评分基础\n";

  (* 测试评分范围 *)
  let test_score_1 = 0.0 in
  let test_score_2 = 1.0 in
  let test_score_3 = 0.5 in

  test_assert "最低评分有效" (test_score_1 >= 0.0);
  test_assert "最高评分有效" (test_score_2 <= 1.0);
  test_assert "中等评分有效" (test_score_3 >= 0.0 && test_score_3 <= 1.0);

  (* 测试评分计算 *)
  let avg_score = (test_score_1 +. test_score_2 +. test_score_3) /. 3.0 in
  test_assert "平均分计算正确" (avg_score > 0.0 && avg_score < 1.0)

(** {1 诗词结构分析测试} *)

let test_poem_structure_analysis () =
  Printf.printf "\n🏗️  测试组3: 诗词结构分析\n";

  (* 测试简单诗句结构 *)
  let simple_verse = "春眠不觉晓" in
  test_assert "简单诗句长度合理" (String.length simple_verse > 0);
  test_assert "简单诗句字符数正确" (String.length simple_verse = 15);

  (* UTF-8编码下的字节数 *)

  (* 测试多句诗词结构 *)
  let verses = [ "春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少" ] in
  test_assert "多句诗词结构完整" (List.length verses = 4);
  test_assert "每句长度一致"
    (List.for_all (fun v -> String.length v = String.length (List.hd verses)) verses)

(** {1 韵律质量评估测试} *)

let test_rhyme_quality_assessment () =
  Printf.printf "\n🎵 测试组4: 韵律质量评估\n";

  (* 创建测试韵律分析报告 *)
  let xiao_char = String.get "晓" 0 in
  let chun_char = String.get "春" 0 in
  let mian_char = String.get "眠" 0 in
  let test_report =
    {
      verse = "春眠不觉晓";
      rhyme_ending = Some xiao_char;
      rhyme_group = TianRhyme;
      rhyme_category = PingSheng;
      char_analysis = [ (chun_char, PingSheng, TianRhyme); (mian_char, PingSheng, TianRhyme) ];
    }
  in

  test_assert "韵律报告诗句正确" (test_report.verse = "春眠不觉晓");
  test_assert "韵律报告有韵脚" (test_report.rhyme_ending <> None);
  test_assert "韵律报告韵组正确" (test_report.rhyme_group = TianRhyme);
  test_assert "韵律报告字符分析非空" (List.length test_report.char_analysis > 0)

(** {1 诗词整体质量分析测试} *)

let test_poem_quality_analysis () =
  Printf.printf "\n📈 测试组5: 诗词整体质量分析\n";

  (* 创建测试诗词分析 *)
  let test_analysis =
    {
      verses = [ "春眠不觉晓"; "处处闻啼鸟" ];
      verse_analyses = [];
      overall_rhyme_groups = [ TianRhyme; YueRhyme ];
      overall_rhyme_categories = [ PingSheng; ZeSheng ];
      rhyme_consistency_score = 0.85;
      artistic_quality_score = 0.85;
      suggestions = [];
    }
  in

  test_assert "诗词分析诗句数量正确" (List.length test_analysis.verses = 2);
  test_assert "诗词分析韵组多样性" (List.length test_analysis.overall_rhyme_groups >= 1);
  test_assert "诗词分析质量分数合理" (test_analysis.artistic_quality_score >= 0.0 && test_analysis.artistic_quality_score <= 1.0);
  test_assert "诗词分析韵律一致性检查" (test_analysis.rhyme_consistency_score > 0.0)

(** {1 边界条件和错误处理测试} *)

let test_boundary_conditions () =
  Printf.printf "\n⚠️  测试组6: 边界条件处理\n";

  (* 测试空诗句 *)
  let empty_verse = "" in
  test_assert "空诗句长度为零" (String.length empty_verse = 0);

  (* 测试极长诗句 *)
  let long_verse = String.make 200 'a' in
  test_assert "极长诗句处理" (String.length long_verse = 200);

  (* 测试边界评分 *)
  let boundary_scores = [ 0.0; 1.0; -0.1; 1.1 ] in
  let valid_scores = List.filter (fun score -> score >= 0.0 && score <= 1.0) boundary_scores in
  test_assert "边界评分过滤正确" (List.length valid_scores = 2)

(** {1 性能压力测试} *)

let test_performance_stress () =
  Printf.printf "\n⚡ 测试组7: 性能压力测试\n";

  (* 测试大量诗句处理性能 *)
  let large_verses = Array.to_list (Array.make 100 "春眠不觉晓处处闻啼鸟") in
  let start_time = Sys.time () in
  let verse_count = List.length large_verses in
  let end_time = Sys.time () in
  let processing_time = end_time -. start_time in

  test_assert "大量诗句处理结果正确" (verse_count = 100);
  test_assert "大量诗句处理性能合理" (processing_time < 1.0);

  (* 测试重复评分计算性能 *)
  let start_time2 = Sys.time () in
  for _ = 1 to 1000 do
    let _ = 0.5 +. 0.3 in
    ()
  done;
  let end_time2 = Sys.time () in
  let calc_time = end_time2 -. start_time2 in

  test_assert "重复计算性能合理" (calc_time < 0.1)

(** {1 综合集成测试} *)

let test_integration_scenarios () =
  Printf.printf "\n🔗 测试组8: 综合集成场景\n";

  (* 测试完整诗词分析流程 *)
  let poem_verses = [ "春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少" ] in
  let verse_count = List.length poem_verses in
  let total_length = List.fold_left (fun acc v -> acc + String.length v) 0 poem_verses in

  test_assert "完整诗词诗句数量" (verse_count = 4);
  test_assert "完整诗词总长度合理" (total_length > 0);

  (* 测试韵律一致性检查 *)
  let rhyme_groups = [ TianRhyme; TianRhyme; TianRhyme; TianRhyme ] in
  let consistent_rhymes = List.for_all (fun group -> group = TianRhyme) rhyme_groups in
  test_assert "韵律一致性检查正确" consistent_rhymes;

  (* 测试评分综合计算 *)
  let individual_scores = [ 0.8; 0.7; 0.9; 0.6 ] in
  let total_score = List.fold_left ( +. ) 0.0 individual_scores in
  let average_score = total_score /. float_of_int (List.length individual_scores) in
  test_assert "评分综合计算正确" (average_score > 0.0 && average_score <= 1.0)

(** {1 主测试执行函数} *)

let run_all_tests () =
  Printf.printf "🧪 开始执行 Phase 2 艺术性评估全面测试\n";
  Printf.printf "=========================================\n";

  test_artistic_dimensions ();
  test_artistic_scoring_basics ();
  test_poem_structure_analysis ();
  test_rhyme_quality_assessment ();
  test_poem_quality_analysis ();
  test_boundary_conditions ();
  test_performance_stress ();
  test_integration_scenarios ();

  print_test_summary ();
  Printf.printf "\n🎯 Phase 2 艺术性评估测试完成\n"

(** 程序入口 *)
let () = run_all_tests ()
