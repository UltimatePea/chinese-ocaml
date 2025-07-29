(** 韵律分析模块 - 提供韵律兼容性检查和模式分析功能
    
    从rhyme_data_unified.ml重构而来，专注于韵律兼容性分析、
    模式识别和建议生成，实现智能的韵律分析功能。
                                                           
    @author Alpha, 主要工作代理 - 负责功能实现和技术债务处理
    @version 3.0 - 模块化重构版本
    @since 2025-07-29 - 基于issue #1662的模块化重构
    @parent_module rhyme_data_unified.ml *)

open Rhyme_data_core

(** {1 韵律兼容性检查} *)

let check_rhyme_compatibility char1 char2 =
  let cache_key = if char1 < char2 then char1 ^ "|" ^ char2 else char2 ^ "|" ^ char1 in

  match Hashtbl.find_opt compatibility_cache cache_key with
  | Some result ->
      performance_stats :=
        { !performance_stats with cache_hits = !performance_stats.cache_hits + 1 };
      RhymeSuccess result
  | None ->
      let result =
        match
          ( Hashtbl.find_opt character_rhyme_index char1,
            Hashtbl.find_opt character_rhyme_index char2 )
        with
        | Some item1, Some item2 -> item1.rhyme_group = item2.rhyme_group
        | _ -> false
      in
      Hashtbl.replace compatibility_cache cache_key result;
      RhymeSuccess result

let check_multi_character_compatibility char_list =
  let rec check_pairs = function
    | [] | [_] -> RhymeSuccess true
    | char1 :: (char2 :: _ as rest) ->
        (match check_rhyme_compatibility char1 char2 with
        | RhymeSuccess true -> check_pairs (char2 :: rest)
        | RhymeSuccess false -> RhymeSuccess false
        | error -> error)
  in
  check_pairs char_list

(** {1 韵律字符查找和建议} *)

let find_rhyming_characters char ?(max_results = -1) () =
  match Hashtbl.find_opt character_rhyme_index char with
  | Some item -> (
      match Hashtbl.find_opt rhyme_group_index item.rhyme_group with
      | Some char_list ->
          let rhyming_chars = List.filter (fun c -> c <> char) char_list in
          let limited_results =
            if max_results > 0 then
              let rec take n lst acc =
                if n <= 0 || lst = [] then List.rev acc
                else take (n - 1) (List.tl lst) (List.hd lst :: acc)
              in
              take max_results rhyming_chars []
            else rhyming_chars
          in
          RhymeSuccess limited_results
      | None -> RhymeSuccess [])
  | None -> RhymeSuccess []

let suggest_rhyme_alternatives char =
  match find_rhyming_characters char ~max_results:10 () with
  | RhymeSuccess rhyming_chars ->
      let alternatives = List.map (fun c -> (c, 0.9)) rhyming_chars in
      RhymeSuccess alternatives
  | RhymeError err -> RhymeError err
  | RhymeWarning (chars, warn) -> RhymeWarning (List.map (fun c -> (c, 0.9)) chars, warn)

let suggest_rhyme_alternatives_by_tone char target_tone =
  match find_rhyming_characters char () with
  | RhymeSuccess rhyming_chars ->
      let filtered_chars = 
        List.filter_map (fun c ->
          match Hashtbl.find_opt character_rhyme_index c with
          | Some item when item.tone = target_tone -> Some (c, 0.95)
          | Some _ -> Some (c, 0.7)  (* 同韵但不同声调，优先级稍低 *)
          | None -> None
        ) rhyming_chars
      in
      RhymeSuccess filtered_chars
  | error -> error

(** {1 韵律模式分析} *)

let analyze_rhyme_pattern char_list =
  let group_map = Hashtbl.create 20 in

  List.iter
    (fun char ->
      match Hashtbl.find_opt character_rhyme_index char with
      | Some item ->
          let existing =
            match Hashtbl.find_opt group_map item.rhyme_group with Some lst -> lst | None -> []
          in
          Hashtbl.replace group_map item.rhyme_group (char :: existing)
      | None -> ())
    char_list;

  let patterns =
    Hashtbl.fold (fun group chars acc -> (group, List.rev chars) :: acc) group_map []
  in

  RhymeSuccess patterns

let analyze_tone_pattern char_list =
  let tone_counts = Hashtbl.create 4 in
  
  List.iter (fun char ->
    match Hashtbl.find_opt character_rhyme_index char with
    | Some item ->
        let count = match Hashtbl.find_opt tone_counts item.tone with
          | Some n -> n + 1
          | None -> 1
        in
        Hashtbl.replace tone_counts item.tone count
    | None -> ()
  ) char_list;
  
  let pattern = Hashtbl.fold (fun tone count acc -> (tone, count) :: acc) tone_counts [] in
  RhymeSuccess pattern

let detect_rhyme_scheme char_list =
  (* 简化实现：检测AABA、ABAB等韵律格式 *)
  match analyze_rhyme_pattern char_list with
  | RhymeSuccess patterns ->
      let scheme = 
        List.mapi (fun i char ->
          let group = List.find_opt (fun (_, chars) -> List.mem char chars) patterns in
          match group with
          | Some (g, _) -> Some (i, g)
          | None -> None
        ) char_list
        |> List.filter_map (fun x -> x)
      in
      RhymeSuccess scheme
  | error -> error

(** {1 韵律质量评估} *)

type rhyme_quality_metrics = {
  consistency_score : float;
  tone_diversity : int;
  quality_score : float;
  rhyme_groups : int;
}

let evaluate_rhyme_quality char_list =
  match analyze_rhyme_pattern char_list with
  | RhymeSuccess patterns ->
      let total_chars = List.length char_list in
      let rhyming_chars = List.fold_left (fun acc (_, chars) -> acc + List.length chars) 0 patterns in
      let consistency_score = float_of_int rhyming_chars /. float_of_int total_chars in
      
      let tone_diversity = 
        match analyze_tone_pattern char_list with
        | RhymeSuccess tone_pattern -> List.length tone_pattern
        | _ -> 0
      in
      
      let quality_score = consistency_score *. (1.0 +. float_of_int tone_diversity /. 4.0) in
      RhymeSuccess {
        consistency_score;
        tone_diversity;
        quality_score;
        rhyme_groups = List.length patterns;
      }
  | error -> error

(** {1 韵律建议生成} *)

let generate_rhyme_suggestions base_char char_list max_suggestions =
  match find_rhyming_characters base_char () with
  | RhymeSuccess candidates ->
      (* 过滤掉已经在列表中的字符 *)
      let available_candidates = List.filter (fun c -> not (List.mem c char_list)) candidates in
      
      (* 根据与现有字符的兼容性排序 *)
      let scored_candidates = List.map (fun candidate ->
        let compatibility_score = 
          List.fold_left (fun acc existing_char ->
            match check_rhyme_compatibility candidate existing_char with
            | RhymeSuccess true -> acc +. 1.0
            | _ -> acc
          ) 0.0 char_list
        in
        (candidate, compatibility_score /. float_of_int (List.length char_list))
      ) available_candidates in
      
      let sorted_candidates = List.sort (fun (_, s1) (_, s2) -> compare s2 s1) scored_candidates in
      let limited_suggestions = 
        if max_suggestions > 0 then
          let rec take n lst acc =
            if n <= 0 || lst = [] then List.rev acc
            else take (n - 1) (List.tl lst) (List.hd lst :: acc)
          in
          take max_suggestions sorted_candidates []
        else sorted_candidates
      in
      
      RhymeSuccess limited_suggestions
  | error -> error