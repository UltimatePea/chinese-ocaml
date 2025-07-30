(* 艺术数据查询引擎模块 *)

open Artistic_core_types
open Artistic_data_parser
open Unified_data_engine

(** {1 数据源名称和查询配置} *)

let word_info_source = "artistic_word_info"
let evaluation_standards_source = "artistic_evaluation_standards"
let templates_source = "artistic_templates"

(** {1 基础查询功能} *)

let lookup_word_info (word : string) : word_info option =
  match Unified_data_engine.load_json_data word_info_source with
  | Success json ->
      let word_info_list = parse_word_info_from_json json in
      (try Some (List.assoc word word_info_list) 
       with Not_found -> None)
  | Failure _ -> None

let get_words_by_condition (condition : word_info -> bool) : string list =
  match Unified_data_engine.load_json_data word_info_source with
  | Success json ->
      let word_info_list = parse_word_info_from_json json in
      List.filter_map (fun (word, info) ->
        if condition info then Some word else None
      ) word_info_list
  | Failure _ -> []

(** {1 公共查询接口} *)

let get_word_info (word : string) : word_info query_result =
  match lookup_word_info word with
  | Some info -> Found info
  | None -> NotFound

let get_words_by_category (category : word_category) : string list query_result =
  try
    let words = get_words_by_condition (fun info -> info.category = category) in
    if words = [] then NotFound else Found words
  with exn ->
    QueryError ("查询类别词汇失败: " ^ Printexc.to_string exn)

let search_words_by_pattern (pattern : string) : string list query_result =
  try
    let pattern_regex = Str.regexp pattern in
    let words = get_words_by_condition (fun info ->
      Str.string_match pattern_regex info.word 0
    ) in
    if words = [] then NotFound else Found words
  with exn ->
    QueryError ("模式搜索失败: " ^ Printexc.to_string exn)

let take n lst =
  let rec aux acc n = function
    | [] -> List.rev acc
    | x :: xs when n > 0 -> aux (x :: acc) (n - 1) xs
    | _ -> List.rev acc
  in
  aux [] n lst

let get_high_value_words (category : word_category) (limit : int) : (string * float) list query_result =
  match Unified_data_engine.load_json_data word_info_source with
  | Success json ->
      let parsed_word_info : (string * word_info) list = parse_word_info_from_json json in
      let category_words = List.filter (fun (_, (info : word_info)) -> info.category = category) parsed_word_info in
      let sorted_words = List.sort (fun (_, info1) (_, info2) -> 
        compare info2.artistic_value info1.artistic_value
      ) category_words in
      let limited_words = take (min limit (List.length sorted_words)) sorted_words in
      let result = List.map (fun (word, info) -> (word, info.artistic_value)) limited_words in
      if result = [] then NotFound else Found result
  | Failure err ->
      QueryError ("获取高价值词汇失败: " ^ Unified_data_engine.format_error err)

(** {1 评价标准查询} *)

let get_evaluation_standards (dimension : evaluation_dimension) : evaluation_standard list query_result =
  match Unified_data_engine.load_json_data evaluation_standards_source with
  | Success json ->
      let standards_list = parse_evaluation_standards_from_json json in
      (try
        Found (List.assoc dimension standards_list)
      with Not_found -> NotFound)
  | Failure err ->
      QueryError ("获取评价标准失败: " ^ Unified_data_engine.format_error err)

(** {1 艺术模板查询} *)

let get_artistic_templates (category : word_category) : artistic_template list query_result =
  match Unified_data_engine.load_json_data templates_source with
  | Success json ->
      let templates_list = parse_artistic_templates_from_json json in
      (try
        Found (List.assoc category templates_list)
      with Not_found -> NotFound)
  | Failure err ->
      QueryError ("获取艺术模板失败: " ^ Unified_data_engine.format_error err)

(** {1 数据统计查询} *)

let get_word_category_statistics () : (word_category * int) list query_result =
  match Unified_data_engine.load_json_data word_info_source with
  | Success json ->
      let word_info_list : (string * word_info) list = parse_word_info_from_json json in
      let categories = List.map (fun (_, (info : word_info)) -> info.category) word_info_list in
      let category_counts = Hashtbl.create 8 in
      List.iter (fun category ->
        let current_count = try Hashtbl.find category_counts category with Not_found -> 0 in
        Hashtbl.replace category_counts category (current_count + 1)
      ) categories;
      
      let stats = Hashtbl.fold (fun category count acc -> (category, count) :: acc) category_counts [] in
      Found stats
  | Failure err ->
      QueryError ("获取词汇类别统计失败: " ^ Unified_data_engine.format_error err)