(** 平仄模式检查器
    
    此模块负责检查诗句的平仄模式是否符合格律要求。
    从原 meter_engine.ml 中提取，遵循单一职责原则。
    
    @author Alpha, 主要开发代理
    @version 1.0 
    @since 2025-07-30
    @refactor_from meter_engine.ml (解决issue #1775技术债务) *)

open Poetry_core.Poetry_types
open Meter_types

(** {1 类型定义} *)

type tonal_analysis_result = {
  pattern_type : string;
  alternation_score : float;
  balance_score : float;
  complexity_score : float;
}
(** 平仄特征分析结果 *)

(** {1 平仄检查核心功能} *)

(** 检查平仄符合度 *)
let check_tonal_compliance verses pattern meter_state =
  if List.length pattern.tonal_pattern = 0 then
    (* 古体诗不限平仄 *)
    (List.map (fun _ -> true) verses, [])
  else
    let verse_analyses =
      List.map
        (fun verse ->
          let analyzer_state = meter_state.rhythm_analyzer in
          Rhythm_analyzer.analyze_verse_rhythm verse analyzer_state)
        verses
    in
    let actual_patterns =
      List.map (fun analysis -> analysis.Rhythm_analyzer.rhyme_pattern) verse_analyses
    in

    let compliance =
      List.map2
        (fun actual expected ->
          if List.length actual = List.length expected then
            List.for_all2 (fun a e -> a = e) actual expected
          else false)
        actual_patterns pattern.tonal_pattern
    in

    let violations =
      List.mapi
        (fun i ((actual, expected), compliant) ->
          if not compliant then
            let actual_str = List.map rhyme_category_to_string actual |> String.concat "" in
            let expected_str = List.map rhyme_category_to_string expected |> String.concat "" in
            Some (Printf.sprintf "第%d行平仄不符：要求%s，实际%s" (i + 1) expected_str actual_str)
          else None)
        (List.combine (List.combine actual_patterns pattern.tonal_pattern) compliance)
      |> List.filter_map (fun x -> x)
    in
    (compliance, violations)

(** {1 平仄模式辅助功能} *)

(** 将平仄类别转换为字符串表示 *)
let rhyme_category_to_string = function
  | PingSheng -> "平"
  | ZeSheng -> "仄"
  | ShangSheng -> "上"
  | QuSheng -> "去"
  | RuSheng -> "入"

(** 验证平仄模式合法性 *)
let validate_tonal_pattern pattern =
  match pattern.form with
  | GuTi | ZiYou ->
      (* 古体诗和自由体不限平仄 *)
      true
  | _ ->
      (* 其他诗体需要验证平仄模式长度与行数匹配 *)
      List.length pattern.tonal_pattern = pattern.required_lines
      && List.for_all2
           (fun tonal_line line_length -> List.length tonal_line = line_length)
           pattern.tonal_pattern pattern.line_lengths

(** 生成平仄违规建议 *)
let generate_tonal_suggestions violations =
  if List.length violations = 0 then []
  else
    let suggestion_base = "调整平仄搭配：" in
    let specific_suggestions =
      if List.length violations <= 2 then [ "重点关注违规行的平仄调整" ] else [ "建议参考标准平仄模式进行全面调整" ]
    in
    [ suggestion_base ] @ specific_suggestions

(** {1 高级平仄分析} *)

(** 计算平仄符合度得分 *)
let calculate_tonal_score compliance =
  let total_lines = List.length compliance in
  if total_lines = 0 then 1.0
  else
    let compliant_lines = List.fold_left (fun acc b -> if b then acc + 1 else acc) 0 compliance in
    float_of_int compliant_lines /. float_of_int total_lines

(** 分析平仄模式特征 *)
let analyze_tonal_features _verses pattern =
  if List.length pattern.tonal_pattern = 0 then
    (* 古体诗特征 *)
    { pattern_type = "古体平仄"; alternation_score = 0.0; balance_score = 0.0; complexity_score = 0.0 }
  else
    (* 计算平仄交替度 *)
    let alternation_score =
      List.fold_left
        (fun acc tonal_line ->
          let alternations = ref 0 in
          for i = 0 to List.length tonal_line - 2 do
            if List.nth tonal_line i <> List.nth tonal_line (i + 1) then incr alternations
          done;
          acc +. (float_of_int !alternations /. float_of_int (max 1 (List.length tonal_line - 1))))
        0.0 pattern.tonal_pattern
      /. float_of_int (List.length pattern.tonal_pattern)
    in

    (* 计算平仄平衡度 *)
    let all_tones = List.flatten pattern.tonal_pattern in
    let ping_count =
      List.fold_left (fun acc t -> if t = PingSheng then acc + 1 else acc) 0 all_tones
    in
    let ze_count = List.length all_tones - ping_count in
    let balance_score =
      if List.length all_tones = 0 then 1.0
      else
        1.0
        -. abs_float (float_of_int ping_count -. float_of_int ze_count)
           /. float_of_int (List.length all_tones)
    in

    {
      pattern_type = "格律平仄";
      alternation_score;
      balance_score;
      complexity_score = alternation_score *. balance_score;
    }
