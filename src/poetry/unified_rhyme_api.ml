(** 统一韵律API模块 - 重构版本
    
    提供统一的韵律数据访问接口，整合各个专门模块的功能。
    已重构为模块化架构，数据与逻辑分离。

    @author 骆言诗词编程团队
    @version 3.0 - 重构版本
    @since 2025-07-19 - unified_rhyme_api.ml模块化重构 *)

open Rhyme_types

(** {1 核心韵律检测API - 重新导出} *)

(** 查找字符的韵律信息 *)
let find_rhyme_info = Rhyme_api_core.find_rhyme_info

(** 检测字符的韵类 *)
let detect_rhyme_category = Rhyme_api_core.detect_rhyme_category

(** 检测字符的韵组 *)
let detect_rhyme_group = Rhyme_api_core.detect_rhyme_group

(** 获取韵组包含的所有字符 *)
let get_rhyme_characters = Rhyme_api_core.get_rhyme_characters

(** 验证字符列表的韵律一致性 *)
let validate_rhyme_consistency = Rhyme_api_core.validate_rhyme_consistency

(** 检查两个字符是否押韵 *)
let check_rhyme = Rhyme_api_core.check_rhyme

(** 查找与给定字符押韵的所有字符 *)
let find_rhyming_characters = Rhyme_api_core.find_rhyming_characters

(** 检查字符是否为已知韵字 *)
let is_known_rhyme_char = Rhyme_api_core.is_known_rhyme_char

(** 获取字符的韵律描述 *)
let get_rhyme_description = Rhyme_api_core.get_rhyme_description

(** {1 高级韵律分析API - 重新导出} *)

(** 分析文本的韵律模式 *)
let analyze_rhyme_pattern = Rhyme_advanced_analysis.analyze_rhyme_pattern

(** 获取韵律数据统计信息 *)
let get_rhyme_stats = Rhyme_advanced_analysis.get_rhyme_stats

(** 分析诗句的韵律结构 *)
let analyze_poem_line_structure = Rhyme_advanced_analysis.analyze_poem_line_structure

(** 检测诗句间的押韵关系 *)
let detect_poem_rhyme_scheme = Rhyme_advanced_analysis.detect_poem_rhyme_scheme

(** 评估文本的韵律质量 *)
let evaluate_rhyme_quality = Rhyme_advanced_analysis.evaluate_rhyme_quality

(** 建议押韵字符 *)
let suggest_rhyming_chars = Rhyme_advanced_analysis.suggest_rhyming_chars

(** {1 数据管理API - 重新导出} *)

(** 加载韵律数据到缓存 *)
let load_rhyme_data = Unified_rhyme_data.load_rhyme_data_to_cache

(** 获取指定韵组的字符集 *)
let get_rhyme_group_chars = Unified_rhyme_data.get_rhyme_group_chars

(** 获取所有韵组列表 *)
let get_all_rhyme_groups () = 
  List.map (fun (group, _) -> group) (Unified_rhyme_data.get_all_rhyme_groups ())

(** 获取韵律数据统计信息 *)
let get_data_stats = Unified_rhyme_data.get_data_stats

(** {1 兼容性函数} *)

(** 兼容原有接口的函数别名 *)
module Legacy = struct
  let find_rhyme = find_rhyme_info
  let get_rhyme_info = find_rhyme_info
  let rhyme_detection = detect_rhyme_category
  let rhyme_group_detection = detect_rhyme_group
  let is_same_rhyme = check_rhyme
  let validate_rhyme = validate_rhyme_consistency
end

(** 初始化函数 - 供外部模块调用 *)
let initialize () = load_rhyme_data ()