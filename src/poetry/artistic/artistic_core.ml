(** 诗词艺术评估核心模块 - Phase 1-C 模块化重构
 *
 * 此模块包含核心评价算法和基础评价器实现
 * 从 artistic_evaluators.ml 中提取的核心功能
 *
 * @author Whisky, PR Worker - Phase 1-C 模块化重构
 * @refactors Issue #2171 - Phase 1-C 代码重构现代化
 *)

(** {1 核心类型定义} *)

type evaluation_dimension =
  | RhymeHarmony
  | TonalBalance
  | MetricalForm
  | Parallelism
  | Imagery
  | Rhythm
  | Elegance
  | ContentDepth
  | FormBeauty
  | SoundHarmony
  | ContextMood
  | EmotionExpression
  | Innovation
  | Overall

type dimension_score = {
  dimension : evaluation_dimension;
  score : float;
  max_possible : float;
  confidence : float;
  details : string option;
  suggestions : string list;
}

type artistic_evaluation = {
  overall_score : float;
  dimension_scores : dimension_score list;
  strengths : string list;
  weaknesses : string list;
  improvement_suggestions : string list;
  artistic_level : [ `Beginner | `Intermediate | `Advanced | `Master ];
  quality_grade : [ `Excellent | `Good | `Fair | `Poor ];
  evaluation_metadata : (string * string) list;
}

type evaluation_context = {
  verse : string;
  verses : string list;
  poem_type : string option;
  author : string option;
  historical_context : string option;
  metadata : (string * string) list;
}

(** {1 评价器接口定义} *)

module type EVALUATOR = sig
  val dimension : evaluation_dimension
  val name : string
  val description : string
  val weight : float
  val required_context : string list
  val is_applicable : evaluation_context -> bool
  val evaluate : evaluation_context -> dimension_score
end

(** {1 核心工具函数} *)

(** 字符串包含检测 - UTF-8安全 *)
let string_contains_substring s sub =
  let len_s = String.length s in
  let len_sub = String.length sub in
  let rec search i =
    if i + len_sub > len_s then false
    else if String.sub s i len_sub = sub then true
    else search (i + 1)
  in
  if len_sub = 0 then true
  else search 0

(** 列表取前 n 个元素 *)
let rec list_take n lst =
  if n <= 0 then []
  else match lst with
  | [] -> []
  | h :: t -> h :: list_take (n - 1) t

(** 提取韵脚字符 - 复杂UTF-8字符处理算法 *)
let extract_final_char verse =
  let trimmed = String.trim verse in
  if String.length trimmed > 0 then
    let len = String.length trimmed in
    let rec find_last_char pos =
      if pos <= 0 then None
      else
        let byte = Char.code trimmed.[pos] in
        if byte < 0x80 then (* ASCII *)
          if pos = len - 1 then Some (String.sub trimmed pos 1) else find_last_char (pos - 1)
        else if byte land 0xC0 = 0x80 then (* UTF-8续字节 *)
          find_last_char (pos - 1)
        else (* UTF-8起始字节 *)
          let char_len =
            if byte land 0xE0 = 0xC0 then 2
            else if byte land 0xF0 = 0xE0 then 3
            else if byte land 0xF8 = 0xF0 then 4
            else 1
          in
          if pos + char_len = len then Some (String.sub trimmed pos char_len)
          else find_last_char (pos - 1)
    in
    find_last_char (len - 1)
  else None

(** 计算韵律多样性 *)
let calculate_rhyme_diversity rhyme_chars =
  let unique_chars =
    let rec unique acc = function
      | [] -> List.rev acc
      | h :: t -> if List.mem h acc then unique acc t else unique (h :: acc) t
    in
    unique [] rhyme_chars
  in
  let unique_count = List.length unique_chars in
  let rhyme_count = List.length rhyme_chars in
  (float_of_int unique_count /. float_of_int rhyme_count, unique_count, rhyme_count)

(** 维度评分计算通用算法 *)
let calculate_weighted_score scores weights =
  let total_weight = List.fold_left (+.) 0.0 weights in
  if total_weight = 0.0 then 0.0
  else
    let weighted_sum = List.fold_left2 (fun acc score weight -> acc +. (score *. weight)) 0.0 scores weights in
    weighted_sum /. total_weight

(** 通用维度评分提取器 *)
let extract_dimension_score evaluation dimension =
  match List.find_opt (fun score -> score.dimension = dimension) evaluation.dimension_scores with
  | Some score -> score.score
  | None -> Artistic_config.default_evaluation_score