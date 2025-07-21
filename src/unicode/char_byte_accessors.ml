(** Unicode字符字节访问器模块 - 提供各个字节位的访问函数 *)

open Char_byte_definitions

(** 三元组字节访问器助手 *)
let get_byte1 (b1, _, _) = b1
let get_byte2 (_, b2, _) = b2
let get_byte3 (_, _, b3) = b3

(** 引号字符字节访问器 *)
module Quote = struct
  let left_quote_byte1 = get_byte1 Quote.left_quote_bytes
  let left_quote_byte2 = get_byte2 Quote.left_quote_bytes
  let left_quote_byte3 = get_byte3 Quote.left_quote_bytes
  let right_quote_byte1 = get_byte1 Quote.right_quote_bytes
  let right_quote_byte2 = get_byte2 Quote.right_quote_bytes
  let right_quote_byte3 = get_byte3 Quote.right_quote_bytes
  let string_start_byte1 = get_byte1 Quote.string_start_bytes
  let string_start_byte2 = get_byte2 Quote.string_start_bytes
  let string_start_byte3 = get_byte3 Quote.string_start_bytes
  let string_end_byte1 = get_byte1 Quote.string_end_bytes
  let string_end_byte2 = get_byte2 Quote.string_end_bytes
  let string_end_byte3 = get_byte3 Quote.string_end_bytes
end

(** 中文标点符号字节访问器 *)
module ChinesePunctuation = struct
  let chinese_left_paren_byte1 = get_byte1 ChinesePunctuation.chinese_left_paren_bytes
  let chinese_left_paren_byte2 = get_byte2 ChinesePunctuation.chinese_left_paren_bytes
  let chinese_left_paren_byte3 = get_byte3 ChinesePunctuation.chinese_left_paren_bytes
  let chinese_right_paren_byte1 = get_byte1 ChinesePunctuation.chinese_right_paren_bytes
  let chinese_right_paren_byte2 = get_byte2 ChinesePunctuation.chinese_right_paren_bytes
  let chinese_right_paren_byte3 = get_byte3 ChinesePunctuation.chinese_right_paren_bytes
  let chinese_comma_byte1 = get_byte1 ChinesePunctuation.chinese_comma_bytes
  let chinese_comma_byte2 = get_byte2 ChinesePunctuation.chinese_comma_bytes
  let chinese_comma_byte3 = get_byte3 ChinesePunctuation.chinese_comma_bytes
  let chinese_colon_byte1 = get_byte1 ChinesePunctuation.chinese_colon_bytes
  let chinese_colon_byte2 = get_byte2 ChinesePunctuation.chinese_colon_bytes
  let chinese_colon_byte3 = get_byte3 ChinesePunctuation.chinese_colon_bytes
  let chinese_period_byte1 = get_byte1 ChinesePunctuation.chinese_period_bytes
  let chinese_period_byte2 = get_byte2 ChinesePunctuation.chinese_period_bytes
  let chinese_period_byte3 = get_byte3 ChinesePunctuation.chinese_period_bytes
end

(** 全角字符字节访问器 *)
module Fullwidth = struct
  let fullwidth_left_paren_byte3 = get_byte3 Fullwidth.fullwidth_left_paren_bytes
  let fullwidth_right_paren_byte3 = get_byte3 Fullwidth.fullwidth_right_paren_bytes
  let fullwidth_comma_byte3 = get_byte3 Fullwidth.fullwidth_comma_bytes
  let fullwidth_colon_byte3 = get_byte3 Fullwidth.fullwidth_colon_bytes
  let fullwidth_semicolon_byte3 = get_byte3 Fullwidth.fullwidth_semicolon_bytes
  let fullwidth_pipe_byte1 = get_byte1 Fullwidth.fullwidth_pipe_bytes
  let fullwidth_pipe_byte2 = get_byte2 Fullwidth.fullwidth_pipe_bytes
  let fullwidth_pipe_byte3 = get_byte3 Fullwidth.fullwidth_pipe_bytes
  let fullwidth_period_byte3 = get_byte3 Fullwidth.fullwidth_period_bytes
  
  (* 中文注释符号字节访问器 *)
  let comment_colon_byte1 = get_byte1 Fullwidth.fullwidth_colon_bytes
  let comment_colon_byte2 = get_byte2 Fullwidth.fullwidth_colon_bytes
  let comment_colon_byte3 = get_byte3 Fullwidth.fullwidth_colon_bytes
end

(** 其他符号字节访问器 *)
module OtherSymbols = struct
  (* 中文操作符字节访问器 *)
  let chinese_minus_byte1 = get_byte1 OtherSymbols.chinese_minus_bytes
  let chinese_minus_byte2 = get_byte2 OtherSymbols.chinese_minus_bytes
  let chinese_minus_byte3 = get_byte3 OtherSymbols.chinese_minus_bytes
  
  (* 中文方括号字节访问器 *)
  let chinese_square_left_bracket_byte1 = get_byte1 OtherSymbols.chinese_square_left_bracket_bytes
  let chinese_square_left_bracket_byte2 = get_byte2 OtherSymbols.chinese_square_left_bracket_bytes
  let chinese_square_left_bracket_byte3 = get_byte3 OtherSymbols.chinese_square_left_bracket_bytes
  let chinese_square_right_bracket_byte1 = get_byte1 OtherSymbols.chinese_square_right_bracket_bytes
  let chinese_square_right_bracket_byte2 = get_byte2 OtherSymbols.chinese_square_right_bracket_bytes
  let chinese_square_right_bracket_byte3 = get_byte3 OtherSymbols.chinese_square_right_bracket_bytes
  
  (* 箭头符号字节访问器 *)
  let chinese_arrow_byte1 = get_byte1 OtherSymbols.chinese_arrow_bytes
  let chinese_arrow_byte2 = get_byte2 OtherSymbols.chinese_arrow_bytes
  let chinese_arrow_byte3 = get_byte3 OtherSymbols.chinese_arrow_bytes
  let chinese_double_arrow_byte1 = get_byte1 OtherSymbols.chinese_double_arrow_bytes
  let chinese_double_arrow_byte2 = get_byte2 OtherSymbols.chinese_double_arrow_bytes
  let chinese_double_arrow_byte3 = get_byte3 OtherSymbols.chinese_double_arrow_bytes
  let chinese_assign_arrow_byte1 = get_byte1 OtherSymbols.chinese_assign_arrow_bytes
  let chinese_assign_arrow_byte2 = get_byte2 OtherSymbols.chinese_assign_arrow_bytes
  let chinese_assign_arrow_byte3 = get_byte3 OtherSymbols.chinese_assign_arrow_bytes
end