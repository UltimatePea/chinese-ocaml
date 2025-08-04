(* Updated to use new consolidated poetry rhyme module *)
open Poetry_rhyme.Rhyme_query

let () =
  print_endline "=== 测试统一韵律数据模块 ===";

  (* 测试基本查询功能 *)
  print_endline "测试字符查询:";
  let test_chars = [ "山"; "时"; "天"; "不存在" ] in
  List.iter
    (fun char ->
      match query_character_cached char with
      | Found character ->
          let cat_str =
            match character.rhyme_category with
            | Poetry_rhyme.Rhyme_types.PingSheng -> "平声"
            | Poetry_rhyme.Rhyme_types.ShangSheng -> "上声"
            | Poetry_rhyme.Rhyme_types.QuSheng -> "去声" 
            | Poetry_rhyme.Rhyme_types.RuSheng -> "入声"
            | Poetry_rhyme.Rhyme_types.ZeSheng -> "仄声"
          in
          let grp_str =
            match character.rhyme_group with
            | Poetry_rhyme.Rhyme_types.AnRhyme -> "安韵"
            | Poetry_rhyme.Rhyme_types.SiRhyme -> "思韵"
            | Poetry_rhyme.Rhyme_types.TianRhyme -> "天韵"
            | _ -> "其他韵"
          in
          Printf.printf "  %s: %s, %s\n" char cat_str grp_str
      | NotFound _ -> Printf.printf "  %s: 未找到\n" char
      | MultipleMatches chars ->
          if List.length chars > 0 then
            let first_char = List.hd chars in
            Printf.printf "  %s: 多个匹配，第一个结果\n" first_char.character
          else
            Printf.printf "  %s: 查询结果为空\n" char)
    test_chars;

  print_endline "";
  
  (* Print basic statistics instead of database info *)
  let stats = Poetry_rhyme.Rhyme_data.get_statistics () in
  Printf.printf "数据统计: 总字符数=%d, 总韵组数=%d\n" stats.total_characters stats.total_groups;

  print_endline "=== 测试完成 ==="
