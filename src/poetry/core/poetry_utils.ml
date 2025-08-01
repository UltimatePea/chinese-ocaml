(** 骆言诗词通用工具模块 (兼容性重定向层)
 *
 * Issue #2015: 韵律工具和辅助模块整合
 * 注意：由于库依赖限制，core子库不能直接引用主库的Poetry_unified_utils
 * 此模块保持基本功能以避免循环依赖
 *
 * Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理
 * Author: Whisky, PR Worker - 兼容性重定向层
 * @since 2025-08-01 - 重定向到统一工具模块
 *
 * 古云：工欲善其事，必先利其器。 此模块提供诗词模块的通用工具函数，避免代码重复。
 *)

open Poetry_types

(** 注意：此模块为兼容性保留，主要功能已迁移到主库的Poetry_unified_utils模块 *)

(** === 字符串处理工具 === *)

let is_chinese_character char =
  let byte_length = String.length char in
  byte_length >= 3 && byte_length <= 4
  &&
  let code = Char.code char.[0] in
  code >= 0xE4 && code <= 0xE9

let extract_chinese_characters text =
  let rec extract_chars acc i =
    if i >= String.length text then List.rev acc
    else
      let char_len =
        if i < String.length text - 2 then
          let first_byte = Char.code text.[i] in
          if first_byte >= 0xE4 && first_byte <= 0xE9 then 3
          else if first_byte >= 0xF0 && first_byte <= 0xF4 then 4
          else 1
        else 1
      in
      let char = String.sub text i (min char_len (String.length text - i)) in
      if is_chinese_character char then extract_chars (char :: acc) (i + char_len)
      else extract_chars acc (i + 1)
  in
  extract_chars [] 0

(** === 基本评分工具 === *)

let normalize_score score min_score max_score =
  if max_score <= min_score then 0.0
  else
    let clamped = max min_score (min max_score score) in
    (clamped -. min_score) /. (max_score -. min_score)

let score_to_grade score =
  if score >= 0.9 then Excellent
  else if score >= 0.7 then Good
  else if score >= 0.5 then Fair
  else Poor

let grade_to_score = function Excellent -> 0.95 | Good -> 0.8 | Fair -> 0.6 | Poor -> 0.3