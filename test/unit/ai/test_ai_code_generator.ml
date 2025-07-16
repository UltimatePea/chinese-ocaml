(* AI模块测试 - AI代码生成器测试 *)
open Ai.Ai_code_generator

(* 从生产代码中提取的测试函数 *)
let test_ai_code_generator () =
  let test_cases =
    [
      "创建一个计算斐波那契数列的函数";
      "实现快速排序算法对列表排序";
      "计算数字列表的平均值";
      "过滤出列表中的偶数";
      "查找列表中的最大值";
      "将字符串反转";
      "实现二分查找算法";
      "计算阶乘的递归函数";
    ]
  in

  Printf.printf "\n🚀 AI代码生成助手测试开始\n";
  Printf.printf "%s\n\n" (String.make 50 '=');

  List.iteri
    (fun i description ->
      Printf.printf "🧪 测试案例 %d: %s\n" (i + 1) description;
      Printf.printf "%s\n" (String.make 40 '-');

      let result = intelligent_code_generation description () in

      Printf.printf "📊 生成结果:\n";
      Printf.printf "置信度: %.0f%%\n" (result.confidence *. 100.0);
      Printf.printf "解释: %s\n\n" result.explanation;

      Printf.printf "📝 生成代码:\n```luoyan\n%s\n```\n\n" result.generated_code;

      Printf.printf "📈 质量指标:\n";
      Printf.printf "  语法正确性: %.0f%%\n" (result.quality_metrics.syntax_correctness *. 100.0);
      Printf.printf "  中文规范性: %.0f%%\n" (result.quality_metrics.chinese_compliance *. 100.0);
      Printf.printf "  可读性: %.0f%%\n" (result.quality_metrics.readability *. 100.0);
      Printf.printf "  效率预估: %.0f%%\n\n" (result.quality_metrics.efficiency *. 100.0);

      if List.length result.alternatives > 0 then (
        Printf.printf "🔄 替代方案:\n";
        List.iteri
          (fun j alt ->
            Printf.printf "  %d. %s (置信度: %.0f%%)\n" (j + 1) alt.alt_description
              (alt.alt_confidence *. 100.0))
          result.alternatives;
        Printf.printf "\n");

      let optimizations = suggest_optimizations result.generated_code in
      if List.length optimizations > 0 then (
        Printf.printf "💡 优化建议:\n";
        List.iteri (fun j suggestion -> Printf.printf "  %d. %s\n" (j + 1) suggestion) optimizations;
        Printf.printf "\n");

      let explanation = generate_code_explanation result.generated_code description in
      Printf.printf "📚 详细说明:\n%s\n\n" explanation;

      Printf.printf "%s\n\n" (String.make 50 '='))
    test_cases;

  Printf.printf "🎉 AI代码生成助手测试完成！\n"

(* 运行测试 *)
let () = test_ai_code_generator ()