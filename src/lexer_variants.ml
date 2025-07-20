(** 骆言词法分析器 - 变体转换模块
    
    注意：这个模块已经被重构为更模块化的结构。
    主要功能现在分布在以下专门模块中：
    
    - Keyword_converter_basic: 基础和语义关键字转换
    - Keyword_converter_system: 系统相关关键字转换  
    - Keyword_converter_chinese: 中文风格关键字转换
    - Keyword_converter_special: 特殊类型和诗词关键字转换
    - Keyword_converter_main: 主协调器模块
    
    本模块现在作为向后兼容的包装器，确保现有代码继续正常工作。
*)

(** 将多态变体转换为token类型 - 主入口函数 
    这是对外暴露的主要函数，保持完全的向后兼容性 *)
let variant_to_token = Keyword_converter_main.variant_to_token

(** 为了向后兼容，重新导出各个转换函数 *)
module Basic = Keyword_converter_basic
module System = Keyword_converter_system  
module Chinese = Keyword_converter_chinese
module Special = Keyword_converter_special
module Converter = Keyword_converter_main