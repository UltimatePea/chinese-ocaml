(* 数据加载器验证模块
   
   负责验证加载的数据是否符合预期格式和内容规范。
   提供各种数据类型的验证函数。 *)

open Data_loader_types
open Printf
open Utils

(** 转换数据加载器结果到通用验证结果 *)
let to_data_loader_result = function
  | Validation_utils.Valid v -> Success v
  | Validation_utils.Invalid msg -> Error (ValidationError ("validation", msg))

(** 验证字符串列表 *)
let validate_string_list data =
  let chinese_string_validator s = Validation_utils.validate_chinese_string s in
  match Validation_utils.validate_all_elements chinese_string_validator data with
  | Validation_utils.Valid result -> Success result
  | Validation_utils.Invalid msg -> Error (ValidationError ("string_list", msg))

(** 验证词性数据对 *)
let validate_word_class_pairs data =
  let valid_classes =
    [
      "Noun";
      "Verb";
      "Adjective";
      "Adverb";
      "Numeral";
      "Classifier";
      "Pronoun";
      "Preposition";
      "Conjunction";
      "Particle";
      "Interjection";
      "Unknown";
    ]
  in

  let is_valid_class class_name = List.mem class_name valid_classes in

  let invalid_pairs = List.filter (fun (_, class_name) -> not (is_valid_class class_name)) data in
  if List.length invalid_pairs > 0 then
    let word, invalid_class = List.hd invalid_pairs in
    Error (ValidationError ("word_class_pairs", sprintf "无效的词性 %s for word %s" invalid_class word))
  else Success data

(** 验证键值对数据 *)
let validate_key_value_pairs data =
  match Validation_utils.validate_key_value_pairs data with
  | Validation_utils.Valid result -> Success result
  | Validation_utils.Invalid msg -> Error (ValidationError ("key_value_pairs", msg))

(** 验证非空列表 *)
let validate_non_empty_list data =
  match Validation_utils.validate_non_empty_list data with
  | Validation_utils.Valid result -> Success result
  | Validation_utils.Invalid msg -> Error (ValidationError ("list", msg))
