(** 智能文档生成器测试 *)

open Ai.Intelligent_doc_generator

(** 测试用的函数信息列表 *)
let sample_functions =
  [
    (* 斐波那契函数 *)
    make_function_info "斐波那契" [ "n" ]
      (make_condition
         (make_binary (make_variable "n") "<=" (make_literal "1"))
         (make_variable "n")
         (make_binary
            (make_function_call "斐波那契" [ make_binary (make_variable "n") "-" (make_literal "1") ])
            "+"
            (make_function_call "斐波那契" [ make_binary (make_variable "n") "-" (make_literal "2") ])))
      true;
    (* 计算平均值函数 *)
    make_function_info "计算平均值" [ "列表" ]
      (make_binary
         (make_function_call "列表求和" [ make_variable "列表" ])
         "/"
         (make_function_call "列表长度" [ make_variable "列表" ]))
      false;
    (* 过滤函数 *)
    make_function_info "过滤大于十" [ "列表" ]
      (make_match (make_variable "列表")
         [
           ("[]", make_list []);
           ( "头::尾",
             make_condition
               (make_binary (make_variable "头") ">" (make_literal "10"))
               (make_function_call "cons"
                  [ make_variable "头"; make_function_call "过滤大于十" [ make_variable "尾" ] ])
               (make_function_call "过滤大于十" [ make_variable "尾" ]) );
         ])
      false;
  ]

(** 基础功能测试 *)
let test_basic_functionality () =
  Printf.printf "=== 基础功能测试 ===\n";

  (* 测试函数文档生成 *)
  let fib_info = List.hd sample_functions in
  let doc = generate_function_doc fib_info default_config in

  Printf.printf "✓ 函数名: %s\n" fib_info.name;
  Printf.printf "✓ 概要: %s\n" doc.summary;
  Printf.printf "✓ 参数数量: %d\n" (List.length doc.parameters);
  Printf.printf "✓ 返回值: %s\n" doc.return_value;
  Printf.printf "✓ 示例数量: %d\n" (List.length doc.examples);
  Printf.printf "✓ 置信度: %.1f%%\n\n" (doc.confidence *. 100.0);

  assert (doc.confidence > 0.5);
  assert (List.length doc.parameters = 1);

  Printf.printf "✅ 基础功能测试通过\n\n"

(** 格式化输出测试 *)
let test_formatting () =
  Printf.printf "=== 格式化输出测试 ===\n";

  let simple_func =
    make_function_info "相加" [ "x"; "y" ]
      (make_binary (make_variable "x") "+" (make_variable "y"))
      false
  in

  let doc = generate_function_doc simple_func default_config in

  (* 测试Markdown格式 *)
  let markdown_output = format_as_markdown doc "相加" in

  Printf.printf "Markdown输出长度: %d 字符\n" (String.length markdown_output);
  assert (String.length markdown_output > 50);
  assert (String.contains markdown_output '#');

  (* 测试OCaml文档格式 *)
  let ocaml_doc = format_as_ocaml_doc doc "相加" in
  Printf.printf "OCaml文档输出长度: %d 字符\n" (String.length ocaml_doc);
  assert (String.length ocaml_doc > 30);
  assert (String.contains ocaml_doc '*');

  Printf.printf "✅ 格式化输出测试通过\n\n"

(** API参考生成测试 *)
let test_api_reference () =
  Printf.printf "=== API参考生成测试 ===\n";

  let api_ref = generate_api_reference sample_functions default_config in

  Printf.printf "API参考文档长度: %d 字符\n" (String.length api_ref);
  assert (String.length api_ref > 200);

  (* 检查是否包含函数名 *)
  assert (string_contains api_ref "斐波那契");
  assert (string_contains api_ref "计算平均值");
  assert (string_contains api_ref "过滤大于十");

  Printf.printf "✅ API参考生成测试通过\n\n"

(** 不同配置测试 *)
let test_different_configs () =
  Printf.printf "=== 不同配置测试 ===\n";

  let simple_func =
    make_function_info "简单相加" [ "a"; "b" ]
      (make_binary (make_variable "a") "+" (make_variable "b"))
      false
  in

  (* 简要模式 *)
  let brief_config = { default_config with detail_level = `Brief; include_examples = false } in
  let brief_doc = generate_function_doc simple_func brief_config in

  (* 详细模式 *)
  let detailed_config =
    { default_config with detail_level = `Comprehensive; include_examples = true }
  in
  let detailed_doc = generate_function_doc simple_func detailed_config in

  Printf.printf "简要模式示例数量: %d\n" (List.length brief_doc.examples);
  Printf.printf "详细模式示例数量: %d\n" (List.length detailed_doc.examples);

  assert (List.length brief_doc.examples = 0);
  assert (List.length detailed_doc.examples > 0);

  Printf.printf "✅ 不同配置测试通过\n\n"

(** 复杂函数测试 *)
let test_complex_functions () =
  Printf.printf "=== 复杂函数测试 ===\n";

  (* 测试递归函数 *)
  let recursive_func =
    make_function_info "阶乘" [ "n" ]
      (make_condition
         (make_binary (make_variable "n") "=" (make_literal "0"))
         (make_literal "1")
         (make_binary (make_variable "n") "*"
            (make_function_call "阶乘" [ make_binary (make_variable "n") "-" (make_literal "1") ])))
      true
  in

  let recursive_doc = generate_function_doc recursive_func default_config in

  Printf.printf "递归函数注意事项数量: %d\n" (List.length recursive_doc.notes);
  assert (List.length recursive_doc.notes > 0);

  (* 测试模式匹配函数 *)
  let pattern_match_func =
    make_function_info "长度" [ "列表" ]
      (make_match (make_variable "列表")
         [
           ("[]", make_literal "0");
           ( "_::尾",
             make_binary (make_literal "1") "+" (make_function_call "长度" [ make_variable "尾" ]) );
         ])
      false
  in

  let pattern_doc = generate_function_doc pattern_match_func default_config in

  Printf.printf "模式匹配函数注意事项: %s\n"
    (if List.length pattern_doc.notes > 0 then List.hd pattern_doc.notes else "无");

  Printf.printf "✅ 复杂函数测试通过\n\n"

(** 边界情况测试 *)
let test_edge_cases () =
  Printf.printf "=== 边界情况测试 ===\n";

  (* 测试无参数函数 *)
  let no_param_func = make_function_info "常量" [] (make_literal "42") false in
  let no_param_doc = generate_function_doc no_param_func default_config in
  Printf.printf "无参数函数参数列表长度: %d\n" (List.length no_param_doc.parameters);
  assert (List.length no_param_doc.parameters = 0);

  (* 测试复杂返回类型 *)
  let tuple_func =
    make_function_info "创建三元组" [ "x"; "y"; "z" ]
      (make_tuple [ make_variable "x"; make_variable "y"; make_variable "z" ])
      false
  in
  let tuple_doc = generate_function_doc tuple_func default_config in
  Printf.printf "三元组函数返回值描述: %s\n" tuple_doc.return_value;

  Printf.printf "✅ 边界情况测试通过\n\n"

(** 性能测试 *)
let test_performance () =
  Printf.printf "=== 性能测试 ===\n";

  let start_time = Sys.time () in

  (* 生成100个函数的文档 *)
  for i = 1 to 100 do
    let func_name = Printf.sprintf "函数%d" i in
    let params = [ "参数1"; "参数2" ] in
    let body = make_binary (make_variable "参数1") "+" (make_variable "参数2") in
    let func_info = make_function_info func_name params body false in
    let _ = generate_function_doc func_info default_config in
    ()
  done;

  let end_time = Sys.time () in
  let duration = end_time -. start_time in

  Printf.printf "生成100个函数文档耗时: %.3f秒\n" duration;
  Printf.printf "平均每个函数: %.1f毫秒\n" (duration *. 1000.0 /. 100.0);

  assert (duration < 5.0);

  (* 应该在5秒内完成 *)
  Printf.printf "✅ 性能测试通过\n\n"

(** 集成测试 *)
let test_integration () =
  Printf.printf "=== 集成测试 ===\n";

  (* 测试完整的工作流程 *)
  let module_doc = generate_module_documentation "测试模块" sample_functions default_config in

  Printf.printf "模块概要: %s\n" module_doc.module_summary;
  Printf.printf "函数数量: %d\n" (List.length module_doc.functions);
  Printf.printf "使用指南: %s\n" module_doc.usage_guide;

  assert (List.length module_doc.functions = 3);

  (* 应该有3个函数 *)

  (* 检查每个函数都有文档 *)
  List.iter
    (fun (name, doc) ->
      Printf.printf "  函数 %s: 置信度 %.0f%%\n" name (doc.confidence *. 100.0);
      assert (doc.confidence > 0.0))
    module_doc.functions;

  Printf.printf "✅ 集成测试通过\n\n"

(** 功能特征检测测试 *)
let test_feature_detection () =
  Printf.printf "=== 功能特征检测测试 ===\n";

  (* 测试递归特征检测 *)
  let recursive_func = List.hd sample_functions in
  (* 斐波那契函数 *)
  assert recursive_func.is_recursive;

  (* 测试列表处理特征检测 *)
  let list_func = List.nth sample_functions 2 in
  (* 过滤函数 *)
  let list_doc = generate_function_doc list_func default_config in
  let has_list_feature =
    List.exists (fun note -> string_contains note "列表" || string_contains note "匹配") list_doc.notes
  in
  assert has_list_feature;

  Printf.printf "✅ 功能特征检测测试通过\n\n"

(** 中文编程优化测试 *)
let test_chinese_optimization () =
  Printf.printf "=== 中文编程优化测试 ===\n";

  (* 测试中文函数名的动词识别 *)
  let calculation_func =
    make_function_info "计算总和" [ "数组" ] (make_function_call "求和" [ make_variable "数组" ]) false
  in
  let calc_doc = generate_function_doc calculation_func default_config in

  assert (string_contains calc_doc.summary "计算");

  (* 测试处理类函数 *)
  let process_func =
    make_function_info "处理数据" [ "输入" ] (make_function_call "处理" [ make_variable "输入" ]) false
  in
  let process_doc = generate_function_doc process_func default_config in

  assert (string_contains process_doc.summary "处理");

  Printf.printf "✅ 中文编程优化测试通过\n\n"

(** 主测试函数 *)
let run_all_tests () =
  Printf.printf "\n🧪 智能文档生成器全面测试开始\n";
  Printf.printf "%s\n\n" ("=" ^ String.make 50 '=');

  test_basic_functionality ();
  test_formatting ();
  test_api_reference ();
  test_different_configs ();
  test_complex_functions ();
  test_edge_cases ();
  test_performance ();
  test_integration ();
  test_feature_detection ();
  test_chinese_optimization ();

  Printf.printf "🎉 所有智能文档生成器测试完成！\n";
  Printf.printf "📊 测试统计:\n";
  Printf.printf "   • 基础功能测试: ✅ 通过\n";
  Printf.printf "   • 格式化输出测试: ✅ 通过\n";
  Printf.printf "   • API参考生成测试: ✅ 通过\n";
  Printf.printf "   • 不同配置测试: ✅ 通过\n";
  Printf.printf "   • 复杂函数测试: ✅ 通过\n";
  Printf.printf "   • 边界情况测试: ✅ 通过\n";
  Printf.printf "   • 性能测试: ✅ 通过\n";
  Printf.printf "   • 集成测试: ✅ 通过\n";
  Printf.printf "   • 功能特征检测测试: ✅ 通过\n";
  Printf.printf "   • 中文编程优化测试: ✅ 通过\n";
  Printf.printf "   • 状态: ✅ 所有测试通过\n\n"

(** 运行测试 *)
let () = run_all_tests ()
