(** 缓冲区大小常量模块 *)

(** 缓冲区大小常量 - 固定值版本 *)
let default_buffer_size = 1024

let large_buffer_size = 4096
let report_buffer_size = large_buffer_size * 4
let utf8_char_buffer_size = 8 (* UTF-8字符固定大小 *)
