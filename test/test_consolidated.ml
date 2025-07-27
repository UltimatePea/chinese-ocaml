open Poetry.Consolidated_rhyme_data

let () =
  print_endline "=== 测试统一韵律数据模块 ===";

  (* 测试基本查询功能 *)
  print_endline "测试字符查询:";
  let test_chars = [ "山"; "时"; "天"; "不存在" ] in
  List.iter
    (fun char ->
      match find_rhyme_info char with
      | Some (category, group) ->
          let cat_str =
            match category with
            | Poetry.Poetry_types_consolidated.PingSheng -> "平声"
            | Poetry.Poetry_types_consolidated.ZeSheng -> "仄声"
            | Poetry.Poetry_types_consolidated.RuSheng -> "入声"
            | _ -> "其他"
          in
          let grp_str =
            match group with
            | Poetry.Poetry_types_consolidated.AnRhyme -> "安韵"
            | Poetry.Poetry_types_consolidated.SiRhyme -> "思韵"
            | Poetry.Poetry_types_consolidated.TianRhyme -> "天韵"
            | _ -> "其他韵"
          in
          Printf.printf "  %s: %s, %s\n" char cat_str grp_str
      | None -> Printf.printf "  %s: 未找到\n" char)
    test_chars;

  print_endline "";
  print_database_info ();

  print_endline "=== 测试完成 ==="
