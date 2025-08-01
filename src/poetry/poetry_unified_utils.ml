(** 骆言诗词统一工具模块 - 韵律工具和辅助模块整合
 *
 * Issue #2015: 韵律工具和辅助模块整合
 * 将10个工具模块整合为3个高效模块的第一个：统一通用工具模块
 *
 * 整合的模块：
 * - rhyme_utils.ml (基础字符串、列表处理)
 * - core/poetry_utils.ml (高级工具、性能、配置)
 * - poetry_analysis_utils.ml (分析工具)
 *
 * Author: Whisky, PR Worker
 * @since 2025-08-01
 * @version 1.0 - 初始整合版本
 *)

open Poetry_core.Poetry_types

(** {1 核心依赖和模块定义} *)

(* StringSet模块定义 - 用于高效字符串集合操作 *)
module StringSet = Set.Make(String)

(** {1 字符串处理工具} *)

(** === UTF-8和中文字符处理 === *)

(* 使用统一的UTF-8字符列表转换函数 *)
let utf8_to_char_list s = Yyocamlc_lib.Utf8_utils.StringUtils.utf8_to_char_list s
let string_to_char_list = Yyocamlc_lib.Utf8_utils.string_to_char_list
let char_list_to_string = Yyocamlc_lib.Utf8_utils.char_list_to_string

(* 使用统一的中文字符处理函数 *)
let is_chinese_char = Yyocamlc_lib.Utf8_utils.is_chinese_char
let filter_chinese_chars = Yyocamlc_lib.Utf8_utils.filter_chinese_chars
let chinese_length = Yyocamlc_lib.Utf8_utils.chinese_length

(* 获取字符串的最后一个字符 *)
let get_last_char s = if String.length s = 0 then None else Some s.[String.length s - 1]

(* 获取字符串的第一个字符 *)
let get_first_char s = if String.length s = 0 then None else Some s.[0]

(** === 高级中文字符处理 === *)

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

(** === 空白字符和格式化处理 === *)

(* 移除字符串中的空白字符 *)
let trim_whitespace s =
  let rec trim_left i =
    if i >= String.length s then ""
    else if s.[i] = ' ' || s.[i] = '\t' || s.[i] = '\n' || s.[i] = '\r' then trim_left (i + 1)
    else
      let rec trim_right j =
        if j < i then ""
        else if s.[j] = ' ' || s.[j] = '\t' || s.[j] = '\n' || s.[j] = '\r' then trim_right (j - 1)
        else String.sub s i (j - i + 1)
      in
      trim_right (String.length s - 1)
  in
  trim_left 0

let normalize_whitespace text =
  let whitespace_regex = Str.regexp "[ \t\n\r]+" in
  Str.global_replace whitespace_regex " " (String.trim text)

let remove_punctuation text =
  let punctuation_chars = [ "。"; "，"; "；"; "："; "？"; "！"; "、"; "《"; "》"; "("; ")"; "["; "]" ] in
  List.fold_left
    (fun acc punc -> Str.global_replace (Str.regexp_string punc) "" acc)
    text punctuation_chars

(* 检查字符串是否为空或仅包含空白字符 *)
let is_empty_or_whitespace s = String.length (trim_whitespace s) = 0

(** === 诗词特定字符串处理 === *)

(* 分割字符串为诗句 *)
let split_verse_lines text =
  let lines = String.split_on_char '\n' text in
  List.map trim_whitespace lines |> List.filter (fun line -> String.length line > 0)

(* 规范化诗句格式 *)
let normalize_verse verse = trim_whitespace verse |> filter_chinese_chars

(* 判断两个字符串是否相等（忽略空白） *)
let equal_ignoring_whitespace s1 s2 = String.equal (trim_whitespace s1) (trim_whitespace s2)

(** === 高效子串搜索 === *)

(* 高效子串搜索：使用Boyer-Moore类似的优化思路 *)
let contains_substring text pattern =
  let text_len = String.length text in
  let pattern_len = String.length pattern in
  if pattern_len = 0 then true
  else if pattern_len > text_len then false
  else
    let rec search_from pos =
      if pos > text_len - pattern_len then false
      else
        let rec match_at start pattern_pos =
          if pattern_pos >= pattern_len then true
          else if text.[start + pattern_pos] = pattern.[pattern_pos] then
            match_at start (pattern_pos + 1)
          else false
        in
        if match_at pos 0 then true else search_from (pos + 1)
    in
    search_from 0

(** {1 列表处理工具} *)

(** === 基础列表操作 === *)

(* 安全获取列表元素 *)
let safe_nth list n = try Some (List.nth list n) with _ -> None

(* 安全获取列表头部 *)
let safe_head list = match list with [] -> None | h :: _ -> Some h

(* 安全获取列表尾部 *)
let safe_tail list = match list with [] -> None | _ :: t -> Some t

(* 列表去重 - 使用统一的List_utils实现 *)
let unique_list = Yyocamlc_lib.List_utils.Group.unique

(** === 高级列表操作 === *)

let rec take n lst =
  if n <= 0 then [] else match lst with [] -> [] | x :: xs -> x :: take (n - 1) xs

let rec drop n lst = if n <= 0 then lst else match lst with [] -> [] | _ :: xs -> drop (n - 1) xs

let partition_by_size size lst =
  let rec partition acc current current_size remaining =
    match remaining with
    | [] -> if current = [] then List.rev acc else List.rev (List.rev current :: acc)
    | x :: xs ->
        if current_size >= size then partition (List.rev current :: acc) [ x ] 1 xs
        else partition acc (x :: current) (current_size + 1) xs
  in
  partition [] [] 0 lst

let unique_by f lst =
  let seen = Hashtbl.create (List.length lst) in
  List.filter
    (fun x ->
      let key = f x in
      if Hashtbl.mem seen key then false
      else (
        Hashtbl.add seen key ();
        true))
    lst

(** === 集合操作 === *)

(* 计算两个列表的交集 - 保持多态性，优化小列表查找 *)
let intersect list1 list2 = 
  (* 为了保持多态性，对于小列表使用List.mem，大列表可以考虑其他策略 *)
  if List.length list2 > 100 then
    (* 对于大列表，使用哈希表优化 *)
    let hash_table = Hashtbl.create (List.length list2) in
    List.iter (fun x -> Hashtbl.replace hash_table x ()) list2;
    List.filter (fun x -> Hashtbl.mem hash_table x) list1
  else
    (* 对于小列表，保持原有逻辑 *)
    List.filter (fun x -> List.mem x list2) list1

(* 计算两个列表的并集 - 多态版本 *)
let union list1 list2 = 
  let combined = list1 @ list2 in
  let rec remove_dups acc seen = function
    | [] -> List.rev acc
    | h :: t -> 
        if List.mem h seen then remove_dups acc seen t
        else remove_dups (h :: acc) (h :: seen) t
  in
  remove_dups [] [] combined

(* 映射并过滤None值 *)
let filter_map f list =
  List.fold_right (fun x acc -> match f x with Some y -> y :: acc | None -> acc) list []

(** === 分组和枚举 === *)

(* 创建带编号的列表 *)
let enumerate list =
  let rec aux acc n = function [] -> List.rev acc | h :: t -> aux ((n, h) :: acc) (n + 1) t in
  aux [] 0 list

let group_by f lst =
  let groups = Hashtbl.create 16 in
  List.iter
    (fun item ->
      let key = f item in
      let current = match Hashtbl.find_opt groups key with Some items -> items | None -> [] in
      Hashtbl.replace groups key (item :: current))
    lst;
  Hashtbl.fold (fun key items acc -> (key, List.rev items) :: acc) groups []

(** {1 评分和评级工具} *)

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

let weighted_average scores weights =
  if List.length scores <> List.length weights then Result.Error "分数和权重列表长度不匹配"
  else
    let total_weight = List.fold_left ( +. ) 0.0 weights in
    if total_weight = 0.0 then Result.Error "总权重不能为零"
    else
      let weighted_sum =
        List.fold_left2 (fun acc score weight -> acc +. (score *. weight)) 0.0 scores weights
      in
      Result.Ok (weighted_sum /. total_weight)

(** {1 缓存工具} *)

module LRU_Cache = struct
  type ('k, 'v) t = {
    capacity : int;
    mutable size : int;
    table : ('k, 'v * int) Hashtbl.t;
    mutable timestamp : int;
  }

  let create capacity = { capacity; size = 0; table = Hashtbl.create capacity; timestamp = 0 }

  let get cache key =
    match Hashtbl.find_opt cache.table key with
    | Some (value, _) ->
        cache.timestamp <- cache.timestamp + 1;
        Hashtbl.replace cache.table key (value, cache.timestamp);
        Some value
    | None -> None

  let put cache key value =
    cache.timestamp <- cache.timestamp + 1;
    if Hashtbl.mem cache.table key then Hashtbl.replace cache.table key (value, cache.timestamp)
    else (
      if cache.size >= cache.capacity then (
        (* 移除最老的条目 *)
        let oldest_key = ref None in
        let oldest_time = ref max_int in
        Hashtbl.iter
          (fun k (_, time) ->
            if time < !oldest_time then (
              oldest_time := time;
              oldest_key := Some k))
          cache.table;
        match !oldest_key with
        | Some k ->
            Hashtbl.remove cache.table k;
            cache.size <- cache.size - 1
        | None -> ());
      Hashtbl.add cache.table key (value, cache.timestamp);
      cache.size <- cache.size + 1)

  let clear cache =
    Hashtbl.clear cache.table;
    cache.size <- 0;
    cache.timestamp <- 0

  let size cache = cache.size
end

(** {1 性能测量工具} *)

let time_execution f =
  let start_time = Unix.gettimeofday () in
  let result = f () in
  let end_time = Unix.gettimeofday () in
  (result, end_time -. start_time)

let benchmark_function name f iterations =
  let times = ref [] in
  for _ = 1 to iterations do
    let _, duration = time_execution f in
    times := duration :: !times
  done;
  let total_time = List.fold_left ( +. ) 0.0 !times in
  let avg_time = total_time /. float_of_int iterations in
  let min_time = List.fold_left min max_float !times in
  let max_time = List.fold_left max 0.0 !times in
  Printf.printf "基准测试 [%s]: 平均 %.6fs, 最小 %.6fs, 最大 %.6fs\n%!" name avg_time min_time max_time

(** {1 配置工具} *)

let load_config_from_json filename =
  try
    let content =
      let ic = open_in filename in
      let content = really_input_string ic (in_channel_length ic) in
      close_in ic;
      content
    in
    Success (Yojson.Safe.from_string content)
  with
  | Sys_error _ -> Failure ("文件未找到: " ^ filename)
  | Yojson.Json_error msg -> Failure ("JSON格式错误: " ^ msg)

let get_config_value json path default_value =
  let rec navigate json_obj = function
    | [] -> json_obj
    | key :: rest -> (
        match json_obj with
        | `Assoc assoc -> (
            match List.assoc_opt key assoc with Some value -> navigate value rest | None -> `Null)
        | _ -> `Null)
  in
  let result = navigate json (String.split_on_char '.' path) in
  if result = `Null then default_value else result

(** {1 调试和日志工具} *)

let debug_enabled = ref false
let enable_debug () = debug_enabled := true
let disable_debug () = debug_enabled := false

let debug_print format =
  if !debug_enabled then Printf.printf ("[DEBUG] " ^^ format ^^ "\n%!")
  else Printf.ifprintf stdout format

let trace_function name f x =
  debug_print "进入函数: %s" name;
  let start_time = Unix.gettimeofday () in
  try
    let result = f x in
    let duration = Unix.gettimeofday () -. start_time in
    debug_print "退出函数: %s (耗时: %.6fs)" name duration;
    result
  with exn ->
    let duration = Unix.gettimeofday () -. start_time in
    debug_print "函数异常: %s (耗时: %.6fs, 异常: %s)" name duration (Printexc.to_string exn);
    raise exn

(** {1 比较和排序工具} *)

let compare_by f x y = compare (f x) (f y)
let sort_by_score items = List.sort (fun (_, score1) (_, score2) -> compare score2 score1) items

(** {1 文本分析工具} *)

let count_characters text = String.length (String.concat "" (extract_chinese_characters text))

let similarity_score text1 text2 =
  let chars1 = extract_chinese_characters text1 in
  let chars2 = extract_chinese_characters text2 in
  let set1 =
    List.fold_left (fun acc char -> if List.mem char acc then acc else char :: acc) [] chars1
  in
  let set2 =
    List.fold_left (fun acc char -> if List.mem char acc then acc else char :: acc) [] chars2
  in
  let intersection = List.filter (fun char -> List.mem char set2) set1 in
  let union_size = List.length set1 + List.length set2 - List.length intersection in
  if union_size = 0 then 1.0 else float_of_int (List.length intersection) /. float_of_int union_size

(** {1 词汇计数分析} *)

(* 高效计数函数：避免重复遍历和不必要的字符检查 *)
let count_imagery_words verse =
  let keywords = Poetry_data_unified.get_imagery_keywords () in
  List.fold_left
    (fun count keyword -> if contains_substring verse keyword then count + 1 else count)
    0 keywords

let count_elegant_words verse =
  let words = Poetry_data_unified.get_elegant_words () in
  List.fold_left
    (fun count word -> if contains_substring verse word then count + 1 else count)
    0 words

(** {1 改进建议生成} *)

let generate_improvement_suggestions report =
  let suggestions = ref [] in

  if report.rhyme_score < 0.6 then suggestions := "建议注意韵律和谐度，选择押韵字符" :: !suggestions;

  if report.tone_score < 0.6 then suggestions := "建议调整平仄搭配，增强声调平衡" :: !suggestions;

  if report.parallelism_score < 0.6 then suggestions := "建议工整对仗，注意字数和声调对应" :: !suggestions;

  if report.imagery_score < 0.6 then suggestions := "建议丰富意象，增加自然和情感元素" :: !suggestions;

  if report.rhythm_score < 0.6 then suggestions := "建议调整节奏感，适度变化声调" :: !suggestions;

  if report.elegance_score < 0.6 then suggestions := "建议提高雅致程度，使用更文雅的词汇" :: !suggestions;

  List.rev !suggestions

(** {1 高阶分析工具} *)

let detect_artistic_flaws _verse report =
  let flaws = ref [] in

  if report.rhyme_score < 0.5 then flaws := "韵律和谐度不足" :: !flaws;
  if report.tone_score < 0.5 then flaws := "平仄搭配不当" :: !flaws;
  if report.imagery_score < 0.5 then flaws := "意象贫乏" :: !flaws;
  if report.rhythm_score < 0.5 then flaws := "节奏感不强" :: !flaws;
  if report.elegance_score < 0.5 then flaws := "用词不够雅致" :: !flaws;

  List.rev !flaws

let calculate_overall_score report =
  let total =
    report.rhyme_score +. report.tone_score +. report.parallelism_score +. report.imagery_score
    +. report.rhythm_score +. report.elegance_score
  in
  total /. 6.0

(** {1 数据验证工具} *)

let validate_non_empty text = if String.trim text = "" then Failure "输入为空" else Success text

let validate_length text max_length =
  let length = count_characters text in
  if length > max_length then
    Failure ("文本过长: 当前长度 " ^ string_of_int length ^ ", 最大长度 " ^ string_of_int max_length)
  else Success text

let validate_chinese_only text =
  let chars = extract_chinese_characters text in
  let original_chars = String.length text in
  let chinese_chars = List.length chars in
  if chinese_chars * 3 <> original_chars then Failure "文本包含非中文字符" else Success text

(** {1 字符串格式化辅助函数} *)

(* 字符串格式化辅助函数 *)
let format_list to_string separator list = String.concat separator (List.map to_string list)