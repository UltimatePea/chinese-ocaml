(** 艺术数据访问器实现 - Phase 2.3.2 *)

open Unified_data_engine

(** {1 艺术数据类型定义} *)

type word_category =
  | Imagery           
  | Elegant           
  | Metaphor          
  | Emotion           
  | Nature            
  | Classical         

type evaluation_dimension =
  | RhymeHarmony      
  | TonalBalance      
  | Parallelism       
  | ImageryDepth      
  | FormBeauty        
  | ContentDepth      
  | MoodContext       

type word_info = {
  word : string;                    
  category : word_category;         
  frequency : int;                  
  artistic_value : float;           
  synonyms : string list;           
  contexts : string list;           
  examples : string list;           
}

type evaluation_standard = {
  dimension : evaluation_dimension; 
  name : string;                    
  description : string;             
  weight : float;                   
  min_score : float;                
  max_score : float;                
  criteria : (string * float) list; 
}

type artistic_template = {
  name : string;                    
  category : word_category;         
  pattern : string;                 
  examples : string list;           
  effectiveness : float;            
}

type 'a query_result = 
  | Found of 'a
  | NotFound
  | QueryError of string

(** {1 内部状态和配置} *)

let initialized = ref false

(* 数据源名称常量 *)
let imagery_data_source = "artistic_imagery_data"
let elegant_data_source = "artistic_elegant_data"
let evaluation_standards_source = "artistic_evaluation_standards"
let templates_source = "artistic_templates"
let word_info_source = "artistic_word_info"

(** {1 工具函数} *)

let word_category_from_string = function
  | "意象" | "imagery" -> Imagery
  | "雅致" | "elegant" -> Elegant
  | "比喻" | "metaphor" -> Metaphor
  | "情感" | "emotion" -> Emotion
  | "自然" | "nature" -> Nature
  | "古典" | "classical" -> Classical
  | _ -> Imagery

let evaluation_dimension_from_string = function
  | "韵律和谐度" | "rhyme_harmony" -> RhymeHarmony
  | "声调平衡度" | "tonal_balance" -> TonalBalance
  | "对仗工整度" | "parallelism" -> Parallelism
  | "意象深度" | "imagery_depth" -> ImageryDepth
  | "形式美感" | "form_beauty" -> FormBeauty
  | "内容深度" | "content_depth" -> ContentDepth
  | "意境营造" | "mood_context" -> MoodContext
  | _ -> ImageryDepth

(** {1 数据解析函数} *)

let parse_word_info_from_json (json : Yojson.Basic.t) : (string * word_info) list =
  let open Yojson.Basic.Util in
  try
    let words = json |> to_list in
    List.map (fun word_json ->
      let word = word_json |> member "word" |> to_string in
      let category_str = word_json |> member "category" |> to_string in
      let frequency = word_json |> member "frequency" |> to_int in
      let artistic_value = word_json |> member "artistic_value" |> to_float in
      let synonyms = try word_json |> member "synonyms" |> to_list |> List.map to_string with _ -> [] in
      let contexts = try word_json |> member "contexts" |> to_list |> List.map to_string with _ -> [] in
      let examples = try word_json |> member "examples" |> to_list |> List.map to_string with _ -> [] in
      
      let word_info = {
        word;
        category = word_category_from_string category_str;
        frequency;
        artistic_value;
        synonyms;
        contexts;
        examples;
      } in
      (word, word_info)
    ) words
  with _ -> []

let parse_evaluation_standards_from_json (json : Yojson.Basic.t) : (evaluation_dimension * evaluation_standard list) list =
  let open Yojson.Basic.Util in
  try
    let dimensions = json |> member "standards" |> to_assoc in
    List.map (fun (dim_str, standards_json) ->
      let dimension = evaluation_dimension_from_string dim_str in
      let standards = standards_json |> to_list |> List.map (fun std_json ->
        let name = std_json |> member "name" |> to_string in
        let description = std_json |> member "description" |> to_string in
        let weight = std_json |> member "weight" |> to_float in
        let min_score = std_json |> member "min_score" |> to_float in
        let max_score = std_json |> member "max_score" |> to_float in
        let criteria = try 
          std_json |> member "criteria" |> to_list |> List.map (fun c ->
            let desc = c |> member "description" |> to_string in
            let score = c |> member "score" |> to_float in
            (desc, score)
          )
        with _ -> [] in
        {dimension; name; description; weight; min_score; max_score; criteria}
      ) in
      (dimension, standards)
    ) dimensions
  with _ -> []

let parse_artistic_templates_from_json (json : Yojson.Basic.t) : (word_category * artistic_template list) list =
  let open Yojson.Basic.Util in
  try
    let categories = json |> member "templates" |> to_assoc in
    List.map (fun (cat_str, templates_json) ->
      let category = word_category_from_string cat_str in
      let templates = templates_json |> to_list |> List.map (fun tmpl_json ->
        let name = tmpl_json |> member "name" |> to_string in
        let pattern = tmpl_json |> member "pattern" |> to_string in
        let examples = try tmpl_json |> member "examples" |> to_list |> List.map to_string with _ -> [] in
        let effectiveness = tmpl_json |> member "effectiveness" |> to_float in
        {name; category; pattern; examples; effectiveness}
      ) in
      (category, templates)
    ) categories
  with _ -> []

(** {1 数据查询辅助函数} *)

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

(** {1 默认数据定义} *)

let default_imagery_words = [
  "山"; "水"; "月"; "风"; "花"; "鸟"; "云"; "雨"; "雪"; "霜";
  "春"; "夏"; "秋"; "冬"; "朝"; "暮"; "日"; "星"; "天"; "地";
  "江"; "河"; "湖"; "海"; "松"; "竹"; "梅"; "兰"; "菊"; "莲";
]

let default_elegant_words = [
  "之"; "者"; "也"; "矣"; "乎"; "哉"; "焉"; "夫"; "其"; "若";
  "兮"; "惟"; "唯"; "斯"; "是"; "谓"; "盖"; "且"; "犹"; "尚";
  "方"; "将"; "能"; "可"; "足"; "得"; "所"; "于"; "以"; "为";
  "而"; "与"; "从"; "自"; "由";
]

(** {1 公共接口实现} *)

let initialize () =
  if not (Unified_data_engine.is_initialized ()) then
    Unified_data_engine.initialize ();
  
  if not !initialized then (
    (* 注册艺术相关的数据源 *)
    Unified_data_engine.register_data_source 
      imagery_data_source 
      Artistic 
      (JsonFile "data/artistic/imagery_words.json") 
      Cached;
    
    Unified_data_engine.register_data_source 
      elegant_data_source 
      Artistic 
      (JsonFile "data/artistic/elegant_words.json") 
      Cached;
    
    Unified_data_engine.register_data_source 
      evaluation_standards_source 
      Artistic 
      (JsonFile "data/artistic/evaluation_standards.json") 
      Preloaded;
    
    Unified_data_engine.register_data_source 
      templates_source 
      Artistic 
      (JsonFile "data/artistic/templates.json") 
      Cached;
    
    Unified_data_engine.register_data_source 
      word_info_source 
      Artistic 
      (JsonFile "data/artistic/word_info.json") 
      Preloaded;
    
    initialized := true
  )

let is_initialized () = !initialized

let register_custom_word_source (name : string) (filepath : string) =
  if not !initialized then initialize ();
  Unified_data_engine.register_data_source 
    name 
    Artistic 
    (JsonFile filepath) 
    Cached

let get_word_info (word : string) : word_info query_result =
  if not !initialized then initialize ();
  match lookup_word_info word with
  | Some info -> Found info
  | None -> NotFound

let get_words_by_category (category : word_category) : string list query_result =
  if not !initialized then initialize ();
  try
    let words = get_words_by_condition (fun info -> info.category = category) in
    if words = [] then
      (* 如果没有数据，使用默认数据 *)
      match category with
      | Imagery -> Found default_imagery_words
      | Elegant -> Found default_elegant_words
      | _ -> NotFound
    else Found words
  with exn ->
    QueryError ("查询类别词汇失败: " ^ Printexc.to_string exn)

let search_words_by_pattern (pattern : string) : string list query_result =
  if not !initialized then initialize ();
  try
    let pattern_regex = Str.regexp pattern in
    let words = get_words_by_condition (fun info ->
      Str.string_match pattern_regex info.word 0
    ) in
    if words = [] then NotFound else Found words
  with exn ->
    QueryError ("模式搜索失败: " ^ Printexc.to_string exn)

let get_high_value_words (category : word_category) (limit : int) : (string * float) list query_result =
  if not !initialized then initialize ();
  match Unified_data_engine.load_json_data word_info_source with
  | Success json ->
      let parsed_word_info : (string * word_info) list = parse_word_info_from_json json in
      let category_words = List.filter (fun (_, (info : word_info)) -> info.category = category) parsed_word_info in
      let sorted_words = List.sort (fun (_, info1) (_, info2) -> 
        compare info2.artistic_value info1.artistic_value
      ) category_words in
      let limited_words = List.take (min limit (List.length sorted_words)) sorted_words in
      let result = List.map (fun (word, info) -> (word, info.artistic_value)) limited_words in
      if result = [] then NotFound else Found result
  | Failure err ->
      QueryError ("获取高价值词汇失败: " ^ Unified_data_engine.format_error err)

(** {1 意象词汇专用接口实现} *)

let get_imagery_keywords () : string list query_result =
  match get_words_by_category Imagery with
  | Found words -> Found words
  | NotFound -> Found default_imagery_words
  | QueryError err -> QueryError err

let get_nature_imagery () : string list query_result =
  match get_words_by_category Nature with
  | Found words -> Found words
  | NotFound -> 
      let nature_words = List.filter (fun word ->
        String.contains word (String.get "山" 0) || String.contains word (String.get "水" 0) || 
        String.contains word (String.get "花" 0) || String.contains word (String.get "树" 0)
      ) default_imagery_words in
      Found nature_words
  | QueryError err -> QueryError err

let get_seasonal_imagery (season : string) : string list query_result =
  let seasonal_keywords = match season with
    | "春" -> ["春"; "花"; "绿"; "暖"; "莺"; "燕"]
    | "夏" -> ["夏"; "热"; "荷"; "蝉"; "绿"; "浓"]
    | "秋" -> ["秋"; "叶"; "黄"; "凉"; "雁"; "霜"]
    | "冬" -> ["冬"; "雪"; "白"; "寒"; "梅"; "冰"]
    | _ -> []
  in
  if seasonal_keywords = [] then NotFound else Found seasonal_keywords

let suggest_imagery_for_theme (theme : string) : string list query_result =
  (* 简化实现：基于主题关键字匹配意象 *)
  let theme_imagery_map = [
    ("离别", ["柳"; "月"; "风"; "泪"; "路"]);
    ("思乡", ["月"; "雁"; "梦"; "山"; "水"]);
    ("爱情", ["花"; "月"; "红"; "泪"; "心"]);
    ("田园", ["山"; "水"; "田"; "鸟"; "花"]);
  ] in
  (try
    Found (List.assoc theme theme_imagery_map)
  with Not_found ->
    NotFound)

(** {1 雅致词汇专用接口实现} *)

let get_elegant_words () : string list query_result =
  match get_words_by_category Elegant with
  | Found words -> Found words
  | NotFound -> Found default_elegant_words
  | QueryError err -> QueryError err

let get_classical_expressions () : string list query_result =
  match get_words_by_category Classical with
  | Found words -> Found words
  | NotFound -> Found (List.take 15 default_elegant_words)
  | QueryError err -> QueryError err

let get_formal_particles () : string list query_result =
  let particles = ["之"; "乎"; "者"; "也"; "矣"; "焉"; "哉"; "兮"] in
  Found particles

let assess_word_elegance (word : string) : float query_result =
  match get_word_info word with
  | Found info when info.category = Elegant || info.category = Classical ->
      Found info.artistic_value
  | Found _ -> Found 0.0
  | NotFound ->
      (* 简单的雅致度评估 *)
      if List.mem word default_elegant_words then
        Found 0.8
      else
        Found 0.1
  | QueryError err -> QueryError err

(** {1 评价标准管理实现} *)

let get_evaluation_standards (dimension : evaluation_dimension) : evaluation_standard list query_result =
  if not !initialized then initialize ();
  match Unified_data_engine.load_json_data evaluation_standards_source with
  | Success json ->
      let standards_list = parse_evaluation_standards_from_json json in
      (try
        Found (List.assoc dimension standards_list)
      with Not_found -> NotFound)
  | Failure err ->
      QueryError ("获取评价标准失败: " ^ Unified_data_engine.format_error err)

let get_all_evaluation_dimensions () : evaluation_dimension list =
  [RhymeHarmony; TonalBalance; Parallelism; ImageryDepth; FormBeauty; ContentDepth; MoodContext]

let get_standard_weights () : (evaluation_dimension * float) list query_result =
  let default_weights = [
    (RhymeHarmony, 0.20);
    (TonalBalance, 0.20);
    (Parallelism, 0.15);
    (ImageryDepth, 0.15);
    (FormBeauty, 0.10);
    (ContentDepth, 0.10);
    (MoodContext, 0.10);
  ] in
  Found default_weights

let validate_evaluation_criteria (dimension : evaluation_dimension) (criteria_text : string) : bool query_result =
  (* 简化的验证：检查是否包含维度相关关键词 *)
  let dimension_keywords = match dimension with
    | RhymeHarmony -> ["韵"; "音"; "和谐"]
    | TonalBalance -> ["平"; "仄"; "声调"]
    | Parallelism -> ["对仗"; "工整"; "对偶"]
    | ImageryDepth -> ["意象"; "深度"; "内容"]
    | FormBeauty -> ["形式"; "美感"; "结构"]
    | ContentDepth -> ["内容"; "深度"; "思想"]
    | MoodContext -> ["意境"; "营造"; "氛围"]
  in
  let contains_keywords = List.exists (fun keyword ->
    String.contains criteria_text (String.get keyword 0)
  ) dimension_keywords in
  Found contains_keywords

(** {1 艺术模板管理实现} *)

let get_artistic_templates (category : word_category) : artistic_template list query_result =
  if not !initialized then initialize ();
  match Unified_data_engine.load_json_data templates_source with
  | Success json ->
      let templates_list = parse_artistic_templates_from_json json in
      (try
        Found (List.assoc category templates_list)
      with Not_found -> NotFound)
  | Failure err ->
      QueryError ("获取艺术模板失败: " ^ Unified_data_engine.format_error err)

let suggest_template_for_context (context : string) : artistic_template list query_result =
  (* 简化实现：基于语境关键词推荐模板 *)
  let context_template_map = [
    ("山水", {name = "山水模板"; category = Nature; pattern = "山...水..."; examples = []; effectiveness = 0.8});
    ("花鸟", {name = "花鸟模板"; category = Nature; pattern = "花...鸟..."; examples = []; effectiveness = 0.7});
  ] in
  let matching_templates = List.filter_map (fun (ctx, template) ->
    if String.contains context (String.get ctx 0) then Some template else None
  ) context_template_map in
  if matching_templates = [] then NotFound else Found matching_templates

let evaluate_template_effectiveness (template_name : string) : float query_result =
  (* 简化实现：返回固定的有效性评分 *)
  if String.length template_name > 0 then
    Found 0.75
  else
    Found 0.0

(** {1 高级分析功能实现} *)

let analyze_text_artistic_elements (text : string) : (word_category * string list) list query_result =
  if not !initialized then initialize ();
  try
    let text_chars = List.init (String.length text) (String.get text) in
    let text_words = List.map (String.make 1) text_chars in
    
    let imagery_words = List.filter (fun word -> List.mem word default_imagery_words) text_words in
    let elegant_words = List.filter (fun word -> List.mem word default_elegant_words) text_words in
    
    let result = [] in
    let result = if imagery_words <> [] then (Imagery, imagery_words) :: result else result in
    let result = if elegant_words <> [] then (Elegant, elegant_words) :: result else result in
    
    if result = [] then NotFound else Found result
  with exn ->
    QueryError ("分析艺术元素失败: " ^ Printexc.to_string exn)

let suggest_improvements (_ : string) (focus_dimension : evaluation_dimension) : string list query_result =
  let suggestions = match focus_dimension with
    | RhymeHarmony -> ["检查韵脚的一致性"; "调整音韵搭配"]
    | TonalBalance -> ["平衡平仄声调"; "注意声律变化"]
    | Parallelism -> ["加强对仗工整度"; "对偶句式对称"]
    | ImageryDepth -> ["丰富意象内容"; "加深意象层次"]
    | FormBeauty -> ["优化诗句结构"; "注意形式美感"]
    | ContentDepth -> ["深化思想内容"; "提升表达深度"]
    | MoodContext -> ["营造更佳意境"; "强化情感表达"]
  in
  Found suggestions

let calculate_artistic_score (text : string) : (evaluation_dimension * float) list query_result =
  (* 简化的艺术性评分计算 *)
  let base_scores = [
    (RhymeHarmony, 0.7);
    (TonalBalance, 0.6);
    (Parallelism, 0.5);
    (ImageryDepth, 0.8);
    (FormBeauty, 0.6);
    (ContentDepth, 0.7);
    (MoodContext, 0.8);
  ] in
  
  (* 基于文本长度调整评分 *)
  let text_length = String.length text in
  let length_factor = min 1.0 (float_of_int text_length /. 20.0) in
  
  let adjusted_scores = List.map (fun (dim, score) ->
    (dim, score *. length_factor)
  ) base_scores in
  
  Found adjusted_scores

let compare_artistic_quality (text1 : string) (text2 : string) : (evaluation_dimension * float * float) list query_result =
  match calculate_artistic_score text1, calculate_artistic_score text2 with
  | Found scores1, Found scores2 ->
      let comparison = List.map2 (fun (dim1, score1) (dim2, score2) ->
        assert (dim1 = dim2);
        (dim1, score1, score2)
      ) scores1 scores2 in
      Found comparison
  | Found _, NotFound -> QueryError "无法计算第二个文本的评分"
  | NotFound, Found _ -> QueryError "无法计算第一个文本的评分"
  | NotFound, NotFound -> QueryError "无法计算两个文本的评分"
  | QueryError err, _ -> QueryError err
  | _, QueryError err -> QueryError err

(** {1 数据统计和分析实现} *)

let get_word_category_statistics () : (word_category * int) list query_result =
  if not !initialized then initialize ();
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

let get_popular_words (category : word_category) (limit : int) : (string * int) list query_result =
  match get_words_by_category category with
  | Found words ->
      let limited_words = List.take (min limit (List.length words)) words in
      let word_freq_pairs = List.map (fun word -> (word, 1)) limited_words in (* 简化实现 *)
      Found word_freq_pairs
  | NotFound -> NotFound
  | QueryError err -> QueryError err

let get_artistic_trends () : (word_category * float) list query_result =
  (* 简化的趋势分析 *)
  let trends = [
    (Imagery, 0.85);
    (Elegant, 0.70);
    (Nature, 0.80);
    (Classical, 0.60);
    (Emotion, 0.75);
    (Metaphor, 0.65);
  ] in
  Found trends

(** {1 兼容性接口实现} *)

let load_imagery_data () : string list =
  match get_imagery_keywords () with
  | Found words -> words
  | _ -> default_imagery_words

let load_elegant_data () : string list =
  match get_elegant_words () with
  | Found words -> words
  | _ -> default_elegant_words

let check_word_availability (word : string) : bool =
  match get_word_info word with
  | Found _ -> true
  | _ -> List.mem word default_imagery_words || List.mem word default_elegant_words

(** {1 错误处理和诊断实现} *)

let format_query_error (error_msg : string) : string =
  "艺术数据查询错误: " ^ error_msg

let validate_data_integrity () : (string * bool * string option) list =
  if not !initialized then initialize ();
  Unified_data_engine.validate_all_sources ()

let get_cache_status () : (string * bool * int) list =
  if not !initialized then initialize ();
  let cache_info = Unified_data_engine.get_cache_info () in
  List.map (fun (name, size_bytes, _) -> (name, true, size_bytes)) cache_info

let diagnose_performance () : string =
  if not !initialized then initialize ();
  let stats = Unified_data_engine.get_engine_stats () in
  Printf.sprintf "艺术数据访问器性能报告:\n总请求数: %d\n缓存命中率: %.2f%%\n平均加载时间: %.2f ms\n数据源数量: %d"
    stats.total_requests
    (if stats.total_requests > 0 then 
       float_of_int stats.cache_hits /. float_of_int stats.total_requests *. 100.0 
     else 0.0)
    stats.average_load_time
    stats.data_sources_count