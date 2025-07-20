(** Unicode字符常量定义接口

    本模块提供Unicode字符处理中使用的字符常量定义，
    主要用于UTF-8字节序列的识别和处理。
    
    主要功能：
    - 提供常用UTF-8字节常量
    - 向后兼容性支持
    - 简化字符检查逻辑
*)

(** 便捷字符常量模块 - 保持向后兼容性 *)
module CharConstants : sig
  (** {2 UTF-8字节常量} *)
  
  val char_xe3 : char
  (** UTF-8字节常量 0xE3 - 用于中文字符范围检查 *)
  
  val char_x80 : char
  (** UTF-8字节常量 0x80 - 用于UTF-8序列检查 *)
  
  val char_x8e : char
  (** UTF-8字节常量 0x8E - 用于特定字符检查 *)
  
  val char_x8f : char
  (** UTF-8字节常量 0x8F - 用于特定字符检查 *)
  
  val char_xef : char
  (** UTF-8字节常量 0xEF - 用于全角字符范围检查 *)
  
  val char_xbc : char
  (** UTF-8字节常量 0xBC - 用于全角字符检查 *)
  
  val char_xbd : char
  (** UTF-8字节常量 0xBD - 用于全角字符检查 *)
  
  val char_x9c : char
  (** UTF-8字节常量 0x9C - 用于特定字符检查 *)
  
  val char_xe8 : char
  (** UTF-8字节常量 0xE8 - 用于中文字符检查 *)
  
  val char_xb4 : char
  (** UTF-8字节常量 0xB4 - 用于特定字符检查 *)
  
  val char_x9f : char
  (** UTF-8字节常量 0x9F - 用于特定字符检查 *)
  
  val char_xe2 : char
  (** UTF-8字节常量 0xE2 - 用于箭头符号检查 *)
end