(* 数据加载器核心模块
   
   提供通用的数据加载功能，整合缓存、文件读取和解析。
   实现可复用的加载模式，支持不同类型的数据加载。 *)

open Data_loader_types
open Data_loader_cache
open Data_loader_file
open Data_loader_parser

(* 使用统一日志系统 *)
let _, _, log_warn, _ = Unified_logging.create_module_logger "DataLoader"

(** 通用加载器函数 - 消除重复代码模式 *)
let generic_loader (type a) ?(use_cache = true) cache_prefix relative_path (parser : string -> a) :
    a data_result =
  let cache_key = cache_prefix ^ ":" ^ relative_path in

  (* 检查缓存 *)
  (if use_cache then
     match get_cached cache_key with Some data -> Some (Success (data : a)) | None -> None
   else None)
  |> function
  | Some result -> result
  | None -> (
      (* 从文件加载 *)
      let full_path = get_data_path relative_path in
      match read_file_content full_path with
      | Error err -> Error err
      | Success content ->
          let parsed_data = parser content in
          if use_cache then set_cache cache_key parsed_data;
          Success parsed_data)

(** 加载字符串列表数据 - 使用通用加载器 *)
let load_string_list ?(use_cache = true) relative_path =
  generic_loader ~use_cache "string_list" relative_path parse_string_array

(** 加载词性数据对 - 使用通用加载器 *)
let load_word_class_pairs ?(use_cache = true) relative_path =
  generic_loader ~use_cache "word_class_pairs" relative_path parse_word_class_pairs

(** 加载简单对象数据 - 使用通用加载器 *)
let load_simple_object ?(use_cache = true) relative_path =
  generic_loader ~use_cache "simple_object" relative_path parse_simple_object

(** 提供降级机制 - 如果文件不存在则返回默认数据 *)
let load_with_fallback loader relative_path fallback_data =
  (* 统一的错误处理模式，消除重复代码 *)
  let handle_error error_type file_or_type msg =
    log_warn (Printf.sprintf "%s %s 失败: %s，使用默认数据" error_type file_or_type msg);
    fallback_data
  in
  match loader relative_path with
  | Success data -> data
  | Error (FileNotFound _) -> handle_error "数据文件" relative_path "不存在"
  | Error (ParseError (file, msg)) -> handle_error "解析数据文件" file msg
  | Error (ValidationError (dtype, msg)) -> handle_error "验证数据类型" dtype msg
