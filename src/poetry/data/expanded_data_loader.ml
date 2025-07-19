(** 扩展诗词数据加载器 - 骆言项目 Phase 13 技术债务清理

    负责从外部JSON文件加载扩展诗词数据，实现数据与代码分离。 替代原有的硬编码数据，提高维护性和可扩展性。

    @author 骆言技术债务清理团队 Phase 13
    @version 1.0
    @since 2025-07-19 *)

open Printf
open Word_class_types

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

(** ========== JSON 简单解析器 ========== *)

module SimpleJsonParser = struct
  (** 去除空白字符 *)
  let trim_whitespace s =
    let len = String.length s in
    let rec start i =
      if i >= len then len
      else match s.[i] with ' ' | '\t' | '\n' | '\r' -> start (i + 1) | _ -> i
    in
    let rec finish i =
      if i < 0 then -1 else match s.[i] with ' ' | '\t' | '\n' | '\r' -> finish (i - 1) | _ -> i
    in
    let s_start = start 0 in
    let s_end = finish (len - 1) in
    if s_start > s_end then "" else String.sub s s_start (s_end - s_start + 1)

  (** 解析字符串数组 *)
  let parse_string_array content =
    try
      let trimmed = trim_whitespace content in
      if String.length trimmed < 2 then []
      else if trimmed.[0] <> '[' || trimmed.[String.length trimmed - 1] <> ']' then []
      else
        let inner = String.sub trimmed 1 (String.length trimmed - 2) in
        let items = String.split_on_char ',' inner in
        List.map
          (fun item ->
            let cleaned = trim_whitespace item in
            if
              String.length cleaned >= 2
              && cleaned.[0] = '"'
              && cleaned.[String.length cleaned - 1] = '"'
            then String.sub cleaned 1 (String.length cleaned - 2)
            else cleaned)
          items
        |> List.filter (fun s -> String.length s > 0)
    with _ -> []

  (** 简单提取字段值 - 用于提取JSON对象中的字段 *)
  let extract_field content field_name =
    try
      let field_pattern = "\"" ^ field_name ^ "\"" in
      let field_start =
        let rec search pos =
          if pos + String.length field_pattern > String.length content then raise Not_found
          else if String.sub content pos (String.length field_pattern) = field_pattern then pos
          else search (pos + 1)
        in
        search 0
      in
      let colon_pos = String.index_from content field_start ':' in
      let value_start = colon_pos + 1 in

      (* 寻找值的开始 *)
      let rec find_value_start pos =
        if pos >= String.length content then pos
        else
          match content.[pos] with
          | ' ' | '\t' | '\n' | '\r' -> find_value_start (pos + 1)
          | _ -> pos
      in
      let actual_start = find_value_start value_start in

      (* 判断值的类型并提取 *)
      if actual_start < String.length content then
        match content.[actual_start] with
        | '"' ->
            (* 字符串值 *)
            let end_quote = String.index_from content (actual_start + 1) '"' in
            String.sub content (actual_start + 1) (end_quote - actual_start - 1)
        | '[' ->
            (* 数组值 *)
            let rec find_array_end pos bracket_count =
              if pos >= String.length content then pos
              else
                match content.[pos] with
                | '[' -> find_array_end (pos + 1) (bracket_count + 1)
                | ']' when bracket_count = 1 -> pos
                | ']' -> find_array_end (pos + 1) (bracket_count - 1)
                | _ -> find_array_end (pos + 1) bracket_count
            in
            let array_end = find_array_end actual_start 0 in
            String.sub content actual_start (array_end - actual_start + 1)
        | _ ->
            (* 其他值类型 *)
            let rec find_value_end pos =
              if pos >= String.length content then pos
              else
                match content.[pos] with
                | ',' | '}' | ']' | '\n' -> pos
                | _ -> find_value_end (pos + 1)
            in
            let value_end = find_value_end actual_start in
            trim_whitespace (String.sub content actual_start (value_end - actual_start))
      else ""
    with Not_found | Invalid_argument _ -> ""
end

(** ========== 文件读取工具 ========== *)

module FileReader = struct
  (** 读取文件内容 *)
  let read_file_content filename =
    try
      let ic = open_in filename in
      let content = really_input_string ic (in_channel_length ic) in
      close_in ic;
      content
    with
    | Sys_error _ -> raise (DataLoadError (FileNotFound filename))
    | e -> raise (DataLoadError (ParseError (filename, Printexc.to_string e)))

  (** 获取数据文件路径 *)
  let get_data_path relative_path =
    let project_root = Sys.getcwd () in
    Filename.concat (Filename.concat project_root "data/poetry/expanded") relative_path
end

(** ========== 词性数据加载器 ========== *)

module WordClassLoader = struct
  (** 加载名词数据 *)
  let load_nouns () =
    let file_path = FileReader.get_data_path "nouns.json" in
    let content = FileReader.read_file_content file_path in

    let load_noun_category category_name =
      let category_content = SimpleJsonParser.extract_field content category_name in
      let words_content = SimpleJsonParser.extract_field category_content "words" in
      let words = SimpleJsonParser.parse_string_array words_content in
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
    let file_path = FileReader.get_data_path "verbs.json" in
    let content = FileReader.read_file_content file_path in

    let load_verb_category category_name =
      let category_content = SimpleJsonParser.extract_field content category_name in
      let words_content = SimpleJsonParser.extract_field category_content "words" in
      let words = SimpleJsonParser.parse_string_array words_content in
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
    let file_path = FileReader.get_data_path "adjectives.json" in
    let content = FileReader.read_file_content file_path in

    let load_adjective_category category_name =
      let category_content = SimpleJsonParser.extract_field content category_name in
      let words_content = SimpleJsonParser.extract_field category_content "words" in
      let words = SimpleJsonParser.parse_string_array words_content in
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
    let file_path = FileReader.get_data_path "adverbs.json" in
    let content = FileReader.read_file_content file_path in

    let load_adverb_category category_name =
      let category_content = SimpleJsonParser.extract_field content category_name in
      let words_content = SimpleJsonParser.extract_field category_content "words" in
      let words = SimpleJsonParser.parse_string_array words_content in
      List.map (fun word -> (word, Adverb)) words
    in

    let degree = load_adverb_category "degree" in
    let temporal = load_adverb_category "temporal" in
    let manner = load_adverb_category "manner" in

    (degree, temporal, manner)

  (** 加载数词和量词数据 *)
  let load_numerals_classifiers () =
    let file_path = FileReader.get_data_path "numerals_classifiers.json" in
    let content = FileReader.read_file_content file_path in

    let load_numeral_category category_name word_class =
      let category_content = SimpleJsonParser.extract_field content category_name in
      let words_content = SimpleJsonParser.extract_field category_content "words" in
      let words = SimpleJsonParser.parse_string_array words_content in
      List.map (fun word -> (word, word_class)) words
    in

    let cardinal_numbers = load_numeral_category "cardinal_numbers" Numeral in
    let ordinal_numbers = load_numeral_category "ordinal_numbers" Numeral in
    let classifiers = load_numeral_category "classifiers" Classifier in

    (cardinal_numbers, ordinal_numbers, classifiers)

  (** 加载功能词数据 *)
  let load_function_words () =
    let file_path = FileReader.get_data_path "function_words.json" in
    let content = FileReader.read_file_content file_path in

    let load_function_category category_name word_class =
      let category_content = SimpleJsonParser.extract_field content category_name in
      let words_content = SimpleJsonParser.extract_field category_content "words" in
      let words = SimpleJsonParser.parse_string_array words_content in
      List.map (fun word -> (word, word_class)) words
    in

    let pronouns = load_function_category "pronouns" Pronoun in
    let prepositions = load_function_category "prepositions" Preposition in
    let conjunctions = load_function_category "conjunctions" Conjunction in
    let particles = load_function_category "particles" Particle in
    let interjections = load_function_category "interjections" Interjection in

    (pronouns, prepositions, conjunctions, particles, interjections)
end

(** ========== 降级机制 - 如果JSON文件加载失败，使用默认数据 ========== *)

module FallbackData = struct
  (** 基本名词备份数据 *)
  let basic_person_relation_nouns =
    [
      ("人", Noun);
      ("民", Noun);
      ("众", Noun);
      ("群", Noun);
      ("族", Noun);
      ("家", Noun);
      ("户", Noun);
      ("口", Noun);
      ("丁", Noun);
      ("身", Noun);
    ]

  let basic_social_status_nouns =
    [ ("王", Noun); ("君", Noun); ("臣", Noun); ("民", Noun); ("官", Noun) ]

  let basic_movement_verbs = [ ("来", Verb); ("去", Verb); ("到", Verb); ("达", Verb); ("至", Verb) ]

  let basic_size_adjectives =
    [ ("大", Adjective); ("小", Adjective); ("长", Adjective); ("短", Adjective); ("高", Adjective) ]

  let basic_degree_adverbs =
    [ ("很", Adverb); ("非", Adverb); ("极", Adverb); ("最", Adverb); ("更", Adverb) ]

  let basic_numbers =
    [ ("一", Numeral); ("二", Numeral); ("三", Numeral); ("四", Numeral); ("五", Numeral) ]

  let basic_classifiers =
    [
      ("个", Classifier); ("只", Classifier); ("条", Classifier); ("根", Classifier); ("支", Classifier);
    ]

  let basic_pronouns =
    [ ("我", Pronoun); ("你", Pronoun); ("他", Pronoun); ("她", Pronoun); ("它", Pronoun) ]
end

(** ========== 导出接口 ========== *)

(** 安全加载函数 - 提供降级机制 *)
let safe_load_nouns () =
  try WordClassLoader.load_nouns ()
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认名词数据\n" (format_error err);
    ( FallbackData.basic_person_relation_nouns,
      FallbackData.basic_social_status_nouns,
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [] )

let safe_load_verbs () =
  try WordClassLoader.load_verbs ()
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认动词数据\n" (format_error err);
    (FallbackData.basic_movement_verbs, [], [], [], [], [], [], [], [], [], [])

let safe_load_adjectives () =
  try WordClassLoader.load_adjectives ()
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认形容词数据\n" (format_error err);
    (FallbackData.basic_size_adjectives, [], [], [], [], [], [], [], [], [], [], [])

let safe_load_adverbs () =
  try WordClassLoader.load_adverbs ()
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认副词数据\n" (format_error err);
    (FallbackData.basic_degree_adverbs, [], [])

let safe_load_numerals_classifiers () =
  try WordClassLoader.load_numerals_classifiers ()
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认数词量词数据\n" (format_error err);
    (FallbackData.basic_numbers, [], FallbackData.basic_classifiers)

let safe_load_function_words () =
  try WordClassLoader.load_function_words ()
  with DataLoadError err ->
    Printf.eprintf "警告: %s，使用默认功能词数据\n" (format_error err);
    (FallbackData.basic_pronouns, [], [], [], [])
