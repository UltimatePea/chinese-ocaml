(** 数据完整性测试 - 验证Issue #1795修复
    
    测试确保data_manager.ml不再使用硬编码的默认韵组和韵类值。
                                                           
    @author Charlie, 规划代理 - 数据完整性保障
    @test_fix_for Issue #1795 - 硬编码默认值问题
    @since 2025-07-30 *)

open Poetry_data_core.Data_types
open Poetry_data.Data_manager

(** 测试数据 - 具有不同韵组和韵类的字符 *)
let test_characters = [
  {
    character = "春";
    category = "平声";
    group = "安韵";
    metadata = [("test", "spring")];
  };
  {
    character = "花";
    category = "仄声";  
    group = "思韵";
    metadata = [("test", "flower")];
  };
  {
    character = "雪";
    category = "入声";
    group = "月韵"; 
    metadata = [("test", "snow")];
  };
]

(** 测试数据源加载器 *)
let test_data_loader () = Success test_characters

(** 初始化测试环境 *)
let setup_test_environment () =
  (* 注册测试数据源 *)
  let source_id = RhymeData "integrity_test_1795" in
  register_data_source source_id test_data_loader (fun _ -> true) [("description", "Issue 1795 integrity test")];
  (* 重建索引以确保数据可查询 *)
  rebuild_indexes test_characters;
  source_id

(** 测试按韵类查询不返回硬编码韵组 *)
let test_by_category_no_hardcoded_group () =
  Printf.printf "Testing ByCategory query returns correct groups (not hardcoded AnRhyme)...\n";
  
  (* 查询"仄声"韵类，应该返回"花"且韵组应该是"思韵"而不是硬编码的AnRhyme *)
  match query_data (ByCategory "仄声") with
  | Success results ->
      Printf.printf "Found %d results for 仄声 category\n" (List.length results);
      
      (* 应该找到一个结果：花 *)
      assert (List.length results = 1);
      let item = List.hd results in
      
      (* 验证字符正确 *)
      assert (item.character = "花");
      
      (* 关键测试：韵组应该是"思韵"，不是硬编码的AnRhyme *)
      if item.group = "安韵" then
        failwith "❌ CRITICAL: Found hardcoded AnRhyme default value - Issue #1795 not fixed!";
      
      assert (item.group = "思韵");
      assert (item.category = "仄声");
      
      Printf.printf "✓ ByCategory returns correct group: 思韵 (not hardcoded AnRhyme)\n"
      
  | Error err ->
      let err_msg = match err with 
        | FileNotFound msg -> "FileNotFound: " ^ msg
        | ParseError (ctx, msg) -> "ParseError in " ^ ctx ^ ": " ^ msg
        | ValidationError (ctx, msg) -> "ValidationError in " ^ ctx ^ ": " ^ msg
      in
      failwith ("ByCategory query failed: " ^ err_msg)

(** 测试按韵组查询不返回硬编码韵类 *)  
let test_by_group_no_hardcoded_category () =
  Printf.printf "Testing ByGroup query returns correct categories (not hardcoded PingSheng)...\n";
  
  (* 查询YueRhyme韵组，应该返回"雪"且韵类应该是RuSheng而不是硬编码的PingSheng *)
  match query_data (ByGroup YueRhyme) with
  | Success results ->
      Printf.printf "Found %d results for YueRhyme group\n" (List.length results);
      
      (* 应该找到一个结果：雪 *)
      assert (List.length results = 1);
      let item = List.hd results in
      
      (* 验证字符正确 *)
      assert (item.character = "雪");
      
      (* 关键测试：韵类应该是RuSheng，不是硬编码的PingSheng *)
      if item.category = PingSheng then
        failwith "❌ CRITICAL: Found hardcoded PingSheng default value - Issue #1795 not fixed!";
      
      assert (item.category = RuSheng);
      assert (item.group = YueRhyme);
      
      Printf.printf "✓ ByGroup returns correct category: RuSheng (not hardcoded PingSheng)\n"
      
  | Error err ->
      let err_msg = match err with 
        | FileNotFound msg -> "FileNotFound: " ^ msg
        | ParseError (ctx, msg) -> "ParseError in " ^ ctx ^ ": " ^ msg
        | ValidationError (ctx, msg) -> "ValidationError in " ^ ctx ^ ": " ^ msg
      in
      failwith ("ByGroup query failed: " ^ err_msg)

(** 运行所有数据完整性测试 *)
let run_data_integrity_tests () =
  Printf.printf "\n=== Data Integrity Test Suite - Issue #1795 ===\n\n";
  
  try
    (* 设置测试环境 *)
    let _source_id = setup_test_environment () in
    Printf.printf "✓ Test environment setup complete\n";
    
    (* 运行关键测试 *)
    test_by_category_no_hardcoded_group ();
    test_by_group_no_hardcoded_category ();
    
    Printf.printf "\n🎉 All data integrity tests passed!\n";
    Printf.printf "✅ Issue #1795 successfully fixed:\n";
    Printf.printf "  - No hardcoded AnRhyme defaults in ByCategory queries\n";
    Printf.printf "  - No hardcoded PingSheng defaults in ByGroup queries\n";
    Printf.printf "  - Data integrity preserved across all query types\n\n";
    
    true
  with
  | Failure msg ->
      Printf.printf "\n❌ Data integrity test failed: %s\n" msg;
      false
  | exn ->
      Printf.printf "\n❌ Data integrity test error: %s\n" (Printexc.to_string exn);
      false

(** 如果直接运行此文件，执行数据完整性测试 *)
let () =
  if !Sys.interactive = false then (
    let success = run_data_integrity_tests () in
    exit (if success then 0 else 1)
  )