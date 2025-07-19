(** 骆言编译器Unicode字符处理常量模块 
    从constants.ml重构而来，使用数据结构化方法管理UTF-8字符 *)

(** UTF-8字符三字节组合类型 *)
type utf8_triple = {
  byte1 : int;
  byte2 : int;
  byte3 : int;
}

(** UTF-8字符定义记录 *)
type utf8_char_def = {
  name : string;          (** 字符名称 *)
  char : string;          (** 实际字符 *)
  triple : utf8_triple;   (** UTF-8字节组合 *)
  category : string;      (** 字符类别 *)
}

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
let char_definitions = [
  (* 引用标识符 *)
  { name = "left_quote"; char = "「"; 
    triple = { byte1 = 0xE3; byte2 = 0x80; byte3 = 0x8C }; 
    category = "quote" };
  { name = "right_quote"; char = "」"; 
    triple = { byte1 = 0xE3; byte2 = 0x80; byte3 = 0x8D }; 
    category = "quote" };
    
  (* 字符串字面量 *)
  { name = "string_start"; char = "『"; 
    triple = { byte1 = 0xE3; byte2 = 0x80; byte3 = 0x8E }; 
    category = "string_literal" };
  { name = "string_end"; char = "』"; 
    triple = { byte1 = 0xE3; byte2 = 0x80; byte3 = 0x8F }; 
    category = "string_literal" };
    
  (* 全角符号 *)
  { name = "fullwidth_left_paren"; char = "（"; 
    triple = { byte1 = 0xEF; byte2 = 0xBC; byte3 = 0x88 }; 
    category = "fullwidth" };
  { name = "fullwidth_right_paren"; char = "）"; 
    triple = { byte1 = 0xEF; byte2 = 0xBC; byte3 = 0x89 }; 
    category = "fullwidth" };
  { name = "fullwidth_comma"; char = "，"; 
    triple = { byte1 = 0xEF; byte2 = 0xBC; byte3 = 0x8C }; 
    category = "fullwidth" };
  { name = "fullwidth_colon"; char = "："; 
    triple = { byte1 = 0xEF; byte2 = 0xBC; byte3 = 0x9A }; 
    category = "fullwidth" };
  { name = "fullwidth_semicolon"; char = "；"; 
    triple = { byte1 = 0xEF; byte2 = 0xBC; byte3 = 0x9B }; 
    category = "fullwidth" };
  { name = "fullwidth_pipe"; char = "｜"; 
    triple = { byte1 = 0xEF; byte2 = 0xBD; byte3 = 0x9C }; 
    category = "fullwidth" };
  { name = "fullwidth_period"; char = "．"; 
    triple = { byte1 = 0xEF; byte2 = 0xBC; byte3 = 0x8E }; 
    category = "fullwidth" };
    
  (* 中文标点符号 *)
  { name = "chinese_period"; char = "。"; 
    triple = { byte1 = 0xE3; byte2 = 0x80; byte3 = 0x82 }; 
    category = "chinese_punctuation" };
    
  (* 中文操作符 *)
  { name = "chinese_minus"; char = "负"; 
    triple = { byte1 = 0xE8; byte2 = 0xB4; byte3 = 0x9F }; 
    category = "chinese_operator" };
]

(** 字符查找映射表 - 提供快速查找功能 *)
module CharMap = struct
  let name_to_char_map = 
    List.fold_left (fun acc def -> 
      (def.name, def.char) :: acc
    ) [] char_definitions
    
  let name_to_triple_map = 
    List.fold_left (fun acc def -> 
      (def.name, def.triple) :: acc
    ) [] char_definitions
    
  let char_to_triple_map = 
    List.fold_left (fun acc def -> 
      (def.char, def.triple) :: acc
    ) [] char_definitions
end

(** 全角数字范围 *)
module FullwidthDigit = struct
  let start_byte3 = 0x90 (* ０ *)
  let end_byte3 = 0x99 (* ９ *)
  
  let is_fullwidth_digit byte3 = 
    byte3 >= start_byte3 && byte3 <= end_byte3
end

(** 便捷字符常量 - 保持向后兼容性 *)
module CharConstants = struct
  let char_xe3 = '\xe3'
  let char_x80 = '\x80'
  let char_x8e = '\x8e'
  let char_x8f = '\x8f'
  let char_xef = '\xef'
  let char_xbc = '\xbc'
  let char_xbd = '\xbd'
  let char_x9c = '\x9c'
  let char_xe8 = '\xe8'
  let char_xb4 = '\xb4'
  let char_x9f = '\x9f'
  let char_xe2 = '\xe2'
end

(** 便捷检查函数 *)
module Checks = struct
  let is_chinese_punctuation_prefix byte = byte = Prefix.chinese_punctuation
  let is_chinese_operator_prefix byte = byte = Prefix.chinese_operator
  let is_arrow_symbol_prefix byte = byte = Prefix.arrow_symbol
  let is_fullwidth_prefix byte = byte = Prefix.fullwidth
end

(** 向后兼容性函数 - 维护原有接口 *)
module Legacy = struct
  (** 获取字符的UTF-8三字节码 *)
  let get_char_bytes name =
    try
      let triple = List.assoc name CharMap.name_to_triple_map in
      (triple.byte1, triple.byte2, triple.byte3)
    with Not_found -> failwith ("Unknown character: " ^ name)
  
  (** 按类别获取字符列表 *)
  let get_chars_by_category category =
    List.filter (fun def -> def.category = category) char_definitions
    |> List.map (fun def -> def.char)
    
  (** 检查字符是否为指定类别 *)
  let is_char_category char category =
    List.exists (fun def -> 
      def.char = char && def.category = category
    ) char_definitions
end

(** 向后兼容性别名 - 保持原有常量名 *)
module Compatibility = struct
  (* 原UTF8模块的向后兼容别名 *)
  let chinese_char_start = Range.chinese_char_start
  let chinese_char_mid_start = Range.chinese_char_mid_start
  let chinese_char_mid_end = Range.chinese_char_mid_end
  let chinese_char_threshold = Range.chinese_char_threshold
  
  let chinese_punctuation_prefix = Prefix.chinese_punctuation
  let chinese_operator_prefix = Prefix.chinese_operator
  let arrow_symbol_prefix = Prefix.arrow_symbol
  let fullwidth_prefix = Prefix.fullwidth
  
  (* 获取三字节组合的向后兼容函数 *)
  let left_quote_bytes = Legacy.get_char_bytes "left_quote"
  let right_quote_bytes = Legacy.get_char_bytes "right_quote"
  let string_start_bytes = Legacy.get_char_bytes "string_start"
  let string_end_bytes = Legacy.get_char_bytes "string_end"
  let fullwidth_left_paren_bytes = Legacy.get_char_bytes "fullwidth_left_paren"
  let fullwidth_right_paren_bytes = Legacy.get_char_bytes "fullwidth_right_paren"
  let fullwidth_comma_bytes = Legacy.get_char_bytes "fullwidth_comma"
  let fullwidth_colon_bytes = Legacy.get_char_bytes "fullwidth_colon"
  let fullwidth_semicolon_bytes = Legacy.get_char_bytes "fullwidth_semicolon"
  let fullwidth_pipe_bytes = Legacy.get_char_bytes "fullwidth_pipe"
  let fullwidth_period_bytes = Legacy.get_char_bytes "fullwidth_period"
  let chinese_period_bytes = Legacy.get_char_bytes "chinese_period"
  let chinese_minus_bytes = Legacy.get_char_bytes "chinese_minus"
  
  let left_quote_byte1 = let (b1, _, _) = left_quote_bytes in b1
  let left_quote_byte2 = let (_, b2, _) = left_quote_bytes in b2
  let left_quote_byte3 = let (_, _, b3) = left_quote_bytes in b3
  
  let right_quote_byte1 = let (b1, _, _) = right_quote_bytes in b1
  let right_quote_byte2 = let (_, b2, _) = right_quote_bytes in b2
  let right_quote_byte3 = let (_, _, b3) = right_quote_bytes in b3
  
  let string_start_byte1 = let (b1, _, _) = string_start_bytes in b1
  let string_start_byte2 = let (_, b2, _) = string_start_bytes in b2
  let string_start_byte3 = let (_, _, b3) = string_start_bytes in b3
  
  let string_end_byte1 = let (b1, _, _) = string_end_bytes in b1
  let string_end_byte2 = let (_, b2, _) = string_end_bytes in b2
  let string_end_byte3 = let (_, _, b3) = string_end_bytes in b3
  
  (* 全角符号范围 *)
  let fullwidth_start_byte1 = 0xEF
  let fullwidth_start_byte2 = 0xBC
  
  (* 全角符号具体码点 *)
  let fullwidth_left_paren_byte3 = let (_, _, b3) = fullwidth_left_paren_bytes in b3
  let fullwidth_right_paren_byte3 = let (_, _, b3) = fullwidth_right_paren_bytes in b3
  let fullwidth_comma_byte3 = let (_, _, b3) = fullwidth_comma_bytes in b3
  let fullwidth_colon_byte3 = let (_, _, b3) = fullwidth_colon_bytes in b3
  let fullwidth_semicolon_byte3 = let (_, _, b3) = fullwidth_semicolon_bytes in b3
  let fullwidth_pipe_byte1 = let (b1, _, _) = fullwidth_pipe_bytes in b1
  let fullwidth_pipe_byte2 = let (_, b2, _) = fullwidth_pipe_bytes in b2
  let fullwidth_pipe_byte3 = let (_, _, b3) = fullwidth_pipe_bytes in b3
  let fullwidth_period_byte3 = let (_, _, b3) = fullwidth_period_bytes in b3
  
  (* 中文注释符号完整码点 - 使用fullwidth_colon的字节码 *)
  let comment_colon_byte1 = let (b1, _, _) = fullwidth_colon_bytes in b1
  let comment_colon_byte2 = let (_, b2, _) = fullwidth_colon_bytes in b2
  let comment_colon_byte3 = let (_, _, b3) = fullwidth_colon_bytes in b3
  
  (* 全角数字范围 *)
  let fullwidth_digit_start = FullwidthDigit.start_byte3
  let fullwidth_digit_end = FullwidthDigit.end_byte3
  
  (* 中文标点符号 *)
  let chinese_period_byte1 = let (b1, _, _) = chinese_period_bytes in b1
  let chinese_period_byte2 = let (_, b2, _) = chinese_period_bytes in b2
  let chinese_period_byte3 = let (_, _, b3) = chinese_period_bytes in b3
  
  (* 中文操作符 *)
  let chinese_minus_byte1 = let (b1, _, _) = chinese_minus_bytes in b1
  let chinese_minus_byte2 = let (_, b2, _) = chinese_minus_bytes in b2
  let chinese_minus_byte3 = let (_, _, b3) = chinese_minus_bytes in b3
  
  (* 字符常量 - 从CharConstants模块导入 *)
  let char_xe3 = CharConstants.char_xe3
  let char_x80 = CharConstants.char_x80
  let char_x8e = CharConstants.char_x8e
  let char_x8f = CharConstants.char_x8f
  let char_xef = CharConstants.char_xef
  let char_xbc = CharConstants.char_xbc
  let char_xbd = CharConstants.char_xbd
  let char_x9c = CharConstants.char_x9c
  let char_xe8 = CharConstants.char_xe8
  let char_xb4 = CharConstants.char_xb4
  let char_x9f = CharConstants.char_x9f
  let char_xe2 = CharConstants.char_xe2
  
  (* 便捷检查函数 - 向后兼容 *)
  let is_chinese_punctuation_prefix = Checks.is_chinese_punctuation_prefix
  let is_chinese_operator_prefix = Checks.is_chinese_operator_prefix
  let is_arrow_symbol_prefix = Checks.is_arrow_symbol_prefix
  let is_fullwidth_prefix = Checks.is_fullwidth_prefix
end