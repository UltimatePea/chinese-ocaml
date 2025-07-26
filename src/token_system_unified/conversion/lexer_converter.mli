(** 骆言Token系统整合重构 - 词法分析器Token转换接口 *)

open Yyocamlc_lib.Token_types
open Converter_interface

(** 词法分析器Token转换器 *)
module LexerConverter :
  CONVERTER with type input = string * position and type output = token * position

(** 批量词法转换器 *)
module BatchLexerConverter :
  BATCH_CONVERTER with type input = string * position and type output = token * position

(** 安全词法转换器 *)
module SafeLexerConverter :
  SAFE_CONVERTER with type input = string * position and type output = token * position
