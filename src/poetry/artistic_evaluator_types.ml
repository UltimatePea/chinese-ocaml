(* 诗词艺术性评价器类型定义模块
   
   定义评价器所需的基础类型和数据结构，为整个评价体系
   提供统一的类型标准。承古典诗学传统，建现代类型体系。 *)

(* 诗词评价维度类型 - 承古典诗学传统之六大评价准则 
   
   古代诗评中，品诗优劣需察其多重维度：
   《诗品》、《沧浪诗话》等历代诗论，皆有评价标准。
   今归纳为六大维度，涵盖声律、对仗、意境等传统要求。 *)
type evaluation_dimension =
  | Rhyme (* 韵律 - 音韵和谐，依韵书分类，察押韵之美 *)
  | Tone (* 声调 - 平仄相谐，四声搭配，观抑扬顿挫 *)
  | Parallelism (* 对仗 - 律诗格律，词性相对，句式工整 *)
  | Imagery (* 意象 - 诗词意境，象征手法，境界层次 *)
  | Rhythm (* 节奏 - 音律节拍，句式长短，韵律流动 *)
  | Elegance (* 雅致 - 词语典雅，格调高下，文辞品味 *)

(* 诗词评价结果类型 - 量化传统美学判断 
   
   古人品诗，多以主观感受论优劣；今以数值评分，
   使传统美学标准得以客观化、精确化表达。 *)
type evaluation_result = {
  dimension : evaluation_dimension; (* 评价维度 *)
  score : float; (* 评分值(0.0-1.0) *)
  details : string option; (* 详细说明，可包含古典诗论引证 *)
}

(* 诗词评价上下文 - 预处理诗词数据，优化计算性能 
   
   为避免重复计算字符解析、声调查询等开销较大的操作，
   预先创建评价上下文，缓存常用数据结构。
   此设计既提高效率，又保持代码清晰。 *)
type evaluation_context = {
  verse : string; (* 待评价诗句原文 *)
  char_count : int; (* UTF-8字符计数 *)
  char_list : string list; (* 字符列表，便于遍历 *)
  tone_lookup : (string, Tone_data.tone_type) Hashtbl.t; (* 声调查找哈希表 *)
}

(* 诗词评价器通用接口 - 统一各维度评价器的标准
   
   定义所有评价器必须实现的基本接口，确保评价体系的一致性。
   每个评价器专注于一个维度，遵循"术业有专攻"的设计理念。 *)
module type EVALUATOR = sig
  val evaluate : evaluation_context -> evaluation_result (* 核心评价函数 *)
  val get_dimension : unit -> evaluation_dimension (* 获取评价维度 *)
  val get_description : unit -> string (* 获取评价器描述 *)
end
