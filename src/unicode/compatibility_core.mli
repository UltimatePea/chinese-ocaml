(** 向后兼容性核心模块接口
    
    保持原有接口并整合各子模块，确保现有代码的兼容性。
*)

(** 向后兼容性别名模块
    
    提供原UTF8模块和其他模块的向后兼容别名，确保现有代码能够正常工作。
*)
module Compatibility : sig
  (** 中文字符范围常量 *)
  val chinese_char_start : int
  val chinese_char_mid_start : int
  val chinese_char_mid_end : int
  val chinese_char_threshold : int
  
  (** 字符前缀常量 *)
  val chinese_punctuation_prefix : int
  val chinese_operator_prefix : int
  val arrow_symbol_prefix : int
  val fullwidth_prefix : int
  
  (** 获取字符的字节组合（向后兼容接口）
      
      @param char_name 字符名称
      @return 字符的三字节组合
  *)
  val get_char_bytes : string -> int * int * int
end