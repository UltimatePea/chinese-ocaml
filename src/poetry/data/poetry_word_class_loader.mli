(** 诗词词类数据加载器 - 核心词汇数据加载逻辑
    
    负责从JSON数据文件中加载各类词汇数据，包括名词、动词、形容词、
    副词、数词分类词和功能词等。提供标准化的词类数据访问接口。
    
    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 *)

open Word_class_types

(** 加载名词数据
    @return 包含10个名词类别的元组：
    (人际关系, 社会地位, 建筑场所, 地理政治, 工具物品, 
     情感心理, 道德品德, 知识学习, 时间空间, 事务活动) *)
val load_nouns : unit -> 
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list

(** 加载动词数据  
    @return 包含11个动词类别的元组：
    (运动位置, 感觉行为, 认知活动, 社会交流, 情感表达, 
     社会行为, 农业, 制造业, 运输业, 商业, 清洁) *)
val load_verbs : unit ->
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list

(** 加载形容词数据
    @return 包含12个形容词类别的元组：
    (尺寸, 形状, 颜色, 质地, 价值判断, 情感状态, 
     运动状态, 温度质感, 纯洁清洁, 道德品格, 智慧光明, 精确程度) *)
val load_adjectives : unit ->
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list

(** 加载副词数据
    @return 包含3个副词类别的元组：(程度, 时间, 方式) *)
val load_adverbs : unit ->
  (string * word_class) list * (string * word_class) list * (string * word_class) list

(** 加载数词和分类词数据
    @return 包含3个类别的元组：(基数词, 序数词, 分类词) *)
val load_numerals_classifiers : unit ->
  (string * word_class) list * (string * word_class) list * (string * word_class) list

(** 加载功能词数据
    @return 包含5个功能词类别的元组：(代词, 介词, 连词, 助词, 感叹词) *)
val load_function_words : unit ->
  (string * word_class) list * (string * word_class) list * 
  (string * word_class) list * (string * word_class) list * (string * word_class) list