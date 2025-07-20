(** 诗词数据后备支持模块 - 提供默认数据和容错机制
    
    当主要数据文件加载失败时，提供基本的词汇数据作为后备。
    确保系统在数据文件缺失的情况下仍能正常运行。
    
    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 *)

open Word_class_types

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