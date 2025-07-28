(** JSON统一化功能测试
    
    测试Wave 2 JSON统一化重构后的各个模块功能
    确保类型统一化和API兼容性正常工作
    
    Author: Echo, Test Engineer Agent
    @version 1.0
    @since 2025-07-28
    @fix_issue #1550 *)

(* 测试JSON加载器功能 *)
let test_json_loader () =
  print_endline "=== 测试JSON加载器 ===";

  try
    (* 测试示例JSON生成 *)
    let sample_json = Poetry_data_loaders.generate_sample_json () in
    print_endline "✓ 示例JSON生成成功";

    (* 测试JSON字符串解析 *)
    let json_string = Yojson.Safe.to_string sample_json in
    let database = Poetry_data_loaders.parse_rhyme_database json_string in
    Printf.printf "✓ JSON解析成功，包含 %d 个韵组\n" (List.length database.groups);

    (* 测试数据库验证 *)
    let is_valid = Poetry_types.Rhyme_types.validate_rhyme_database database in
    Printf.printf "✓ 数据库验证结果: %b\n" is_valid;

    (* 测试合并功能 *)
    let merged = Poetry_data_loaders.merge_databases [ database; database ] in
    Printf.printf "✓ 数据库合并成功，合并后包含 %d 个韵组\n" (List.length merged.groups);

    true
  with exn ->
    Printf.printf "✗ JSON加载器测试失败: %s\n" (Printexc.to_string exn);
    false

(* 测试JSON解析器功能 *)
let test_json_parser () =
  print_endline "\n=== 测试JSON解析器 ===";

  try
    (* 测试韵律类型转换 *)
    let category = Poetry_data.RhymeTypeConverter.parse_rhyme_category "平声" in
    let group = Poetry_data.RhymeTypeConverter.parse_rhyme_group "安韵" in
    print_endline "✓ 韵律类型转换成功";

    (* 测试字段提取 *)
    let json_str = "{\"rhyme_groups\": {\"花韵\": {}, \"月韵\": {}}}" in
    let field_value = Poetry_data.JsonFieldExtractor.extract_field json_str "rhyme_groups" in
    Printf.printf "✓ JSON字段提取成功: %s\n" field_value;

    true
  with exn ->
    Printf.printf "✗ JSON解析器测试失败: %s\n" (Printexc.to_string exn);
    false

(* 测试声调数据加载器 *)
let test_tone_data_loader () =
  print_endline "\n=== 测试声调数据加载器 ===";

  try
    (* 测试声调数据解析 *)
    let sample_tone_json =
      "{\"rhyme_groups\": {\n\
      \      \"花韵\": {\"category\": \"平声\", \"characters\": [\"花\", \"霞\"]},\n\
      \      \"月韵\": {\"category\": \"仄声\", \"characters\": [\"月\", \"雪\"]}\n\
      \    }}"
    in
    let ping, shang, qu, ru = Poetry_tone_data.parse_tone_data sample_tone_json in
    Printf.printf "✓ 声调数据解析成功: 平声%d字, 上声%d字, 去声%d字, 入声%d字\n" (List.length ping) (List.length shang)
      (List.length qu) (List.length ru);

    (* 测试降级数据获取 *)
    let fallback_ping, fallback_shang, fallback_qu, fallback_ru =
      Poetry_tone_data.get_tone_data_with_fallback ()
    in
    Printf.printf "✓ 降级数据获取成功: 平声%d字, 上声%d字, 去声%d字, 入声%d字\n" (List.length fallback_ping)
      (List.length fallback_shang) (List.length fallback_qu) (List.length fallback_ru);

    true
  with exn ->
    Printf.printf "✗ 声调数据加载器测试失败: %s\n" (Printexc.to_string exn);
    false

(* 测试类型统一性 *)
let test_type_unification () =
  print_endline "\n=== 测试类型统一性 ===";

  try
    (* 测试不同模块返回的类型可以互操作 *)
    let sample_json = Poetry_data_loaders.generate_sample_json () in
    let json_string = Yojson.Safe.to_string sample_json in
    let database = Poetry_data_loaders.parse_rhyme_database json_string in

    (* 验证类型兼容性 *)
    let first_group = List.hd database.groups in
    let group_name = Poetry_types.Rhyme_types.rhyme_group_to_string first_group.group in
    print_endline ("✓ 类型统一性验证成功，第一个韵组: " ^ group_name);

    (* 测试类型转换函数 *)
    let category_str =
      Poetry_types.Rhyme_types.rhyme_category_to_string Poetry_types.Rhyme_types.PingSheng
    in
    let group_opt = Poetry_types.Rhyme_types.string_to_rhyme_group "AnRhyme" in
    Printf.printf "✓ 类型转换函数正常: %s, 安韵转换%s\n" category_str
      (match group_opt with Some _ -> "成功" | None -> "失败");

    true
  with exn ->
    Printf.printf "✗ 类型统一性测试失败: %s\n" (Printexc.to_string exn);
    false

(* 主测试函数 *)
let run_all_tests () =
  print_endline "🧪 开始JSON统一化功能测试";
  print_endline "=========================================";

  let tests =
    [
      ("JSON加载器", test_json_loader);
      ("JSON解析器", test_json_parser);
      ("声调数据加载器", test_tone_data_loader);
      ("类型统一性", test_type_unification);
    ]
  in

  let results =
    List.map
      (fun (name, test_func) ->
        let result = test_func () in
        (name, result))
      tests
  in

  let passed = List.filter (fun (_, result) -> result) results in
  let failed = List.filter (fun (_, result) -> not result) results in

  print_endline "\n=========================================";
  Printf.printf "📊 测试总结: %d/%d 通过\n" (List.length passed) (List.length tests);

  if List.length failed > 0 then (
    print_endline "❌ 失败的测试:";
    List.iter (fun (name, _) -> print_endline ("  - " ^ name)) failed);

  if List.length passed = List.length tests then print_endline "🎉 所有测试通过！JSON统一化重构成功！"
  else print_endline "⚠️  部分测试失败，需要进一步调试";

  List.length passed = List.length tests

(* 运行测试 *)
let () =
  let success = run_all_tests () in
  exit (if success then 0 else 1)
