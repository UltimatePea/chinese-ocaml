(** 测试韵律数据验证功能 - 验证 #1806 修复 *)

open Poetry_core.Rhyme_core_types
open Src.Poetry.Rhyme_data.Rhyme_data_registry

let test_data_integrity () =
  Printf.printf "=== 韵律数据验证测试 ===\n\n";
  
  (* 运行数据完整性检查 *)
  Printf.printf "1. 运行数据完整性检查:\n";
  let is_valid = check_data_integrity () in
  Printf.printf "验证结果: %s\n\n" (if is_valid then "通过" else "失败");
  
  (* 检查具体的韵组数据 *)
  Printf.printf "2. 检查月韵和雪韵的数据:\n";
  let yue_data = get_rhyme_data_by_group YueRhyme in
  let xue_data = get_rhyme_data_by_group XueRhyme in
  
  Printf.printf "月韵字符: ";
  List.iter (fun entry -> Printf.printf "%s " entry.character) yue_data.entries;
  Printf.printf "\n";
  
  Printf.printf "雪韵字符: ";
  List.iter (fun entry -> Printf.printf "%s " entry.character) xue_data.entries;
  Printf.printf "\n\n";
  
  (* 检查'雪'字是否只出现在月韵中 *)
  let yue_has_xue = List.exists (fun entry -> entry.character = "雪") yue_data.entries in
  let xue_has_xue = List.exists (fun entry -> entry.character = "雪") xue_data.entries in
  
  Printf.printf "3. '雪'字分布检查:\n";
  Printf.printf "月韵包含'雪': %s\n" (if yue_has_xue then "是" else "否");
  Printf.printf "雪韵包含'雪': %s\n" (if xue_has_xue then "是" else "否");
  
  let fix_status = yue_has_xue && not xue_has_xue in
  Printf.printf "%s '雪'字重复问题%s\n" 
    (if fix_status then "✓" else "✗")
    (if fix_status then "已修复！" else "仍存在");
  
  Printf.printf "\n=== 测试完成 ===\n";
  is_valid && fix_status

let () = 
  let success = test_data_integrity () in
  if success then
    Printf.printf "\n🎉 所有测试通过！Issue #1806 已解决。\n"
  else
    Printf.printf "\n❌ 测试失败，需要进一步修复。\n"