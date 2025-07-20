(** 外化数据加载器 - 骆言项目 Issue #647 技术债务清理
 
    负责从外部JSON文件加载诗词数据，替代原有的硬编码数据存储模块。
    实现数据与代码分离，提高维护性和可扩展性。

    @author 骆言技术债务清理团队 Issue #647
    @version 1.0
    @since 2025-07-20 *)

open Printf

(** ========== 错误处理 ========== *)

type externalized_data_error =
  | FileNotFound of string
  | ParseError of string * string
  | ValidationError of string

exception ExternalizedDataError of externalized_data_error

let format_error = function
  | FileNotFound file -> sprintf "数据文件未找到: %s" file
  | ParseError (file, msg) -> sprintf "解析文件 %s 失败: %s" file msg
  | ValidationError msg -> sprintf "数据验证失败: %s" msg

(** ========== JSON 解析器增强 ========== *)

module JsonDataParser = struct
  (** 去除空白字符 *)
  let trim_whitespace s =
    let len = String.length s in
    let rec start i =
      if i >= len then len
      else match s.[i] with ' ' | '\t' | '\n' | '\r' -> start (i + 1) | _ -> i
    in
    let rec finish i =
      if i < 0 then -1 else match s.[i] with ' ' | '\t' | '\n' | '\r' -> finish (i - 1) | _ -> i
    in
    let s_start = start 0 in
    let s_end = finish (len - 1) in
    if s_start > s_end then "" else String.sub s s_start (s_end - s_start + 1)

  (** 提取字段值 *)
  let extract_field content field_name =
    try
      let field_pattern = "\"" ^ field_name ^ "\"" in
      let field_start =
        let rec search pos =
          if pos + String.length field_pattern > String.length content then raise Not_found
          else if String.sub content pos (String.length field_pattern) = field_pattern then pos
          else search (pos + 1)
        in
        search 0
      in
      let colon_pos = String.index_from content field_start ':' in
      let value_start = colon_pos + 1 in

      (* 寻找值的开始 *)
      let rec find_value_start pos =
        if pos >= String.length content then pos
        else
          match content.[pos] with
          | ' ' | '\t' | '\n' | '\r' -> find_value_start (pos + 1)
          | _ -> pos
      in
      let actual_start = find_value_start value_start in

      (* 判断值的类型并提取 *)
      if actual_start < String.length content then
        match content.[actual_start] with
        | '"' ->
            (* 字符串值 *)
            let end_quote = String.index_from content (actual_start + 1) '"' in
            String.sub content (actual_start + 1) (end_quote - actual_start - 1)
        | '[' ->
            (* 数组值 *)
            let rec find_array_end pos bracket_count =
              if pos >= String.length content then pos
              else
                match content.[pos] with
                | '[' -> find_array_end (pos + 1) (bracket_count + 1)
                | ']' when bracket_count = 1 -> pos
                | ']' -> find_array_end (pos + 1) (bracket_count - 1)
                | _ -> find_array_end (pos + 1) bracket_count
            in
            let array_end = find_array_end actual_start 0 in
            String.sub content actual_start (array_end - actual_start + 1)
        | '{' ->
            (* 对象值 *)
            let rec find_object_end pos brace_count =
              if pos >= String.length content then pos
              else
                match content.[pos] with
                | '{' -> find_object_end (pos + 1) (brace_count + 1)
                | '}' when brace_count = 1 -> pos
                | '}' -> find_object_end (pos + 1) (brace_count - 1)
                | _ -> find_object_end (pos + 1) brace_count
            in
            let object_end = find_object_end actual_start 0 in
            String.sub content actual_start (object_end - actual_start + 1)
        | _ ->
            (* 其他值类型 *)
            let rec find_value_end pos =
              if pos >= String.length content then pos
              else
                match content.[pos] with
                | ',' | '}' | ']' | '\n' -> pos
                | _ -> find_value_end (pos + 1)
            in
            let value_end = find_value_end actual_start in
            trim_whitespace (String.sub content actual_start (value_end - actual_start))
      else ""
    with Not_found | Invalid_argument _ -> ""

  (** 解析字符串数组 *)
  let parse_string_array content =
    try
      let trimmed = trim_whitespace content in
      if String.length trimmed < 2 then []
      else if trimmed.[0] <> '[' || trimmed.[String.length trimmed - 1] <> ']' then []
      else
        let inner = String.sub trimmed 1 (String.length trimmed - 2) in
        let items = String.split_on_char ',' inner in
        List.map
          (fun item ->
            let cleaned = trim_whitespace item in
            if
              String.length cleaned >= 2
              && cleaned.[0] = '"'
              && cleaned.[String.length cleaned - 1] = '"'
            then String.sub cleaned 1 (String.length cleaned - 2)
            else cleaned)
          items
        |> List.filter (fun s -> String.length s > 0)
    with _ -> []

  (** 提取嵌套分类的词汇 *)
  let extract_categorized_words content category_name =
    let category_content = extract_field content category_name in
    let categories_content = extract_field category_content "categories" in
    
    (* 提取每个子分类的words字段 *)
    let extract_subcategory_words subcategory_name =
      let subcategory_content = extract_field categories_content subcategory_name in
      let words_content = extract_field subcategory_content "words" in
      parse_string_array words_content
    in
    
    (* 返回提取函数供调用者使用 *)
    extract_subcategory_words
end

(** ========== 文件读取工具 ========== *)

module ExternalizedFileReader = struct
  (** 读取文件内容 *)
  let read_file_content filename =
    try
      let ic = open_in filename in
      let content = really_input_string ic (in_channel_length ic) in
      close_in ic;
      content
    with
    | Sys_error _ -> raise (ExternalizedDataError (FileNotFound filename))
    | e -> raise (ExternalizedDataError (ParseError (filename, Printexc.to_string e)))

  (** 获取数据文件路径 *)
  let get_data_path relative_path =
    let project_root = Sys.getcwd () in
    Filename.concat (Filename.concat project_root "data/poetry/expanded") relative_path
end

(** ========== 词性数据加载器 ========== *)

module ExternalizedWordClassLoader = struct
  (** 加载自然景物名词数据 *)
  let load_nature_nouns () =
    let file_path = ExternalizedFileReader.get_data_path "word_class_storage.json" in
    let content = ExternalizedFileReader.read_file_content file_path in
    
    let extract_words = JsonDataParser.extract_categorized_words content "nature_nouns" in
    
    let mountains_rivers = extract_words "mountains_rivers" in
    let weather_sky = extract_words "weather_sky" in
    let time_seasons = extract_words "time_seasons" in
    let plants_life = extract_words "plants_life" in
    
    (mountains_rivers, weather_sky, time_seasons, plants_life)

  (** 加载量词数据 *)
  let load_measuring_classifiers () =
    let file_path = ExternalizedFileReader.get_data_path "word_class_storage.json" in
    let content = ExternalizedFileReader.read_file_content file_path in
    
    let extract_words = JsonDataParser.extract_categorized_words content "measuring_classifiers" in
    
    let general = extract_words "general" in
    let containers = extract_words "containers" in
    let tools_weapons = extract_words "tools_weapons" in
    let measurement_units = extract_words "measurement_units" in
    let time_frequency = extract_words "time_frequency" in
    
    (general, containers, tools_weapons, measurement_units, time_frequency)

  (** 加载工具物品名词数据 *)
  let load_tools_objects () =
    let file_path = ExternalizedFileReader.get_data_path "word_class_storage.json" in
    let content = ExternalizedFileReader.read_file_content file_path in
    
    let extract_words = JsonDataParser.extract_categorized_words content "tools_objects" in
    
    let household = extract_words "household" in
    let writing_materials = extract_words "writing_materials" in
    let musical_instruments = extract_words "musical_instruments" in
    let weapons = extract_words "weapons" in
    let construction = extract_words "construction" in
    let clothing = extract_words "clothing" in
    
    (household, writing_materials, musical_instruments, weapons, construction, clothing)
end

(** ========== 声调数据加载器 ========== *)

module ExternalizedToneLoader = struct
  (** 加载声调数据 *)
  let load_tone_data () =
    let file_path = ExternalizedFileReader.get_data_path "tone_data_storage.json" in
    let content = ExternalizedFileReader.read_file_content file_path in
    
    let tone_data_content = JsonDataParser.extract_field content "tone_data" in
    
    let ping_sheng_content = JsonDataParser.extract_field tone_data_content "ping_sheng" in
    let ping_sheng_chars_content = JsonDataParser.extract_field ping_sheng_content "characters" in
    let ping_sheng_chars = JsonDataParser.parse_string_array ping_sheng_chars_content in
    
    let shang_sheng_content = JsonDataParser.extract_field tone_data_content "shang_sheng" in
    let shang_sheng_chars_content = JsonDataParser.extract_field shang_sheng_content "characters" in
    let shang_sheng_chars = JsonDataParser.parse_string_array shang_sheng_chars_content in
    
    let qu_sheng_content = JsonDataParser.extract_field tone_data_content "qu_sheng" in
    let qu_sheng_chars_content = JsonDataParser.extract_field qu_sheng_content "characters" in
    let qu_sheng_chars = JsonDataParser.parse_string_array qu_sheng_chars_content in
    
    let ru_sheng_content = JsonDataParser.extract_field tone_data_content "ru_sheng" in
    let ru_sheng_chars_content = JsonDataParser.extract_field ru_sheng_content "characters" in
    let ru_sheng_chars = JsonDataParser.parse_string_array ru_sheng_chars_content in
    
    (ping_sheng_chars, shang_sheng_chars, qu_sheng_chars, ru_sheng_chars)
end

(** ========== 降级机制 - 如果JSON文件加载失败，使用默认数据 ========== *)

module FallbackHardcodedData = struct
  (** 基本自然景物名词备份数据 *)
  let basic_nature_nouns =
    [
      "山"; "川"; "河"; "江"; "海"; "湖"; "天"; "空"; "云"; "雾";
      "春"; "夏"; "秋"; "冬"; "朝"; "暮"; "树"; "木"; "花"; "叶"
    ]

  (** 基本量词备份数据 *)
  let basic_classifiers =
    [
      "个"; "只"; "条"; "根"; "支"; "片"; "张"; "块"; "团"; "群"
    ]

  (** 基本工具物品备份数据 *)
  let basic_tools_objects =
    [
      "桌"; "椅"; "床"; "柜"; "笔"; "墨"; "纸"; "砚"; "琴"; "瑟"
    ]

  (** 基本声调数据 *)
  let basic_ping_sheng = [ "一"; "天"; "年"; "先"; "田" ]
  let basic_shang_sheng = [ "上"; "老"; "好"; "小"; "少" ]
  let basic_qu_sheng = [ "去"; "次"; "事"; "字"; "自" ]
  let basic_ru_sheng = [ "入"; "出"; "国"; "德"; "得" ]
end

(** ========== 导出接口 ========== *)

(** 安全加载函数 - 提供降级机制 *)
let safe_load_nature_nouns () =
  try ExternalizedWordClassLoader.load_nature_nouns ()
  with ExternalizedDataError err ->
    Printf.eprintf "警告: %s，使用默认自然景物名词数据\n" (format_error err);
    (FallbackHardcodedData.basic_nature_nouns, [], [], [])

let safe_load_measuring_classifiers () =
  try ExternalizedWordClassLoader.load_measuring_classifiers ()
  with ExternalizedDataError err ->
    Printf.eprintf "警告: %s，使用默认量词数据\n" (format_error err);
    (FallbackHardcodedData.basic_classifiers, [], [], [], [])

let safe_load_tools_objects () =
  try ExternalizedWordClassLoader.load_tools_objects ()
  with ExternalizedDataError err ->
    Printf.eprintf "警告: %s，使用默认工具物品数据\n" (format_error err);
    (FallbackHardcodedData.basic_tools_objects, [], [], [], [], [])

let safe_load_tone_data () =
  try ExternalizedToneLoader.load_tone_data ()
  with ExternalizedDataError err ->
    Printf.eprintf "警告: %s，使用默认声调数据\n" (format_error err);
    (FallbackHardcodedData.basic_ping_sheng, 
     FallbackHardcodedData.basic_shang_sheng,
     FallbackHardcodedData.basic_qu_sheng,
     FallbackHardcodedData.basic_ru_sheng)

(** 统一数据访问接口 - 兼容原有接口 *)
let get_nature_nouns_list () =
  let (mountains_rivers, weather_sky, time_seasons, plants_life) = safe_load_nature_nouns () in
  mountains_rivers @ weather_sky @ time_seasons @ plants_life

let get_measuring_classifiers_list () = 
  let (general, containers, tools_weapons, measurement_units, time_frequency) = safe_load_measuring_classifiers () in
  general @ containers @ tools_weapons @ measurement_units @ time_frequency

let get_tools_objects_list () =
  let (household, writing_materials, musical_instruments, weapons, construction, clothing) = safe_load_tools_objects () in
  household @ writing_materials @ musical_instruments @ weapons @ construction @ clothing

let get_ping_sheng_list () =
  let (ping_sheng, _, _, _) = safe_load_tone_data () in
  ping_sheng

let get_shang_sheng_list () =
  let (_, shang_sheng, _, _) = safe_load_tone_data () in
  shang_sheng

let get_qu_sheng_list () =
  let (_, _, qu_sheng, _) = safe_load_tone_data () in
  qu_sheng

let get_ru_sheng_list () =
  let (_, _, _, ru_sheng) = safe_load_tone_data () in
  ru_sheng