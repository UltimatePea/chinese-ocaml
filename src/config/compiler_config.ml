(** 骆言编译器核心配置模块 *)

(** 编译器配置类型定义 *)
type t = {
  (* 缓冲区配置 *)
  buffer_size : int;  (** 默认缓冲区大小 *)
  large_buffer_size : int;  (** 大缓冲区大小 *)
  report_buffer_size : int;  (** 报告缓冲区大小 *)
  utf8_char_buffer_size : int;  (** UTF-8字符缓冲区大小 *)
  
  (* 编译超时配置 *)
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

(** 默认编译器配置 *)
let default = {
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

(** 当前编译器配置 *)
let current = ref default

(** 获取当前编译器配置 *)
let get () = !current

(** 设置编译器配置 *)
let set config = current := config

(** 更新编译器配置字段 *)
let update_buffer_size size = 
  current := { !current with buffer_size = size }

let update_compilation_timeout timeout = 
  current := { !current with compilation_timeout = timeout }

let update_output_directory dir = 
  current := { !current with output_directory = dir }

let update_temp_directory dir = 
  current := { !current with temp_directory = dir }

let update_c_compiler compiler = 
  current := { !current with c_compiler = compiler }

let update_optimization_level level = 
  current := { !current with optimization_level = level }

(** 环境变量解析辅助函数 *)
let parse_positive_int_env_var v =
  try
    let i = int_of_string v in
    if i > 0 then Some i else None
  with Failure _ -> None

let parse_positive_float_env_var v =
  try
    let f = float_of_string v in
    if f > 0.0 then Some f else None
  with Failure _ -> None

let parse_non_empty_string_env_var v = 
  if String.length v > 0 then Some v else None

let parse_int_range_env_var v min_val max_val =
  try
    let i = int_of_string v in
    if i >= min_val && i <= max_val then Some i else None
  with Failure _ -> None

(** 编译器配置环境变量映射 *)
let env_var_mappings = [
  ("CHINESE_OCAML_BUFFER_SIZE", fun v ->
    match parse_positive_int_env_var v with
    | Some size -> update_buffer_size size
    | None -> ());
    
  ("CHINESE_OCAML_TIMEOUT", fun v ->
    match parse_positive_float_env_var v with
    | Some timeout -> update_compilation_timeout timeout
    | None -> ());
    
  ("CHINESE_OCAML_OUTPUT_DIR", fun v ->
    match parse_non_empty_string_env_var v with
    | Some dir -> update_output_directory dir
    | None -> ());
    
  ("CHINESE_OCAML_TEMP_DIR", fun v ->
    match parse_non_empty_string_env_var v with
    | Some dir -> update_temp_directory dir
    | None -> ());
    
  ("CHINESE_OCAML_C_COMPILER", fun v ->
    match parse_non_empty_string_env_var v with
    | Some compiler -> update_c_compiler compiler
    | None -> ());
    
  ("CHINESE_OCAML_OPT_LEVEL", fun v ->
    match parse_int_range_env_var v 0 3 with
    | Some level -> update_optimization_level level
    | None -> ());
]

(** 从环境变量加载编译器配置 *)
let load_from_env () =
  List.iter (fun (env_var, setter) ->
    try
      let value = Sys.getenv env_var in
      setter value
    with Not_found -> ()
  ) env_var_mappings