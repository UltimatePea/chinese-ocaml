(** 韵律高级分析模块
    
    提供高级的韵律分析功能，包括文本韵律模式分析、统计信息生成等。
    从unified_rhyme_api.ml重构而来。
    
    @author 骆言诗词编程团队
    @version 1.0
    @since 2025-07-19 - unified_rhyme_api.ml重构 *)

open Rhyme_types

(** {1 高级韵律分析函数} *)

(** 分析文本的韵律模式

    分析给定文本的整体韵律模式，返回韵类和韵组的统计信息。

    @param text 要分析的文本
    @return (韵类分布, 韵组分布) *)
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
  let (total_chars, total_groups) = Rhyme_cache.get_cache_stats () in

  let category_counts = Hashtbl.create 10 in
  let all_chars = Rhyme_cache.get_all_cached_chars () in
  
  List.iter (fun char ->
    match Rhyme_api_core.find_rhyme_info char with
    | Some (category, _) ->
        let count = try Hashtbl.find category_counts category with Not_found -> 0 in
        Hashtbl.replace category_counts category (count + 1)
    | None -> ()
  ) all_chars;

  let stats =
    [
      ("总字符数", total_chars);
      ("韵组数", total_groups);
      ("平声字符", try Hashtbl.find category_counts PingSheng with Not_found -> 0);
      ("仄声字符", try Hashtbl.find category_counts ZeSheng with Not_found -> 0);
    ]
  in
  stats

(** 分析诗句的韵律结构

    分析诗句中每个字符的韵律特征，返回结构化的韵律信息。

    @param poem_line 诗句
    @return 每个字符的韵律信息列表 *)
let analyze_poem_line_structure poem_line =
  let chars = List.init (String.length poem_line) (String.get poem_line) in
  let string_chars = List.map (String.make 1) chars in
  
  List.map (fun char ->
    let rhyme_info = Rhyme_api_core.find_rhyme_info char in
    let description = Rhyme_api_core.get_rhyme_description char in
    (char, rhyme_info, description)
  ) string_chars

(** 检测诗句间的押韵关系

    检测多个诗句之间的押韵模式，适用于律诗、绝句等格式。

    @param poem_lines 诗句列表
    @return 押韵关系分析结果 *)
let detect_poem_rhyme_scheme poem_lines =
  let last_chars = List.map (fun line ->
    if String.length line > 0 then
      String.make 1 (String.get line (String.length line - 1))
    else ""
  ) poem_lines in
  
  let rhyme_groups = List.map Rhyme_api_core.detect_rhyme_group last_chars in
  
  let grouped = List.mapi (fun i group -> (i + 1, group)) rhyme_groups in
  
  (* 分析押韵模式 *)
  let pattern = List.fold_left (fun acc (line_num, group) ->
    if group = UnknownRhyme then acc
    else (line_num, group) :: acc
  ) [] grouped in
  
  List.rev pattern

(** 评估文本的韵律质量

    综合评估文本的韵律质量，包括押韵一致性、韵律丰富度等指标。

    @param text 要评估的文本
    @return 韵律质量评分 (0.0 - 1.0) *)
let evaluate_rhyme_quality text =
  let (category_dist, group_dist) = analyze_rhyme_pattern text in
  
  let total_rhyme_chars = List.fold_left (fun acc (_, count) -> acc + count) 0 category_dist in
  let total_chars = String.length text in
  
  let rhyme_coverage = if total_chars > 0 then 
    float_of_int total_rhyme_chars /. float_of_int total_chars 
  else 0.0 in
  
  let group_diversity = float_of_int (List.length group_dist) /. 9.0 in (* 总共9个韵组 *)
  
  let balance_score = 
    if List.length category_dist >= 2 then
      let ping_count = try List.assoc PingSheng category_dist with Not_found -> 0 in
      let ze_count = try List.assoc ZeSheng category_dist with Not_found -> 0 in
      let total = ping_count + ze_count in
      if total > 0 then
        1.0 -. abs_float (float_of_int ping_count /. float_of_int total -. 0.5) *. 2.0
      else 0.0
    else 0.0
  in
  
  (* 综合评分：韵律覆盖度40% + 韵组多样性30% + 平仄平衡30% *)
  rhyme_coverage *. 0.4 +. group_diversity *. 0.3 +. balance_score *. 0.3

(** 建议押韵字符

    基于给定的字符，建议可能的押韵字符。

    @param reference_char 参考字符
    @param exclude_chars 要排除的字符列表
    @return 建议的押韵字符列表 *)
let suggest_rhyming_chars reference_char exclude_chars =
  let rhyming_chars = Rhyme_api_core.find_rhyming_characters reference_char in
  List.filter (fun char -> not (List.mem char exclude_chars)) rhyming_chars