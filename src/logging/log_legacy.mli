(** 骆言日志兼容性模块 - 为旧代码提供兼容性支持 *)

(** 替代Printf.printf的函数 *)
val printf : ('a, unit, string, unit) format4 -> 'a

(** 替代Unified_logging.Legacy.eprintf的函数 *)
val eprintf : ('a, unit, string, unit) format4 -> 'a

(** 替代print_endline的函数 *)
val print_endline : string -> unit

(** 替代print_string的函数 *)
val print_string : string -> unit

(** 保持Printf.sprintf原有行为 *)
val sprintf : ('a, unit, string, string) format4 -> 'a