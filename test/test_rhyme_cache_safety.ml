(** 韵律缓存安全性测试 - 简化版本

    验证简化的缓存模块的安全性，确保无全局状态风险。 修复 Issue #1463 中的架构问题。

    Author: Alpha, 主工作代理 Fix #1463 - 简化架构后的安全性验证 *)

open Utils.Rhyme_data_utils
open Alcotest

(** 缓存安全性测试模块 - 简化版本 *)
module CacheSafetyTests = struct
  (** 测试简单缓存功能 *)
  let test_simple_cache () =
    let get, put, _stats = create_simple_cache 10 in
    let test_key = (PingSheng, FengRhyme) in
    let test_data = [ "春"; "花" ] in

    (* 测试存储和获取 *)
    put test_key test_data;
    match get test_key with
    | Some data -> Alcotest.(check (list string)) "缓存数据匹配" test_data data
    | None -> Alcotest.fail "缓存应该返回数据"

  (** 测试缓存容量限制 *)
  let test_cache_capacity () =
    let get, put, _stats = create_simple_cache 2 in

    (* 填充超过容量的数据 *)
    put (PingSheng, FengRhyme) [ "春" ];
    put (ZeSheng, YueRhyme) [ "花" ];
    put (ShangSheng, TianRhyme) [ "秋" ];

    (* 这应该触发清空 *)

    (* 验证缓存仍然工作 *)
    put (QuSheng, WangRhyme) [ "月" ];
    match get (QuSheng, WangRhyme) with
    | Some data -> Alcotest.(check (list string)) "缓存清空后仍能工作" [ "月" ] data
    | None -> Alcotest.fail "缓存清空后应该仍能存储新数据"

  (** 测试韵律数据验证功能 *)
  let test_rhyme_validation () =
    let entries = create_rhyme_entries [ "春"; "花" ] PingSheng FengRhyme in
    let validator = create_rhyme_validator entries in

    Alcotest.(check bool) "应该验证存在的字符" true (validator "春");
    Alcotest.(check bool) "应该拒绝不存在的字符" false (validator "雪")

  (** 测试韵律匹配功能 *)
  let test_rhyme_matching () =
    let entries = create_rhyme_entries [ "春"; "花" ] PingSheng FengRhyme in
    let matcher = create_rhyme_matcher entries in

    match matcher "春" with
    | Some group -> Alcotest.(check string) "应该匹配正确的韵组" "风韵" (string_of_rhyme_group group)
    | None -> Alcotest.fail "应该找到韵组"
end

(** 测试套件 *)
let cache_safety_tests =
  [
    ("简单缓存功能", `Quick, CacheSafetyTests.test_simple_cache);
    ("缓存容量限制", `Quick, CacheSafetyTests.test_cache_capacity);
    ("韵律数据验证", `Quick, CacheSafetyTests.test_rhyme_validation);
    ("韵律匹配功能", `Quick, CacheSafetyTests.test_rhyme_matching);
  ]

let () = run "韵律缓存安全性测试" [ ("缓存安全性", cache_safety_tests) ]
