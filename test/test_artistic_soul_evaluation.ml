open OUnit2
open Poetry.Artistic_soul_evaluation

(* 测试代码样例 *)
let test_code_samples = [
  ("技术性代码", "
    let factorial n =
      if n <= 1 then 1
      else n * factorial (n - 1)
  ");
  
  ("四言骈体风格", "
    函名求和，
    参数甲乙，
    返回相加，
    结束定义。
  ");
  
  ("五言律诗风格", "
    数列层递减，
    乘积步步增；
    一归元始处，
    无穷蕴其中。
  ");
  
  ("七言绝句风格", "
    山重水复疑无路算法，
    柳暗花明又一村求解。
    函数封装巧思妙设计，
    代码复用价值千金重。
  ");
  
  ("深度诗意版本", "
    // 斐波那契数列：如春花秋月的递归美学
    函数 斐波那契诗意版(数值) {
      若数为零，    // 无中生有，道之始也
      则返回零；    // 归于虚无，元始状态
      若数为一，    // 一生二，太极初分
      则返回一；    // 万物之源，生命之初
      
      // 前数与后数相加，如诗人的人生感悟层层递进
      返回 斐波那契诗意版(数值 - 1) + 斐波那契诗意版(数值 - 2);
    }
  ");
]

let test_evaluate_technical_mastery _ =
  List.iter (fun (name, code) ->
    let score = evaluate_technical_mastery code in
    printf "技术掌握度评价 - %s: %.2f\n" name score;
    assert_bool ("技术掌握度应该在合理范围内: " ^ name) (score >= 0.0 && score <= 1.0);
  ) test_code_samples

let test_evaluate_literary_beauty _ =
  List.iter (fun (name, code) ->
    let score = evaluate_literary_beauty code in
    printf "文学美感评价 - %s: %.2f\n" name score;
    assert_bool ("文学美感应该在合理范围内: " ^ name) (score >= 0.0 && score <= 1.0);
  ) test_code_samples

let test_evaluate_cultural_depth _ =
  List.iter (fun (name, code) ->
    let score = evaluate_cultural_depth code in
    printf "文化深度评价 - %s: %.2f\n" name score;
    assert_bool ("文化深度应该在合理范围内: " ^ name) (score >= 0.0 && score <= 1.0);
  ) test_code_samples

let test_evaluate_emotional_resonance _ =
  List.iter (fun (name, code) ->
    let score = evaluate_emotional_resonance code in
    printf "情感共鸣评价 - %s: %.2f\n" name score;
    assert_bool ("情感共鸣应该在合理范围内: " ^ name) (score >= 0.0 && score <= 1.0);
  ) test_code_samples

let test_evaluate_philosophical_wisdom _ =
  List.iter (fun (name, code) ->
    let score = evaluate_philosophical_wisdom code in
    printf "哲理智慧评价 - %s: %.2f\n" name score;
    assert_bool ("哲理智慧应该在合理范围内: " ^ name) (score >= 0.0 && score <= 1.0);
  ) test_code_samples

let test_evaluate_poetic_spirit _ =
  List.iter (fun (name, code) ->
    let score = evaluate_poetic_spirit code in
    printf "诗意精神评价 - %s: %.2f\n" name score;
    assert_bool ("诗意精神应该在合理范围内: " ^ name) (score >= 0.0 && score <= 1.0);
  ) test_code_samples

let test_evaluate_artistic_soul _ =
  List.iter (fun (name, code) ->
    let soul_dimensions = evaluate_artistic_soul code in
    printf "\n=== 艺术灵魂综合评价 - %s ===\n" name;
    printf "技术掌握度: %.2f\n" soul_dimensions.technical_mastery;
    printf "文学美感: %.2f\n" soul_dimensions.literary_beauty;
    printf "文化深度: %.2f\n" soul_dimensions.cultural_depth;
    printf "情感共鸣: %.2f\n" soul_dimensions.emotional_resonance;
    printf "哲理智慧: %.2f\n" soul_dimensions.philosophical_wisdom;
    printf "诗意精神: %.2f\n" soul_dimensions.poetic_spirit;
    
    (* 验证所有维度都在合理范围内 *)
    assert_bool "技术掌握度范围检查" (soul_dimensions.technical_mastery >= 0.0 && soul_dimensions.technical_mastery <= 1.0);
    assert_bool "文学美感范围检查" (soul_dimensions.literary_beauty >= 0.0 && soul_dimensions.literary_beauty <= 1.0);
    assert_bool "文化深度范围检查" (soul_dimensions.cultural_depth >= 0.0 && soul_dimensions.cultural_depth <= 1.0);
    assert_bool "情感共鸣范围检查" (soul_dimensions.emotional_resonance >= 0.0 && soul_dimensions.emotional_resonance <= 1.0);
    assert_bool "哲理智慧范围检查" (soul_dimensions.philosophical_wisdom >= 0.0 && soul_dimensions.philosophical_wisdom <= 1.0);
    assert_bool "诗意精神范围检查" (soul_dimensions.poetic_spirit >= 0.0 && soul_dimensions.poetic_spirit <= 1.0);
  ) test_code_samples

let test_determine_soul_grade _ =
  List.iter (fun (name, code) ->
    let soul_dimensions = evaluate_artistic_soul code in
    let grade = determine_soul_grade soul_dimensions in
    let grade_str = match grade with
      | TranscendentSoul -> "超凡入圣"
      | EnlightenedSoul -> "通达智慧"
      | CultivatedSoul -> "涵养有度"
      | DevelopingSoul -> "渐入佳境"
      | TechnicalSoul -> "技术为主"
      | LackingSoul -> "缺乏灵魂"
    in
    printf "灵魂等级 - %s: %s\n" name grade_str;
  ) test_code_samples

let test_generate_soul_evaluation_report _ =
  List.iter (fun (name, code) ->
    let report = generate_soul_evaluation_report code in
    printf "\n=== 灵魂评价报告 - %s ===\n" name;
    printf "代码片段: %s\n" (String.sub report.code_text 0 (min 50 (String.length report.code_text)));
    printf "改进建议数量: %d\n" (List.length report.improvement_suggestions);
    printf "自然意象数量: %d\n" (List.length report.imagery_analysis.natural_imagery);
    printf "文化意象数量: %d\n" (List.length report.imagery_analysis.cultural_imagery);
    
    (* 验证报告结构完整性 *)
    assert_bool "报告应包含代码文本" (String.length report.code_text > 0);
    assert_bool "报告应包含改进建议" (List.length report.improvement_suggestions > 0);
  ) test_code_samples

let test_poetic_soul_critique _ =
  let critics = ["严羽"; "王国维"; "钟嵘"; "司空图"; "综合评价"] in
  List.iter (fun (name, code) ->
    printf "\n=== 诗意评价 - %s ===\n" name;
    List.iter (fun critic ->
      let critique = poetic_soul_critique code critic in
      printf "%s评价: %s\n" critic critique;
      assert_bool ("评价应包含实际内容: " ^ critic) (String.length critique > 10);
    ) critics;
  ) test_code_samples

let test_generate_soul_improvement_suggestions _ =
  List.iter (fun (name, code) ->
    let soul_dimensions = evaluate_artistic_soul code in
    let suggestions = generate_soul_improvement_suggestions soul_dimensions in
    printf "\n=== 提升建议 - %s ===\n" name;
    List.iteri (fun i suggestion ->
      printf "%d. %s\n" (i + 1) suggestion;
    ) suggestions;
    assert_bool ("应该有提升建议: " ^ name) (List.length suggestions > 0);
  ) test_code_samples

(* 测试特定的艺术性特征 *)
let test_artistic_features _ =
  let highly_poetic_code = "
    // 春风又绿江南岸算法
    函数 春风化雨排序(数组) {
      若数组如春花，    // 空或单元素，如春花初绽
      则直接返回；      // 无需排序，自然和谐
      
      选定基准春风，    // 选择基准元素
      分割江南江北；    // 分割为两部分
      
      春风化雨处理，    // 递归排序
      万物复苏归序。    // 合并结果
    }
  " in
  
  let soul_dimensions = evaluate_artistic_soul highly_poetic_code in
  printf "\n=== 高度诗意代码分析 ===\n";
  printf "技术掌握度: %.2f\n" soul_dimensions.technical_mastery;
  printf "文学美感: %.2f\n" soul_dimensions.literary_beauty;
  printf "文化深度: %.2f\n" soul_dimensions.cultural_depth;
  printf "情感共鸣: %.2f\n" soul_dimensions.emotional_resonance;
  printf "哲理智慧: %.2f\n" soul_dimensions.philosophical_wisdom;
  printf "诗意精神: %.2f\n" soul_dimensions.poetic_spirit;
  
  let grade = determine_soul_grade soul_dimensions in
  printf "灵魂等级: %s\n" (match grade with
    | TranscendentSoul -> "超凡入圣"
    | EnlightenedSoul -> "通达智慧"
    | CultivatedSoul -> "涵养有度"
    | DevelopingSoul -> "渐入佳境"
    | TechnicalSoul -> "技术为主"
    | LackingSoul -> "缺乏灵魂"
  );
  
  (* 高度诗意代码应该在多个维度上表现良好 *)
  assert_bool "诗意代码的文学美感应该较高" (soul_dimensions.literary_beauty >= 0.5);
  assert_bool "诗意代码的诗意精神应该较高" (soul_dimensions.poetic_spirit >= 0.5);

let suite =
  "Artistic Soul Evaluation Tests" >::: [
    "test_evaluate_technical_mastery" >:: test_evaluate_technical_mastery;
    "test_evaluate_literary_beauty" >:: test_evaluate_literary_beauty;
    "test_evaluate_cultural_depth" >:: test_evaluate_cultural_depth;
    "test_evaluate_emotional_resonance" >:: test_evaluate_emotional_resonance;
    "test_evaluate_philosophical_wisdom" >:: test_evaluate_philosophical_wisdom;
    "test_evaluate_poetic_spirit" >:: test_evaluate_poetic_spirit;
    "test_evaluate_artistic_soul" >:: test_evaluate_artistic_soul;
    "test_determine_soul_grade" >:: test_determine_soul_grade;
    "test_generate_soul_evaluation_report" >:: test_generate_soul_evaluation_report;
    "test_poetic_soul_critique" >:: test_poetic_soul_critique;
    "test_generate_soul_improvement_suggestions" >:: test_generate_soul_improvement_suggestions;
    "test_artistic_features" >:: test_artistic_features;
  ]

let () = run_test_tt_main suite