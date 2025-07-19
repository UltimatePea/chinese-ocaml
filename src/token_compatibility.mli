(** Token兼容性适配层接口 - 统一Token系统与现有代码的桥梁 *)

open Unified_token_core

val convert_legacy_token_string : string -> string option -> unified_token option
(** 旧系统token名称到统一token的转换
    @param token_name 旧的token名称字符串
    @param value_opt 可选的token值
    @return 转换后的统一token，如果无法转换则返回None *)

val make_compatible_positioned_token :
  string -> string option -> string -> int -> int -> positioned_token option
(** 创建兼容性positioned_token
    @param legacy_token_name 旧的token名称
    @param value_opt 可选的token值
    @param filename 文件名
    @param line 行号
    @param column 列号
    @return 带位置信息的统一token *)

val is_compatible_with_legacy : string -> bool
(** 检查是否兼容旧的token名称
    @param token_name 旧的token名称
    @return 如果支持则返回true *)

val get_supported_legacy_tokens : unit -> string list
(** 获取所有支持的旧token名称列表
    @return 支持的旧token名称字符串列表 *)

val generate_compatibility_report : unit -> string
(** 生成兼容性报告
    @return 兼容性状态报告字符串 *)
