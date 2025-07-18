(** 骆言编译器统一配置管理模块 *)

type compiler_config = {
  (* 缓冲区配置 *)
  buffer_size : int;  (** 默认缓冲区大小 *)
  large_buffer_size : int;  (** 大缓冲区大小 *)
  report_buffer_size : int;  (** 报告缓冲区大小 *)
  utf8_char_buffer_size : int;  (** UTF-8字符缓冲区大小 *)
  (* 超时配置 *)
  compilation_timeout : float;  (** 编译超时（秒） *)
  test_timeout : float;  (** 测试超时（秒） *)
  (* 文件路径配置 *)
  output_directory : string;  (** 输出目录 *)
  temp_directory : string;  (** 临时文件目录 *)
  runtime_directory : string;  (** 运行时库目录 *)
  default_c_output : string;  (** 默认C输出文件名 *)
  temp_file_prefix : string;  (** 临时文件前缀 *)
  (* C编译器配置 *)
  c_compiler : string;  (** C编译器名称 *)
  c_compiler_flags : string list;  (** C编译器标志 *)
  optimization_level : int;  (** 优化级别 (0-3) *)
  debug_symbols : bool;  (** 是否包含调试符号 *)
  (* 哈希表配置 *)
  default_hashtable_size : int;  (** 默认哈希表大小 *)
  large_hashtable_size : int;  (** 大哈希表大小 *)
  (* 性能调优配置 *)
  max_iterations : int;  (** 最大迭代次数 *)
  confidence_threshold : float;  (** 置信度阈值 *)
}
(** 编译器配置类型定义 *)

type runtime_config = {
  (* 调试配置 *)
  debug_mode : bool;  (** 调试模式 *)
  verbose_logging : bool;  (** 详细日志 *)
  log_level : string;  (** 日志级别: debug, info, warn, error *)
  (* 错误处理配置 *)
  error_recovery : bool;  (** 错误恢复机制 *)
  max_error_count : int;  (** 最大错误数量 *)
  continue_on_error : bool;  (** 遇到错误时是否继续 *)
  show_suggestions : bool;  (** 是否显示建议 *)
  colored_output : bool;  (** 彩色输出 *)
  (* 智能功能配置 *)
  spell_correction : bool;  (** 拼写纠正 *)
  type_inference : bool;  (** 类型推断 *)
  auto_completion : bool;  (** 自动补全 *)
  code_formatting : bool;  (** 代码格式化 *)
}
(** 运行时配置类型定义 *)

(** 默认编译器配置 *)
let default_compiler_config =
  {
    (* 缓冲区配置 *)
    buffer_size = 256;
    large_buffer_size = 1024;
    report_buffer_size = 4096;
    utf8_char_buffer_size = 8;
    (* 超时配置 *)
    compilation_timeout = 30.0;
    test_timeout = 5.0;
    (* 文件路径配置 *)
    output_directory = "./output";
    temp_directory = "/tmp/chinese-ocaml";
    runtime_directory = "C后端/runtime/";
    default_c_output = "output.c";
    temp_file_prefix = "yyocamlc";
    (* C编译器配置 *)
    c_compiler = "clang";
    c_compiler_flags = [ "-Wall"; "-Wextra"; "-std=c99" ];
    optimization_level = 2;
    debug_symbols = false;
    (* 哈希表配置 *)
    default_hashtable_size = 16;
    large_hashtable_size = 256;
    (* 性能调优配置 *)
    max_iterations = 1000;
    confidence_threshold = 0.8;
  }

(** 默认运行时配置 *)
let default_runtime_config =
  {
    (* 调试配置 *)
    debug_mode = false;
    verbose_logging = false;
    log_level = "info";
    (* 错误处理配置 *)
    error_recovery = true;
    max_error_count = 10;
    continue_on_error = true;
    show_suggestions = true;
    colored_output = false;
    (* 智能功能配置 *)
    spell_correction = true;
    type_inference = true;
    auto_completion = false;
    code_formatting = true;
  }

(** 全局配置变量 *)
let compiler_config = ref default_compiler_config

let runtime_config = ref default_runtime_config

(** 配置获取函数 *)
let get_compiler_config () = !compiler_config

let get_runtime_config () = !runtime_config

(** 配置设置函数 *)
let set_compiler_config config = compiler_config := config

let set_runtime_config config = runtime_config := config

(** 环境变量映射 *)
let env_var_mappings =
  [
    ( "CHINESE_OCAML_DEBUG",
      fun v ->
        let debug = String.lowercase_ascii v = "true" || v = "1" in
        runtime_config := { !runtime_config with debug_mode = debug } );
    ( "CHINESE_OCAML_VERBOSE",
      fun v ->
        let verbose = String.lowercase_ascii v = "true" || v = "1" in
        runtime_config := { !runtime_config with verbose_logging = verbose } );
    ( "CHINESE_OCAML_BUFFER_SIZE",
      fun v ->
        try
          let size = int_of_string v in
          if size > 0 then compiler_config := { !compiler_config with buffer_size = size }
        with _ -> () );
    ( "CHINESE_OCAML_TIMEOUT",
      fun v ->
        try
          let timeout = float_of_string v in
          if timeout > 0.0 then
            compiler_config := { !compiler_config with compilation_timeout = timeout }
        with _ -> () );
    ( "CHINESE_OCAML_OUTPUT_DIR",
      fun v ->
        if String.length v > 0 then
          compiler_config := { !compiler_config with output_directory = v } );
    ( "CHINESE_OCAML_TEMP_DIR",
      fun v ->
        if String.length v > 0 then compiler_config := { !compiler_config with temp_directory = v }
    );
    ( "CHINESE_OCAML_C_COMPILER",
      fun v ->
        if String.length v > 0 then compiler_config := { !compiler_config with c_compiler = v } );
    ( "CHINESE_OCAML_OPT_LEVEL",
      fun v ->
        try
          let level = int_of_string v in
          if level >= 0 && level <= 3 then
            compiler_config := { !compiler_config with optimization_level = level }
        with _ -> () );
    ( "CHINESE_OCAML_MAX_ERRORS",
      fun v ->
        try
          let max_errors = int_of_string v in
          if max_errors > 0 then
            runtime_config := { !runtime_config with max_error_count = max_errors }
        with _ -> () );
    ( "CHINESE_OCAML_LOG_LEVEL",
      fun v ->
        let level = String.lowercase_ascii v in
        if List.mem level [ "debug"; "info"; "warn"; "error" ] then
          runtime_config := { !runtime_config with log_level = level } );
    ( "CHINESE_OCAML_COLOR",
      fun v ->
        let colored = String.lowercase_ascii v = "true" || v = "1" in
        runtime_config := { !runtime_config with colored_output = colored } );
  ]

(** 从环境变量加载配置 *)
let load_from_env () =
  List.iter
    (fun (env_var, setter) ->
      try
        let value = Sys.getenv env_var in
        setter value
      with Not_found -> ())
    env_var_mappings

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

(** 根据键名应用配置值 *)
let apply_config_value key value =
  match clean_json_key key with
  | "debug_mode" -> runtime_config := { !runtime_config with debug_mode = value = "true" }
  | "buffer_size" ->
      safe_int_of_string value (fun v ->
          compiler_config := { !compiler_config with buffer_size = v })
  | "timeout" ->
      safe_float_of_string value (fun v ->
          compiler_config := { !compiler_config with compilation_timeout = v })
  | "output_directory" -> compiler_config := { !compiler_config with output_directory = value }
  | "c_compiler" -> compiler_config := { !compiler_config with c_compiler = value }
  | "optimization_level" ->
      safe_int_of_string value (fun v ->
          compiler_config := { !compiler_config with optimization_level = v })
  | _ -> ()

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

(** JSON配置文件支持（简化版） *)
let parse_json_config_simple content =
  content |> String.split_on_char '\n' |> List.iter parse_config_line

(** 从配置文件加载 *)
let load_from_file filename =
  try
    let ic = open_in filename in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    parse_json_config_simple content;
    true
  with _ -> false

(** 配置初始化 *)
let init_config ?(config_file = "config.json") () =
  (* 首先加载默认配置 *)
  compiler_config := default_compiler_config;
  runtime_config := default_runtime_config;

  (* 然后从配置文件加载 *)
  let _ = load_from_file config_file in

  (* 最后从环境变量加载（优先级最高） *)
  load_from_env ();

  (* 创建必要的目录 *)
  (try Unix.mkdir !compiler_config.output_directory 0o755 with _ -> ());
  try Unix.mkdir !compiler_config.temp_directory 0o755 with _ -> ()

(** 配置验证 *)
let validate_config () =
  let compiler_cfg = !compiler_config in
  let runtime_cfg = !runtime_config in
  let errors = ref [] in

  (* 验证缓冲区大小 *)
  if compiler_cfg.buffer_size <= 0 then errors := "缓冲区大小必须大于0" :: !errors;

  (* 验证超时时间 *)
  if compiler_cfg.compilation_timeout <= 0.0 then errors := "编译超时时间必须大于0" :: !errors;

  (* 验证优化级别 *)
  if compiler_cfg.optimization_level < 0 || compiler_cfg.optimization_level > 3 then
    errors := "优化级别必须在0-3之间" :: !errors;

  (* 验证最大错误数量 *)
  if runtime_cfg.max_error_count <= 0 then errors := "最大错误数量必须大于0" :: !errors;

  (* 验证日志级别 *)
  if not (List.mem runtime_cfg.log_level [ "debug"; "info"; "warn"; "error" ]) then
    errors := "日志级别必须是debug、info、warn或error之一" :: !errors;

  !errors

(** 打印当前配置 *)
let print_config () =
  let compiler_cfg = !compiler_config in
  let runtime_cfg = !runtime_config in
  Printf.printf "=== 骆言编译器配置 ===\n";
  Printf.printf "缓冲区大小: %d\n" compiler_cfg.buffer_size;
  Printf.printf "编译超时: %.1f秒\n" compiler_cfg.compilation_timeout;
  Printf.printf "输出目录: %s\n" compiler_cfg.output_directory;
  Printf.printf "C编译器: %s\n" compiler_cfg.c_compiler;
  Printf.printf "优化级别: %d\n" compiler_cfg.optimization_level;
  Printf.printf "调试模式: %b\n" runtime_cfg.debug_mode;
  Printf.printf "详细日志: %b\n" runtime_cfg.verbose_logging;
  Printf.printf "错误恢复: %b\n" runtime_cfg.error_recovery;
  Printf.printf "最大错误数: %d\n" runtime_cfg.max_error_count;
  Printf.printf "=======================\n";
  flush stdout

(** 便捷的配置获取函数 *)
module Get = struct
  let buffer_size () = !compiler_config.buffer_size
  let large_buffer_size () = !compiler_config.large_buffer_size
  let compilation_timeout () = !compiler_config.compilation_timeout
  let output_directory () = !compiler_config.output_directory
  let temp_directory () = !compiler_config.temp_directory
  let c_compiler () = !compiler_config.c_compiler
  let c_compiler_flags () = !compiler_config.c_compiler_flags
  let optimization_level () = !compiler_config.optimization_level
  let debug_mode () = !runtime_config.debug_mode
  let verbose_logging () = !runtime_config.verbose_logging
  let error_recovery () = !runtime_config.error_recovery
  let max_error_count () = !runtime_config.max_error_count
  let continue_on_error () = !runtime_config.continue_on_error
  let show_suggestions () = !runtime_config.show_suggestions
  let colored_output () = !runtime_config.colored_output
  let spell_correction () = !runtime_config.spell_correction
  let hashtable_size () = !compiler_config.default_hashtable_size
  let large_hashtable_size () = !compiler_config.large_hashtable_size
end
