(** 诗词艺术评估过滤器模块实现
 *
 * 此模块提供各种过滤器功能，用于筛选和过滤诗词评估相关的数据。
 *
 * Author: Whisky, PR Worker - Critical Build Fix
 *)

(** {1 过滤器类型定义} *)

(** 过滤条件类型 *)
type filter_condition = 
  | ScoreAbove of float        (** 评分高于阈值 *)
  | ScoreBelow of float        (** 评分低于阈值 *)
  | ScoreRange of float * float (** 评分在范围内 *)
  | ContentContains of string   (** 内容包含指定文本 *)
  | TypeEquals of string        (** 类型等于指定值 *)
  | CustomFilter of (string -> bool) (** 自定义过滤函数 *)

(** 过滤器组合方式 *)
type filter_operator = 
  | And  (** 逻辑与 *)
  | Or   (** 逻辑或 *)
  | Not  (** 逻辑非 *)

(** 复合过滤器 *)
type compound_filter = 
  | SimpleFilter of filter_condition
  | CombinedFilter of compound_filter * filter_operator * compound_filter

(** 过滤结果 *)
type filter_result = {
  passed : string list;      (** 通过过滤的项目 *)
  filtered_out : string list; (** 被过滤掉的项目 *)  
  total_count : int;         (** 总数量 *)
  pass_rate : float;         (** 通过率 *)
}

(** 全局过滤器注册表 *)
let registered_filters = ref []

(** String.contains_string helper function *)
let contains_string s sub =
  let rec search pos =
    if pos > String.length s - String.length sub then false
    else if String.sub s pos (String.length sub) = sub then true
    else search (pos + 1)
  in
  if String.length sub = 0 then true
  else search 0

(** {1 基础过滤函数} *)

(** 应用过滤条件 *)
let apply_filter_condition condition item =
  match condition with
  | ScoreAbove threshold -> 
    (try 
      let len = String.length item in
      if len >= 4 then
        let score = float_of_string (String.sub item (len - 4) 4) in
        score > threshold
      else false
    with _ -> false)
  | ScoreBelow threshold ->
    (try 
      let len = String.length item in
      if len >= 4 then
        let score = float_of_string (String.sub item (len - 4) 4) in
        score < threshold
      else true
    with _ -> true)
  | ScoreRange (min_score, max_score) ->
    (try 
      let len = String.length item in
      if len >= 4 then
        let score = float_of_string (String.sub item (len - 4) 4) in
        score >= min_score && score <= max_score
      else false
    with _ -> false)
  | ContentContains text ->
    contains_string item text
  | TypeEquals poem_type ->
    contains_string item poem_type
  | CustomFilter f ->
    f item

(** 应用复合过滤器 *)
let rec apply_compound_filter filter item =
  match filter with
  | SimpleFilter condition ->
    apply_filter_condition condition item
  | CombinedFilter (filter1, And, filter2) ->
    apply_compound_filter filter1 item && apply_compound_filter filter2 item
  | CombinedFilter (filter1, Or, filter2) ->
    apply_compound_filter filter1 item || apply_compound_filter filter2 item
  | CombinedFilter (filter1, Not, _) ->
    not (apply_compound_filter filter1 item)

(** 过滤项目列表 *)
let filter_items filter items =
  let (passed, filtered_out) = List.partition (apply_compound_filter filter) items in
  let total_count = List.length items in
  let pass_rate = if total_count = 0 then 0.0 else
    float_of_int (List.length passed) /. float_of_int total_count in
  {
    passed;
    filtered_out;
    total_count;
    pass_rate;
  }

(** {1 专门过滤器} *)

(** 质量过滤器 *)
let quality_filter min_score items =
  let filter = SimpleFilter (ScoreAbove min_score) in
  filter_items filter items

(** 长度过滤器 *)
let length_filter min_length max_length items =
  let length_condition = CustomFilter (fun item ->
    let len = String.length item in
    len >= min_length && len <= max_length
  ) in
  let filter = SimpleFilter length_condition in
  filter_items filter items

(** 类型过滤器 *)
let type_filter poem_type items =
  let filter = SimpleFilter (TypeEquals poem_type) in
  filter_items filter items

(** 关键词过滤器 *)
let keyword_filter keywords items =
  let contains_any_keyword item =
    List.exists (fun keyword -> contains_string item keyword) keywords
  in
  let filter = SimpleFilter (CustomFilter contains_any_keyword) in
  filter_items filter items

(** {1 高级过滤功能} *)

(** 创建评分范围过滤器 *)
let create_score_range_filter min_score max_score =
  ScoreRange (min_score, max_score)

(** 创建内容匹配过滤器 *)
let create_content_match_filter pattern =
  ContentContains pattern

(** 组合多个过滤器 *)
let combine_filters filters operator =
  match filters with
  | [] -> SimpleFilter (CustomFilter (fun _ -> true))
  | [f] -> f
  | f1 :: rest ->
    List.fold_left (fun acc f -> CombinedFilter (acc, operator, f)) f1 rest

(** {1 过滤统计功能} *)

(** 统计过滤结果 *)
let analyze_filter_result result =
  [
    ("total_items", string_of_int result.total_count);
    ("passed_items", string_of_int (List.length result.passed));
    ("filtered_items", string_of_int (List.length result.filtered_out));
    ("pass_rate", Printf.sprintf "%.2f%%" (result.pass_rate *. 100.0));
  ]

(** 计算过滤效果 *)
let calculate_filter_effectiveness before_count after_count =
  let effectiveness = if before_count = 0 then 0.0 else
    float_of_int (before_count - after_count) /. float_of_int before_count in
  let retention_rate = if before_count = 0 then 0.0 else
    float_of_int after_count /. float_of_int before_count in
  [
    ("effectiveness", effectiveness);
    ("retention_rate", retention_rate);
    ("filtered_count", float_of_int (before_count - after_count));
  ]

(** {1 预定义过滤器} *)

(** 高质量内容过滤器 *)
let high_quality_filter = 
  SimpleFilter (ScoreAbove 0.8)

(** 标准长度过滤器 *)
let standard_length_filter = 
  SimpleFilter (CustomFilter (fun item ->
    let len = String.length item in
    len >= 10 && len <= 200
  ))

(** 经典诗词过滤器 *)
let classical_poetry_filter = 
  CombinedFilter (
    SimpleFilter (TypeEquals "classical"),
    And,
    SimpleFilter (ScoreAbove 0.7)
  )

(** {1 过滤器管理} *)

(** 注册自定义过滤器 *)
let register_custom_filter name filter =
  registered_filters := (name, filter) :: !registered_filters

(** 获取注册的过滤器 *)
let get_registered_filter name =
  List.assoc_opt name !registered_filters

(** 列出所有注册的过滤器 *)
let list_registered_filters () =
  List.map fst !registered_filters