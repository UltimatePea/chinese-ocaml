(** 韵组统一管理模块 - 平声仄声统一管理
    
    提供平声、仄声、入声等韵组的统一管理和分类。
    整合原有的20多个独立韵组文件到统一的管理体系中。
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施
    
    @since 2025-08-03 *)

open Rhyme_core_unified
open Rhyme_data_consolidated

(** {1 韵组分类管理} *)

(** 平声韵组管理 *)
module PingShengGroups = struct
  (** 平声韵组列表 *)
  let ping_sheng_groups = [AnRhyme; SiRhyme; TianRhyme; WangRhyme; YuRhyme; FengRhyme]
  
  (** 获取所有平声韵组 *)
  let get_all_ping_groups () = ping_sheng_groups
  
  (** 检查是否为平声韵组 *)
  let is_ping_group group = List.mem group ping_sheng_groups
  
  (** 获取平声韵组的字符数据 *)
  let get_ping_group_data group =
    if is_ping_group group then
      Some (get_characters_by_group group)
    else
      None
  
  (** 获取所有平声字符 *)
  let get_all_ping_characters () =
    List.fold_left (fun acc group ->
      let chars = get_characters_by_group group in
      chars @ acc
    ) [] ping_sheng_groups
  
  (** 统计平声韵组信息 *)
  let get_ping_statistics () =
    let all_chars = get_all_ping_characters () in
    let total_count = List.length all_chars in
    let group_count = List.length ping_sheng_groups in
    let avg_chars_per_group = if group_count > 0 then total_count / group_count else 0 in
    (total_count, group_count, avg_chars_per_group)
end

(** 仄声韵组管理 *)
module ZeShengGroups = struct
  (** 仄声韵组列表 *)
  let ze_sheng_groups = [QuRhyme; HuaRhyme; JiangRhyme; HuiRhyme]
  
  (** 获取所有仄声韵组 *)
  let get_all_ze_groups () = ze_sheng_groups
  
  (** 检查是否为仄声韵组 *)
  let is_ze_group group = List.mem group ze_sheng_groups
  
  (** 获取仄声韵组的字符数据 *)
  let get_ze_group_data group =
    if is_ze_group group then
      Some (get_characters_by_group group)
    else
      None
  
  (** 获取所有仄声字符 *)
  let get_all_ze_characters () =
    List.fold_left (fun acc group ->
      let chars = get_characters_by_group group in
      chars @ acc
    ) [] ze_sheng_groups
  
  (** 统计仄声韵组信息 *)
  let get_ze_statistics () =
    let all_chars = get_all_ze_characters () in
    let total_count = List.length all_chars in
    let group_count = List.length ze_sheng_groups in
    let avg_chars_per_group = if group_count > 0 then total_count / group_count else 0 in
    (total_count, group_count, avg_chars_per_group)
end

(** 入声韵组管理 *)
module RuShengGroups = struct
  (** 入声韵组列表 *)
  let ru_sheng_groups = [YueRhyme; XueRhyme]
  
  (** 获取所有入声韵组 *)
  let get_all_ru_groups () = ru_sheng_groups
  
  (** 检查是否为入声韵组 *)
  let is_ru_group group = List.mem group ru_sheng_groups
  
  (** 获取入声韵组的字符数据 *)
  let get_ru_group_data group =
    if is_ru_group group then
      Some (get_characters_by_group group)
    else
      None
  
  (** 获取所有入声字符 *)
  let get_all_ru_characters () =
    List.fold_left (fun acc group ->
      let chars = get_characters_by_group group in
      chars @ acc
    ) [] ru_sheng_groups
  
  (** 统计入声韵组信息 *)
  let get_ru_statistics () =
    let all_chars = get_all_ru_characters () in
    let total_count = List.length all_chars in
    let group_count = List.length ru_sheng_groups in
    let avg_chars_per_group = if group_count > 0 then total_count / group_count else 0 in
    (total_count, group_count, avg_chars_per_group)
end

(** {1 统一韵组管理接口} *)

(** 韵组分类信息 *)
type group_classification = {
  group: rhyme_group;
  tone_type: rhyme_category;
  character_count: int;
  representative_chars: string list;
}

(** 获取韵组分类 *)
let classify_group group =
  let chars = get_characters_by_group group in
  let char_count = List.length chars in
  let representative_chars = 
    List.take 3 (List.map (fun ci -> ci.character) chars) in
  
  let tone_type = 
    if PingShengGroups.is_ping_group group then PingSheng
    else if ZeShengGroups.is_ze_group group then ZeSheng
    else if RuShengGroups.is_ru_group group then RuSheng
    else ZeSheng (* 默认仄声 *)
  in
  
  {
    group;
    tone_type;
    character_count = char_count;
    representative_chars;
  }

(** 获取所有韵组分类信息 *)
let get_all_group_classifications () =
  let all_groups = [AnRhyme; SiRhyme; TianRhyme; WangRhyme; QuRhyme; YuRhyme; 
                    HuaRhyme; FengRhyme; YueRhyme; XueRhyme; JiangRhyme; HuiRhyme] in
  List.map classify_group all_groups

(** 按声调类型分组 *)
let group_by_tone_type () =
  let ping_groups = PingShengGroups.get_all_ping_groups () in
  let ze_groups = ZeShengGroups.get_all_ze_groups () in
  let ru_groups = RuShengGroups.get_all_ru_groups () in
  
  [
    (PingSheng, ping_groups);
    (ZeSheng, ze_groups);
    (RuSheng, ru_groups);
  ]

(** {1 韵组匹配和查询} *)

(** 检查两个韵组是否同类 *)
let are_groups_same_type group1 group2 =
  let class1 = classify_group group1 in
  let class2 = classify_group group2 in
  class1.tone_type = class2.tone_type

(** 查找字符所属的韵组类型 *)
let find_character_group_type char =
  match find_character_info char with
  | Some char_info ->
      let classification = classify_group char_info.group in
      Some classification.tone_type
  | None -> None

(** 获取指定声调类型的所有韵组 *)
let get_groups_by_tone_type tone_type =
  match tone_type with
  | PingSheng -> PingShengGroups.get_all_ping_groups ()
  | ZeSheng -> ZeShengGroups.get_all_ze_groups ()
  | RuSheng -> RuShengGroups.get_all_ru_groups ()
  | _ -> []

(** {1 韵组平衡分析} *)

(** 韵组平衡信息 *)
type balance_info = {
  ping_sheng_count: int;
  ze_sheng_count: int;
  ru_sheng_count: int;
  total_count: int;
  ping_ratio: float;
  ze_ratio: float;
  ru_ratio: float;
  is_balanced: bool;
}

(** 分析韵组平衡 *)
let analyze_group_balance () =
  let (ping_count, _, _) = PingShengGroups.get_ping_statistics () in
  let (ze_count, _, _) = ZeShengGroups.get_ze_statistics () in
  let (ru_count, _, _) = RuShengGroups.get_ru_statistics () in
  
  let total_count = ping_count + ze_count + ru_count in
  let ping_ratio = if total_count > 0 then float_of_int ping_count /. float_of_int total_count else 0.0 in
  let ze_ratio = if total_count > 0 then float_of_int ze_count /. float_of_int total_count else 0.0 in
  let ru_ratio = if total_count > 0 then float_of_int ru_count /. float_of_int total_count else 0.0 in
  
  (* 平水韵中平声和仄声应该相对平衡 *)
  let is_balanced = ping_ratio >= 0.4 && ping_ratio <= 0.6 in
  
  {
    ping_sheng_count = ping_count;
    ze_sheng_count = ze_count;
    ru_sheng_count = ru_count;
    total_count;
    ping_ratio;
    ze_ratio;
    ru_ratio;
    is_balanced;
  }

(** 打印韵组平衡分析 *)
let print_balance_analysis () =
  let balance = analyze_group_balance () in
  Printf.printf "=== 韵组平衡分析 ===\n";
  Printf.printf "平声字符: %d (%.1f%%)\n" balance.ping_sheng_count (balance.ping_ratio *. 100.0);
  Printf.printf "仄声字符: %d (%.1f%%)\n" balance.ze_sheng_count (balance.ze_ratio *. 100.0);
  Printf.printf "入声字符: %d (%.1f%%)\n" balance.ru_sheng_count (balance.ru_ratio *. 100.0);
  Printf.printf "总字符数: %d\n" balance.total_count;
  Printf.printf "平衡状态: %s\n" (if balance.is_balanced then "✓ 平衡" else "✗ 不平衡");
  Printf.printf "==================\n"

(** {1 高级韵组操作} *)

(** 查找相似韵组 *)
let find_similar_groups group max_results =
  let target_class = classify_group group in
  let all_classifications = get_all_group_classifications () in
  
  let similar_groups = List.filter (fun class_info ->
    class_info.group <> group && 
    class_info.tone_type = target_class.tone_type
  ) all_classifications in
  
  let sorted_groups = List.sort (fun c1 c2 ->
    compare c2.character_count c1.character_count
  ) similar_groups in
  
  List.take max_results sorted_groups

(** 韵组使用建议 *)
let suggest_rhyme_groups poem_style =
  match poem_style with
  | "绝句" -> 
      Printf.printf "绝句建议使用韵组: 安韵、思韵、天韵等常用平声韵\n";
      PingShengGroups.get_all_ping_groups ()
  | "律诗" ->
      Printf.printf "律诗建议使用韵组: 平声韵为主，注意平仄搭配\n";
      PingShengGroups.get_all_ping_groups ()
  | "词" ->
      Printf.printf "词建议使用韵组: 根据词牌要求，平仄声韵组皆可\n";
      let all_groups = get_all_group_classifications () in
      List.map (fun c -> c.group) all_groups
  | _ ->
      Printf.printf "通用建议: 平声韵组较为常用\n";
      PingShengGroups.get_all_ping_groups ()

(** {1 实用工具函数} *)

(** 随机选择韵组 *)
let random_group_by_type tone_type =
  let groups = get_groups_by_tone_type tone_type in
  if List.length groups > 0 then
    let index = Random.int (List.length groups) in
    Some (List.nth groups index)
  else
    None

(** 获取韵组详细信息 *)
let get_group_detailed_info group =
  let classification = classify_group group in
  let chars = get_characters_by_group group in
  let common_chars = List.filter (fun ci -> ci.is_common) chars in
  let high_freq_chars = List.filter (fun ci -> ci.usage_frequency > 0.8) chars in
  
  Printf.printf "=== 韵组详细信息: %s ===\n" 
    (match group with
     | AnRhyme -> "安韵" | SiRhyme -> "思韵" | TianRhyme -> "天韵"
     | WangRhyme -> "王韵" | QuRhyme -> "去韵" | YuRhyme -> "鱼韵"
     | HuaRhyme -> "花韵" | FengRhyme -> "风韵" | YueRhyme -> "月韵"
     | XueRhyme -> "雪韵" | JiangRhyme -> "江韵" | HuiRhyme -> "灰韵"
     | UnknownRhyme -> "未知韵");
  Printf.printf "声调类型: %s\n" 
    (match classification.tone_type with
     | PingSheng -> "平声" | ZeSheng -> "仄声" | RuSheng -> "入声" 
     | ShangSheng -> "上声" | QuSheng -> "去声");
  Printf.printf "字符总数: %d\n" classification.character_count;
  Printf.printf "常用字数: %d\n" (List.length common_chars);
  Printf.printf "高频字数: %d\n" (List.length high_freq_chars);
  Printf.printf "代表字符: %s\n" (String.concat "、" classification.representative_chars);
  Printf.printf "========================\n"