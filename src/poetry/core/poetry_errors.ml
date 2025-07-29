(** 骆言诗词错误处理模块 - 统一错误管理系统 Author: Alpha, 主要工作代理 - 负责功能实现和技术债务处理

    古云：知错能改，善莫大焉。 此模块统一诗词模块的错误处理，提供清晰的错误分类和恢复机制。

    设计原则： 1. 错误类型化 - 每种错误都有明确的类型 2. 错误链追踪 - 保留完整的错误调用链 3. 恢复策略 - 为常见错误提供恢复建议 4. 国际化支持 - 支持中英文错误消息 *)

open Poetry_types

(** === 错误分类系统 === *)

type error_severity =
  | Critical (* 严重错误 - 系统无法继续运行 *)
  | Error (* 一般错误 - 操作失败但系统可继续 *)
  | Warning (* 警告 - 操作成功但有潜在问题 *)
  | Info (* 信息 - 仅供参考 *)

type error_category =
  | DataError (* 数据相关错误 *)
  | ParseError (* 解析错误 *)
  | ValidationError (* 验证错误 *)
  | ConfigError (* 配置错误 *)
  | NetworkError (* 网络错误 *)
  | SystemError (* 系统错误 *)

(** === 具体错误类型定义 === *)

type data_error =
  | File_Not_Found of string (* 文件未找到 *)
  | Invalid_JSON of string * string (* JSON格式错误，文件名和错误信息 *)
  | Data_Corruption of string (* 数据损坏 *)
  | Missing_Required_Field of string * string (* 缺少必需字段 *)
  | Cache_Miss of string (* 缓存未命中 *)
  | Cache_Expired of string (* 缓存过期 *)
  | DataSourceError of string (* 数据源错误 - 向后兼容性 *)

type parse_error =
  | Invalid_Character of chinese_character * int (* 无效字符和位置 *)
  | Malformed_Poem of string (* 格式错误的诗歌 *)
  | Unknown_Rhyme_Pattern of string (* 未知韵律模式 *)
  | Invalid_Meter of string (* 无效格律 *)

type validation_error =
  | Empty_Input (* 空输入 *)
  | Text_Too_Long of int * int (* 文本过长，当前长度和最大长度 *)
  | Invalid_Poem_Form of poem_form * string (* 无效的诗歌形式 *)
  | Rhyme_Mismatch of string * string (* 韵律不匹配 *)
  | Meter_Violation of meter_pattern * string (* 格律违反 *)

type config_error =
  | Invalid_Config_File of string (* 无效配置文件 *)
  | Missing_Config_Value of string (* 缺少配置值 *)
  | Invalid_Cache_Size of int (* 无效缓存大小 *)
  | Unsupported_Data_Source of string (* 不支持的数据源 *)

type network_error =
  | Connection_Failed of string (* 连接失败 *)
  | Timeout of int (* 超时 *)
  | HTTP_Error of int * string (* HTTP错误码和消息 *)
  | API_Rate_Limit (* API速率限制 *)

type system_error =
  | Memory_Exhausted (* 内存耗尽 *)
  | Disk_Full (* 磁盘已满 *)
  | Permission_Denied of string (* 权限拒绝 *)
  | Resource_Busy of string (* 资源忙 *)

(** === 统一错误类型 === *)

type poetry_error = {
  category : error_category;
  severity : error_severity;
  message : string;
  details : string option;
  timestamp : float;
  source_location : string option; (* 错误发生的源码位置 *)
  error_chain : poetry_error list; (* 错误链，追踪错误传播 *)
  recovery_suggestion : string option; (* 恢复建议 *)
}

type specific_error =
  | Data_Error of data_error
  | Parse_Error of parse_error
  | Validation_Error of validation_error
  | Config_Error of config_error
  | Network_Error of network_error
  | System_Error of system_error

(** === 错误创建函数 === *)

let current_timestamp () = Unix.time ()

let create_error ?(details = None) ?(source_location = None) ?(error_chain = [])
    ?(recovery_suggestion = None) category severity message =
  {
    category;
    severity;
    message;
    details;
    timestamp = current_timestamp ();
    source_location;
    error_chain;
    recovery_suggestion;
  }

(** === 具体错误构造函数 === *)

let data_error error =
  let message, details, recovery =
    match error with
    | File_Not_Found path -> ("文件未找到", Some path, Some "请检查文件路径是否正确")
    | Invalid_JSON (file, err) -> ("JSON格式错误", Some (file ^ ": " ^ err), Some "请检查JSON文件格式")
    | Data_Corruption path -> ("数据损坏", Some path, Some "请重新下载或修复数据文件")
    | Missing_Required_Field (field, file) ->
        ("缺少必需字段", Some (field ^ " in " ^ file), Some "请添加缺少的字段")
    | Cache_Miss key -> ("缓存未命中", Some key, Some "数据将从源重新加载")
    | Cache_Expired key -> ("缓存过期", Some key, Some "缓存将自动刷新")
    | DataSourceError msg -> ("数据源错误", Some msg, Some "请检查数据源配置和连接")
  in
  create_error ~details ~recovery_suggestion:recovery DataError Error message

let parse_error error =
  let message, details, recovery =
    match error with
    | Invalid_Character (char, pos) ->
        ("无效字符", Some (char ^ " at position " ^ string_of_int pos), Some "请检查输入文本中的特殊字符")
    | Malformed_Poem text -> ("格式错误的诗歌", Some text, Some "请检查诗歌的行数和格式")
    | Unknown_Rhyme_Pattern pattern -> ("未知韵律模式", Some pattern, Some "请使用标准的韵律模式")
    | Invalid_Meter meter -> ("无效格律", Some meter, Some "请参考标准格律模式")
  in
  create_error ~details ~recovery_suggestion:recovery ParseError Error message

let validation_error error =
  let message, details, recovery =
    match error with
    | Empty_Input -> ("输入为空", None, Some "请提供有效的输入文本")
    | Text_Too_Long (current, max) ->
        ("文本过长", Some (Printf.sprintf "当前长度: %d, 最大长度: %d" current max), Some "请缩短输入文本")
    | Invalid_Poem_Form (_, reason) -> ("无效的诗歌形式", Some reason, Some "请选择正确的诗歌形式")
    | Rhyme_Mismatch (char1, char2) -> ("韵律不匹配", Some (char1 ^ " 和 " ^ char2), Some "请调整字词以符合韵律要求")
    | Meter_Violation (_, violation) -> ("格律违反", Some violation, Some "请按照格律要求调整平仄")
  in
  create_error ~details ~recovery_suggestion:recovery ValidationError Error message

(** === 错误处理辅助函数 === *)

let chain_error parent_error new_error =
  { new_error with error_chain = parent_error :: new_error.error_chain }

let is_recoverable error =
  match error.severity with Critical -> false | Error -> true | Warning | Info -> true

let get_error_message error = error.message

let get_full_error_description error =
  let base_msg = error.message in
  let details_msg = match error.details with Some d -> "\n详细信息: " ^ d | None -> "" in
  let recovery_msg = match error.recovery_suggestion with Some r -> "\n建议: " ^ r | None -> "" in
  base_msg ^ details_msg ^ recovery_msg

let format_error_chain errors =
  let format_single_error err =
    Printf.sprintf "[%s] %s"
      (match err.category with
      | DataError -> "数据错误"
      | ParseError -> "解析错误"
      | ValidationError -> "验证错误"
      | ConfigError -> "配置错误"
      | NetworkError -> "网络错误"
      | SystemError -> "系统错误")
      err.message
  in
  String.concat " -> " (List.map format_single_error errors)

(** === 结果类型的错误处理 === *)

let map_error f = function
  | Success v -> Success v
  | Failure err -> Failure (f err)
  | Partial (v, warnings) -> Partial (v, warnings)

let bind_error f = function
  | Success v -> f v
  | Failure err -> Failure err
  | Partial (v, warnings) -> (
      match f v with
      | Success v' -> Partial (v', warnings)
      | Failure err -> Failure err
      | Partial (v', new_warnings) -> Partial (v', warnings @ new_warnings))

let catch_errors f = try Success (f ()) with exn -> Failure (Printexc.to_string exn)

(** === 日志记录 === *)

type log_level = Debug | Info | Warn | Error | Fatal

let log_error ?(level = Error) error =
  let timestamp =
    Unix.time () |> Unix.localtime |> fun tm ->
    Printf.sprintf "%04d-%02d-%02d %02d:%02d:%02d" (tm.tm_year + 1900) (tm.tm_mon + 1) tm.tm_mday
      tm.tm_hour tm.tm_min tm.tm_sec
  in
  let level_str =
    match level with
    | Debug -> "DEBUG"
    | Info -> "INFO"
    | Warn -> "WARN"
    | Error -> "ERROR"
    | Fatal -> "FATAL"
  in
  Printf.eprintf "[%s] %s: %s\n%!" timestamp level_str (get_full_error_description error)

(** === 向后兼容性异常 === *)

(** 数据源错误异常 - 为保持向后兼容性而添加 *)
exception DataSourceError of string
