(** 韵律模块化重构测试 - 骆言诗词编程特性
    
    测试新的模块化韵律数据库是否正常工作，
    验证向后兼容性和新增功能。
    
    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-19 - Phase 14.2 模块化重构测试 *)

open Rhyme_groups.Rhyme_database

(** 测试基本功能 *)
let test_basic_functionality () =
  Printf.printf "=== 韵律模块化重构测试 ===\n\n";
  
  (* 测试数据库统计 *)
  let (total_chars, rhyme_groups, rhyme_categories) = get_database_stats () in
  Printf.printf "数据库统计信息:\n";
  Printf.printf "- 总字符数: %d\n" total_chars;
  Printf.printf "- 韵组数量: %d\n" rhyme_groups;
  Printf.printf "- 韵类数量: %d\n" rhyme_categories;
  Printf.printf "\n";

  (* 测试向后兼容接口 *)
  Printf.printf "向后兼容接口测试:\n";
  Printf.printf "- expanded_rhyme_char_count: %d\n" expanded_rhyme_char_count;
  Printf.printf "- get_expanded_rhyme_database 数量: %d\n" 
    (List.length (get_expanded_rhyme_database ()));
  Printf.printf "- 字符'鱼'是否在数据库中: %b\n" 
    (is_in_expanded_rhyme_database "鱼");
  Printf.printf "- 字符'不'是否在数据库中: %b\n" 
    (is_in_expanded_rhyme_database "不");
  Printf.printf "\n";

  (* 测试新增模块化接口 *)
  Printf.printf "新增模块化接口测试:\n";
  let yu_rhyme_data = get_rhyme_data_by_group Rhyme_groups.Rhyme_types.YuRhyme in
  let hua_rhyme_data = get_rhyme_data_by_group Rhyme_groups.Rhyme_types.HuaRhyme in
  Printf.printf "- 鱼韵组字符数: %d\n" (List.length yu_rhyme_data);
  Printf.printf "- 花韵组字符数: %d\n" (List.length hua_rhyme_data);
  Printf.printf "\n";

  (* 测试数据完整性 *)
  Printf.printf "数据完整性测试:\n";
  let (is_valid, duplicates) = validate_database () in
  Printf.printf "- 数据库是否完整: %b\n" is_valid;
  if not is_valid then (
    Printf.printf "- 重复字符: %s\n" (String.concat ", " duplicates)
  );
  Printf.printf "\n";

  (* 显示所有韵组 *)
  Printf.printf "可用韵组列表:\n";
  let all_groups = get_all_rhyme_groups () in
  List.iter (fun group ->
    let group_str = Rhyme_groups.Rhyme_types.string_of_rhyme_group group in
    let count = get_rhyme_group_char_count group in
    Printf.printf "- %s: %d个字符\n" group_str count
  ) all_groups;
  Printf.printf "\n";

  Printf.printf "=== 测试完成 ===\n"

(** 主函数 *)
let () = test_basic_functionality ()