(** 韵律验证模块
    
    本模块整合了原本分散的韵律验证逻辑，提供统一的验证接口。
    这是Issue #1999韵律模块整合的验证支撑部分。
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施
    
    整合来源:
    - src/poetry/rhyme/core/rhyme_validator.ml
    - 分散在各模块中的验证逻辑
    - 数据完整性检查功能
    
    @since 2025-08-04 *)

open Rhyme_types
open Rhyme_groups

(** {1 基础验证函数} *)

(** 验证字符是否为有效的韵律字符 *)
let is_valid_rhyme_character char =
  match find_character_group char with
  | Some _ -> true
  | None -> false

(** 验证声调分类是否正确 *)
let validate_tone_category char expected_tone =
  match find_character_group char with
  | Some (_, actual_tone) -> actual_tone = expected_tone
  | None -> false

(** 验证韵组分类是否正确 *)
let validate_rhyme_group char expected_group =
  match find_character_group char with
  | Some (actual_group, _) -> actual_group = expected_group
  | None -> false

(** {1 韵律匹配验证} *)

(** 验证两个字符是否押韵 *)
let validate_rhyme_match char1 char2 =
  match find_character_group char1, find_character_group char2 with
  | Some (group1, _), Some (group2, _) -> group1 = group2
  | _ -> false

(** 验证字符列表是否同韵 *)
let validate_same_rhyme characters =
  match characters with
  | [] -> true
  | [_] -> true
  | first :: rest ->
    match find_character_group first with
    | Some (expected_group, _) ->
      List.for_all (fun char ->
        match find_character_group char with
        | Some (group, _) -> group = expected_group
        | None -> false
      ) rest
    | None -> false

(** 验证平仄搭配是否合理 *)
let validate_ping_ze_pattern characters expected_pattern =
  if List.length characters <> List.length expected_pattern then false
  else
    List.for_all2 (fun char expected_ping ->
      match find_character_group char with
      | Some (_, tone) ->
        let is_ping = (tone = PingSheng) in
        is_ping = expected_ping
      | None -> false
    ) characters expected_pattern

(** {1 数据完整性验证} *)

(** 验证韵组数据完整性 *)
let validate_rhyme_data () =
  let stats = get_rhyme_statistics () in
  let issues = ref [] in
  
  (* 检查是否有字符数据 *)
  if stats.total_characters = 0 then
    issues := "韵律字符数据为空" :: !issues;
  
  (* 检查韵组覆盖 *)
  if stats.total_groups < 11 then
    issues := Printf.sprintf "韵组数量不足：期望11个，实际%d个" stats.total_groups :: !issues;
  
  (* 检查平仄分布 *)
  let ping_ratio = float_of_int stats.ping_sheng_count /. float_of_int stats.total_characters in
  if ping_ratio < 0.3 || ping_ratio > 0.8 then
    issues := Printf.sprintf "平仄比例异常：平声占比%.2f" ping_ratio :: !issues;
  
  (* 检查韵组分布均匀性 *)
  List.iter (fun (group, count) ->
    if count = 0 then
      issues := Printf.sprintf "韵组 %s 无字符数据" (string_of_rhyme_group group) :: !issues;
    if count > stats.total_characters / 2 then
      issues := Printf.sprintf "韵组 %s 字符过多：%d个" (string_of_rhyme_group group) count :: !issues;
  ) stats.group_distribution;
  
  !issues

(** 验证韵组内部一致性 *)
let validate_group_consistency group =
  let characters : rhyme_character list = get_group_characters group in
  let issues = ref [] in
  
  (* 检查韵组是否为空 *)
  if List.length characters = 0 then
    issues := Printf.sprintf "韵组 %s 为空" (string_of_rhyme_group group) :: !issues;
  
  (* 检查字符韵组一致性 *)
  List.iter (fun (char_data : rhyme_character) ->
    if char_data.rhyme_group <> group then
      issues := Printf.sprintf "字符 %s 韵组不一致" char_data.character :: !issues
  ) characters;
  
  (* 检查重复字符 *)
  let char_set = Hashtbl.create 100 in
  List.iter (fun char_data ->
    if Hashtbl.mem char_set char_data.character then
      issues := Printf.sprintf "重复字符：%s" char_data.character :: !issues
    else
      Hashtbl.add char_set char_data.character ()
  ) characters;
  
  !issues

(** {1 验证报告生成} *)

(** 生成完整的验证报告 *)
let generate_validation_report () =
  let buffer = Buffer.create 1000 in
  Buffer.add_string buffer "=== 韵律数据验证报告 ===\n\n";
  
  (* 基础统计信息 *)
  let stats = get_rhyme_statistics () in
  Buffer.add_string buffer (Printf.sprintf "总字符数: %d\n" stats.total_characters);
  Buffer.add_string buffer (Printf.sprintf "总韵组数: %d\n" stats.total_groups);
  Buffer.add_string buffer (Printf.sprintf "平声字符: %d (%.1f%%)\n" 
    stats.ping_sheng_count 
    (100.0 *. float_of_int stats.ping_sheng_count /. float_of_int stats.total_characters));
  Buffer.add_string buffer (Printf.sprintf "仄声字符: %d (%.1f%%)\n" 
    stats.ze_sheng_count
    (100.0 *. float_of_int stats.ze_sheng_count /. float_of_int stats.total_characters));
  Buffer.add_string buffer "\n";
  
  (* 数据完整性验证 *)
  let data_issues = validate_rhyme_data () in
  Buffer.add_string buffer "数据完整性验证:\n";
  if List.length data_issues = 0 then
    Buffer.add_string buffer "  ✅ 所有检查通过\n"
  else (
    List.iter (fun issue ->
      Buffer.add_string buffer (Printf.sprintf "  ❌ %s\n" issue)
    ) data_issues
  );
  Buffer.add_string buffer "\n";
  
  (* 各韵组一致性验证 *)
  Buffer.add_string buffer "韵组一致性验证:\n";
  List.iter (fun group ->
    let group_issues = validate_group_consistency group in
    if List.length group_issues = 0 then
      Buffer.add_string buffer (Printf.sprintf "  ✅ %s: 验证通过\n" (string_of_rhyme_group group))
    else (
      Buffer.add_string buffer (Printf.sprintf "  ❌ %s: 发现问题\n" (string_of_rhyme_group group));
      List.iter (fun issue ->
        Buffer.add_string buffer (Printf.sprintf "     - %s\n" issue)
      ) group_issues
    )
  ) all_rhyme_groups;
  
  Buffer.contents buffer

(** {1 快速验证接口} *)

(** 快速验证所有数据是否正常 *)
let quick_validate () =
  let data_issues = validate_rhyme_data () in
  let all_group_issues = List.fold_left (fun acc group ->
    let group_issues = validate_group_consistency group in
    acc @ group_issues
  ) [] all_rhyme_groups in
  List.length data_issues = 0 && List.length all_group_issues = 0

(** 获取验证错误总数 *)
let get_validation_error_count () =
  let data_issues = validate_rhyme_data () in
  let all_group_issues = List.fold_left (fun acc group ->
    let group_issues = validate_group_consistency group in
    acc @ group_issues
  ) [] all_rhyme_groups in
  List.length data_issues + List.length all_group_issues