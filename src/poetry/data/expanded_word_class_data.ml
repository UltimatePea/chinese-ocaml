(* 禁用未使用值的警告，因为这些值主要用于数据库查询 *)
[@@@warning "-32"]

(** 扩展词性数据模块 - 优化访问器模式版
    
    重构目标：
    - 消除159个重复的let绑定
    - 使用统一的数据访问模式
    - 保持API向后兼容
    - 减少代码重复90%以上
    
    @author 骆言诗词编程团队 技术债务清理 Issue #628
    @version 3.0 - 访问器模式优化版
    @since 2025-07-20
    @updated 2025-07-20 Issue #628: 重复访问器模式优化 *)

open Word_class_types
open Expanded_data_loader
(*open Poetry_core.Types - removed dependency*)

(** {1 统一数据访问器} *)

(** 数据类型索引 *)
type data_category = Nouns | Verbs | Adjectives | Adverbs | NumeralsClassifiers | FunctionWords

(* type data_subcategory = int *)

(** 缓存加载的数据 *)
let cached_data = ref None

(** 统一数据加载函数 *)
let get_all_data () =
  match !cached_data with
  | Some data -> data
  | None ->
      let data =
        ( safe_load_nouns (),
          safe_load_verbs (),
          safe_load_adjectives (),
          safe_load_adverbs (),
          safe_load_numerals_classifiers (),
          safe_load_function_words () )
      in
      cached_data := Some data;
      data

(** 通用辅助函数 - 从元组中获取指定索引的数据 *)
let get_tuple_element tuple_data index =
  let extract_by_index data i =
    match (data, i) with
    | (d0, _, _, _, _, _, _, _, _, _), 0 -> Some d0
    | (_, d1, _, _, _, _, _, _, _, _), 1 -> Some d1
    | (_, _, d2, _, _, _, _, _, _, _), 2 -> Some d2
    | (_, _, _, d3, _, _, _, _, _, _), 3 -> Some d3
    | (_, _, _, _, d4, _, _, _, _, _), 4 -> Some d4
    | (_, _, _, _, _, d5, _, _, _, _), 5 -> Some d5
    | (_, _, _, _, _, _, d6, _, _, _), 6 -> Some d6
    | (_, _, _, _, _, _, _, d7, _, _), 7 -> Some d7
    | (_, _, _, _, _, _, _, _, d8, _), 8 -> Some d8
    | (_, _, _, _, _, _, _, _, _, d9), 9 -> Some d9
    | _ -> None
  in
  extract_by_index tuple_data index

(** 为11元组提供特殊处理 *)
let get_11tuple_element tuple_data index =
  let extract_by_index data i =
    match (data, i) with
    | (d0, _, _, _, _, _, _, _, _, _, _), 0 -> Some d0
    | (_, d1, _, _, _, _, _, _, _, _, _), 1 -> Some d1
    | (_, _, d2, _, _, _, _, _, _, _, _), 2 -> Some d2
    | (_, _, _, d3, _, _, _, _, _, _, _), 3 -> Some d3
    | (_, _, _, _, d4, _, _, _, _, _, _), 4 -> Some d4
    | (_, _, _, _, _, d5, _, _, _, _, _), 5 -> Some d5
    | (_, _, _, _, _, _, d6, _, _, _, _), 6 -> Some d6
    | (_, _, _, _, _, _, _, d7, _, _, _), 7 -> Some d7
    | (_, _, _, _, _, _, _, _, d8, _, _), 8 -> Some d8
    | (_, _, _, _, _, _, _, _, _, d9, _), 9 -> Some d9
    | (_, _, _, _, _, _, _, _, _, _, d10), 10 -> Some d10
    | _ -> None
  in
  extract_by_index tuple_data index

(** 为12元组提供特殊处理 *)
let get_12tuple_element tuple_data index =
  let extract_by_index data i =
    match (data, i) with
    | (d0, _, _, _, _, _, _, _, _, _, _, _), 0 -> Some d0
    | (_, d1, _, _, _, _, _, _, _, _, _, _), 1 -> Some d1
    | (_, _, d2, _, _, _, _, _, _, _, _, _), 2 -> Some d2
    | (_, _, _, d3, _, _, _, _, _, _, _, _), 3 -> Some d3
    | (_, _, _, _, d4, _, _, _, _, _, _, _), 4 -> Some d4
    | (_, _, _, _, _, d5, _, _, _, _, _, _), 5 -> Some d5
    | (_, _, _, _, _, _, d6, _, _, _, _, _), 6 -> Some d6
    | (_, _, _, _, _, _, _, d7, _, _, _, _), 7 -> Some d7
    | (_, _, _, _, _, _, _, _, d8, _, _, _), 8 -> Some d8
    | (_, _, _, _, _, _, _, _, _, d9, _, _), 9 -> Some d9
    | (_, _, _, _, _, _, _, _, _, _, d10, _), 10 -> Some d10
    | (_, _, _, _, _, _, _, _, _, _, _, d11), 11 -> Some d11
    | _ -> None
  in
  extract_by_index tuple_data index

(** 为3元组提供特殊处理 *)
let get_3tuple_element tuple_data index =
  match (tuple_data, index) with
  | (d0, _, _), 0 -> Some d0
  | (_, d1, _), 1 -> Some d1
  | (_, _, d2), 2 -> Some d2
  | _ -> None

(** 为5元组提供特殊处理 *)
let get_5tuple_element tuple_data index =
  match (tuple_data, index) with
  | (d0, _, _, _, _), 0 -> Some d0
  | (_, d1, _, _, _), 1 -> Some d1
  | (_, _, d2, _, _), 2 -> Some d2
  | (_, _, _, d3, _), 3 -> Some d3
  | (_, _, _, _, d4), 4 -> Some d4
  | _ -> None

(** 通用数据访问函数 - 转换字符串列表为词性标记列表 *)
let get_data_by_category category subcategory =
  let nouns, verbs, adjectives, adverbs, nums_cls, func_words = get_all_data () in
  let add_word_class word_class string_list =
    List.map (fun word -> (word, word_class)) string_list
  in
  let safe_get_data data_opt word_class =
    match data_opt with
    | Some data -> add_word_class word_class data
    | None -> []
  in
  match category with
  | Nouns -> 
      safe_get_data (get_tuple_element nouns subcategory) Noun
  | Verbs -> 
      safe_get_data (get_11tuple_element verbs subcategory) Verb
  | Adjectives -> 
      safe_get_data (get_12tuple_element adjectives subcategory) Adjective
  | Adverbs -> 
      safe_get_data (get_3tuple_element adverbs subcategory) Adverb
  | NumeralsClassifiers -> (
      match subcategory with
      | 0 | 1 -> safe_get_data (get_3tuple_element nums_cls subcategory) Numeral
      | 2 -> safe_get_data (get_3tuple_element nums_cls subcategory) Classifier
      | _ -> [])
  | FunctionWords -> 
      safe_get_data (get_5tuple_element func_words subcategory) Pronoun

(** {1 向后兼容的API访问器} *)

(** 类型转换工具函数 *)
let extract_strings word_class_list = List.map (fun (word, _) -> word) word_class_list

(** 名词类别 *)
let person_relation_nouns = extract_strings (get_data_by_category Nouns 0)

let social_status_nouns = extract_strings (get_data_by_category Nouns 1)
let building_place_nouns = extract_strings (get_data_by_category Nouns 2)
let geography_politics_nouns = extract_strings (get_data_by_category Nouns 3)
let tools_objects_nouns = extract_strings (get_data_by_category Nouns 4)
let emotional_psychological_nouns = extract_strings (get_data_by_category Nouns 5)
let moral_virtue_nouns = extract_strings (get_data_by_category Nouns 6)
let knowledge_learning_nouns = extract_strings (get_data_by_category Nouns 7)
let time_space_nouns = extract_strings (get_data_by_category Nouns 8)
let affairs_activity_nouns = extract_strings (get_data_by_category Nouns 9)

(** 动词类别 *)
let movement_position_verbs = extract_strings (get_data_by_category Verbs 0)

let sensory_action_verbs = extract_strings (get_data_by_category Verbs 1)
let cognitive_activity_verbs = extract_strings (get_data_by_category Verbs 2)
let social_communication_verbs = extract_strings (get_data_by_category Verbs 3)
let emotional_expression_verbs = extract_strings (get_data_by_category Verbs 4)
let social_behavior_verbs = extract_strings (get_data_by_category Verbs 5)
let agricultural_verbs = extract_strings (get_data_by_category Verbs 6)
let manufacturing_verbs = extract_strings (get_data_by_category Verbs 7)
let transportation_verbs = extract_strings (get_data_by_category Verbs 8)
let commercial_verbs = extract_strings (get_data_by_category Verbs 9)
let cleaning_verbs = extract_strings (get_data_by_category Verbs 10)

(** 形容词类别 *)
let size_adjectives = extract_strings (get_data_by_category Adjectives 0)

let shape_adjectives = extract_strings (get_data_by_category Adjectives 1)
let color_adjectives = extract_strings (get_data_by_category Adjectives 2)
let texture_adjectives = extract_strings (get_data_by_category Adjectives 3)
let value_judgment_adjectives = extract_strings (get_data_by_category Adjectives 4)
let emotional_state_adjectives = extract_strings (get_data_by_category Adjectives 5)
let motion_state_adjectives = extract_strings (get_data_by_category Adjectives 6)
let temperature_texture_adjectives = extract_strings (get_data_by_category Adjectives 7)
let purity_cleanliness_adjectives = extract_strings (get_data_by_category Adjectives 8)
let moral_character_adjectives = extract_strings (get_data_by_category Adjectives 9)
let wisdom_brightness_adjectives = extract_strings (get_data_by_category Adjectives 10)
let precision_degree_adjectives = extract_strings (get_data_by_category Adjectives 11)

(** 副词类别 *)
let degree_adverbs = extract_strings (get_data_by_category Adverbs 0)

let temporal_adverbs = extract_strings (get_data_by_category Adverbs 1)
let manner_adverbs = extract_strings (get_data_by_category Adverbs 2)

(** 数词量词类别 *)
let cardinal_numbers = extract_strings (get_data_by_category NumeralsClassifiers 0)

let ordinal_numbers = extract_strings (get_data_by_category NumeralsClassifiers 1)
let measuring_classifiers = extract_strings (get_data_by_category NumeralsClassifiers 2)

(** 功能词类别 *)
let pronoun_words = extract_strings (get_data_by_category FunctionWords 0)

let preposition_words = extract_strings (get_data_by_category FunctionWords 1)
let conjunction_words = extract_strings (get_data_by_category FunctionWords 2)
let particle_words = extract_strings (get_data_by_category FunctionWords 3)
let interjection_words = extract_strings (get_data_by_category FunctionWords 4)

(** {1 兼容性支持} *)

module ExternalizedWordClass = struct
  include Consolidated_data_loader.ExternalizedCompat
end
(** 从整合数据加载器引入自然景物名词（已迁移至consolidated_data_loader） *)

let nature_nouns =
  try
    (* 使用统一数据加载器获取自然景物名词 *)
    let _rhyme_data =
      Poetry_data_loaders.Unified_loader.load_data
        (Poetry_data_loaders.Unified_loader.JsonFile "data/poetry/nature_nouns.json")
        Poetry_data_loaders.Unified_loader.WordClassData ()
    in

    (* FIXME #1999: rhyme_groups和characters字段不存在，返回空列表 *)
    []
  with _ -> []

(** {1 数据合并} *)

(** {1 词性数据分组定义} *)

(** 带词性标记的数据 - 用于数据库查询 *)
let noun_category_data_with_class =
  [
    get_data_by_category Nouns 0;
    get_data_by_category Nouns 1;
    get_data_by_category Nouns 2;
    get_data_by_category Nouns 3;
    get_data_by_category Nouns 4;
    get_data_by_category Nouns 5;
    get_data_by_category Nouns 6;
    get_data_by_category Nouns 7;
    get_data_by_category Nouns 8;
    get_data_by_category Nouns 9;
  ]

(** 带词性标记的动词数据 *)
let verb_category_data_with_class =
  [
    get_data_by_category Verbs 0;
    get_data_by_category Verbs 1;
    get_data_by_category Verbs 2;
    get_data_by_category Verbs 3;
    get_data_by_category Verbs 4;
    get_data_by_category Verbs 5;
    get_data_by_category Verbs 6;
    get_data_by_category Verbs 7;
    get_data_by_category Verbs 8;
    get_data_by_category Verbs 9;
    get_data_by_category Verbs 10;
  ]

(** 全部扩展词性数据的合并列表 - 带词性标记版本 *)
let all_expanded_word_class_data =
  lazy
    (List.concat
       (List.concat
          [
            noun_category_data_with_class;
            verb_category_data_with_class;
            (* 为其他类别创建带词性的版本 *)
            [
              get_data_by_category Adjectives 0;
              get_data_by_category Adjectives 1;
              get_data_by_category Adjectives 2;
              get_data_by_category Adjectives 3;
              get_data_by_category Adjectives 4;
              get_data_by_category Adjectives 5;
              get_data_by_category Adjectives 6;
              get_data_by_category Adjectives 7;
              get_data_by_category Adjectives 8;
              get_data_by_category Adjectives 9;
              get_data_by_category Adjectives 10;
              get_data_by_category Adjectives 11;
            ];
            [
              get_data_by_category Adverbs 0;
              get_data_by_category Adverbs 1;
              get_data_by_category Adverbs 2;
            ];
            [
              get_data_by_category NumeralsClassifiers 0;
              get_data_by_category NumeralsClassifiers 1;
              get_data_by_category NumeralsClassifiers 2;
            ];
            [
              get_data_by_category FunctionWords 0;
              get_data_by_category FunctionWords 1;
              get_data_by_category FunctionWords 2;
              get_data_by_category FunctionWords 3;
              get_data_by_category FunctionWords 4;
            ];
          ]))

(** {1 统计信息} *)

let _get_data_statistics () =
  let total_words = List.length (Lazy.force all_expanded_word_class_data) in
  let count_category category =
    let rec count_subcategories acc i =
      let data = get_data_by_category category i in
      if data = [] && i > 0 then acc else count_subcategories (acc + List.length data) (i + 1)
    in
    count_subcategories 0 0
  in

  let nouns_count = List.length nature_nouns + count_category Nouns in
  let verbs_count = count_category Verbs in
  let adjectives_count = count_category Adjectives in
  let adverbs_count = count_category Adverbs in
  let numerals_count = count_category NumeralsClassifiers in
  let function_words_count = count_category FunctionWords in

  Printf.printf "扩展词性数据统计 (Phase 13 访问器优化版本):\n";
  Printf.printf "  总词汇数: %d\n" total_words;
  Printf.printf "  名词: %d\n" nouns_count;
  Printf.printf "  动词: %d\n" verbs_count;
  Printf.printf "  形容词: %d\n" adjectives_count;
  Printf.printf "  副词: %d\n" adverbs_count;
  Printf.printf "  数词量词: %d\n" numerals_count;
  Printf.printf "  功能词: %d\n" function_words_count

(** {1 向后兼容API} *)

(** 获取扩展词性数据库 *)
let get_expanded_word_class_database () = Lazy.force all_expanded_word_class_data

(** 判断字符是否在扩展词性数据库中 *)
let is_in_expanded_word_class_database char =
  List.exists (fun (word, _) -> word = char) (get_expanded_word_class_database ())

(** 获取扩展字符列表 *)
let get_expanded_char_list () = List.map fst (get_expanded_word_class_database ())

(** 查找字符的词性 *)
let find_word_class char =
  try Some (List.assoc char (get_expanded_word_class_database ())) with Not_found -> None

(** 按词性获取字符列表 *)
let get_chars_by_class word_class =
  List.fold_left
    (fun acc (word, wc) -> if wc = word_class then word :: acc else acc)
    []
    (get_expanded_word_class_database ())
  |> List.rev

(** 扩展词性数据库字符总数 *)
let expanded_word_class_char_count = List.length (get_expanded_word_class_database ())
