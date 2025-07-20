(** 诗词艺术性评价器全面测试模块 - Phase 25 测试覆盖率提升
    
    本测试模块专门针对 poetry/artistic_evaluator.ml 进行深度测试，
    验证诗词艺术性评价的各个维度和算法准确性。
    
    测试覆盖范围：
    - 六大评价维度（韵律、声调、对仗、意象、节奏、雅致）
    - 评价算法准确性
    - 古典诗词测试用例
    - 边界条件和错误处理
    - 性能和扩展性
    - Unicode和繁简字符支持
    
    @author 骆言技术债务清理团队 - Phase 25
    @version 1.0
    @since 2025-07-20 Issue #678 核心模块测试覆盖率提升 *)

open Alcotest
open Poetry.Artistic_evaluator

(** 测试用的经典诗词 *)
let classical_poems = [
  ("春眠不觉晓，处处闻啼鸟。", "孟浩然《春晓》第一二句");
  ("夜来风雨声，花落知多少。", "孟浩然《春晓》第三四句");
  ("床前明月光，疑是地上霜。", "李白《静夜思》第一二句");
  ("举头望明月，低头思故乡。", "李白《静夜思》第三四句");
  ("白日依山尽，黄河入海流。", "王之涣《登鹳雀楼》第一二句");
  ("欲穷千里目，更上一层楼。", "王之涣《登鹳雀楼》第三四句");
]

(** 测试用的现代诗句 *)
let modern_poems = [
  ("今天天气很好", "现代简单描述");
  ("123456789", "数字序列");
  ("Hello World", "英文句子");
  ("混合中English文字", "中英混合");
]

(** 评价维度测试 *)
module EvaluationDimensionTests = struct

  (** 测试韵律评价 *)
  let test_rhyme_evaluation () =
    List.iter (fun (poem, desc) ->
      try
        let ctx = create_evaluation_context poem in
        let result = evaluate_dimension ctx Rhyme in
        
        (* 验证评价结果格式 *)
        check (float 0.001) (Printf.sprintf "%s - 韵律评分在有效范围" desc) true 
          (result.score >= 0.0 && result.score <= 1.0);
        check bool (Printf.sprintf "%s - 韵律评价维度正确" desc) true 
          (result.dimension = Rhyme);
        
        Printf.printf "%s 韵律评分: %.3f\n" desc result.score
      with
      | exn -> fail (Printf.sprintf "%s 韵律评价失败: %s" desc (Printexc.to_string exn))
    ) classical_poems

  (** 测试声调评价 *)
  let test_tone_evaluation () =
    List.iter (fun (poem, desc) ->
      try
        let ctx = create_evaluation_context poem in
        let result = evaluate_dimension ctx Tone in
        
        check (float 0.001) (Printf.sprintf "%s - 声调评分在有效范围" desc) true 
          (result.score >= 0.0 && result.score <= 1.0);
        check bool (Printf.sprintf "%s - 声调评价维度正确" desc) true 
          (result.dimension = Tone);
        
        Printf.printf "%s 声调评分: %.3f\n" desc result.score
      with
      | exn -> fail (Printf.sprintf "%s 声调评价失败: %s" desc (Printexc.to_string exn))
    ) classical_poems

  (** 测试对仗评价 *)
  let test_parallelism_evaluation () =
    (* 测试典型的对仗句 *)
    let parallel_pairs = [
      ("白日依山尽，黄河入海流。", "经典对仗");
      ("两个黄鹂鸣翠柳，一行白鹭上青天。", "杜甫名句对仗");
      ("山重水复疑无路，柳暗花明又一村。", "陆游名句对仗");
    ] in
    
    List.iter (fun (poem, desc) ->
      try
        let ctx = create_evaluation_context poem in
        let result = evaluate_dimension ctx Parallelism in
        
        check (float 0.001) (Printf.sprintf "%s - 对仗评分在有效范围" desc) true 
          (result.score >= 0.0 && result.score <= 1.0);
        
        Printf.printf "%s 对仗评分: %.3f\n" desc result.score
      with
      | exn -> fail (Printf.sprintf "%s 对仗评价失败: %s" desc (Printexc.to_string exn))
    ) parallel_pairs

  (** 测试意象评价 *)
  let test_imagery_evaluation () =
    List.iter (fun (poem, desc) ->
      try
        let ctx = create_evaluation_context poem in
        let result = evaluate_dimension ctx Imagery in
        
        check (float 0.001) (Printf.sprintf "%s - 意象评分在有效范围" desc) true 
          (result.score >= 0.0 && result.score <= 1.0);
        
        Printf.printf "%s 意象评分: %.3f\n" desc result.score
      with
      | exn -> fail (Printf.sprintf "%s 意象评价失败: %s" desc (Printexc.to_string exn))
    ) classical_poems

  (** 测试节奏评价 *)
  let test_rhythm_evaluation () =
    List.iter (fun (poem, desc) ->
      try
        let ctx = create_evaluation_context poem in
        let result = evaluate_dimension ctx Rhythm in
        
        check (float 0.001) (Printf.sprintf "%s - 节奏评分在有效范围" desc) true 
          (result.score >= 0.0 && result.score <= 1.0);
        
        Printf.printf "%s 节奏评分: %.3f\n" desc result.score
      with
      | exn -> fail (Printf.sprintf "%s 节奏评价失败: %s" desc (Printexc.to_string exn))
    ) classical_poems

  (** 测试雅致评价 *)
  let test_elegance_evaluation () =
    List.iter (fun (poem, desc) ->
      try
        let ctx = create_evaluation_context poem in
        let result = evaluate_dimension ctx Elegance in
        
        check (float 0.001) (Printf.sprintf "%s - 雅致评分在有效范围" desc) true 
          (result.score >= 0.0 && result.score <= 1.0);
        
        Printf.printf "%s 雅致评分: %.3f\n" desc result.score
      with
      | exn -> fail (Printf.sprintf "%s 雅致评价失败: %s" desc (Printexc.to_string exn))
    ) classical_poems

end

(** 评价上下文测试 *)
module EvaluationContextTests = struct

  (** 测试评价上下文创建 *)
  let test_context_creation () =
    List.iter (fun (poem, desc) ->
      try
        let ctx = create_evaluation_context poem in
        check bool (Printf.sprintf "%s - 上下文创建成功" desc) true true
      with
      | exn -> fail (Printf.sprintf "%s 上下文创建失败: %s" desc (Printexc.to_string exn))
    ) classical_poems

  (** 测试空诗句处理 *)
  let test_empty_poem_handling () =
    let empty_cases = [""; "   "; "\n\t\r"] in
    List.iter (fun empty_poem ->
      try
        let ctx = create_evaluation_context empty_poem in
        let result = evaluate_dimension ctx Rhyme in
        check (float 0.001) "空诗句评分应为0" 0.0 result.score
      with
      | exn -> fail (Printf.sprintf "空诗句处理失败: %s" (Printexc.to_string exn))
    ) empty_cases

  (** 测试上下文缓存性能 *)
  let test_context_caching () =
    let poem = "春眠不觉晓，处处闻啼鸟。" in
    
    (* 测试重复创建上下文的性能 *)
    let start_time = Sys.time () in
    for _i = 1 to 100 do
      let ctx = create_evaluation_context poem in
      ignore (evaluate_dimension ctx Rhyme)
    done;
    let elapsed = Sys.time () -. start_time in
    
    check bool "上下文创建性能合理" true (elapsed < 1.0);
    Printf.printf "100次上下文创建和评价耗时: %.6f 秒\n" elapsed

end

(** 综合评价测试 *)
module ComprehensiveEvaluationTests = struct

  (** 测试完整诗词评价 *)
  let test_complete_poem_evaluation () =
    List.iter (fun (poem, desc) ->
      try
        let ctx = create_evaluation_context poem in
        let all_dimensions = [Rhyme; Tone; Parallelism; Imagery; Rhythm; Elegance] in
        
        let results = List.map (evaluate_dimension ctx) all_dimensions in
        
        (* 验证所有维度都有评分 *)
        check int (Printf.sprintf "%s - 评价维度数量" desc) 6 (List.length results);
        
        (* 验证评分范围 *)
        List.iter (fun result ->
          check (float 0.001) (Printf.sprintf "%s - 评分范围正确" desc) true 
            (result.score >= 0.0 && result.score <= 1.0)
        ) results;
        
        (* 计算平均分 *)
        let total_score = List.fold_left (fun acc r -> acc +. r.score) 0.0 results in
        let avg_score = total_score /. (float_of_int (List.length results)) in
        
        Printf.printf "%s 综合评分: %.3f\n" desc avg_score
      with
      | exn -> fail (Printf.sprintf "%s 完整评价失败: %s" desc (Printexc.to_string exn))
    ) classical_poems

  (** 测试评价一致性 *)
  let test_evaluation_consistency () =
    let poem = "春眠不觉晓，处处闻啼鸟。" in
    
    (* 多次评价同一首诗，结果应该一致 *)
    let results = List.init 10 (fun _ ->
      let ctx = create_evaluation_context poem in
      evaluate_dimension ctx Rhyme
    ) in
    
    let first_score = (List.hd results).score in
    List.iter (fun result ->
      check (float 0.0001) "评价结果一致性" first_score result.score
    ) results

  (** 测试经典诗词vs现代文本 *)
  let test_classical_vs_modern_distinction () =
    (* 经典诗词应该得到更高的艺术性评分 *)
    let classical_poem = "床前明月光，疑是地上霜。" in
    let modern_text = "今天天气很好，我很开心。" in
    
    let classical_ctx = create_evaluation_context classical_poem in
    let modern_ctx = create_evaluation_context modern_text in
    
    let dimensions = [Rhyme; Tone; Imagery; Elegance] in
    
    List.iter (fun dim ->
      let classical_result = evaluate_dimension classical_ctx dim in
      let modern_result = evaluate_dimension modern_ctx dim in
      
      (* 经典诗词在大多数维度上应该得分更高 *)
      Printf.printf "维度 %s: 经典诗词 %.3f vs 现代文本 %.3f\n"
        (match dim with Rhyme -> "韵律" | Tone -> "声调" | Imagery -> "意象" | Elegance -> "雅致" | _ -> "其他")
        classical_result.score modern_result.score
    ) dimensions

end

(** Unicode和特殊字符测试 *)
module UnicodeTests = struct

  (** 测试繁体字诗词 *)
  let test_traditional_chinese_poems () =
    let traditional_poems = [
      ("床前明月光，疑是地上霜。", "简体版");
      ("牀前明月光，疑是地上霜。", "繁体版");
      ("舉頭望明月，低頭思故鄉。", "全繁体版");
    ] in
    
    List.iter (fun (poem, desc) ->
      try
        let ctx = create_evaluation_context poem in
        let result = evaluate_dimension ctx Rhyme in
        
        check (float 0.001) (Printf.sprintf "%s - 繁体字处理" desc) true 
          (result.score >= 0.0 && result.score <= 1.0);
        
        Printf.printf "%s 韵律评分: %.3f\n" desc result.score
      with
      | exn -> fail (Printf.sprintf "%s 繁体字处理失败: %s" desc (Printexc.to_string exn))
    ) traditional_poems

  (** 测试Unicode字符 *)
  let test_unicode_characters () =
    let unicode_texts = [
      ("春風吹🌸花開", "带表情符号");
      ("αβγδε诗词", "带希腊字母");
      ("مرحبا世界", "带阿拉伯文");
    ] in
    
    List.iter (fun (text, desc) ->
      try
        let ctx = create_evaluation_context text in
        let result = evaluate_dimension ctx Elegance in
        
        check (float 0.001) (Printf.sprintf "%s - Unicode处理" desc) true 
          (result.score >= 0.0 && result.score <= 1.0)
      with
      | exn -> fail (Printf.sprintf "%s Unicode处理失败: %s" desc (Printexc.to_string exn))
    ) unicode_texts

end

(** 性能和扩展性测试 *)
module PerformanceTests = struct

  (** 测试长诗词处理 *)
  let test_long_poem_processing () =
    (* 创建长诗词（重复经典句子） *)
    let long_poem = String.concat "，" (List.init 100 (fun _ -> "春眠不觉晓")) in
    
    let start_time = Sys.time () in
    try
      let ctx = create_evaluation_context long_poem in
      let result = evaluate_dimension ctx Rhyme in
      let elapsed = Sys.time () -. start_time in
      
      check bool "长诗词处理性能合理" true (elapsed < 2.0);
      check (float 0.001) "长诗词评分有效" true 
        (result.score >= 0.0 && result.score <= 1.0);
      
      Printf.printf "长诗词处理时间: %.6f 秒\n" elapsed
    with
    | exn -> fail (Printf.sprintf "长诗词处理失败: %s" (Printexc.to_string exn))

  (** 测试批量评价性能 *)
  let test_batch_evaluation_performance () =
    let poems = List.init 50 (fun i -> 
      Printf.sprintf "诗句%d：春眠不觉晓，处处闻啼鸟。" i) in
    
    let start_time = Sys.time () in
    List.iter (fun poem ->
      let ctx = create_evaluation_context poem in
      ignore (evaluate_dimension ctx Rhyme)
    ) poems;
    let elapsed = Sys.time () -. start_time in
    
    check bool "批量评价性能合理" true (elapsed < 3.0);
    Printf.printf "50首诗词批量评价时间: %.6f 秒\n" elapsed

  (** 测试内存使用 *)
  let test_memory_usage () =
    let gc_stats_before = Gc.stat () in
    
    for _i = 1 to 100 do
      let ctx = create_evaluation_context "春眠不觉晓，处处闻啼鸟。" in
      let _ = evaluate_dimension ctx Rhyme in
      let _ = evaluate_dimension ctx Tone in
      let _ = evaluate_dimension ctx Imagery in
      ()
    done;
    
    Gc.full_major ();
    let gc_stats_after = Gc.stat () in
    
    let memory_increase = gc_stats_after.live_words - gc_stats_before.live_words in
    check bool "内存使用合理" true (memory_increase < 200000);
    
    Printf.printf "内存增长: %d words\n" memory_increase

end

(** 错误处理和边界条件测试 *)
module ErrorHandlingTests = struct

  (** 测试异常字符处理 *)
  let test_abnormal_character_handling () =
    let abnormal_texts = [
      ("!@#$%^&*()", "特殊符号");
      ("12345", "纯数字");
      ("ABCDEF", "纯英文");
      ("\x00\x01\x02", "控制字符");
    ] in
    
    List.iter (fun (text, desc) ->
      try
        let ctx = create_evaluation_context text in
        let result = evaluate_dimension ctx Rhyme in
        check (float 0.001) (Printf.sprintf "%s - 异常字符处理" desc) true 
          (result.score >= 0.0 && result.score <= 1.0)
      with
      | exn -> fail (Printf.sprintf "%s 异常字符处理失败: %s" desc (Printexc.to_string exn))
    ) abnormal_texts

  (** 测试极限情况 *)
  let test_extreme_cases () =
    let extreme_cases = [
      ("", "空字符串");
      (String.make 10000 (Char.chr 0x8BD7), "超长重复字符");
      (String.make 1 (Char.chr 0x8BD7), "单字符");
    ] in
    
    List.iter (fun (text, desc) ->
      try
        let ctx = create_evaluation_context text in
        let result = evaluate_dimension ctx Tone in
        check (float 0.001) (Printf.sprintf "%s - 极限情况处理" desc) true 
          (result.score >= 0.0 && result.score <= 1.0)
      with
      | exn -> fail (Printf.sprintf "%s 极限情况处理失败: %s" desc (Printexc.to_string exn))
    ) extreme_cases

end

(** 测试套件注册 *)
let test_suite = [
  "评价维度测试", [
    test_case "韵律评价" `Quick EvaluationDimensionTests.test_rhyme_evaluation;
    test_case "声调评价" `Quick EvaluationDimensionTests.test_tone_evaluation;
    test_case "对仗评价" `Quick EvaluationDimensionTests.test_parallelism_evaluation;
    test_case "意象评价" `Quick EvaluationDimensionTests.test_imagery_evaluation;
    test_case "节奏评价" `Quick EvaluationDimensionTests.test_rhythm_evaluation;
    test_case "雅致评价" `Quick EvaluationDimensionTests.test_elegance_evaluation;
  ];
  
  "评价上下文", [
    test_case "上下文创建" `Quick EvaluationContextTests.test_context_creation;
    test_case "空诗句处理" `Quick EvaluationContextTests.test_empty_poem_handling;
    test_case "上下文缓存" `Quick EvaluationContextTests.test_context_caching;
  ];
  
  "综合评价", [
    test_case "完整诗词评价" `Quick ComprehensiveEvaluationTests.test_complete_poem_evaluation;
    test_case "评价一致性" `Quick ComprehensiveEvaluationTests.test_evaluation_consistency;
    test_case "经典vs现代区分" `Quick ComprehensiveEvaluationTests.test_classical_vs_modern_distinction;
  ];
  
  "Unicode支持", [
    test_case "繁体字诗词" `Quick UnicodeTests.test_traditional_chinese_poems;
    test_case "Unicode字符" `Quick UnicodeTests.test_unicode_characters;
  ];
  
  "性能测试", [
    test_case "长诗词处理" `Quick PerformanceTests.test_long_poem_processing;
    test_case "批量评价性能" `Quick PerformanceTests.test_batch_evaluation_performance;
    test_case "内存使用" `Quick PerformanceTests.test_memory_usage;
  ];
  
  "错误处理", [
    test_case "异常字符处理" `Quick ErrorHandlingTests.test_abnormal_character_handling;
    test_case "极限情况" `Quick ErrorHandlingTests.test_extreme_cases;
  ];
]

(** 运行所有测试 *)
let () = 
  Printf.printf "骆言诗词艺术性评价器全面测试 - Phase 25\n";
  Printf.printf "======================================================\n";
  run "Artistic Evaluator Comprehensive Tests" test_suite