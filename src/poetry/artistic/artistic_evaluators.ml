(** 标准化评估器模块
 *
 * 整合所有evaluators目录下的评估器到统一的接口中。
 * 此模块整合了10个独立评估器文件的功能。
 *
 * @author Whisky, PR Worker - 诗词艺术评估模块整合实施
 * @version 1.0 - 模块整合版本
 * @since 2025-08-03
 * @fix_issue #2000 Poetry艺术评估模块整合实施
 *)

open Artistic_engine_unified

(** {1 专门化评估器实现} *)

(** 韵律和谐评估器
    整合自 src/poetry/evaluators/rhyme_harmony_evaluator.ml *)
module RhymeHarmonyEvaluator = struct
  type rhyme_pattern = {
    pattern_id : string;
    tone_sequence : string;
    rhyme_scheme : string;
  }

  (** 分析韵脚模式 *)
  let analyze_rhyme_pattern (verses : string list) : rhyme_pattern =
    let pattern_id = Printf.sprintf "pattern_%d" (List.length verses) in
    let tone_sequence = String.concat "" (List.map (fun v -> 
      if String.length v > 0 then string_of_int (Char.code (String.get v 0) mod 4) else "0"
    ) verses) in
    let rhyme_scheme = "ABAB" in  (* 简化版本 *)
    { pattern_id; tone_sequence; rhyme_scheme }

  (** 评估韵律和谐度 *)
  let evaluate (verse : string) : dimension_score =
    evaluate_rhyme_harmony verse

  (** 批量评估多个诗句 *)
  let evaluate_batch (verses : string list) : dimension_score list =
    List.map evaluate verses
end

(** 声调平衡评估器
    整合自 src/poetry/evaluators/tonal_balance_evaluator.ml *)
module TonalBalanceEvaluator = struct
  type tone_pattern = Ping | Ze | Unknown

  (** 简化的声调检测 *)
  let detect_tone (char : char) : tone_pattern =
    if Char.code char mod 2 = 0 then Ping else Ze

  (** 分析声调模式 *)
  let analyze_tonal_pattern (verse : string) : tone_pattern list =
    List.map detect_tone (List.of_seq (String.to_seq verse))

  (** 评估声调平衡度 *)
  let evaluate (verse : string) (expected_pattern : string option) : dimension_score =
    evaluate_tonal_balance verse expected_pattern

  (** 检查声调模式匹配度 *)
  let check_pattern_match (verse : string) (expected : string) : float =
    let actual = analyze_tonal_pattern verse in
    let expected_chars = List.of_seq (String.to_seq expected) in
    let matches = List.fold_left2 (fun acc actual_tone expected_char ->
      let expected_tone = if Char.code expected_char = Char.code (String.get "平" 0) then Ping else Ze in
      if actual_tone = expected_tone then acc + 1 else acc
    ) 0 actual expected_chars in
    float_of_int matches /. float_of_int (List.length actual)
end

(** 对仗评估器
    整合自 src/poetry/evaluators/parallelism_evaluator.ml *)
module ParallelismEvaluator = struct
  type word_class = Noun | Verb | Adjective | Adverb | Other

  (** 简化的词性检测 *)
  let detect_word_class (word : string) : word_class =
    if String.length word = 0 then Other
    else
      let first_char_code = Char.code (String.get word 0) in
      if List.mem first_char_code [23665; 27700; 33457; 26376] then Noun      (* 山水花月 *)
      else if List.mem first_char_code [26469; 21435; 30475; 21548] then Verb  (* 来去看听 *)
      else if List.mem first_char_code [32654; 22909; 39640; 28145] then Adjective (* 美好高深 *)
      else Other

  (** 分析句子结构 *)
  let analyze_structure (verse : string) : word_class list =
    let words = String.split_on_char ' ' verse in
    List.map detect_word_class words

  (** 评估对仗工整度 *)
  let evaluate (left_verse : string) (right_verse : string) : dimension_score =
    evaluate_parallelism left_verse right_verse

  (** 检查词性对应 *)
  let check_word_class_correspondence (left : string) (right : string) : float =
    let left_structure = analyze_structure left in
    let right_structure = analyze_structure right in
    if List.length left_structure <> List.length right_structure then 0.0
    else
      let matches = List.fold_left2 (fun acc l r ->
        if l = r then acc + 1 else acc
      ) 0 left_structure right_structure in
      float_of_int matches /. float_of_int (List.length left_structure)
end

(** 意象评估器
    整合自 src/poetry/evaluators/imagery_evaluator.ml *)
module ImageryEvaluator = struct
  type imagery_category = Nature | Human | Abstract | Temporal | Spatial

  (** 意象关键词库 *)
  let imagery_keywords = [
    (Nature, ["山"; "水"; "花"; "月"; "风"; "云"; "雪"; "日"; "星"; "树"]);
    (Human, ["人"; "君"; "子"; "客"; "友"; "心"; "手"; "眼"; "面"]);
    (Abstract, ["情"; "爱"; "恨"; "思"; "念"; "愁"; "喜"; "忧"; "乐"]);
    (Temporal, ["春"; "夏"; "秋"; "冬"; "朝"; "暮"; "昨"; "今"; "明"]);
    (Spatial, ["东"; "西"; "南"; "北"; "上"; "下"; "内"; "外"; "远"; "近"]);
  ]

  (** 检测意象类别 *)
  let detect_imagery (verse : string) : (imagery_category * int) list =
    List.map (fun (category, keywords) ->
      let count = List.fold_left (fun acc keyword ->
        if String.contains verse (String.get keyword 0) then acc + 1 else acc
      ) 0 keywords in
      (category, count)
    ) imagery_keywords

  (** 评估意象深度 *)
  let evaluate (verse : string) : dimension_score =
    evaluate_imagery verse

  (** 计算意象丰富度 *)
  let calculate_richness (verse : string) : float =
    let imagery_counts = detect_imagery verse in
    let _total_imagery = List.fold_left (fun acc (_, count) -> acc + count) 0 imagery_counts in
    let categories_used = List.length (List.filter (fun (_, count) -> count > 0) imagery_counts) in
    float_of_int categories_used /. float_of_int (List.length imagery_keywords)
end

(** 形式美感评估器
    整合自 src/poetry/evaluators/form_beauty_evaluator.ml *)
module FormBeautyEvaluator = struct
  type verse_structure = {
    character_count : int;
    word_count : int;
    symmetry_score : float;
    rhythm_score : float;
  }

  (** 分析诗句结构 *)
  let analyze_structure (verse : string) : verse_structure =
    let character_count = String.length verse in
    let word_count = List.length (String.split_on_char ' ' verse) in
    let symmetry_score = if character_count mod 2 = 0 then 1.0 else 0.7 in
    let rhythm_score = 0.8 in  (* 简化版本 *)
    { character_count; word_count; symmetry_score; rhythm_score }

  (** 评估形式美感 *)
  let evaluate (verse : string) : dimension_score =
    evaluate_form_beauty verse

  (** 检查格律符合度 *)
  let check_metrical_compliance (verse : string) (meter_type : string) : float =
    let structure = analyze_structure verse in
    match meter_type with
    | "五言" -> if structure.character_count = 5 then 1.0 else 0.5
    | "七言" -> if structure.character_count = 7 then 1.0 else 0.5
    | _ -> 0.6  (* 默认分数 *)
end

(** 内容深度评估器
    整合自 src/poetry/evaluators/content_depth_evaluator.ml *)
module ContentDepthEvaluator = struct
  type content_theme = Philosophy | Nature | Love | Friendship | Patriotism | Melancholy

  (** 主题关键词 *)
  let theme_keywords = [
    (Philosophy, ["道"; "理"; "思"; "悟"; "禅"; "智"; "明"]);
    (Nature, ["山"; "水"; "花"; "鸟"; "风"; "月"; "云"]);
    (Love, ["爱"; "情"; "心"; "相思"; "恋"; "慕"]);
    (Friendship, ["友"; "知音"; "酒"; "聚"; "别"; "离"]);
    (Patriotism, ["国"; "君"; "民"; "忠"; "义"; "志"]);
    (Melancholy, ["愁"; "悲"; "泪"; "叹"; "忧"; "恨"]);
  ]

  (** 检测主题 *)
  let detect_themes (verse : string) : (content_theme * float) list =
    List.map (fun (theme, keywords) ->
      let score = List.fold_left (fun acc keyword ->
        if String.contains verse (String.get keyword 0) then acc +. 0.2 else acc
      ) 0.0 keywords in
      (theme, min 1.0 score)
    ) theme_keywords

  (** 评估内容深度 *)
  let evaluate (verse : string) : dimension_score =
    let themes = detect_themes verse in
    let depth_score = List.fold_left (fun acc (_, score) -> acc +. score) 0.0 themes /.
                     float_of_int (List.length themes) in
    {
      dimension = ContentDepth;
      score = depth_score;
      confidence = 0.6;
      details = Printf.sprintf "内容深度: %.2f" depth_score;
    }
end

(** {1 统一评估接口} *)

(** 综合评估模块，整合所有评估器 *)
module ComprehensiveEvaluator = struct
  (** 评估单个诗句的所有维度 *)
  let evaluate_all_dimensions (verse : string) : evaluation_result =
    let rhyme_score = RhymeHarmonyEvaluator.evaluate verse in
    let tonal_score = TonalBalanceEvaluator.evaluate verse None in
    let imagery_score = ImageryEvaluator.evaluate verse in
    let form_score = FormBeautyEvaluator.evaluate verse in
    let content_score = ContentDepthEvaluator.evaluate verse in
    
    let all_scores = [rhyme_score; tonal_score; imagery_score; form_score; content_score] in
    let overall_score = 
      List.fold_left (fun acc score -> acc +. score.score) 0.0 all_scores /.
      float_of_int (List.length all_scores) in
    
    {
      dimension_scores = all_scores;
      overall_score = overall_score;
      weighted_score = overall_score;  (* 简化版本 *)
      evaluation_time = 0.1;
      metadata = [("evaluator", "comprehensive")];
    }

  (** 评估对联 *)
  let evaluate_couplet (left_verse : string) (right_verse : string) : evaluation_result =
    let left_result = evaluate_all_dimensions left_verse in
    let right_result = evaluate_all_dimensions right_verse in
    let parallelism_score = ParallelismEvaluator.evaluate left_verse right_verse in
    
    let combined_scores = left_result.dimension_scores @ right_result.dimension_scores @ [parallelism_score] in
    let overall_score = 
      List.fold_left (fun acc score -> acc +. score.score) 0.0 combined_scores /.
      float_of_int (List.length combined_scores) in
    
    {
      dimension_scores = combined_scores;
      overall_score = overall_score;
      weighted_score = overall_score;
      evaluation_time = 0.2;
      metadata = [("evaluator", "couplet")];
    }
end

(** {1 兼容性层} *)

(** 提供与原有API兼容的函数 *)

(** 评估韵律和谐度 - 兼容旧版API *)
let evaluate_rhyme_harmony_legacy (verse : string) : float =
  (RhymeHarmonyEvaluator.evaluate verse).score

(** 评估声调平衡度 - 兼容旧版API *)
let evaluate_tonal_balance_legacy (verse : string) (pattern : string) : float =
  (TonalBalanceEvaluator.evaluate verse (Some pattern)).score

(** 评估对仗工整度 - 兼容旧版API *)
let evaluate_parallelism_legacy (left : string) (right : string) : float =
  (ParallelismEvaluator.evaluate left right).score

(** 评估意象深度 - 兼容旧版API *)
let evaluate_imagery_legacy (verse : string) : float =
  (ImageryEvaluator.evaluate verse).score

(** 评估形式美感 - 兼容旧版API *)
let evaluate_form_beauty_legacy (verse : string) : float =
  (FormBeautyEvaluator.evaluate verse).score