(** Token兼容性核心转换模块接口 - Token Compatibility Core Module Interface
    
    此模块提供核心的Token转换逻辑，协调各种映射模块并提供统一转换接口。
    这是从 token_compatibility.ml 中提取出来的专门模块，提升代码可维护性。
    
    @author 骆言技术债务清理团队 Issue #646
    @version 1.0
    @since 2025-07-20 *)

(** 核心转换函数
    将遗留的token字符串转换为统一系统中的token
    @param token_str 要转换的token字符串
    @param value_opt 可选的token值
    @return 转换后的统一token，如果无法转换则返回None *)
val convert_legacy_token_string : string -> string option -> Unified_token_core.unified_token option

(** 创建兼容的带位置Token
    为转换后的token创建包含位置信息的positioned token
    @param token_str 要转换的token字符串
    @param value_opt 可选的token值
    @param filename 文件名
    @param line 行号
    @param column 列号
    @return 带位置信息的token，如果无法转换则返回None *)
val make_compatible_positioned_token : 
  string -> string option -> string -> int -> int -> 
  Unified_token_core.positioned_token option

(** 检查Token字符串是否与统一系统兼容
    快速检查给定的token字符串是否可以转换为统一系统的token
    @param token_str 要检查的token字符串
    @return 如果可以转换则返回true，否则返回false *)
val is_compatible_with_legacy : string -> bool