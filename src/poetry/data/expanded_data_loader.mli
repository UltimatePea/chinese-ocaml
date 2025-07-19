(** 扩展诗词数据加载器接口 - 骆言项目 Phase 13 技术债务清理
    
    负责从外部JSON文件加载扩展诗词数据，实现数据与代码分离。
    替代原有的硬编码数据，提高维护性和可扩展性。
    
    @author 骆言技术债务清理团队 Phase 13
    @version 1.0
    @since 2025-07-19 *)

open Word_class_types

(** 数据加载错误类型 *)
type data_load_error = 
  | FileNotFound of string
  | ParseError of string * string
  | ValidationError of string

(** 数据加载异常 *)
exception DataLoadError of data_load_error

(** 格式化错误信息 *)
val format_error : data_load_error -> string

(** 安全加载名词数据 - 返回元组包含所有名词分类
    @return (person_relation, social_status, building_place, geography_politics, tools_objects,
             emotional_psychological, moral_virtue, knowledge_learning, time_space, affairs_activity) *)
val safe_load_nouns : unit -> 
  (string * word_class) list * (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * (string * word_class) list * 
  (string * word_class) list

(** 安全加载动词数据 - 返回元组包含所有动词分类
    @return (movement_position, sensory_action, cognitive_activity, social_communication, 
             emotional_expression, social_behavior, agricultural, manufacturing, 
             transportation, commercial, cleaning) *)
val safe_load_verbs : unit -> 
  (string * word_class) list * (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list

(** 安全加载形容词数据 - 返回元组包含所有形容词分类
    @return (size, shape, color, texture, value_judgment, emotional_state, motion_state,
             temperature_texture, purity_cleanliness, moral_character, wisdom_brightness, precision_degree) *)
val safe_load_adjectives : unit -> 
  (string * word_class) list * (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * (string * word_class) list

(** 安全加载副词数据 - 返回元组包含所有副词分类
    @return (degree, temporal, manner) *)
val safe_load_adverbs : unit -> 
  (string * word_class) list * (string * word_class) list * (string * word_class) list

(** 安全加载数词和量词数据 - 返回元组包含数词和量词分类
    @return (cardinal_numbers, ordinal_numbers, classifiers) *)
val safe_load_numerals_classifiers : unit -> 
  (string * word_class) list * (string * word_class) list * (string * word_class) list

(** 安全加载功能词数据 - 返回元组包含所有功能词分类
    @return (pronouns, prepositions, conjunctions, particles, interjections) *)
val safe_load_function_words : unit -> 
  (string * word_class) list * (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list