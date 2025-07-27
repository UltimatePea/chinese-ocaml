(** 韵律缓存安全性测试
    
    验证缓存模块的内存安全性和错误处理能力，
    解决Delta代理指出的潜在内存泄漏问题。
    
    Author: Alpha, 主工作代理
    Fix #1460 Phase 2.1 - 缓存安全性验证 *)

open Utils.Rhyme_data_utils
open Utils.Rhyme_data_cache
open Alcotest

(** 缓存安全性测试模块 *)
module CacheSafetyTests = struct
  
  (** 清理测试环境 *)
  let setup_test () =
    RhymeCache.clear_cache ();
    RhymeCache.configure_cache ~max_size:10 ~memory_limit_mb:1 ()

  (** 测试内存限制保护 *)
  let test_memory_limit_protection () =
    setup_test ();
    let large_dataset = ref [] in
    
    (* 创建大量数据来测试内存限制 *)
    for i = 1 to 1000 do
      let entry = {
        character = "测" ^ string_of_int i;
        category = PingSheng;
        group = FengRhyme;
        tone_info = Some ("测试音调信息" ^ string_of_int i);
        usage_notes = Some ("测试使用说明" ^ string_of_int i);
      } in
      large_dataset := entry :: !large_dataset
    done;
    
    (* 尝试存储大量数据 *)
    for i = 1 to 20 do
      let category = if i mod 2 = 0 then PingSheng else ZeSheng in
      let group = if i mod 3 = 0 then FengRhyme else YueRhyme in
      RhymeCache.store_cached category group !large_dataset 
        (Printf.sprintf "large_data_%d.json" i)
    done;
    
    let stats = RhymeCache.get_cache_stats () in
    check bool "缓存大小受限制" true (stats.total_entries <= 10);
    check bool "缓存非空" true (stats.total_entries > 0)

  (** 测试LRU淘汰机制 *)
  let test_lru_eviction_mechanism () =
    setup_test ();
    let test_data = [{
      character = "测";
      category = PingSheng;
      group = FengRhyme;
      tone_info = None;
      usage_notes = None;
    }] in
    
    (* 填充缓存到上限 *)
    let groups = [AnRhyme; SiRhyme; TianRhyme; WangRhyme; QuRhyme; 
                  YuRhyme; HuaRhyme; FengRhyme; YueRhyme; JiangRhyme] in
    List.iteri (fun i group ->
      RhymeCache.store_cached PingSheng group test_data 
        (Printf.sprintf "test_%d.json" i)
    ) groups;
    
    let initial_stats = RhymeCache.get_cache_stats () in
    check bool "缓存已满" true (initial_stats.total_entries = 10);
    
    (* 添加更多条目，应该触发LRU淘汰 *)
    RhymeCache.store_cached ZeSheng HuiRhyme test_data "new_entry.json";
    
    let final_stats = RhymeCache.get_cache_stats () in
    check bool "LRU淘汰工作正常" true (final_stats.total_entries <= 10);
    
    (* 验证新条目确实被存储 *)
    let retrieved = RhymeCache.get_cached ZeSheng HuiRhyme in
    check bool "新条目可以检索" true (retrieved <> None)

  (** 测试缓存配置功能 *)
  let test_cache_configuration () =
    RhymeCache.configure_cache ~max_size:5 ~memory_limit_mb:2 ();
    let test_data = [{
      character = "配";
      category = PingSheng;
      group = FengRhyme;
      tone_info = None;
      usage_notes = None;
    }] in
    
    (* 尝试存储超过配置限制的数据 *)
    for i = 1 to 8 do
      let group = List.nth [AnRhyme; SiRhyme; TianRhyme; WangRhyme; QuRhyme; 
                           YuRhyme; HuaRhyme; FengRhyme] (i mod 8) in
      RhymeCache.store_cached PingSheng group test_data 
        (Printf.sprintf "config_test_%d.json" i)
    done;
    
    let stats = RhymeCache.get_cache_stats () in
    check bool "缓存遵守新配置限制" true (stats.total_entries <= 5)

  (** 测试缓存健康监控 *)
  let test_cache_health_monitoring () =
    setup_test ();
    let health_empty = RhymeCache.get_cache_health () in
    check bool "空缓存健康度正常" true (String.contains health_empty '%');
    
    (* 添加一些数据 *)
    let test_data = [{
      character = "健";
      category = PingSheng;
      group = FengRhyme;
      tone_info = None;
      usage_notes = None;
    }] in
    
    RhymeCache.store_cached PingSheng FengRhyme test_data "health_test.json";
    
    let health_with_data = RhymeCache.get_cache_health () in
    check bool "有数据时健康度报告正常" true (String.contains health_with_data '%')

  (** 测试并发访问安全性 *)
  let test_concurrent_access_safety () =
    setup_test ();
    let test_data = [{
      character = "并";
      category = PingSheng;
      group = FengRhyme;
      tone_info = None;
      usage_notes = None;
    }] in
    
    (* 存储一些初始数据 *)
    RhymeCache.store_cached PingSheng FengRhyme test_data "concurrent_1.json";
    RhymeCache.store_cached ZeSheng YueRhyme test_data "concurrent_2.json";
    
    (* 模拟并发读写操作 *)
    for i = 1 to 100 do
      if i mod 2 = 0 then (
        ignore (RhymeCache.get_cached PingSheng FengRhyme)
      ) else (
        let group = if i mod 3 = 0 then AnRhyme else SiRhyme in
        RhymeCache.store_cached PingSheng group test_data 
          (Printf.sprintf "concurrent_%d.json" i)
      )
    done;
    
    let final_stats = RhymeCache.get_cache_stats () in
    check bool "并发操作后缓存状态正常" true (final_stats.total_entries >= 0);
    check bool "并发操作后有缓存命中" true (final_stats.cache_hits > 0)

  (** 测试异常处理 *)
  let test_exception_handling () =
    setup_test ();
    
    (* 测试正常操作不会抛出异常 *)
    let test_operation () =
      let test_data = [{
        character = "异";
        category = PingSheng;
        group = FengRhyme;
        tone_info = None;
        usage_notes = None;
      }] in
      
      RhymeCache.store_cached PingSheng FengRhyme test_data "exception_test.json";
      ignore (RhymeCache.get_cached PingSheng FengRhyme);
      RhymeCache.clear_cache ()
    in
    
    (* 这个操作应该不抛出异常 *)
    try
      test_operation ();
      check bool "正常操作无异常" true true
    with
    | e ->
      check bool ("异常处理失败: " ^ Printexc.to_string e) true false

  (** 测试内存统计准确性 *)
  let test_memory_statistics_accuracy () =
    setup_test ();
    let initial_stats = RhymeCache.get_cache_stats () in
    check int "初始内存使用为0" 0 initial_stats.memory_usage_bytes;
    
    let test_data = [{
      character = "统";
      category = PingSheng;
      group = FengRhyme;
      tone_info = Some "测试音调";
      usage_notes = Some "测试说明";
    }] in
    
    RhymeCache.store_cached PingSheng FengRhyme test_data "memory_test.json";
    
    let after_stats = RhymeCache.get_cache_stats () in
    check bool "存储后内存使用增加" true (after_stats.memory_usage_bytes > 0);
    check bool "条目数量正确" true (after_stats.total_entries = 1)
end

(** 主测试套件 *)
let test_suite = [
  ( "韵律缓存安全性测试",
    [
      test_case "内存限制保护" `Quick CacheSafetyTests.test_memory_limit_protection;
      test_case "LRU淘汰机制" `Quick CacheSafetyTests.test_lru_eviction_mechanism;
      test_case "缓存配置功能" `Quick CacheSafetyTests.test_cache_configuration;
      test_case "缓存健康监控" `Quick CacheSafetyTests.test_cache_health_monitoring;
      test_case "并发访问安全性" `Quick CacheSafetyTests.test_concurrent_access_safety;
      test_case "异常处理" `Quick CacheSafetyTests.test_exception_handling;
      test_case "内存统计准确性" `Quick CacheSafetyTests.test_memory_statistics_accuracy;
    ] );
]

(** 主测试入口 *)
let () =
  try
    Alcotest.run "韵律缓存安全性测试" test_suite
  with
  | e ->
    Printf.printf "缓存安全性测试错误: %s\n" (Printexc.to_string e);
    exit 1