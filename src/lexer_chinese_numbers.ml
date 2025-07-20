(** 骆言词法分析器 - 中文数字处理模块 *)

open Lexer_state
open Lexer_tokens

(** 中文数字转换器模块 *)
module ChineseNumberConverter = struct
  (* 数字字符映射 *)
  let char_to_digit = function
    | "一" -> 1
    | "二" -> 2
    | "三" -> 3
    | "四" -> 4
    | "五" -> 5
    | "六" -> 6
    | "七" -> 7
    | "八" -> 8
    | "九" -> 9
    | "零" -> 0
    | _ -> 0

  (* 单位字符映射 *)
  let char_to_unit = function
    | "十" -> 10
    | "百" -> 100
    | "千" -> 1000
    | "万" -> 10000
    | "亿" -> 100000000
    | _ -> 1

  (* 将UTF-8字符串解析为中文字符列表 *)
  let rec utf8_to_char_list input pos chars =
    if pos >= String.length input then List.rev chars
    else
      let ch, next_pos = Lexer_char_processing.next_utf8_char input pos in
      if ch = "" then List.rev chars else utf8_to_char_list input next_pos (ch :: chars)

  (* 解析带单位的复杂数字 *)
  let rec parse_with_units chars acc current_num =
    match chars with
    | [] -> acc + current_num
    | ch :: rest ->
        if char_to_digit ch > 0 then
          (* 数字字符 *)
          parse_with_units rest acc (char_to_digit ch)
        else if ch = "零" then
          (* 零字符，继续处理 *)
          parse_with_units rest acc current_num
        else
          (* 单位字符 *)
          let unit = char_to_unit ch in
          if unit = 1 then
            (* 不是单位字符，当作数字处理 *)
            parse_with_units rest acc ((current_num * 10) + char_to_digit ch)
          else if unit >= 10000 then
            (* 万、亿等大单位 *)
            let section_value = if current_num = 0 then acc else acc + current_num in
            parse_with_units rest (section_value * unit) 0
          else
            (* 十、百、千等小单位 *)
            let digit = if current_num = 0 then 1 else current_num in
            parse_with_units rest (acc + (digit * unit)) 0

  (* 解析纯数字序列 *)
  let rec parse_simple_digits chars acc =
    match chars with
    | [] -> acc
    | ch :: rest ->
        let digit = char_to_digit ch in
        parse_simple_digits rest ((acc * 10) + digit)

  (* 解析中文数字字符列表 *)
  let parse_chinese_number chars =
    (* 检查是否包含单位字符 *)
    let has_units = List.exists (fun ch -> char_to_unit ch > 1) chars in
    if has_units then
      parse_with_units chars 0 0
    else
      parse_simple_digits chars 0

  (* 构造浮点数值 *)
  let construct_float_value int_val dec_val decimal_places =
    float_of_int int_val +. (float_of_int dec_val /. (10. ** float_of_int decimal_places))
end

(** 读取中文数字序列 *)
let read_chinese_number_sequence state =
  let input = state.input in
  let length = state.length in
  let rec loop pos acc =
    if pos >= length then (acc, pos)
    else
      let ch, next_pos = Lexer_char_processing.next_utf8_char input pos in
      if Lexer_char_processing.is_chinese_digit_char ch then loop next_pos (acc ^ ch) else (acc, pos)
  in
  let sequence, new_pos = loop state.position "" in
  let new_col = state.current_column + (new_pos - state.position) in
  (sequence, { state with position = new_pos; current_column = new_col })

(** 转换中文数字序列为数值 *)
let convert_chinese_number_sequence sequence =
  (* 分割整数部分和小数部分 *)
  let parts = Str.split (Str.regexp "点") sequence in
  match parts with
  | [ integer_part ] ->
      (* 只有整数部分 *)
      let chars = ChineseNumberConverter.utf8_to_char_list integer_part 0 [] in
      let is_negative = List.length chars > 0 && List.hd chars = "负" in
      let number_chars = if is_negative then List.tl chars else chars in
      let int_val = ChineseNumberConverter.parse_chinese_number number_chars in
      let final_val = if is_negative then -int_val else int_val in
      Lexer_tokens.IntToken final_val
  | [ integer_part; decimal_part ] ->
      (* 有整数和小数部分 *)
      let int_chars = ChineseNumberConverter.utf8_to_char_list integer_part 0 [] in
      let dec_chars = ChineseNumberConverter.utf8_to_char_list decimal_part 0 [] in
      let is_negative = List.length int_chars > 0 && List.hd int_chars = "负" in
      let number_int_chars = if is_negative then List.tl int_chars else int_chars in
      let int_val = ChineseNumberConverter.parse_chinese_number number_int_chars in
      let dec_val = ChineseNumberConverter.parse_chinese_number dec_chars in
      let decimal_places = List.length dec_chars in
      let float_val = ChineseNumberConverter.construct_float_value int_val dec_val decimal_places in
      let final_val = if is_negative then -.float_val else float_val in
      Lexer_tokens.FloatToken final_val
  | _ ->
      (* 默认情况，应该不会到达这里 *)
      Lexer_tokens.IntToken 0