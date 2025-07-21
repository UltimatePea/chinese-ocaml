(** 入声字符数据模块 - 第二阶段技术债务重构版本
 
    基于数据外化重构，将原有硬编码的长字符列表移动到外部JSON文件，
    实现数据与代码分离，大幅减少代码行数，提升可维护性。
    
    修复 Issue #801 - 技术债务改进第二阶段：超长函数重构和数据外化
 
    @author 骆言诗词编程团队
    @version 2.0 (数据外化重构版)
    @since 2025-07-21 - 技术债务改进第二阶段 *)

open Yojson.Safe.Util

(** {1 数据加载异常处理} *)

exception Ru_sheng_data_error of string

(** {1 数据文件路径配置} *)

(** 获取数据文件路径 *)
let get_data_file_path filename =
  let current_dir = Sys.getcwd () in
  Filename.concat (Filename.concat current_dir "data/poetry/tone_data") filename

(** 入声数据文件路径 *)
let ru_sheng_data_file = get_data_file_path "ru_sheng.json"

(** {1 懒加载数据缓存} *)

(** 数据缓存 *)
let json_data_cache = ref None

(** 获取JSON数据 (懒加载) *)
let get_json_data () =
  match !json_data_cache with
  | Some data -> data
  | None ->
    try
      let data = Yojson.Safe.from_file ru_sheng_data_file in
      json_data_cache := Some data;
      data
    with
    | Sys_error msg -> 
      raise (Ru_sheng_data_error (Printf.sprintf "无法读取入声数据文件: %s" msg))
    | Yojson.Json_error msg ->
      raise (Ru_sheng_data_error (Printf.sprintf "入声数据JSON格式错误: %s" msg))

(** {1 数据解析函数} *)

(** 解析入声字符列表 *)
let parse_ru_sheng_chars json =
  try
    json |> member "characters" |> to_list |> List.map to_string
  with
  | Type_error (msg, _) -> 
    raise (Ru_sheng_data_error (Printf.sprintf "解析入声字符列表失败: %s" msg))
  | _ -> 
    raise (Ru_sheng_data_error "入声字符列表字段不存在")

(** {1 数据获取函数} *)

(** 入声字符数据列表 (懒加载) *)
let ru_sheng_chars =
  lazy (
    let json = get_json_data () in
    parse_ru_sheng_chars json
  )

(** {1 兼容性接口函数} *)

(** 获取入声字符列表 *)
let get_ru_sheng_chars () = Lazy.force ru_sheng_chars

(** 检查字符是否为入声 *)
let is_ru_sheng char = 
  List.mem char (Lazy.force ru_sheng_chars)

(** {1 扩展功能} *)

(** 获取入声字符数量 *)
let get_ru_sheng_count () = 
  List.length (Lazy.force ru_sheng_chars)

(** 获取数据元信息 *)
let get_metadata () =
  try
    let json = get_json_data () in
    let name = json |> member "name" |> to_string in
    let description = json |> member "description" |> to_string in
    let version = json |> member "version" |> to_string in
    let tone_type = json |> member "tone_type" |> to_string in
    (name, description, version, tone_type)
  with
  | Type_error (msg, _) -> 
    raise (Ru_sheng_data_error (Printf.sprintf "解析元信息失败: %s" msg))
  | _ -> 
    raise (Ru_sheng_data_error "元信息字段不完整")

(** {1 调试和验证函数} *)

(** 验证数据完整性 *)
let validate_data () =
  try
    let chars = Lazy.force ru_sheng_chars in
    let count = List.length chars in
    let has_duplicates = 
      let unique_chars = List.sort_uniq String.compare chars in
      List.length unique_chars <> count
    in
    if has_duplicates then
      raise (Ru_sheng_data_error "发现重复的入声字符")
    else if count < 10 then
      raise (Ru_sheng_data_error "入声字符数量过少")
    else
      Printf.printf "✅ 入声数据验证通过：共 %d 个字符\n" count
  with
  | Ru_sheng_data_error _ as e -> raise e
  | exn ->
    raise (Ru_sheng_data_error (Printf.sprintf "数据验证时发生未知错误: %s" 
                               (Printexc.to_string exn)))