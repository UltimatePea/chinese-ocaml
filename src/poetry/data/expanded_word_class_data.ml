(** 扩展词性数据模块 - 骆言诗词编程特性 Phase 13 外化重构版
    
    基于Issue #516需求，将扩展词性数据从硬编码迁移到外部JSON文件。
    依《现代汉语词典》、《古汉语常用字字典》等典籍，
    结合诗词用字特点，分类整理常用字词词性。
    
    重构说明：
    - 移除了1575行硬编码数据，改为从外部JSON文件加载
    - 保持原有API接口不变，向后兼容
    - 增加错误处理和降级机制，确保系统稳定性
    - 大幅减少代码重复，提高维护性
    
    @author 骆言诗词编程团队 Phase 13
    @version 2.0 - 外化重构版
    @since 2025-07-19
    @updated 2025-07-19 Phase 13: 数据外化重构完成 *)

open Word_class_types
(** 使用统一的词性类型定义 *)

open Expanded_data_loader

(** {1 外部数据加载} *)

(** 延迟加载标志 - 确保数据只加载一次 *)
let _data_loaded = ref false

let _loaded_data = ref None

(** 加载所有扩展词性数据 *)
let load_all_data () =
  if not !_data_loaded then (
    let nouns = safe_load_nouns () in
    let verbs = safe_load_verbs () in
    let adjectives = safe_load_adjectives () in
    let adverbs = safe_load_adverbs () in
    let nums_cls = safe_load_numerals_classifiers () in
    let func_words = safe_load_function_words () in

    _loaded_data := Some (nouns, verbs, adjectives, adverbs, nums_cls, func_words);
    _data_loaded := true)

(** 获取加载的数据 *)
let get_loaded_data () =
  load_all_data ();
  match !_loaded_data with Some data -> data | None -> failwith "数据加载失败"

(** {1 数据生成辅助函数} *)

(** 词性数据生成辅助函数 - 消除代码重复的核心函数 *)
let _make_word_class_list words word_class = List.map (fun word -> (word, word_class)) words

(** {1 名词数据} *)

module WordClassStorage = Word_class_data_storage
(** 引入词性数据存储模块（保持向后兼容） *)

(** 自然景物名词 - 继续从存储模块加载（保持兼容性） *)
let nature_nouns = List.map (fun word -> (word, Noun)) WordClassStorage.nature_nouns_list

(** 人物称谓数据 - 从外部JSON加载 *)
let person_relation_nouns =
  let person_relation, _, _, _, _, _, _, _, _, _ =
    let nouns, _, _, _, _, _ = get_loaded_data () in
    nouns
  in
  person_relation

(** 社会地位数据 - 从外部JSON加载 *)
let social_status_nouns =
  let _, social_status, _, _, _, _, _, _, _, _ =
    let nouns, _, _, _, _, _ = get_loaded_data () in
    nouns
  in
  social_status

(** 建筑场所数据 - 从外部JSON加载 *)
let building_place_nouns =
  let _, _, building_place, _, _, _, _, _, _, _ =
    let nouns, _, _, _, _, _ = get_loaded_data () in
    nouns
  in
  building_place

(** 地理政治数据 - 从外部JSON加载 *)
let geography_politics_nouns =
  let _, _, _, geography_politics, _, _, _, _, _, _ =
    let nouns, _, _, _, _, _ = get_loaded_data () in
    nouns
  in
  geography_politics

(** 器物用具数据 - 从外部JSON加载 *)
let tools_objects_nouns =
  let _, _, _, _, tools_objects, _, _, _, _, _ =
    let nouns, _, _, _, _, _ = get_loaded_data () in
    nouns
  in
  tools_objects

(** 情感心理名词 - 从外部JSON加载 *)
let emotional_psychological_nouns =
  let _, _, _, _, _, emotional_psychological, _, _, _, _ =
    let nouns, _, _, _, _, _ = get_loaded_data () in
    nouns
  in
  emotional_psychological

(** 道德品质名词 - 从外部JSON加载 *)
let moral_virtue_nouns =
  let _, _, _, _, _, _, moral_virtue, _, _, _ =
    let nouns, _, _, _, _, _ = get_loaded_data () in
    nouns
  in
  moral_virtue

(** 学问知识名词 - 从外部JSON加载 *)
let knowledge_learning_nouns =
  let _, _, _, _, _, _, _, knowledge_learning, _, _ =
    let nouns, _, _, _, _, _ = get_loaded_data () in
    nouns
  in
  knowledge_learning

(** 时空概念名词 - 从外部JSON加载 *)
let time_space_nouns =
  let _, _, _, _, _, _, _, _, time_space, _ =
    let nouns, _, _, _, _, _ = get_loaded_data () in
    nouns
  in
  time_space

(** 事务活动名词 - 从外部JSON加载 *)
let affairs_activity_nouns =
  let _, _, _, _, _, _, _, _, _, affairs_activity =
    let nouns, _, _, _, _, _ = get_loaded_data () in
    nouns
  in
  affairs_activity

(** {1 动词数据} *)

(** 移动位置动词 - 从外部JSON加载 *)
let movement_position_verbs =
  let movement_position, _, _, _, _, _, _, _, _, _, _ =
    let _, verbs, _, _, _, _ = get_loaded_data () in
    verbs
  in
  movement_position

(** 感官动作动词 - 从外部JSON加载 *)
let sensory_action_verbs =
  let _, sensory_action, _, _, _, _, _, _, _, _, _ =
    let _, verbs, _, _, _, _ = get_loaded_data () in
    verbs
  in
  sensory_action

(** 思维活动动词 - 从外部JSON加载 *)
let cognitive_activity_verbs =
  let _, _, cognitive_activity, _, _, _, _, _, _, _, _ =
    let _, verbs, _, _, _, _ = get_loaded_data () in
    verbs
  in
  cognitive_activity

(** 社交沟通动词 - 从外部JSON加载 *)
let social_communication_verbs =
  let _, _, _, social_communication, _, _, _, _, _, _, _ =
    let _, verbs, _, _, _, _ = get_loaded_data () in
    verbs
  in
  social_communication

(** 情感表达动词 - 从外部JSON加载 *)
let emotional_expression_verbs =
  let _, _, _, _, emotional_expression, _, _, _, _, _, _ =
    let _, verbs, _, _, _, _ = get_loaded_data () in
    verbs
  in
  emotional_expression

(** 社会行为动词 - 从外部JSON加载 *)
let social_behavior_verbs =
  let _, _, _, _, _, social_behavior, _, _, _, _, _ =
    let _, verbs, _, _, _, _ = get_loaded_data () in
    verbs
  in
  social_behavior

(** 农业生产动词 - 从外部JSON加载 *)
let agricultural_verbs =
  let _, _, _, _, _, _, agricultural, _, _, _, _ =
    let _, verbs, _, _, _, _ = get_loaded_data () in
    verbs
  in
  agricultural

(** 手工制造动词 - 从外部JSON加载 *)
let manufacturing_verbs =
  let _, _, _, _, _, _, _, manufacturing, _, _, _ =
    let _, verbs, _, _, _, _ = get_loaded_data () in
    verbs
  in
  manufacturing

(** 搬运运输动词 - 从外部JSON加载 *)
let transportation_verbs =
  let _, _, _, _, _, _, _, _, transportation, _, _ =
    let _, verbs, _, _, _, _ = get_loaded_data () in
    verbs
  in
  transportation

(** 买卖交易动词 - 从外部JSON加载 *)
let commercial_verbs =
  let _, _, _, _, _, _, _, _, _, commercial, _ =
    let _, verbs, _, _, _, _ = get_loaded_data () in
    verbs
  in
  commercial

(** 清洁处理动词 - 从外部JSON加载 *)
let cleaning_verbs =
  let _, _, _, _, _, _, _, _, _, _, cleaning =
    let _, verbs, _, _, _, _ = get_loaded_data () in
    verbs
  in
  cleaning

(** {1 形容词数据} *)

(** 尺寸大小形容词 - 从外部JSON加载 *)
let size_adjectives =
  let size, _, _, _, _, _, _, _, _, _, _, _ =
    let _, _, adjectives, _, _, _ = get_loaded_data () in
    adjectives
  in
  size

(** 形状外观形容词 - 从外部JSON加载 *)
let shape_adjectives =
  let _, shape, _, _, _, _, _, _, _, _, _, _ =
    let _, _, adjectives, _, _, _ = get_loaded_data () in
    adjectives
  in
  shape

(** 颜色色彩形容词 - 从外部JSON加载 *)
let color_adjectives =
  let _, _, color, _, _, _, _, _, _, _, _, _ =
    let _, _, adjectives, _, _, _ = get_loaded_data () in
    adjectives
  in
  color

(** 质地材料形容词 - 从外部JSON加载 *)
let texture_adjectives =
  let _, _, _, texture, _, _, _, _, _, _, _, _ =
    let _, _, adjectives, _, _, _ = get_loaded_data () in
    adjectives
  in
  texture

(** 品质评价形容词 - 从外部JSON加载 *)
let value_judgment_adjectives =
  let _, _, _, _, value_judgment, _, _, _, _, _, _, _ =
    let _, _, adjectives, _, _, _ = get_loaded_data () in
    adjectives
  in
  value_judgment

(** 情感状态形容词 - 从外部JSON加载 *)
let emotional_state_adjectives =
  let _, _, _, _, _, emotional_state, _, _, _, _, _, _ =
    let _, _, adjectives, _, _, _ = get_loaded_data () in
    adjectives
  in
  emotional_state

(** 运动状态形容词 - 从外部JSON加载 *)
let motion_state_adjectives =
  let _, _, _, _, _, _, motion_state, _, _, _, _, _ =
    let _, _, adjectives, _, _, _ = get_loaded_data () in
    adjectives
  in
  motion_state

(** 温度湿度形容词 - 从外部JSON加载 *)
let temperature_texture_adjectives =
  let _, _, _, _, _, _, _, temperature_texture, _, _, _, _ =
    let _, _, adjectives, _, _, _ = get_loaded_data () in
    adjectives
  in
  temperature_texture

(** 纯净污浊形容词 - 从外部JSON加载 *)
let purity_cleanliness_adjectives =
  let _, _, _, _, _, _, _, _, purity_cleanliness, _, _, _ =
    let _, _, adjectives, _, _, _ = get_loaded_data () in
    adjectives
  in
  purity_cleanliness

(** 道德品质形容词 - 从外部JSON加载 *)
let moral_character_adjectives =
  let _, _, _, _, _, _, _, _, _, moral_character, _, _ =
    let _, _, adjectives, _, _, _ = get_loaded_data () in
    adjectives
  in
  moral_character

(** 智慧明暗形容词 - 从外部JSON加载 *)
let wisdom_brightness_adjectives =
  let _, _, _, _, _, _, _, _, _, _, wisdom_brightness, _ =
    let _, _, adjectives, _, _, _ = get_loaded_data () in
    adjectives
  in
  wisdom_brightness

(** 精密程度形容词 - 从外部JSON加载 *)
let precision_degree_adjectives =
  let _, _, _, _, _, _, _, _, _, _, _, precision_degree =
    let _, _, adjectives, _, _, _ = get_loaded_data () in
    adjectives
  in
  precision_degree

(** {1 副词数据} *)

(** 程度副词 - 从外部JSON加载 *)
let degree_adverbs =
  let degree, _, _ =
    let _, _, _, adverbs, _, _ = get_loaded_data () in
    adverbs
  in
  degree

(** 时间副词 - 从外部JSON加载 *)
let temporal_adverbs =
  let _, temporal, _ =
    let _, _, _, adverbs, _, _ = get_loaded_data () in
    adverbs
  in
  temporal

(** 方式副词 - 从外部JSON加载 *)
let manner_adverbs =
  let _, _, manner =
    let _, _, _, adverbs, _, _ = get_loaded_data () in
    adverbs
  in
  manner

(** {1 数词量词数据} *)

(** 基数词 - 从外部JSON加载 *)
let cardinal_numbers =
  let cardinal_numbers, _, _ =
    let _, _, _, _, nums_cls, _ = get_loaded_data () in
    nums_cls
  in
  cardinal_numbers

(** 序数词 - 从外部JSON加载 *)
let ordinal_numbers =
  let _, ordinal_numbers, _ =
    let _, _, _, _, nums_cls, _ = get_loaded_data () in
    nums_cls
  in
  ordinal_numbers

(** 量词数据 - 从外部JSON加载和存储模块合并 *)
let measuring_classifiers =
  let _, _, classifiers =
    let _, _, _, _, nums_cls, _ = get_loaded_data () in
    nums_cls
  in
  classifiers
  @ List.map (fun word -> (word, Classifier)) WordClassStorage.measuring_classifiers_list

(** {1 功能词数据} *)

(** 代词数据 - 从外部JSON加载 *)
let pronoun_words =
  let pronouns, _, _, _, _ =
    let _, _, _, _, _, func_words = get_loaded_data () in
    func_words
  in
  pronouns

(** 介词数据 - 从外部JSON加载 *)
let preposition_words =
  let _, prepositions, _, _, _ =
    let _, _, _, _, _, func_words = get_loaded_data () in
    func_words
  in
  prepositions

(** 连词数据 - 从外部JSON加载 *)
let conjunction_words =
  let _, _, conjunctions, _, _ =
    let _, _, _, _, _, func_words = get_loaded_data () in
    func_words
  in
  conjunctions

(** 助词数据 - 从外部JSON加载 *)
let particle_words =
  let _, _, _, particles, _ =
    let _, _, _, _, _, func_words = get_loaded_data () in
    func_words
  in
  particles

(** 叹词数据 - 从外部JSON加载 *)
let interjection_words =
  let _, _, _, _, interjections =
    let _, _, _, _, _, func_words = get_loaded_data () in
    func_words
  in
  interjections

(** {1 合并数据列表 - 保持向后兼容} *)

(** 全部扩展词性数据的合并列表 *)
let all_expanded_word_class_data =
  lazy
    (nature_nouns @ person_relation_nouns @ social_status_nouns @ building_place_nouns
   @ geography_politics_nouns @ tools_objects_nouns @ emotional_psychological_nouns
   @ moral_virtue_nouns @ knowledge_learning_nouns @ time_space_nouns @ affairs_activity_nouns
   @ movement_position_verbs @ sensory_action_verbs @ cognitive_activity_verbs
   @ social_communication_verbs @ emotional_expression_verbs @ social_behavior_verbs
   @ agricultural_verbs @ manufacturing_verbs @ transportation_verbs @ commercial_verbs
   @ cleaning_verbs @ size_adjectives @ shape_adjectives @ color_adjectives @ texture_adjectives
   @ value_judgment_adjectives @ emotional_state_adjectives @ motion_state_adjectives
   @ temperature_texture_adjectives @ purity_cleanliness_adjectives @ moral_character_adjectives
   @ wisdom_brightness_adjectives @ precision_degree_adjectives @ degree_adverbs @ temporal_adverbs
   @ manner_adverbs @ cardinal_numbers @ ordinal_numbers @ measuring_classifiers @ pronoun_words
   @ preposition_words @ conjunction_words @ particle_words @ interjection_words)

(** 统计信息 *)
let _get_data_statistics () =
  let total_words = List.length (Lazy.force all_expanded_word_class_data) in
  let nouns_count =
    List.length nature_nouns + List.length person_relation_nouns + List.length social_status_nouns
    + List.length building_place_nouns
    + List.length geography_politics_nouns
    + List.length tools_objects_nouns
    + List.length emotional_psychological_nouns
    + List.length moral_virtue_nouns
    + List.length knowledge_learning_nouns
    + List.length time_space_nouns
    + List.length affairs_activity_nouns
  in
  let verbs_count =
    List.length movement_position_verbs
    + List.length sensory_action_verbs
    + List.length cognitive_activity_verbs
    + List.length social_communication_verbs
    + List.length emotional_expression_verbs
    + List.length social_behavior_verbs + List.length agricultural_verbs
    + List.length manufacturing_verbs + List.length transportation_verbs
    + List.length commercial_verbs + List.length cleaning_verbs
  in
  let adjectives_count =
    List.length size_adjectives + List.length shape_adjectives + List.length color_adjectives
    + List.length texture_adjectives
    + List.length value_judgment_adjectives
    + List.length emotional_state_adjectives
    + List.length motion_state_adjectives
    + List.length temperature_texture_adjectives
    + List.length purity_cleanliness_adjectives
    + List.length moral_character_adjectives
    + List.length wisdom_brightness_adjectives
    + List.length precision_degree_adjectives
  in
  let adverbs_count =
    List.length degree_adverbs + List.length temporal_adverbs + List.length manner_adverbs
  in
  let numerals_count =
    List.length cardinal_numbers + List.length ordinal_numbers + List.length measuring_classifiers
  in
  let function_words_count =
    List.length pronoun_words + List.length preposition_words + List.length conjunction_words
    + List.length particle_words + List.length interjection_words
  in

  Printf.printf "扩展词性数据统计 (Phase 13 外化版本):\n";
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
