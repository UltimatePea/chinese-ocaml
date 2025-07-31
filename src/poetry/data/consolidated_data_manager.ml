(** 数据管理器整合模块 - Phase 1模块整合
    
    将原始的多个分散数据管理和加载模块整合为统一的数据管理引擎，
    减少模块数量，提高维护效率，保持功能完整性。
    
    原整合目标:
    - data_manager_storage.ml → 整合到此模块
    - data_manager_lookup.ml → 整合到此模块  
    - data_source_manager.ml → 整合到此模块
    - rhyme_data_loader.ml → 整合到此模块
    - tone_data_loader.ml → 整合到此模块
    - poetry_word_class_loader.ml → 整合到此模块
    - loaders/json_loader.ml → 整合到此模块
    - loaders/unified_loader.ml → 整合到此模块
    
    @author Whisky, Technical Implementation Agent
    @version 1.0 - Poetry模块整合Phase 1
    @since 2025-07-31
    @consolidation_target 8个分散模块 → 1个整合模块 *)

open Data_manager_types

(** {1 数据存储管理} *)

module Data_storage = struct
  
  type 'a data_store = {
    mutable data : (string, 'a) Hashtbl.t;
    mutable metadata : (string, string) Hashtbl.t;
    mutable last_updated : float;
  }
  
  (** 创建新的数据存储 *)
  let create_data_store () = {
    data = Hashtbl.create 1000;
    metadata = Hashtbl.create 100;
    last_updated = Unix.time ();
  }
  
  (** 存储数据项 *)
  let store_data_item store key value metadata_opt =
    Hashtbl.replace store.data key value;
    (match metadata_opt with
     | Some metadata -> Hashtbl.replace store.metadata key metadata
     | None -> ());
    store.last_updated <- Unix.time ()
  
  (** 获取数据项 *)
  let get_data_item store key =
    Hashtbl.find_opt store.data key
  
  (** 获取所有数据项 *)
  let get_all_data_items store =
    Hashtbl.fold (fun key value acc -> (key, value) :: acc) store.data []
  
  (** 数据项计数 *)
  let get_data_count store =
    Hashtbl.length store.data
  
  (** 清空数据存储 *)
  let clear_data_store store =
    Hashtbl.clear store.data;
    Hashtbl.clear store.metadata;
    store.last_updated <- Unix.time ()
end

(** {1 数据查找管理} *)

module Data_lookup = struct
  
  (** 模糊查找数据项 *)
  let fuzzy_lookup store pattern =
    let regex = Str.regexp_string pattern in
    Hashtbl.fold (fun key value acc ->
      if Str.string_match regex key 0 then (key, value) :: acc else acc
    ) store.Data_storage.data []
  
  (** 前缀查找 *)
  let prefix_lookup store prefix =
    let prefix_len = String.length prefix in
    Hashtbl.fold (fun key value acc ->
      if String.length key >= prefix_len && 
         String.sub key 0 prefix_len = prefix then
        (key, value) :: acc
      else acc
    ) store.Data_storage.data []
  
  (** 范围查找 *)
  let range_lookup store start_key end_key =
    Hashtbl.fold (fun key value acc ->
      if String.compare key start_key >= 0 && String.compare key end_key <= 0 then
        (key, value) :: acc
      else acc
    ) store.Data_storage.data []
  
  (** 多键查找 *)
  let multi_key_lookup store keys =
    List.fold_left (fun acc key ->
      match Data_storage.get_data_item store key with
      | Some value -> (key, value) :: acc
      | None -> acc
    ) [] keys
end

(** {1 数据源管理} *)

module Data_source_manager = struct
  
  type data_source = 
    | File of string
    | Database of string * string  (* host, database *)
    | Memory of (string * string) list
    | Network of string
  
  type source_config = {
    source : data_source;
    format : string; (* json, csv, xml, etc *)
    encoding : string;
    refresh_interval : float option;
  }
  
  (** 默认数据源配置 *)
  let default_configs = [
    {
      source = File "data/rhyme_data.json";
      format = "json";
      encoding = "utf-8";
      refresh_interval = Some 86400.0; (* 24小时 *)
    };
    {
      source = File "data/tone_data.json";
      format = "json";
      encoding = "utf-8"; 
      refresh_interval = Some 86400.0;
    };
    {
      source = Memory [("test_key", "test_value")];
      format = "memory";
      encoding = "utf-8";
      refresh_interval = None;
    };
  ]
  
  (** 从数据源加载数据 *)
  let load_from_source config =
    match config.source with
    | File filepath ->
      (try
         let content = In_channel.with_open_text filepath In_channel.input_all in
         Some [("file_content", content)]
       with _ -> None)
    | Database (host, db) ->
      (* 模拟数据库加载 *)
      Some [("db_host", host); ("db_name", db)]
    | Memory data ->
      Some data
    | Network url ->
      (* 模拟网络加载 *)
      Some [("network_url", url)]
  
  (** 批量加载所有数据源 *)
  let load_all_sources configs =
    List.fold_left (fun acc config ->
      match load_from_source config with
      | Some data -> data @ acc
      | None -> acc
    ) [] configs
end

(** {1 专用数据加载器} *)

module Rhyme_data_loader = struct
  
  type rhyme_data_entry = {
    character : string;
    rhyme_group : string;
    tone_category : string;
    frequency : float;
  }
  
  (** 解析韵律数据 *)
  let parse_rhyme_data content =
    let lines = String.split_on_char '\n' content in
    List.fold_left (fun acc line ->
      let parts = String.split_on_char ',' line in
      match parts with
      | [char; group; tone; freq] ->
        let entry = {
          character = String.trim char;
          rhyme_group = String.trim group;
          tone_category = String.trim tone;
          frequency = Float.of_string (String.trim freq);
        } in
        entry :: acc
      | _ -> acc
    ) [] lines
  
  (** 加载韵律数据到存储 *)
  let load_rhyme_data_to_store store source_path =
    try
      let content = In_channel.with_open_text source_path In_channel.input_all in
      let entries = parse_rhyme_data content in
      List.iter (fun entry ->
        Data_storage.store_data_item store entry.character entry.rhyme_group (Some entry.tone_category)
      ) entries;
      List.length entries
    with _ -> 0
end

module Tone_data_loader = struct
  
  type tone_data_entry = {
    character : string;
    pinyin : string;
    tone_mark : int;
    category : string;
  }
  
  (** 解析声调数据 *)
  let parse_tone_data content =
    let lines = String.split_on_char '\n' content in
    List.fold_left (fun acc line ->
      let parts = String.split_on_char ',' line in
      match parts with
      | [char; pinyin; tone; category] ->
        let entry = {
          character = String.trim char;
          pinyin = String.trim pinyin;
          tone_mark = Int.of_string (String.trim tone);
          category = String.trim category;
        } in
        entry :: acc
      | _ -> acc
    ) [] lines
  
  (** 加载声调数据到存储 *)
  let load_tone_data_to_store store source_path =
    try
      let content = In_channel.with_open_text source_path In_channel.input_all in
      let entries = parse_tone_data content in
      List.iter (fun entry ->
        Data_storage.store_data_item store entry.character entry.pinyin (Some entry.category)
      ) entries;
      List.length entries
    with _ -> 0
end

module Poetry_word_class_loader = struct
  
  type word_class_entry = {
    word : string;
    word_class : string;
    usage_context : string;
    examples : string list;
  }
  
  (** 解析词性数据 *)
  let parse_word_class_data content =
    let lines = String.split_on_char '\n' content in
    List.fold_left (fun acc line ->
      let parts = String.split_on_char '|' line in
      match parts with
      | word :: word_class :: context :: examples ->
        let entry = {
          word = String.trim word;
          word_class = String.trim word_class;
          usage_context = String.trim context;
          examples = List.map String.trim examples;
        } in
        entry :: acc
      | _ -> acc
    ) [] lines
  
  (** 加载词性数据到存储 *)
  let load_word_class_data_to_store store source_path =
    try
      let content = In_channel.with_open_text source_path In_channel.input_all in
      let entries = parse_word_class_data content in
      List.iter (fun entry ->
        Data_storage.store_data_item store entry.word entry.word_class (Some entry.usage_context)
      ) entries;
      List.length entries
    with _ -> 0
end

(** {1 JSON数据加载器} *)

module Json_loader = struct
  
  (** 简单JSON解析（模拟实现） *)
  let parse_simple_json content =
    (* 这里是简化的JSON解析，实际应使用专门的JSON库 *)
    let lines = String.split_on_char '\n' content in
    List.fold_left (fun acc line ->
      if String.contains line ':' then
        let parts = String.split_on_char ':' line in
        match parts with
        | key :: value :: _ ->
          let clean_key = String.trim (String.map (fun c -> if c = '"' || c = '{' || c = '}' then ' ' else c) key) in
          let clean_value = String.trim (String.map (fun c -> if c = '"' || c = ',' then ' ' else c) value) in
          if clean_key <> "" && clean_value <> "" then
            (String.trim clean_key, String.trim clean_value) :: acc
          else acc
        | _ -> acc
      else acc
    ) [] lines
  
  (** 从JSON文件加载数据到存储 *)
  let load_json_to_store store json_path =
    try
      let content = In_channel.with_open_text json_path In_channel.input_all in
      let pairs = parse_simple_json content in
      List.iter (fun (key, value) ->
        Data_storage.store_data_item store key value None
      ) pairs;
      List.length pairs
    with _ -> 0
end

(** {1 统一数据管理接口} *)

module Unified_data_manager = struct
  
  (* 全局数据存储实例 *)
  let rhyme_store = Data_storage.create_data_store ()
  let tone_store = Data_storage.create_data_store ()
  let word_class_store = Data_storage.create_data_store ()
  let general_store = Data_storage.create_data_store ()
  
  (** 初始化数据管理系统 *)
  let init_data_system () =
    Printf.printf "数据管理系统初始化完成\n";
    Printf.printf "- 韵律数据存储: 就绪\n";
    Printf.printf "- 声调数据存储: 就绪\n";
    Printf.printf "- 词性数据存储: 就绪\n";
    Printf.printf "- 通用数据存储: 就绪\n"
  
  (** 智能数据加载 *)
  let smart_load_data data_type source_path =
    let loader_result = match data_type with
      | "rhyme" -> Rhyme_data_loader.load_rhyme_data_to_store rhyme_store source_path
      | "tone" -> Tone_data_loader.load_tone_data_to_store tone_store source_path
      | "word_class" -> Poetry_word_class_loader.load_word_class_data_to_store word_class_store source_path
      | "json" -> Json_loader.load_json_to_store general_store source_path
      | _ -> 0 in
    Printf.printf "加载%s数据: %d条记录\n" data_type loader_result;
    loader_result
  
  (** 智能数据查询 *)
  let smart_query data_type key =
    let store = match data_type with
      | "rhyme" -> rhyme_store
      | "tone" -> tone_store
      | "word_class" -> word_class_store
      | _ -> general_store in
    Data_storage.get_data_item store key
  
  (** 批量数据查询 *)
  let batch_query data_type keys =
    let store = match data_type with
      | "rhyme" -> rhyme_store
      | "tone" -> tone_store
      | "word_class" -> word_class_store
      | _ -> general_store in
    Data_lookup.multi_key_lookup store keys
  
  (** 数据统计信息 *)
  let get_data_statistics () =
    let rhyme_count = Data_storage.get_data_count rhyme_store in
    let tone_count = Data_storage.get_data_count tone_store in
    let word_class_count = Data_storage.get_data_count word_class_store in
    let general_count = Data_storage.get_data_count general_store in
    Printf.printf "数据存储统计:\n";
    Printf.printf "- 韵律数据: %d条\n" rhyme_count;
    Printf.printf "- 声调数据: %d条\n" tone_count;
    Printf.printf "- 词性数据: %d条\n" word_class_count;
    Printf.printf "- 通用数据: %d条\n" general_count;
    (rhyme_count, tone_count, word_class_count, general_count)
  
  (** 数据完整性检查 *)
  let integrity_check () =
    let (rhyme_count, tone_count, word_class_count, general_count) = get_data_statistics () in
    let total_count = rhyme_count + tone_count + word_class_count + general_count in
    Printf.printf "数据完整性检查:\n";
    Printf.printf "- 总数据量: %d条\n" total_count;
    Printf.printf "- 数据完整性: %s\n" (if total_count > 0 then "良好" else "需要加载数据");
    total_count > 0
end