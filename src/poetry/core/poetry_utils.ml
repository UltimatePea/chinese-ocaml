(** 骆言诗词通用工具模块
    Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理
    
    古云：工欲善其事，必先利其器。
    此模块提供诗词模块的通用工具函数，避免代码重复。
    
    设计原则：
    1. 纯函数优先 - 无副作用，便于测试和组合
    2. 性能优化 - 对频繁调用的函数进行优化
    3. 类型安全 - 充分利用OCaml的类型系统
    4. 可复用 - 函数设计要通用，避免业务逻辑耦合
*)

open Poetry_types

(** === 字符串处理工具 === *)

let is_chinese_character char =
  let byte_length = String.length char in
  byte_length >= 3 && byte_length <= 4 && 
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
      if is_chinese_character char then
        extract_chars (char :: acc) (i + char_len)
      else
        extract_chars acc (i + 1)
  in
  extract_chars [] 0

let normalize_whitespace text =
  let whitespace_regex = Str.regexp "[ \t\n\r]+" in
  Str.global_replace whitespace_regex " " (String.trim text)

let remove_punctuation text =
  let punctuation_chars = ["。"; "，"; "；"; "："; "？"; "！"; "、"; "《"; "》"; "("; ")"; "["; "]"] in
  List.fold_left (fun acc punc -> 
    Str.global_replace (Str.regexp_string punc) "" acc
  ) text punctuation_chars

(** === 列表处理工具 === *)

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
    | [] -> if current = [] then List.rev acc else List.rev (List.rev current :: acc)
    | x :: xs ->
        if current_size >= size then
          partition (List.rev current :: acc) [x] 1 xs
        else
          partition acc (x :: current) (current_size + 1) xs
  in
  partition [] [] 0 lst

let unique_by f lst =
  let seen = Hashtbl.create (List.length lst) in
  List.filter (fun x ->
    let key = f x in
    if Hashtbl.mem seen key then false
    else (Hashtbl.add seen key (); true)
  ) lst

(** === 分数和评级工具 === *)

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

let grade_to_score = function
  | Excellent -> 0.95
  | Good -> 0.8
  | Fair -> 0.6
  | Poor -> 0.3

let weighted_average scores weights =
  if List.length scores <> List.length weights then
    Result.Error "分数和权重列表长度不匹配"
  else
    let total_weight = List.fold_left (+.) 0.0 weights in
    if total_weight = 0.0 then
      Result.Error "总权重不能为零"
    else
      let weighted_sum = List.fold_left2 (fun acc score weight -> 
        acc +. score *. weight
      ) 0.0 scores weights in
      Result.Ok (weighted_sum /. total_weight)

(** === 缓存工具 === *)

module LRU_Cache = struct
  type ('k, 'v) t = {
    capacity : int;
    mutable size : int;
    table : ('k, 'v * int) Hashtbl.t;
    mutable timestamp : int;
  }

  let create capacity = {
    capacity;
    size = 0;
    table = Hashtbl.create capacity;
    timestamp = 0;
  }

  let get cache key =
    match Hashtbl.find_opt cache.table key with
    | Some (value, _) ->
        cache.timestamp <- cache.timestamp + 1;
        Hashtbl.replace cache.table key (value, cache.timestamp);
        Some value
    | None -> None

  let put cache key value =
    cache.timestamp <- cache.timestamp + 1;
    if Hashtbl.mem cache.table key then
      Hashtbl.replace cache.table key (value, cache.timestamp)
    else begin
      if cache.size >= cache.capacity then begin
        (* 移除最老的条目 *)
        let oldest_key = ref None in
        let oldest_time = ref max_int in
        Hashtbl.iter (fun k (_, time) ->
          if time < !oldest_time then begin
            oldest_time := time;
            oldest_key := Some k
          end
        ) cache.table;
        match !oldest_key with
        | Some k -> 
            Hashtbl.remove cache.table k;
            cache.size <- cache.size - 1
        | None -> ()
      end;
      Hashtbl.add cache.table key (value, cache.timestamp);
      cache.size <- cache.size + 1
    end

  let clear cache =
    Hashtbl.clear cache.table;
    cache.size <- 0;
    cache.timestamp <- 0

  let size cache = cache.size
end

(** === 性能测量工具 === *)

let time_execution f =
  let start_time = Unix.gettimeofday () in
  let result = f () in
  let end_time = Unix.gettimeofday () in
  (result, end_time -. start_time)

let benchmark_function name f iterations =
  let times = ref [] in
  for _ = 1 to iterations do
    let (_, duration) = time_execution f in
    times := duration :: !times
  done;
  let total_time = List.fold_left (+.) 0.0 !times in
  let avg_time = total_time /. float_of_int iterations in
  let min_time = List.fold_left min max_float !times in
  let max_time = List.fold_left max 0.0 !times in
  Printf.printf "基准测试 [%s]: 平均 %.6fs, 最小 %.6fs, 最大 %.6fs\n%!"
    name avg_time min_time max_time

(** === 配置工具 === *)

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
    | key :: rest ->
        match json_obj with
        | `Assoc assoc ->
            (match List.assoc_opt key assoc with
             | Some value -> navigate value rest
             | None -> `Null)
        | _ -> `Null
  in
  let result = navigate json (String.split_on_char '.' path) in
  if result = `Null then default_value else result

(** === 调试和日志工具 === *)

let debug_enabled = ref false

let enable_debug () = debug_enabled := true
let disable_debug () = debug_enabled := false

let debug_print format =
  if !debug_enabled then
    Printf.printf ("[DEBUG] " ^^ format ^^ "\n%!")
  else
    Printf.ifprintf stdout format

let trace_function name f x =
  debug_print "进入函数: %s" name;
  let start_time = Unix.gettimeofday () in
  try
    let result = f x in
    let duration = Unix.gettimeofday () -. start_time in
    debug_print "退出函数: %s (耗时: %.6fs)" name duration;
    result
  with
  | exn ->
    let duration = Unix.gettimeofday () -. start_time in
    debug_print "函数异常: %s (耗时: %.6fs, 异常: %s)" name duration (Printexc.to_string exn);
    raise exn

(** === 比较和排序工具 === *)

let compare_by f x y = compare (f x) (f y)

let sort_by_score items =
  List.sort (fun (_, score1) (_, score2) -> compare score2 score1) items

let group_by f lst =
  let groups = Hashtbl.create 16 in
  List.iter (fun item ->
    let key = f item in
    let current = match Hashtbl.find_opt groups key with
      | Some items -> items
      | None -> []
    in
    Hashtbl.replace groups key (item :: current)
  ) lst;
  Hashtbl.fold (fun key items acc -> (key, List.rev items) :: acc) groups []

(** === 文本分析工具 === *)

let count_characters text =
  String.length (String.concat "" (extract_chinese_characters text))

let similarity_score text1 text2 =
  let chars1 = extract_chinese_characters text1 in
  let chars2 = extract_chinese_characters text2 in
  let set1 = List.fold_left (fun acc char -> 
    if List.mem char acc then acc else char :: acc
  ) [] chars1 in
  let set2 = List.fold_left (fun acc char -> 
    if List.mem char acc then acc else char :: acc
  ) [] chars2 in
  let intersection = List.filter (fun char -> List.mem char set2) set1 in
  let union_size = List.length set1 + List.length set2 - List.length intersection in
  if union_size = 0 then 1.0
  else float_of_int (List.length intersection) /. float_of_int union_size

(** === 数据验证工具 === *)

let validate_non_empty text =
  if String.trim text = "" then
    Failure "输入为空"
  else
    Success text

let validate_length text max_length =
  let length = count_characters text in
  if length > max_length then
    Failure ("文本过长: 当前长度 " ^ string_of_int length ^ ", 最大长度 " ^ string_of_int max_length)
  else
    Success text

let validate_chinese_only text =
  let chars = extract_chinese_characters text in
  let original_chars = String.length text in
  let chinese_chars = List.length chars in
  if chinese_chars * 3 <> original_chars then
    Failure "文本包含非中文字符"
  else
    Success text