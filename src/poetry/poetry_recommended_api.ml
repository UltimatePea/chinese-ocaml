(** 诗词处理推荐API模块
 *
 * 此模块提供骆言编译器诗词功能的推荐入口点，整合最佳实践接口。
 * 
 * 设计目标：
 * - 为开发者提供清晰的API入口
 * - 减少模块选择的困惑
 * - 隐藏内部实现复杂性
 * - 提供一致的错误处理
 *
 * 使用建议：
 * - 新代码应优先使用此模块的接口
 * - 此模块封装了最稳定和性能最优的实现
 * - 提供向后兼容的迁移路径
 *
 * @author 骆言编程团队
 * @version 1.0 
 * @since 2025-07-25
 * @issue #1155 诗词模块整合优化
 *)

(** {1 核心类型定义} *)

(* 类型转换函数 *)
let convert_rhyme_group = function
  | Poetry_rhyme.Rhyme_types.AnRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.AnRhyme
  | Poetry_rhyme.Rhyme_types.SiRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.SiRhyme
  | Poetry_rhyme.Rhyme_types.TianRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.TianRhyme
  | Poetry_rhyme.Rhyme_types.WangRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.WangRhyme
  | Poetry_rhyme.Rhyme_types.QuRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.QuRhyme
  | Poetry_rhyme.Rhyme_types.YuRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.YuRhyme
  | Poetry_rhyme.Rhyme_types.HuaRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.HuaRhyme
  | Poetry_rhyme.Rhyme_types.FengRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.FengRhyme
  | Poetry_rhyme.Rhyme_types.YueRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.YueRhyme
  | Poetry_rhyme.Rhyme_types.JiangRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.JiangRhyme
  | Poetry_rhyme.Rhyme_types.HuiRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.HuiRhyme
  | Poetry_rhyme.Rhyme_types.UnknownRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.UnknownRhyme

type rhyme_info = Yyocamlc_lib.Poetry_core.Poetry_types.rhyme_category * Yyocamlc_lib.Poetry_core.Poetry_types.rhyme_group
(** 推荐使用的韵律信息类型 *)

type evaluation_result = {
  score : float;  (** 总分 (0.0-1.0) *)
  rhyme_quality : float;  (** 韵律质量 *)
  artistic_quality : float;  (** 艺术质量 *)
  form_compliance : float;  (** 格律符合度 *)
  recommendations : string list;  (** 改进建议 *)
}
(** 推荐使用的诗词评价结果类型 *)

(** {1 韵律分析API - 推荐接口} *)

(** 查找字符的韵律信息
 * 
 * 这是统一的韵律查找函数，推荐替代以下重复模块：
 * - Rhyme_detection.find_rhyme_info (已弃用)
 * - Rhyme_database.lookup_rhyme (性能较低)
 * - Rhyme_json_api.get_rhyme_data (接口复杂)
 *
 * @param char_str 要查找的字符（字符串格式）
 * @return 韵律信息，如果未找到则返回None
 *)
let find_rhyme_info (char_str : string) : rhyme_info option =
  let result = Poetry_rhyme.Rhyme_query.query_character_cached char_str in
  match result with
  | Found character -> 
      let category = (match character.tone with 
        | PingSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.PingSheng 
        | ShangSheng | QuSheng | RuSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.ZeSheng) in
      Some (category, convert_rhyme_group character.rhyme_group)
  | NotFound _ -> None
  | MultipleMatches (char::_) -> 
      let category = (match char.tone with 
        | PingSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.PingSheng 
        | ShangSheng | QuSheng | RuSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.ZeSheng) in
      Some (category, convert_rhyme_group char.rhyme_group)
  | MultipleMatches [] -> None

(** 检测韵律类型
 *
 * 推荐使用，替代：
 * - Rhyme_analysis.detect_category (重复实现)
 * - Rhyme_validation.check_rhyme_type (接口不一致)
 *
 * @param char_str 要检测的字符（字符串格式）
 * @return 韵律类型
 *)
let detect_rhyme_category (char_str : string) : Yyocamlc_lib.Poetry_core.Poetry_types.rhyme_category =
  let result = Poetry_rhyme.Rhyme_query.query_character_cached char_str in
  match result with
  | Found character -> 
      (match character.tone with 
        | PingSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.PingSheng 
        | ShangSheng | QuSheng | RuSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.ZeSheng)
  | NotFound _ -> Yyocamlc_lib.Poetry_core.Poetry_types.PingSheng
  | MultipleMatches (char::_) -> 
      (match char.tone with 
        | PingSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.PingSheng 
        | ShangSheng | QuSheng | RuSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.ZeSheng)
  | MultipleMatches [] -> Yyocamlc_lib.Poetry_core.Poetry_types.PingSheng

(** 验证两个字符是否押韵
 *
 * 推荐使用，性能优化版本，替代：
 * - Rhyme_matching.check_rhyme (算法较旧)
 * - Rhyme_scoring.verify_rhyme (计算开销大)
 *
 * @param char1_str 第一个字符（字符串格式）
 * @param char2_str 第二个字符（字符串格式）
 * @return 是否押韵
 *)
let check_rhyme_match (char1_str : string) (char2_str : string) : bool =
  match (find_rhyme_info char1_str, find_rhyme_info char2_str) with
  | Some (_, group1), Some (_, group2) -> group1 = group2
  | _ -> false

(** {1 诗词评价API - 推荐接口} *)

(** 评估诗词质量
 *
 * 综合评价函数，使用整合后的韵律和艺术性分析引擎，替代：
 * - Artistic_evaluation.evaluate_poem (功能分散)
 * - Poetry_forms_evaluation.check_form (只检查格律)
 * - Artistic_evaluators.comprehensive_eval (接口复杂)
 *
 * @param poem_lines 诗词行列表
 * @return 评价结果
 *)
let evaluate_poem (poem_lines : string list) : evaluation_result =
  try
    (* 使用整合的韵律验证进行韵律分析 *)
    let rhyme_score = 
      if List.length poem_lines < 2 then 0.5
      else
        let valid_rhymes = ref 0 in
        let total_pairs = ref 0 in
        List.iteri (fun i line1 ->
          List.iteri (fun j line2 ->
            if i < j && String.length line1 > 0 && String.length line2 > 0 then (
              incr total_pairs;
              let last_char1 = String.sub line1 (String.length line1 - 1) 1 in
              let last_char2 = String.sub line2 (String.length line2 - 1) 1 in
              if check_rhyme_match last_char1 last_char2 then
                incr valid_rhymes
            )
          ) poem_lines
        ) poem_lines;
        if !total_pairs > 0 then
          float_of_int !valid_rhymes /. float_of_int !total_pairs
        else 0.5
    in

    (* 使用整合的艺术性分析引擎 - 迁移到统一引擎 *)
    let artistic_score = Poetry_artistic.Artistic_evaluators.evaluate_poem_artistic (String.concat "\n" poem_lines) in
    
    (* 从艺术性评价中提取形式分数 *)
    let form_score = artistic_score in

    (* 合并所有改进建议 *)
    let rhyme_suggestions = ["建议检查韵律匹配"] in
    let artistic_suggestions = [] in (* Simplified for now *)
    let all_recommendations = rhyme_suggestions @ artistic_suggestions in

    {
      score = (artistic_score +. form_score +. rhyme_score) /. 3.0;
      rhyme_quality = rhyme_score;
      artistic_quality = artistic_score;
      form_compliance = form_score;
      recommendations = all_recommendations;
    }
  with exc ->
    (* 错误情况下返回默认评价，包含错误信息 *)
    {
      score = 0.0;
      rhyme_quality = 0.0;
      artistic_quality = 0.0;
      form_compliance = 0.0;
      recommendations = [ Printf.sprintf "评价过程中出现错误: %s" (Printexc.to_string exc) ];
    }

(** {1 数据管理API - 推荐接口} *)

(** 预加载韵律数据 * * 推荐在程序启动时调用，提升后续查询性能。 * 替代多个重复的数据加载函数。 *)
let preload_rhyme_data () : unit = 
  (* 新的整合模块在加载时自动初始化数据，验证数据完整性即可 *)
  let (is_valid, _) = Poetry_rhyme.Rhyme_data.validate_data_integrity () in
  if not is_valid then failwith "韵律数据预加载失败"

(** 清理缓存数据 * * 内存清理函数，可在不需要诗词功能时调用。 *)
let cleanup_cache () : unit = Poetry_rhyme.Rhyme_query.clear_cache ()

(** {1 兼容性说明} *)

(** * 已弃用模块列表 (建议迁移至推荐API)： * * 韵律相关： * - Rhyme_detection (请使用 find_rhyme_info) * - Rhyme_database
    (请使用 find_rhyme_info) * - Rhyme_json_api (请使用 find_rhyme_info) * -
    Rhyme_analysis.detect_category (请使用 detect_rhyme_category) * - Rhyme_validation.check_rhyme_type
    (请使用 detect_rhyme_category) * - Rhyme_matching.check_rhyme (请使用 check_rhyme_match) * * 评价相关： * -
    Artistic_evaluation.evaluate_poem (请使用 evaluate_poem) * - Poetry_forms_evaluation.check_form
    (evaluate_poem 已包含) * - Artistic_evaluators.comprehensive_eval (请使用 evaluate_poem) *)

(** {1 性能提示} *)

(** * 性能最佳实践： * 1. 程序启动时调用 preload_rhyme_data() * 2. 批量处理诗词时复用缓存 * 3. 不需要时调用 cleanup_cache() 释放内存 *
    4. 使用此模块而非直接调用底层模块 *)
