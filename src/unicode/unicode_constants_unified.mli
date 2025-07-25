(** 骆言编译器Unicode字符处理常量模块 - 统一版本接口
    
    本模块提供中文诗词编程语言所需的所有Unicode字符常量定义。
    字符按照功能分类组织，支持：
    - 中文标点符号（引号、括号、逗号等）
    - 全角符号（数字、字母、操作符）  
    - 箭头符号（赋值、逻辑推导）
    - 中文数字（零到万亿）
    
    @version 1.0 - Phase 1: 统一常量定义和命名规范
    @since 2025-07-25
*)

(** 核心字节三元组类型 *)
type byte_triple = int * int * int

(** 字符定义记录类型 *)
type char_definition = {
  name: string;        (** 字符名称标识符 *)
  char: string;        (** Unicode字符本身 *)
  bytes: byte_triple;  (** UTF-8字节表示 *)
  category: string;    (** 字符类别 *)
}

(** 助手函数：从字符名称获取字节组合 *)
val get_char_bytes_by_name : string -> byte_triple

(** 助手函数：从字符获取字节组合 *)
val get_char_bytes_by_char : string -> byte_triple

(** 中文引号字符常量定义 *)
module ChineseQuotes : sig
  (** 中文左引号『的字节表示 *)
  val left_quote_bytes : byte_triple
  
  (** 中文右引号』的字节表示 *)
  val right_quote_bytes : byte_triple
  
  (** 字符串开始标记『的字节表示 *)
  val string_start_bytes : byte_triple
  
  (** 字符串结束标记』的字节表示 *)
  val string_end_bytes : byte_triple
  
  (** 所有引号字符定义列表 *)
  val all_quote_chars : char_definition list
end

(** 中文标点符号常量定义 *)
module ChinesePunctuation : sig
  (** 中文左括号（的字节表示 *)
  val left_parentheses_bytes : byte_triple
  
  (** 中文右括号）的字节表示 *)
  val right_parentheses_bytes : byte_triple
  
  (** 中文逗号，的字节表示 *)
  val comma_bytes : byte_triple
  
  (** 中文冒号：的字节表示 *)
  val colon_bytes : byte_triple
  
  (** 中文句号。的字节表示 *)
  val period_bytes : byte_triple
  
  (** 中文分号；的字节表示 *)
  val semicolon_bytes : byte_triple
  
  (** 中文顿号、的字节表示（诗句节拍用） *)
  val pause_mark_bytes : byte_triple
  
  (** 所有中文标点符号定义列表 *)
  val all_punctuation_chars : char_definition list
end

(** 中文方括号和符号常量定义 *)
module ChineseSymbols : sig
  (** 中文左方括号【的字节表示 *)
  val left_square_bracket_bytes : byte_triple
  
  (** 中文右方括号】的字节表示 *)
  val right_square_bracket_bytes : byte_triple
  
  (** 全角管道符｜的字节表示 *)
  val pipe_bytes : byte_triple
  
  (** 箭头符号→的字节表示 *)
  val arrow_bytes : byte_triple
  
  (** 双箭头符号⇒的字节表示 *)
  val double_arrow_bytes : byte_triple
  
  (** 赋值箭头←的字节表示 *)
  val assign_arrow_bytes : byte_triple
  
  (** 所有符号字符定义列表 *)
  val all_symbol_chars : char_definition list
end

(** 诗词特有的Unicode字符定义 *)
module PoetrySymbols : sig
  (** 书名号左《的字节表示 *)
  val title_left_bytes : byte_triple
  
  (** 书名号右》的字节表示 *)
  val title_right_bytes : byte_triple
  
  (** 感叹号！的字节表示 *)
  val exclamation_bytes : byte_triple
  
  (** 问号？的字节表示 *)
  val question_bytes : byte_triple
  
  (** 韵脚标记◎的字节表示 *)
  val rhyme_marker_bytes : byte_triple
  
  (** 非韵脚标记○的字节表示 *)
  val non_rhyme_marker_bytes : byte_triple
  
  (** 可韵可不韵△的字节表示 *)
  val optional_rhyme_bytes : byte_triple
  
  (** 诗词专用符号定义列表 *)
  val all_poetry_chars : char_definition list
end

(** 字节访问器模块 - 提供统一的字节位访问接口 *)
module ByteAccessors : sig
  (** 获取第一个字节 *)
  val get_byte1 : byte_triple -> int
  
  (** 获取第二个字节 *)
  val get_byte2 : byte_triple -> int
  
  (** 获取第三个字节 *)
  val get_byte3 : byte_triple -> int
  
  (** 获取字节三元组 *)
  val get_bytes_tuple : byte_triple -> byte_triple
  
  (** 检查字节三元组是否有效（非零） *)
  val is_valid_bytes : byte_triple -> bool
end

(** 统一的字符定义集合 *)
module UnifiedCharDefinitions : sig
  (** 所有字符定义的完整列表 *)
  val all_char_definitions : char_definition list
  
  (** 按类别分组查找字符定义 *)
  val find_by_category : string -> char_definition list
  
  (** 按字符查找定义 *)
  val find_by_char : string -> char_definition option
  
  (** 按名称查找定义 *)
  val find_by_name : string -> char_definition option
end

(** 向后兼容性接口 - 保持现有代码正常工作 *)
module LegacyCompatibility : sig
  (** 兼容旧的Quote模块 *)
  module Quote : sig
    val left_quote_bytes : byte_triple
    val right_quote_bytes : byte_triple
    val string_start_bytes : byte_triple
    val string_end_bytes : byte_triple
  end
  
  (** 兼容旧的ChinesePunctuation模块 *)
  module ChinesePunctuation : sig
    val chinese_left_paren_bytes : byte_triple
    val chinese_right_paren_bytes : byte_triple
    val chinese_comma_bytes : byte_triple
    val chinese_colon_bytes : byte_triple
    val chinese_period_bytes : byte_triple
  end
  
  (** 兼容旧的Fullwidth模块 *)
  module Fullwidth : sig
    val fullwidth_left_paren_bytes : byte_triple
    val fullwidth_right_paren_bytes : byte_triple
    val fullwidth_comma_bytes : byte_triple
    val fullwidth_colon_bytes : byte_triple
    val fullwidth_period_bytes : byte_triple
    val fullwidth_semicolon_bytes : byte_triple
    val fullwidth_pipe_bytes : byte_triple
  end
  
  (** 兼容旧的OtherSymbols模块 *)
  module OtherSymbols : sig
    val chinese_minus_bytes : byte_triple
    val chinese_square_left_bracket_bytes : byte_triple
    val chinese_square_right_bracket_bytes : byte_triple
    val chinese_arrow_bytes : byte_triple
    val chinese_double_arrow_bytes : byte_triple
    val chinese_assign_arrow_bytes : byte_triple
    val chinese_pipe_bytes : byte_triple
  end
end