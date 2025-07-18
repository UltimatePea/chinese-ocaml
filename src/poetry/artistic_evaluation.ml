(* 诗词艺术性评价模块 - 骆言诗词编程特性
   古之诗者，不仅求格律之正，更求意境之美。音韵和谐，对仗工整，方为佳作。
   此模块专司诗词艺术性评价，综合音韵、对仗、意境等因素，为诗词创作提供全面指导。
   既遵古制，又开新风，助力程序员书写诗意代码。
*)

open Yyocamlc_lib
open Rhyme_analysis
open Tone_pattern
open Artistic_evaluator

(* 中文字符计数函数：使用统一的UTF-8工具模块 *)
let count_chinese_chars text =
  (* 使用统一的UTF-8工具模块，消除代码重复 *)
  Utf8_utils.StringUtils.utf8_length text

(* 艺术性评价维度 *)
type artistic_dimension =
  | RhymeHarmony (* 韵律和谐 *)
  | TonalBalance (* 声调平衡 *)
  | Parallelism (* 对仗工整 *)
  | Imagery (* 意象深度 *)
  | Rhythm (* 节奏感 *)
  | Elegance (* 雅致程度 *)
  | ClassicalElegance (* 古典雅致 - 新增维度 *)
  | ModernInnovation (* 现代创新 - 新增维度 *)
  | CulturalDepth (* 文化深度 - 新增维度 *)
  | EmotionalResonance (* 情感共鸣 - 新增维度 *)
  | IntellectualDepth (* 理性深度 - 新增维度 *)

(* 评价等级：依传统诗词品评标准 *)
type evaluation_grade =
  | Excellent (* 上品 - 意境高远，韵律和谐，可称佳作 *)
  | Good (* 中品 - 格律工整，音韵协调，颇具水准 *)
  | Fair (* 下品 - 基本合格，略有瑕疵，尚可改进 *)
  | Poor (* 不入流 - 格律错乱，音韵不谐，需重修 *)

(* 艺术性评价报告：全面分析诗词的艺术特征 *)
type artistic_report = {
  verse : string; (* 原诗句 *)
  rhyme_score : float; (* 韵律得分 *)
  tone_score : float; (* 声调得分 *)
  parallelism_score : float; (* 对仗得分 *)
  imagery_score : float; (* 意象得分 *)
  rhythm_score : float; (* 节奏得分 *)
  elegance_score : float; (* 雅致得分 *)
  overall_grade : evaluation_grade; (* 总体评价 *)
  suggestions : string list; (* 改进建议 *)
}

(* 诗词美学指导报告 - 根据实施计划新增 *)
(* 注释：为了避免类型冲突，暂时注释掉复杂的类型定义 *)

(* 四言骈体艺术性评价标准 *)
type siyan_artistic_standards = {
  char_count : int; (* 字数标准：每句四字 *)
  tone_pattern : bool list; (* 声调模式：平仄相对 *)
  parallelism_required : bool; (* 是否要求对仗 *)
  rhythm_weight : float; (* 节奏权重 *)
}

(* 诗词形式定义 - 支持多种经典诗词格式 *)
type poetry_form =
  | SiYanPianTi (* 四言骈体 - 已支持 *)
  | WuYanLuShi (* 五言律诗 - 新增支持 *)
  | QiYanJueJu (* 七言绝句 - 新增支持 *)
  | CiPai of string (* 词牌格律 - 新增支持 *)
  | ModernPoetry (* 现代诗 - 新增支持 *)

(* 五言律诗艺术性评价标准 *)
type wuyan_lushi_standards = {
  line_count : int; (* 句数标准：八句 *)
  char_per_line : int; (* 每句字数：五字 *)
  rhyme_scheme : bool array; (* 韵脚模式：2-4-6-8句押韵 *)
  parallelism_required : bool array; (* 对仗要求：颔联、颈联对仗 *)
  tone_pattern : bool list list; (* 声调模式：平仄相对 *)
  rhythm_weight : float; (* 节奏权重 *)
}

(* 七言绝句艺术性评价标准 *)
type qiyan_jueju_standards = {
  line_count : int; (* 句数标准：四句 *)
  char_per_line : int; (* 每句字数：七字 *)
  rhyme_scheme : bool array; (* 韵脚模式：2-4句押韵 *)
  parallelism_required : bool array; (* 对仗要求：后两句对仗 *)
  tone_pattern : bool list list; (* 声调模式：平仄相对 *)
  rhythm_weight : float; (* 节奏权重 *)
}

(* 四言骈体标准 *)
let siyan_standards =
  {
    char_count = 4;
    tone_pattern = [ true; true; false; false ];
    parallelism_required = true;
    rhythm_weight = 0.3;
  }

(* 五言律诗标准定义 *)
let wuyan_lushi_standards : wuyan_lushi_standards =
  {
    line_count = 8;
    char_per_line = 5;
    rhyme_scheme = [|false; true; false; true; false; true; false; true|];
    parallelism_required = [|false; false; true; true; true; true; false; false|];
    tone_pattern = [
      [ true; true; false; false; true ];   (* 首联起句 *)
      [ false; false; true; true; false ];  (* 首联对句 *)
      [ false; false; true; true; false ];  (* 颔联起句 *)
      [ true; true; false; false; true ];   (* 颔联对句 *)
      [ true; true; false; false; true ];   (* 颈联起句 *)
      [ false; false; true; true; false ];  (* 颈联对句 *)
      [ false; false; true; true; false ];  (* 尾联起句 *)
      [ true; true; false; false; true ];   (* 尾联对句 *)
    ];
    rhythm_weight = 0.4;
  }

(* 七言绝句标准定义 *)
let qiyan_jueju_standards : qiyan_jueju_standards =
  {
    line_count = 4;
    char_per_line = 7;
    rhyme_scheme = [|false; true; false; true|];
    parallelism_required = [|false; false; true; true|];
    tone_pattern = [
      [ true; true; false; false; true; true; false ];   (* 起句 *)
      [ false; false; true; true; false; false; true ];  (* 承句 *)
      [ false; false; true; true; false; false; true ];  (* 转句 *)
      [ true; true; false; false; true; true; false ];   (* 合句 *)
    ];
    rhythm_weight = 0.35;
  }

(* 评价韵律和谐度：检查诗句的音韵是否和谐 *)
let evaluate_rhyme_harmony verse =
  let rhyme_report = generate_rhyme_report verse in
  let rhyme_group = rhyme_report.rhyme_group in

  (* 基础韵律得分 *)
  let base_score =
    match rhyme_group with UnknownRhyme -> 0.4 (* 未知韵组，得分较低 *) | _ -> 0.8 (* 已知韵组，基础得分 *)
  in

  (* 韵脚质量评价 *)
  let rhyme_quality = match rhyme_report.rhyme_ending with None -> 0.0 | Some _ -> 0.2 in

  base_score +. rhyme_quality

(* 评价声调平衡度：检查平仄搭配是否合理 *)
let evaluate_tonal_balance verse expected_pattern =
  let tone_report = generate_tone_report verse expected_pattern in
  let pattern_match = tone_report.pattern_match in

  (* 基础声调得分 *)
  let base_score = if pattern_match then 0.8 else 0.4 in

  (* 声调多样性评价 *)
  let tone_diversity =
    let level_count = List.length (List.filter (fun x -> x) tone_report.simple_pattern) in
    let total_count = List.length tone_report.simple_pattern in
    let oblique_count = total_count - level_count in
    let diversity = min level_count oblique_count in
    float_of_int diversity /. float_of_int total_count *. 0.2
  in

  base_score +. tone_diversity

(* 评价对仗工整度：检查对仗的工整程度 *)
let evaluate_parallelism left_verse right_verse =
  let left_chars = count_chinese_chars left_verse in
  let right_chars = count_chinese_chars right_verse in

  (* 字数对应 *)
  let char_balance = if left_chars = right_chars then 0.4 else 0.0 in

  (* 声调对应 *)
  let left_pattern = analyze_simple_tone_pattern left_verse in
  let right_pattern = analyze_simple_tone_pattern right_verse in

  let tone_correspondence =
    if List.length left_pattern = List.length right_pattern then
      let pairs = List.combine left_pattern right_pattern in
      let opposite_pairs = List.filter (fun (l, r) -> l <> r) pairs in
      let correspondence_ratio =
        float_of_int (List.length opposite_pairs) /. float_of_int (List.length pairs)
      in
      correspondence_ratio *. 0.4
    else 0.0
  in

  (* 韵律对应 *)
  let get_last_char s = if String.length s > 0 then String.get s (String.length s - 1) else '?' in
  let left_rhyme_group = detect_rhyme_group (get_last_char left_verse) in
  let right_rhyme_group = detect_rhyme_group (get_last_char right_verse) in
  let rhyme_correspondence = if left_rhyme_group <> right_rhyme_group then 0.2 else 0.0 in

  char_balance +. tone_correspondence +. rhyme_correspondence

(* 评价意象深度：通过关键词分析评价意象的深度 *)
let evaluate_imagery verse =
  (* 简化的意象评价：基于诗句长度和复杂度 *)
  let char_count = count_chinese_chars verse in
  let complexity_score = min (float_of_int char_count) 10.0 /. 10.0 in

  (* 检查是否包含常见诗词意象 *)
  let common_imagery =
    [
      "山";
      "水";
      "月";
      "风";
      "花";
      "鸟";
      "云";
      "雨";
      "雪";
      "霜";
      "春";
      "夏";
      "秋";
      "冬";
      "朝";
      "暮";
      "日";
      "星";
      "天";
      "地";
      "江";
      "河";
      "湖";
      "海";
      "松";
      "竹";
      "梅";
      "兰";
      "菊";
      "莲";
    ]
  in

  let imagery_count =
    List.fold_left
      (fun acc imagery -> if String.contains verse (String.get imagery 0) then acc + 1 else acc)
      0 common_imagery
  in

  let imagery_score = min (float_of_int imagery_count) 3.0 /. 3.0 *. 0.5 in

  (complexity_score *. 0.5) +. imagery_score

(* 评价节奏感：基于字数和声调变化评价节奏 *)
let evaluate_rhythm verse =
  let tone_sequence = analyze_tone_sequence verse in
  let char_count = List.length tone_sequence in

  (* 基础节奏得分 *)
  let base_rhythm =
    match char_count with
    | 4 -> 0.8 (* 四言节奏明快 *)
    | 5 -> 0.9 (* 五言节奏优美 *)
    | 7 -> 0.7 (* 七言节奏稍缓 *)
    | _ -> 0.5 (* 其他长度 *)
  in

  (* 声调变化评价 *)
  let tone_changes = ref 0 in
  let rec count_changes = function
    | [] | [ _ ] -> ()
    | a :: (b :: _ as rest) ->
        if a <> b then incr tone_changes;
        count_changes rest
  in
  count_changes tone_sequence;

  let change_score = min (float_of_int !tone_changes) 3.0 /. 3.0 *. 0.2 in

  base_rhythm +. change_score

(* 评价雅致程度：基于用词和意境的雅致程度 *)
let evaluate_elegance verse =
  (* 简化的雅致度评价 *)
  let _char_count = count_chinese_chars verse in

  (* 检查是否包含雅致用词 *)
  let elegant_words =
    [
      "之";
      "者";
      "也";
      "矣";
      "乎";
      "哉";
      "焉";
      "夫";
      "盖";
      "是";
      "以";
      "而";
      "与";
      "于";
      "其";
      "为";
      "若";
      "如";
      "或";
      "且";
    ]
  in

  let elegant_count =
    List.fold_left
      (fun acc word -> if String.contains verse (String.get word 0) then acc + 1 else acc)
      0 elegant_words
  in

  let elegance_ratio = min (float_of_int elegant_count) 2.0 /. 2.0 in

  (* 基础雅致得分 *)
  let base_elegance = 0.6 in

  base_elegance +. (elegance_ratio *. 0.4)

(* 综合评价等级：根据各项得分确定总体评价等级 *)
let determine_overall_grade scores =
  let total_score =
    scores.rhyme_score +. scores.tone_score +. scores.parallelism_score +. scores.imagery_score
    +. scores.rhythm_score +. scores.elegance_score
  in
  let average_score = total_score /. 6.0 in

  if average_score >= 0.8 then Excellent
  else if average_score >= 0.6 then Good
  else if average_score >= 0.4 then Fair
  else Poor

(* 通用评价框架 - 消除代码重复 *)
module EvaluationFramework = struct
  (* 评价权重配置 *)
  type evaluation_weights = {
    rhyme_weight : float;
    tone_weight : float;
    parallelism_weight : float;
    imagery_weight : float;
    rhythm_weight : float;
    elegance_weight : float;
  }
  
  (* 通用评价结果创建函数 *)
  let create_evaluation_result verse_combined scores suggestions =
    let rhyme_score, tone_score, parallelism_score, imagery_score, rhythm_score, elegance_score = scores in
    {
      verse = verse_combined;
      rhyme_score = rhyme_score;
      tone_score = tone_score;
      parallelism_score = parallelism_score;
      imagery_score = imagery_score;
      rhythm_score = rhythm_score;
      elegance_score = elegance_score;
      overall_grade = Poor; (* 临时设置，将由calculate_overall_grade计算 *)
      suggestions = suggestions;
    }
  
  (* 计算总分和等级 *)
  let calculate_overall_grade weights scores =
    let rhyme_score, tone_score, parallelism_score, imagery_score, rhythm_score, elegance_score = scores in
    let overall_score = 
      rhyme_score *. weights.rhyme_weight +. 
      tone_score *. weights.tone_weight +. 
      parallelism_score *. weights.parallelism_weight +. 
      imagery_score *. weights.imagery_weight +. 
      rhythm_score *. weights.rhythm_weight +. 
      elegance_score *. weights.elegance_weight
    in
    if overall_score >= 0.85 then Excellent
    else if overall_score >= 0.7 then Good
    else if overall_score >= 0.5 then Fair
    else Poor
  
  (* 创建错误评价结果 *)
  let create_error_evaluation verses error_message =
    let verse_combined = String.concat "\n" (Array.to_list verses) in
    {
      verse = verse_combined;
      rhyme_score = 0.0;
      tone_score = 0.0;
      parallelism_score = 0.0;
      imagery_score = 0.0;
      rhythm_score = 0.0;
      elegance_score = 0.0;
      overall_grade = Poor;
      suggestions = [error_message];
    }
  
  (* 计算多句诗词的声调得分 *)
  let calculate_tone_scores verses tone_patterns =
    let total_score = ref 0.0 in
    let count = Array.length verses in
    for i = 0 to count - 1 do
      let expected_pattern = List.nth tone_patterns i in
      let score = evaluate_tonal_balance verses.(i) expected_pattern in
      total_score := !total_score +. score;
    done;
    !total_score /. float_of_int count
  
  (* 计算对仗得分 *)
  let calculate_parallelism_scores verses parallelism_pairs =
    let scores = List.map (fun (i, j) -> evaluate_parallelism verses.(i) verses.(j)) parallelism_pairs in
    if List.length scores > 0 then
      List.fold_left (+.) 0.0 scores /. float_of_int (List.length scores)
    else 0.0
end

(* 生成改进建议：根据评价结果提供具体的改进建议 *)
let generate_improvement_suggestions report =
  let suggestions = ref [] in

  if report.rhyme_score < 0.6 then suggestions := "建议调整韵脚，使音韵更加和谐" :: !suggestions;

  if report.tone_score < 0.6 then suggestions := "建议调整平仄搭配，使声调更加平衡" :: !suggestions;

  if report.parallelism_score < 0.6 then suggestions := "建议加强对仗工整度，使结构更加对称" :: !suggestions;

  if report.imagery_score < 0.6 then suggestions := "建议丰富意象表达，使诗句更有深度" :: !suggestions;

  if report.rhythm_score < 0.6 then suggestions := "建议调整节奏感，使诗句更有韵律美" :: !suggestions;

  if report.elegance_score < 0.6 then suggestions := "建议使用更雅致的词汇，提升诗句品味" :: !suggestions;

  if !suggestions = [] then [ "诗句已达较高水准，可在细节上继续打磨" ] else List.rev !suggestions

(* 全面艺术性评价：为诗句提供全面的艺术性分析 *)
let comprehensive_artistic_evaluation verse expected_pattern =
  let rhyme_score = evaluate_rhyme_harmony verse in
  let tone_score = evaluate_tonal_balance verse expected_pattern in
  let parallelism_score = 0.7 in
  (* 单句评价，暂设默认值 *)
  let imagery_score = evaluate_imagery verse in
  let rhythm_score = evaluate_rhythm verse in
  let elegance_score = evaluate_elegance verse in

  let initial_report =
    {
      verse;
      rhyme_score;
      tone_score;
      parallelism_score;
      imagery_score;
      rhythm_score;
      elegance_score;
      overall_grade = Good;
      (* 临时值，后续更新 *)
      suggestions = [];
    }
  in

  let overall_grade = determine_overall_grade initial_report in
  let suggestions = generate_improvement_suggestions initial_report in

  { initial_report with overall_grade; suggestions }

(* 四言骈体专项评价：专门针对四言骈体的艺术性评价 *)
let evaluate_siyan_parallel_prose verses =
  let evaluations =
    List.map
      (fun verse -> comprehensive_artistic_evaluation verse siyan_standards.tone_pattern)
      verses
  in

  (* 计算整体得分 *)
  let total_scores =
    List.fold_left
      (fun acc eval ->
        {
          verse = acc.verse ^ "\n" ^ eval.verse;
          rhyme_score = acc.rhyme_score +. eval.rhyme_score;
          tone_score = acc.tone_score +. eval.tone_score;
          parallelism_score = acc.parallelism_score +. eval.parallelism_score;
          imagery_score = acc.imagery_score +. eval.imagery_score;
          rhythm_score = acc.rhythm_score +. eval.rhythm_score;
          elegance_score = acc.elegance_score +. eval.elegance_score;
          overall_grade = acc.overall_grade;
          suggestions = acc.suggestions @ eval.suggestions;
        })
      {
        verse = "";
        rhyme_score = 0.0;
        tone_score = 0.0;
        parallelism_score = 0.0;
        imagery_score = 0.0;
        rhythm_score = 0.0;
        elegance_score = 0.0;
        overall_grade = Poor;
        suggestions = [];
      }
      evaluations
  in

  let verse_count = float_of_int (List.length verses) in
  let average_report =
    {
      verse = String.trim total_scores.verse;
      rhyme_score = total_scores.rhyme_score /. verse_count;
      tone_score = total_scores.tone_score /. verse_count;
      parallelism_score = total_scores.parallelism_score /. verse_count;
      imagery_score = total_scores.imagery_score /. verse_count;
      rhythm_score = total_scores.rhythm_score /. verse_count;
      elegance_score = total_scores.elegance_score /. verse_count;
      overall_grade = Good;
      suggestions = [];
    }
  in

  let overall_grade = determine_overall_grade average_report in
  let suggestions = generate_improvement_suggestions average_report in

  { average_report with overall_grade; suggestions }

(* 诗词品评：传统诗词品评方式的现代实现 *)
let poetic_critique verse poetry_type =
  let critique_intro =
    match poetry_type with
    | "四言骈体" -> "观此四言骈体，句式简练，"
    | "五言律诗" -> "品此五言律诗，格律工整，"
    | "七言绝句" -> "赏此七言绝句，起承转合，"
    | _ -> "评此诗句，"
  in

  let evaluation = comprehensive_artistic_evaluation verse [ true; true; false; false ] in

  let grade_comment =
    match evaluation.overall_grade with
    | Excellent -> "意境深远，音韵和谐，可称佳作也。"
    | Good -> "颇具功力，音律协调，尚属佳品。"
    | Fair -> "基本合格，略有瑕疵，尚可雕琢。"
    | Poor -> "格律未谐，音韵失调，需重修改。"
  in

  critique_intro ^ grade_comment

(** {1 Enhanced Artistic Evaluation System - 增强的艺术性评价系统} *)

(* 综合艺术性评价系统 - 根据实施计划增强版本 *)
let enhanced_comprehensive_artistic_evaluation verse =
  (* 使用新的模块化评价器系统 *)
  let context = Artistic_evaluator.create_evaluation_context verse in
  let evaluation_results = Artistic_evaluator.ComprehensiveEvaluator.evaluate_all context in
  
  (* 提取各维度评分 *)
  let get_score_by_dimension dimension results =
    List.find_opt (fun result -> result.dimension = dimension) results
    |> Option.map (fun result -> result.score)
    |> Option.value ~default:0.0
  in
  
  let rhyme_score = get_score_by_dimension Rhyme evaluation_results in
  let tone_score = get_score_by_dimension Tone evaluation_results in
  let parallelism_score = get_score_by_dimension Parallelism evaluation_results in
  let imagery_score = get_score_by_dimension Imagery evaluation_results in
  let rhythm_score = get_score_by_dimension Rhythm evaluation_results in
  let elegance_score = get_score_by_dimension Elegance evaluation_results in

  (* 计算总体评级 *)
  let overall_grade =
    let total_score =
      rhyme_score +. tone_score +. parallelism_score +. imagery_score +. rhythm_score
      +. elegance_score
    in
    let average_score = total_score /. 6.0 in
    if average_score >= 0.9 then Excellent
    else if average_score >= 0.75 then Good
    else if average_score >= 0.6 then Fair
    else Poor
  in

  (* 生成改进建议 *)
  let suggestions =
    generate_improvement_suggestions
      {
        verse;
        rhyme_score;
        tone_score;
        parallelism_score;
        imagery_score;
        rhythm_score;
        elegance_score;
        overall_grade;
        suggestions = [];
      }
  in

  {
    verse;
    rhyme_score;
    tone_score;
    parallelism_score;
    imagery_score;
    rhythm_score;
    elegance_score;
    overall_grade;
    suggestions;
  }


(* 诗词美学指导系统 - 根据实施计划新增 *)
let poetic_aesthetics_guidance verse poetry_type =
  let evaluation = enhanced_comprehensive_artistic_evaluation verse in

  let type_specific_guidance =
    match poetry_type with
    | "四言骈体" -> [ "四言骈体应注重句式对仗，每句四字，上下联相对"; "平仄搭配要协调，避免连续同调"; "用词要典雅，多用古典意象" ]
    | "五言律诗" -> [ "五言律诗要严格遵循格律，首联、颔联、颈联、尾联各有规范"; "中间两联必须对仗，词性、声调都要相对"; "意境要深远，情景交融" ]
    | "七言绝句" -> [ "七言绝句要起承转合，四句成篇"; "首句立意，次句承接，三句转折，末句收束"; "语言要精炼，意象要鲜明" ]
    | _ -> [ "注重音韵和谐，平仄相间"; "选用典雅词汇，避免俗语"; "意象要丰富，情感要真挚" ]
  in

  let quality_suggestions =
    if evaluation.overall_grade = Excellent then [ "作品已达上乘水准，音韵和谐，意境深远"; "可在细节上继续雕琢，追求完美" ]
    else if evaluation.rhyme_score < 0.7 then [ "韵律方面需要改进，建议检查韵脚匹配"; "注意平仄搭配，避免音调单一" ]
    else []
  in

  (* 返回一个简化的报告作为字符串 *)
  "诗词分析报告：\n" ^ "类型：" ^ poetry_type ^ "\n" ^ "总体评价："
  ^ (match evaluation.overall_grade with
    | Excellent -> "优秀"
    | Good -> "良好"
    | Fair -> "一般"
    | Poor -> "待改进")
  ^ "\n"
  ^ String.concat "\n" (type_specific_guidance @ quality_suggestions)

(* 五言律诗艺术性评价函数 - 使用通用框架重构 *)
let evaluate_wuyan_lushi verses =
  (* 验证诗词格式 *)
  if Array.length verses != 8 then
    EvaluationFramework.create_error_evaluation verses "五言律诗必须为八句，当前句数不符合要求"
  else
    (* 使用通用框架计算各项得分 *)
    let verse_combined = String.concat "\n" (Array.to_list verses) in
    let rhyme_score = evaluate_rhyme_harmony verse_combined in
    let tone_score = EvaluationFramework.calculate_tone_scores verses wuyan_lushi_standards.tone_pattern in
    let parallelism_score = EvaluationFramework.calculate_parallelism_scores verses [(2, 3); (4, 5)] in
    let imagery_score = evaluate_imagery verse_combined in
    let rhythm_score = evaluate_rhythm verse_combined in
    let elegance_score = evaluate_elegance verse_combined in
    
    (* 五言律诗权重配置 *)
    let weights = EvaluationFramework.{
      rhyme_weight = 0.2;
      tone_weight = 0.25;
      parallelism_weight = 0.25;
      imagery_weight = 0.15;
      rhythm_weight = 0.1;
      elegance_weight = 0.05;
    } in
    
    let scores = (rhyme_score, tone_score, parallelism_score, imagery_score, rhythm_score, elegance_score) in
    let overall_grade = EvaluationFramework.calculate_overall_grade weights scores in
    let suggestions = [
      "五言律诗讲究格律严谨，颔联、颈联必须对仗";
      "韵脚通常在第二、四、六、八句";
      "意境要深远，情景交融，体现文人雅士风范";
    ] in
    
    { (EvaluationFramework.create_evaluation_result verse_combined scores suggestions) with
      overall_grade = overall_grade }

(* 七言绝句艺术性评价函数 - 使用通用框架重构 *)
let evaluate_qiyan_jueju verses =
  (* 验证诗词格式 *)
  if Array.length verses != 4 then
    EvaluationFramework.create_error_evaluation verses "七言绝句必须为四句，当前句数不符合要求"
  else
    (* 使用通用框架计算各项得分 *)
    let verse_combined = String.concat "\n" (Array.to_list verses) in
    let rhyme_score = evaluate_rhyme_harmony verse_combined in
    let tone_score = EvaluationFramework.calculate_tone_scores verses qiyan_jueju_standards.tone_pattern in
    let parallelism_score = EvaluationFramework.calculate_parallelism_scores verses [(2, 3)] in
    let imagery_score = evaluate_imagery verse_combined in
    let rhythm_score = evaluate_rhythm verse_combined in
    let elegance_score = evaluate_elegance verse_combined in
    
    (* 七言绝句权重配置 *)
    let weights = EvaluationFramework.{
      rhyme_weight = 0.25;
      tone_weight = 0.25;
      parallelism_weight = 0.2;
      imagery_weight = 0.15;
      rhythm_weight = 0.1;
      elegance_weight = 0.05;
    } in
    
    let scores = (rhyme_score, tone_score, parallelism_score, imagery_score, rhythm_score, elegance_score) in
    let overall_grade = EvaluationFramework.calculate_overall_grade weights scores in
    let suggestions = [
      "七言绝句要起承转合，四句成篇";
      "第二、四句通常押韵";
      "语言要精炼，意象要鲜明，情感要真挚";
    ] in
    
    { (EvaluationFramework.create_evaluation_result verse_combined scores suggestions) with
      overall_grade = overall_grade }

(* 四言骈体评价专用函数 *)
let evaluate_siyan_pianti verses =
  if Array.length verses > 0 then
    enhanced_comprehensive_artistic_evaluation verses.(0)
  else
    {
      verse = "";
      rhyme_score = 0.0;
      tone_score = 0.0;
      parallelism_score = 0.0;
      imagery_score = 0.0;
      rhythm_score = 0.0;
      elegance_score = 0.0;
      overall_grade = Poor;
      suggestions = ["输入内容为空"];
    }

(* 词牌格律评价专用函数 *)
let evaluate_cipai _cipai_type verses =
  {
    verse = String.concat "\n" (Array.to_list verses);
    rhyme_score = 0.5;
    tone_score = 0.5;
    parallelism_score = 0.5;
    imagery_score = 0.5;
    rhythm_score = 0.5;
    elegance_score = 0.5;
    overall_grade = Fair;
    suggestions = ["词牌格律评价功能正在开发中"];
  }

(* 现代诗评价专用函数 *)
let evaluate_modern_poetry verses =
  let verse_combined = String.concat "\n" (Array.to_list verses) in
  let imagery_score = evaluate_imagery verse_combined in
  let rhythm_score = evaluate_rhythm verse_combined in
  let elegance_score = evaluate_elegance verse_combined in
  
  let overall_score = 
    imagery_score *. 0.4 +. rhythm_score *. 0.3 +. elegance_score *. 0.3
  in
  let overall_grade = 
    if overall_score >= 0.8 then Excellent
    else if overall_score >= 0.65 then Good
    else if overall_score >= 0.45 then Fair
    else Poor
  in
  
  {
    verse = verse_combined;
    rhyme_score = 0.0;
    tone_score = 0.0;
    parallelism_score = 0.0;
    imagery_score = imagery_score;
    rhythm_score = rhythm_score;
    elegance_score = elegance_score;
    overall_grade = overall_grade;
    suggestions = [
      "现代诗注重意象创新和情感表达";
      "追求语言的现代性和个性化";
      "可以打破传统格律，但要有内在的节奏感";
    ];
  }

(* 根据诗词形式进行相应的艺术性评价 - 重构版本 *)
let evaluate_poetry_by_form poetry_form verses =
  match poetry_form with
  | WuYanLuShi -> evaluate_wuyan_lushi verses
  | QiYanJueJu -> evaluate_qiyan_jueju verses
  | SiYanPianTi -> evaluate_siyan_pianti verses
  | CiPai cipai_type -> evaluate_cipai cipai_type verses
  | ModernPoetry -> evaluate_modern_poetry verses

(* 导出函数：模块接口导出 *)
let () = ()
