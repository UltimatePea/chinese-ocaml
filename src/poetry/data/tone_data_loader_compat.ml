(** 声调数据加载器兼容层实现 - Phase 2.2: 向后兼容性保证
    
    此模块代理所有原始tone_data_loader的接口到unified_data_loader_comprehensive，
    确保现有代码无需任何修改即可使用新的统一架构。
    
    @author Alpha, 技术债务清理专员
    @version 2.2 - Phase 2.2 兼容层
    @since 2025-07-29
    @fix_issue #1732 *)

open Unified_data_loader_comprehensive

(** {1 类型定义 - 与原始模块完全一致} *)

type tone_data_error = FileNotFound of string | ParseError of string | InvalidData of string

exception ToneDataError of tone_data_error

(** {1 内部缓存状态} *)

(** 缓存的声调数据 *)
let cached_tone_data = ref None

(** {1 错误转换工具} *)

(** 将comprehensive错误转换为兼容层错误 *)
let convert_comprehensive_to_tone_error = function
  | ComprehensiveLoadError (ToneLoadError (msg, detail)) ->
      ToneDataError (ParseError (msg ^ ": " ^ detail))
  | ComprehensiveLoadError (UnifiedLoadError msg) -> ToneDataError (InvalidData msg)
  | ComprehensiveLoadError (CompatibilityError msg) -> ToneDataError (InvalidData msg)
  | _ -> ToneDataError (InvalidData "未知错误")

(** {1 错误处理实现} *)

let format_error = function
  | FileNotFound filename -> Printf.sprintf "声调数据文件未找到: %s" filename
  | ParseError msg -> Printf.sprintf "声调数据JSON解析错误: %s" msg
  | InvalidData msg -> Printf.sprintf "声调数据格式无效: %s" msg

(** {1 数据加载接口实现} *)

let get_ping_sheng_chars () =
  try get_ping_sheng_chars_comprehensive () with
  | ComprehensiveLoadError _ as e -> raise (convert_comprehensive_to_tone_error e)
  | e -> raise (ToneDataError (InvalidData (Printexc.to_string e)))

let get_shang_sheng_chars () =
  try get_shang_sheng_chars_comprehensive () with
  | ComprehensiveLoadError _ as e -> raise (convert_comprehensive_to_tone_error e)
  | e -> raise (ToneDataError (InvalidData (Printexc.to_string e)))

let get_qu_sheng_chars () =
  try get_qu_sheng_chars_comprehensive () with
  | ComprehensiveLoadError _ as e -> raise (convert_comprehensive_to_tone_error e)
  | e -> raise (ToneDataError (InvalidData (Printexc.to_string e)))

let get_ru_sheng_chars () =
  try get_ru_sheng_chars_comprehensive () with
  | ComprehensiveLoadError _ as e -> raise (convert_comprehensive_to_tone_error e)
  | e -> raise (ToneDataError (InvalidData (Printexc.to_string e)))

let get_all_tone_data () =
  match !cached_tone_data with
  | Some cached_data -> cached_data
  | None -> (
      try
        let all_data = get_all_tone_data_comprehensive () in
        cached_tone_data := Some all_data;
        all_data
      with
      | ComprehensiveLoadError _ as e -> raise (convert_comprehensive_to_tone_error e)
      | e -> raise (ToneDataError (InvalidData (Printexc.to_string e))))

(** {1 缓存和管理接口实现} *)

let reload_tone_data () =
  cached_tone_data := None;
  clear_comprehensive_cache ();
  Printf.printf "声调数据缓存已清理，重新加载中...\n";
  get_all_tone_data ()

let validate_data () =
  try
    let _ = get_all_tone_data () in
    Printf.printf "声调数据完整性验证通过\n";
    true
  with
  | ToneDataError error ->
      Printf.printf "声调数据验证失败: %s\n" (format_error error);
      false
  | e ->
      Printf.printf "声调数据验证异常: %s\n" (Printexc.to_string e);
      false

(** {1 内部接口实现} *)

let load_tone_data_from_json () =
  (* 直接调用comprehensive函数，可能抛出异常 *)
  get_all_tone_data_comprehensive ()

let safe_load_tone_data () =
  try load_tone_data_from_json () with
  | ToneDataError error ->
      let error_msg = format_error error in
      Printf.printf "警告: 声调数据JSON加载失败，使用默认数据: %s\n" error_msg;
      (* 返回默认数据 *)
      ([ "春"; "风" ], [ "雨"; "雪" ], [ "去"; "望" ], [ "入"; "月" ])
  | e ->
      Printf.printf "警告: 声调数据加载异常，使用默认数据: %s\n" (Printexc.to_string e);
      ([ "春"; "风" ], [ "雨"; "雪" ], [ "去"; "望" ], [ "入"; "月" ])
