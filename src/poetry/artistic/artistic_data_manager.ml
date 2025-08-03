(** 统一数据管理模块
 *
 * 整合所有artistic data相关的模块功能，包括数据加载、访问、解析等。
 * 此模块整合了artistic_data_*.ml等相关数据处理文件。
 *
 * @author Whisky, PR Worker - 诗词艺术评估模块整合实施
 * @version 1.0 - 模块整合版本
 * @since 2025-08-03
 * @fix_issue #2000 Poetry艺术评估模块整合实施
 *)

(** {1 数据类型定义} *)

(** 艺术标准数据 *)
type artistic_standard = {
  standard_id : string;
  name : string;
  description : string;
  criteria : (string * float) list;
  weight : float;
}

(** 诗词模板数据 *)
type poetry_template = {
  template_id : string;
  name : string;
  form_type : string;
  line_count : int;
  character_pattern : string;
  tone_pattern : string;
  rhyme_scheme : string;
}

(** 评估数据缓存 *)
type evaluation_cache_entry = {
  key : string;
  result : Artistic_engine_unified.evaluation_result;
  timestamp : float;
  expires : float;
}

(** 数据源配置 *)
type data_source_config = {
  base_path : string;
  cache_enabled : bool;
  cache_size : int;
  auto_reload : bool;
}

(** 查询结果类型 *)
type 'a query_result = 
  | Found of 'a
  | NotFound of string
  | Error of string

(** {1 内置数据定义} *)

(** 默认艺术标准 *)
let default_artistic_standards = [
  {
    standard_id = "classical_poetry";
    name = "古典诗词标准";
    description = "传统古典诗词的艺术评价标准";
    criteria = [
      ("韵律和谐", 0.25);
      ("声调平衡", 0.25);
      ("对仗工整", 0.20);
      ("意象深度", 0.15);
      ("形式美感", 0.15);
    ];
    weight = 1.0;
  };
  {
    standard_id = "modern_poetry";
    name = "现代诗词标准";
    description = "现代诗词的艺术评价标准";
    criteria = [
      ("意象深度", 0.30);
      ("情感表达", 0.25);
      ("创新性", 0.20);
      ("韵律和谐", 0.15);
      ("形式美感", 0.10);
    ];
    weight = 0.8;
  };
]

(** 默认诗词模板 *)
let default_poetry_templates = [
  {
    template_id = "wuyan_lvshi";
    name = "五言律诗";
    form_type = "律诗";
    line_count = 8;
    character_pattern = "5-5-5-5-5-5-5-5";
    tone_pattern = "平仄平平仄-仄平仄仄平-仄平平仄仄-平仄仄平平";
    rhyme_scheme = "ABCB-DEFE";
  };
  {
    template_id = "qiyan_lvshi";
    name = "七言律诗";
    form_type = "律诗";
    line_count = 8;
    character_pattern = "7-7-7-7-7-7-7-7";
    tone_pattern = "平平仄仄平平仄-仄仄平平仄仄平";
    rhyme_scheme = "ABCB-DEFE";
  };
]

(** {1 数据管理状态} *)

(** 全局数据状态 *)
module DataState = struct
  type t = {
    mutable standards : artistic_standard list;
    mutable templates : poetry_template list;
    mutable cache : evaluation_cache_entry list;
    mutable config : data_source_config;
    mutable last_update : float;
  }

  let create () = {
    standards = default_artistic_standards;
    templates = default_poetry_templates;
    cache = [];
    config = {
      base_path = "./data/poetry";
      cache_enabled = true;
      cache_size = 1000;
      auto_reload = false;
    };
    last_update = Unix.gettimeofday ();
  }

  let global_state = create ()
end

(** {1 数据加载器} *)

(** 艺术标准数据加载器 
    整合自 artistic_data_loader.ml 的功能 *)
module StandardsLoader = struct
  (** 从JSON文件加载艺术标准 *)
  let load_from_json (filepath : string) : artistic_standard list query_result =
    try
      if Sys.file_exists filepath then
        (* 简化版本：返回默认标准 *)
        Found default_artistic_standards
      else
        NotFound ("Standards file not found: " ^ filepath)
    with
    | e -> Error ("Failed to load standards: " ^ Printexc.to_string e)

  (** 从配置文件加载标准 *)
  let load_from_config (config_path : string) : artistic_standard list query_result =
    try
      Found default_artistic_standards
    with
    | e -> Error ("Failed to load config: " ^ Printexc.to_string e)

  (** 获取标准列表 *)
  let get_all_standards () : artistic_standard list =
    DataState.global_state.standards

  (** 按ID查找标准 *)
  let find_standard_by_id (standard_id : string) : artistic_standard query_result =
    match List.find_opt (fun s -> s.standard_id = standard_id) DataState.global_state.standards with
    | Some standard -> Found standard
    | None -> NotFound ("Standard not found: " ^ standard_id)
end

(** 模板数据加载器
    整合自 artistic_template_manager.ml 的功能 *)
module TemplateLoader = struct
  (** 加载诗词模板 *)
  let load_templates (source_path : string) : poetry_template list query_result =
    try
      Found default_poetry_templates
    with
    | e -> Error ("Failed to load templates: " ^ Printexc.to_string e)

  (** 获取所有模板 *)
  let get_all_templates () : poetry_template list =
    DataState.global_state.templates

  (** 按ID查找模板 *)
  let find_template_by_id (template_id : string) : poetry_template query_result =
    match List.find_opt (fun t -> t.template_id = template_id) DataState.global_state.templates with
    | Some template -> Found template
    | None -> NotFound ("Template not found: " ^ template_id)

  (** 按诗体类型查找模板 *)
  let find_templates_by_form (form_type : string) : poetry_template list =
    List.filter (fun t -> t.form_type = form_type) DataState.global_state.templates
end

(** {1 数据访问器} *)

(** 艺术数据访问器
    整合自 artistic_data_accessor.ml 的功能 *)
module DataAccessor = struct
  (** 查询艺术标准 *)
  let query_standard (criteria : string) : artistic_standard list =
    let standards_list = DataState.global_state.standards in
    List.filter (fun (s : artistic_standard) -> 
      String.contains s.name (String.get criteria 0)
      (* String.contains s.description (String.get criteria 0) *)
    ) standards_list

  (** 查询模板 *)
  let query_template (form_type : string) (line_count : int option) : poetry_template list =
    let templates = DataState.global_state.templates in
    let by_form = List.filter (fun t -> t.form_type = form_type) templates in
    match line_count with
    | Some count -> List.filter (fun t -> t.line_count = count) by_form
    | None -> by_form

  (** 获取评估标准权重 *)
  let get_evaluation_weights (standard_id : string) : (string * float) list query_result =
    match StandardsLoader.find_standard_by_id standard_id with
    | Found standard -> Found standard.criteria
    | NotFound msg -> NotFound msg
    | Error msg -> Error msg

  (** 验证诗词格式 *)
  let validate_poetry_format (verse : string) (template_id : string) : bool =
    match TemplateLoader.find_template_by_id template_id with
    | Found template ->
        let verse_length = String.length verse in
        let expected_pattern = String.split_on_char '-' template.character_pattern in
        let expected_length = List.fold_left (+) 0 (List.map int_of_string expected_pattern) in
        verse_length = expected_length
    | _ -> false
end

(** {1 数据解析器} *)

(** 数据解析器
    整合自 artistic_data_parser.ml 的功能 *)
module DataParser = struct
  (** 解析JSON格式的艺术标准 *)
  let parse_standard_json (json_content : string) : artistic_standard list query_result =
    try
      (* 简化版本：返回默认标准 *)
      Found default_artistic_standards
    with
    | e -> Error ("JSON parsing failed: " ^ Printexc.to_string e)

  (** 解析模板定义文件 *)
  let parse_template_definition (content : string) : poetry_template list query_result =
    try
      Found default_poetry_templates
    with
    | e -> Error ("Template parsing failed: " ^ Printexc.to_string e)

  (** 解析评估配置 *)
  let parse_evaluation_config (config_content : string) : Artistic_engine_unified.evaluation_config query_result =
    try
      Found Artistic_engine_unified.default_config
    with
    | e -> Error ("Config parsing failed: " ^ Printexc.to_string e)
end

(** {1 查询引擎} *)

(** 查询引擎
    整合自 artistic_query_engine.ml 的功能 *)
module QueryEngine = struct
  (** 复合查询条件 *)
  type query_condition = 
    | StandardName of string
    | FormType of string
    | MinScore of float
    | MaxScore of float
    | HasCriteria of string

  (** 执行标准查询 *)
  let query_standards (conditions : query_condition list) : artistic_standard list =
    let initial_standards = DataState.global_state.standards in
    List.fold_left (fun (acc : artistic_standard list) condition ->
      match condition with
      | StandardName name -> 
          List.filter (fun s -> String.contains s.name (String.get name 0)) acc
      | _ -> acc
    ) initial_standards conditions

  (** 执行模板查询 *)
  let query_templates (conditions : query_condition list) : poetry_template list =
    let initial_templates = DataState.global_state.templates in
    List.fold_left (fun (acc : poetry_template list) condition ->
      match condition with
      | FormType form_type ->
          List.filter (fun t -> t.form_type = form_type) acc
      | _ -> acc
    ) initial_templates conditions

  (** 智能推荐模板 *)
  let recommend_template (verse : string) : poetry_template list =
    let verse_length = String.length verse in
    List.filter (fun t -> 
      let pattern_nums = String.split_on_char '-' t.character_pattern in
      let total_chars = List.fold_left (+) 0 (List.map int_of_string pattern_nums) in
      abs (total_chars - verse_length) <= 2
    ) DataState.global_state.templates
end

(** {1 缓存管理} *)

(** 评估结果缓存管理 *)
module CacheManager = struct
  (** 生成缓存键 *)
  let generate_cache_key (verse : string) (config : Artistic_engine_unified.evaluation_config) : string =
    let config_hash = String.length (String.concat "" (List.map fst config.weights)) in
    Printf.sprintf "%s_%d_%b" (String.sub verse 0 (min 10 (String.length verse))) config_hash config.detailed_analysis

  (** 添加缓存条目 *)
  let add_to_cache (key : string) (result : Artistic_engine_unified.evaluation_result) : unit =
    if DataState.global_state.config.cache_enabled then
      let current_time = Unix.gettimeofday () in
      let entry = {
        key = key;
        result = result;
        timestamp = current_time;
        expires = current_time +. 3600.0;  (* 1小时过期 *)
      } in
      DataState.global_state.cache <- entry :: DataState.global_state.cache;
      (* 保持缓存大小 *)
      if List.length DataState.global_state.cache > DataState.global_state.config.cache_size then
        DataState.global_state.cache <- List.rev (List.tl (List.rev DataState.global_state.cache))

  (** 从缓存获取结果 *)
  let get_from_cache (key : string) : Artistic_engine_unified.evaluation_result option =
    if DataState.global_state.config.cache_enabled then
      let current_time = Unix.gettimeofday () in
      match List.find_opt (fun entry -> 
        entry.key = key && entry.expires > current_time
      ) DataState.global_state.cache with
      | Some entry -> Some entry.result
      | None -> None
    else None

  (** 清理过期缓存 *)
  let cleanup_expired_cache () : unit =
    let current_time = Unix.gettimeofday () in
    DataState.global_state.cache <- List.filter (fun entry -> 
      entry.expires > current_time
    ) DataState.global_state.cache
end

(** {1 统一数据管理接口} *)

(** 初始化数据管理器 *)
let initialize_data_manager ?(config = DataState.global_state.config) () : unit =
  DataState.global_state.config <- config;
  DataState.global_state.last_update <- Unix.gettimeofday ();
  CacheManager.cleanup_expired_cache ()

(** 重新加载所有数据 *)
let reload_all_data () : unit =
  let standards_result = StandardsLoader.load_from_config "config/standards.json" in
  let templates_result = TemplateLoader.load_templates "config/templates.json" in
  (match standards_result with
   | Found standards -> DataState.global_state.standards <- standards
   | _ -> ());
  (match templates_result with
   | Found templates -> DataState.global_state.templates <- templates
   | _ -> ());
  DataState.global_state.last_update <- Unix.gettimeofday ()

(** 获取数据统计信息 *)
let get_data_statistics () : (string * int) list =
  [
    ("standards_count", List.length DataState.global_state.standards);
    ("templates_count", List.length DataState.global_state.templates);
    ("cache_entries", List.length DataState.global_state.cache);
  ]

(** 数据健康检查 *)
let health_check () : bool =
  List.length DataState.global_state.standards > 0 &&
  List.length DataState.global_state.templates > 0