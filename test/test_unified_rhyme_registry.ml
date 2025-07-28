(** 统一韵律数据注册中心测试模块
    
    测试新的统一韵律数据注册中心是否正确工作，验证技术债务重构的效果。
    
    Author: Alpha, 主要工作代理
    @since 2025-07-27 - Poetry模块技术债务专项整合 - Fix #1528 *)

open Poetry.Unified_rhyme_registry
open Poetry.Rhyme_types

(** 辅助函数：取列表前n个元素 *)
let rec take n lst =
  if n <= 0 then []
  else match lst with
    | [] -> []
    | h :: t -> h :: take (n - 1) t

(** 测试基本查询功能 *)
let test_basic_lookup () =
  Printf.printf "=== 测试统一韵律数据注册中心基本查询功能 ===\n";
  
  (* 测试安韵组字符查询 *)
  let test_chars = ["安"; "山"; "间"; "闲"] in
  List.iter (fun char ->
    match lookup_character char with
    | Some (category, group) ->
        Printf.printf "字符 '%s': %s %s\n" char 
          (rhyme_category_to_string category) 
          (rhyme_group_to_string group)
    | None -> Printf.printf "字符 '%s': 未找到\n" char
  ) test_chars;
  
  (* 测试思韵组字符查询 *)
  let si_chars = ["思"; "诗"; "时"; "知"] in
  List.iter (fun char ->
    match lookup_character char with
    | Some (category, group) ->
        Printf.printf "字符 '%s': %s %s\n" char 
          (rhyme_category_to_string category) 
          (rhyme_group_to_string group)
    | None -> Printf.printf "字符 '%s': 未找到\n" char
  ) si_chars;
  
  Printf.printf "\n"

(** 测试同韵检查功能 *)
let test_rhyme_matching () =
  Printf.printf "=== 测试同韵检查功能 ===\n";
  
  let test_pairs = [
    ("安", "山");   (* 应该同韵 - 安韵组 *)
    ("思", "诗");   (* 应该同韵 - 思韵组 *)
    ("天", "年");   (* 应该同韵 - 天韵组 *)
    ("安", "思");   (* 应该不同韵 *)
    ("山", "诗");   (* 应该不同韵 *)
  ] in
  
  List.iter (fun (char1, char2) ->
    let same_rhyme = is_same_rhyme char1 char2 in
    Printf.printf "'%s' 与 '%s' %s\n" char1 char2 
      (if same_rhyme then "同韵" else "不同韵")
  ) test_pairs;
  
  Printf.printf "\n"

(** 测试平仄声判断功能 *)
let test_tone_detection () =
  Printf.printf "=== 测试平仄声判断功能 ===\n";
  
  let ping_chars = ["安"; "思"; "天"; "风"] in
  let ze_chars = ["花"; "月"; "江"; "去"] in
  
  Printf.printf "平声字符测试:\n";
  List.iter (fun char ->
    let is_ping = is_ping_sheng_char char in
    Printf.printf "'%s': %s\n" char (if is_ping then "平声" else "非平声")
  ) ping_chars;
  
  Printf.printf "\n仄声字符测试:\n";
  List.iter (fun char ->
    let is_ze = is_ze_sheng_char char in
    Printf.printf "'%s': %s\n" char (if is_ze then "仄声" else "非仄声")
  ) ze_chars;
  
  Printf.printf "\n"

(** 测试韵组数据获取功能 *)
let test_group_data_access () =
  Printf.printf "=== 测试韵组数据获取功能 ===\n";
  
  let test_groups = [AnRhyme; SiRhyme; TianRhyme] in
  
  List.iter (fun group ->
    match get_rhyme_group_registry group with
    | Some registry ->
        Printf.printf "韵组: %s\n" (rhyme_group_to_string group);
        Printf.printf "描述: %s\n" registry.description;
        Printf.printf "字符数: %d\n" (List.length registry.entries);
        let first_chars = take (min 5 (List.length registry.entries)) registry.entries in
        let char_str = String.concat ", " (List.map (fun e -> e.character) first_chars) in
        Printf.printf "示例字符: %s...\n" char_str;
        Printf.printf "\n"
    | None ->
        Printf.printf "韵组 %s: 未找到数据\n\n" (rhyme_group_to_string group)
  ) test_groups

(** 测试统计信息功能 *)
let test_statistics () =
  Printf.printf "=== 测试统计信息功能 ===\n";
  let stats = get_registry_statistics () in
  Printf.printf "%s\n\n" stats

(** 测试向后兼容接口 *)
let test_backward_compatibility () =
  Printf.printf "=== 测试向后兼容接口 ===\n";
  
  (* 测试简单查询接口 *)
  let test_chars = ["安"; "思"; "天"] in
  List.iter (fun char ->
    match simple_lookup char with
    | Some (c, category, group) ->
        Printf.printf "兼容查询 '%s': (%s, %s, %s)\n" c c
          (rhyme_category_to_string category) 
          (rhyme_group_to_string group)
    | None -> Printf.printf "兼容查询 '%s': 未找到\n" char
  ) test_chars;
  
  (* 测试韵组数据获取接口 *)
  Printf.printf "\n安韵组兼容数据 (前5个):\n";
  let an_data = get_rhyme_group_data AnRhyme in
  let first_5 = take (min 5 (List.length an_data)) an_data in
  List.iter (fun (char, category, group) ->
    Printf.printf "('%s', %s, %s)\n" char 
      (rhyme_category_to_string category) 
      (rhyme_group_to_string group)
  ) first_5;
  
  Printf.printf "\n"

(** 主测试函数 *)
let run_tests () =
  Printf.printf "开始测试统一韵律数据注册中心...\n\n";
  
  test_basic_lookup ();
  test_rhyme_matching ();
  test_tone_detection ();
  test_group_data_access ();
  test_statistics ();
  test_backward_compatibility ();
  
  Printf.printf "统一韵律数据注册中心测试完成!\n";
  Printf.printf "如果看到此消息，说明新的统一系统工作正常，可以替代重复的旧模块。\n"

(** 运行测试 *)
let () = run_tests ()