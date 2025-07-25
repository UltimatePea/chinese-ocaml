(** 韵律JSON处理整合模块测试

    测试新的整合模块是否正确工作，并验证向后兼容性。

    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-24 - Phase 7.1 JSON处理系统整合重构 *)

open Poetry.Rhyme_json_api

(** 测试核心模块功能 *)
let test_core_module () =
  Printf.printf "=== 测试韵律JSON核心模组 ===\n";

  (* 测试降级数据 *)
  let fallback_data = use_fallback_data () in
  Printf.printf "降级数据韵组数量: %d\n" (List.length fallback_data.rhyme_groups);

  (* 测试类型转换 *)
  let category = string_to_rhyme_category "平声" in
  let rhyme_group = string_to_rhyme_group "安韵" in
  Printf.printf "转换测试 - 平声: %s, 安韵: %s\n"
    (match category with PingSheng -> "平声" | _ -> "其他")
    (match rhyme_group with AnRhyme -> "安韵" | _ -> "其他");

  (* 测试缓存 *)
  let _ = clear_cache () in
  Printf.printf "缓存已清理, 缓存有效: %s\n" (if is_cache_valid () then "是" else "否");

  (* 测试统计信息 *)
  match get_data_statistics () with
  | Some (groups, chars) -> Printf.printf "统计信息 - 韵组: %d, 字符: %d\n" groups chars
  | None -> Printf.printf "无法获取统计信息\n"

(** 测试API兼容层 *)
let test_api_compatibility () =
  Printf.printf "\n=== 测试API兼容层 ===\n";

  (* 测试通过API获取数据 *)
  (match get_rhyme_data () with
  | Some data -> Printf.printf "API获取数据成功，韵组数量: %d\n" (List.length data.rhyme_groups)
  | None -> Printf.printf "API获取数据失败\n");

  (* 测试获取所有韵组 *)
  let groups = get_all_rhyme_groups () in
  Printf.printf "API获取韵组列表，数量: %d\n" (List.length groups);

  (* 测试获取韵组字符 *)
  let chars = get_rhyme_group_characters "安韵" in
  Printf.printf "安韵字符数量: %d\n" (List.length chars);

  (* 测试获取韵组韵类 *)
  let category = get_rhyme_group_category "安韵" in
  Printf.printf "安韵韵类: %s\n" (match category with PingSheng -> "平声" | ZeSheng -> "仄声" | _ -> "其他")

(** 测试子模块兼容性 *)
let test_submodule_compatibility () =
  Printf.printf "\n=== 测试子模块兼容性 ===\n";

  (* 测试Types模块 *)
  let category = Types.string_to_rhyme_category "平声" in
  Printf.printf "Types模块转换测试 - 平声: %s\n" (match category with Types.PingSheng -> "平声" | _ -> "其他");

  (* 测试Cache模块 *)
  Printf.printf "Cache模块TTL: %.0f秒\n" Cache.cache_ttl;

  (* 测试Access模块 *)
  let groups = Access.get_all_rhyme_groups () in
  Printf.printf "Access模块获取韵组: %d个\n" (List.length groups);

  (* 测试Io模块 *)
  Printf.printf "Io模块默认文件: %s\n" Io.default_data_file

(** 测试原有接口完全兼容性 *)
let test_loader_compatibility () =
  Printf.printf "\n=== 测试Loader模块兼容性 ===\n";

  (* 测试原有的rhyme_json_loader接口 *)
  let module Loader = Poetry.Rhyme_json_loader in
  (* 测试获取数据 *)
  (match Loader.get_rhyme_data () with
  | Some data -> Printf.printf "Loader获取数据成功，韵组数量: %d\n" (List.length data.rhyme_groups)
  | None -> Printf.printf "Loader获取数据失败\n");

  (* 测试获取韵组数据 *)
  let groups = Loader.get_all_rhyme_groups () in
  Printf.printf "Loader韵组数量: %d\n" (List.length groups);

  (* 测试统计功能 *)
  Loader.print_statistics ()

(** 主测试函数 *)
let run_tests () =
  test_core_module ();
  test_api_compatibility ();
  test_submodule_compatibility ();
  test_loader_compatibility ();
  Printf.printf "\n=== 整合模块测试完成 ===\n"

(** 运行测试 *)
let () = run_tests ()
