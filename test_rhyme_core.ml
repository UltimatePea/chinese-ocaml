(** 韵律核心模块测试程序 - 验证重构功能

    此程序测试新建的统一韵律核心模块功能是否正常

    @author 骆言诗词编程团队
    @version 3.0 - 核心重构版本测试
    @since 2025-07-25 *)

open Poetry_core.Rhyme_core_types
open Poetry_core.Rhyme_core_api

let () =
  Printf.printf "=== 韵律核心模块功能测试 ===\n\n";

  (* 测试1: 字符韵律查询 *)
  Printf.printf "测试1: 字符韵律查询\n";
  let test_chars = [ "山"; "诗"; "天"; "望" ] in
  List.iter
    (fun char ->
      match find_character_rhyme char with
      | Some entry ->
          Printf.printf "字符 '%s': 韵组=%s, 类别=%s\n" char
            (match entry.group with
            | AnRhyme -> "安韵"
            | SiRhyme -> "思韵"
            | TianRhyme -> "天韵"
            | WangRhyme -> "望韵"
            | _ -> "其他")
            (match entry.category with
            | PingSheng -> "平声"
            | ZeSheng -> "仄声"
            | QuSheng -> "去声"
            | _ -> "其他")
      | None -> Printf.printf "字符 '%s': 未找到韵律信息\n" char)
    test_chars;

  Printf.printf "\n测试2: 韵律匹配测试\n";
  let char_pairs = [ ("山", "间"); ("诗", "时"); ("天", "年") ] in
  List.iter
    (fun (c1, c2) ->
      let match_result = can_rhyme_together c1 c2 in
      Printf.printf "'%s' 与 '%s': %s (质量: %.2f)\n" c1 c2
        (if match_result.is_match then "可押韵" else "不可押韵")
        match_result.match_quality)
    char_pairs;

  Printf.printf "\n测试3: 诗句韵律分析\n";
  let test_verse = "春眠不觉晓" in
  let analysis = analyze_verse test_verse () in
  Printf.printf "诗句: %s\n" analysis.verse_text;
  Printf.printf "韵脚: %s\n" (match analysis.rhyme_ending with Some s -> s | None -> "无");
  Printf.printf "质量评分: %.2f\n" analysis.rhyme_quality_score;

  Printf.printf "\n测试4: 系统统计信息\n";
  let stats = get_system_stats () in
  List.iter (fun (key, value) -> Printf.printf "%s: %d\n" key value) stats;

  Printf.printf "\n=== 测试完成 ===\n"
