(** 韵律符合性检查器
    
    此模块负责验证诗句的韵律是否符合格律要求。
    从原 meter_engine.ml 中提取，专门负责韵律相关的检查功能。
    
    @author Alpha, 主要开发代理
    @version 1.0
    @since 2025-07-30
    @refactor_from meter_engine.ml (解决issue #1775技术债务) *)

open Poetry_core.Poetry_types
open Meter_types
open Rhythm_analyzer

type rhyme_check_result = {
  rhyme_compliance : bool list;
  rhyme_violations : string list;
  detected_scheme : rhyme_group option list;
  expected_scheme : rhyme_group option list;
}
(** 韵律检查结果类型 *)

type rhyme_usage_stats = {
  total_lines : int;
  rhyming_lines : int;
  non_rhyming_lines : int;
  rhyme_ratio : float;
  unique_rhyme_groups : int;
}
(** 韵律使用统计结果类型 *)

(** {1 韵律检查核心功能} *)

(** 检查韵律符合度 *)
let check_rhyme_compliance verses (pattern : meter_pattern) rhythm_analyzer_state =
  if List.length pattern.rhyme_scheme = 0 then
    (* 古体诗不限韵律 *)
    {
      rhyme_compliance = List.map (fun _ -> true) verses;
      rhyme_violations = [];
      detected_scheme = List.map (fun _ -> None) verses;
      expected_scheme = pattern.rhyme_scheme;
    }
  else
    let multi_analysis = analyze_multi_verse_rhythm verses rhythm_analyzer_state in
    let actual_scheme = multi_analysis.rhyme_scheme in

    let compliance =
      List.map2
        (fun actual_opt expected_opt ->
          match (actual_opt, expected_opt) with
          | Some actual, Some expected -> actual = expected
          | None, None -> true
          | _, _ -> false)
        actual_scheme pattern.rhyme_scheme
    in

    let violations =
      List.mapi
        (fun i ((actual_opt, expected_opt), compliant) ->
          if not compliant then
            let actual_str =
              Option.map rhyme_group_to_string actual_opt |> Option.value ~default:"无韵"
            in
            let expected_str =
              Option.map rhyme_group_to_string expected_opt |> Option.value ~default:"无韵"
            in
            Some (Printf.sprintf "第%d行韵律不符：要求%s，实际%s" (i + 1) expected_str actual_str)
          else None)
        (List.combine (List.combine actual_scheme pattern.rhyme_scheme) compliance)
      |> List.filter_map (fun x -> x)
    in

    {
      rhyme_compliance = compliance;
      rhyme_violations = violations;
      detected_scheme = actual_scheme;
      expected_scheme = pattern.rhyme_scheme;
    }

(** {1 韵律分析辅助功能} *)

(** 获取单行的韵组 *)
let get_line_rhyme_group line rhythm_analyzer_state =
  let analysis = analyze_verse_rhythm line rhythm_analyzer_state in
  match analysis.rhyme_ending with
  | Some ending -> (
      match analyze_character ending rhythm_analyzer_state with
      | { group = Some group; _ } -> Some group
      | _ -> None)
  | None -> None

(** 分析诗句的韵律模式 *)
let analyze_rhyme_pattern verses rhythm_analyzer_state =
  let multi_analysis = analyze_multi_verse_rhythm verses rhythm_analyzer_state in
  multi_analysis.rhyme_scheme

(** 检查两行是否押韵 *)
let check_lines_rhyme line1 line2 rhythm_analyzer_state =
  let group1 = get_line_rhyme_group line1 rhythm_analyzer_state in
  let group2 = get_line_rhyme_group line2 rhythm_analyzer_state in
  match (group1, group2) with
  | Some g1, Some g2 -> g1 = g2
  | None, None -> false (* 都无韵不算押韵 *)
  | _ -> false

(** {1 韵律符合度计算} *)

(** 计算韵律符合度得分 *)
let calculate_rhyme_compliance_score rhyme_compliance =
  if List.length rhyme_compliance = 0 then 1.0
  else
    let compliant_count =
      List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 rhyme_compliance
    in
    float_of_int compliant_count /. float_of_int (List.length rhyme_compliance)

(** 生成韵律相关的改进建议 *)
let generate_rhyme_suggestions rhyme_violations expected_scheme =
  let suggestions = ref [] in

  if List.length rhyme_violations > 0 then (
    suggestions := "调整用韵以符合格律要求" :: !suggestions;

    (* 根据预期韵式给出具体建议 *)
    let rhyme_positions =
      List.mapi
        (fun i opt -> match opt with Some _ -> Some (i + 1) | None -> None)
        expected_scheme
      |> List.filter_map (fun x -> x)
    in

    if List.length rhyme_positions > 0 then
      let pos_str = String.concat "、" (List.map string_of_int rhyme_positions) in
      suggestions := Printf.sprintf "第%s行需要押韵" pos_str :: !suggestions);

  !suggestions

(** {1 韵律模式验证} *)

(** 验证韵律模式的有效性 *)
let validate_rhyme_scheme scheme =
  let has_rhyme = List.exists (function Some _ -> true | None -> false) scheme in
  let rhyme_count =
    List.fold_left (fun acc opt -> match opt with Some _ -> acc + 1 | None -> acc) 0 scheme
  in

  if not has_rhyme then (false, [ "韵律模式中没有押韵要求" ])
  else if rhyme_count < 2 then (false, [ "韵律模式中押韵行数不足" ])
  else (true, [])

(** 比较两个韵律模式的相似度 *)
let compare_rhyme_schemes scheme1 scheme2 =
  if List.length scheme1 <> List.length scheme2 then 0.0
  else
    let matches =
      List.map2
        (fun opt1 opt2 ->
          match (opt1, opt2) with
          | Some g1, Some g2 -> if g1 = g2 then 1.0 else 0.0
          | None, None -> 1.0
          | _ -> 0.0)
        scheme1 scheme2
    in
    let total_score = List.fold_left ( +. ) 0.0 matches in
    total_score /. float_of_int (List.length matches)

(** {1 韵律统计分析} *)

(** 统计韵律使用情况 *)
let analyze_rhyme_usage verses rhythm_analyzer_state =
  let rhyme_groups =
    List.map (fun verse -> get_line_rhyme_group verse rhythm_analyzer_state) verses
  in
  let rhyme_count =
    List.fold_left (fun acc opt -> match opt with Some _ -> acc + 1 | None -> acc) 0 rhyme_groups
  in
  let total_lines = List.length verses in

  {
    total_lines;
    rhyming_lines = rhyme_count;
    non_rhyming_lines = total_lines - rhyme_count;
    rhyme_ratio =
      (if total_lines = 0 then 0.0 else float_of_int rhyme_count /. float_of_int total_lines);
    unique_rhyme_groups =
      rhyme_groups |> List.filter_map (fun x -> x) |> List.sort_uniq compare |> List.length;
  }
