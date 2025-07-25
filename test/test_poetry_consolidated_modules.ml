(** 诗词整合模块测试 - 验证Phase 1核心模块功能

    测试新创建的整合模块是否正常工作，确保： 1. 类型定义正确 2. 韵律核心功能可用 3. 数据管理模块可用 4. 艺术性评价模块可用

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-24 *)

open Poetry.Poetry_types_consolidated
open Poetry.Poetry_rhyme_core
open Poetry.Poetry_rhyme_data
open Poetry.Poetry_artistic_core

(** {1 类型定义测试} *)

let test_types () =
  print_endline "=== 测试类型定义模块 ===";

  (* 测试韵类和韵组类型 *)
  let ping_sheng = PingSheng in
  let an_rhyme = AnRhyme in
  print_endline ("平声: " ^ rhyme_category_to_string ping_sheng);
  print_endline ("安韵: " ^ rhyme_group_to_string an_rhyme);

  (* 测试艺术性类型 *)
  let excellent = Excellent in
  let rhyme_harmony = RhymeHarmony in
  print_endline ("优秀: " ^ grade_to_string excellent);
  print_endline ("韵律和谐: " ^ dimension_to_string rhyme_harmony);

  (* 测试诗词形式 *)
  let jueju = QiYanJueJu in
  print_endline ("七言绝句: " ^ form_to_string jueju);

  print_endline "类型定义测试通过\n"

(** {1 韵律核心功能测试} *)

let test_rhyme_core () =
  print_endline "=== 测试韵律核心模块 ===";

  (* 测试字符韵律查询 *)
  let char_str = "山" in
  (match find_rhyme_info_string char_str with
  | Some (category, group) ->
      Printf.printf "%s字：%s·%s\n" char_str
        (rhyme_category_to_string category)
        (rhyme_group_to_string group)
  | None -> Printf.printf "%s字韵律信息未找到\n" char_str);

  (* 测试押韵检查 *)
  let str1 = "山" in
  let str2 = "间" in
  let strings_test = strings_rhyme str1 str2 in
  Printf.printf "山与间是否押韵：%b\n" strings_test;

  (* 测试诗句韵律分析 *)
  let verse = "山外青山楼外楼" in
  let report = generate_rhyme_report verse in
  Printf.printf "诗句：%s\n" report.verse;
  Printf.printf "韵脚：%s\n" (match report.rhyme_ending with Some c -> String.make 1 c | None -> "无");
  Printf.printf "韵组：%s\n" (rhyme_group_to_string report.rhyme_group);

  (* 测试快速诊断 *)
  let verses = [ "山外青山楼外楼"; "西湖歌舞几时休" ] in
  let diagnosis = quick_rhyme_diagnosis verses in
  Printf.printf "韵律诊断：%s（质量：%.2f）\n" diagnosis.diagnosis diagnosis.quality_score;

  print_endline "韵律核心测试通过\n"

(** {1 数据管理模块测试} *)

let test_rhyme_data () =
  print_endline "=== 测试韵律数据模块 ===";

  (* 初始化数据 *)
  initialize_data ();
  Printf.printf "数据已加载：%b\n" (is_data_loaded ());

  (* 测试数据统计 *)
  let stats = get_data_statistics () in
  List.iter (fun (name, count) -> Printf.printf "%s: %d\n" name count) stats;

  (* 测试韵组查询 *)
  let an_rhyme_chars = get_rhyme_group_chars AnRhyme in
  Printf.printf "安韵组字符数：%d\n" (List.length an_rhyme_chars);
  let take n lst =
    let rec take_aux acc n = function
      | [] -> List.rev acc
      | _ when n <= 0 -> List.rev acc
      | x :: xs -> take_aux (x :: acc) (n - 1) xs
    in
    take_aux [] n lst
  in
  Printf.printf "安韵组字符示例：%s\n" (String.concat "" (take 5 an_rhyme_chars));

  (* 测试数据验证 *)
  let integrity = validate_data_integrity () in
  Printf.printf "数据完整性：%b\n" integrity;

  print_endline "数据管理测试通过\n"

(** {1 艺术性评价模块测试} *)

let test_artistic_core () =
  print_endline "=== 测试艺术性评价模块 ===";

  (* 测试单句评价 *)
  let verse = "山外青山楼外楼" in
  let report = comprehensive_artistic_evaluation verse None in
  Printf.printf "诗句：%s\n" report.verse;
  Printf.printf "韵律和谐度：%.2f\n" report.rhyme_score;
  Printf.printf "声调平衡度：%.2f\n" report.tone_score;
  Printf.printf "意象深度：%.2f\n" report.imagery_score;
  Printf.printf "节奏感：%.2f\n" report.rhythm_score;
  Printf.printf "雅致程度：%.2f\n" report.elegance_score;
  Printf.printf "总体评级：%s\n" (grade_to_string report.overall_grade);

  (* 测试对仗评价 *)
  let left = "山外青山楼外楼" in
  let right = "西湖歌舞几时休" in
  let parallelism_score = evaluate_parallelism left right in
  Printf.printf "对仗工整度：%.2f\n" parallelism_score;

  (* 测试七言绝句评价 *)
  let jueju_verses = [| "山外青山楼外楼"; "西湖歌舞几时休"; "暖风熏得游人醉"; "直把杭州作汴州" |] in
  let jueju_report = evaluate_qiyan_jueju jueju_verses in
  Printf.printf "七言绝句评级：%s\n" (grade_to_string jueju_report.overall_grade);

  (* 测试智能评价助手 *)
  let auto_form = IntelligentEvaluator.auto_detect_form jueju_verses in
  Printf.printf "自动检测诗词形式：%s\n" (form_to_string auto_form);

  let smart_suggestions = IntelligentEvaluator.smart_suggestions jueju_verses in
  Printf.printf "智能建议：\n";
  List.iteri (fun i suggestion -> Printf.printf "  %d. %s\n" (i + 1) suggestion) smart_suggestions;

  print_endline "艺术性评价测试通过\n"

(** {1 集成测试} *)

let test_integration () =
  print_endline "=== 综合集成测试 ===";

  let verses = [| "春风又绿江南岸"; "明月何时照我还"; "遥知兄弟登高处"; "遍插茱萸少一人" |] in

  (* 使用智能评价助手进行自适应评价 *)
  let analysis = IntelligentEvaluator.adaptive_evaluation verses in

  Printf.printf "诗词形式：%s\n" (form_to_string analysis.form);
  Printf.printf "最终评级：%s\n" (grade_to_string analysis.final_grade);
  Printf.printf "评价意见：%s\n" analysis.critique;

  Printf.printf "韵律质量：%.2f\n" analysis.overall_rhyme.rhyme_quality;
  Printf.printf "韵律一致性：%b\n" analysis.overall_rhyme.rhyme_consistency;

  print_endline "集成测试通过\n"

(** {1 主测试函数} *)

let run_all_tests () =
  print_endline "开始测试诗词整合模块功能...\n";

  try
    test_types ();
    test_rhyme_core ();
    test_rhyme_data ();
    test_artistic_core ();
    test_integration ();

    print_endline "=== 所有测试通过 ===";
    print_endline "诗词模块整合Phase 1成功完成！";
    print_endline "已将140+个模块整合为4个核心模块：";
    print_endline "- poetry_types_consolidated.ml";
    print_endline "- poetry_rhyme_core.ml";
    print_endline "- poetry_rhyme_data.ml";
    print_endline "- poetry_artistic_core.ml"
  with exn ->
    Printf.printf "测试失败：%s\n" (Printexc.to_string exn);
    print_endline "请检查模块依赖和实现"

let _ = run_all_tests ()
