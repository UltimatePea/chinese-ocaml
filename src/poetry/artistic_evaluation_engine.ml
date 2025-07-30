(* 艺术数据评价引擎模块 *)

open Artistic_core_types

(** {1 评价标准管理} *)

let get_standard_weights () : (evaluation_dimension * float) list query_result =
  let default_weights = [
    (RhymeHarmony, 0.20);
    (TonalBalance, 0.20);
    (Parallelism, 0.15);
    (ImageryDepth, 0.15);
    (FormBeauty, 0.10);
    (ContentDepth, 0.10);
    (MoodContext, 0.10);
  ] in
  Found default_weights

let validate_evaluation_criteria (dimension : evaluation_dimension) (criteria_text : string) : bool query_result =
  let dimension_keywords = match dimension with
    | RhymeHarmony -> ["韵"; "音"; "和谐"]
    | TonalBalance -> ["平"; "仄"; "声调"]
    | Parallelism -> ["对仗"; "工整"; "对偶"]
    | ImageryDepth -> ["意象"; "深度"; "内容"]
    | FormBeauty -> ["形式"; "美感"; "结构"]
    | ContentDepth -> ["内容"; "深度"; "思想"]
    | MoodContext -> ["意境"; "营造"; "氛围"]
  in
  let contains_keywords = List.exists (fun keyword ->
    String.contains criteria_text (String.get keyword 0)
  ) dimension_keywords in
  Found contains_keywords

(** {1 艺术性评分计算} *)

let calculate_artistic_score (text : string) : (evaluation_dimension * float) list query_result =
  let base_scores = [
    (RhymeHarmony, 0.7);
    (TonalBalance, 0.6);
    (Parallelism, 0.5);
    (ImageryDepth, 0.8);
    (FormBeauty, 0.6);
    (ContentDepth, 0.7);
    (MoodContext, 0.8);
  ] in
  
  let text_length = String.length text in
  let length_factor = min 1.0 (float_of_int text_length /. 20.0) in
  
  let adjusted_scores = List.map (fun (dim, score) ->
    (dim, score *. length_factor)
  ) base_scores in
  
  Found adjusted_scores

let compare_artistic_quality (text1 : string) (text2 : string) : (evaluation_dimension * float * float) list query_result =
  match calculate_artistic_score text1, calculate_artistic_score text2 with
  | Found scores1, Found scores2 ->
      let comparison = List.map2 (fun (dim1, score1) (dim2, score2) ->
        assert (dim1 = dim2);
        (dim1, score1, score2)
      ) scores1 scores2 in
      Found comparison
  | Found _, NotFound -> QueryError "无法计算第二个文本的评分"
  | NotFound, Found _ -> QueryError "无法计算第一个文本的评分"
  | NotFound, NotFound -> QueryError "无法计算两个文本的评分"
  | QueryError err, _ -> QueryError err
  | _, QueryError err -> QueryError err

(** {1 改进建议生成} *)

let suggest_improvements (_ : string) (focus_dimension : evaluation_dimension) : string list query_result =
  let suggestions = match focus_dimension with
    | RhymeHarmony -> ["检查韵脚的一致性"; "调整音韵搭配"]
    | TonalBalance -> ["平衡平仄声调"; "注意声律变化"]
    | Parallelism -> ["加强对仗工整度"; "对偶句式对称"]
    | ImageryDepth -> ["丰富意象内容"; "加深意象层次"]
    | FormBeauty -> ["优化诗句结构"; "注意形式美感"]
    | ContentDepth -> ["深化思想内容"; "提升表达深度"]
    | MoodContext -> ["营造更佳意境"; "强化情感表达"]
  in
  Found suggestions

(** {1 单词雅致度评估} *)

let assess_word_elegance (word : string) : float query_result =
  (* Simplified implementation to avoid circular dependency *)
  if List.mem word ["之"; "者"; "也"; "矣"; "乎"; "哉"; "焉"; "夫"; "其"; "若"] then
    Found 0.8
  else
    Found 0.1