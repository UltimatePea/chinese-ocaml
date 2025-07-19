(** 测试韵律系统重构 - 验证外部化数据加载 *)

open Poetry.Rhyme_json_loader
open Poetry.Unified_rhyme_api_refactored

(** 测试JSON数据加载 *)
let test_json_loading () =
  Printf.printf "=== 测试JSON数据加载 ===\n";
  match get_rhyme_data () with
  | Some data ->
    Printf.printf "✅ JSON数据加载成功\n";
    Printf.printf "韵组数量: %d\n" (List.length data.rhyme_groups);
    List.iter (fun (name, group_data) ->
      Printf.printf "  %s: %d个字符\n" name (List.length group_data.characters)
    ) data.rhyme_groups
  | None ->
    Printf.printf "❌ JSON数据加载失败\n"

(** 测试韵律查找功能 *)
let test_rhyme_lookup () =
  Printf.printf "\n=== 测试韵律查找功能 ===\n";
  let test_chars = ["安"; "山"; "天"; "风"; "中"; "红"] in
  List.iter (fun char ->
    match find_rhyme_info char with
    | Some (category, group) ->
      let cat_name = match category with
        | PingSheng -> "平声"
        | ShangSheng -> "上声"
        | QuSheng -> "去声"
        | RuSheng -> "入声"
        | ZeSheng -> "仄声"
      in
      let group_name = match group with
        | AnRhyme -> "安韵"
        | SiRhyme -> "思韵"
        | TianRhyme -> "天韵"
        | WangRhyme -> "望韵"
        | QuRhyme -> "去韵"
        | YuRhyme -> "鱼韵"
        | HuaRhyme -> "花韵"
        | FengRhyme -> "风韵"
        | YueRhyme -> "月韵"
        | XueRhyme -> "雪韵"
        | JiangRhyme -> "江韵"
        | HuiRhyme -> "灰韵"
        | UnknownRhyme -> "未知韵"
      in
      Printf.printf "  %s: %s, %s\n" char cat_name group_name
    | None ->
      Printf.printf "  %s: 未找到韵律信息\n" char
  ) test_chars

(** 测试押韵检测 *)
let test_rhyme_checking () =
  Printf.printf "\n=== 测试押韵检测 ===\n";
  let test_pairs = [("安", "山"); ("风", "中"); ("天", "年"); ("花", "家")] in
  List.iter (fun (char1, char2) ->
    let is_rhyme = check_rhyme char1 char2 in
    Printf.printf "  %s 与 %s: %s\n" char1 char2 (if is_rhyme then "押韵" else "不押韵")
  ) test_pairs

(** 测试韵组字符获取 *)
let test_rhyme_group_chars () =
  Printf.printf "\n=== 测试韵组字符获取 ===\n";
  let test_groups = [AnRhyme; FengRhyme; HuaRhyme] in
  List.iter (fun group ->
    let chars = get_rhyme_characters group in
    let group_name = match group with
      | AnRhyme -> "安韵"
      | FengRhyme -> "风韵"
      | HuaRhyme -> "花韵"
      | _ -> "其他韵"
    in
    Printf.printf "  %s: %d个字符\n" group_name (List.length chars);
    if List.length chars > 0 then (
      let sample = List.take (min 5 (List.length chars)) chars in
      Printf.printf "    示例: %s\n" (String.concat ", " sample)
    )
  ) test_groups

(** 测试统计信息 *)
let test_statistics () =
  Printf.printf "\n=== 测试统计信息 ===\n";
  let (char_count, group_count) = get_cache_statistics () in
  Printf.printf "缓存统计: %d个字符映射, %d个韵组映射\n" char_count group_count;
  
  match get_data_statistics () with
  | Some (groups, chars) ->
    Printf.printf "数据统计: %d个韵组, %d个字符\n" groups chars
  | None ->
    Printf.printf "无法获取数据统计\n"

(** 主测试函数 *)
let main () =
  Printf.printf "开始测试韵律系统重构...\n\n";
  
  test_json_loading ();
  test_rhyme_lookup ();
  test_rhyme_checking ();
  test_rhyme_group_chars ();
  test_statistics ();
  
  Printf.printf "\n=== 测试完成 ===\n";
  
  (* 测试数据完整性 *)
  if validate_rhyme_data_integrity () then
    Printf.printf "✅ 数据完整性验证通过\n"
  else
    Printf.printf "❌ 数据完整性验证失败\n"

(** 运行测试 *)
let () = main ()