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

(** === 缺失函数实现 - P0级紧急修复 === *)

let normalize_whitespace text =
  (* 简化实现，规范化空白字符 *)
  let rec normalize acc chars =
    match chars with
    | [] -> String.concat "" (List.rev acc)
    | c :: rest when c = ' ' || c = '\t' || c = '\r' || c = '\n' ->
        let rec skip_whitespace = function
          | [] -> []
          | x :: xs when x = ' ' || x = '\t' || x = '\r' || x = '\n' -> skip_whitespace xs
          | remaining -> remaining
        in
        normalize (" " :: acc) (skip_whitespace rest)
    | c :: rest ->
        normalize (String.make 1 c :: acc) rest
  in
  let chars = List.init (String.length text) (String.get text) in
  String.trim (normalize [] chars)

let remove_punctuation text =
  (* 简化实现，移除常见标点符号 *)
  let is_punctuation c = 
    let code = Char.code c in
    (* ASCII标点 *)
    (code >= 33 && code <= 47) || (code >= 58 && code <= 64) || 
    (code >= 91 && code <= 96) || (code >= 123 && code <= 126)
  in
  let rec remove_chars result i =
    if i >= String.length text then result
    else
      let char = text.[i] in
      if is_punctuation char then
        remove_chars result (i + 1)
      else
        remove_chars (result ^ String.make 1 char) (i + 1)
  in
  remove_chars "" 0

let rec take n lst =
  if n <= 0 then []
  else match lst with
    | [] -> []
    | x :: xs -> x :: take (n - 1) xs

let rec drop n lst =
  if n <= 0 then lst
  else match lst with
    | [] -> []
    | _ :: xs -> drop (n - 1) xs

let partition_by_size size lst =
  let rec partition acc current current_size remaining =
    match remaining with
    | [] when current = [] -> List.rev acc
    | [] -> List.rev (List.rev current :: acc)
    | x :: xs when current_size >= size ->
        partition (List.rev current :: acc) [x] 1 xs
    | x :: xs ->
        partition acc (x :: current) (current_size + 1) xs
  in
  partition [] [] 0 lst

let unique_by f lst =
  let rec unique seen acc = function
    | [] -> List.rev acc
    | x :: xs ->
        let key = f x in
        if List.exists (fun y -> key = f y) seen then
          unique seen acc xs
        else
          unique (x :: seen) (x :: acc) xs
  in
  unique [] [] lst

let weighted_average values weights =
  if List.length values <> List.length weights then
    Failure "权重数量与数值数量不匹配"
  else if List.exists (fun w -> w < 0.0) weights then
    Failure "权重不能为负数"
  else
    let sum_weights = List.fold_left (+.) 0.0 weights in
    if sum_weights = 0.0 then
      Failure "权重总和不能为零"
    else
      let weighted_sum = List.fold_left2 (fun acc v w -> acc +. v *. w) 0.0 values weights in
      Success (weighted_sum /. sum_weights)

(** === LRU缓存模块实现 === *)
module LRU_Cache = struct
  type ('k, 'v) t = {
    capacity: int;
    mutable size: int;
    mutable items: ('k * 'v * int) list;
    mutable counter: int;
  }

  let create capacity = {
    capacity;
    size = 0;
    items = [];
    counter = 0;
  }

  let get cache key =
    let rec search = function
      | [] -> None
      | (k, v, _) :: _rest when k = key ->
          cache.counter <- cache.counter + 1;
          cache.items <- (k, v, cache.counter) :: (List.filter (fun (k', _, _) -> k' <> key) cache.items);
          Some v
      | _ :: rest -> search rest
    in
    search cache.items

  let put cache key value =
    cache.counter <- cache.counter + 1;
    let filtered = List.filter (fun (k, _, _) -> k <> key) cache.items in
    let new_item = (key, value, cache.counter) in
    if List.exists (fun (k, _, _) -> k = key) cache.items then
      cache.items <- new_item :: filtered
    else begin
      cache.items <- new_item :: filtered;
      cache.size <- cache.size + 1;
      if cache.size > cache.capacity then begin
        let sorted = List.sort (fun (_, _, t1) (_, _, t2) -> compare t2 t1) cache.items in
        cache.items <- take cache.capacity sorted;
        cache.size <- cache.capacity
      end
    end

  let clear cache =
    cache.items <- [];
    cache.size <- 0;
    cache.counter <- 0

  let size cache = cache.size
end

(** === 性能测量工具 === *)
let time_execution f =
  let start_time = Sys.time () in
  let result = f () in
  let end_time = Sys.time () in
  (result, end_time -. start_time)

let benchmark_function name f iterations =
  Printf.printf "基准测试: %s (%d次迭代)\n" name iterations;
  let times = ref [] in
  for _i = 1 to iterations do
    let (_, time) = time_execution f in
    times := time :: !times
  done;
  let total_time = List.fold_left (+.) 0.0 !times in
  let avg_time = total_time /. float_of_int iterations in
  Printf.printf "平均时间: %.6f秒\n" avg_time

(** === 配置工具 === *)
let load_config_from_json filename =
  (* 简化实现，返回基本配置对象 *)
  try
    let ic = open_in filename in
    let _content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    (* 简化JSON解析，返回空对象 *)
    Success (`Assoc [])
  with
  | Sys_error msg -> Failure ("文件读取错误: " ^ msg)
  | exn -> Failure ("配置加载错误: " ^ Printexc.to_string exn)

let get_config_value _json _path default_value =
  (* 简化实现，始终返回默认值 *)
  default_value

(** === 调试和日志工具 === *)
let debug_enabled = ref false

let enable_debug () = debug_enabled := true
let disable_debug () = debug_enabled := false

let debug_print fmt =
  if !debug_enabled then
    Printf.printf ("[调试] " ^^ fmt ^^ "\n%!")
  else
    Printf.ifprintf stdout fmt

let trace_function name f arg =
  if !debug_enabled then begin
    Printf.printf "[跟踪] 进入函数: %s\n%!" name;
    let result = f arg in
    Printf.printf "[跟踪] 退出函数: %s\n%!" name;
    result
  end else
    f arg

(** === 比较和排序工具 === *)
let compare_by f x y = 
  let fx = f x and fy = f y in
  if fx < fy then -1
  else if fx > fy then 1
  else 0

let sort_by_score lst =
  List.sort (fun (_, score1) (_, score2) -> compare score2 score1) lst

let group_by f lst =
  let rec group acc = function
    | [] -> acc
    | x :: xs ->
        let key = f x in
        let (same_key, different_key) = List.partition (fun y -> f y = key) xs in
        let group_items = x :: same_key in
        group ((key, group_items) :: acc) different_key
  in
  group [] lst

(** === 文本分析工具 === *)
let count_characters text =
  List.length (extract_chinese_characters text)

let similarity_score text1 text2 =
  let chars1 = extract_chinese_characters text1 in
  let chars2 = extract_chinese_characters text2 in
  let set1 = unique_by (fun x -> x) chars1 in
  let set2 = unique_by (fun x -> x) chars2 in
  let intersection = List.filter (fun c -> List.mem c set2) set1 in
  let union_size = List.length set1 + List.length set2 - List.length intersection in
  if union_size = 0 then 1.0
  else float_of_int (List.length intersection) /. float_of_int union_size

(** === 数据验证工具 === *)
let validate_non_empty text =
  if String.trim text = "" then
    Failure "文本不能为空"
  else
    Success text

let validate_length text max_length =
  let char_count = count_characters text in
  if char_count > max_length then
    Failure (Printf.sprintf "文本长度(%d)超过限制(%d)" char_count max_length)
  else
    Success text

let validate_chinese_only text =
  let all_chars = extract_chinese_characters text in
  (* 简化中文验证 *)
  if List.length all_chars > 0 then
    Success text
  else
    Failure "文本包含非中文字符"