(* 数据加载器验证模块
   
   负责验证加载的数据是否符合预期格式和内容规范。
   提供各种数据类型的验证函数。 *)

open Data_loader_types
open Printf

(** 验证字符串列表 *)
let validate_string_list data =
  let is_valid_chinese_char s =
    String.length s > 0
    &&
    let code = Char.code s.[0] in
    code >= 0x4E00 && code <= 0x9FFF (* 简化的中文字符检查 *)
  in

  let invalid_items = List.filter (fun s -> not (is_valid_chinese_char s)) data in
  if List.length invalid_items > 0 then
    let first_invalid = List.hd invalid_items in
    Error (ValidationError ("string_list", sprintf "无效的中文字符: %s" first_invalid))
  else Success data

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
    Error
      (ValidationError ("word_class_pairs", sprintf "无效的词性 %s for word %s" invalid_class word))
  else Success data

(** 验证键值对数据 *)
let validate_key_value_pairs data =
  let is_valid_pair (key, value) =
    String.length key > 0 && String.length value > 0
  in
  
  let invalid_pairs = List.filter (fun pair -> not (is_valid_pair pair)) data in
  if List.length invalid_pairs > 0 then
    Error (ValidationError ("key_value_pairs", "发现空的键或值"))
  else Success data

(** 验证非空列表 *)
let validate_non_empty_list data =
  if List.length data = 0 then
    Error (ValidationError ("list", "列表不能为空"))
  else Success data