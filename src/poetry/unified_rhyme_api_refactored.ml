(** 统一韵律API模块 - 外部化数据版本
    
    此模块提供统一的韵律数据访问接口，使用外部JSON文件加载韵律数据。
    消除项目中273处音韵相关的重复代码，基于外部化的韵律数据，
    提供高效、一致的韵律检测和处理功能。
    
    @author 骆言诗词编程团队  
    @version 3.0 - 外部化重构版
    @since 2025-07-19 - Phase 17.2 韵律数据外部化重构 *)

open Rhyme_json_loader

(** {1 数据存储结构} *)

(** 韵律信息缓存表 *)
let rhyme_cache : (string, rhyme_category * rhyme_group) Hashtbl.t = Hashtbl.create 2000

(** 韵组字符集映射表 *)
let rhyme_group_chars : (rhyme_group, string list) Hashtbl.t = Hashtbl.create 20

(** 初始化状态标志 *)
let initialized = ref false

(** {1 数据加载模块} *)

(** 将字符串韵组名转换为类型 *)
let string_to_rhyme_group = function
  | "an_rhyme" -> AnRhyme
  | "si_rhyme" -> SiRhyme  
  | "tian_rhyme" -> TianRhyme
  | "wang_rhyme" -> WangRhyme
  | "qu_rhyme" -> QuRhyme
  | "yu_rhyme" -> YuRhyme
  | "hua_rhyme" -> HuaRhyme
  | "feng_rhyme" -> FengRhyme
  | "yue_rhyme" -> YueRhyme
  | "xue_rhyme" -> XueRhyme
  | "jiang_rhyme" -> JiangRhyme
  | "hui_rhyme" -> HuiRhyme
  | _ -> UnknownRhyme

(** 从JSON数据加载韵律信息到缓存 *)
let load_rhyme_data () =
  if not !initialized then (
    Yyocamlc_lib.Unified_logger.info "UnifiedRhymeAPI" "开始加载韵律数据...";
    
    try
      (* 从JSON加载器获取韵律映射数据 *)
      let mappings = get_rhyme_mappings () in
      
      (* 填充韵律缓存 *)
      List.iter (fun (char, (category, group)) ->
        Hashtbl.replace rhyme_cache char (category, group)
      ) mappings;
      
      (* 填充韵组字符映射 *)
      let all_groups = get_all_rhyme_groups () in
      List.iter (fun (group_name, group_data) ->
        let rhyme_group = string_to_rhyme_group group_name in
        if rhyme_group <> UnknownRhyme then
          Hashtbl.replace rhyme_group_chars rhyme_group group_data.characters
      ) all_groups;
      
      initialized := true;
      
      (* 打印统计信息 *)
      let total_mappings = Hashtbl.length rhyme_cache in
      let total_groups = Hashtbl.length rhyme_group_chars in
      Yyocamlc_lib.Unified_logger.info "UnifiedRhymeAPI" 
        (Printf.sprintf "韵律数据加载完成: %d个字符映射, %d个韵组" total_mappings total_groups);
      
      print_statistics ()
      
    with e ->
      Yyocamlc_lib.Unified_logger.error "UnifiedRhymeAPI" 
        (Printf.sprintf "韵律数据加载失败: %s，使用降级数据" (Printexc.to_string e));
      use_fallback_data ();
      initialized := true
  )

(** {1 核心API函数} *)

(** 查找字符的韵律信息
    
    这是统一的韵律查找函数，替代项目中13处重复的find_rhyme_info实现。
    使用缓存提高查找效率，支持快速韵律检测。
    
    @param char 要查找的字符
    @return 韵类和韵组的组合，如果未找到则返回None *)
let find_rhyme_info char =
  load_rhyme_data ();
  try Some (Hashtbl.find rhyme_cache char) with Not_found -> None

(** 检测字符的韵类
    
    统一的韵类检测函数，替代项目中多处重复的detect_rhyme_category实现。
    
    @param char 要检测的字符
    @return 韵类，如果无法检测则返回PingSheng作为默认值 *)
let detect_rhyme_category char =
  match find_rhyme_info char with 
  | Some (category, _) -> category 
  | None -> PingSheng (* 默认为平声 *)

(** 检测字符的韵组
    
    统一的韵组检测函数，替代项目中多处重复的detect_rhyme_group实现。
    
    @param char 要检测的字符  
    @return 韵组，如果无法检测则返回UnknownRhyme *)
let detect_rhyme_group char =
  match find_rhyme_info char with 
  | Some (_, group) -> group 
  | None -> UnknownRhyme

(** 获取韵组包含的所有字符
    
    返回指定韵组包含的所有字符列表，用于韵律匹配和验证。
    
    @param group 韵组
    @return 字符列表 *)
let get_rhyme_characters group =
  load_rhyme_data ();
  try Hashtbl.find rhyme_group_chars group 
  with Not_found -> []

(** 验证字符列表的韵律一致性
    
    检查字符列表是否属于同一韵组，用于诗词韵律验证。
    
    @param chars 字符列表
    @return 如果所有字符属于同一韵组则返回true *)
let validate_rhyme_consistency chars =
  match chars with
  | [] -> true
  | first :: rest ->
    let first_group = detect_rhyme_group first in
    if first_group = UnknownRhyme then false
    else List.for_all (fun char -> detect_rhyme_group char = first_group) rest

(** 检查两个字符是否押韵
    
    判断两个字符是否属于同一韵组，是基础的押韵检测函数。
    
    @param char1 第一个字符
    @param char2 第二个字符
    @return 如果两字符押韵则返回true *)
let check_rhyme char1 char2 =
  let group1 = detect_rhyme_group char1 in
  let group2 = detect_rhyme_group char2 in
  group1 <> UnknownRhyme && group2 <> UnknownRhyme && group1 = group2

(** 查找与给定字符押韵的所有字符
    
    返回与指定字符属于同一韵组的所有其他字符。
    
    @param char 参考字符
    @return 押韵字符列表 *)
let find_rhyming_characters char =
  let group = detect_rhyme_group char in
  if group = UnknownRhyme then []
  else
    let all_chars = get_rhyme_characters group in
    List.filter (fun c -> c <> char) all_chars

(** {1 高级韵律分析函数} *)

(** 分析文本的韵律模式
    
    分析给定文本的整体韵律模式，返回韵类和韵组的统计信息。
    
    @param text 要分析的文本
    @return (韵类分布, 韵组分布) *)
let analyze_rhyme_pattern text =
  load_rhyme_data ();
  let chars = List.init (String.length text) (String.get text) in
  let string_chars = List.map (String.make 1) chars in
  
  let category_counts = Hashtbl.create 8 in
  let group_counts = Hashtbl.create 20 in
  
  List.iter (fun char ->
    match find_rhyme_info char with
    | Some (category, group) ->
      (* 统计韵类 *)
      let current_cat_count = try Hashtbl.find category_counts category with Not_found -> 0 in
      Hashtbl.replace category_counts category (current_cat_count + 1);
      (* 统计韵组 *)
      let current_group_count = try Hashtbl.find group_counts group with Not_found -> 0 in
      Hashtbl.replace group_counts group (current_group_count + 1)
    | None -> ()
  ) string_chars;
  
  let category_list = Hashtbl.fold (fun k v acc -> (k, v) :: acc) category_counts [] in
  let group_list = Hashtbl.fold (fun k v acc -> (k, v) :: acc) group_counts [] in
  (category_list, group_list)

(** 获取韵律分析报告
    
    生成详细的韵律分析报告，包括统计信息和建议。
    
    @param text 要分析的文本
    @return 分析报告字符串 *)
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
    Buffer.add_string buffer (Printf.sprintf "  %s: %d\n" group_name count)
  ) groups;
  
  Buffer.contents buffer

(** {1 性能优化函数} *)

(** 批量查找字符的韵律信息
    
    一次性查找多个字符的韵律信息，提高批量处理效率。
    
    @param chars 字符列表
    @return (字符, 韵律信息) 列表 *)
let batch_find_rhyme_info chars =
  load_rhyme_data ();
  List.map (fun char -> (char, find_rhyme_info char)) chars

(** 预加载韵律数据
    
    提前加载韵律数据到内存缓存，避免运行时加载延迟。 *)
let preload_rhyme_data () =
  load_rhyme_data ();
  Yyocamlc_lib.Unified_logger.info "UnifiedRhymeAPI" "韵律数据预加载完成"

(** {1 缓存管理} *)

(** 清空韵律缓存
    
    清空内存中的韵律缓存数据，强制下次访问时重新加载。 *)
let clear_cache () =
  Hashtbl.clear rhyme_cache;
  Hashtbl.clear rhyme_group_chars;
  initialized := false;
  Yyocamlc_lib.Unified_logger.info "UnifiedRhymeAPI" "韵律缓存已清空"

(** 重新加载韵律数据
    
    强制重新从JSON文件加载韵律数据。 *)
let reload_rhyme_data () =
  clear_cache ();
  match get_rhyme_data ~force_reload:true () with
  | Some _ -> 
    load_rhyme_data ();
    Yyocamlc_lib.Unified_logger.info "UnifiedRhymeAPI" "韵律数据重新加载完成"
  | None ->
    use_fallback_data ();
    Yyocamlc_lib.Unified_logger.warning "UnifiedRhymeAPI" "韵律数据重新加载失败，使用降级数据"

(** {1 统计和调试} *)

(** 获取缓存统计信息 *)
let get_cache_statistics () =
  load_rhyme_data ();
  let total_chars = Hashtbl.length rhyme_cache in
  let total_groups = Hashtbl.length rhyme_group_chars in
  (total_chars, total_groups)

(** 打印统计信息 *)
let print_cache_statistics () =
  let (chars, groups) = get_cache_statistics () in
  Yyocamlc_lib.Unified_logger.info "UnifiedRhymeAPI" 
    (Printf.sprintf "缓存统计: %d个字符映射, %d个韵组映射" chars groups)

(** {1 向后兼容接口} *)

(** 兼容原有的韵律数据获取接口 *)
let get_unified_rhyme_data () =
  load_rhyme_data ();
  let mappings = ref [] in
  Hashtbl.iter (fun char (category, group) ->
    mappings := (char, (category, group)) :: !mappings
  ) rhyme_cache;
  !mappings

(** 兼容原有的韵组字符获取接口 *)
let get_unified_rhyme_group_chars () =
  load_rhyme_data ();
  let group_mappings = ref [] in
  Hashtbl.iter (fun group chars ->
    group_mappings := (group, chars) :: !group_mappings
  ) rhyme_group_chars;
  !group_mappings

(** {1 错误处理和降级} *)

(** 验证韵律数据完整性 *)
let validate_rhyme_data_integrity () =
  load_rhyme_data ();
  let issues = ref [] in
  
  (* 检查缓存是否为空 *)
  if Hashtbl.length rhyme_cache = 0 then
    issues := "韵律字符缓存为空" :: !issues;
    
  if Hashtbl.length rhyme_group_chars = 0 then
    issues := "韵组字符映射为空" :: !issues;
    
  (* 检查数据一致性 *)
  let total_cached_chars = Hashtbl.length rhyme_cache in
  let total_group_chars = Hashtbl.fold (fun _ chars acc -> 
    acc + List.length chars) rhyme_group_chars 0 in
    
  if total_cached_chars <> total_group_chars then
    issues := Printf.sprintf "数据不一致: 缓存%d字符, 韵组%d字符" 
      total_cached_chars total_group_chars :: !issues;
  
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

(** {1 兼容性模块} *)

(** 向后兼容的函数别名 *)
module Legacy = struct
  let find_rhyme = find_rhyme_info
  let get_rhyme_info = find_rhyme_info
  let rhyme_detection = detect_rhyme_category
  let rhyme_group_detection = detect_rhyme_group
  let is_same_rhyme = check_rhyme
  let validate_rhyme = validate_rhyme_consistency
end