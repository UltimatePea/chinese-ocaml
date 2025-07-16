(* AI模块测试 - 声明式编程转换器测试 *)
open Ai.Declarative_transformer

(* 从生产代码中提取的测试函数 *)
let test_declarative_transformer () =
  let test_cases =
    [
      "对于 每个 数字 在 列表 中 做 总和 := !总和 + 数字";
      "对于 每个 元素 在 数组 中 做 如果 元素 > 0 那么 添加 元素";
      "对于 每个 字符串 在 文本列表 中 做 转换为大写 字符串";
      "计数器 := !计数器 + 1";
      "如果 x > 0 那么 设置 结果 为 x";
      "让 辅助 = 函数 累加器 列表 → 匹配 列表 与 | [] → 累加器";
    ]
  in

  Printf.printf "🧪 开始声明式编程风格转换器测试...\n\n";

  List.iter
    (fun code ->
      Printf.printf "🔍 测试代码: %s\n" code;
      let suggestions = analyze_and_suggest code in
      if List.length suggestions > 0 then (
        Printf.printf "✅ 找到 %d 个转换建议:\n" (List.length suggestions);
        List.iteri
          (fun i s ->
            Printf.printf "   %d. %s → %s (%.0f%%)\n" (i + 1) s.transformation_type
              s.transformed_code (s.confidence *. 100.0))
          suggestions)
      else Printf.printf "❌ 未找到适用的转换\n";
      Printf.printf "\n")
    test_cases;

  Printf.printf "🎉 声明式编程风格转换器测试完成！\n"

(* 运行测试 *)
let () = test_declarative_transformer ()