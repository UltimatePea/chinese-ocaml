(** Unicode字符类型定义和字符数据

    本模块定义了骆言编程语言中使用的Unicode字符类型和数据结构，
    用于处理中文字符、标点符号和数字的UTF-8编码。
*)

(** UTF-8字符三字节组合类型 *)
type utf8_triple = { 
  byte1 : int; (** 第一字节 *)
  byte2 : int; (** 第二字节 *)
  byte3 : int; (** 第三字节 *)
}

(** UTF-8字符定义记录 *)
type utf8_char_def = {
  name : string;  (** 字符名称，用于标识该字符 *)
  char : string;  (** 实际的Unicode字符 *)
  triple : utf8_triple;  (** 该字符的UTF-8字节组合 *)
  category : string;  (** 字符类别（quote/string/punctuation/number等） *)
}

(** 中文字符范围检测常量 *)
module Range : sig
  val chinese_char_start : int
  (** 中文字符起始字节码 *)
  
  val chinese_char_mid_start : int
  (** 中文字符中段起始字节码 *)
  
  val chinese_char_mid_end : int
  (** 中文字符中段结束字节码 *)
  
  val chinese_char_threshold : int
  (** 中文字符判断阈值 *)
end

(** UTF-8字符前缀常量 *)
module Prefix : sig
  val chinese_punctuation : int
  (** 中文标点符号前缀字节 *)
  
  val chinese_operator : int
  (** 中文操作符前缀字节 *)
  
  val arrow_symbol : int
  (** 箭头符号前缀字节 *)
  
  val fullwidth : int
  (** 全角符号前缀字节 *)
end

(** 字符定义数据表
    
    包含所有骆言语言中使用的特殊Unicode字符定义，包括：
    - 引用标识符（「」）
    - 字符串字面量（『』）
    - 中文标点符号（（）、，。：）
    - 中文数字（零一二三四五六七八九十点）
    
    @return 完整的字符定义列表
*)
val char_definitions : utf8_char_def list