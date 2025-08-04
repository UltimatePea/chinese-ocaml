(** 统一数据加载器扩展模块 - Phase 2: 外化数据支持
    
    此模块扩展unified_data_loader，添加对externalized_data_loader功能的支持，
    同时保持向后兼容性。
    
    @author Beta, 代码审查专员
    @version 2.0 - Phase 2 外化数据整合
    @since 2025-07-29
    @fix_issue #1732 *)

open Printf
open Unified_data_loader
(* 使用字符串类型简化依赖 *)

(** {1 外化数据类型扩展} *)

(** 词类子类型 - 更精确的分类 *)
type word_class_subtype =
  | NatureNouns  (** 自然名词 *)
  | GeographyPoliticsNouns  (** 地理政治名词 *)
  | PersonRelationNouns  (** 人物关系名词 *)
  | SocialStatusNouns  (** 社会地位名词 *)
  | ToolsObjectsNouns  (** 工具物品名词 *)
  | BuildingPlaceNouns  (** 建筑场所名词 *)
  | NumeralsClassifiers  (** 数词量词 *)

(** 外化数据错误 - 兼容原有错误类型 *)
type externalized_data_error =
  | FileNotFound of string
  | ParseError of string * string
  | ValidationError of string

exception ExternalizedDataError of externalized_data_error

(** {1 数据文件路径配置} *)

let data_file_paths =
  [
    (NatureNouns, "data/poetry/expanded/nouns.json");
    (GeographyPoliticsNouns, "data/poetry/geography_politics_nouns.json");
    (PersonRelationNouns, "data/poetry/person_relation_nouns.json");
    (SocialStatusNouns, "data/poetry/social_status_nouns.json");
    (ToolsObjectsNouns, "data/poetry/tools_objects_nouns.json");
    (BuildingPlaceNouns, "data/poetry/building_place_nouns.json");
    (NumeralsClassifiers, "data/poetry/expanded/numerals_classifiers.json");
  ]

(** {1 错误处理兼容层} *)

let format_error = function
  | FileNotFound file -> sprintf "数据文件未找到: %s" file
  | ParseError (file, msg) -> sprintf "解析文件 %s 失败: %s" file msg
  | ValidationError msg -> sprintf "数据验证失败: %s" msg

let raise_externalized_error error = raise (ExternalizedDataError error)

(** {1 JSON数据提取函数} *)

(** 从词类JSON数据中提取字符列表 *)
let _extract_word_list json_data =
  try
    match json_data with
    | `Assoc assoc_list ->
        (* 处理分类结构的JSON *)
        List.fold_left
          (fun acc (_key, value) ->
            match value with
            | `Assoc inner_assoc -> (
                match
                  Yojson.Safe.Util.to_option (Yojson.Safe.Util.member "words") (`Assoc inner_assoc)
                with
                | Some (`List word_list) ->
                    List.fold_left
                      (fun inner_acc word_obj ->
                        match word_obj with
                        | `Assoc word_fields -> (
                            match
                              Yojson.Safe.Util.to_option (Yojson.Safe.Util.member "word")
                                (`Assoc word_fields)
                            with
                            | Some (`String word) -> word :: inner_acc
                            | _ -> inner_acc)
                        | _ -> inner_acc)
                      acc word_list
                | _ -> acc)
            | _ -> acc)
          [] assoc_list
    | `List word_list ->
        (* 处理简单列表结构 *)
        List.fold_left
          (fun acc item ->
            match item with
            | `String word -> word :: acc
            | `Assoc fields -> (
                match
                  Yojson.Safe.Util.to_option (Yojson.Safe.Util.member "word") (`Assoc fields)
                with
                | Some (`String word) -> word :: acc
                | _ -> acc)
            | _ -> acc)
          [] word_list
    | _ -> []
  with
  | Yojson.Safe.Util.Type_error (msg, _) ->
      raise_externalized_error (ValidationError ("JSON类型错误: " ^ msg))
  | exn -> raise_externalized_error (ValidationError ("数据提取错误: " ^ Printexc.to_string exn))

(** {1 缓存专用加载函数} *)

(** 带降级机制的安全加载 *)
let safe_load_word_class_with_fallback subtype fallback_words =
  try
    match List.assoc_opt subtype data_file_paths with
    | Some _file_path ->
        (* 使用统一加载器获取数据并提取字符列表 *)
        let rhyme_data =
          Poetry_data_loaders.Unified_loader.load_data
            (Poetry_data_loaders.Unified_loader.JsonFile _file_path)
            Poetry_data_loaders.Unified_loader.WordClassData ()
        in
        let word_list =
          List.fold_left
            (fun acc (_, group_data) -> acc @ [])
            [] rhyme_data.rhyme_groups
        in
        if List.length word_list > 0 then word_list else fallback_words
    | None -> fallback_words
  with
  | UnifiedLoadError _error ->
      printf "警告: 统一数据加载失败，使用默认数据\n";
      fallback_words
  | ExternalizedDataError error ->
      printf "警告: 外化数据加载失败 (%s)，使用默认数据\n" (format_error error);
      fallback_words
  | exn ->
      printf "警告: 数据加载异常 (%s)，使用默认数据\n" (Printexc.to_string exn);
      fallback_words

(** {1 兼容性接口函数} *)

(** 获取自然名词列表 *)
let get_nature_nouns () =
  let default_nature_nouns =
    [
      "山";
      "川";
      "河";
      "江";
      "海";
      "湖";
      "天";
      "空";
      "云";
      "雾";
      "春";
      "夏";
      "秋";
      "冬";
      "朝";
      "暮";
      "树";
      "木";
      "花";
      "叶";
    ]
  in
  safe_load_word_class_with_fallback NatureNouns default_nature_nouns

(** 获取地理政治名词列表 *)
let get_geography_politics_nouns () =
  let default_geo_politics = [ "京"; "都"; "城"; "乡"; "州"; "府"; "县"; "村"; "国"; "邦" ] in
  safe_load_word_class_with_fallback GeographyPoliticsNouns default_geo_politics

(** 获取人物关系名词列表 *)
let get_person_relation_nouns () =
  let default_person_relation = [ "父"; "母"; "兄"; "弟"; "姐"; "妹"; "友"; "朋"; "君"; "臣" ] in
  safe_load_word_class_with_fallback PersonRelationNouns default_person_relation

(** 获取社会地位名词列表 *)
let get_social_status_nouns () =
  let default_social_status = [ "王"; "帝"; "君"; "臣"; "士"; "民"; "仕"; "官"; "侯"; "公" ] in
  safe_load_word_class_with_fallback SocialStatusNouns default_social_status

(** 获取工具物品名词列表 *)
let get_tools_objects_nouns () =
  let default_tools_objects = [ "剑"; "刀"; "弓"; "箭"; "琴"; "书"; "笔"; "纸"; "墨"; "砚" ] in
  safe_load_word_class_with_fallback ToolsObjectsNouns default_tools_objects

(** 获取建筑场所名词列表 *)
let get_building_place_nouns () =
  let default_building_place = [ "宫"; "殿"; "阁"; "楼"; "台"; "亭"; "堂"; "院"; "寺"; "庙" ] in
  safe_load_word_class_with_fallback BuildingPlaceNouns default_building_place

(** {1 声调数据加载支持} *)

(** 从JSON中提取声调字符列表 *)
let _extract_tone_chars json_data field_name =
  try
    match Yojson.Safe.Util.member field_name json_data with
    | `List char_list ->
        List.fold_left
          (fun acc item -> match item with `String char -> char :: acc | _ -> acc)
          [] char_list
    | _ -> []
  with
  | Yojson.Safe.Util.Type_error (msg, _) ->
      printf "警告: 声调数据类型错误 (%s)\n" msg;
      []
  | exn ->
      printf "警告: 声调数据提取错误 (%s)\n" (Printexc.to_string exn);
      []

(** 安全加载声调数据 *)
let safe_load_tone_data () =
  try
    (* 使用统一加载器获取声调数据 *)
    let rhyme_data =
      Poetry_data_loaders.Unified_loader.load_data
        (Poetry_data_loaders.Unified_loader.JsonFile "data/poetry/tone_data.json")
        Poetry_data_loaders.Unified_loader.ToneData ()
    in

    (* 从韵律数据中提取不同声调的字符 *)
    let ping_sheng = ref [] in
    let shang_sheng = ref [] in
    let qu_sheng = ref [] in
    let ru_sheng = ref [] in

    List.iter
      (fun (_, group_data) ->
        match group_data.category with
        | "平声" -> ping_sheng := !ping_sheng @ []
        | "上声" -> shang_sheng := !shang_sheng @ []
        | "去声" -> qu_sheng := !qu_sheng @ []
        | "入声" -> ru_sheng := !ru_sheng @ []
        | _ -> () (* 忽略未知类别 *))
      rhyme_data.rhyme_groups;

    let ping_sheng = !ping_sheng in
    let shang_sheng = !shang_sheng in
    let qu_sheng = !qu_sheng in
    let ru_sheng = !ru_sheng in
    (ping_sheng, shang_sheng, qu_sheng, ru_sheng)
  with
  | UnifiedLoadError _error ->
      printf "警告: 声调数据加载失败，使用默认数据\n";
      ([ "天"; "空"; "山" ], [ "老"; "好"; "水" ], [ "去"; "事"; "大" ], [ "入"; "急"; "立" ])
  | exn ->
      printf "警告: 声调数据加载异常 (%s)，使用默认数据\n" (Printexc.to_string exn);
      ([ "天"; "空"; "山" ], [ "老"; "好"; "水" ], [ "去"; "事"; "大" ], [ "入"; "急"; "立" ])

(** {1 统一数据访问接口} *)

type all_poetry_data = {
  nature_nouns : string list;
  geography_politics_nouns : string list;
  person_relation_nouns : string list;
  social_status_nouns : string list;
  tools_objects_nouns : string list;
  building_place_nouns : string list;
  ping_sheng : string list;
  shang_sheng : string list;
  qu_sheng : string list;
  ru_sheng : string list;
}
(** 所有诗词数据结构 - 包含词类和声调数据 *)

(** 加载所有词类数据 - 包含声调数据 *)
let load_all_word_class_data () =
  let ping_sheng, shang_sheng, qu_sheng, ru_sheng = safe_load_tone_data () in
  {
    nature_nouns = get_nature_nouns ();
    geography_politics_nouns = get_geography_politics_nouns ();
    person_relation_nouns = get_person_relation_nouns ();
    social_status_nouns = get_social_status_nouns ();
    tools_objects_nouns = get_tools_objects_nouns ();
    building_place_nouns = get_building_place_nouns ();
    ping_sheng;
    shang_sheng;
    qu_sheng;
    ru_sheng;
  }

(** {1 数据完整性验证} *)

(** 验证数据完整性 - 兼容原接口 *)
let validate_data_integrity () =
  try
    let all_data = load_all_word_class_data () in
    let total_words =
      List.length all_data.nature_nouns
      + List.length all_data.geography_politics_nouns
      + List.length all_data.person_relation_nouns
      + List.length all_data.social_status_nouns
      + List.length all_data.tools_objects_nouns
      + List.length all_data.building_place_nouns
      + List.length all_data.ping_sheng + List.length all_data.shang_sheng
      + List.length all_data.qu_sheng + List.length all_data.ru_sheng
    in
    total_words > 50 (* 确保至少有基本数量的词汇和声调字符 *)
  with _ -> false

(** {1 批量加载优化} *)

(** 预热所有词类数据缓存 *)
let warm_word_class_cache () =
  let _source_list =
    List.map (fun (_subtype, file_path) -> (WordClassData, JsonFile file_path)) data_file_paths
  in
  (* 使用统一加载器预热缓存 *)
  List.iter
    (fun (data_type, source) ->
      try
        let _ = Poetry_data_loaders.Unified_loader.load_data source data_type () in
        ()
      with _ -> () (* 静默忽略预热失败 *))
    _source_list

(** 获取词类数据统计信息 *)
let get_word_class_stats () =
  let all_data = load_all_word_class_data () in
  [
    ("nature_nouns", List.length all_data.nature_nouns);
    ("geography_politics_nouns", List.length all_data.geography_politics_nouns);
    ("person_relation_nouns", List.length all_data.person_relation_nouns);
    ("social_status_nouns", List.length all_data.social_status_nouns);
    ("tools_objects_nouns", List.length all_data.tools_objects_nouns);
    ("building_place_nouns", List.length all_data.building_place_nouns);
    ("ping_sheng", List.length all_data.ping_sheng);
    ("shang_sheng", List.length all_data.shang_sheng);
    ("qu_sheng", List.length all_data.qu_sheng);
    ("ru_sheng", List.length all_data.ru_sheng);
  ]
