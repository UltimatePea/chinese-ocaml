(** 标识符转换器接口 - Issue #1684 技术债务清理
 *
 *  提供标识符转换功能的公共接口，处理变量名、函数名等标识符的转换
 *
 *  @author Alpha代理 Issue #1684
 *  @version 4.0 - Issue #1684: 创建缺失的接口文件
 *  @since 2025-07-29 *)

(** {1 异常定义} *)

exception Unknown_identifier_token of string
(** 标识符转换异常
    
    当遇到无法识别的标识符令牌时抛出此异常
    
    @param string 错误描述信息，包含无法转换的标识符详情 *)

(** {1 转换统计} *)

val get_rule_count : unit -> int
(** 获取标识符转换规则数量
    
    返回当前系统支持的标识符转换规则总数。由于标识符转换相对简单，
    规则数量较少，主要用于统计和监控目的。
    
    @return 转换规则的总数量（通常为2） *)

(** {1 核心转换功能} *)

val convert_identifier_token :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 标识符令牌转换主函数
    
    将输入的标识符令牌转换为目标格式。此函数处理各种标识符类型，
    包括变量名、函数名、类型名等，通过统一转换系统提供转换服务。
    
    @param token 需要转换的标识符令牌
    @return 转换后的标识符令牌
    @raise Unknown_identifier_token 当标识符无法识别或转换失败时
    
    @example
    {[
      let converted_id = convert_identifier_token identifier_token in
      (* 使用转换后的标识符 *)
    ]} *)

(** {1 使用说明}
    
    此模块是统一转换系统的兼容性层，专门处理标识符的转换需求。
    所有转换功能都通过底层的统一转换系统实现，确保转换的一致性。
    
    标识符转换特点：
    - 支持中文标识符到OCaml兼容标识符的转换
    - 处理特殊字符和Unicode字符
    - 保持标识符的语义含义
    - 确保转换结果符合目标语言的标识符规范
    
    典型使用模式：
    {[
      try
        let result = Identifier_converter.convert_identifier_token token in
        (* 处理转换结果 *)
        result
      with
      | Identifier_converter.Unknown_identifier_token msg ->
          (* 处理转换错误 *)
          Printf.eprintf "标识符转换失败: %s\n" msg;
          raise (Failure "标识符转换错误")
    ]}
    
    注意事项：
    - 确保输入的令牌确实是标识符类型
    - 转换失败时会提供详细的错误信息
    - 转换结果保证符合目标语言的标识符规范 *)