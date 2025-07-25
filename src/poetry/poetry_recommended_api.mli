(** 诗词处理推荐API模块接口
 *
 * 提供骆言编译器诗词功能的统一、推荐入口点。
 * 
 * 此模块解决了现有诗词处理模块过度分散的问题，提供：
 * - 统一的API接口
 * - 最佳性能实现
 * - 清晰的使用指导
 * - 兼容性支持
 *
 * @author 骆言编程团队
 * @version 1.0
 * @since 2025-07-25
 * @issue #1155 诗词模块整合优化
 *)

(** {1 核心类型定义} *)

type rhyme_info = Rhyme_types.rhyme_category * Rhyme_types.rhyme_group
(** 韵律信息：韵类和韵组的组合 *)

type evaluation_result = {
  score : float;  (** 总分 (0.0-1.0) *)
  rhyme_quality : float;  (** 韵律质量 (0.0-1.0) *)
  artistic_quality : float;  (** 艺术质量 (0.0-1.0) *)
  form_compliance : float;  (** 格律符合度 (0.0-1.0) *)
  recommendations : string list;  (** 改进建议列表 *)
}
(** 诗词评价结果 *)

(** {1 韵律分析API} *)

val find_rhyme_info : string -> rhyme_info option
(** 查找字符的韵律信息
 *
 * 这是查找韵律信息的推荐方法，具有以下优势：
 * - 使用高效缓存机制
 * - 统一的错误处理
 * - 经过性能优化
 *
 * @param char 要查找的汉字字符
 * @return 韵律信息(韵类, 韵组)，如果未找到则返回None
 * @example
 *   find_rhyme_info '春' = Some (PingSheng, SiRhyme)
 *   find_rhyme_info '月' = Some (ZeSheng, YueRhyme)
 *   find_rhyme_info 'a' = None
 *)

val detect_rhyme_category : string -> Rhyme_types.rhyme_category
(** 检测字符的韵律类型
 *
 * 快速检测字符属于哪种韵律类型。
 *
 * @param char 要检测的汉字字符
 * @return 韵律类型，未知字符返回PingSheng作为默认值
 * @example
 *   detect_rhyme_category '春' = PingSheng
 *   detect_rhyme_category '月' = ZeSheng
 *)

val check_rhyme_match : string -> string -> bool
(** 验证两个字符是否押韵
 *
 * 检查两个字符是否属于相同韵组，可以押韵。
 *
 * @param char1 第一个字符
 * @param char2 第二个字符  
 * @return 如果两字符属于同一韵组则返回true
 * @example
 *   check_rhyme_match '春' '人' = true  (* 都是SiRhyme *)
 *   check_rhyme_match '春' '月' = false (* 不同韵组 *)
 *)

(** {1 诗词评价API} *)

val evaluate_poem : string list -> evaluation_result
(** 评估诗词质量
 *
 * 对诗词进行综合质量评价，包括韵律、艺术性和格律等方面。
 *
 * @param poem_lines 诗词的行列表，每个字符串代表一行
 * @return 详细的评价结果，包含各维度分数和改进建议
 * @example
 *   let poem = ["春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少"] in
 *   let result = evaluate_poem poem in
 *   Printf.printf "总分: %.2f\\n" result.score
 *)

(** {1 数据管理API} *)

val preload_rhyme_data : unit -> unit
(** 预加载韵律数据
 *
 * 建议在程序启动时调用，预加载韵律数据到缓存中。
 * 这可以显著提升后续韵律查询的性能。
 *
 * @example
 *   (* 程序初始化时 *)
 *   Poetry_recommended_api.preload_rhyme_data ()
 *)

val cleanup_cache : unit -> unit
(** 清理缓存数据 * * 清理韵律数据缓存，释放内存。 * 可在不再需要诗词功能时调用。 *)

(** {1 模块迁移指南}
 *
 * 如果您正在使用以下模块，建议迁移到此推荐API：
 *
 * {2 韵律查找}
 * - [Rhyme_detection.find_rhyme_info] → {!find_rhyme_info}
 * - [Rhyme_database.lookup_rhyme] → {!find_rhyme_info}
 * - [Rhyme_json_api.get_rhyme_data] → {!find_rhyme_info}
 *
 * {2 韵律检测}
 * - [Rhyme_analysis.detect_category] → {!detect_rhyme_category}
 * - [Rhyme_validation.check_rhyme_type] → {!detect_rhyme_category}
 *
 * {2 押韵验证}
 * - [Rhyme_matching.check_rhyme] → {!check_rhyme_match}
 * - [Rhyme_scoring.verify_rhyme] → {!check_rhyme_match}
 *
 * {2 诗词评价}
 * - [Artistic_evaluation.evaluate_poem] → {!evaluate_poem}
 * - [Poetry_forms_evaluation.check_form] → {!evaluate_poem}
 * - [Artistic_evaluators.comprehensive_eval] → {!evaluate_poem}
 *
 * {2 迁移好处}
 * - 统一的API接口，减少学习成本
 * - 更好的性能和缓存机制
 * - 统一的错误处理
 * - 面向未来的兼容性
 *)
