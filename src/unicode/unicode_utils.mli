(** Unicode字符检查和工具函数接口

    本模块提供Unicode字符处理的工具函数，包括全角数字检查、
    字符前缀检查等功能。
    
    主要功能：
    - 全角数字范围检查
    - 各种Unicode字符前缀检查
    - 字符分类检查
*)

(** 全角数字范围处理模块 *)
module FullwidthDigit : sig
  val start_byte3 : int
  (** 全角数字起始字节（第三字节） - 对应字符 ０ *)
  
  val end_byte3 : int
  (** 全角数字结束字节（第三字节） - 对应字符 ９ *)
  
  val is_fullwidth_digit : int -> bool
  (** [is_fullwidth_digit byte3] 检查第三字节是否为全角数字
      @param byte3 UTF-8字符的第三字节
      @return 如果是全角数字（０-９）则返回true，否则返回false *)
end

(** 便捷检查函数模块 *)
module Checks : sig
  val is_chinese_punctuation_prefix : int -> bool
  (** [is_chinese_punctuation_prefix byte] 检查字节是否为中文标点符号前缀
      @param byte 要检查的字节
      @return 如果是中文标点符号前缀则返回true *)
  
  val is_chinese_operator_prefix : int -> bool
  (** [is_chinese_operator_prefix byte] 检查字节是否为中文操作符前缀
      @param byte 要检查的字节
      @return 如果是中文操作符前缀则返回true *)
  
  val is_arrow_symbol_prefix : int -> bool
  (** [is_arrow_symbol_prefix byte] 检查字节是否为箭头符号前缀
      @param byte 要检查的字节
      @return 如果是箭头符号前缀则返回true *)
  
  val is_fullwidth_prefix : int -> bool
  (** [is_fullwidth_prefix byte] 检查字节是否为全角符号前缀
      @param byte 要检查的字节
      @return 如果是全角符号前缀则返回true *)
end