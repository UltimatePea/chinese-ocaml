(** 诗词艺术评估过滤器模块 - Phase 1-C 模块化重构
 *
 * 此模块包含过滤、筛选和验证逻辑
 * 从 artistic_evaluators.ml 中提取的过滤相关功能
 *
 * @author Whisky, PR Worker - Phase 1-C 模块化重构
 * @refactors Issue #2171 - Phase 1-C 代码重构现代化
 *)

open Artistic_core
open Artistic_config

(** {1 输入验证过滤器} *)

(** 验证诗句输入 *)
let validate_verse_input verse =
  let trimmed = String.trim verse in
  if String.length trimmed = 0 then
    Error "诗句不能为空"
  else if String.length trimmed > 100 then
    Error "诗句过长（超过100字符）"
  else if String.length trimmed < 2 then
    Error "诗句过短（少于2字符）"
  else
    Ok trimmed

(** 验证诗句列表输入 *)
let validate_verses_input verses =
  if List.length verses = 0 then
    Error "诗句列表不能为空"
  else if List.length verses > 20 then
    Error "诗句数量过多（超过20句）"
  else
    let validate_all = List.map validate_verse_input verses in
    let errors = List.filter_map (function Error e -> Some e | Ok _ -> None) validate_all in
    if List.length errors > 0 then
      Error ("输入验证失败: " ^ String.concat "; " errors)
    else
      let valid_verses = List.filter_map (function Ok v -> Some v | Error _ -> None) validate_all in
      Ok valid_verses

(** {1 评价适用性过滤器} *)

(** 检查评价维度是否适用 *)
let is_dimension_applicable dimension context =
  let verse_count = List.length context.verses in
  let min_verses = EvaluatorConfig.get_min_applicable_verses dimension in
  
  match dimension with
  | RhymeHarmony -> 
      verse_count >= min_verses && verse_count >= RhymeConfig.min_verses_for_analysis
  | Parallelism ->
      verse_count >= min_verses && verse_count mod 2 = 0
  | FormBeauty ->
      verse_count >= 1
  | TonalBalance | Imagery | Rhythm | Elegance ->
      String.length context.verse > 0
  | ContentDepth ->
      String.length context.verse > 10 || List.length context.metadata > 0
  | _ -> true

(** 过滤适用的评价维度 *)
let filter_applicable_dimensions dimensions context =
  List.filter (fun dim -> is_dimension_applicable dim context) dimensions

(** {1 内容质量过滤器} *)

(** 检测中文字符比例 *)
let calculate_chinese_char_ratio text =
  let total_chars = String.length text in
  if total_chars = 0 then 0.0
  else
    let chinese_count = ref 0 in
    let i = ref 0 in
    while !i < total_chars do
      let byte = Char.code text.[!i] in
      if byte >= 0xE4 && byte <= 0xE9 then (
        (* 可能是中文字符 *)
        if !i + 2 < total_chars then (
          chinese_count := !chinese_count + 1;
          i := !i + 3
        ) else
          i := !i + 1
      ) else
        i := !i + 1
    done;
    float_of_int !chinese_count /. float_of_int total_chars

(** 过滤低质量内容 *)
let filter_low_quality_content verses =
  List.filter (fun verse ->
    let chinese_ratio = calculate_chinese_char_ratio verse in
    let verse_length = String.length verse in
    chinese_ratio >= 0.3 && verse_length >= 3 && verse_length <= 50
  ) verses

(** {1 评价结果过滤器} *)

(** 过滤低置信度评分 *)
let filter_low_confidence_scores dimension_scores =
  List.filter (fun score -> 
    score.confidence >= TextConfig.min_confidence_threshold
  ) dimension_scores

(** 过滤异常评分 *)
let filter_outlier_scores dimension_scores =
  List.filter (fun score ->
    score.score >= 0.0 && score.score <= 1.0 && 
    score.confidence >= 0.0 && score.confidence <= 1.0
  ) dimension_scores

(** 限制建议数量 *)
let limit_suggestions suggestions max_count =
  if List.length suggestions <= max_count then suggestions
  else list_take max_count suggestions

(** {1 诗词形式过滤器} *)

(** 检测诗词形式类型 *)
let detect_poetry_form verses =
  let verse_count = List.length verses in
  let verse_lengths = List.map String.length verses in
  let avg_length = 
    if verse_count = 0 then 0
    else List.fold_left (+) 0 verse_lengths / verse_count
  in
  
  match verse_count, avg_length with
  | 4, 5 -> Some "五言绝句"
  | 4, 7 -> Some "七言绝句"  
  | 8, 5 -> Some "五言律诗"
  | 8, 7 -> Some "七言律诗"
  | _, l when l >= 10 -> Some "长句诗"
  | _, l when l <= 4 -> Some "短句诗"
  | _ -> Some "自由体诗"

(** 基于诗词形式过滤适用评价维度 *)
let filter_by_poetry_form poetry_form dimensions =
  match poetry_form with
  | Some "五言绝句" | Some "七言绝句" ->
      (* 绝句重点关注韵律、节奏、意象 *)
      List.filter (function
        | RhymeHarmony | Rhythm | Imagery | Elegance -> true
        | _ -> false
      ) dimensions
  | Some "五言律诗" | Some "七言律诗" ->
      (* 律诗重点关注对仗、韵律、形式美 *)
      List.filter (function
        | RhymeHarmony | Parallelism | FormBeauty | TonalBalance -> true
        | _ -> false
      ) dimensions
  | Some "自由体诗" ->
      (* 自由体重点关注意象、内容深度 *)
      List.filter (function
        | Imagery | ContentDepth | Elegance -> true
        | _ -> false
      ) dimensions
  | _ -> dimensions  (* 未知形式保留所有维度 *)

(** {1 文本预处理过滤器} *)

(** 清理诗句文本 *)
let clean_verse_text verse =
  let cleaned = String.trim verse in
  (* 移除多余的标点符号 *)
  let punctuation_pattern = TextConfig.punctuation_chars in
  let clean_punctuation text =
    List.fold_left (fun acc punct ->
      let parts = String.split_on_char (String.get punct 0) acc in
      String.concat "" parts
    ) text punctuation_pattern
  in
  clean_punctuation cleaned

(** 标准化诗句列表 *)
let normalize_verses verses =
  verses
  |> List.map clean_verse_text
  |> List.filter (fun v -> String.length v > 0)
  |> List.map String.trim

(** {1 评价上下文过滤器} *)

(** 清理和验证评价上下文 *)
let validate_evaluation_context context =
  match validate_verse_input context.verse with
  | Error e -> Error e
  | Ok cleaned_verse ->
      match validate_verses_input context.verses with
      | Error e -> Error e
      | Ok cleaned_verses ->
          let normalized_verses = normalize_verses cleaned_verses in
          let poetry_form = detect_poetry_form normalized_verses in
          Ok {
            context with
            verse = cleaned_verse;
            verses = normalized_verses;
            poem_type = if context.poem_type = None then poetry_form else context.poem_type;
          }

(** {1 性能优化过滤器} *)

(** 早期终止条件检查 *)
let should_skip_evaluation dimension context =
  not (is_dimension_applicable dimension context) ||
  (List.length context.verses = 0 && dimension <> Imagery && dimension <> Rhythm)

(** 批量过滤维度 *)
let batch_filter_dimensions dimensions context =
  let applicable = filter_applicable_dimensions dimensions context in
  let by_form = 
    match context.poem_type with
    | Some form -> filter_by_poetry_form (Some form) applicable
    | None -> 
        let detected_form = detect_poetry_form context.verses in
        filter_by_poetry_form detected_form applicable
  in
  by_form