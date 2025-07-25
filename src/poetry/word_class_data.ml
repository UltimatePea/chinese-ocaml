(* 词性数据模块 - 骆言诗词编程特性
   夫对仗分析，需词性数据。此模块专司词性数据存储，
   与业务逻辑分离，便于维护扩展。
   词性分类依传统诗词理论，收录常用汉字词性。
*)

(* 使用统一的词性类型定义，消除重复 *)
open Poetry_data.Word_class_types

(* 词性数据库：重构后统一接口
   依《现代汉语词典》、《古汉语常用字字典》等典籍，
   结合诗词用字特点，分类整理。
   数据已分离到独立模块，提升可维护性。
*)
(* 模块化数据定义 - 将大型数据分解为小的子列表 *)
let noun_data =
  [
    (* 自然景物 *)
    ("人", Noun);
    ("天", Noun);
    ("地", Noun);
    ("山", Noun);
    ("水", Noun);
    ("日", Noun);
    ("月", Noun);
    ("星", Noun);
    ("云", Noun);
    ("风", Noun);
    ("雨", Noun);
    ("雪", Noun);
    ("花", Noun);
    ("草", Noun);
    ("木", Noun);
    ("树", Noun);
    ("林", Noun);
    ("石", Noun);
    ("土", Noun);
    ("火", Noun);
    (* 时间概念 *)
    ("春", Noun);
    ("夏", Noun);
    ("秋", Noun);
    ("冬", Noun);
    ("年", Noun);
    ("时", Noun);
    ("刻", Noun);
    ("分", Noun);
    ("秒", Noun);
    ("钟", Noun);
    (* 建筑地理 *)
    ("道", Noun);
    ("路", Noun);
    ("门", Noun);
    ("窗", Noun);
    ("房", Noun);
    ("家", Noun);
    ("国", Noun);
    ("城", Noun);
    ("村", Noun);
    ("镇", Noun);
  ]

let verb_data =
  [
    (* 基础动词 *)
    ("是", Verb);
    ("有", Verb);
    ("来", Verb);
    ("去", Verb);
    ("看", Verb);
    ("听", Verb);
    ("说", Verb);
    ("想", Verb);
    ("知", Verb);
    ("会", Verb);
    ("能", Verb);
    ("行", Verb);
    ("走", Verb);
    ("跑", Verb);
    ("飞", Verb);
    (* 动作行为 *)
    ("开", Verb);
    ("关", Verb);
    ("进", Verb);
    ("出", Verb);
    ("入", Verb);
    ("回", Verb);
    ("归", Verb);
    ("返", Verb);
    ("达", Verb);
    ("到", Verb);
    ("过", Verb);
    ("经", Verb);
    ("历", Verb);
    ("遇", Verb);
    ("遭", Verb);
  ]

let adjective_data =
  [
    (* 大小长短 *)
    ("大", Adjective);
    ("小", Adjective);
    ("长", Adjective);
    ("短", Adjective);
    ("高", Adjective);
    ("低", Adjective);
    ("深", Adjective);
    ("浅", Adjective);
    ("宽", Adjective);
    ("窄", Adjective);
    ("厚", Adjective);
    ("薄", Adjective);
    (* 美丑好坏 *)
    ("好", Adjective);
    ("坏", Adjective);
    ("美", Adjective);
    ("丑", Adjective);
    ("亮", Adjective);
    ("暗", Adjective);
    ("明", Adjective);
    ("清", Adjective);
  ]

let other_data =
  [
    (* 数词 *)
    ("一", Numeral);
    ("二", Numeral);
    ("三", Numeral);
    ("四", Numeral);
    ("五", Numeral);
    ("六", Numeral);
    ("七", Numeral);
    ("八", Numeral);
    ("九", Numeral);
    ("十", Numeral);
    (* 量词 *)
    ("个", Classifier);
    ("只", Classifier);
    ("条", Classifier);
    ("根", Classifier);
    ("支", Classifier);
    ("枝", Classifier);
    ("片", Classifier);
    ("张", Classifier);
    (* 代词 *)
    ("我", Pronoun);
    ("你", Pronoun);
    ("他", Pronoun);
    ("她", Pronoun);
    ("它", Pronoun);
    (* 介词 *)
    ("在", Preposition);
    ("于", Preposition);
    ("从", Preposition);
    ("到", Preposition);
    (* 连词 *)
    ("和", Conjunction);
    ("与", Conjunction);
    ("及", Conjunction);
    ("或", Conjunction);
    (* 助词 *)
    ("的", Particle);
    ("地", Particle);
    ("得", Particle);
    ("了", Particle);
    (* 叹词 *)
    ("啊", Interjection);
    ("哎", Interjection);
    ("哦", Interjection);
    ("嗯", Interjection);
  ]

(* 重构后的词性数据库 - 通过组合子列表构建 *)
let word_class_database = noun_data @ verb_data @ adjective_data @ other_data

(** {2 Phase 1 Enhancement - 扩展词性数据库} *)

module Expanded_word_class = Poetry_data.Expanded_word_class_data
(** 引入扩展词性数据模块 - Phase 1 Enhancement *)
