(** 声调数据JSON加载器模块

    外化声调数据的JSON加载器，替代原有的硬编码数据列表。 这个模块专门负责从JSON文件加载声调字符数据。

    @author 骆言技术债务清理团队
    @version 1.0 - JSON数据外化
    @since 2025-07-21
    @updated 2025-07-22 - CI修复确认 *)

open Printf

(** 错误类型定义 *)
type tone_data_error = FileNotFound of string | ParseError of string | InvalidData of string

exception ToneDataError of tone_data_error

let format_error = function
  | FileNotFound file -> sprintf "声调数据文件未找到: %s" file
  | ParseError msg -> sprintf "JSON解析失败: %s" msg
  | InvalidData msg -> sprintf "数据格式无效: %s" msg

(** JSON数据文件路径 - 使用绝对路径避免工作目录问题 *)
let get_project_root () =
  let rec find_root dir =
    let dune_project = Filename.concat dir "dune-project" in
    if Sys.file_exists dune_project then dir
    else
      let parent = Filename.dirname dir in
      if parent = dir then
        (* 到达文件系统根目录，使用当前目录 *)
        Sys.getcwd ()
      else find_root parent
  in
  find_root (Sys.getcwd ())

let tone_data_file =
  let project_root = get_project_root () in
  Filename.concat project_root "data/poetry/tone_data.json"

(** JSON解析辅助函数 *)
let parse_string_list json_list =
  try
    List.map
      (function `String s -> s | _ -> raise (ToneDataError (InvalidData "非字符串类型的数据项")))
      json_list
  with
  | ToneDataError e -> raise (ToneDataError e)
  | _ -> raise (ToneDataError (InvalidData "列表格式错误"))

(** 解析JSON数据结构 *)
let parse_tone_data json =
  try
    let open Yojson.Basic.Util in
    let ping_sheng = json |> member "ping_sheng_chars" |> to_list |> parse_string_list in
    let shang_sheng = json |> member "shang_sheng_chars" |> to_list |> parse_string_list in
    let qu_sheng = json |> member "qu_sheng_chars" |> to_list |> parse_string_list in
    let ru_sheng = json |> member "ru_sheng_chars" |> to_list |> parse_string_list in
    (ping_sheng, shang_sheng, qu_sheng, ru_sheng)
  with
  | Yojson.Basic.Util.Type_error (msg, _) -> raise (ToneDataError (ParseError ("JSON结构错误: " ^ msg)))
  | _ -> raise (ToneDataError (ParseError "未知JSON解析错误"))

(** 从JSON文件加载声调数据 *)
let load_tone_data_from_json () =
  try
    if not (Sys.file_exists tone_data_file) then raise (ToneDataError (FileNotFound tone_data_file));

    let json = Yojson.Basic.from_file tone_data_file in
    parse_tone_data json
  with
  | ToneDataError e -> raise (ToneDataError e)
  | Sys_error msg -> raise (ToneDataError (FileNotFound msg))
  | Yojson.Json_error msg -> raise (ToneDataError (ParseError msg))

(** 缓存机制 *)
let cached_data = ref None

let get_cached_tone_data () =
  match !cached_data with
  | Some data -> data
  | None ->
      let data = load_tone_data_from_json () in
      cached_data := Some data;
      data

(** 降级数据 - 如果JSON加载失败则使用基本数据 *)
let fallback_ping_sheng = [ "一"; "天"; "年"; "先"; "田"; "言"; "然"; "连"; "边"; "山" ]

let fallback_shang_sheng = [ "上"; "老"; "好"; "小"; "少"; "早"; "草"; "手"; "口"; "九" ]
let fallback_qu_sheng = [ "去"; "次"; "事"; "字"; "自"; "大"; "代"; "带"; "待"; "戴" ]
let fallback_ru_sheng = [ "入"; "出"; "国"; "德"; "得"; "北"; "白"; "百"; "柏"; "拍" ]

(** 安全加载函数 - 带降级机制 *)
let safe_load_tone_data () =
  try get_cached_tone_data ()
  with ToneDataError e ->
    eprintf "警告: %s，使用降级数据\n" (format_error e);
    (fallback_ping_sheng, fallback_shang_sheng, fallback_qu_sheng, fallback_ru_sheng)

(** 导出接口 - 兼容原有模块接口 *)

(** 获取平声字符列表 *)
let get_ping_sheng_chars () =
  let ping_sheng, _, _, _ = safe_load_tone_data () in
  ping_sheng

(** 获取上声字符列表 *)
let get_shang_sheng_chars () =
  let _, shang_sheng, _, _ = safe_load_tone_data () in
  shang_sheng

(** 获取去声字符列表 *)
let get_qu_sheng_chars () =
  let _, _, qu_sheng, _ = safe_load_tone_data () in
  qu_sheng

(** 获取入声字符列表 *)
let get_ru_sheng_chars () =
  let _, _, _, ru_sheng = safe_load_tone_data () in
  ru_sheng

(** 获取所有声调数据 *)
let get_all_tone_data () = safe_load_tone_data ()

(** 重新加载数据（清除缓存） *)
let reload_tone_data () =
  cached_data := None;
  safe_load_tone_data ()

(** 验证数据完整性 *)
let validate_data () =
  try
    let ping, shang, qu, ru = get_cached_tone_data () in
    let total_chars = List.length ping + List.length shang + List.length qu + List.length ru in
    printf "声调数据验证通过 - 总字符数: %d\n" total_chars;
    printf "  平声: %d, 上声: %d, 去声: %d, 入声: %d\n" (List.length ping) (List.length shang)
      (List.length qu) (List.length ru);
    true
  with ToneDataError e ->
    eprintf "数据验证失败: %s\n" (format_error e);
    false
