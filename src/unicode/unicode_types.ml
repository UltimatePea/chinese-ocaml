(** Unicode字符类型定义和字符数据 *)

type utf8_triple = { byte1 : int; byte2 : int; byte3 : int }
(** UTF-8字符三字节组合类型 *)

type utf8_char_def = {
  name : string;  (** 字符名称 *)
  char : string;  (** 实际字符 *)
  triple : utf8_triple;  (** UTF-8字节组合 *)
  category : string;  (** 字符类别 *)
}
(** UTF-8字符定义记录 *)

(** 中文字符范围检测常量 *)
module Range = struct
  let chinese_char_start = 0xE4
  let chinese_char_mid_start = 0xE5
  let chinese_char_mid_end = 0xE9
  let chinese_char_threshold = 128
end

(** UTF-8字符前缀常量 *)
module Prefix = struct
  let chinese_punctuation = 0xE3 (* 中文标点符号 *)
  let chinese_operator = 0xE8 (* 中文操作符 *)
  let arrow_symbol = 0xE2 (* 箭头符号 *)
  let fullwidth = 0xEF (* 全角符号 *)
end

(** 字符定义数据表 - 结构化管理所有UTF-8字符 *)
let char_definitions =
  [
    (* 引用标识符 *)
    {
      name = "left_quote";
      char = "「";
      triple = { byte1 = 0xE3; byte2 = 0x80; byte3 = 0x8C };
      category = "quote";
    };
    {
      name = "right_quote";
      char = "」";
      triple = { byte1 = 0xE3; byte2 = 0x80; byte3 = 0x8D };
      category = "quote";
    };
    (* 字符串字面量 *)
    {
      name = "string_start";
      char = "『";
      triple = { byte1 = 0xE3; byte2 = 0x80; byte3 = 0x8E };
      category = "string";
    };
    {
      name = "string_end";
      char = "』";
      triple = { byte1 = 0xE3; byte2 = 0x80; byte3 = 0x8F };
      category = "string";
    };
    (* 中文标点符号 *)
    {
      name = "chinese_left_paren";
      char = "（";
      triple = { byte1 = 0xEF; byte2 = 0xBC; byte3 = 0x88 };
      category = "punctuation";
    };
    {
      name = "chinese_right_paren";
      char = "）";
      triple = { byte1 = 0xEF; byte2 = 0xBC; byte3 = 0x89 };
      category = "punctuation";
    };
    {
      name = "chinese_comma";
      char = "，";
      triple = { byte1 = 0xEF; byte2 = 0xBC; byte3 = 0x8C };
      category = "punctuation";
    };
    {
      name = "chinese_period";
      char = "。";
      triple = { byte1 = 0xE3; byte2 = 0x80; byte3 = 0x82 };
      category = "punctuation";
    };
    {
      name = "chinese_colon";
      char = "：";
      triple = { byte1 = 0xEF; byte2 = 0xBC; byte3 = 0x9A };
      category = "punctuation";
    };
    (* 中文数字符号 *)
    {
      name = "chinese_zero";
      char = "零";
      triple = { byte1 = 0xE9; byte2 = 0x9B; byte3 = 0xB6 };
      category = "number";
    };
    {
      name = "chinese_one";
      char = "一";
      triple = { byte1 = 0xE4; byte2 = 0xB8; byte3 = 0x80 };
      category = "number";
    };
    {
      name = "chinese_two";
      char = "二";
      triple = { byte1 = 0xE4; byte2 = 0xBA; byte3 = 0x8C };
      category = "number";
    };
    {
      name = "chinese_three";
      char = "三";
      triple = { byte1 = 0xE4; byte2 = 0xB8; byte3 = 0x89 };
      category = "number";
    };
    {
      name = "chinese_four";
      char = "四";
      triple = { byte1 = 0xE5; byte2 = 0x9B; byte3 = 0x9B };
      category = "number";
    };
    {
      name = "chinese_five";
      char = "五";
      triple = { byte1 = 0xE4; byte2 = 0xBA; byte3 = 0x94 };
      category = "number";
    };
    {
      name = "chinese_six";
      char = "六";
      triple = { byte1 = 0xE5; byte2 = 0x85; byte3 = 0xAD };
      category = "number";
    };
    {
      name = "chinese_seven";
      char = "七";
      triple = { byte1 = 0xE4; byte2 = 0xB8; byte3 = 0x83 };
      category = "number";
    };
    {
      name = "chinese_eight";
      char = "八";
      triple = { byte1 = 0xE5; byte2 = 0x85; byte3 = 0xAB };
      category = "number";
    };
    {
      name = "chinese_nine";
      char = "九";
      triple = { byte1 = 0xE4; byte2 = 0xB9; byte3 = 0x9D };
      category = "number";
    };
    {
      name = "chinese_ten";
      char = "十";
      triple = { byte1 = 0xE5; byte2 = 0x8D; byte3 = 0x81 };
      category = "number";
    };
    {
      name = "chinese_point";
      char = "点";
      triple = { byte1 = 0xE7; byte2 = 0x82; byte3 = 0xB9 };
      category = "number";
    };
  ]
