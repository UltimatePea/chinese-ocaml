(** 对仗检查器
    
    此模块负责检查诗句的对仗是否符合格律要求。
    从原 meter_engine.ml 中提取，遵循单一职责原则。
    
    @author Alpha, 主要开发代理
    @version 1.0 
    @since 2025-07-30
    @refactor_from meter_engine.ml (解决issue #1775技术债务) *)

open Poetry_core.Poetry_types
open Meter_types

(** {1 对仗检查核心功能} *)

(** 检查对仗符合度 *)
let check_parallelism_compliance verses pattern meter_state =
  if List.length pattern.parallelism_requirements = 0 then ([], [])
  else
    let verse_array = Array.of_list verses in
    let compliance = ref [] in
    let violations = ref [] in

    List.iter
      (fun (line1_idx, line2_idx) ->
        if line1_idx <= Array.length verse_array && line2_idx <= Array.length verse_array then (
          let line1 = verse_array.(line1_idx - 1) in
          let line2 = verse_array.(line2_idx - 1) in

          (* 简单的对仗检查：字数相等 *)
          let char_count_match = String.length line1 = String.length line2 in

          (* 韵律对仗检查 *)
          let analysis1 = Rhythm_analyzer.analyze_verse_rhythm line1 meter_state.rhythm_analyzer in
          let analysis2 = Rhythm_analyzer.analyze_verse_rhythm line2 meter_state.rhythm_analyzer in
          let pattern_match =
            List.length analysis1.rhyme_pattern = List.length analysis2.rhyme_pattern
          in

          let is_compliant = char_count_match && pattern_match in
          compliance := is_compliant :: !compliance;

          if not is_compliant then
            violations := Printf.sprintf "第%d行与第%d行对仗不符" line1_idx line2_idx :: !violations))
      pattern.parallelism_requirements;

    (List.rev !compliance, List.rev !violations)

(** {1 对仗分析辅助功能} *)

(** 验证对仗要求合法性 *)
let validate_parallelism_requirements pattern =
  List.for_all
    (fun (line1, line2) ->
      line1 >= 1 && line1 <= pattern.required_lines && line2 >= 1 && line2 <= pattern.required_lines
      && line1 <> line2)
    pattern.parallelism_requirements

(** 计算对仗符合度得分 *)
let calculate_parallelism_score compliance =
  if List.length compliance = 0 then 1.0
  else
    let compliant_pairs = List.fold_left (fun acc b -> if b then acc + 1 else acc) 0 compliance in
    float_of_int compliant_pairs /. float_of_int (List.length compliance)

(** 生成对仗违规建议 *)
let generate_parallelism_suggestions violations =
  if List.length violations = 0 then []
  else
    let suggestion_base = "完善对仗结构：" in
    let specific_suggestions =
      if List.length violations <= 2 then [ "重点调整违规行对的对仗关系"; "确保对仗句字数相等、平仄相对" ]
      else [ "建议参考标准对仗格式进行全面调整"; "注意词性相对、意义相关的要求" ]
    in
    [ suggestion_base ] @ specific_suggestions

(** {1 高级对仗分析} *)

(** 对仗类型 *)
type parallelism_type =
  | StrictParallelism  (** 严格对仗 *)
  | LooseParallelism  (** 宽松对仗 *)
  | NoParallelism  (** 无对仗要求 *)

type parallelism_quality = {
  parallelism_type : parallelism_type;
  structural_score : float;  (** 结构对仗得分 *)
  semantic_score : float;  (** 语义对仗得分 *)
  tonal_score : float;  (** 平仄对仗得分 *)
  overall_score : float;  (** 综合对仗得分 *)
}
(** 对仗质量评估结果 *)

(** 分析对仗质量 *)
let analyze_parallelism_quality verses pattern meter_state =
  if List.length pattern.parallelism_requirements = 0 then
    {
      parallelism_type = NoParallelism;
      structural_score = 1.0;
      semantic_score = 1.0;
      tonal_score = 1.0;
      overall_score = 1.0;
    }
  else
    let verse_array = Array.of_list verses in
    let structural_scores = ref [] in
    let tonal_scores = ref [] in

    List.iter
      (fun (line1_idx, line2_idx) ->
        if line1_idx <= Array.length verse_array && line2_idx <= Array.length verse_array then (
          let line1 = verse_array.(line1_idx - 1) in
          let line2 = verse_array.(line2_idx - 1) in

          (* 结构对仗评分 *)
          let len1 = String.length line1 in
          let len2 = String.length line2 in
          let struct_score = if len1 = len2 then 1.0 else 0.5 in
          structural_scores := struct_score :: !structural_scores;

          (* 平仄对仗评分 *)
          let analysis1 = Rhythm_analyzer.analyze_verse_rhythm line1 meter_state.rhythm_analyzer in
          let analysis2 = Rhythm_analyzer.analyze_verse_rhythm line2 meter_state.rhythm_analyzer in
          let tonal_score =
            if List.length analysis1.rhyme_pattern = List.length analysis2.rhyme_pattern then
              let opposites =
                List.map2
                  (fun c1 c2 ->
                    match (c1, c2) with PingSheng, ZeSheng | ZeSheng, PingSheng -> 1.0 | _ -> 0.0)
                  analysis1.rhyme_pattern analysis2.rhyme_pattern
              in
              if List.length opposites > 0 then
                List.fold_left ( +. ) 0.0 opposites /. float_of_int (List.length opposites)
              else 0.0
            else 0.0
          in
          tonal_scores := tonal_score :: !tonal_scores))
      pattern.parallelism_requirements;

    let avg_structural =
      if List.length !structural_scores > 0 then
        List.fold_left ( +. ) 0.0 !structural_scores
        /. float_of_int (List.length !structural_scores)
      else 1.0
    in

    let avg_tonal =
      if List.length !tonal_scores > 0 then
        List.fold_left ( +. ) 0.0 !tonal_scores /. float_of_int (List.length !tonal_scores)
      else 1.0
    in

    let semantic_score = 0.8 in
    (* 语义对仗需要更复杂的NLP分析，暂定固定值 *)
    let overall_score = (avg_structural +. semantic_score +. avg_tonal) /. 3.0 in

    let parallelism_type =
      if overall_score >= 0.8 then StrictParallelism
      else if overall_score >= 0.5 then LooseParallelism
      else NoParallelism
    in

    {
      parallelism_type;
      structural_score = avg_structural;
      semantic_score;
      tonal_score = avg_tonal;
      overall_score;
    }

(** {1 对仗模式定义} *)

(** 标准对仗模式 *)
let get_standard_parallelism_patterns form =
  match form with
  | LuShi _ ->
      (* 律诗标准对仗：颔联(3,4句)和颈联(5,6句) *)
      [ (3, 4); (5, 6) ]
  | JueJu _ ->
      (* 绝句一般不要求对仗 *)
      []
  | Ci _ | Qu _ ->
      (* 词曲对仗要求复杂，需要根据具体词牌曲牌确定 *)
      []
  | GuTi | ZiYou ->
      (* 古体诗和自由体不限对仗 *)
      []

(** 检查对仗模式是否符合传统要求 *)
let validate_traditional_parallelism pattern =
  let expected_patterns = get_standard_parallelism_patterns pattern.form in
  List.for_all (fun pair -> List.mem pair expected_patterns) pattern.parallelism_requirements
