(** 骆言日志用户输出模块 - 面向用户的输出功能 *)

open Log_core

(** 成功消息 *)
let success message =
  Printf.fprintf global_config.output_channel "✅ %s\n" message;
  flush global_config.output_channel

(** 警告消息 *)
let warning message =
  Printf.fprintf global_config.output_channel "⚠️  %s\n" message;
  flush global_config.output_channel

(** 错误消息 *)
let error message =
  Printf.fprintf global_config.error_channel "❌ %s\n" message;
  flush global_config.error_channel

(** 信息消息 *)
let info message =
  Printf.fprintf global_config.output_channel "ℹ️  %s\n" message;
  flush global_config.output_channel

(** 进度消息 *)
let progress message =
  Printf.fprintf global_config.output_channel "🔄 %s\n" message;
  flush global_config.output_channel

(** 用户输出 - 程序执行结果等面向用户的信息 *)
let print_user_output message =
  Printf.fprintf global_config.output_channel "%s\n" message;
  flush global_config.output_channel

(** 编译器消息 - 编译过程中的提示信息 *)
let print_compiler_message message =
  if should_log INFO then (
    Printf.fprintf global_config.output_channel "[编译器] %s\n" message;
    flush global_config.output_channel)

(** 调试信息输出 *)
let print_debug_info message =
  if should_log DEBUG then (
    Printf.fprintf global_config.output_channel "[调试] %s\n" message;
    flush global_config.output_channel)

(** 不换行的用户输出 - 用于提示符等 *)
let print_user_prompt message =
  Printf.fprintf global_config.output_channel "%s" message;
  flush global_config.output_channel
