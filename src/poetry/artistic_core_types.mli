(* 艺术数据核心类型定义模块接口 *)

(** {1 艺术数据核心类型定义}
    
    本模块定义了诗词艺术性分析系统的核心数据类型，
    包括词汇分类、评价维度、艺术标准等基础概念。
    这些类型被整个诗词分析引擎广泛使用。 *)

(** 词汇艺术性分类 *)
type word_category = 
  | Imagery     (** 意象类词汇 *)
  | Elegant     (** 雅致类词汇 *)
  | Metaphor    (** 比喻类词汇 *)
  | Emotion     (** 情感类词汇 *)
  | Nature      (** 自然类词汇 *)
  | Classical   (** 古典类词汇 *)

(** 艺术性评价维度 *)
type evaluation_dimension =
  | RhymeHarmony   (** 韵律和谐度 *)
  | TonalBalance   (** 声调平衡度 *)
  | Parallelism    (** 对仗工整度 *)
  | ImageryDepth   (** 意象深度 *)
  | FormBeauty     (** 形式美感 *)
  | ContentDepth   (** 内容深度 *)
  | MoodContext    (** 意境营造 *)

(** 词汇信息记录 *)
type word_info = {
  word : string;              (** 词汇本身 *)
  category : word_category;   (** 艺术性分类 *)
  frequency : int;            (** 使用频率 *)
  artistic_value : float;     (** 艺术价值评分 (0.0-1.0) *)
  synonyms : string list;     (** 同义词列表 *)
  contexts : string list;     (** 适用语境 *)
  examples : string list;     (** 使用示例 *)
}

(** 评价标准定义 *)
type evaluation_standard = {
  dimension : evaluation_dimension;     (** 评价维度 *)
  name : string;                       (** 标准名称 *)
  description : string;                (** 详细描述 *)
  weight : float;                      (** 权重 (0.0-1.0) *)
  min_score : float;                   (** 最低分数 *)
  max_score : float;                   (** 最高分数 *)
  criteria : (string * float) list;   (** 评分标准列表 (描述, 分值) *)
}

(** 艺术性模板 *)
type artistic_template = {
  name : string;               (** 模板名称 *)
  category : word_category;    (** 对应分类 *)
  pattern : string;            (** 模式描述 *)
  examples : string list;      (** 应用示例 *)
  effectiveness : float;       (** 有效性评分 *)
}

(** 查询结果类型 *)
type 'a query_result = 
  | Found of 'a              (** 查询成功 *)
  | NotFound                 (** 未找到 *)
  | QueryError of string     (** 查询错误 *)

(** {1 类型转换函数} *)

val word_category_from_string : string -> word_category
(** 从字符串转换为词汇分类
    @param string 词汇分类的中文或英文名称
    @return 对应的词汇分类，无法识别时返回Imagery *)

val evaluation_dimension_from_string : string -> evaluation_dimension  
(** 从字符串转换为评价维度
    @param string 评价维度的中文或英文名称
    @return 对应的评价维度，无法识别时返回ImageryDepth *)

val get_all_evaluation_dimensions : unit -> evaluation_dimension list
(** 获取所有可用的评价维度列表
    @return 完整的评价维度列表 *)