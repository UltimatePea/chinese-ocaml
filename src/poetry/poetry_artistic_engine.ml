(** 诗词艺术性分析引擎 - 整合版本
 *
 * 此模块整合了原本分散在以下26个艺术性分析模块中的功能：
 * - artistic_evaluation.ml, artistic_evaluator*.ml 系列模块
 * - artistic_guidance.ml, artistic_types.ml, artistic_soul_evaluation.ml
 * - evaluation_framework.ml, form_evaluators.ml, parallelism_analysis.ml
 * 
 * 提供统一的诗词艺术性分析、评价和指导功能。
 *
 * @author 骆言编程团队 - 模块整合项目
 * @version 2.0 (整合版本)
 * @since 2025-07-25
 * @issue #1155 诗词模块整合优化
 *)

(** {1 核心艺术性分析类型} *)

(** 艺术性评价维度 *)
type artistic_dimension =
  | Content  (** 内容深度 *)
  | Form  (** 形式美感 *)
  | Sound  (** 音韵和谐 *)
  | Context  (** 意境营造 *)
  | Emotion  (** 情感表达 *)
  | Innovation  (** 创新性 *)

type artistic_evaluation = {
  overall_score : float;  (** 总体分数 0.0-1.0 *)
  dimension_scores : (artistic_dimension * float) list;  (** 各维度分数 *)
  strengths : string list;  (** 优点列表 *)
  weaknesses : string list;  (** 不足列表 *)
  improvement_suggestions : string list;  (** 改进建议 *)
  artistic_level : [ `Beginner | `Intermediate | `Advanced | `Master ];  (** 艺术水平 *)
}
(** 艺术性评价结果 *)

type mood_analysis = {
  primary_mood : string;  (** 主要意境 *)
  secondary_moods : string list;  (** 次要意境 *)
  mood_intensity : float;  (** 意境强度 *)
  mood_coherence : float;  (** 意境连贯性 *)
}
(** 意境分析结果 *)

type rhetoric_analysis = {
  detected_techniques : string list;  (** 检测到的修辞手法 *)
  technique_examples : (string * string) list;  (** 手法及其例子 *)
  rhetoric_richness : float;  (** 修辞丰富度 *)
}
(** 修辞手法检测结果 *)

(** {1 核心艺术性分析功能} *)

(** 分析诗词内容深度 * 整合了原 artistic_evaluator_content.ml 的功能 *)
let analyze_content_depth (lines : string list) : float * string list =
  let total_chars = List.fold_left (fun acc line -> acc + String.length line) 0 lines in
  let line_count = List.length lines in

  let suggestions = ref [] in
  let score = ref 0.5 in
  (* 基础分数 *)

  (* 基于长度的复杂度分析 *)
  if total_chars > 20 then (
    score := !score +. 0.2;
    suggestions := "内容具有一定的丰富性" :: !suggestions)
  else suggestions := "建议增加内容的深度和复杂性" :: !suggestions;

  (* 基于行数的结构分析 *)
  if line_count >= 4 then (
    score := !score +. 0.2;
    suggestions := "诗歌结构完整" :: !suggestions)
  else suggestions := "可以考虑扩展诗歌的结构" :: !suggestions;

  (min 1.0 !score, List.rev !suggestions)

(** 分析诗词形式美感 * 整合了原 artistic_evaluator_form.ml 的功能 *)
let analyze_form_beauty (lines : string list) : float * string list =
  let suggestions = ref [] in
  let score = ref 0.5 in

  (* 检查行长度一致性 *)
  let line_lengths = List.map String.length lines in
  let uniform_length =
    match line_lengths with
    | [] -> false
    | first :: rest -> List.for_all (fun len -> len = first) rest
  in

  if uniform_length then (
    score := !score +. 0.3;
    suggestions := "诗歌形式整齐，具有形式美感" :: !suggestions)
  else suggestions := "建议统一行长度以增强形式美感" :: !suggestions;

  (* 检查对称性和结构 *)
  if List.length lines mod 2 = 0 then (
    score := !score +. 0.1;
    suggestions := "偶数行结构有助于对称美" :: !suggestions);

  (min 1.0 !score, List.rev !suggestions)

(** 分析音韵和谐度 * 整合了原 artistic_evaluator_sound.ml 的功能 *)
let analyze_sound_harmony (lines : string list) : float * string list =
  let suggestions = ref [] in
  let score = ref 0.5 in

  (* 简化的音韵分析 - 检查韵脚 *)
  if List.length lines >= 2 then (
    let rhyme_engine = Poetry_rhyme_engine.validate_poem_rhyme lines in
    let matching_lines =
      List.filter (fun (_, result) -> result.Poetry_rhyme_engine.is_match) rhyme_engine
    in
    let rhyme_ratio =
      float_of_int (List.length matching_lines) /. float_of_int (List.length lines - 1)
    in

    score := !score +. (rhyme_ratio *. 0.4);
    if rhyme_ratio > 0.5 then suggestions := "韵律和谐，音韵效果良好" :: !suggestions
    else suggestions := "建议改善韵脚以增强音韵美感" :: !suggestions);

  (min 1.0 !score, List.rev !suggestions)

(** 分析意境营造 * 整合了原 artistic_evaluator_context.ml 的功能 *)
let analyze_mood_creation (lines : string list) : mood_analysis =
  (* 简化的意境分析 - 基于关键词检测 *)
  let nature_words = [ "春"; "花"; "月"; "风"; "雪"; "山"; "水"; "云"; "雨"; "夜" ] in
  let emotion_words = [ "愁"; "喜"; "恨"; "爱"; "思"; "念"; "忆"; "感"; "怀"; "叹" ] in

  let text = String.concat "" lines in
  let nature_count =
    List.fold_left
      (fun acc word -> if String.contains text (String.get word 0) then acc + 1 else acc)
      0 nature_words
  in
  let emotion_count =
    List.fold_left
      (fun acc word -> if String.contains text (String.get word 0) then acc + 1 else acc)
      0 emotion_words
  in

  let primary_mood =
    if nature_count > emotion_count then "自然写意"
    else if emotion_count > nature_count then "情感抒发"
    else "情景交融"
  in

  {
    primary_mood;
    secondary_moods = [ "宁静致远"; "思古幽情" ];
    (* 简化版本 *)
    mood_intensity = min 1.0 (float_of_int (nature_count + emotion_count) /. 5.0);
    mood_coherence = 0.7;
    (* 简化假设 *)
  }

(** 检测修辞手法 * 整合了原 artistic_soul_evaluation.ml 的部分功能 *)
let detect_rhetoric_techniques (lines : string list) : rhetoric_analysis =
  let techniques = ref [] in
  let examples = ref [] in

  (* 简化的修辞检测 *)
  let line_lengths = List.map String.length lines in
  let uniform_length =
    match line_lengths with
    | [] -> false
    | first :: rest -> List.for_all (fun len -> len = first) rest
  in

  if uniform_length then (
    techniques := "整齐对仗" :: !techniques;
    examples := ("整齐对仗", "各行字数相等，形成工整美感") :: !examples);

  (* 检测重复字符 (简化的重复修辞检测) *)
  let all_chars = String.concat "" lines in
  let char_counts = Hashtbl.create 50 in
  String.iter
    (fun c ->
      let count = try Hashtbl.find char_counts c with Not_found -> 0 in
      Hashtbl.replace char_counts c (count + 1))
    all_chars;

  let repeated_chars =
    Hashtbl.fold (fun c count acc -> if count > 1 then c :: acc else acc) char_counts []
  in

  if List.length repeated_chars > 0 then (
    techniques := "反复修辞" :: !techniques;
    examples := ("反复修辞", "重复使用某些字符增强表现力") :: !examples);

  {
    detected_techniques = List.rev !techniques;
    technique_examples = List.rev !examples;
    rhetoric_richness = min 1.0 (float_of_int (List.length !techniques) /. 3.0);
  }

(** {1 综合艺术性评价功能} *)

(** 综合评价诗词艺术性 * 整合了原 artistic_evaluation.ml 和 artistic_evaluator_comprehensive.ml 的功能 *)
let comprehensive_artistic_evaluation (lines : string list) : artistic_evaluation =
  (* 各维度分析 *)
  let content_score, content_suggestions = analyze_content_depth lines in
  let form_score, form_suggestions = analyze_form_beauty lines in
  let sound_score, sound_suggestions = analyze_sound_harmony lines in
  let mood_analysis = analyze_mood_creation lines in
  let rhetoric_analysis = detect_rhetoric_techniques lines in

  (* 计算各维度分数 *)
  let dimension_scores =
    [
      (Content, content_score);
      (Form, form_score);
      (Sound, sound_score);
      (Context, mood_analysis.mood_intensity);
      (Emotion, mood_analysis.mood_coherence);
      (Innovation, rhetoric_analysis.rhetoric_richness);
    ]
  in

  (* 计算总体分数 *)
  let total_score = List.fold_left (fun acc (_, score) -> acc +. score) 0.0 dimension_scores in
  let overall_score = total_score /. float_of_int (List.length dimension_scores) in

  (* 确定艺术水平 *)
  let artistic_level =
    if overall_score >= 0.8 then `Master
    else if overall_score >= 0.65 then `Advanced
    else if overall_score >= 0.5 then `Intermediate
    else `Beginner
  in

  (* 收集优点和建议 *)
  let strengths = ref [] in
  let weaknesses = ref [] in
  let all_suggestions = ref [] in

  (* 分析各维度表现 *)
  List.iter
    (fun (dim, score) ->
      let dim_name =
        match dim with
        | Content -> "内容深度"
        | Form -> "形式美感"
        | Sound -> "音韵和谐"
        | Context -> "意境营造"
        | Emotion -> "情感表达"
        | Innovation -> "创新修辞"
      in

      if score >= 0.7 then strengths := (dim_name ^ "表现出色") :: !strengths
      else if score < 0.4 then weaknesses := (dim_name ^ "有待改进") :: !strengths)
    dimension_scores;

  (* 合并具体建议 *)
  all_suggestions := content_suggestions @ form_suggestions @ sound_suggestions @ !all_suggestions;

  {
    overall_score;
    dimension_scores;
    strengths = List.rev !strengths;
    weaknesses = List.rev !weaknesses;
    improvement_suggestions = List.rev !all_suggestions;
    artistic_level;
  }

(** {1 艺术指导功能} *)

(** 生成个性化的艺术改进建议 * 整合了原 artistic_guidance.ml 的功能 *)
let generate_improvement_guidance (evaluation : artistic_evaluation) : string list =
  let guidance = ref [] in

  (* 基于艺术水平给出建议 *)
  (match evaluation.artistic_level with
  | `Beginner ->
      guidance := "建议多阅读经典诗词，学习基本的韵律和格律" :: !guidance;
      guidance := "注重诗歌的结构完整性，从简单的四句诗开始练习" :: !guidance
  | `Intermediate ->
      guidance := "可以尝试更复杂的修辞手法，如比喻、拟人等" :: !guidance;
      guidance := "在保持韵律的基础上，加强意境的营造" :: !guidance
  | `Advanced ->
      guidance := "探索更深层的情感表达和哲理思考" :: !guidance;
      guidance := "尝试融合古典与现代的表达方式" :: !guidance
  | `Master -> guidance := "继续保持高水准，可以指导他人的诗词创作" :: !guidance);

  (* 基于弱项给出针对性建议 *)
  List.iter
    (fun (dim, score) ->
      if score < 0.5 then
        let suggestion =
          match dim with
          | Content -> "建议增加诗歌的内容厚度，可以融入更多的思考和感悟"
          | Form -> "注意诗歌的形式美感，保持行长度的一致性"
          | Sound -> "加强韵脚的选择，提高音韵的和谐度"
          | Context -> "深入营造意境，让读者能够感受到诗歌的画面感"
          | Emotion -> "加强情感的表达，让诗歌更有感染力"
          | Innovation -> "尝试使用一些修辞手法，增加诗歌的表现力"
        in
        guidance := suggestion :: !guidance)
    evaluation.dimension_scores;

  List.rev !guidance

(** {1 向后兼容接口} *)

(** 兼容原 artistic_evaluation.ml 的评价函数 *)
let evaluate_poem_artistic (lines : string list) : float =
  let evaluation = comprehensive_artistic_evaluation lines in
  evaluation.overall_score

(** 兼容原 evaluation_framework.ml 的框架函数 *)
let quick_artistic_check (lines : string list) : bool * string list =
  let evaluation = comprehensive_artistic_evaluation lines in
  (evaluation.overall_score >= 0.5, evaluation.improvement_suggestions)

(** 兼容原 artistic_evaluators.ml 的多维度评价 *)
let multi_dimension_evaluation = comprehensive_artistic_evaluation
