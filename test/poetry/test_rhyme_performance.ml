(** 韵律查找性能测试 - 验证 Map 优化效果

    测试目标：
    - 验证 Map 版本比原始 List.find_opt 版本有显著性能提升
    - 确保优化前后功能完全一致
    - 提供性能基准数据

    Author: Alpha, 技术债务清理专员
    @since 2025-07-25 *)

(* 使用统一韵律模块替代已删除的Poetry_core模块 *)
open Poetry_rhyme.Rhyme_types
open Poetry_rhyme.Rhyme_query

(** 创建测试字符列表 - 包含存在和不存在的字符 *)
let test_characters =
  [
    "山";
    "间";
    "闲";
    "关";
    "还";
    "诗";
    "时";
    "知";
    "思";
    "才";
    "天";
    "年";
    "先";
    "田";
    "边";
    "望";
    "放";
    "向";
    "响";
    "上";
    "不存在1";
    "不存在2";
    "不存在3";
    "不存在4";
    "不存在5";
  ]

(** 原始的线性搜索实现 - 用于性能对比 *)
let find_character_rhyme_linear (char : string) : rhyme_character option =
  (* 模拟原始的线性搜索方式，遍历所有韵组和所有字符 *)
  let all_groups = Poetry_rhyme.Rhyme_data.get_all_groups () in
  let rec search_in_groups = function
    | [] -> None
    | group_data :: rest ->
        let rec search_in_chars = function
          | [] -> search_in_groups rest
          | rhyme_char :: chars_rest ->
              if rhyme_char.character = char then Some rhyme_char
              else search_in_chars chars_rest
        in
        (match search_in_chars (List.map Poetry_types.Poetry_types_consolidated.rhyme_character_to_char_info group_data.all_characters) with
         | Some char_info -> Some (Poetry_types.Poetry_types_consolidated.char_info_to_rhyme_character char_info)
         | None -> None)
  in
  search_in_groups all_groups

(** 性能测试辅助函数 *)
let time_function f () =
  let start_time = Sys.time () in
  let result = f () in
  let end_time = Sys.time () in
  (result, end_time -. start_time)

(** 测试功能一致性 *)
let test_functional_consistency () =
  print_endline "=== 功能一致性测试 ===";
  let inconsistent_results = ref [] in
  let consistent_count = ref 0 in

  List.iter
    (fun char ->
      let linear_result = find_character_rhyme_linear char in
      let optimized_result = match query_character_cached char with 
        | Found entry -> Some entry 
        | NotFound _ | MultipleMatches _ -> None in

      match (linear_result, optimized_result) with
      | None, None -> 
          incr consistent_count
      | Some entry1, Some entry2 when entry1.character = entry2.character -> 
          incr consistent_count
      | _ -> 
          inconsistent_results := char :: !inconsistent_results;
          Printf.printf "  不一致: %s (线性=%s, 优化=%s)\n" 
            char
            (match linear_result with | Some e -> e.character | None -> "None")
            (match optimized_result with | Some e -> e.character | None -> "None"))
    test_characters;

  Printf.printf "一致性测试结果: %d/%d 字符一致\n" !consistent_count (List.length test_characters);
  if List.length !inconsistent_results = 0 then print_endline "✅ 所有测试字符的查找结果一致"
  else (
    print_endline "❌ 发现不一致的结果:";
    List.iter (fun char -> print_endline ("  - " ^ char)) !inconsistent_results)

(** 性能基准测试 *)
let test_performance_benchmark () =
  print_endline "\n=== 性能基准测试 ===";
  let iterations = 10000 in

  (* 测试线性搜索性能 *)
  let _, linear_time =
    time_function
      (fun () ->
        for _i = 1 to iterations do
          List.iter (fun char -> ignore (find_character_rhyme_linear char)) test_characters
        done)
      ()
  in

  (* 测试优化版本性能 *)
  let _, optimized_time =
    time_function
      (fun () ->
        for _i = 1 to iterations do
          List.iter (fun char -> ignore (query_character_cached char)) test_characters
        done)
      ()
  in

  let speedup = linear_time /. optimized_time in

  Printf.printf "线性搜索版本总时间: %.6f 秒\n" linear_time;
  Printf.printf "Map优化版本总时间: %.6f 秒\n" optimized_time;
  Printf.printf "性能提升倍数: %.2fx\n" speedup;

  if speedup > 1.5 then print_endline "✅ 性能优化效果显著"
  else if speedup > 1.1 then print_endline "⚠️  性能有所提升但不明显"
  else print_endline "❌ 性能优化效果不明显"

(** 数据规模测试 *)
let test_data_scale () =
  print_endline "\n=== 数据规模分析 ===";
  let total_characters = List.length test_characters in
  Printf.printf "测试字符数: %d\n" total_characters;
  print_endline "韵律数据已加载完成"

(** 主测试函数 *)
let run_performance_tests () =
  print_endline "韵律API性能优化测试报告";
  print_endline "=====================================";

  test_functional_consistency ();
  test_performance_benchmark ();
  test_data_scale ();

  print_endline "\n测试完成 ✅"

(** 如果作为独立程序运行 *)
let () = if !Sys.interactive = false then run_performance_tests ()
