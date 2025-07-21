(** 骆言编译器配置加载器模块 *)

(** 检查行是否为有效的配置行 *)
let is_valid_config_line line =
  let trimmed = String.trim line in
  String.length trimmed > 0 && not (String.get trimmed 0 = '#')

(** 移除字符串首尾的引号 *)
let remove_quotes s =
  let len = String.length s in
  if len >= 2 && String.get s 0 = '"' && String.get s (len - 1) = '"' then String.sub s 1 (len - 2)
  else s

(** 移除字符串末尾的逗号 *)
let remove_trailing_comma s =
  let len = String.length s in
  if len > 0 && String.get s (len - 1) = ',' then String.sub s 0 (len - 1) else s

(** 清理JSON值字符串，移除引号和逗号 *)
let clean_json_value value_part =
  value_part |> String.trim |> remove_quotes |> remove_trailing_comma |> String.trim

(** 清理JSON键，移除引号和多余空格 *)
let clean_json_key key = key |> String.map (function '"' -> ' ' | c -> c) |> String.trim

(** 安全转换字符串为整数 *)
let safe_int_of_string s f = try f (int_of_string s) with _ -> ()

(** 安全转换字符串为浮点数 *)
let safe_float_of_string s f = try f (float_of_string s) with _ -> ()

(** 配置键映射表 - 数据与逻辑分离架构 *)
let config_key_mappings =
  [
    (* 运行时配置 *)
    ("debug_mode", fun value -> Runtime_config.update_debug_mode (value = "true"));
    (* 编译器配置 - 整数类型 *)
    ("buffer_size", fun value -> safe_int_of_string value Compiler_config.update_buffer_size);
    ( "optimization_level",
      fun value -> safe_int_of_string value Compiler_config.update_optimization_level );
    (* 编译器配置 - 浮点数类型 *)
    ("timeout", fun value -> safe_float_of_string value Compiler_config.update_compilation_timeout);
    (* 编译器配置 - 字符串类型 *)
    ("output_directory", fun value -> Compiler_config.update_output_directory value);
    ("c_compiler", fun value -> Compiler_config.update_c_compiler value);
  ]

(** 配置键快速查找哈希表 *)
let config_key_table =
  let table = Hashtbl.create (List.length config_key_mappings) in
  List.iter (fun (key, handler) -> Hashtbl.add table key handler) config_key_mappings;
  table

(** 根据键名应用配置值 - 优化后的查表实现 *)
let apply_config_value key value =
  let normalized_key = clean_json_key key in
  try
    let handler = Hashtbl.find config_key_table normalized_key in
    handler value
  with Not_found -> ()

(** 解析单行配置 *)
let parse_config_line line =
  if is_valid_config_line line then
    try
      let trimmed = String.trim line in
      let colon_pos = String.index trimmed ':' in
      let key = String.trim (String.sub trimmed 0 colon_pos) in
      let value_part =
        String.trim (String.sub trimmed (colon_pos + 1) (String.length trimmed - colon_pos - 1))
      in
      let value = clean_json_value value_part in
      apply_config_value key value
    with _ -> ()

(** 本地错误类型 - 避免依赖循环 *)
type config_error = 
  | JsonFormatError of string
  | EmptyContent

(** JSON配置文件支持（简化版） *)
let parse_json_config_simple content =
  (* 简单检查JSON格式 - 检查括号匹配 *)
  let check_json_format content =
    let trimmed = String.trim content in
    if String.length trimmed = 0 then
      Error EmptyContent
    else
      let first_char = String.get trimmed 0 in
      let last_char = String.get trimmed (String.length trimmed - 1) in
      if first_char = '{' then
        if last_char <> '}' then 
          Error (JsonFormatError "JSON format error: unclosed brace")
        else Ok ()
      else if String.contains trimmed '{' && not (String.contains trimmed '}') then
        Error (JsonFormatError "JSON format error: unclosed brace")
      else Ok ()
  in
  
  match check_json_format content with
  | Ok () -> content |> String.split_on_char '\n' |> List.iter parse_config_line; Ok ()
  | Error err -> Error err

(** 从配置文件加载 *)
let load_from_file filename =
  try
    let ic = open_in filename in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    match parse_json_config_simple content with
    | Ok () -> true
    | Error err -> 
        (* 记录错误但不中断程序 *)
        let error_msg = match err with
          | JsonFormatError msg -> msg
          | EmptyContent -> "JSON format error: empty content"
        in
        Printf.eprintf "配置文件错误: %s\n%!" error_msg; false
  with _ -> false

(** 配置初始化 *)
let init_config ?(config_file = "config.json") () =
  (* 首先重置到默认配置 *)
  Unified_config.reset_to_defaults ();

  (* 然后从配置文件加载 *)
  let _ = load_from_file config_file in

  (* 最后从环境变量加载（优先级最高） *)
  Unified_config.load_all_from_env ();

  (* 创建必要的目录 *)
  let compiler_cfg = Compiler_config.get () in
  (try Unix.mkdir compiler_cfg.output_directory 0o755 with _ -> ());
  try Unix.mkdir compiler_cfg.temp_directory 0o755 with _ -> ()

(** 配置验证 *)
let validate_config () =
  let compiler_cfg = Compiler_config.get () in
  let runtime_cfg = Runtime_config.get () in
  let errors = ref [] in

  (* 验证编译器配置 *)
  if not (Unified_config.validate_compiler_config compiler_cfg) then
    errors := "编译器配置验证失败" :: !errors;

  (* 验证运行时配置 *)
  if not (Unified_config.validate_runtime_config runtime_cfg) then errors := "运行时配置验证失败" :: !errors;

  !errors
