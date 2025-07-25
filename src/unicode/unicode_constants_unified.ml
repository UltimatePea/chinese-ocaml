(** 骆言编译器Unicode字符处理常量模块 - 统一版本
    
    本模块提供中文诗词编程语言所需的所有Unicode字符常量定义。
    字符按照功能分类组织，支持：
    - 中文标点符号（引号、括号、逗号等）
    - 全角符号（数字、字母、操作符）  
    - 箭头符号（赋值、逻辑推导）
    - 中文数字（零到万亿）
    
    @version 1.0 - Phase 1: 统一常量定义和命名规范
*)

open Unicode_types
open Unicode_mapping

(** 核心字节三元组类型 *)
type byte_triple = int * int * int

(** 字符定义记录类型 *)
type char_definition = {
  name: string;
  char: string;
  bytes: byte_triple;
  category: string;
}

(** 助手函数：从字符名称获取字节组合 *)
let get_char_bytes_by_name char_name =
  match Legacy.find_char_by_name char_name with
  | Some char_str -> (
      match Legacy.find_triple_by_char char_str with
      | Some triple -> (triple.byte1, triple.byte2, triple.byte3)
      | None -> (0, 0, 0))
  | None -> (0, 0, 0)

(** 助手函数：从字符获取字节组合 *)
let get_char_bytes_by_char char_str =
  match Legacy.find_triple_by_char char_str with
  | Some triple -> (triple.byte1, triple.byte2, triple.byte3)
  | None -> (0, 0, 0)

(** 中文引号字符常量定义 *)
module ChineseQuotes = struct
  (** 中文左引号『 - UTF-8: 0xE3, 0x80, 0x8E *)
  let left_quote_bytes = get_char_bytes_by_name "left_quote"
  
  (** 中文右引号』 - UTF-8: 0xE3, 0x80, 0x8F *)
  let right_quote_bytes = get_char_bytes_by_name "right_quote"
  
  (** 字符串开始标记『 *)
  let string_start_bytes = get_char_bytes_by_name "string_start"
  
  (** 字符串结束标记』 *)
  let string_end_bytes = get_char_bytes_by_name "string_end"
  
  (** 所有引号字符列表 *)
  let all_quote_chars = [
    { name = "left_quote"; char = "『"; bytes = left_quote_bytes; category = "punctuation" };
    { name = "right_quote"; char = "』"; bytes = right_quote_bytes; category = "punctuation" };
  ]
end

(** 中文标点符号常量定义 *)
module ChinesePunctuation = struct
  (** 中文左括号（ - UTF-8: 0xEF, 0xBC, 0x88 *)
  let left_parentheses_bytes = get_char_bytes_by_name "chinese_left_paren"
  
  (** 中文右括号） - UTF-8: 0xEF, 0xBC, 0x89 *)
  let right_parentheses_bytes = get_char_bytes_by_name "chinese_right_paren"
  
  (** 中文逗号， - UTF-8: 0xEF, 0xBC, 0x8C *)
  let comma_bytes = get_char_bytes_by_name "chinese_comma"
  
  (** 中文冒号： - UTF-8: 0xEF, 0xBC, 0x9A *)
  let colon_bytes = get_char_bytes_by_name "chinese_colon"
  
  (** 中文句号。 - UTF-8: 0xE3, 0x80, 0x82 *)
  let period_bytes = get_char_bytes_by_name "chinese_period"
  
  (** 中文分号； - UTF-8: 0xEF, 0xBC, 0x9B *)
  let semicolon_bytes = (0xEF, 0xBC, 0x9B)
  
  (** 中文顿号、 - UTF-8: 0xE3, 0x80, 0x81 (诗句节拍用) *)
  let pause_mark_bytes = (0xE3, 0x80, 0x81)
  
  (** 所有中文标点符号列表 *)
  let all_punctuation_chars = [
    { name = "left_parentheses"; char = "（"; bytes = left_parentheses_bytes; category = "punctuation" };
    { name = "right_parentheses"; char = "）"; bytes = right_parentheses_bytes; category = "punctuation" };
    { name = "comma"; char = "，"; bytes = comma_bytes; category = "punctuation" };
    { name = "colon"; char = "："; bytes = colon_bytes; category = "punctuation" };
    { name = "period"; char = "。"; bytes = period_bytes; category = "punctuation" };
    { name = "semicolon"; char = "；"; bytes = semicolon_bytes; category = "punctuation" };
    { name = "pause_mark"; char = "、"; bytes = pause_mark_bytes; category = "punctuation" };
  ]
end

(** 中文方括号和符号常量定义 *)
module ChineseSymbols = struct
  (** 中文左方括号【 - UTF-8: 0xE3, 0x80, 0x90 *)
  let left_square_bracket_bytes = (0xE3, 0x80, 0x90)
  
  (** 中文右方括号】 - UTF-8: 0xE3, 0x80, 0x91 *)
  let right_square_bracket_bytes = (0xE3, 0x80, 0x91)
  
  (** 全角管道符｜ - UTF-8: 0xEF, 0xBD, 0x9C *)
  let pipe_bytes = (0xEF, 0xBD, 0x9C)
  
  (** 箭头符号→ - UTF-8: 0xE2, 0x86, 0x92 *)
  let arrow_bytes = (0xE2, 0x86, 0x92)
  
  (** 双箭头符号⇒ - UTF-8: 0xE2, 0x87, 0x92 *)
  let double_arrow_bytes = (0xE2, 0x87, 0x92)
  
  (** 赋值箭头← - UTF-8: 0xE2, 0x86, 0x90 *)
  let assign_arrow_bytes = (0xE2, 0x86, 0x90)
  
  (** 所有符号字符列表 *)
  let all_symbol_chars = [
    { name = "left_square_bracket"; char = "【"; bytes = left_square_bracket_bytes; category = "symbol" };
    { name = "right_square_bracket"; char = "】"; bytes = right_square_bracket_bytes; category = "symbol" };
    { name = "pipe"; char = "｜"; bytes = pipe_bytes; category = "symbol" };
    { name = "arrow"; char = "→"; bytes = arrow_bytes; category = "symbol" };
    { name = "double_arrow"; char = "⇒"; bytes = double_arrow_bytes; category = "symbol" };
    { name = "assign_arrow"; char = "←"; bytes = assign_arrow_bytes; category = "symbol" };
  ]
end

(** 诗词特有的Unicode字符定义 (新增功能) *)
module PoetrySymbols = struct
  (** 书名号左《 - UTF-8: 0xE3, 0x80, 0x8A *)
  let title_left_bytes = (0xE3, 0x80, 0x8A)
  
  (** 书名号右》 - UTF-8: 0xE3, 0x80, 0x8B *)
  let title_right_bytes = (0xE3, 0x80, 0x8B)
  
  (** 感叹号！ - UTF-8: 0xEF, 0xBC, 0x81 *)
  let exclamation_bytes = (0xEF, 0xBC, 0x81)
  
  (** 问号？ - UTF-8: 0xEF, 0xBC, 0x9F *)
  let question_bytes = (0xEF, 0xBC, 0x9F)
  
  (** 韵脚标记◎ - UTF-8: 0xE2, 0x97, 0x8E *)
  let rhyme_marker_bytes = (0xE2, 0x97, 0x8E)
  
  (** 非韵脚标记○ - UTF-8: 0xE2, 0x97, 0x8B *)
  let non_rhyme_marker_bytes = (0xE2, 0x97, 0x8B)
  
  (** 可韵可不韵△ - UTF-8: 0xE2, 0x96, 0xB3 *)
  let optional_rhyme_bytes = (0xE2, 0x96, 0xB3)
  
  (** 诗词专用符号列表 *)
  let all_poetry_chars = [
    { name = "title_left"; char = "《"; bytes = title_left_bytes; category = "poetry" };
    { name = "title_right"; char = "》"; bytes = title_right_bytes; category = "poetry" };
    { name = "exclamation"; char = "！"; bytes = exclamation_bytes; category = "poetry" };
    { name = "question"; char = "？"; bytes = question_bytes; category = "poetry" };
    { name = "rhyme_marker"; char = "◎"; bytes = rhyme_marker_bytes; category = "poetry" };
    { name = "non_rhyme_marker"; char = "○"; bytes = non_rhyme_marker_bytes; category = "poetry" };
    { name = "optional_rhyme"; char = "△"; bytes = optional_rhyme_bytes; category = "poetry" };
  ]
end

(** 字节访问器模块 - 提供统一的字节位访问接口 *)
module ByteAccessors = struct
  (** 获取第一个字节 *)
  let get_byte1 (b1, _, _) = b1
  
  (** 获取第二个字节 *)
  let get_byte2 (_, b2, _) = b2
  
  (** 获取第三个字节 *)
  let get_byte3 (_, _, b3) = b3
  
  (** 获取字节三元组 *)
  let get_bytes_tuple bytes = bytes
  
  (** 检查字节三元组是否有效（非零） *)
  let is_valid_bytes (b1, b2, b3) = 
    not (b1 = 0 && b2 = 0 && b3 = 0)
end

(** 统一的字符定义集合 *)
module UnifiedCharDefinitions = struct
  (** 所有字符定义的完整列表 *)
  let all_char_definitions = 
    ChineseQuotes.all_quote_chars @
    ChinesePunctuation.all_punctuation_chars @
    ChineseSymbols.all_symbol_chars @
    PoetrySymbols.all_poetry_chars
  
  (** 按类别分组查找 *)
  let find_by_category category =
    List.filter (fun def -> def.category = category) all_char_definitions
  
  (** 按字符查找定义 *)
  let find_by_char char_str =
    List.find_opt (fun def -> def.char = char_str) all_char_definitions
  
  (** 按名称查找定义 *)
  let find_by_name name =
    List.find_opt (fun def -> def.name = name) all_char_definitions
end

(** 向后兼容性接口 - 保持现有代码正常工作 *)
module LegacyCompatibility = struct
  (** 保持旧模块结构的兼容性导出 *)
  module Quote = struct
    let left_quote_bytes = ChineseQuotes.left_quote_bytes
    let right_quote_bytes = ChineseQuotes.right_quote_bytes
    let string_start_bytes = ChineseQuotes.string_start_bytes
    let string_end_bytes = ChineseQuotes.string_end_bytes
  end
  
  module ChinesePunctuation = struct
    let chinese_left_paren_bytes = ChinesePunctuation.left_parentheses_bytes
    let chinese_right_paren_bytes = ChinesePunctuation.right_parentheses_bytes
    let chinese_comma_bytes = ChinesePunctuation.comma_bytes
    let chinese_colon_bytes = ChinesePunctuation.colon_bytes
    let chinese_period_bytes = ChinesePunctuation.period_bytes
  end
  
  module Fullwidth = struct
    let fullwidth_left_paren_bytes = (get_char_bytes_by_name "chinese_left_paren")
    let fullwidth_right_paren_bytes = (get_char_bytes_by_name "chinese_right_paren")
    let fullwidth_comma_bytes = (get_char_bytes_by_name "chinese_comma")
    let fullwidth_colon_bytes = (get_char_bytes_by_name "chinese_colon")
    let fullwidth_period_bytes = (get_char_bytes_by_name "chinese_period")
    let fullwidth_semicolon_bytes = (0xEF, 0xBC, 0x9B)
    let fullwidth_pipe_bytes = (0xEF, 0xBD, 0x9C)
  end
  
  module OtherSymbols = struct
    let chinese_minus_bytes = (0, 0, 0)
    let chinese_square_left_bracket_bytes = (0xE3, 0x80, 0x90)
    let chinese_square_right_bracket_bytes = (0xE3, 0x80, 0x91)
    let chinese_arrow_bytes = (0xE2, 0x86, 0x92)
    let chinese_double_arrow_bytes = (0xE2, 0x87, 0x92)
    let chinese_assign_arrow_bytes = (0xE2, 0x86, 0x90)
    let chinese_pipe_bytes = (0xEF, 0xBD, 0x9C)
  end
end