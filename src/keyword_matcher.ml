(** 骆言词法分析器关键字匹配优化模块 - 模块化重构版本 *)

open Utf8_utils

(** 词法分析器状态类型 *)
type lexer_state = {
  input : string;
  position : int;
  length : int;
  current_line : int;
  current_column : int;
  filename : string;
}

(** 关键字查找表 - 使用高效的哈希表结构 *)
module KeywordTable = struct
  include Keyword_matcher_core.KeywordTable
end

(** 优化的关键字匹配算法 *)
module OptimizedMatcher = struct
  (** 尝试匹配关键字的优化版本 *)
  let try_match_keyword state =
    let rec try_keywords keywords best_match =
      match keywords with
      | [] -> best_match
      | (keyword, token) :: rest ->
          let keyword_len = String.length keyword in
          if state.position + keyword_len <= state.length then
            let substring = String.sub state.input state.position keyword_len in
            if substring = keyword then
              (* 检查关键字边界 *)
              if BoundaryDetection.is_chinese_keyword_boundary state.input state.position keyword
              then
                (* 找到完整关键字，但继续检查是否有更长的匹配 *)
                let new_match = Some (token, keyword_len) in
                match best_match with
                | None -> try_keywords rest new_match
                | Some (_, best_len) when keyword_len > best_len -> try_keywords rest new_match
                | Some _ -> try_keywords rest best_match
              else try_keywords rest best_match
            else try_keywords rest best_match
          else try_keywords rest best_match
    in
    try_keywords (KeywordTable.get_all_keywords ()) None

  (** 高效的前缀匹配 *)
  let match_by_prefix state =
    let rec try_keywords keywords best_match =
      match keywords with
      | [] -> best_match
      | (keyword, token) :: rest ->
          let keyword_len = String.length keyword in
          if
            state.position + keyword_len <= state.length
            && String.sub state.input state.position keyword_len = keyword
            && BoundaryDetection.is_chinese_keyword_boundary state.input state.position keyword
          then
            let new_match = Some (token, keyword_len) in
            match best_match with
            | None -> try_keywords rest new_match
            | Some (_, best_len) when keyword_len > best_len -> try_keywords rest new_match
            | Some _ -> try_keywords rest best_match
          else try_keywords rest best_match
    in
    if state.position >= state.length then None
    else
      let c = state.input.[state.position] in
      (* 根据首字符快速过滤可能的关键字 *)
      let candidates =
        if Char.code c >= Constants.UTF8.chinese_char_threshold then
          (* 中文字符开头 - 搜索中文关键字 *)
          KeywordTable.get_all_chinese_keywords ()
        else
          (* ASCII字符开头 - 搜索ASCII关键字 *)
          KeywordTable.get_all_ascii_keywords ()
      in
      try_keywords candidates None
end

(** 关键字统计和分析工具 *)
module KeywordAnalytics = struct
  type keyword_stats = {
    total_keywords : int;
    chinese_keywords : int;
    ascii_keywords : int;
    avg_chinese_length : float;
    avg_ascii_length : float;
    max_length : int;
    min_length : int;
  }

  (** 分析关键字统计信息 *)
  let analyze_keywords () =
    let chinese_kws = KeywordTable.get_all_chinese_keywords () in
    let ascii_kws = KeywordTable.get_all_ascii_keywords () in

    let chinese_lengths = List.map (fun (kw, _) -> String.length kw) chinese_kws in
    let ascii_lengths = List.map (fun (kw, _) -> String.length kw) ascii_kws in
    let all_lengths = List.rev_append chinese_lengths ascii_lengths in

    let sum_chinese = List.fold_left ( + ) 0 chinese_lengths in
    let sum_ascii = List.fold_left ( + ) 0 ascii_lengths in

    {
      total_keywords = List.length chinese_kws + List.length ascii_kws;
      chinese_keywords = List.length chinese_kws;
      ascii_keywords = List.length ascii_kws;
      avg_chinese_length =
        (if chinese_lengths = [] then 0.0
         else float_of_int sum_chinese /. float_of_int (List.length chinese_lengths));
      avg_ascii_length =
        (if ascii_lengths = [] then 0.0
         else float_of_int sum_ascii /. float_of_int (List.length ascii_lengths));
      max_length = List.fold_left max 0 all_lengths;
      min_length = (match all_lengths with [] -> 0 | hd :: tl -> List.fold_left min hd tl);
    }

  (** 打印关键字统计信息 *)
  let print_keyword_stats stats =
    Unified_logging.Legacy.printf "=== 关键字统计分析 ===\n";
    Unified_logging.Legacy.printf "总关键字数: %d\n" stats.total_keywords;
    Unified_logging.Legacy.printf "中文关键字: %d\n" stats.chinese_keywords;
    Unified_logging.Legacy.printf "ASCII关键字: %d\n" stats.ascii_keywords;
    Unified_logging.Legacy.printf "中文关键字平均长度: %.2f 字符\n" stats.avg_chinese_length;
    Unified_logging.Legacy.printf "ASCII关键字平均长度: %.2f 字符\n" stats.avg_ascii_length;
    Unified_logging.Legacy.printf "最长关键字: %d 字符\n" stats.max_length;
    Unified_logging.Legacy.printf "最短关键字: %d 字符\n" stats.min_length;
    Unified_logging.Legacy.printf "==================\n"
end

(** 主要匹配函数 - 对外接口 *)
let match_keyword state = OptimizedMatcher.match_by_prefix state

(** 快速关键字查找 - 用于其他模块 *)
let lookup_keyword keyword_string = KeywordTable.find_keyword keyword_string

(** 检查字符串是否为关键字 *)
let is_keyword keyword_string =
  match lookup_keyword keyword_string with Some _ -> true | None -> false