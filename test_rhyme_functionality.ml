open Poetry.Unified_rhyme_api

(** 简单的韵律功能测试
    测试重构后的韵律API是否正常工作 *)

let test_rhyme_detection () =
  print_endline "=== 韵律检测功能测试 ===";
  
  (* 初始化韵律数据 *)
  initialize ();
  print_endline "✓ 韵律数据初始化完成";
  
  (* 测试基本韵律信息查找 *)
  print_endline "\n--- 测试find_rhyme_info功能 ---";
  let test_chars = ["花"; "家"; "霞"; "华"] in
  List.iter (fun char ->
    match find_rhyme_info char with
    | Some (category, group) -> Printf.printf "✓ '%s' 韵律信息: 韵类=%s, 韵组=%s\n" char 
        (match category with 
         | Poetry.Rhyme_types.PingSheng -> "平声"
         | Poetry.Rhyme_types.ZeSheng -> "仄声" 
         | Poetry.Rhyme_types.ShangSheng -> "上声"
         | Poetry.Rhyme_types.QuSheng -> "去声"
         | Poetry.Rhyme_types.RuSheng -> "入声")
        (match group with
         | Poetry.Rhyme_types.HuaRhyme -> "花韵"
         | Poetry.Rhyme_types.AnRhyme -> "安韵"
         | Poetry.Rhyme_types.SiRhyme -> "思韵"
         | Poetry.Rhyme_types.TianRhyme -> "天韵"
         | _ -> "其他韵")
    | None -> Printf.printf "✗ '%s' 未找到韵律信息\n" char
  ) test_chars;
  
  (* 测试韵律检测 *)
  print_endline "\n--- 测试check_rhyme功能 ---";
  let rhyme_pairs = [("花", "家"); ("山", "天"); ("诗", "词")] in
  List.iter (fun (char1, char2) ->
    if check_rhyme char1 char2 then
      Printf.printf "✓ '%s' 和 '%s' 押韵\n" char1 char2
    else
      Printf.printf "✗ '%s' 和 '%s' 不押韵\n" char1 char2
  ) rhyme_pairs;
  
  (* 测试韵组检测 *)
  print_endline "\n--- 测试detect_rhyme_group功能 ---";
  List.iter (fun char ->
    let group = detect_rhyme_group char in
    Printf.printf "✓ '%s' 属于韵组: %s\n" char 
        (match group with
         | Poetry.Rhyme_types.HuaRhyme -> "花韵"
         | Poetry.Rhyme_types.AnRhyme -> "安韵"
         | Poetry.Rhyme_types.SiRhyme -> "思韵"
         | Poetry.Rhyme_types.TianRhyme -> "天韵"
         | _ -> "其他韵")
  ) test_chars;
  
  (* 测试韵律一致性验证 *)
  print_endline "\n--- 测试validate_rhyme_consistency功能 ---";
  let test_lists = [
    ["花"; "家"; "华"]; (* 应该一致 *)
    ["山"; "水"; "云"]; (* 可能不一致 *)
  ] in
  List.iteri (fun i chars ->
    if validate_rhyme_consistency chars then
      Printf.printf "✓ 列表%d韵律一致: %s\n" (i+1) (String.concat ", " chars)
    else
      Printf.printf "✗ 列表%d韵律不一致: %s\n" (i+1) (String.concat ", " chars)
  ) test_lists;
  
  print_endline "\n=== 测试完成 ===\n"

let () = test_rhyme_detection ()