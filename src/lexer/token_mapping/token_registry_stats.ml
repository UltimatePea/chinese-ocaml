(** Token注册器 - 统计和验证功能 *)

open Token_registry_core

(** 统计信息 *)
let get_registry_stats () =
  let all_mappings = get_all_mappings () in
  let total = List.length all_mappings in
  let categories =
    List.map (fun entry -> entry.category) all_mappings |> List.sort_uniq String.compare
  in
  let category_counts =
    List.map (fun cat -> (cat, List.length (get_mappings_by_category cat))) categories
  in
  Printf.sprintf {|
=== Token注册器统计 ===
注册Token数: %d 个
分类数: %d 个
分类详情: %s
  |} total
    (List.length categories)
    (String.concat ", "
       (List.map (fun (cat, count) -> Printf.sprintf "%s(%d)" cat count) category_counts))

(** 验证注册器一致性 *)
let validate_registry () =
  let mappings = get_all_mappings () in
  let duplicates =
    List.fold_left
      (fun acc entry ->
        let count =
          List.length (List.filter (fun e -> e.source_token = entry.source_token) mappings)
        in
        if count > 1 then entry.source_token :: acc else acc)
      [] mappings
    |> List.sort_uniq String.compare
  in

  if duplicates = [] then Printf.printf "✅ Token注册器验证通过，无重复映射\n"
  else Printf.printf "❌ Token注册器验证失败，发现重复映射: %s\n" (String.concat ", " duplicates)
