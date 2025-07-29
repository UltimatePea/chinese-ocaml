(** 统一数据加载器核心模块 - Poetry模块整合Phase 1

    此模块统一所有Poetry相关的数据加载功能，消除代码重复，
    提供一致的接口和错误处理机制。

    设计目标：
    1. 统一错误处理 - 所有加载器使用相同的错误类型
    2. 通用加载接口 - 支持不同类型的数据源
    3. 可扩展架构 - 便于添加新的数据类型
    4. 高性能实现 - 内置缓存和优化机制

    @author Alpha, 技术债务清理专员
    @version 1.0 - Phase 1 统一核心
    @since 2025-07-29
    @fix_issue #1729 *)

open Printf

(** {1 核心类型定义} *)

(** 数据加载错误类型 - 统一所有加载器的错误处理 *)
type unified_load_error =
  | FileNotFound of string  (** 文件未找到 *)
  | ParseError of string * string  (** 解析错误：文件名 * 错误描述 *)
  | ValidationError of string  (** 数据验证错误 *)
  | CacheError of string  (** 缓存错误 *)
  | NetworkError of string  (** 网络错误（用于远程数据源） *)
  | FormatError of string * string  (** 格式错误：预期格式 * 实际内容 *)

exception UnifiedLoadError of unified_load_error

(** 数据源类型 - 支持多种数据来源 *)
type data_source_type =
  | JsonFile of string  (** JSON文件路径 *)
  | JsonString of string  (** JSON字符串 *)
  | BinaryFile of string  (** 二进制文件路径 *)
  | RemoteUrl of string  (** 远程URL（预留） *)
  | CachedData of string  (** 缓存的数据键 *)

(** 数据类型分类 - 明确区分不同类型的诗词数据 *)
type data_content_type =
  | RhymeData  (** 韵律数据 *)
  | ToneData  (** 声调数据 *)
  | PoetryData  (** 诗词内容数据 *)
  | WordClassData  (** 词类数据 *)
  | ArtisticData  (** 艺术性评价数据 *)

(** 加载选项 - 控制加载行为 *)
type load_options = {
  use_cache : bool;  (** 是否使用缓存 *)
  validate_data : bool;  (** 是否验证数据 *)
  fallback_enabled : bool;  (** 是否启用备用数据源 *)
  max_retries : int;  (** 最大重试次数 *)
}

(** 默认加载选项 *)
let default_load_options = {
  use_cache = true;
  validate_data = true;
  fallback_enabled = true;
  max_retries = 3;
}

(** {1 错误处理辅助函数} *)

let format_error = function
  | FileNotFound file -> sprintf "文件未找到: %s" file
  | ParseError (file, msg) -> sprintf "解析错误 %s: %s" file msg
  | ValidationError msg -> sprintf "数据验证失败: %s" msg
  | CacheError msg -> sprintf "缓存错误: %s" msg
  | NetworkError msg -> sprintf "网络错误: %s" msg
  | FormatError (expected, actual) -> 
      sprintf "格式错误 - 期望: %s, 实际: %s" expected (String.sub actual 0 (min 50 (String.length actual)))

let raise_load_error error =
  raise (UnifiedLoadError error)

(** {1 通用文件操作} *)

(** 安全读取文件内容 *)
let read_file_safe filename =
  try
    if not (Sys.file_exists filename) then
      raise_load_error (FileNotFound filename);
    let ic = open_in filename in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    content
  with
  | Sys_error msg -> raise_load_error (FileNotFound (sprintf "%s (%s)" filename msg))
  | UnifiedLoadError _ as e -> raise e
  | exn -> raise_load_error (ParseError (filename, Printexc.to_string exn))

(** {1 JSON处理统一接口} *)

(** JSON解析辅助函数 *)
let parse_json_safe content filename =
  try
    Yojson.Safe.from_string content
  with
  | Yojson.Json_error msg -> raise_load_error (ParseError (filename, msg))
  | exn -> raise_load_error (ParseError (filename, Printexc.to_string exn))

(** 从JSON文件加载数据 *)
let load_json_file filename =
  let content = read_file_safe filename in
  parse_json_safe content filename

(** {1 缓存管理} *)

(** 简单内存缓存 *)
let cache_table : (string, Yojson.Safe.t) Hashtbl.t = Hashtbl.create 32

(** 缓存键生成 *)
let make_cache_key data_type source =
  let source_str = match source with
    | JsonFile path -> "file:" ^ path
    | JsonString _ -> "string:hash_" ^ (string_of_int (Hashtbl.hash source))
    | BinaryFile path -> "binary:" ^ path
    | RemoteUrl url -> "remote:" ^ url
    | CachedData key -> "cached:" ^ key
  in
  let type_str = match data_type with
    | RhymeData -> "rhyme"
    | ToneData -> "tone"
    | PoetryData -> "poetry"
    | WordClassData -> "wordclass"
    | ArtisticData -> "artistic"
  in
  sprintf "%s_%s" type_str source_str

(** 从缓存获取数据 *)
let get_from_cache cache_key =
  try
    Some (Hashtbl.find cache_table cache_key)
  with Not_found -> None

(** 存入缓存 *)
let store_in_cache cache_key data =
  Hashtbl.replace cache_table cache_key data

(** {1 统一加载接口} *)

(** 核心加载函数 - 支持所有数据源类型 *)
let rec load_data_unified ?(options = default_load_options) data_type source =
  let cache_key = make_cache_key data_type source in
  
  (* 1. 尝试从缓存加载 *)
  (if options.use_cache then
    match get_from_cache cache_key with
    | Some cached_data -> Some cached_data
    | None -> None
  else None) |> function
  | Some cached_data -> cached_data
  | None ->
  
  (* 2. 从数据源加载 *)
  let raw_data = match source with
    | JsonFile filename -> load_json_file filename
    | JsonString content -> parse_json_safe content "string_input"
    | BinaryFile _ -> raise_load_error (FormatError ("JSON", "Binary files not yet supported in Phase 1"))
    | RemoteUrl _ -> raise_load_error (FormatError ("JSON", "Remote URLs not yet supported in Phase 1"))
    | CachedData key -> 
        (match get_from_cache key with
         | Some data -> data
         | None -> raise_load_error (CacheError ("Cache key not found: " ^ key)))
  in
  
  (* 3. 数据验证（如果启用） *)
  if options.validate_data then
    validate_data_format data_type raw_data;
  
  (* 4. 存入缓存 *)
  if options.use_cache then
    store_in_cache cache_key raw_data;
  
  raw_data

(** 数据格式验证 *)
and validate_data_format data_type json_data =
  (* 基础JSON结构验证 *)
  try
    match data_type with
    | RhymeData -> 
        (* 验证韵律数据必须包含字符和韵组信息 *)
        (match json_data with
         | `Assoc _ -> () (* 基础对象结构 *)
         | `List _ -> ()  (* 或列表结构 *)
         | _ -> raise_load_error (ValidationError "韵律数据必须为对象或数组"))
    | ToneData ->
        (* 验证声调数据结构 *)
        (match json_data with
         | `Assoc _ | `List _ -> ()
         | _ -> raise_load_error (ValidationError "声调数据必须为对象或数组"))
    | PoetryData ->
        (* 验证诗词数据结构 *)
        (match json_data with
         | `Assoc _ | `List _ -> ()
         | _ -> raise_load_error (ValidationError "诗词数据必须为对象或数组"))
    | WordClassData ->
        (* 验证词类数据结构 *)
        (match json_data with
         | `Assoc _ | `List _ -> ()
         | _ -> raise_load_error (ValidationError "词类数据必须为对象或数组"))
    | ArtisticData ->
        (* 验证艺术性数据结构 *)
        (match json_data with
         | `Assoc _ | `List _ -> ()
         | _ -> raise_load_error (ValidationError "艺术性数据必须为对象或数组"))
  with
  | Yojson.Safe.Util.Type_error (msg, _) -> 
      raise_load_error (ValidationError ("JSON类型错误: " ^ msg))
  | UnifiedLoadError _ as e -> raise e
  | exn -> 
      raise_load_error (ValidationError ("验证过程中出现错误: " ^ Printexc.to_string exn))

(** {1 便捷加载函数} *)

(** 加载韵律数据 *)
let load_rhyme_data ?(options = default_load_options) source =
  load_data_unified ~options RhymeData source

(** 加载声调数据 *)
let load_tone_data ?(options = default_load_options) source =
  load_data_unified ~options ToneData source

(** 加载诗词数据 *)
let load_poetry_data ?(options = default_load_options) source =
  load_data_unified ~options PoetryData source

(** 加载词类数据 *)
let load_word_class_data ?(options = default_load_options) source =
  load_data_unified ~options WordClassData source

(** 加载艺术性数据 *)
let load_artistic_data ?(options = default_load_options) source =
  load_data_unified ~options ArtisticData source

(** {1 批量加载支持} *)

(** 批量加载多个数据源 *)
let load_multiple_sources ?(options = default_load_options) sources =
  List.map (fun (data_type, source) -> 
    try
      Some (data_type, load_data_unified ~options data_type source)
    with UnifiedLoadError error ->
      if options.fallback_enabled then
        (Printf.eprintf "加载失败，跳过: %s\n" (format_error error); None)
      else
        raise (UnifiedLoadError error)
  ) sources
  |> List.filter_map (fun x -> x)

(** {1 缓存管理接口} *)

(** 清空所有缓存 *)
let clear_cache () =
  Hashtbl.clear cache_table

(** 获取缓存统计信息 *)
let get_cache_stats () =
  let size = Hashtbl.length cache_table in
  let keys = Hashtbl.fold (fun k _ acc -> k :: acc) cache_table [] in
  (size, keys)

(** 预热缓存 - 预加载常用数据 *)
let warm_cache common_sources =
  List.iter (fun (data_type, source) ->
    try
      ignore (load_data_unified ~options:{default_load_options with use_cache = true} data_type source)
    with UnifiedLoadError _ -> ()  (* 忽略预热过程中的错误 *)
  ) common_sources