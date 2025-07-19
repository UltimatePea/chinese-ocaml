(** 词性类型定义模块接口 - 骆言诗词编程特性
    
    统一的词性类型定义接口，消除项目中的重复类型定义。
    此模块专注于类型定义，不包含数据，避免循环依赖。
    
    @author 骆言技术债务清理团队 - Phase 12 第三阶段
    @version 1.0
    @since 2025-07-19 *)

(** {1 词性分类类型} *)

(** 词性分类：依传统诗词理论分类词性 *)
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
val word_class_to_string : word_class -> string

(** 数据生成辅助函数 - 消除重复的 List.map 模式
    
    将字符串列表转换为 (字符串, 词性) 元组列表，
    用于统一生成词性数据，避免手工编写重复的元组。
    
    @param words 字符串列表，每个字符串代表一个词
    @param word_class 统一的词性类型
    @return (字符串 * 词性) 元组列表 *)
val make_word_class_list : string list -> word_class -> (string * word_class) list