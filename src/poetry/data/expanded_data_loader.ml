(** 扩展诗词数据加载器 - 骆言项目 重构版本
    
    主要接口模块，协调各个专门模块提供统一的数据加载接口。
    负责错误处理和容错机制，确保数据加载的可靠性。
    
    @author 骆言技术债务清理团队
    @version 2.0 (重构版本)
    @since 2025-07-20 *)

open Printf

(** ========== 错误处理 ========== *)

type data_load_error =
  | FileNotFound of string
  | ParseError of string * string
  | ValidationError of string

exception DataLoadError of data_load_error

let format_error = function
  | FileNotFound file -> sprintf "数据文件未找到: %s" file
  | ParseError (file, msg) -> sprintf "解析文件 %s 失败: %s" file msg
  | ValidationError msg -> sprintf "数据验证失败: %s" msg

(** ========== 安全加载函数 - 提供容错机制 ========== *)

(** 将文件读取异常转换为数据加载异常 *)
let convert_file_error f =
  try f ()
  with Poetry_file_reader.FileReadError msg -> raise (DataLoadError (FileNotFound msg))

(** 安全加载名词数据 - 提供降级机制 *)
let safe_load_nouns () =
  try convert_file_error Poetry_word_class_loader.load_nouns
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认名词数据\n" (format_error err);
    ( Poetry_data_fallback.basic_person_relation_nouns,
      Poetry_data_fallback.basic_social_status_nouns,
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [] )

let safe_load_verbs () =
  try convert_file_error Poetry_word_class_loader.load_verbs
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认动词数据\n" (format_error err);
    (Poetry_data_fallback.basic_movement_verbs, [], [], [], [], [], [], [], [], [], [])

let safe_load_adjectives () =
  try convert_file_error Poetry_word_class_loader.load_adjectives
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认形容词数据\n" (format_error err);
    (Poetry_data_fallback.basic_size_adjectives, [], [], [], [], [], [], [], [], [], [], [])

let safe_load_adverbs () =
  try convert_file_error Poetry_word_class_loader.load_adverbs
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认副词数据\n" (format_error err);
    (Poetry_data_fallback.basic_degree_adverbs, [], [])

let safe_load_numerals_classifiers () =
  try convert_file_error Poetry_word_class_loader.load_numerals_classifiers
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认数词量词数据\n" (format_error err);
    (Poetry_data_fallback.basic_numbers, [], Poetry_data_fallback.basic_classifiers)

let safe_load_function_words () =
  try convert_file_error Poetry_word_class_loader.load_function_words
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认功能词数据\n" (format_error err);
    (Poetry_data_fallback.basic_pronouns, [], [], [], [])