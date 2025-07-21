(** 诗词词类数据加载器 - 核心词汇数据加载逻辑

    负责从JSON数据文件中加载各类词汇数据，包括名词、动词、形容词、 副词、数词分类词和功能词等。提供标准化的词类数据访问接口。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 *)

open Word_class_types

(** 加载名词数据 *)
let load_nouns () =
  let file_path = Poetry_file_reader.get_data_path "nouns.json" in
  let content = Poetry_file_reader.read_file_content file_path in

  let load_noun_category category_name =
    let category_content = Poetry_json_parser.extract_field content category_name in
    let words_content = Poetry_json_parser.extract_field category_content "words" in
    let words = Poetry_json_parser.parse_string_array words_content in
    List.map (fun word -> (word, Noun)) words
  in

  let person_relation = load_noun_category "person_relation" in
  let social_status = load_noun_category "social_status" in
  let building_place = load_noun_category "building_place" in
  let geography_politics = load_noun_category "geography_politics" in
  let tools_objects = load_noun_category "tools_objects" in
  let emotional_psychological = load_noun_category "emotional_psychological" in
  let moral_virtue = load_noun_category "moral_virtue" in
  let knowledge_learning = load_noun_category "knowledge_learning" in
  let time_space = load_noun_category "time_space" in
  let affairs_activity = load_noun_category "affairs_activity" in

  ( person_relation,
    social_status,
    building_place,
    geography_politics,
    tools_objects,
    emotional_psychological,
    moral_virtue,
    knowledge_learning,
    time_space,
    affairs_activity )

(** 加载动词数据 *)
let load_verbs () =
  let file_path = Poetry_file_reader.get_data_path "verbs.json" in
  let content = Poetry_file_reader.read_file_content file_path in

  let load_verb_category category_name =
    let category_content = Poetry_json_parser.extract_field content category_name in
    let words_content = Poetry_json_parser.extract_field category_content "words" in
    let words = Poetry_json_parser.parse_string_array words_content in
    List.map (fun word -> (word, Verb)) words
  in

  let movement_position = load_verb_category "movement_position" in
  let sensory_action = load_verb_category "sensory_action" in
  let cognitive_activity = load_verb_category "cognitive_activity" in
  let social_communication = load_verb_category "social_communication" in
  let emotional_expression = load_verb_category "emotional_expression" in
  let social_behavior = load_verb_category "social_behavior" in
  let agricultural = load_verb_category "agricultural" in
  let manufacturing = load_verb_category "manufacturing" in
  let transportation = load_verb_category "transportation" in
  let commercial = load_verb_category "commercial" in
  let cleaning = load_verb_category "cleaning" in

  ( movement_position,
    sensory_action,
    cognitive_activity,
    social_communication,
    emotional_expression,
    social_behavior,
    agricultural,
    manufacturing,
    transportation,
    commercial,
    cleaning )

(** 加载形容词数据 *)
let load_adjectives () =
  let file_path = Poetry_file_reader.get_data_path "adjectives.json" in
  let content = Poetry_file_reader.read_file_content file_path in

  let load_adjective_category category_name =
    let category_content = Poetry_json_parser.extract_field content category_name in
    let words_content = Poetry_json_parser.extract_field category_content "words" in
    let words = Poetry_json_parser.parse_string_array words_content in
    List.map (fun word -> (word, Adjective)) words
  in

  let size = load_adjective_category "size" in
  let shape = load_adjective_category "shape" in
  let color = load_adjective_category "color" in
  let texture = load_adjective_category "texture" in
  let value_judgment = load_adjective_category "value_judgment" in
  let emotional_state = load_adjective_category "emotional_state" in
  let motion_state = load_adjective_category "motion_state" in
  let temperature_texture = load_adjective_category "temperature_texture" in
  let purity_cleanliness = load_adjective_category "purity_cleanliness" in
  let moral_character = load_adjective_category "moral_character" in
  let wisdom_brightness = load_adjective_category "wisdom_brightness" in
  let precision_degree = load_adjective_category "precision_degree" in

  ( size,
    shape,
    color,
    texture,
    value_judgment,
    emotional_state,
    motion_state,
    temperature_texture,
    purity_cleanliness,
    moral_character,
    wisdom_brightness,
    precision_degree )

(** 加载副词数据 *)
let load_adverbs () =
  let file_path = Poetry_file_reader.get_data_path "adverbs.json" in
  let content = Poetry_file_reader.read_file_content file_path in

  let load_adverb_category category_name =
    let category_content = Poetry_json_parser.extract_field content category_name in
    let words_content = Poetry_json_parser.extract_field category_content "words" in
    let words = Poetry_json_parser.parse_string_array words_content in
    List.map (fun word -> (word, Adverb)) words
  in

  let degree = load_adverb_category "degree" in
  let temporal = load_adverb_category "temporal" in
  let manner = load_adverb_category "manner" in

  (degree, temporal, manner)

(** 加载数词和量词数据 *)
let load_numerals_classifiers () =
  let file_path = Poetry_file_reader.get_data_path "numerals_classifiers.json" in
  let content = Poetry_file_reader.read_file_content file_path in

  let load_numeral_category category_name word_class =
    let category_content = Poetry_json_parser.extract_field content category_name in
    let words_content = Poetry_json_parser.extract_field category_content "words" in
    let words = Poetry_json_parser.parse_string_array words_content in
    List.map (fun word -> (word, word_class)) words
  in

  let cardinal_numbers = load_numeral_category "cardinal_numbers" Numeral in
  let ordinal_numbers = load_numeral_category "ordinal_numbers" Numeral in
  let classifiers = load_numeral_category "classifiers" Classifier in

  (cardinal_numbers, ordinal_numbers, classifiers)

(** 加载功能词数据 *)
let load_function_words () =
  let file_path = Poetry_file_reader.get_data_path "function_words.json" in
  let content = Poetry_file_reader.read_file_content file_path in

  let load_function_category category_name word_class =
    let category_content = Poetry_json_parser.extract_field content category_name in
    let words_content = Poetry_json_parser.extract_field category_content "words" in
    let words = Poetry_json_parser.parse_string_array words_content in
    List.map (fun word -> (word, word_class)) words
  in

  let pronouns = load_function_category "pronouns" Pronoun in
  let prepositions = load_function_category "prepositions" Preposition in
  let conjunctions = load_function_category "conjunctions" Conjunction in
  let particles = load_function_category "particles" Particle in
  let interjections = load_function_category "interjections" Interjection in

  (pronouns, prepositions, conjunctions, particles, interjections)
