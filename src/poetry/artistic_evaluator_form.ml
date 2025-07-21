(* 诗词形式评价器模块 - 对仗、节奏、雅致评价
   
   专门负责诗词形式层面的评价，包含对仗、节奏、雅致三个维度。
   承律诗格律传统，察句式工整，观文辞典雅之美。 *)

open Artistic_evaluator_types
open Artistic_evaluator_context

(* 对仗评价器 - 律诗格律，词性相对，句式工整之美 *)
module ParallelismEvaluator : EVALUATOR = struct
  let get_dimension () = Parallelism
  let get_description () = "对仗工整性评价 - 依律诗传统，察句式相对之美"

  let evaluate context =
    let base_score = if get_char_count context >= 4 then 0.7 else 0.5 in

    (* 检查是否包含对仗结构 *)
    let parallelism_keywords = [ "对仗"; "上联"; "下联"; "工整"; "相对" ] in
    let contains_parallelism =
      List.exists
        (fun keyword -> String.contains (get_verse context) (String.get keyword 0))
        parallelism_keywords
    in

    let final_score = if contains_parallelism then base_score +. 0.3 else base_score in
    { dimension = Parallelism; score = final_score; details = None }
end

(* 节奏评价器 - 音律节拍，句式长短，韵律流动之美 *)
module RhythmEvaluator : EVALUATOR = struct
  let get_dimension () = Rhythm
  let get_description () = "节奏流畅性评价 - 依传统格律，察音律节拍之美"

  let evaluate context =
    let ideal_rhythm = [ 4; 5; 7 ] in
    (* 四言、五言、七言 - 传统诗词最常见的格律形式 *)

    let char_count = get_char_count context in
    let rhythm_score =
      if List.mem char_count ideal_rhythm then 0.9
      else if char_count >= 4 && char_count <= 10 then 0.7
      else 0.5
    in

    (* 检查句式结构 - 标点符号体现句式层次 *)
    let structure_score =
      let verse = get_verse context in
      if String.contains verse (String.get "，" 0) || String.contains verse (String.get "。" 0) then
        0.8
      else 0.6
    in

    let final_score = (rhythm_score *. 0.7) +. (structure_score *. 0.3) in
    { dimension = Rhythm; score = final_score; details = None }
end

(* 雅致评价器 - 词语典雅，格调高下，文辞品味之美 *)
module EleganceEvaluator : EVALUATOR = struct
  let get_dimension () = Elegance
  let get_description () = "雅致程度评价 - 辨词语雅俗，品文辞典雅之度"

  let evaluate context =
    (* 雅致字符列表 - 体现传统文人雅致情趣的常用字 *)
    let elegant_chars = [ "雅"; "韵"; "清"; "雅"; "淡"; "素"; "朴"; "简"; "洁"; "净"; "纯"; "真"; "善"; "美" ] in
    let elegant_count =
      List.fold_left
        (fun acc char ->
          if String.contains (get_verse context) (String.get char 0) then acc + 1 else acc)
        0 elegant_chars
    in

    let elegance_score = min (float_of_int elegant_count) 3.0 /. 3.0 in

    (* 避免俗词的评估 - 识别过于世俗化的表达 *)
    let vulgar_chars = [ "钱"; "财"; "利"; "俗"; "粗"; "低"; "劣" ] in
    let vulgar_count =
      List.fold_left
        (fun acc char ->
          if String.contains (get_verse context) (String.get char 0) then acc + 1 else acc)
        0 vulgar_chars
    in

    (* 无俗词加分，体现文辞之纯雅 *)
    let refinement_bonus = if vulgar_count = 0 then 0.2 else 0.0 in
    let final_score = min 1.0 (elegance_score +. refinement_bonus) in

    { dimension = Elegance; score = final_score; details = None }
end
