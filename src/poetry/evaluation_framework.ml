(** 通用诗词评价框架模块 - 提供各种诗词形式共用的评价工具和基础设施 *)

open Artistic_types
open Artistic_evaluators

(** 权重配置类型 *)
type evaluation_weights = {
  rhyme_weight : float;
  tone_weight : float;
  parallelism_weight : float;
  imagery_weight : float;
  rhythm_weight : float;
  elegance_weight : float;
}

(** 计算声调得分 *)
let calculate_tone_scores verses expected_patterns =
  let scores =
    Array.mapi
      (fun i verse ->
        match expected_patterns with
        | Some patterns when i < Array.length patterns ->
            evaluate_tonal_balance verse (Some patterns.(i))
        | _ -> evaluate_tonal_balance verse None)
      verses
  in
  Array.fold_left ( +. ) 0.0 scores /. float_of_int (Array.length scores)

(** 计算对仗得分 *)
let calculate_parallelism_scores verses parallelism_pairs =
  let scores =
    List.map
      (fun (i, j) ->
        if i < Array.length verses && j < Array.length verses then
          evaluate_parallelism verses.(i) verses.(j)
        else 0.0)
      parallelism_pairs
  in
  match scores with
  | [] -> 0.0
  | _ -> List.fold_left ( +. ) 0.0 scores /. float_of_int (List.length scores)

(** 计算整体等级 *)
let calculate_overall_grade weights (rhyme, tone, parallelism, imagery, rhythm, elegance) =
  let total_score =
    (rhyme *. weights.rhyme_weight) +. (tone *. weights.tone_weight)
    +. (parallelism *. weights.parallelism_weight)
    +. (imagery *. weights.imagery_weight)
    +. (rhythm *. weights.rhythm_weight)
    +. (elegance *. weights.elegance_weight)
  in
  if total_score >= 0.8 then Excellent
  else if total_score >= 0.7 then Good
  else if total_score >= 0.6 then Fair
  else Poor

(** 创建评价结果 *)
let create_evaluation_result verse (rhyme, tone, parallelism, imagery, rhythm, elegance) suggestions =
  {
    verse;
    rhyme_score = rhyme;
    tone_score = tone;
    parallelism_score = parallelism;
    imagery_score = imagery;
    rhythm_score = rhythm;
    elegance_score = elegance;
    overall_grade = Fair; (* 会被后续覆盖 *)
    suggestions;
  }

(** 创建错误评价结果 *)
let create_error_evaluation verses error_message =
  {
    verse = String.concat "\n" (Array.to_list verses);
    rhyme_score = 0.0;
    tone_score = 0.0;
    parallelism_score = 0.0;
    imagery_score = 0.0;
    rhythm_score = 0.0;
    elegance_score = 0.0;
    overall_grade = Poor;
    suggestions = [ error_message ];
  }