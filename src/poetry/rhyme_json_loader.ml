(** 韵律JSON数据加载器 - 外部化韵律数据管理
    
    此模块负责从外部JSON文件加载韵律数据，替代硬编码的数据定义。
    提供安全的错误处理和降级机制，确保系统稳定性。
    
    @author 骆言诗词编程团队 
    @version 1.0
    @since 2025-07-19 - Phase 17.2 韵律数据外部化重构 *)

(* 本地韵律类型定义，避免循环依赖 *)

(** 韵类定义 *)
type rhyme_category =
  | PingSheng
  | ZeSheng
  | ShangSheng
  | QuSheng
  | RuSheng

(** 韵组定义 *)
type rhyme_group =
  | AnRhyme
  | SiRhyme
  | TianRhyme
  | WangRhyme
  | QuRhyme
  | YuRhyme
  | HuaRhyme
  | FengRhyme
  | YueRhyme
  | XueRhyme
  | JiangRhyme
  | HuiRhyme
  | UnknownRhyme

(** {1 JSON解析异常} *)

exception Json_parse_error of string
(** JSON解析错误异常 *)

exception Rhyme_data_not_found of string
(** 韵律数据未找到异常 *)

(** {1 数据类型定义} *)

type rhyme_group_data = {
  category: string;
  characters: string list;
}
(** 韵组数据类型 *)

type rhyme_data_file = {
  rhyme_groups: (string * rhyme_group_data) list;
  metadata: (string * string) list;
}
(** 韵律数据文件类型 *)

(** {1 配置和常量} *)

(** 默认数据文件路径 *)
let default_data_file = "data/poetry/rhyme_groups/rhyme_data.json"

(** 缓存TTL (秒) - 5分钟 *)
let cache_ttl = 300.0

(** {1 内存缓存} *)

(** 缓存的韵律数据 *)
let cached_data = ref None

(** 缓存时间戳 *)
let cache_timestamp = ref 0.0

(** 缓存是否有效 *)
let is_cache_valid () =
  match !cached_data with
  | None -> false
  | Some _ ->
    let current_time = Unix.time () in
    (current_time -. !cache_timestamp) < cache_ttl

(** {1 JSON解析函数} *)

(** 简化的JSON字符串解析 - 移除引号和逗号 *)
let clean_json_string s =
  let s = String.trim s in
  let len = String.length s in
  if len = 0 then ""
  else
    let s = 
      if len >= 2 && s.[0] = '"' && s.[len-1] = '"' then
        String.sub s 1 (len - 2)
      else s
    in
    let s_len = String.length s in
    let s = if s_len > 0 && s.[s_len - 1] = ',' then
      String.sub s 0 (s_len - 1)
    else s
    in
    String.trim s


(** {1 韵类转换函数} *)

(** 将字符串转换为韵类 *)
let string_to_rhyme_category = function
  | "ping_sheng" -> PingSheng
  | "shang_sheng" -> ShangSheng  
  | "qu_sheng" -> QuSheng
  | "ru_sheng" -> RuSheng
  | "ze_sheng" -> ZeSheng
  | _ -> PingSheng (* 默认为平声 *)

(** 将字符串转换为韵组 *)
let string_to_rhyme_group = function
  | "an_rhyme" -> AnRhyme
  | "si_rhyme" -> SiRhyme
  | "tian_rhyme" -> TianRhyme
  | "wang_rhyme" -> WangRhyme
  | "qu_rhyme" -> QuRhyme
  | "yu_rhyme" -> YuRhyme
  | "hua_rhyme" -> HuaRhyme
  | "feng_rhyme" -> FengRhyme
  | "yue_rhyme" -> YueRhyme
  | "xue_rhyme" -> XueRhyme
  | "jiang_rhyme" -> JiangRhyme
  | "hui_rhyme" -> HuiRhyme
  | _ -> UnknownRhyme

(** {1 文件读取函数} *)

(** 安全读取文件内容 *)
let safe_read_file filename =
  try
    let ic = open_in filename in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    Some content
  with 
  | Sys_error _ -> None
  | _ -> None

(** {1 数据加载和解析} *)

(** 安全的JSON解析 - 处理嵌套结构 *)
let parse_nested_json content =
  let lines = String.split_on_char '\n' content in
  let rhyme_groups = ref [] in
  let current_group = ref "" in
  let current_category = ref "" in
  let current_chars = ref [] in
  let in_rhyme_groups = ref false in
  let in_group = ref false in
  let in_characters = ref false in
  
  List.iter (fun line ->
    let trimmed = String.trim line in
    
    (* 安全检查字符串长度 *)
    if String.length trimmed > 0 then (
      if String.contains trimmed ':' then (
        if Str.string_match (Str.regexp ".*rhyme_groups.*") trimmed 0 then (
          in_rhyme_groups := true
        ) else if !in_rhyme_groups && Str.string_match (Str.regexp ".*_rhyme.*") trimmed 0 then (
          (* 保存前一个组的数据 *)
          if !current_group <> "" && !current_category <> "" then (
            let group_data = { category = !current_category; characters = List.rev !current_chars } in
            rhyme_groups := (!current_group, group_data) :: !rhyme_groups
          );
          (* 安全解析新组 *)
          let parts = String.split_on_char ':' trimmed in
          if List.length parts >= 1 then (
            let key = List.hd parts in
            current_group := clean_json_string key;
            current_category := "";
            current_chars := [];
            in_group := true;
            in_characters := false
          )
        ) else if !in_group && Str.string_match (Str.regexp ".*category.*") trimmed 0 then (
          let parts = String.split_on_char ':' trimmed in
          if List.length parts >= 2 then (
            let value = List.nth parts 1 in
            current_category := clean_json_string value
          )
        ) else if !in_group && Str.string_match (Str.regexp ".*characters.*") trimmed 0 then (
          in_characters := true
        )
      ) else if !in_characters && trimmed <> "" && not (trimmed = "[" || trimmed = "]") then (
        if String.length trimmed > 0 && trimmed.[0] = '"' then (
          let char = clean_json_string trimmed in
          if String.length char > 0 then
            current_chars := char :: !current_chars
        )
      ) else if trimmed = "}" && !in_group then (
        in_group := false;
        in_characters := false
      )
    )
  ) lines;
  
  (* 保存最后一个组 *)
  if !current_group <> "" && !current_category <> "" then (
    let group_data = { category = !current_category; characters = List.rev !current_chars } in
    rhyme_groups := (!current_group, group_data) :: !rhyme_groups
  );
  
  List.rev !rhyme_groups

(** 从JSON文件加载韵律数据 *)
let load_rhyme_data_from_file ?(filename = default_data_file) () =
  match safe_read_file filename with
  | None -> 
    Yyocamlc_lib.Unified_logger.warning "RhymeJsonLoader" 
      (Printf.sprintf "无法读取韵律数据文件: %s" filename);
    None
  | Some content ->
    try
      let rhyme_groups = parse_nested_json content in
      let data = { rhyme_groups; metadata = [] } in
      Some data
    with e ->
      Yyocamlc_lib.Unified_logger.error "RhymeJsonLoader" 
        (Printf.sprintf "解析韵律数据失败: %s" (Printexc.to_string e));
      None

(** {1 缓存管理} *)

(** 获取韵律数据（带缓存） *)
let get_rhyme_data ?(force_reload = false) () =
  if force_reload || not (is_cache_valid ()) then (
    match load_rhyme_data_from_file () with
    | Some data ->
      cached_data := Some data;
      cache_timestamp := Unix.time ();
      Yyocamlc_lib.Unified_logger.info "RhymeJsonLoader" "韵律数据加载成功";
      Some data
    | None ->
      Yyocamlc_lib.Unified_logger.warning "RhymeJsonLoader" "韵律数据加载失败，使用缓存数据";
      !cached_data
  ) else (
    Yyocamlc_lib.Unified_logger.debug "RhymeJsonLoader" "使用缓存的韵律数据";
    !cached_data
  )

(** {1 数据访问接口} *)

(** 获取所有韵组数据 *)
let get_all_rhyme_groups () =
  match get_rhyme_data () with
  | Some data -> data.rhyme_groups
  | None -> []

(** 获取指定韵组的字符列表 *)
let get_rhyme_group_characters group_name =
  let groups = get_all_rhyme_groups () in
  try
    let (_, group_data) = List.find (fun (name, _) -> name = group_name) groups in
    group_data.characters
  with Not_found -> []

(** 获取指定韵组的韵类 *)
let get_rhyme_group_category group_name =
  let groups = get_all_rhyme_groups () in
  try
    let (_, group_data) = List.find (fun (name, _) -> name = group_name) groups in
    string_to_rhyme_category group_data.category
  with Not_found -> PingSheng

(** {1 向后兼容接口} *)

(** 获取韵律映射表 - (字符 -> (韵类, 韵组)) *)
let get_rhyme_mappings () =
  let groups = get_all_rhyme_groups () in
  let mappings = ref [] in
  List.iter (fun (group_name, group_data) ->
    let rhyme_category = string_to_rhyme_category group_data.category in
    let rhyme_group = string_to_rhyme_group group_name in
    List.iter (fun char ->
      mappings := (char, (rhyme_category, rhyme_group)) :: !mappings
    ) group_data.characters
  ) groups;
  !mappings

(** {1 统计和调试} *)

(** 获取加载的韵律数据统计信息 *)
let get_data_statistics () =
  match get_rhyme_data () with
  | Some data ->
    let total_groups = List.length data.rhyme_groups in
    let total_chars = List.fold_left (fun acc (_, group_data) ->
      acc + List.length group_data.characters
    ) 0 data.rhyme_groups in
    Some (total_groups, total_chars)
  | None -> None

(** 打印韵律数据统计信息 *)
let print_statistics () =
  match get_data_statistics () with
  | Some (groups, chars) ->
    Yyocamlc_lib.Unified_logger.info "RhymeJsonLoader" 
      (Printf.sprintf "韵律数据统计: %d个韵组, %d个字符" groups chars)
  | None ->
    Yyocamlc_lib.Unified_logger.warning "RhymeJsonLoader" "无韵律数据可统计"

(** {1 降级机制} *)

(** 提供基本的硬编码降级数据 *)
let fallback_rhyme_data = [
  ("an_rhyme", { category = "ping_sheng"; characters = ["安"; "山"; "天"; "年"] });
  ("feng_rhyme", { category = "ping_sheng"; characters = ["风"; "中"; "东"; "红"] });
]

(** 使用降级数据 *)
let use_fallback_data () =
  Yyocamlc_lib.Unified_logger.warning "RhymeJsonLoader" "使用降级韵律数据";
  let data = { rhyme_groups = fallback_rhyme_data; metadata = [] } in
  cached_data := Some data;
  cache_timestamp := Unix.time ()