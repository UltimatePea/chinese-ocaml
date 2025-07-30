(** 行数和字数检查器
    
    此模块负责验证诗句的行数和各行字数是否符合格律要求。
    从原 meter_engine.ml 中提取，专门负责行相关的检查功能。
    
    @author Alpha, 主要开发代理
    @version 1.0
    @since 2025-07-30
    @refactor_from meter_engine.ml (解决issue #1775技术债务) *)

open Meter_types

(** 行检查结果类型 *)
type line_check_result = {
  line_count_compliance : bool;
  line_length_compliance : bool list;
  line_count_violations : string list;
  line_length_violations : string list;
}

(** {1 行数检查} *)

(** 检查诗句行数是否符合要求 *)
let check_line_count verses pattern =
  let actual_count = List.length verses in
  let expected_count = pattern.required_lines in
  
  if expected_count = 0 then
    (true, [])  (* 不限制行数的诗体 *)
  else if actual_count = expected_count then
    (true, [])
  else
    let violation = Printf.sprintf "行数不符：期望%d行，实际%d行" expected_count actual_count in
    (false, [violation])

(** {1 字数检查} *)

(** 计算单行字符数 (考虑中文字符) *)
let count_chinese_chars line =
  let len = String.length line in
  let count = ref 0 in
  let i = ref 0 in
  while !i < len do
    let c = String.get line !i in
    if Char.code c >= 0x80 then (
      (* 可能是多字节UTF-8字符，简单按3字节一个中文字符处理 *)
      if !i + 2 < len then i := !i + 3 else i := !i + 1;
      incr count
    ) else (
      (* ASCII字符 *)
      incr i;
      if c <> ' ' && c <> '\t' && c <> '\n' && c <> '\r' then
        incr count
    )
  done;
  !count

(** 检查各行字数是否符合要求 *)
let check_line_lengths verses pattern =
  let expected_lengths = pattern.line_lengths in
  
  if List.length expected_lengths = 0 then
    (* 不限制字数的诗体 *)
    (List.map (fun _ -> true) verses, [])
  else
    let rec check_lines vs els violations compliances =
      match vs, els with
      | [], [] -> (List.rev compliances, List.rev violations)
      | [], _ -> (List.rev compliances, List.rev violations)
      | _, [] -> 
          (* 超出预期行数，但仍然检查 *)
          let vs_compliance = List.map (fun _ -> false) vs in
          let vs_violations = List.mapi (fun i _ -> 
            Printf.sprintf "第%d行：超出预期行数" (i + List.length compliances + 1)
          ) vs in
          (List.rev compliances @ vs_compliance, List.rev violations @ vs_violations)
      | v::vs_rest, el::els_rest ->
          let actual_length = count_chinese_chars v in
          if actual_length = el then
            check_lines vs_rest els_rest violations (true::compliances)
          else
            let violation = Printf.sprintf "第%d行字数不符：期望%d字，实际%d字" 
              (List.length compliances + 1) el actual_length in
            check_lines vs_rest els_rest (violation::violations) (false::compliances)
    in
    check_lines verses expected_lengths [] []

(** {1 综合行检查} *)

(** 执行所有行相关检查 *)
let check_all_line_requirements verses pattern =
  let (line_count_ok, line_count_violations) = check_line_count verses pattern in
  let (line_length_compliance, line_length_violations) = check_line_lengths verses pattern in
  
  {
    line_count_compliance = line_count_ok;
    line_length_compliance = line_length_compliance;
    line_count_violations = line_count_violations;
    line_length_violations = line_length_violations;
  }

(** {1 辅助功能} *)

(** 生成行数相关的改进建议 *)
let generate_line_suggestions line_count_violations line_length_violations =
  let suggestions = ref [] in
  
  if List.length line_count_violations > 0 then
    suggestions := "调整诗句行数以符合格律要求" :: !suggestions;
    
  if List.length line_length_violations > 0 then
    suggestions := "调整各行字数以符合格律模式" :: !suggestions;
    
  !suggestions

(** 计算行检查的符合度得分 *)
let calculate_line_compliance_score line_count_ok line_length_compliance =
  let line_count_score = if line_count_ok then 1.0 else 0.0 in
  let line_length_score = 
    if List.length line_length_compliance = 0 then 1.0
    else
      let compliant_count = List.fold_left (fun acc x -> if x then acc + 1 else acc) 0 line_length_compliance in
      float_of_int compliant_count /. float_of_int (List.length line_length_compliance)
  in
  (line_count_score +. line_length_score) /. 2.0