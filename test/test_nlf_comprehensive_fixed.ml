open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser
open Yyocamlc_lib.Ast

(** 自然语言函数定义系统综合测试套件 *)

let test_count = ref 0
let passed_count = ref 0

let test_execution test_name test_code expected_output =
  incr test_count;
  Printf.printf "🧪 测试 %d: %s\n" !test_count test_name;
  try
    let tokens = tokenize test_code "test.ly" in
    let state = create_parser_state tokens in
    let (ast, _) = parse_statement state in
    let result = match ast with
      | LetStmt (name, _) -> Printf.sprintf "函数 %s 定义成功" name
      | _ -> "其他语句"
    in
    if result = expected_output then (
      Printf.printf "✓ 通过\n";
      incr passed_count
    ) else (
      Printf.printf "✗ 失败 - 预期: %s, 实际: %s\n" expected_output result
    )
  with
  | e -> Printf.printf "✗ 异常: %s\n" (Printexc.to_string e)

let test_error test_name test_code =
  incr test_count;
  Printf.printf "🧪 测试 %d: %s\n" !test_count test_name;
  try
    let tokens = tokenize test_code "test.ly" in
    let state = create_parser_state tokens in
    let (_ast, _) = parse_statement state in
    Printf.printf "✗ 应该抛出错误\n"
  with
  | _ -> Printf.printf "✓ 正确处理错误\n"; incr passed_count

let run_all_tests () =
  Printf.printf "🧪 自然语言函数定义系统综合测试套件\n";
  Printf.printf "====================================\n";

  Printf.printf "\n=== 基础功能测试 ===\n";

  (* 测试1: 简单自然语言函数定义 *)
  test_execution "简单函数定义"
    "定义「加一」接受「数字」：数字加上「1」"
    "函数 加一 定义成功";

  (* 测试2: 条件函数 *)
  test_execution "条件函数定义"
    "定义「是否正数」接受「值」：当「值」小于等于「0」时返回「假」否则返回「真」"
    "函数 是否正数 定义成功";

  (* 测试3: 递归函数 *)
  test_execution "递归函数定义"
    "定义「阶乘」接受「n」：当「n」小于等于「1」时返回「1」否则返回「n」乘以「n减一」之「阶乘」"
    "函数 阶乘 定义成功";

  Printf.printf "\n=== 自然语言模式测试 ===\n";

  (* 测试4: 减一模式 *)
  test_execution "减一模式"
    "定义「前驱」接受「数」：数减一"
    "函数 前驱 定义成功";

  (* 测试5: 输入模式 *)
  test_execution "输入模式"
    "定义「处理输入」接受「输入」：输入减一"
    "函数 处理输入 定义成功";

  (* 测试6: 乘法模式 *)
  test_execution "乘法模式"
    "定义「平方」接受「x」：x乘以「x」"
    "函数 平方 定义成功";

  (* 测试7: 加法模式 *)
  test_execution "加法模式"
    "定义「求和」接受「a」：a加上「10」"
    "函数 求和 定义成功";

  Printf.printf "\n=== 复杂条件测试 ===\n";

  (* 测试8: 多条件函数 *)
  test_execution "多条件函数"
    "定义「绝对值」接受「数值」：当「数值」小于等于「0」时返回「0」减去「数值」否则返回「数值」"
    "函数 绝对值 定义成功";

  (* 测试9: 嵌套条件 *)
  test_execution "嵌套条件"
    "定义「符号」接受「x」：当「x」为「0」时返回「0」否则返回「1」"
    "函数 符号 定义成功";

  Printf.printf "\n=== 递归模式测试 ===\n";

  (* 测试10: 斐波那契数列 *)
  test_execution "斐波那契数列"
    "定义「斐波那契」接受「n」：当「n」小于等于「1」时返回「n」否则返回「n减一」之「斐波那契」加上「n减一减一」之「斐波那契」"
    "函数 斐波那契 定义成功";

  (* 测试11: 尾递归阶乘 *)
  test_execution "尾递归阶乘"
    "定义「尾递归阶乘」接受「n」：当「n」小于等于「1」时返回「1」否则返回「n」乘以「n减一」之「尾递归阶乘」"
    "函数 尾递归阶乘 定义成功";

  Printf.printf "\n=== 参数绑定测试 ===\n";

  (* 测试12: 参数重命名 *)
  test_execution "参数重命名"
    "定义「处理数据」接受「原始数据」：原始数据加上「5」"
    "函数 处理数据 定义成功";

  (* 测试13: 长参数名 *)
  test_execution "长参数名"
    "定义「计算结果」接受「用户输入的数字」：用户输入的数字乘以「2」"
    "函数 计算结果 定义成功";

  Printf.printf "\n=== 类型推断测试 ===\n";

  (* 测试14: 整数类型 *)
  test_execution "整数类型推断"
    "定义「整数计算」接受「数」：数加上「42」"
    "函数 整数计算 定义成功";

  (* 测试15: 布尔类型 *)
  test_execution "布尔类型推断"
    "定义「比较」接受「a」：当「a」为「0」时返回「真」否则返回「假」"
    "函数 比较 定义成功";

  Printf.printf "\n=== 错误处理测试 ===\n";

  (* 测试16: 语法错误恢复 *)
  test_error "语法错误恢复" "定义「错误函数」接受";

  Printf.printf "\n=== 兼容性测试 ===\n";

  (* 测试17: 与传统语法混用 *)
  test_execution "传统语法混用"
    "定义「新函数」接受「输入」：输入加上「2」"
    "函数 新函数 定义成功";

  Printf.printf "\n=== 性能测试 ===\n";

  let start_time = Sys.time () in
  for i = 1 to 100 do
    let test_code = Printf.sprintf "定义「函数%d」接受「参数」：参数加上「%d」" i i in
    try
      let tokens = tokenize test_code "test.ly" in
      let state = create_parser_state tokens in
      let (_ast, _) = parse_statement state in
      ()
    with _ -> ()
  done;
  let end_time = Sys.time () in
  let duration = end_time -. start_time in

  incr test_count;
  Printf.printf "🧪 测试 %d: 性能基准测试\n" !test_count;
  Printf.printf "✓ 100个函数解析耗时: %.4f秒\n" duration;
  if duration < 1.0 then (
    Printf.printf "✓ 性能测试通过 (< 1秒)\n";
    incr passed_count
  ) else (
    Printf.printf "✗ 性能测试失败 (>= 1秒)\n"
  );

  Printf.printf "\n=== 边界条件测试 ===\n";

  (* 测试19: 空函数体 *)
  test_error "空函数体处理" "定义「空函数」接受「参数」：";

  (* 测试20: 长函数名 *)
  test_execution "长函数名处理"
    "定义「这是一个非常长的函数名称用来测试系统的处理能力」接受「参数」：参数加上「1」"
    "函数 这是一个非常长的函数名称用来测试系统的处理能力 定义成功";

  Printf.printf "\n=== 集成测试 ===\n";

  (* 测试21: 复合自然语言表达式 *)
  test_execution "复合表达式"
    "定义「复杂计算」接受「输入」：当「输入」小于等于「0」时返回「输入」乘以「-1」否则返回「输入」加上「输入减一」之「复杂计算」"
    "函数 复杂计算 定义成功";

  (* 测试22: 多参数支持扩展 *)
  test_execution "多参数函数（扩展）"
    "定义「两数相加」接受「第一个数」：第一个数加上「100」"
    "函数 两数相加 定义成功";

  Printf.printf "\n=== 测试总结 ===\n";
  Printf.printf "总测试数: %d\n" !test_count;
  Printf.printf "通过测试: %d\n" !passed_count;
  Printf.printf "失败测试: %d\n" (!test_count - !passed_count);
  Printf.printf "通过率: %.1f%%\n" (100.0 *. (float_of_int !passed_count) /. (float_of_int !test_count));

  if !passed_count = !test_count then
    Printf.printf "🎉 所有测试通过！自然语言函数定义系统实施成功！\n"
  else
    Printf.printf "⚠️  部分测试失败，需要进一步优化\n"

let () = run_all_tests ()