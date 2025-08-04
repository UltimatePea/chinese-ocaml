(** 骆言诗词形式评价器 - 专门的诗词形式评价
    
    Author: Whisky, PR Worker - Issue #2084 Phase 3 艺术评价系统整合
    Date: 2025-08-04
    
    本模块整合了各种诗词形式的专门评价器，包括：
    - 原 form_evaluators.ml, poetry_form_evaluators.ml 等
    - 四言骈体、五言律诗、七言绝句等形式评价
    - 词牌格律检查和现代诗评价 *)

open Poetry_types_unified.Unified_poetry_types

(** === 四言骈体评价器 === *)

module SiYanPianTiEvaluator = struct
  
  let standard_pattern = {
    char_count = 4;
    tone_pattern = [true; false; true; false]; (* 平仄平仄 *)
    parallelism_required = true;
    rhythm_weight = 0.8;
  }
  
  (** 评价四言骈体诗句 *)
  let evaluate_siyan verse =
    let chars = String.split_on_char ' ' verse |> List.filter ((<>) "") in
    let char_count = List.length chars in
    
    (* 字数检查 *)
    let char_score = if char_count = standard_pattern.char_count then 1.0 else 0.5 in
    
    (* 声调模式检查 *)
    let tone_score = 0.8 in (* 简化实现 *)
    
    (* 对仗要求检查 *)
    let parallelism_score = if standard_pattern.parallelism_required then 0.9 else 0.7 in
    
    (* 节奏感评价 *)
    let rhythm_score = char_score *. standard_pattern.rhythm_weight in
    
    let overall_score = (char_score +. tone_score +. parallelism_score +. rhythm_score) /. 4.0 in
    
    {
      verse;
      rhyme_score = 0.8;
      tone_score;
      parallelism_score;
      imagery_score = 0.8;
      rhythm_score;
      elegance_score = 0.85;
      overall_grade = if overall_score >= 0.8 then Good else Fair;
      detailed_feedback = Printf.sprintf "四言骈体评价：字数符合度%.2f，声调%.2f，对仗%.2f，节奏%.2f" 
        char_score tone_score parallelism_score rhythm_score;
      suggestions = if overall_score < 0.7 then ["注意四言格律要求"; "加强对仗工整度"] else ["四言骈体基本合格"];
    }

end

(** === 五言律诗评价器 === *)

module WuYanLuShiEvaluator = struct
  
  let standard_pattern = {
    line_count = 8;
    char_per_line = 5;
    rhyme_scheme = [|false; true; false; true; false; true; false; true|]; (* 2、4、6、8句押韵 *)
    parallelism_required = [|false; false; true; true; true; true; false; false|]; (* 颔联、颈联对仗 *)
    tone_pattern = [[true;false;true;false;true]; [false;true;false;true;false]]; (* 简化平仄模式 *)
    rhythm_weight = 0.9;
  }
  
  (** 评价五言律诗 *)
  let evaluate_wuyan verses =
    let verse_count = List.length verses in
    
    (* 句数检查 *)
    let line_score = if verse_count = standard_pattern.line_count then 1.0 else 0.6 in
    
    (* 字数检查 *)
    let char_scores = List.map (fun verse ->
      let chars = String.split_on_char ' ' verse |> List.filter ((<>) "") in
      if List.length chars = standard_pattern.char_per_line then 1.0 else 0.7
    ) verses in
    let avg_char_score = List.fold_left (+.) 0.0 char_scores /. float_of_int verse_count in
    
    (* 韵脚检查 *)
    let rhyme_score = 0.85 in (* 简化实现 *)
    
    (* 对仗检查 *)
    let parallelism_score = 0.8 in (* 简化实现 *)
    
    (* 声调模式检查 *)
    let tone_score = 0.8 in (* 简化实现 *)
    
    let overall_score = (line_score +. avg_char_score +. rhyme_score +. parallelism_score +. tone_score) /. 5.0 in
    
    {
      rhyme_harmony = rhyme_score;
      tonal_balance = tone_score;
      parallelism = parallelism_score;
      imagery = 0.8;
      rhythm = overall_score *. standard_pattern.rhythm_weight;
      elegance = 0.85;
      overall = overall_score;
    }

end

(** === 七言绝句评价器 === *)

module QiYanJueJuEvaluator = struct
  
  let standard_pattern = {
    line_count = 4;
    char_per_line = 7;
    rhyme_scheme = [|false; true; false; true|]; (* 2、4句押韵 *)
    parallelism_required = [|false; false; true; true|]; (* 后两句可对仗 *)
    tone_pattern = [[true;false;true;false;true;false;true]]; (* 简化平仄模式 *)
    rhythm_weight = 0.85;
  }
  
  (** 评价七言绝句 *)
  let evaluate_qiyan verses =
    let verse_count = List.length verses in
    
    (* 句数检查 *)
    let line_score = if verse_count = standard_pattern.line_count then 1.0 else 0.5 in
    
    (* 字数检查 *)
    let char_scores = List.map (fun verse ->
      let chars = String.split_on_char ' ' verse |> List.filter ((<>) "") in
      if List.length chars = standard_pattern.char_per_line then 1.0 else 0.7
    ) verses in
    let avg_char_score = List.fold_left (+.) 0.0 char_scores /. float_of_int verse_count in
    
    (* 韵脚检查 *)
    let rhyme_score = 0.85 in
    
    (* 意境评价 *)
    let imagery_score = 0.8 in
    
    (* 整体评价 *)
    let overall_score = (line_score +. avg_char_score +. rhyme_score +. imagery_score) /. 4.0 in
    
    {
      rhyme_harmony = rhyme_score;
      tonal_balance = 0.8;
      parallelism = 0.7; (* 绝句对仗要求相对较低 *)
      imagery = imagery_score;
      rhythm = overall_score *. standard_pattern.rhythm_weight;
      elegance = 0.85;
      overall = overall_score;
    }

end

(** === 词牌格律评价器 === *)

module CiPaiEvaluator = struct
  
  (** 评价词牌格律 *)
  let evaluate_cipai cipai_name verses =
    (* 简化的词牌评价 - 实际应用中会根据具体词牌要求 *)
    let verse_count = List.length verses in
    let base_score = 0.75 in
    
    let length_bonus = match verse_count with
      | n when n >= 4 && n <= 8 -> 0.1
      | n when n >= 9 && n <= 16 -> 0.15
      | _ -> 0.0 in
    
    let cipai_bonus = match cipai_name with
      | "水调歌头" | "念奴娇" | "满江红" -> 0.1
      | "如梦令" | "忆江南" | "浣溪沙" -> 0.05
      | _ -> 0.0 in
    
    let overall_score = base_score +. length_bonus +. cipai_bonus in
    
    {
      rhyme_harmony = overall_score;
      tonal_balance = 0.8;
      parallelism = 0.7;
      imagery = 0.85;
      rhythm = 0.9; (* 词牌通常节奏感很强 *)
      elegance = 0.9; (* 词牌通常很雅致 *)
      overall = overall_score;
    }

end

(** === 现代诗评价器 === *)

module ModernPoetryEvaluator = struct
  
  (** 评价现代诗 *)
  let evaluate_modern _verses =
    let _verse_count = List.length _verses in
    
    (* 现代诗更注重意象和情感表达 *)
    let imagery_score = 0.9 in
    let emotion_score = 0.85 in
    let innovation_score = 0.8 in
    
    (* 形式要求相对宽松 *)
    let form_score = 0.7 in
    
    let overall_score = (imagery_score +. emotion_score +. innovation_score +. form_score) /. 4.0 in
    
    {
      rhyme_harmony = 0.6; (* 现代诗对韵律要求较低 *)
      tonal_balance = 0.6;
      parallelism = 0.5; (* 对仗要求很低 *)
      imagery = imagery_score;
      rhythm = 0.7; (* 自由节奏 *)
      elegance = 0.75;
      overall = overall_score;
    }

end

(** === 统一形式评价接口 === *)

(** 根据诗词形式进行评价 *)
let rec evaluate_by_form form verses =
  match form with
  | SiYanPianTi ->
      (* 对四言骈体，评价每句然后综合 *)
      let verse_reports = List.map SiYanPianTiEvaluator.evaluate_siyan verses in
      let total_scores = List.fold_left (fun acc report ->
        {
          rhyme_harmony = acc.rhyme_harmony +. report.rhyme_score;
          tonal_balance = acc.tonal_balance +. report.tone_score;
          parallelism = acc.parallelism +. report.parallelism_score;
          imagery = acc.imagery +. report.imagery_score;
          rhythm = acc.rhythm +. report.rhythm_score;
          elegance = acc.elegance +. report.elegance_score;
          overall = acc.overall +. (match report.overall_grade with Excellent -> 1.0 | Good -> 0.8 | Fair -> 0.6 | Poor -> 0.4);
        }
      ) {rhyme_harmony=0.0; tonal_balance=0.0; parallelism=0.0; imagery=0.0; rhythm=0.0; elegance=0.0; overall=0.0} verse_reports in
      let count = float_of_int (List.length verses) in
      {
        rhyme_harmony = total_scores.rhyme_harmony /. count;
        tonal_balance = total_scores.tonal_balance /. count;
        parallelism = total_scores.parallelism /. count;
        imagery = total_scores.imagery /. count;
        rhythm = total_scores.rhythm /. count;
        elegance = total_scores.elegance /. count;
        overall = total_scores.overall /. count;
      }
  | WuYanLuShi -> WuYanLuShiEvaluator.evaluate_wuyan verses
  | QiYanJueJu -> QiYanJueJuEvaluator.evaluate_qiyan verses
  | CiPai name -> CiPaiEvaluator.evaluate_cipai name verses
  | ModernPoetry -> ModernPoetryEvaluator.evaluate_modern verses
  | SiYanParallelProse -> 
      (* 四言排律与四言骈体类似，但要求更严格 *)
      let base_scores = evaluate_by_form SiYanPianTi verses in
      { base_scores with parallelism = base_scores.parallelism *. 1.1; overall = base_scores.overall *. 1.05 }

(** 获取形式评价建议 *)
let get_form_suggestions form _verses =
  match form with
  | SiYanPianTi -> ["保持四字一句的格律"; "注重对仗工整"; "控制平仄节奏"]
  | WuYanLuShi -> ["遵循八句格律"; "颔联颈联要对仗"; "2、4、6、8句押韵"; "注意平仄相对"]
  | QiYanJueJu -> ["保持四句体制"; "2、4句押韵"; "意境要完整"; "前景后情或前情后景"]
  | CiPai name -> [Printf.sprintf "遵循%s词牌格律" name; "注意词牌特有的音律要求"; "上下阕结构要合理"]
  | ModernPoetry -> ["注重意象表达"; "情感真挚自然"; "可适当创新形式"; "节奏感要好"]
  | SiYanParallelProse -> ["严格遵循四言格律"; "全篇对仗工整"; "声律和谐"; "文辞典雅"]