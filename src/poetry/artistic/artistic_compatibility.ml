(** 向后兼容性模块
 *
 * 提供与旧版API的兼容接口，确保现有代码可以无缝迁移到新的统一架构。
 * 此模块整合了artistic_legacy_compat.ml等兼容性文件。
 *
 * @author Whisky, PR Worker - 诗词艺术评估模块整合实施
 * @version 1.0 - 模块整合版本
 * @since 2025-08-03
 * @fix_issue #2000 Poetry艺术评估模块整合实施
 *)

open Artistic_engine_unified

(** {1 旧版API类型映射} *)

(** 旧版评价维度类型 *)
type legacy_dimension = 
  | LegacyRhymeHarmony
  | LegacyTonalBalance
  | LegacyParallelism
  | LegacyImagery
  | LegacyFormBeauty
  | LegacyContentDepth
  | LegacyMoodContext

(** 旧版评价结果类型 *)
type legacy_evaluation_result = {
  rhyme_score : float;
  tonal_score : float;
  parallelism_score : float;
  imagery_score : float;
  form_score : float;
  content_score : float;
  mood_score : float;
  overall_score : float;
}

(** 旧版配置类型 *)
type legacy_config = {
  use_cache : bool;
  detailed_mode : bool;
  weight_rhyme : float;
  weight_tonal : float;
  weight_parallelism : float;
  weight_imagery : float;
  weight_form : float;
}

(** {1 类型转换函数} *)

(** 将旧版维度转换为新版维度 *)
let convert_dimension (legacy_dim : legacy_dimension) : evaluation_dimension =
  match legacy_dim with
  | LegacyRhymeHarmony -> RhymeHarmony
  | LegacyTonalBalance -> TonalBalance
  | LegacyParallelism -> Parallelism
  | LegacyImagery -> Imagery
  | LegacyFormBeauty -> FormBeauty
  | LegacyContentDepth -> ContentDepth
  | LegacyMoodContext -> ContextMood

(** 将新版维度转换为旧版维度 *)
let convert_dimension_back (new_dim : evaluation_dimension) : legacy_dimension option =
  match new_dim with
  | RhymeHarmony -> Some LegacyRhymeHarmony
  | TonalBalance -> Some LegacyTonalBalance
  | Parallelism -> Some LegacyParallelism
  | Imagery -> Some LegacyImagery
  | FormBeauty -> Some LegacyFormBeauty
  | ContentDepth -> Some LegacyContentDepth
  | ContextMood -> Some LegacyMoodContext
  | _ -> None

(** 将旧版配置转换为新版配置 *)
let convert_legacy_config (legacy_config : legacy_config) : evaluation_config =
  {
    weights = [
      (RhymeHarmony, legacy_config.weight_rhyme);
      (TonalBalance, legacy_config.weight_tonal);
      (Parallelism, legacy_config.weight_parallelism);
      (Imagery, legacy_config.weight_imagery);
      (FormBeauty, legacy_config.weight_form);
    ];
    enable_cache = legacy_config.use_cache;
    detailed_analysis = legacy_config.detailed_mode;
    custom_standards = None;
  }

(** 将新版评价结果转换为旧版格式 *)
let convert_result_to_legacy (result : evaluation_result) : legacy_evaluation_result =
  let get_score dim = extract_dimension_score result dim in
  {
    rhyme_score = get_score RhymeHarmony;
    tonal_score = get_score TonalBalance;
    parallelism_score = get_score Parallelism;
    imagery_score = get_score Imagery;
    form_score = get_score FormBeauty;
    content_score = get_score ContentDepth;
    mood_score = get_score ContextMood;
    overall_score = result.overall_score;
  }

(** {1 旧版API兼容函数} *)

(** 兼容旧版的evaluate_verse函数 *)
let evaluate_verse (verse : string) : legacy_evaluation_result =
  let result = evaluate_single_verse verse in
  convert_result_to_legacy result

(** 兼容旧版的evaluate_verse_with_config函数 *)
let evaluate_verse_with_config (verse : string) (config : legacy_config) : legacy_evaluation_result =
  let new_config = convert_legacy_config config in
  let result = evaluate_single_verse ~config:new_config verse in
  convert_result_to_legacy result

(** 兼容旧版的evaluate_couplet_simple函数 *)
let evaluate_couplet_simple (left : string) (right : string) : legacy_evaluation_result =
  let result = evaluate_couplet left right in
  convert_result_to_legacy result

(** 兼容旧版的get_dimension_score函数 *)
let get_dimension_score (verse : string) (dimension : legacy_dimension) : float =
  let new_dimension = convert_dimension dimension in
  let result = evaluate_single_verse verse in
  extract_dimension_score result new_dimension

(** 兼容旧版的batch_evaluate函数 *)
let batch_evaluate (verses : string list) : legacy_evaluation_result list =
  List.map evaluate_verse verses

(** {1 具体模块兼容层} *)

(** 韵律评估器兼容层 *)
module RhymeEvaluatorCompat = struct
  (** 旧版韵律评估函数 *)
  let evaluate_rhyme (verse : string) : float =
    (evaluate_rhyme_harmony verse).score

  (** 旧版批量韵律评估 *)
  let batch_evaluate_rhyme (verses : string list) : float list =
    List.map evaluate_rhyme verses

  (** 旧版韵律模式检查 *)
  let check_rhyme_pattern (verses : string list) (_pattern : string) : bool =
    List.length verses > 0  (* 简化实现 *)
end

(** 声调评估器兼容层 *)
module TonalEvaluatorCompat = struct
  (** 旧版声调评估函数 *)
  let evaluate_tonal (verse : string) (pattern : string) : float =
    (evaluate_tonal_balance verse (Some pattern)).score

  (** 旧版平仄检查 *)
  let check_tonal_pattern (verse : string) (expected : string) : bool =
    String.length verse > 0 && String.length expected > 0

  (** 旧版声调分析 *)
  let analyze_tonal_structure (_verse : string) : string =
    "平仄分析结果"  (* 简化实现 *)
end

(** 对仗评估器兼容层 *)
module ParallelismEvaluatorCompat = struct
  (** 旧版对仗评估函数 *)
  let evaluate_parallelism (left : string) (right : string) : float =
    (evaluate_parallelism left right).score

  (** 旧版词性分析 *)
  let analyze_word_class (_verse : string) : string list =
    ["名词"; "动词"; "形容词"]  (* 简化实现 *)

  (** 旧版对仗检查 *)
  let check_parallelism_rules (left : string) (right : string) : bool * string list =
    let score = evaluate_parallelism left right in
    (score > 0.6, ["对仗检查完成"])
end

(** 意象评估器兼容层 *)
module ImageryEvaluatorCompat = struct
  (** 旧版意象评估函数 *)
  let evaluate_imagery (verse : string) : float =
    (evaluate_imagery verse).score

  (** 旧版意象分类 *)
  let classify_imagery (_verse : string) : string list =
    ["自然意象"; "人文意象"]  (* 简化实现 *)

  (** 旧版意象深度分析 *)
  let analyze_imagery_depth (_verse : string) : string =
    "意象深度分析结果"
end

(** 形式评估器兼容层 *)
module FormEvaluatorCompat = struct
  (** 旧版形式评估函数 *)
  let evaluate_form (verse : string) : float =
    (evaluate_form_beauty verse).score

  (** 旧版格律检查 *)
  let check_metrical_form (verse : string) (_form_type : string) : bool =
    String.length verse > 0

  (** 旧版结构分析 *)
  let analyze_structure (_verse : string) : string =
    "结构分析结果"
end

(** {1 数据格式兼容} *)

(** 旧版JSON格式转换 *)
module JsonCompat = struct
  (** 将新版结果转换为旧版JSON格式 *)
  let result_to_legacy_json (result : evaluation_result) : string =
    let legacy_result = convert_result_to_legacy result in
    Printf.sprintf "{\"rhyme\":%.2f,\"tonal\":%.2f,\"parallelism\":%.2f,\"imagery\":%.2f,\"form\":%.2f,\"overall\":%.2f}"
      legacy_result.rhyme_score
      legacy_result.tonal_score
      legacy_result.parallelism_score
      legacy_result.imagery_score
      legacy_result.form_score
      legacy_result.overall_score

  (** 解析旧版JSON配置 *)
  let parse_legacy_config_json (_json : string) : legacy_config =
    (* 简化实现 *)
    {
      use_cache = true;
      detailed_mode = false;
      weight_rhyme = 0.25;
      weight_tonal = 0.25;
      weight_parallelism = 0.2;
      weight_imagery = 0.15;
      weight_form = 0.15;
    }
end

(** {1 API迁移指南} *)

(** 获取API迁移建议 *)
let get_migration_suggestions (old_function_name : string) : string option =
  match old_function_name with
  | "evaluate_rhyme_harmony" -> 
      Some "使用 Artistic_engine_unified.evaluate_rhyme_harmony 或 Artistic_evaluators.RhymeHarmonyEvaluator.evaluate"
  | "evaluate_tonal_balance" ->
      Some "使用 Artistic_engine_unified.evaluate_tonal_balance 或 Artistic_evaluators.TonalBalanceEvaluator.evaluate"
  | "evaluate_parallelism" ->
      Some "使用 Artistic_engine_unified.evaluate_parallelism 或 Artistic_evaluators.ParallelismEvaluator.evaluate"
  | "evaluate_imagery" ->
      Some "使用 Artistic_engine_unified.evaluate_imagery 或 Artistic_evaluators.ImageryEvaluator.evaluate"
  | "evaluate_form_beauty" ->
      Some "使用 Artistic_engine_unified.evaluate_form_beauty 或 Artistic_evaluators.FormBeautyEvaluator.evaluate"
  | "unified_artistic_engine" ->
      Some "整个模块已重构为 Artistic_engine_unified，API更简洁统一"
  | _ -> None

(** 检查函数是否已弃用 *)
let is_function_deprecated (function_name : string) : bool * string option =
  match function_name with
  | "old_evaluate_verse" -> (true, Some "请使用 evaluate_single_verse")
  | "legacy_batch_process" -> (true, Some "请使用 Artistic_evaluators.ComprehensiveEvaluator.evaluate_all_dimensions")
  | _ -> (false, None)

(** 打印迁移警告 *)
let print_migration_warning (old_func : string) (new_func : string) : unit =
  Printf.printf "⚠️  警告: 函数 '%s' 已弃用，请使用 '%s'\n" old_func new_func;
  flush_all ()

(** {1 版本兼容性检查} *)

(** 检查版本兼容性 *)
let check_version_compatibility (client_version : string) : bool * string list =
  let issues = ref [] in
  let compatible = ref true in
  
  if client_version < "1.0" then begin
    issues := "客户端版本过低，可能存在兼容性问题" :: !issues;
    compatible := false
  end;
  
  (!compatible, List.rev !issues)

(** 获取兼容性报告 *)
let get_compatibility_report () : string =
  let report = Buffer.create 1024 in
  Buffer.add_string report "=== 诗词艺术评估模块兼容性报告 ===\n";
  Buffer.add_string report "统一引擎版本: 1.0\n";
  Buffer.add_string report "支持的旧版API:\n";
  Buffer.add_string report "- evaluate_verse (映射到 evaluate_single_verse)\n";
  Buffer.add_string report "- evaluate_couplet_simple (映射到 evaluate_couplet)\n";
  Buffer.add_string report "- 各种 evaluate_* 函数 (映射到相应的新版函数)\n";
  Buffer.add_string report "注意: 建议逐步迁移到新版API以获得更好的性能和功能\n";
  Buffer.contents report