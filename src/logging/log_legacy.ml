(** 骆言日志兼容性模块 - 为旧代码提供兼容性支持 *)

open Log_core

(** 替代Printf.printf的函数 *)
let printf fmt = Printf.ksprintf (info "Legacy") fmt

(** 替代Unified_logging.Legacy.eprintf的函数 *)
let eprintf fmt = Printf.ksprintf (error "Legacy") fmt

(** 替代print_endline的函数 *)
let print_endline message = info "Legacy" message

(** 替代print_string的函数 *)
let print_string message =
  Printf.fprintf global_config.output_channel "%s" message;
  flush global_config.output_channel

(** 保持Printf.sprintf原有行为 *)
let sprintf = Printf.sprintf
