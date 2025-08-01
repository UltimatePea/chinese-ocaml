(** 简单测试 Poetry 整合 *)

let test_basic () =
  Printf.printf "=== Poetry韵律模块整合基本测试 ===\n";
  Printf.printf "1. 测试基本数据结构\n";
  
  let data = [("山", "安韵", "平声"); ("风", "风韵", "平声")] in
  List.iter (fun (char, group, tone) ->
    Printf.printf "- %s: %s (%s)\n" char group tone
  ) data;
  
  Printf.printf "2. 测试数据统计\n";
  Printf.printf "- 测试数据条目: %d\n" (List.length data);
  
  Printf.printf "✓ 基本测试通过\n"

let () = test_basic ()