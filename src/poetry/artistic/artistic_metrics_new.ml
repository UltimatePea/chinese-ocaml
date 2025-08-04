(** ×Íz/Ä0!W - Phase 1-C !WÍ„
 *
 * d!W+z/4s$š(ÏÄ§Œ¡—
 * ÎŸ	!W-ÐÖvÍ„„øsŸý
 *
 * @author Whisky, PR Worker - Phase 1-C !WÍ„
 * @refactors Issue #2171 - Phase 1-C ãÍ„°ã
 *)

open Artistic_core
open Artistic_config

(** {1 z/4s$š} *)

(** $šz/4s *)
let determine_artistic_level overall_score =
  if overall_score >= ThresholdConfig.master_level_threshold then
    `Master
  else if overall_score >= ThresholdConfig.advanced_level_threshold then
    `Advanced
  else if overall_score >= ThresholdConfig.intermediate_level_threshold then
    `Intermediate
  else
    `Beginner

(** {1 (ÏÄ§$š} *)

type quality_scores = {
  rhyme_harmony : float;
  tonal_balance : float;
  parallelism : float;
  imagery : float;
  rhythm : float;
  elegance : float;
}

(** $štS(ÏI§ *)
let determine_overall_grade scores =
  let avg_score = 
    (scores.rhyme_harmony +. scores.tonal_balance +. scores.parallelism +. 
     scores.imagery +. scores.rhythm +. scores.elegance) /. 6.0
  in
  if avg_score >= ThresholdConfig.excellent_threshold then
    `Excellent
  else if avg_score >= ThresholdConfig.good_threshold then
    `Good
  else if avg_score >= ThresholdConfig.fair_threshold then
    `Fair
  else
    `Poor

(** {1 ¡—ýp} *)

(** ¡—üÄ *)
let calculate_comprehensive_score dimension_scores =
  let weights = WeightConfig.all_weights in
  let scores = List.map (fun ds -> ds.score) dimension_scores in
  calculate_weighted_score scores weights

(** ¡—ná¦ *)
let calculate_average_confidence dimension_scores =
  let confidences = List.map (fun ds -> ds.confidence) dimension_scores in
  let sum = List.fold_left (+.) 0.0 confidences in
  sum /. float_of_int (List.length confidences)