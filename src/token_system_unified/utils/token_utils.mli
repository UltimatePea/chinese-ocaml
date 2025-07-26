(** 骆言编译器 - Token系统工具函数接口
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Yyocamlc_lib.Token_types
open Error_types

(** Token调试工具 *)
module Debug : sig
  val token_to_debug_string : token -> string
  val print_token_list : token list -> unit
  val print_positioned_token_list : positioned_token list -> unit
end

(** Token过滤和查找工具 *)
module Filter : sig
  val filter_by_category : token_category -> token list -> token list
  val filter_keywords : token list -> token list
  val filter_literals : token list -> token list
  val filter_identifiers : token list -> token list
  val filter_operators : token list -> token list
  val filter_delimiters : token list -> token list
  val find_token : token -> token list -> token option
  val count_token : token -> token list -> int
  val contains_token : token -> token list -> bool
end

(** Token流处理工具 *)
module Stream : sig
  val create_positioned_token : token -> int -> int -> int -> string -> positioned_token
  val create_stream_from_tokens : token list -> token_stream
  val extract_tokens : token_stream -> token list
  val extract_texts : token_stream -> string list
  val is_empty : token_stream -> bool
  val peek_first : token_stream -> token token_result
  val peek_last : token_stream -> token token_result
  val drop_first : token_stream -> token_stream token_result
  val split_at_position : int -> token_stream -> token_stream * token_stream
end

(** Token验证工具 *)
module Validation : sig
  val validate_basic_syntax : token_stream -> unit token_result
  val validate_token : token -> token token_result
  val validate_token_list : token list -> token list token_result
end

(** Token统计工具 *)
module Statistics : sig
  val generate_comprehensive_stats : token list -> (string * int) list
  val format_stats_report : (string * int) list -> string
end
