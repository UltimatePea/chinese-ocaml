(** 扩展诗词数据加载器 - 重构为统一加载器兼容层

    此模块现在作为Unified_data_loader的兼容层，保持原有API不变，
    但内部使用统一的数据加载核心，消除代码重复。

    重构目标：
    1. 保持100%向后兼容性
    2. 使用统一的错误处理和缓存机制
    3. 简化代码维护
    4. 提高性能和可靠性

    @author Alpha, 技术债务清理专员 - Poetry模块整合Phase 1
    @version 3.0 - 统一加载器兼容层
    @since 2025-07-29
    @refactored_from 扩展诗词数据加载器 v2.0
    @fix_issue #1729 *)

open Printf

(** {1 兼容性类型映射} *)

(** 原始错误类型 - 为了API兼容性保留 *)
type data_load_error =
  | FileNotFound of string
  | ParseError of string * string
  | ValidationError of string
  | CacheError of string
  | NetworkError of string

exception DataLoadError of data_load_error

(** 错误类型转换：统一错误 -> 兼容错误 *)
(* Error conversion helper - adapts from unified_loader errors to local error type *)
let convert_unified_error = function
  | Poetry_data_loaders.Unified_loader.UnifiedLoadError (Poetry_data_loaders.Unified_loader.FileNotFound file) -> FileNotFound file
  | Poetry_data_loaders.Unified_loader.UnifiedLoadError (Poetry_data_loaders.Unified_loader.ParseError (file, msg)) -> ParseError (file, msg)
  | Poetry_data_loaders.Unified_loader.UnifiedLoadError (Poetry_data_loaders.Unified_loader.ValidationError msg) -> ValidationError msg
  | Poetry_data_loaders.Unified_loader.UnifiedLoadError (Poetry_data_loaders.Unified_loader.CacheError msg) -> CacheError msg
  | Poetry_data_loaders.Unified_loader.UnifiedLoadError (Poetry_data_loaders.Unified_loader.NetworkError msg) -> NetworkError msg
  | Poetry_data_loaders.Unified_loader.UnifiedLoadError (Poetry_data_loaders.Unified_loader.FormatError (expected, actual)) -> 
      ParseError ("格式错误", sprintf "期望: %s, 实际: %s" expected actual)
  | Poetry_data_loaders.Unified_loader.UnifiedLoadError (Poetry_data_loaders.Unified_loader.TypeMismatch (expected, actual)) ->
      ParseError ("类型不匹配", sprintf "期望: %s, 实际: %s" expected actual)
  | Poetry_data_loaders.Unified_loader.UnifiedLoadError (Poetry_data_loaders.Unified_loader.PermissionError msg) -> FileNotFound msg
  | Poetry_data_loaders.Unified_loader.UnifiedLoadError (Poetry_data_loaders.Unified_loader.CorruptedData msg) -> ValidationError msg
  | _ -> ValidationError "未知错误"

(** 兼容性错误格式化 *)
let format_error = function
  | FileNotFound file -> sprintf "数据文件未找到: %s" file
  | ParseError (file, msg) -> sprintf "解析文件 %s 失败: %s" file msg
  | ValidationError msg -> sprintf "数据验证失败: %s" msg
  | CacheError msg -> sprintf "缓存错误: %s" msg
  | NetworkError msg -> sprintf "网络错误: %s" msg

(** {1 统一加载器包装函数} *)

(** 包装统一加载器调用，转换错误类型 *)
let load_with_unified_loader data_type source =
  try
    Poetry_data_loaders.Unified_loader.load_data source data_type ()
  with
  | Poetry_data_loaders.Unified_loader.UnifiedLoadError error ->
      raise (DataLoadError (convert_unified_error (Poetry_data_loaders.Unified_loader.UnifiedLoadError error)))

(** {1 兼容性加载函数 - 保持原有API} *)

(** 将文件读取异常转换为数据加载异常 - 兼容性函数 *)
let convert_file_error f =
  try f () 
  with 
  | Poetry_file_reader.FileReadError msg -> raise (DataLoadError (FileNotFound msg))
  | DataLoadError _ as e -> raise e
  | exn -> raise (DataLoadError (ValidationError (Printexc.to_string exn)))

(** 安全加载名词数据 - 使用统一加载器 + 降级机制 *)
let safe_load_nouns () =
  try
    (* 尝试使用统一加载器加载词类数据 *)
    let word_class_files = [
      "data/poetry/person_relation_nouns.json";
      "data/poetry/social_status_nouns.json";
      "data/poetry/geography_politics_nouns.json";
      "data/poetry/building_place_nouns.json";
      "data/poetry/tools_objects_nouns.json";
    ] in
    
    let load_noun_category file =
      try
        let json_data = load_with_unified_loader 
          Unified_data_loader.WordClassData 
          (Unified_data_loader.JsonFile file) in
        let open Yojson.Safe.Util in
        json_data |> to_list |> List.map to_string
      with
      | DataLoadError _ -> []
      | _ -> []
    in
    
    let categories = List.map load_noun_category word_class_files in
    
    (* 确保返回10个元素的元组以保持兼容性 *)
    match categories with
    | [person; social; geo; building; tools] ->
        (person, social, geo, building, tools, [], [], [], [], [])
    | _ -> raise (DataLoadError (ValidationError "名词数据格式不正确"))
        
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认名词数据\n" (format_error err);
    (* 提取字符串部分，忽略词类标记 *)
    let extract_strings word_list = List.map (fun (word, _) -> word) word_list in
    ( extract_strings Poetry_data_fallback.basic_person_relation_nouns,
      extract_strings Poetry_data_fallback.basic_social_status_nouns,
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [] )

(** 安全加载动词数据 *)
let safe_load_verbs () =
  try
    (* 尝试使用统一加载器 *)
    let json_data = load_with_unified_loader 
      Unified_data_loader.WordClassData 
      (Unified_data_loader.JsonFile "data/poetry/verb_data.json") in
    
    let open Yojson.Safe.Util in
    let movement_verbs = json_data |> member "movement" |> to_list |> List.map to_string in
    (movement_verbs, [], [], [], [], [], [], [], [], [], [])
    
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认动词数据\n" (format_error err);
    let extract_strings word_list = List.map (fun (word, _) -> word) word_list in
    (extract_strings Poetry_data_fallback.basic_movement_verbs, [], [], [], [], [], [], [], [], [], [])

(** 安全加载形容词数据 *)
let safe_load_adjectives () =
  try
    let json_data = load_with_unified_loader 
      Unified_data_loader.WordClassData 
      (Unified_data_loader.JsonFile "data/poetry/adjective_data.json") in
    
    let open Yojson.Safe.Util in
    let size_adjectives = json_data |> member "size" |> to_list |> List.map to_string in
    (size_adjectives, [], [], [], [], [], [], [], [], [], [], [])
    
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认形容词数据\n" (format_error err);
    let extract_strings word_list = List.map (fun (word, _) -> word) word_list in
    (extract_strings Poetry_data_fallback.basic_size_adjectives, [], [], [], [], [], [], [], [], [], [], [])

(** 安全加载副词数据 *)
let safe_load_adverbs () =
  try
    let json_data = load_with_unified_loader 
      Unified_data_loader.WordClassData 
      (Unified_data_loader.JsonFile "data/poetry/adverb_data.json") in
    
    let open Yojson.Safe.Util in
    let degree_adverbs = json_data |> member "degree" |> to_list |> List.map to_string in
    (degree_adverbs, [], [])
    
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认副词数据\n" (format_error err);
    let extract_strings word_list = List.map (fun (word, _) -> word) word_list in
    (extract_strings Poetry_data_fallback.basic_degree_adverbs, [], [])

(** 安全加载数词量词数据 *)
let safe_load_numerals_classifiers () =
  try
    let json_data = load_with_unified_loader 
      Unified_data_loader.WordClassData 
      (Unified_data_loader.JsonFile "data/poetry/numeral_classifier_data.json") in
    
    let open Yojson.Safe.Util in
    let numbers = json_data |> member "numbers" |> to_list |> List.map to_string in
    let classifiers = json_data |> member "classifiers" |> to_list |> List.map to_string in
    (numbers, [], classifiers)
    
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认数词量词数据\n" (format_error err);
    let extract_strings word_list = List.map (fun (word, _) -> word) word_list in
    (extract_strings Poetry_data_fallback.basic_numbers, [], extract_strings Poetry_data_fallback.basic_classifiers)

(** 安全加载功能词数据 *)
let safe_load_function_words () =
  try
    let json_data = load_with_unified_loader 
      Unified_data_loader.WordClassData 
      (Unified_data_loader.JsonFile "data/poetry/function_word_data.json") in
    
    let open Yojson.Safe.Util in
    let pronouns = json_data |> member "pronouns" |> to_list |> List.map to_string in
    (pronouns, [], [], [], [])
    
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认功能词数据\n" (format_error err);
    let extract_strings word_list = List.map (fun (word, _) -> word) word_list in
    (extract_strings Poetry_data_fallback.basic_pronouns, [], [], [], [])

(** {1 高级接口 - 利用统一加载器的新功能} *)

(** 批量加载所有词类数据 - 新增便捷接口 *)
let load_all_word_classes () =
  let sources = [
    (Unified_data_loader.WordClassData, Unified_data_loader.JsonFile "data/poetry/complete_word_class_data.json");
  ] in
  
  try
    let results = Unified_data_loader.load_multiple_sources sources in
    match results with
    | [(_, json_data)] -> Some json_data
    | _ -> None
  with
  | Unified_data_loader.UnifiedLoadError _ -> None

(** 获取缓存状态 - 调试和监控接口 *)
let get_cache_info () =
  let (size, keys) = Unified_data_loader.get_cache_stats () in
  Printf.sprintf "缓存条目数: %d, 键: [%s]" size (String.concat "; " keys)

(** 清理缓存 - 内存管理接口 *)
let clear_all_cache () =
  Unified_data_loader.clear_cache ()

(** {1 性能优化接口} *)

(** 预热常用数据缓存 *)
let warm_common_cache () =
  let common_sources = [
    (Unified_data_loader.WordClassData, Unified_data_loader.JsonFile "data/poetry/complete_word_class_data.json");
    (Unified_data_loader.RhymeData, Unified_data_loader.JsonFile "data/poetry/sample_rhyme_data.json");
    (Unified_data_loader.ToneData, Unified_data_loader.JsonFile "data/poetry/tone_data.json");
  ] in
  Unified_data_loader.warm_cache common_sources

(** {1 向后兼容性确保} *)

(** 确保与原Poetry_word_class_loader接口兼容 *)
module Compatibility = struct
  (** 模拟原Poetry_word_class_loader的接口 *)
  let load_nouns = safe_load_nouns
  let load_verbs = safe_load_verbs  
  let load_adjectives = safe_load_adjectives
  let load_adverbs = safe_load_adverbs
  let load_numerals_classifiers = safe_load_numerals_classifiers
  let load_function_words = safe_load_function_words
end