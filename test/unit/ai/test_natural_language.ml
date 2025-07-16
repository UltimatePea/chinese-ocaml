(* AI模块测试 - 自然语言处理测试 *)
open Ai.Natural_language

(* 从生产代码中提取的测试函数 *)
let test_natural_language_processing () =
  let test_cases =
    [
      "创建一个递归函数计算「斐波那契数列」";
      "对「用户列表」进行排序处理";
      "如果「年龄」大于十八那么允许访问";
      "匹配「输入类型」与不同的处理方式";
      "计算一加二的结果";
      "将字符串转换为数字";
    ]
  in

  List.iter
    (fun input ->
      Printf.printf "\n=== 自然语言处理测试: %s ===\n" input;

      Printf.printf "语义单元:\n";
      let units = extract_semantic_units input in
      List.iter
        (fun unit ->
          Printf.printf "  %s [%.0f%%] - %s\n" unit.text (unit.confidence *. 100.0)
            (match unit.word_type with
            | Verb v -> "动词:" ^ v
            | Noun n -> "名词:" ^ n
            | Keyword k -> "关键字:" ^ k
            | Number n -> "数字:" ^ string_of_int n
            | Identifier i -> "标识符:" ^ i
            | Adjective a -> "形容词:" ^ a
            | Unknown u -> "未知:" ^ u))
        units;

      Printf.printf "\n意图识别:\n";
      let intent = identify_intent units in
      Printf.printf "  %s\n"
        (match intent with
        | DefineFunction (name, _) -> "定义函数: " ^ name
        | ProcessData (data, op) -> "处理数据: " ^ op ^ " " ^ data
        | ControlFlow flow -> "控制流: " ^ flow
        | Calculate calc -> "计算: " ^ calc
        | Transform (s, t) -> "变换: " ^ s ^ " → " ^ t
        | Query obj -> "查询: " ^ obj);

      Printf.printf "\n代码建议:\n";
      let suggestions = generate_code_suggestions intent in
      List.iteri (fun i suggestion -> Printf.printf "  %d. %s\n" (i + 1) suggestion) suggestions;

      Printf.printf "\n关键信息:\n";
      let key_info = extract_key_information input in
      List.iter (fun (category, value) -> Printf.printf "  %s: %s\n" category value) key_info)
    test_cases

(* 运行测试 *)
let () = test_natural_language_processing ()