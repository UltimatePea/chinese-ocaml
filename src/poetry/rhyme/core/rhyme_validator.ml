(** 骆言诗词韵律验证模块 - 韵律规则验证引擎
    
    Author: Whisky, PR Worker Agent - Poetry架构整合Phase 2
    Issue: #2084 Poetry模块架构整合计划
    
    此模块整合了韵律验证相关功能，提供统一的韵律规则验证接口。
    
    整合来源：
    - rhyme_validation.ml
    - poetry_standards.ml  
    - 各种分散的验证逻辑
    
    @version 1.0 - 统一韵律验证器
    @since 2025-08-03 *)

open Poetry_core.Types

(** === 验证结果类型 === *)

type validation_result = {
  is_valid : bool;
  score : float;
  issues : string list;
  suggestions : string list;
}

(** === 验证配置 === *)

type validation_config = {
  strict_rhyme_matching : bool;  (** 严格韵律匹配 *)
  allow_approximate_rhyme : bool; (** 允许近似押韵 *)
  tonal_balance_required : bool; (** 要求声调平衡 *)
  parallelism_check : bool; (** 检查对仗 *)
  min_confidence : float; (** 最小置信度 *)
}

let default_validation_config = {
  strict_rhyme_matching = false;
  allow_approximate_rhyme = true;  
  tonal_balance_required = true;
  parallelism_check = true;
  min_confidence = 0.6;
}

(** === 韵律规则验证 === *)

(* 验证韵脚是否合规 *)
let validate_rhyme_endings verses =
  let endings = List.filter_map (fun verse ->
    if String.length verse > 0 then
      let chars = String.split_on_char ' ' verse |> List.filter (fun s -> s <> "") in
      match List.rev chars with
      | last :: _ -> Some last
      | [] -> None
    else None
  ) verses in
  
  let rhyme_groups = List.filter_map (fun ending ->
    match Rhyme_engine.find_character_rhyme ending with
    | Some info -> Some info.rhyme_group
    | None -> None
  ) endings in
  
  let unique_groups = List.sort_uniq compare rhyme_groups in
  let consistency = 
    if List.length rhyme_groups = 0 then 0.0
    else 1.0 -. (float_of_int (List.length unique_groups) /. float_of_int (List.length rhyme_groups)) in
  
  {
    is_valid = consistency >= 0.5;
    score = consistency;
    issues = if consistency < 0.5 then ["韵脚不够一致"] else [];
    suggestions = if consistency < 0.8 then ["建议使用同一韵组的字作为韵脚"] else [];
  }

(* 验证声调平衡 *)
let validate_tonal_balance verses =
  let all_tones = List.fold_left (fun acc verse ->
    let chars = String.split_on_char ' ' verse |> List.filter (fun s -> s <> "") in
    let tones = List.filter_map (fun char ->
      match Rhyme_engine.find_character_rhyme char with
      | Some info -> Some (is_ping_sheng info.rhyme_category)
      | None -> None
    ) chars in
    tones @ acc
  ) [] verses in
  
  let ping_count = List.length (List.filter (fun x -> x) all_tones) in
  let ze_count = List.length (List.filter (fun x -> not x) all_tones) in
  let total = ping_count + ze_count in
  
  let balance_ratio = if total = 0 then 0.0 
    else abs_float (float_of_int ping_count /. float_of_int total -. 0.5) in
  let balance_score = 1.0 -. balance_ratio *. 2.0 in
  
  {
    is_valid = balance_score >= 0.3;
    score = balance_score;
    issues = if balance_score < 0.5 then ["声调平衡不够"] else [];
    suggestions = if balance_score < 0.7 then ["建议增加平仄搭配的变化"] else [];
  }

(* 验证对仗工整 *)
let validate_parallelism verses =
  (* 简化的对仗检查：检查相邻句子的结构相似性 *)
  let pairs = List.fold_left2 (fun acc v1 v2 ->
    let len1 = String.length v1 in
    let len2 = String.length v2 in
    let length_match = abs (len1 - len2) <= 1 in
    (length_match, v1, v2) :: acc
  ) [] verses (List.tl verses @ [List.hd verses]) in
  
  let matching_pairs = List.filter (fun (match_result, _, _) -> match_result) pairs in
  let parallelism_score = 
    if List.length pairs = 0 then 0.0
    else float_of_int (List.length matching_pairs) /. float_of_int (List.length pairs) in
  
  {
    is_valid = parallelism_score >= 0.5;
    score = parallelism_score;
    issues = if parallelism_score < 0.6 then ["对仗不够工整"] else [];
    suggestions = if parallelism_score < 0.8 then ["建议调整句子结构，使相邻句子字数相近"] else [];
  }

(** === 诗体格式验证 === *)

(* 验证五言律诗格式 *)
let validate_wuyan_lushi verses =
  let line_count_valid = List.length verses = 8 in
  let char_count_valid = List.for_all (fun verse ->
    let chars = String.split_on_char ' ' verse |> List.filter (fun s -> s <> "") in
    List.length chars = 5
  ) verses in
  
  let rhyme_validation = validate_rhyme_endings verses in
  let tonal_validation = validate_tonal_balance verses in
  
  {
    is_valid = line_count_valid && char_count_valid && rhyme_validation.is_valid;
    score = (if line_count_valid then 0.3 else 0.0) +. 
            (if char_count_valid then 0.3 else 0.0) +. 
            rhyme_validation.score *. 0.4;
    issues = (if not line_count_valid then ["不是八句"] else []) @
             (if not char_count_valid then ["不是五言"] else []) @
             rhyme_validation.issues;
    suggestions = rhyme_validation.suggestions @ tonal_validation.suggestions;
  }

(* 验证七言绝句格式 *)
let validate_qiyan_jueju verses =
  let line_count_valid = List.length verses = 4 in
  let char_count_valid = List.for_all (fun verse ->
    let chars = String.split_on_char ' ' verse |> List.filter (fun s -> s <> "") in
    List.length chars = 7
  ) verses in
  
  let rhyme_validation = validate_rhyme_endings verses in
  
  {
    is_valid = line_count_valid && char_count_valid && rhyme_validation.is_valid;
    score = (if line_count_valid then 0.4 else 0.0) +. 
            (if char_count_valid then 0.4 else 0.0) +. 
            rhyme_validation.score *. 0.2;
    issues = (if not line_count_valid then ["不是四句"] else []) @
             (if not char_count_valid then ["不是七言"] else []) @
             rhyme_validation.issues;
    suggestions = rhyme_validation.suggestions;
  }

(* 验证四言骈体格式 *)
let validate_siyan_pianti verses =
  let char_count_valid = List.for_all (fun verse ->
    let chars = String.split_on_char ' ' verse |> List.filter (fun s -> s <> "") in
    List.length chars = 4
  ) verses in
  
  let parallelism_validation = validate_parallelism verses in
  let tonal_validation = validate_tonal_balance verses in
  
  {
    is_valid = char_count_valid && parallelism_validation.is_valid;
    score = (if char_count_valid then 0.4 else 0.0) +. 
            parallelism_validation.score *. 0.3 +.
            tonal_validation.score *. 0.3;
    issues = (if not char_count_valid then ["不是四言"] else []) @
             parallelism_validation.issues @
             tonal_validation.issues;
    suggestions = parallelism_validation.suggestions @ tonal_validation.suggestions;
  }

(** === 综合验证接口 === *)

(* 根据诗体类型进行验证 *)
let validate_by_form verses form =
  match form with
  | WuYanLuShi -> validate_wuyan_lushi verses
  | QiYanJueJu -> validate_qiyan_jueju verses  
  | SiYanPianTi -> validate_siyan_pianti verses
  | CiPai _ -> {
      is_valid = true;
      score = 0.8;
      issues = [];
      suggestions = ["词牌格式验证暂未实现"];
    }
  | ModernPoetry -> {
      is_valid = true;
      score = 1.0;
      issues = [];
      suggestions = ["现代诗无格律限制"];
    }
  | SiYanParallelProse -> validate_siyan_pianti verses

(* 自动检测诗体并验证 *)
let auto_validate verses =
  let line_count = List.length verses in
  let first_line_chars = match verses with
    | verse :: _ -> 
      let chars = String.split_on_char ' ' verse |> List.filter (fun s -> s <> "") in
      List.length chars
    | [] -> 0 in
  
  let detected_form = match line_count, first_line_chars with
    | 8, 5 -> Some WuYanLuShi
    | 4, 7 -> Some QiYanJueJu
    | _, 4 -> Some SiYanPianTi
    | _ -> None in
  
  match detected_form with
  | Some form -> 
    let validation = validate_by_form verses form in
    Success (form, validation)
  | None -> 
    let general_validation = {
      is_valid = List.length verses > 0;
      score = 0.5;
      issues = ["无法识别诗体格式"];
      suggestions = ["请检查诗句数量和字数是否符合常见格律"];
    } in
    Partial ((ModernPoetry, general_validation), [general_validation.issues |> String.concat "; "])

(** === 验证报告生成 === *)

type validation_report = {
  overall_valid : bool;
  overall_score : float;
  detected_form : poetry_form option;
  rhyme_validation : validation_result;
  tonal_validation : validation_result; 
  structure_validation : validation_result;
  recommendations : string list;
}


(* 生成完整的验证报告 *)
let generate_validation_report verses =
  let rhyme_val = validate_rhyme_endings verses in
  let tonal_val = validate_tonal_balance verses in
  let parallelism_val = validate_parallelism verses in
  
  let overall_score = (rhyme_val.score +. tonal_val.score +. parallelism_val.score) /. 3.0 in
  let overall_valid = rhyme_val.is_valid && tonal_val.is_valid && parallelism_val.is_valid in
  
  let recommendations = 
    rhyme_val.suggestions @ tonal_val.suggestions @ parallelism_val.suggestions
    |> List.sort_uniq compare in
  
  {
    overall_valid = overall_valid;
    overall_score = overall_score;
    detected_form = (match auto_validate verses with
      | Success (form, _) -> Some form
      | _ -> None);
    rhyme_validation = rhyme_val;
    tonal_validation = tonal_val;
    structure_validation = parallelism_val;
    recommendations = recommendations;
  }