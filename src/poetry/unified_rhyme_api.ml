(** 统一韵律API模块 - 完整统一版本

    此模块提供统一的韵律数据访问接口，整合各个专门模块的功能。 消除韵律API重复，提供单一入口点，使用模块化架构。

    重构策略：
    - 统一API入口：消除unified_rhyme_api_refactored.ml重复
    - 模块化设计：重新导出核心模块功能
    - 保持兼容性：支持所有现有接口
    - 增强功能：添加高级分析和缓存管理

    @author 骆言诗词编程团队
    @version 4.0 - 统一重构版本
    @since 2025-07-20 - 消除API模块重复，统一实现

    Fix #617 - 韵律API模块重复代码清理 *)

open Poetry_core.Poetry_types
open Yyocamlc_lib.Unified_formatter.PoetryFormatting

(** {1 核心韵律检测API - 重新导出} *)

(** 查找字符的韵律信息 统一的韵律查找函数，替代项目中多处重复的find_rhyme_info实现 *)
let find_rhyme_info = Rhyme_api_core.find_rhyme_info

(** 检测字符的韵类 统一的韵类检测函数，替代项目中多处重复的detect_rhyme_category实现 *)
let detect_rhyme_category = Rhyme_api_core.detect_rhyme_category

(** 检测字符的韵组 统一的韵组检测函数，替代项目中多处重复的detect_rhyme_group实现 *)
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

(** {1 高级韵律分析API - 直接实现} *)

(** 分析文本的韵律模式 *)
let analyze_rhyme_pattern text =
  Unified_rhyme_data.load_rhyme_data_to_cache ();
  let chars = List.init (String.length text) (String.get text) in
  let string_chars = List.map (String.make 1) chars in

  let category_counts = Hashtbl.create 10 in
  let group_counts = Hashtbl.create 20 in

  List.iter
    (fun char ->
      match Rhyme_api_core.find_rhyme_info char with
      | Some (category, group) ->
          let cat_count = try Hashtbl.find category_counts category with Not_found -> 0 in
          let grp_count = try Hashtbl.find group_counts group with Not_found -> 0 in
          Hashtbl.replace category_counts category (cat_count + 1);
          Hashtbl.replace group_counts group (grp_count + 1)
      | None -> ())
    string_chars;

  let category_list = Hashtbl.fold (fun k v acc -> (k, v) :: acc) category_counts [] in
  let group_list = Hashtbl.fold (fun k v acc -> (k, v) :: acc) group_counts [] in
  (category_list, group_list)

(** 获取韵律数据统计信息 *)
let get_rhyme_stats () =
  Unified_rhyme_data.load_rhyme_data_to_cache ();
  let total_chars, total_groups = Rhyme_cache.get_cache_stats_global () in

  let category_counts = Hashtbl.create 10 in
  let all_chars = Rhyme_cache.get_all_cached_chars_global () in

  List.iter
    (fun char ->
      match Rhyme_api_core.find_rhyme_info char with
      | Some (category, _) ->
          let count = try Hashtbl.find category_counts category with Not_found -> 0 in
          Hashtbl.replace category_counts category (count + 1)
      | None -> ())
    all_chars;

  let stats =
    [
      ("总字符数", total_chars);
      ("韵组数", total_groups);
      ("平声字符", try Hashtbl.find category_counts PingSheng with Not_found -> 0);
      ("仄声字符", try Hashtbl.find category_counts ZeSheng with Not_found -> 0);
    ]
  in
  stats

(** 分析诗句的韵律结构 *)
let analyze_poem_line_structure poem_line =
  let chars = List.init (String.length poem_line) (String.get poem_line) in
  let string_chars = List.map (String.make 1) chars in

  List.map
    (fun char ->
      let rhyme_info = Rhyme_api_core.find_rhyme_info char in
      let description = Rhyme_api_core.get_rhyme_description char in
      (char, rhyme_info, description))
    string_chars

(** 检测诗句间的押韵关系 *)
let detect_poem_rhyme_scheme poem_lines =
  let last_chars =
    List.map
      (fun line ->
        if String.length line > 0 then String.make 1 (String.get line (String.length line - 1))
        else "")
      poem_lines
  in

  let rhyme_groups = List.map Rhyme_api_core.detect_rhyme_group last_chars in

  let grouped = List.mapi (fun i group -> (i + 1, group)) rhyme_groups in

  let pattern =
    List.fold_left
      (fun acc (line_num, group) -> if group = UnknownRhyme then acc else (line_num, group) :: acc)
      [] grouped
  in

  List.rev pattern

(** 评估文本的韵律质量 *)
let evaluate_rhyme_quality text =
  let category_dist, group_dist = analyze_rhyme_pattern text in

  let total_rhyme_chars = List.fold_left (fun acc (_, count) -> acc + count) 0 category_dist in
  let total_chars = String.length text in

  let rhyme_coverage =
    if total_chars > 0 then float_of_int total_rhyme_chars /. float_of_int total_chars else 0.0
  in

  let group_diversity = float_of_int (List.length group_dist) /. 9.0 in

  let balance_score =
    if List.length category_dist >= 2 then
      let ping_count = try List.assoc PingSheng category_dist with Not_found -> 0 in
      let ze_count = try List.assoc ZeSheng category_dist with Not_found -> 0 in
      let total = ping_count + ze_count in
      if total > 0 then
        1.0 -. (abs_float ((float_of_int ping_count /. float_of_int total) -. 0.5) *. 2.0)
      else 0.0
    else 0.0
  in

  (rhyme_coverage *. 0.4) +. (group_diversity *. 0.3) +. (balance_score *. 0.3)

(** 建议押韵字符 *)
let suggest_rhyming_chars reference_char exclude_chars =
  let rhyming_chars = Rhyme_api_core.find_rhyming_characters reference_char in
  List.filter (fun char -> not (List.mem char exclude_chars)) rhyming_chars

(** {1 兼容性函数 - 从旧 Rhyme_analysis 模块迁移} *)

(** 字符串版本的韵类检测 *)
let detect_rhyme_category_by_string = Rhyme_matching.detect_rhyme_category_by_string

(** 提取韵尾 *)
let extract_rhyme_ending = Rhyme_pattern.extract_rhyme_ending

(** 生成韵律报告 *)
let generate_rhyme_report verse =
  let rhyme_ending_char = extract_rhyme_ending verse in
  let chars = List.init (String.length verse) (String.get verse) in
  let char_analysis =
    List.map
      (fun char ->
        let char_str = String.make 1 char in
        let category = detect_rhyme_category char_str in
        let group = detect_rhyme_group char_str in
        (char, category, group))
      chars
  in
  let dominant_rhyme_group =
    match rhyme_ending_char with
    | Some char -> detect_rhyme_group (String.make 1 char)
    | None -> UnknownRhyme
  in
  let dominant_rhyme_category =
    match rhyme_ending_char with
    | Some char -> detect_rhyme_category (String.make 1 char)
    | None -> ZeSheng
  in
  {
    verse;
    rhyme_ending = rhyme_ending_char;
    rhyme_group = dominant_rhyme_group;
    rhyme_category = dominant_rhyme_category;
    char_analysis;
  }

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
let clear_cache = Rhyme_cache.clear_cache_global

(** 获取缓存统计信息 *)
let get_cache_statistics = Rhyme_cache.get_cache_stats_global

(** 预加载韵律数据 - 性能优化 *)
let preload_rhyme_data () =
  load_rhyme_data ();
  Yyocamlc_lib.Unified_logger.info "UnifiedRhymeAPI" "韵律数据预加载完成"

(** {1 批量处理API - 新增功能} *)

(** 批量查找字符的韵律信息 一次性查找多个字符的韵律信息，提高批量处理效率 *)
let batch_find_rhyme_info chars = List.map (fun char -> (char, find_rhyme_info char)) chars

(** 批量检测韵律一致性 检查多组字符列表的韵律一致性 *)
let batch_validate_rhyme_consistency char_groups =
  List.map (fun chars -> (chars, validate_rhyme_consistency chars)) char_groups

(** {1 高级分析功能 - 新增} *)

(** 获取韵律分析报告 生成详细的韵律分析报告，包括统计信息和建议 *)
let get_rhyme_analysis_report text =
  let categories, groups = analyze_rhyme_pattern text in
  let buffer = Buffer.create 1024 in

  Buffer.add_string buffer "=== 韵律分析报告 ===\n";
  Buffer.add_string buffer (format_text_length_info (String.length text));

  Buffer.add_string buffer "\n韵类分布:\n";
  List.iter
    (fun (category, count) ->
      let category_name =
        match category with
        | PingSheng -> "平声"
        | ShangSheng -> "上声"
        | QuSheng -> "去声"
        | RuSheng -> "入声"
        | ZeSheng -> "仄声"
      in
      Buffer.add_string buffer (format_category_count category_name count))
    categories;

  Buffer.add_string buffer "\n韵组分布:\n";
  List.iter
    (fun (group, count) ->
      let group_name =
        match group with
        | AnRhyme -> "安韵"
        | SiRhyme -> "思韵"
        | TianRhyme -> "天韵"
        | WangRhyme -> "望韵"
        | QuRhyme -> "去韵"
        | YuRhyme -> "鱼韵"
        | HuaRhyme -> "花韵"
        | FengRhyme -> "风韵"
        | YueRhyme -> "月韵"
        | XueRhyme -> "雪韵"
        | JiangRhyme -> "江韵"
        | HuiRhyme -> "灰韵"
        | UnknownRhyme -> "未知韵"
      in
      Buffer.add_string buffer (format_rhyme_group_count group_name count))
    groups;

  Buffer.contents buffer

(** 验证韵律数据完整性 检查韵律数据的完整性和一致性 *)
let validate_rhyme_data_integrity () =
  let total_chars, total_groups = get_cache_statistics () in
  let issues = ref [] in

  if total_chars = 0 then issues := "韵律字符缓存为空" :: !issues;

  if total_groups = 0 then issues := "韵组字符映射为空" :: !issues;

  match !issues with
  | [] ->
      Yyocamlc_lib.Unified_logger.info "UnifiedRhymeAPI" "韵律数据完整性验证通过";
      true
  | issues ->
      List.iter (fun issue -> Yyocamlc_lib.Unified_logger.warning "UnifiedRhymeAPI" issue) issues;
      false

(** 安全的韵律查找（带错误处理） *)
let safe_find_rhyme_info char =
  try find_rhyme_info char
  with e ->
    Yyocamlc_lib.Unified_logger.error "UnifiedRhymeAPI"
      (format_character_lookup_error char (Printexc.to_string e));
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

(** 初始化函数 - 供外部模块调用 预加载韵律数据，确保系统就绪 *)
let initialize () =
  preload_rhyme_data ();
  let integrity_ok = validate_rhyme_data_integrity () in
  if integrity_ok then Yyocamlc_lib.Unified_logger.info "UnifiedRhymeAPI" "统一韵律API初始化完成"
  else Yyocamlc_lib.Unified_logger.warning "UnifiedRhymeAPI" "统一韵律API初始化完成，但存在数据完整性警告"
