(** 测试统一诗词数据加载器 - Phase 15 代码重复消除验证

    此测试文件验证统一诗词数据加载器的功能是否正常工作。

    @author 骆言诗词编程团队 - Phase 15 代码重复消除
    @version 1.0
    @since 2025-07-19 *)

open Poetry_data.Poetry_data_loader

(** 确保数据源注册器被加载 *)
let () = ignore (Poetry_data.Data_source_registry.get_registration_stats ())

(** 测试基础功能 *)
let test_basic_functionality () =
  Printf.printf "=== 测试统一诗词数据加载器基础功能 ===\n\n";

  (* 测试数据源注册 *)
  Printf.printf "1. 数据源注册测试:\n";
  let sources = get_registered_source_names () in
  Printf.printf "   已注册数据源数量: %d\n" (List.length sources);
  List.iter (fun name -> Printf.printf "   - %s\n" name) sources;

  (* 测试统计信息 *)
  Printf.printf "\n2. 数据库统计信息:\n";
  let total_chars, groups, categories = get_database_stats () in
  Printf.printf "   总字符数: %d\n" total_chars;
  Printf.printf "   韵组数: %d\n" groups;
  Printf.printf "   韵类数: %d\n" categories;

  (* 测试数据完整性 *)
  Printf.printf "\n3. 数据完整性验证:\n";
  let is_valid, errors = validate_database () in
  Printf.printf "   数据库有效性: %s\n" (if is_valid then "✅ 有效" else "❌ 有错误");
  if not is_valid then (
    Printf.printf "   错误列表:\n";
    List.iter (fun error -> Printf.printf "     - %s\n" error) errors);

  Printf.printf "\n"

(** 测试查询功能 *)
let test_query_functionality () =
  Printf.printf "=== 测试查询功能 ===\n\n";

  (* 测试字符查询 *)
  let test_chars = [ "鱼"; "书"; "居"; "虚"; "不存在" ] in
  Printf.printf "1. 字符存在性查询:\n";
  List.iter
    (fun char ->
      let exists = is_char_in_database char in
      Printf.printf "   '%s': %s\n" char (if exists then "✅ 存在" else "❌ 不存在"))
    test_chars;

  (* 测试字符韵律信息查询 *)
  Printf.printf "\n2. 字符韵律信息查询:\n";
  List.iter
    (fun char ->
      match get_char_rhyme_info char with
      | Some (c, category, group) ->
          Printf.printf "   '%s': 韵类=%s, 韵组=%s\n" c
            (match category with PingSheng -> "平声" | ZeSheng -> "仄声" | _ -> "其他")
            (match group with YuRhyme -> "鱼韵" | HuaRhyme -> "花韵" | _ -> "其他韵")
      | None -> Printf.printf "   '%s': 未找到韵律信息\n" char)
    (List.take 3 test_chars);

  Printf.printf "\n"

(** 测试向后兼容性 *)
let test_backward_compatibility () =
  Printf.printf "=== 测试向后兼容性接口 ===\n\n";

  (* 测试兼容接口 *)
  Printf.printf "1. 兼容性接口测试:\n";
  let expanded_db = get_expanded_rhyme_database () in
  Printf.printf "   扩展韵律数据库字符数: %d\n" (List.length expanded_db);

  let char_list = get_expanded_char_list () in
  Printf.printf "   字符列表长度: %d\n" (List.length char_list);

  let char_count = expanded_rhyme_char_count () in
  Printf.printf "   字符总数: %d\n" char_count;

  (* 测试字符存在性兼容接口 *)
  Printf.printf "\n2. 字符存在性兼容接口测试:\n";
  let test_chars = [ "鱼"; "书"; "不存在" ] in
  List.iter
    (fun char ->
      let exists = is_in_expanded_rhyme_database char in
      Printf.printf "   '%s': %s\n" char (if exists then "✅ 存在" else "❌ 不存在"))
    test_chars;

  Printf.printf "\n"

(** 测试性能 *)
let test_performance () =
  Printf.printf "=== 性能测试 ===\n\n";

  let start_time = Sys.time () in

  (* 测试数据库构建性能 *)
  clear_cache ();
  let _ = get_unified_database () in
  let build_time = Sys.time () -. start_time in

  (* 测试查询性能 *)
  let query_start = Sys.time () in
  for _i = 1 to 1000 do
    ignore (is_char_in_database "鱼")
  done;
  let query_time = Sys.time () -. query_start in

  Printf.printf "1. 性能统计:\n";
  Printf.printf "   数据库构建时间: %.6f 秒\n" build_time;
  Printf.printf "   1000次查询时间: %.6f 秒\n" query_time;
  Printf.printf "   平均单次查询时间: %.6f 秒\n" (query_time /. 1000.0);

  Printf.printf "\n"

(** 主测试函数 *)
let run_tests () =
  Printf.printf "骆言统一诗词数据加载器测试 - Phase 15 代码重复消除\n";
  Printf.printf "======================================================\n\n";

  test_basic_functionality ();
  test_query_functionality ();
  test_backward_compatibility ();
  test_performance ();

  Printf.printf "======================================================\n";
  Printf.printf "测试完成! 统一诗词数据加载器工作正常。\n"

(** 运行测试 *)
let () = run_tests ()
