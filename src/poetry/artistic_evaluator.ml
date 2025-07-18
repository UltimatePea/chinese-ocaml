(* 诗词艺术性评价器模块 - 模块化重构版本
   专门负责诗词艺术性评价的核心模块，提供标准化的评价接口和公共功能。
   此模块遵循单一职责原则，职责明确，接口清晰。
*)

open Yyocamlc_lib
open Tone_data

(* 评价维度类型 *)
type evaluation_dimension =
  | Rhyme (* 韵律 *)
  | Tone (* 声调 *)
  | Parallelism (* 对仗 *)
  | Imagery (* 意象 *)
  | Rhythm (* 节奏 *)
  | Elegance (* 雅致 *)

(* 评价结果类型 *)
type evaluation_result = {
  dimension : evaluation_dimension;
  score : float;
  details : string option;
}

(* 评价上下文 - 包含缓存的计算结果 *)
type evaluation_context = {
  verse : string;
  char_count : int;
  char_list : string list;
  tone_lookup : (string, tone_type) Hashtbl.t;
}

(* 创建评价上下文 - 预计算常用数据 *)
let create_evaluation_context verse =
  let char_count = Utf8_utils.StringUtils.utf8_length verse in
  let char_list = Utf8_utils.StringUtils.utf8_to_char_list verse in
  
  (* 创建声调查找表以优化性能 *)
  let tone_lookup = Hashtbl.create 64 in
  List.iter (fun (char, tone) ->
    Hashtbl.replace tone_lookup char tone
  ) tone_database;
  
  { verse; char_count; char_list; tone_lookup }

(* 获取字符声调 - 使用哈希表优化 *)
let get_char_tone context char =
  try Some (Hashtbl.find context.tone_lookup char)
  with Not_found -> None

(* 评价器基类接口 *)
module type EVALUATOR = sig
  val evaluate : evaluation_context -> evaluation_result
  val get_dimension : unit -> evaluation_dimension
  val get_description : unit -> string
end

(* 韵律评价器 *)
module RhymeEvaluator : EVALUATOR = struct
  let get_dimension () = Rhyme
  let get_description () = "韵律和谐性评价"
  
  let evaluate context =
    let base_score = min (float_of_int context.char_count) 10.0 /. 10.0 in
    
    (* 检查韵脚匹配 *)
    let rhyme_score =
      if String.length context.verse >= 2 then
        let last_char = String.sub context.verse (String.length context.verse - 1) 1 in
        match get_char_tone context last_char with
        | Some LevelTone -> 0.8
        | Some _ -> 0.6
        | None -> 0.4
      else 0.4
    in
    
    let final_score = (base_score *. 0.4) +. (rhyme_score *. 0.6) in
    { dimension = Rhyme; score = final_score; details = None }
end

(* 声调评价器 *)
module ToneEvaluator : EVALUATOR = struct
  let get_dimension () = Tone
  let get_description () = "声调平衡评价"
  
  let evaluate context =
    let tone_counts =
      List.fold_left
        (fun (level, rising, departing, entering) char ->
          match get_char_tone context char with
          | Some LevelTone -> (level + 1, rising, departing, entering)
          | Some RisingTone -> (level, rising + 1, departing, entering)
          | Some DepartingTone -> (level, rising, departing + 1, entering)
          | Some EnteringTone -> (level, rising, departing, entering + 1)
          | Some FallingTone -> (level, rising, departing, entering + 1)
          | None -> (level, rising, departing, entering + 1))
        (0, 0, 0, 0) context.char_list
    in
    
    let total_chars = List.length context.char_list in
    let final_score = 
      if total_chars = 0 then 0.0
      else
        let level, rising, departing, entering = tone_counts in
        let balance =
          1.0
          -. abs_float (float_of_int level -. float_of_int (rising + departing + entering))
             /. float_of_int total_chars
        in
        max 0.0 balance
    in
    
    { dimension = Tone; score = final_score; details = None }
end

(* 对仗评价器 *)
module ParallelismEvaluator : EVALUATOR = struct
  let get_dimension () = Parallelism
  let get_description () = "对仗工整性评价"
  
  let evaluate context =
    let base_score = if context.char_count >= 4 then 0.7 else 0.5 in
    
    (* 检查是否包含对仗结构 *)
    let parallelism_keywords = [ "对仗"; "上联"; "下联"; "工整"; "相对" ] in
    let contains_parallelism =
      List.exists (fun keyword -> 
        String.contains context.verse (String.get keyword 0)
      ) parallelism_keywords
    in
    
    let final_score = if contains_parallelism then base_score +. 0.3 else base_score in
    { dimension = Parallelism; score = final_score; details = None }
end

(* 意象评价器 *)
module ImageryEvaluator : EVALUATOR = struct
  let get_dimension () = Imagery
  let get_description () = "意象深度评价"
  
  let evaluate context =
    let nature_imagery = [ "山"; "水"; "月"; "风"; "花"; "鸟"; "云"; "雨"; "雪"; "霜" ] in
    let seasonal_imagery = [ "春"; "夏"; "秋"; "冬"; "朝"; "暮"; "日"; "星" ] in
    let literary_imagery = [ "诗"; "词"; "书"; "画"; "琴"; "棋"; "茶"; "酒" ] in
    
    let count_imagery imagery_list =
      List.fold_left
        (fun acc imagery -> 
          if String.contains context.verse (String.get imagery 0) then acc + 1 else acc
        )
        0 imagery_list
    in
    
    let nature_count = count_imagery nature_imagery in
    let seasonal_count = count_imagery seasonal_imagery in
    let literary_count = count_imagery literary_imagery in
    
    let total_imagery = nature_count + seasonal_count + literary_count in
    let imagery_score = min (float_of_int total_imagery) 5.0 /. 5.0 in
    
    (* 深度加权：文学意象权重更高 *)
    let depth_score =
      (float_of_int nature_count *. 0.3)
      +. (float_of_int seasonal_count *. 0.4)
      +. (float_of_int literary_count *. 0.6)
    in
    
    let final_score = (imagery_score *. 0.6) +. (min depth_score 1.0 *. 0.4) in
    { dimension = Imagery; score = final_score; details = None }
end

(* 节奏评价器 *)
module RhythmEvaluator : EVALUATOR = struct
  let get_dimension () = Rhythm
  let get_description () = "节奏流畅性评价"
  
  let evaluate context =
    let ideal_rhythm = [ 4; 5; 7 ] in (* 四言、五言、七言 *)
    
    let rhythm_score =
      if List.mem context.char_count ideal_rhythm then 0.9
      else if context.char_count >= 4 && context.char_count <= 10 then 0.7
      else 0.5
    in
    
    (* 检查句式结构 *)
    let structure_score =
      if String.contains context.verse (String.get "，" 0) || 
         String.contains context.verse (String.get "。" 0) then 0.8
      else 0.6
    in
    
    let final_score = (rhythm_score *. 0.7) +. (structure_score *. 0.3) in
    { dimension = Rhythm; score = final_score; details = None }
end

(* 雅致评价器 *)
module EleganceEvaluator : EVALUATOR = struct
  let get_dimension () = Elegance
  let get_description () = "雅致程度评价"
  
  let evaluate context =
    let elegant_chars = [ "雅"; "韵"; "清"; "雅"; "淡"; "素"; "朴"; "简"; "洁"; "净"; "纯"; "真"; "善"; "美" ] in
    let elegant_count =
      List.fold_left
        (fun acc char -> 
          if String.contains context.verse (String.get char 0) then acc + 1 else acc
        )
        0 elegant_chars
    in
    
    let elegance_score = min (float_of_int elegant_count) 3.0 /. 3.0 in
    
    (* 避免俗词的加分 *)
    let vulgar_chars = [ "钱"; "财"; "利"; "俗"; "粗"; "低"; "劣" ] in
    let vulgar_count =
      List.fold_left
        (fun acc char -> 
          if String.contains context.verse (String.get char 0) then acc + 1 else acc
        )
        0 vulgar_chars
    in
    
    let refinement_bonus = if vulgar_count = 0 then 0.2 else 0.0 in
    let final_score = min 1.0 (elegance_score +. refinement_bonus) in
    
    { dimension = Elegance; score = final_score; details = None }
end

(* 综合评价器 - 协调各个子评价器 *)
module ComprehensiveEvaluator = struct
  let evaluators = [
    (module RhymeEvaluator : EVALUATOR);
    (module ToneEvaluator : EVALUATOR);
    (module ParallelismEvaluator : EVALUATOR);
    (module ImageryEvaluator : EVALUATOR);
    (module RhythmEvaluator : EVALUATOR);
    (module EleganceEvaluator : EVALUATOR);
  ]
  
  let evaluate_all context =
    List.map (fun (module E : EVALUATOR) -> E.evaluate context) evaluators
end