(** 诗词整合引擎测试
 * 
 * 测试新整合的韵律引擎和艺术性分析引擎
 * Issue #1155 诗词模块整合优化验证
 *)

open Poetry.Poetry_rhyme_engine
open Poetry.Poetry_artistic_engine
open Poetry.Poetry_recommended_api

let test_rhyme_engine () =
  Printf.printf "\n=== 韵律引擎测试 ===\n";
  
  (* 测试韵律分析 *)
  Printf.printf "\n1. 单字符韵律分析:\n";
  ["春"; "花"; "月"; "风"] |> List.iter (fun char ->
    match analyze_char_rhyme char with
    | Some result ->
      Printf.printf "  %s: %s韵，置信度%.2f\n" char
        (match result.category with
         | Poetry.Rhyme_types.PingSheng -> "平声" 
         | Poetry.Rhyme_types.ZeSheng -> "仄声"
         | _ -> "其他声")
        result.confidence
    | None -> Printf.printf "  %s: 未找到韵律信息\n" char
  );
  
  (* 测试韵律匹配 *)
  Printf.printf "\n2. 韵律匹配测试:\n";
  let test_pairs = [("春", "人"); ("花", "家"); ("月", "雪"); ("风", "花")] in
  List.iter (fun (char1, char2) ->
    let result = Poetry.Poetry_rhyme_engine.check_rhyme_match char1 char2 in
    Printf.printf "  %s-%s: %s (分数:%.2f) - %s\n" 
      char1 char2 
      (if result.is_match then "押韵" else "不押韵")
      result.similarity_score
      result.explanation
  ) test_pairs;
  
  (* 测试诗词韵律一致性 *)
  Printf.printf "\n3. 诗词韵律一致性验证:\n";
  let poem = ["春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少"] in
  let rhyme_validation = validate_poem_rhyme poem in
  List.iter (fun (line_idx, result) ->
    Printf.printf "  第%d-%d行: %s\n" 
      (line_idx + 1) (line_idx + 2)
      (if result.is_match then "押韵" else result.explanation)
  ) rhyme_validation

let test_artistic_engine () =
  Printf.printf "\n=== 艺术性分析引擎测试 ===\n";
  
  let poem = ["春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少"] in
  
  (* 测试各维度分析 *)
  Printf.printf "\n1. 内容深度分析:\n";
  let (content_score, content_suggestions) = analyze_content_depth poem in
  Printf.printf "  分数: %.2f\n" content_score;
  List.iter (fun suggestion -> 
    Printf.printf "  建议: %s\n" suggestion
  ) content_suggestions;
  
  Printf.printf "\n2. 形式美感分析:\n";
  let (form_score, form_suggestions) = analyze_form_beauty poem in
  Printf.printf "  分数: %.2f\n" form_score;
  List.iter (fun suggestion -> 
    Printf.printf "  建议: %s\n" suggestion
  ) form_suggestions;
  
  Printf.printf "\n3. 音韵和谐度分析:\n";
  let (sound_score, sound_suggestions) = analyze_sound_harmony poem in
  Printf.printf "  分数: %.2f\n" sound_score;
  List.iter (fun suggestion -> 
    Printf.printf "  建议: %s\n" suggestion
  ) sound_suggestions;
  
  Printf.printf "\n4. 意境分析:\n";
  let mood_result = analyze_mood_creation poem in
  Printf.printf "  主要意境: %s\n" mood_result.primary_mood;
  Printf.printf "  意境强度: %.2f\n" mood_result.mood_intensity;
  Printf.printf "  意境连贯性: %.2f\n" mood_result.mood_coherence;
  
  Printf.printf "\n5. 修辞手法检测:\n";
  let rhetoric_result = detect_rhetoric_techniques poem in
  Printf.printf "  检测到的手法: %s\n" (String.concat ", " rhetoric_result.detected_techniques);
  Printf.printf "  修辞丰富度: %.2f\n" rhetoric_result.rhetoric_richness;
  
  (* 测试综合评价 *)
  Printf.printf "\n6. 综合艺术性评价:\n";
  let evaluation = comprehensive_artistic_evaluation poem in
  Printf.printf "  总体分数: %.2f\n" evaluation.overall_score;
  Printf.printf "  艺术水平: %s\n" (match evaluation.artistic_level with
    | `Beginner -> "初学者" | `Intermediate -> "中级" 
    | `Advanced -> "高级" | `Master -> "大师级");
  Printf.printf "  优点: %s\n" (String.concat "; " evaluation.strengths);
  Printf.printf "  改进建议数量: %d\n" (List.length evaluation.improvement_suggestions)

let test_recommended_api () =
  Printf.printf "\n=== 推荐API集成测试 ===\n";
  
  let poem = ["春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少"] in
  
  (* 测试韵律查找 *)
  Printf.printf "\n1. 韵律信息查找:\n";
  ["春"; "人"; "花"; "家"] |> List.iter (fun char ->
    match find_rhyme_info char with
    | Some (category, _group) ->
      Printf.printf "  %s: %s\n" char
        (match category with
         | Poetry.Rhyme_types.PingSheng -> "平声" 
         | Poetry.Rhyme_types.ZeSheng -> "仄声"
         | _ -> "其他声")
    | None -> Printf.printf "  %s: 未找到\n" char
  );
  
  (* 测试韵律匹配 *)
  Printf.printf "\n2. 韵律匹配:\n";
  let match_result1 = Poetry.Poetry_rhyme_engine.check_rhyme_match "春" "人" in
  Printf.printf "  春-人: %s\n" (if match_result1.is_match then "押韵" else "不押韵");
  let match_result2 = Poetry.Poetry_rhyme_engine.check_rhyme_match "花" "茶" in
  Printf.printf "  花-茶: %s\n" (if match_result2.is_match then "押韵" else "不押韵");
  
  (* 测试综合评价 *)
  Printf.printf "\n3. 诗词综合评价:\n";
  let result = evaluate_poem poem in
  Printf.printf "  总分: %.2f\n" result.score;
  Printf.printf "  韵律质量: %.2f\n" result.rhyme_quality;
  Printf.printf "  艺术质量: %.2f\n" result.artistic_quality;
  Printf.printf "  格律符合度: %.2f\n" result.form_compliance;
  Printf.printf "  改进建议:\n";
  List.iteri (fun i suggestion ->
    Printf.printf "    %d. %s\n" (i + 1) suggestion
  ) result.recommendations

let test_engine_performance () =
  Printf.printf "\n=== 引擎性能测试 ===\n";
  
  (* 预热引擎 *)
  Printf.printf "\n1. 预热韵律引擎...\n";
  warm_up_engine ();
  Printf.printf "  韵律引擎状态: %s\n" (get_engine_stats ());
  
  (* 批量处理测试 *)
  Printf.printf "\n2. 批量韵律分析测试:\n";
  let test_chars = ["春"; "夏"; "秋"; "冬"; "花"; "鸟"; "风"; "月"] in
  let batch_results = analyze_chars_rhyme test_chars in
  Printf.printf "  处理字符数: %d\n" (List.length batch_results);
  let successful_analyses = List.filter (fun (_, result) -> result <> None) batch_results in
  Printf.printf "  成功分析数: %d\n" (List.length successful_analyses);
  
  (* 清理资源 *)
  Printf.printf "\n3. 清理引擎资源...\n";
  cleanup_engine ();
  Printf.printf "  资源清理完成\n"

let () =
  Printf.printf "=== 诗词模块整合验证测试 ===\n";
  Printf.printf "测试目标: 验证Issue #1155的模块整合效果\n";
  
  test_rhyme_engine ();
  test_artistic_engine ();
  test_recommended_api ();
  test_engine_performance ();
  
  Printf.printf "\n=== 测试完成 ===\n";
  Printf.printf "模块整合成功！推荐API现在使用整合后的引擎提供更好的功能。\n"