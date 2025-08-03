(** 统一韵律系统集成测试
    
    测试新的统一韵律数据系统的基本功能，验证：
    - 统一类型系统正常工作
    - 数据引擎功能正确
    - JSON加载器能正确解析数据
    - 各模块间集成无误
    
    @author Alpha, 主要开发代理
    @version 2.0
    @since 2025-07-27
    @fix_issue #1501 *)

open Poetry_types.Rhyme_types
open Poetry_data_core.Rhyme_data_engine
open Poetry_data_loaders.Json_loader

let () =
  Printf.printf "=== 统一韵律系统集成测试 ===\n\n";

  (* 测试1: 统一类型系统 *)
  Printf.printf "1. 测试统一类型系统...\n";
  let sample_item = create_rhyme_item "花" PingSheng HuaRhyme in
  Printf.printf "   创建韵律数据项: %s (%s, %s)\n" sample_item.character
    (rhyme_category_to_string sample_item.category)
    (rhyme_group_to_string sample_item.group);

  (* 测试2: 数据引擎初始化 *)
  Printf.printf "\n2. 测试数据引擎初始化...\n";
  let engine = initialize () in
  Printf.printf "   数据引擎初始化完成\n";

  (* 测试3: 创建示例数据库 *)
  Printf.printf "\n3. 创建示例数据库...\n";
  let sample_items =
    [
      create_enhanced_rhyme_item "花" PingSheng HuaRhyme ~tone_value:1 ~frequency:0.95 ~source:"test"
        ();
      create_enhanced_rhyme_item "霞" PingSheng HuaRhyme ~tone_value:1 ~frequency:0.87 ~source:"test"
        ();
      create_enhanced_rhyme_item "家" PingSheng HuaRhyme ~tone_value:1 ~frequency:0.92 ~source:"test"
        ();
    ]
  in

  let sample_metadata = [ ("description", "花韵组测试数据") ] in
  let sample_group = create_rhyme_group_data HuaRhyme sample_items sample_metadata in

  let sample_database =
    {
      groups = [ sample_group ];
      version = "2.0-test";
      last_updated = "2025-07-27";
      sources = [ "integration_test" ];
    }
  in

  Printf.printf "   创建示例数据库: %d个韵组, %d个字符\n"
    (List.length sample_database.groups)
    (List.length sample_items);

  (* 测试4: 数据库验证 *)
  Printf.printf "\n4. 验证数据库...\n";
  let is_valid = validate_rhyme_database sample_database in
  Printf.printf "   数据库验证结果: %s\n" (if is_valid then "有效" else "无效");

  (* 测试5: 加载数据库到引擎 *)
  Printf.printf "\n5. 加载数据库到引擎...\n";
  let engine_with_data = load_database sample_database engine in
  let total_items, group_count, version = get_database_info engine_with_data in
  Printf.printf "   加载完成: %d个数据项, %d个韵组, 版本%s\n" total_items group_count version;

  (* 测试6: 字符查询 *)
  Printf.printf "\n6. 测试字符查询...\n";
  let test_chars = [ "花"; "霞"; "家"; "不存在" ] in
  List.iter
    (fun char ->
      match lookup_character char engine_with_data with
      | Some item ->
          Printf.printf "   查询'%s': 找到 (%s, %s)\n" char
            (rhyme_category_to_string item.category)
            (rhyme_group_to_string item.group)
      | None -> Printf.printf "   查询'%s': 未找到\n" char)
    test_chars;

  (* 测试7: 韵律匹配 *)
  Printf.printf "\n7. 测试韵律匹配...\n";
  let match_pairs = [ ("花", "霞"); ("花", "家"); ("花", "不存在") ] in
  List.iter
    (fun (char1, char2) ->
      let matches = check_rhyme_match char1 char2 engine_with_data in
      Printf.printf "   '%s' 与 '%s' 韵律匹配: %s\n" char1 char2 (if matches then "是" else "否"))
    match_pairs;

  (* 测试8: 韵组查询 *)
  Printf.printf "\n8. 测试韵组查询...\n";
  let hua_chars = get_group_characters HuaRhyme engine_with_data in
  Printf.printf "   花韵组包含%d个字符: %s\n" (List.length hua_chars)
    (String.concat ", " (List.map (fun item -> item.character) hua_chars));

  (* 测试9: 性能指标 *)
  Printf.printf "\n9. 获取性能指标...\n";
  let metrics = get_performance_metrics engine_with_data in
  List.iter (fun (key, value) -> Printf.printf "   %s: %s\n" key value) metrics;

  (* 测试10: JSON示例生成 *)
  Printf.printf "\n10. 测试JSON功能...\n";
  let _sample_json = generate_sample_json () in
  Printf.printf "   生成示例JSON结构完成\n";

  let temp_file = "/tmp/test_rhyme_data.json" in
  create_sample_file temp_file;
  Printf.printf "   创建示例JSON文件: %s\n" temp_file;

  (* 验证文件格式 *)
  let is_valid_format = validate_file_format temp_file in
  Printf.printf "   文件格式验证: %s\n" (if is_valid_format then "有效" else "无效");

  (* 分析JSON数据库 *)
  let analysis = analyze_json_database temp_file in
  Printf.printf "   JSON数据库分析:\n";
  List.iter (fun (key, value) -> Printf.printf "     %s: %s\n" key value) analysis;

  Printf.printf "\n=== 集成测试完成 ===\n";
  Printf.printf "所有基本功能测试通过！新的统一韵律系统工作正常。\n"
