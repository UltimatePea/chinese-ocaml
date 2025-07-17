(* 词性数据模块接口 - 骆言诗词编程特性
   此模块提供词性数据存储和访问接口，
   与对仗分析业务逻辑分离，提升代码可维护性。
*)

(* 词性分类：依传统诗词理论分类词性 *)
type word_class =
  | Noun          (* 名词 - 人物地名等实体 *)
  | Verb          (* 动词 - 动作行为等 *)
  | Adjective     (* 形容词 - 性质状态等 *)
  | Adverb        (* 副词 - 修饰动词形容词 *)
  | Numeral       (* 数词 - 一二三等数量 *)
  | Classifier    (* 量词 - 个只条等单位 *)
  | Pronoun       (* 代词 - 我你他等称谓 *)
  | Preposition   (* 介词 - 在于从等关系 *)
  | Conjunction   (* 连词 - 和与或等连接 *)
  | Particle      (* 助词 - 之乎者也等 *)
  | Interjection  (* 叹词 - 啊哎呀等感叹 *)
  | Unknown       (* 未知词性 - 待分析 *)

(* 词性数据库：收录常用汉字词性的关联列表
   字符串到词性的映射，用于词性检测和对仗分析
*)
val word_class_database : (string * word_class) list