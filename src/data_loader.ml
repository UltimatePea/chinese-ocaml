(** 数据加载器模块 - 骆言项目 Phase 10 技术债务清理
    
    负责从外部数据文件加载各种配置数据，实现数据与代码分离。
    支持JSON格式数据文件的解析、缓存和错误处理。
    
    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-19 *)

open Printf

(** 数据加载器的错误类型 *)
type data_error =
  | FileNotFound of string
  | ParseError of string * string  (** 文件名 * 错误信息 *)
  | ValidationError of string * string  (** 数据类型 * 错误详情 *)

(** 数据加载结果 *)
type 'a data_result = 
  | Success of 'a
  | Error of data_error

(** 缓存管理 *)
module Cache = struct
  type 'a cache_entry = {
    data: 'a;
    timestamp: float;
  }

  let cache_table : (string, Obj.t cache_entry) Hashtbl.t = Hashtbl.create 16

  (** 缓存存活时间（秒） *)
  let cache_ttl = 300.0  (* 5 minutes *)

  (** 检查缓存是否有效 *)
  let is_cache_valid timestamp =
    let current_time = Unix.time () in
    current_time -. timestamp < cache_ttl

  (** 获取缓存数据 *)
  let get_cached key =
    try
      let entry = Hashtbl.find cache_table key in
      if is_cache_valid entry.timestamp then
        Some (Obj.obj entry.data)
      else (
        Hashtbl.remove cache_table key;
        None
      )
    with Not_found -> None

  (** 设置缓存数据 *)
  let set_cache key data =
    let entry = {
      data = Obj.repr data;
      timestamp = Unix.time ();
    } in
    Hashtbl.replace cache_table key entry

  (** 清空缓存 *)
  let clear_cache () = Hashtbl.clear cache_table
end

(** 文件读取工具 *)
module FileReader = struct
  (** 读取文件内容 *)
  let read_file_content filename =
    try
      let ic = open_in filename in
      let content = really_input_string ic (in_channel_length ic) in
      close_in ic;
      Success content
    with
    | Sys_error _ -> Error (FileNotFound filename)
    | e -> Error (ParseError (filename, Printexc.to_string e))

  (** 获取数据文件路径 *)
  let get_data_path relative_path =
    (* 数据文件位于项目根目录的 data/ 文件夹中 *)
    let project_root = Sys.getcwd () in
    Filename.concat (Filename.concat project_root "data") relative_path
end

(** JSON解析器 - 简化版本，专门用于我们的数据格式 *)
module SimpleJsonParser = struct
  (** 去除空白字符 *)
  let trim_whitespace s =
    let len = String.length s in
    let rec start i =
      if i >= len then len
      else match s.[i] with
        | ' ' | '\t' | '\n' | '\r' -> start (i + 1)
        | _ -> i
    in
    let rec finish i =
      if i < 0 then -1
      else match s.[i] with
        | ' ' | '\t' | '\n' | '\r' -> finish (i - 1)
        | _ -> i
    in
    let s_start = start 0 in
    let s_end = finish (len - 1) in
    if s_start > s_end then ""
    else String.sub s s_start (s_end - s_start + 1)

  (** 解析字符串数组 - 简化版本 *)
  let parse_string_array content =
    try
      (* 移除外层的方括号和空白 *)
      let trimmed = trim_whitespace content in
      if String.length trimmed < 2 then []
      else if trimmed.[0] <> '[' || trimmed.[String.length trimmed - 1] <> ']' then
        []
      else
        let inner = String.sub trimmed 1 (String.length trimmed - 2) in
        let items = String.split_on_char ',' inner in
        List.map (fun item ->
          let cleaned = trim_whitespace item in
          (* 移除引号 *)
          if String.length cleaned >= 2 && cleaned.[0] = '"' && cleaned.[String.length cleaned - 1] = '"' then
            String.sub cleaned 1 (String.length cleaned - 2)
          else
            cleaned
        ) items
        |> List.filter (fun s -> String.length s > 0)
    with
    | _ -> []

  (** 解析键值对数组 - 用于词性数据 *)
  let parse_word_class_pairs content =
    try
      (* 这个函数解析形如 [{"word": "山", "class": "Noun"}, ...] 的JSON *)
      let trimmed = trim_whitespace content in
      if String.length trimmed < 2 then []
      else if trimmed.[0] <> '[' || trimmed.[String.length trimmed - 1] <> ']' then
        []
      else
        let inner = String.sub trimmed 1 (String.length trimmed - 2) in
        (* 简化的对象解析 - 这里我们使用正则表达式的简化版本 *)
        let items = String.split_on_char '}' inner in
        List.fold_left (fun acc item ->
          if String.contains item '"' then
            try
              (* 提取word和class字段 - 简化处理 *)
              let parts = String.split_on_char '"' item in
              let rec extract_pair parts =
                match parts with
                | _ :: "word" :: _ :: word :: _ :: "class" :: _ :: class_name :: _ ->
                    Some (word, class_name)
                | _ :: "class" :: _ :: class_name :: _ :: "word" :: _ :: word :: _ ->
                    Some (word, class_name)
                | _ :: rest -> extract_pair rest
                | [] -> None
              in
              match extract_pair parts with
              | Some (word, class_name) -> (word, class_name) :: acc
              | None -> acc
            with _ -> acc
          else acc
        ) [] items
        |> List.rev
    with
    | _ -> []
end

(** 通用数据加载器 *)
module Loader = struct
  (** 加载字符串列表数据 *)
  let load_string_list ?(use_cache=true) relative_path =
    let cache_key = "string_list:" ^ relative_path in
    
    (* 检查缓存 *)
    (if use_cache then
      match Cache.get_cached cache_key with
      | Some data -> Some (Success (data : string list))
      | None -> None
    else None) |> function
    | Some result -> result
    | None ->
    
    (* 从文件加载 *)
    let full_path = FileReader.get_data_path relative_path in
    match FileReader.read_file_content full_path with
    | Error err -> Error err
    | Success content ->
        let string_list = SimpleJsonParser.parse_string_array content in
        if use_cache then Cache.set_cache cache_key string_list;
        Success string_list

  (** 加载词性数据对 *)
  let load_word_class_pairs ?(use_cache=true) relative_path =
    let cache_key = "word_class_pairs:" ^ relative_path in
    
    (* 检查缓存 *)
    (if use_cache then
      match Cache.get_cached cache_key with
      | Some data -> Some (Success (data : (string * string) list))
      | None -> None
    else None) |> function
    | Some result -> result
    | None ->
    
    (* 从文件加载 *)
    let full_path = FileReader.get_data_path relative_path in
    match FileReader.read_file_content full_path with
    | Error err -> Error err
    | Success content ->
        let pairs = SimpleJsonParser.parse_word_class_pairs content in
        if use_cache then Cache.set_cache cache_key pairs;
        Success pairs

  (** 提供降级机制 - 如果文件不存在则返回默认数据 *)
  let load_with_fallback loader relative_path fallback_data =
    match loader relative_path with
    | Success data -> data
    | Error (FileNotFound _) -> 
        Printf.eprintf "警告: 数据文件 %s 不存在，使用默认数据\n" relative_path;
        fallback_data
    | Error (ParseError (file, msg)) ->
        Printf.eprintf "警告: 解析数据文件 %s 失败: %s，使用默认数据\n" file msg;
        fallback_data
    | Error (ValidationError (dtype, msg)) ->
        Printf.eprintf "警告: 验证数据类型 %s 失败: %s，使用默认数据\n" dtype msg;
        fallback_data
end

(** 数据验证器 *)
module Validator = struct
  (** 验证字符串列表 *)
  let validate_string_list data =
    let is_valid_chinese_char s =
      String.length s > 0 && 
      let code = Char.code s.[0] in
      code >= 0x4E00 && code <= 0x9FFF  (* 简化的中文字符检查 *)
    in
    
    let invalid_items = List.filter (fun s -> not (is_valid_chinese_char s)) data in
    if List.length invalid_items > 0 then
      let first_invalid = List.hd invalid_items in
      Error (ValidationError ("string_list", sprintf "无效的中文字符: %s" first_invalid))
    else
      Success data

  (** 验证词性数据对 *)
  let validate_word_class_pairs data =
    let valid_classes = [
      "Noun"; "Verb"; "Adjective"; "Adverb"; "Numeral"; 
      "Classifier"; "Pronoun"; "Preposition"; "Conjunction"; 
      "Particle"; "Interjection"; "Unknown"
    ] in
    
    let is_valid_class class_name = List.mem class_name valid_classes in
    
    let invalid_pairs = List.filter (fun (_, class_name) -> not (is_valid_class class_name)) data in
    if List.length invalid_pairs > 0 then
      let (word, invalid_class) = List.hd invalid_pairs in
      Error (ValidationError ("word_class_pairs", sprintf "无效的词性 %s for word %s" invalid_class word))
    else
      Success data
end

(** 错误处理工具 *)
module ErrorHandler = struct
  (** 格式化错误信息 *)
  let format_error = function
    | FileNotFound file -> sprintf "文件未找到: %s" file
    | ParseError (file, msg) -> sprintf "解析文件 %s 失败: %s" file msg
    | ValidationError (dtype, msg) -> sprintf "验证数据类型 %s 失败: %s" dtype msg

  (** 记录错误日志 *)
  let log_error error =
    let error_msg = format_error error in
    Printf.eprintf "[数据加载器错误] %s\n" error_msg;
    flush stderr

  (** 处理错误结果 *)
  let handle_error_result = function
    | Success data -> data
    | Error error ->
        log_error error;
        failwith (format_error error)
end

(** 统计信息 *)
module Stats = struct
  let load_count = ref 0
  let cache_hits = ref 0
  let cache_misses = ref 0

  let increment_load () = incr load_count
  let increment_cache_hit () = incr cache_hits
  let increment_cache_miss () = incr cache_misses

  let print_stats () =
    printf "数据加载器统计:\n";
    printf "  总加载次数: %d\n" !load_count;
    printf "  缓存命中: %d\n" !cache_hits;
    printf "  缓存未命中: %d\n" !cache_misses;
    printf "  缓存命中率: %.2f%%\n" 
      (if !load_count > 0 then (float_of_int !cache_hits) /. (float_of_int !load_count) *. 100.0 else 0.0)

  let reset_stats () =
    load_count := 0;
    cache_hits := 0;
    cache_misses := 0
end

(** 导出接口 *)
let load_string_list = Loader.load_string_list
let load_word_class_pairs = Loader.load_word_class_pairs
let load_with_fallback = Loader.load_with_fallback
let validate_string_list = Validator.validate_string_list
let validate_word_class_pairs = Validator.validate_word_class_pairs
let handle_error = ErrorHandler.handle_error_result
let clear_cache = Cache.clear_cache
let print_stats = Stats.print_stats