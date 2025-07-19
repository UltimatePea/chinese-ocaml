(** 词性类型定义模块 - 骆言诗词编程特性
    
    统一的词性类型定义，消除项目中的重复类型定义。
    此模块专注于类型定义，不包含数据，避免循环依赖。
    
    @author 骆言技术债务清理团队 - Phase 12 第三阶段
    @version 1.0
    @since 2025-07-19 *)

(** {1 词性分类类型定义} *)

(** 词性分类：依传统诗词理论分类词性
    
    名词实词，动词虚词，形容词状语，各有所归。
    此分类用于对仗分析，确保词性相对。
    
    分类基于《现代汉语词典》、《古汉语常用字字典》等典籍，
    结合诗词用字特点，满足对仗分析需求。 *)
type word_class =
  | Noun (* 名词 - 人物地名等实体 *)
  | Verb (* 动词 - 动作行为等 *)
  | Adjective (* 形容词 - 性质状态等 *)
  | Adverb (* 副词 - 修饰动词形容词 *)
  | Numeral (* 数词 - 一二三等数量 *)
  | Classifier (* 量词 - 个只条等单位 *)
  | Pronoun (* 代词 - 我你他等称谓 *)
  | Preposition (* 介词 - 在于从等关系 *)
  | Conjunction (* 连词 - 和与或等连接 *)
  | Particle (* 助词 - 之乎者也等 *)
  | Interjection (* 叹词 - 啊哎呀等感叹 *)
  | Unknown (* 未知词性 - 待分析 *)

(** {1 辅助函数} *)

(** 将词性转换为可读字符串，用于调试和显示 *)
let word_class_to_string = function
  | Noun -> "名词"
  | Verb -> "动词"
  | Adjective -> "形容词"
  | Adverb -> "副词"
  | Numeral -> "数词"
  | Classifier -> "量词"
  | Pronoun -> "代词"
  | Preposition -> "介词"
  | Conjunction -> "连词"
  | Particle -> "助词"
  | Interjection -> "叹词"
  | Unknown -> "未知"

(** 数据生成辅助函数 - 消除重复的 List.map 模式
    
    将字符串列表转换为 (字符串, 词性) 元组列表，
    用于统一生成词性数据，避免手工编写重复的元组。
    
    @param words 字符串列表，每个字符串代表一个词
    @param word_class 统一的词性类型
    @return (字符串 * 词性) 元组列表 *)
let make_word_class_list words word_class =
  List.map (fun word -> (word, word_class)) words