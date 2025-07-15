(** 编程模式匹配库接口 - Programming Pattern Matching Library Interface *)

type programming_pattern = {
  name : string; (* 模式名称 *)
  keywords : string list; (* 关键词 *)
  template : string; (* 代码模板 *)
  description : string; (* 描述 *)
  category : string; (* 分类 *)
  complexity : int; (* 复杂度 1-5 *)
  examples : string list; (* 示例 *)
}
(** 编程模式类型 *)

type pattern_match = {
  pattern : programming_pattern; (* 匹配的模式 *)
  confidence : float; (* 匹配置信度 *)
  extracted_params : (string * string) list; (* 提取的参数 *)
}
(** 模式匹配结果 *)

val find_best_patterns : string -> int -> pattern_match list
(** 查找最佳匹配模式 *)

val generate_code_from_pattern : pattern_match -> string
(** 生成基于模式的代码 *)

val analyze_code_intent : string -> string
(** 分析代码意图 *)

val recommend_related_patterns : programming_pattern -> programming_pattern list
(** 推荐相关模式 *)

val format_pattern_match : pattern_match -> string
(** 格式化模式匹配结果 *)

val test_pattern_matching : unit -> unit
(** 测试模式匹配功能 *)
