(** 骆言日志兼容性模块 - 为旧代码提供兼容性支持 
    Printf.sprintf 依赖消除 Phase 5.1 - 完成日志兼容性模块迁移
    @version 2.0 - Printf.sprintf 依赖消除完成
    @since 2025-07-24 Issue #1044 Printf.sprintf Phase 5 *)

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

(** 替代Printf.sprintf - 使用Base_formatter消除Printf.sprintf依赖 
    这个函数被弃用，建议使用Utils.Base_formatter中的具体格式化函数 *)
let sprintf _fmt = 
  failwith "sprintf已弃用，请使用Utils.Base_formatter中的具体格式化函数"
