(** 骆言统一日志系统 - 模块化重构后的兼容性包装器 *)

(** 重新导出核心日志功能以保持向后兼容性 *)
module Core = Log_core

(** 重新导出类型以保持兼容性 *)
type log_level = Log_core.log_level = 
  | DEBUG | INFO | WARN | ERROR | QUIET

type log_config = Log_core.log_config = {
  mutable current_level : log_level;
  mutable show_timestamps : bool;
  mutable show_module_name : bool;
  mutable show_colors : bool;
  mutable output_channel : out_channel;
  mutable error_channel : out_channel;
}

(** 重新导出核心函数 *)
let global_config = Log_core.global_config
let level_to_int = Log_core.level_to_int
let level_to_string = Log_core.level_to_string
let level_to_color = Log_core.level_to_color
let set_level = Log_core.set_level
let get_level = Log_core.get_level
let set_show_timestamps = Log_core.set_show_timestamps
let set_show_module_name = Log_core.set_show_module_name
let set_show_colors = Log_core.set_show_colors
let set_output_channel = Log_core.set_output_channel
let set_error_channel = Log_core.set_error_channel
let get_timestamp = Log_core.get_timestamp
let should_log = Log_core.should_log
let format_message = Log_core.format_message
let log_internal = Log_core.log_internal

(** 重新导出基础日志函数 *)
let debug = Log_core.debug
let info = Log_core.info
let warn = Log_core.warn
let error = Log_core.error
let debugf = Log_core.debugf
let infof = Log_core.infof
let warnf = Log_core.warnf
let errorf = Log_core.errorf
let debug_if = Log_core.debug_if
let info_if = Log_core.info_if
let warn_if = Log_core.warn_if
let error_if = Log_core.error_if
let create_module_logger = Log_core.create_module_logger
let init_module_logger = Log_core.init_module_logger
let time_operation = Log_core.time_operation

(** 重新导出初始化函数 *)
let init_from_env = Log_core.init_from_env
let init = Log_core.init
let enable_debug = Log_core.enable_debug
let enable_quiet = Log_core.enable_quiet
let enable_verbose = Log_core.enable_verbose

(** 重新导出消息模块 *)
module Messages = Log_messages

(** 重新导出用户输出模块 *)
module UserOutput = Log_output

(** 重新导出兼容性模块 *)
module Legacy = Log_legacy