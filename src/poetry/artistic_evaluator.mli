(** 诗词艺术性评价器模块接口
    
    此模块提供标准化的诗词艺术性评价功能，包括韵律、声调、对仗、意象、节奏和雅致等维度的评价。
    模块采用现代OCaml设计模式，提供类型安全的评价接口和高性能的评价实现。
*)

(** 评价维度类型 - 定义诗词艺术性评价的各个维度 *)
type evaluation_dimension =
  | Rhyme        (** 韵律 - 评价韵脚和押韵的和谐性 *)
  | Tone         (** 声调 - 评价声调的平衡性和起伏 *)
  | Parallelism  (** 对仗 - 评价对仗的工整性 *)
  | Imagery      (** 意象 - 评价意象的丰富性和深度 *)
  | Rhythm       (** 节奏 - 评价节奏的流畅性 *)
  | Elegance     (** 雅致 - 评价用词的雅致程度 *)

(** 评价结果类型 - 包含评价维度、分数和详细信息 *)
type evaluation_result = {
  dimension : evaluation_dimension;  (** 评价维度 *)
  score : float;                     (** 评价分数 (0.0 - 1.0) *)
  details : string option;           (** 可选的详细评价信息 *)
}

(** 评价上下文类型 - 包含预计算的评价数据，提升性能 *)
type evaluation_context = {
  verse : string;                                    (** 原始诗句 *)
  char_count : int;                                  (** 字符数量 *)
  char_list : string list;                           (** 字符列表 *)
  tone_lookup : (string, Tone_data.tone_type) Hashtbl.t;  (** 声调查找表 *)
}

(** 创建评价上下文
    
    @param verse 要评价的诗句
    @return 包含预计算数据的评价上下文
*)
val create_evaluation_context : string -> evaluation_context

(** 获取字符声调
    
    @param context 评价上下文
    @param char 字符
    @return 字符对应的声调，如果未找到则返回None
*)
val get_char_tone : evaluation_context -> string -> Tone_data.tone_type option

(** 评价器模块类型签名 - 定义所有评价器必须实现的接口 *)
module type EVALUATOR = sig
  (** 执行评价
      
      @param context 评价上下文
      @return 评价结果
  *)
  val evaluate : evaluation_context -> evaluation_result
  
  (** 获取评价维度
      
      @return 该评价器负责的评价维度
  *)
  val get_dimension : unit -> evaluation_dimension
  
  (** 获取评价器描述
      
      @return 评价器的中文描述
  *)
  val get_description : unit -> string
end

(** 韵律评价器 - 评价韵脚和押韵的和谐性 *)
module RhymeEvaluator : EVALUATOR

(** 声调评价器 - 评价声调的平衡性和起伏 *)
module ToneEvaluator : EVALUATOR

(** 对仗评价器 - 评价对仗的工整性 *)
module ParallelismEvaluator : EVALUATOR

(** 意象评价器 - 评价意象的丰富性和深度 *)
module ImageryEvaluator : EVALUATOR

(** 节奏评价器 - 评价节奏的流畅性 *)
module RhythmEvaluator : EVALUATOR

(** 雅致评价器 - 评价用词的雅致程度 *)
module EleganceEvaluator : EVALUATOR

(** 综合评价器 - 协调所有子评价器，提供统一的评价接口 *)
module ComprehensiveEvaluator : sig
  (** 执行全面评价
      
      @param context 评价上下文
      @return 所有维度的评价结果列表
  *)
  val evaluate_all : evaluation_context -> evaluation_result list
end