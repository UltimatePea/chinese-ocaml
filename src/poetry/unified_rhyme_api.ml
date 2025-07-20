(** 统一韵律API模块 - 完整统一版本
    
    此模块提供统一的韵律数据访问接口，整合各个专门模块的功能。
    消除韵律API重复，提供单一入口点，使用模块化架构。
    
    重构策略：
    - 统一API入口：消除unified_rhyme_api_refactored.ml重复
    - 模块化设计：重新导出核心模块功能
    - 保持兼容性：支持所有现有接口
    - 增强功能：添加高级分析和缓存管理

    @author 骆言诗词编程团队
    @version 4.0 - 统一重构版本
    @since 2025-07-20 - 消除API模块重复，统一实现
    
    Fix #617 - 韵律API模块重复代码清理 *)

open Rhyme_types

(** {1 核心韵律检测API - 重新导出} *)

(** 查找字符的韵律信息 
    统一的韵律查找函数，替代项目中多处重复的find_rhyme_info实现 *)
let find_rhyme_info = Rhyme_api_core.find_rhyme_info

(** 检测字符的韵类 
    统一的韵类检测函数，替代项目中多处重复的detect_rhyme_category实现 *)
let detect_rhyme_category = Rhyme_api_core.detect_rhyme_category

(** 检测字符的韵组 
    统一的韵组检测函数，替代项目中多处重复的detect_rhyme_group实现 *)
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
let suggest_rhyming_chars char candidates = Rhyme_advanced_analysis.suggest_rhyming_chars char candidates

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

(** {1 缓存管理API - 重新导出} *)

(** 清空韵律缓存 *)
let clear_cache = Rhyme_cache.clear_cache

(** 获取缓存统计信息 *)
let get_cache_statistics = Rhyme_cache.get_cache_stats

(** 预加载韵律数据 - 性能优化 *)
let preload_rhyme_data () =
  load_rhyme_data ();
  Yyocamlc_lib.Unified_logger.info "UnifiedRhymeAPI" "韵律数据预加载完成"

(** {1 批量处理API - 新增功能} *)

(** 批量查找字符的韵律信息
    一次性查找多个字符的韵律信息，提高批量处理效率 *)
let batch_find_rhyme_info chars =
  List.map (fun char -> (char, find_rhyme_info char)) chars

(** 批量检测韵律一致性
    检查多组字符列表的韵律一致性 *)
let batch_validate_rhyme_consistency char_groups =
  List.map (fun chars -> (chars, validate_rhyme_consistency chars)) char_groups

(** {1 高级分析功能 - 新增} *)

(** 获取韵律分析报告
    生成详细的韵律分析报告，包括统计信息和建议 *)
let get_rhyme_analysis_report text =
  let (categories, groups) = analyze_rhyme_pattern text in
  let buffer = Buffer.create 1024 in
  
  Buffer.add_string buffer "=== 韵律分析报告 ===\n";
  Buffer.add_string buffer (Printf.sprintf "文本长度: %d 字符\n" (String.length text));
  
  Buffer.add_string buffer "\n韵类分布:\n";
  List.iter (fun (category, count) ->
    let category_name = match category with
      | PingSheng -> "平声"
      | ShangSheng -> "上声"  
      | QuSheng -> "去声"
      | RuSheng -> "入声"
      | ZeSheng -> "仄声"
    in
    Buffer.add_string buffer (Printf.sprintf "  %s: %d\n" category_name count)
  ) categories;
  
  Buffer.add_string buffer "\n韵组分布:\n";
  List.iter (fun (group, count) ->
    let group_name = match group with
      | AnRhyme -> "安韵" | SiRhyme -> "思韵" | TianRhyme -> "天韵"
      | WangRhyme -> "望韵" | QuRhyme -> "去韵" | YuRhyme -> "鱼韵"
      | HuaRhyme -> "花韵" | FengRhyme -> "风韵" | YueRhyme -> "月韵"
      | JiangRhyme -> "江韵" | HuiRhyme -> "灰韵"
      | UnknownRhyme -> "未知韵"
    in
    Buffer.add_string buffer (Printf.sprintf "  %s: %d\n" group_name count)
  ) groups;
  
  Buffer.contents buffer

(** 验证韵律数据完整性
    检查韵律数据的完整性和一致性 *)
let validate_rhyme_data_integrity () =
  let (total_chars, total_groups) = get_cache_statistics () in
  let issues = ref [] in
  
  if total_chars = 0 then
    issues := "韵律字符缓存为空" :: !issues;
    
  if total_groups = 0 then
    issues := "韵组字符映射为空" :: !issues;
  
  match !issues with
  | [] -> 
    Yyocamlc_lib.Unified_logger.info "UnifiedRhymeAPI" "韵律数据完整性验证通过";
    true
  | issues ->
    List.iter (fun issue ->
      Yyocamlc_lib.Unified_logger.warning "UnifiedRhymeAPI" issue
    ) issues;
    false

(** 安全的韵律查找（带错误处理） *)
let safe_find_rhyme_info char =
  try
    find_rhyme_info char
  with e ->
    Yyocamlc_lib.Unified_logger.error "UnifiedRhymeAPI" 
      (Printf.sprintf "查找字符「%s」韵律信息时出错: %s" char (Printexc.to_string e));
    None

(** {1 兼容性函数和模块} *)

(** 向后兼容的函数别名模块 *)
module Legacy = struct
  let find_rhyme = find_rhyme_info
  let get_rhyme_info = find_rhyme_info
  let rhyme_detection = detect_rhyme_category
  let rhyme_group_detection = detect_rhyme_group
  let is_same_rhyme = check_rhyme
  let validate_rhyme = validate_rhyme_consistency
end

(** {1 初始化和入口函数} *)

(** 初始化函数 - 供外部模块调用
    预加载韵律数据，确保系统就绪 *)
let initialize () = 
  preload_rhyme_data ();
  let integrity_ok = validate_rhyme_data_integrity () in
  if integrity_ok then
    Yyocamlc_lib.Unified_logger.info "UnifiedRhymeAPI" "统一韵律API初始化完成"
  else
    Yyocamlc_lib.Unified_logger.warning "UnifiedRhymeAPI" "统一韵律API初始化完成，但存在数据完整性警告"