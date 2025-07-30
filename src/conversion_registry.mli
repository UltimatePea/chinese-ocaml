(** Token转换器注册和调度模块接口 - Issue #1318 统一重构
 *
 *  统一Token转换系统的主入口点，提供向后兼容的转换接口
 *  基于Token_conversion_unified模块构建
 *  
 *  ## 核心功能
 *  - 统一Token转换接口
 *  - 批量Token转换  
 *  - 转换统计信息
 *  - 统一异常处理
 *  
 *  @author 骆言技术债务清理团队
 *  @version 3.0 - 基于统一转换系统
 *  @since 2025-07-25 *)

exception Token_conversion_failed of string
(** Token转换失败异常
    @param string 详细错误信息，包含转换器类型和失败原因 *)

val convert_token : Token_unified.token -> Token_unified.token
(** 转换单个Token
    @param token 待转换的Token
    @return 转换后的Token
    @raise Token_conversion_failed 当转换失败时 *)

val convert_token_list : Token_unified.token list -> Token_unified.token list  
(** 批量转换Token列表
    @param tokens 待转换的Token列表
    @return 转换后的Token列表
    @raise Token_conversion_failed 当任何Token转换失败时 *)

val get_conversion_stats : unit -> Token_conversion_unified.conversion_stats
(** 获取转换系统统计信息
    @return 包含各转换器使用统计的记录 *)