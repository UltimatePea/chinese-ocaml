(** 骆言诗词数据加载模块

    此模块专门负责诗词艺术性评价所需的数据加载和文件处理功能。 从原poetry_artistic_core.ml模块中提取数据加载相关功能。

    主要功能：
    - 安全的文件读取
    - JSON数据解析
    - 词汇数据批量加载
    - 延迟加载机制

    Author: Beta, Code Reviewer
    @since 2025-07-25 - 技术债务重构Phase 3 *)

(** {1 文件读取辅助函数} *)

(** 安全的文件读取函数
    @param filepath 文件路径
    @return 文件内容的Option类型，读取失败返回None *)
let read_file_safely filepath =
  try
    let ic = open_in filepath in
    Fun.protect
      ~finally:(fun () -> close_in ic)
      (fun () -> Some (really_input_string ic (in_channel_length ic)))
  with
  | Sys_error _ -> None
  | _ -> None

(** {1 JSON解析辅助函数} *)

(** 在JSON内容中查找指定类别的words数组
    @param content JSON文件内容字符串
    @param category_name 类别名称
    @return 找到的JSON数组字符串的Option类型 *)
let find_json_section content category_name =
  let category_pattern = "\"" ^ category_name ^ "\"" in
  let words_pattern = "\"words\"" in
  try
    (* 查找类别位置 *)
    let category_pos = Str.search_forward (Str.regexp_string category_pattern) content 0 in
    (* 在类别后查找words字段 *)
    let words_pos = Str.search_forward (Str.regexp_string words_pattern) content category_pos in
    (* 查找数组开始和结束位置 *)
    let bracket_start = String.index_from content words_pos '[' in
    let rec find_matching_bracket pos depth =
      if pos >= String.length content then failwith "Unmatched bracket"
      else
        match content.[pos] with
        | '[' -> find_matching_bracket (pos + 1) (depth + 1)
        | ']' when depth = 1 -> pos
        | ']' -> find_matching_bracket (pos + 1) (depth - 1)
        | _ -> find_matching_bracket (pos + 1) depth
    in
    let bracket_end = find_matching_bracket bracket_start 0 in
    Some (String.sub content bracket_start (bracket_end - bracket_start + 1))
  with Not_found | Invalid_argument _ | Failure _ -> None

(** 从JSON内容中安全提取指定类别的词汇
    @param content JSON文件内容字符串
    @param category_name 类别名称
    @return 词汇字符串列表 *)
let extract_words_from_category content category_name =
  match find_json_section content category_name with
  | Some json_array -> (
      try Poetry_data.Poetry_json_parser.parse_string_array json_array with _ -> [])
  | None -> []

(** 支持的词汇数据类别列表 *)
let supported_categories =
  [
    "natural_imagery";
    "emotional_imagery";
    "cultural_imagery";
    "aesthetic_qualities";
    "dimensional_qualities";
  ]

(** {1 主要加载函数} *)

(** 从JSON文件加载词汇数组 - 重构版本

    此函数提供健壮的JSON数据加载机制，包含完整的错误处理和验证。 支持多种数据类别的批量提取，并提供降级处理能力。

    @param filepath JSON文件路径
    @return 所有类别词汇的合并数组，失败时返回空数组

    支持的数据类别：
    - natural_imagery: 自然意象词汇
    - emotional_imagery: 情感意象词汇
    - cultural_imagery: 文化意象词汇
    - aesthetic_qualities: 美学品质词汇
    - dimensional_qualities: 空间维度词汇 *)
let load_words_from_json_file filepath =
  match read_file_safely filepath with
  | Some content ->
      (* 批量提取所有类别 *)
      List.fold_left
        (fun acc category ->
          let words = extract_words_from_category content category in
          words @ acc)
        [] supported_categories
  | None -> []

(** {1 延迟加载数据} *)

(** 延迟加载的意象关键词库 *)
let imagery_keywords =
  lazy
    (let data_path = "data/poetry/imagery_keywords.json" in
     let loaded_words = load_words_from_json_file data_path in
     if loaded_words = [] then
       (* 如果加载失败，使用原始硬编码数据作为后备 *)
       [
         (* 自然意象 *)
         "山";
         "水";
         "花";
         "月";
         "风";
         "雪";
         "云";
         "雨";
         "春";
         "秋";
         "江";
         "河";
         "湖";
         "海";
         "天";
         "地";
         "星";
         "日";
         "夜";
         "晨";
         (* 情感意象 *)
         "情";
         "爱";
         "思";
         "梦";
         "愁";
         "喜";
         "悲";
         "怒";
         "忧";
         "乐";
         "离";
         "别";
         "归";
         "来";
         "去";
         "望";
         "盼";
         "念";
         "想";
         "忆";
         (* 文化意象 *)
         "诗";
         "书";
         "画";
         "琴";
         "棋";
         "茶";
         "酒";
         "香";
         "禅";
         "道";
         "古";
         "今";
         "昔";
         "时";
         "年";
         "岁";
         "世";
         "代";
         "朝";
         "暮";
       ]
     else loaded_words)

(** 延迟加载的雅致词汇库 *)
let elegant_words =
  lazy
    (let data_path = "data/poetry/elegant_words.json" in
     let loaded_words = load_words_from_json_file data_path in
     if loaded_words = [] then
       (* 如果加载失败，使用原始硬编码数据作为后备 *)
       [
         "雅";
         "致";
         "清";
         "幽";
         "静";
         "淡";
         "素";
         "朴";
         "简";
         "净";
         "美";
         "秀";
         "丽";
         "妙";
         "绝";
         "奇";
         "神";
         "仙";
         "灵";
         "韵";
         "高";
         "深";
         "远";
         "广";
         "博";
         "厚";
         "重";
         "轻";
         "柔";
         "刚";
       ]
     else loaded_words)
