(** 古典语言转换器接口 - Issue #1684 技术债务清理
 *
 *  提供古典语言转换功能的公共接口，包括文言文、自然语言和古代语言转换
 *
 *  @author Alpha代理 Issue #1684
 *  @version 4.0 - Issue #1684: 创建缺失的接口文件
 *  @since 2025-07-29 *)

(** {1 异常定义} *)

exception Unknown_classical_token of string
(** 古典语言转换异常
    
    当遇到无法识别的古典语言令牌时抛出此异常
    
    @param string 错误描述信息，包含无法转换的令牌详情 *)

(** {1 转换统计} *)

val get_rule_count : unit -> int
(** 获取古典语言转换规则数量
    
    返回当前系统支持的古典语言转换规则总数，用于统计和性能分析
    
    @return 转换规则的总数量 *)

(** {1 核心转换功能} *)

val convert_classical_token :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 古典语言令牌转换主函数
    
    将输入的古典语言令牌转换为目标格式。此函数是模块的核心功能，
    通过统一转换系统提供转换服务。
    
    @param token 需要转换的古典语言令牌
    @return 转换后的令牌
    @raise Unknown_classical_token 当令牌无法识别或转换失败时
    
    @example
    {[
      let result = convert_classical_token input_token in
      (* 处理转换结果 *)
    ]} *)

(** {1 专门化转换功能} *)

val convert_wenyan_token :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 文言文令牌转换函数
    
    专门用于转换文言文语法构造的令牌。实际上是 {!convert_classical_token} 
    的别名，提供更明确的语义接口。
    
    @param token 需要转换的文言文令牌
    @return 转换后的令牌
    @raise Unknown_classical_token 当令牌无法识别或转换失败时 *)

val convert_natural_language_token :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 自然语言令牌转换函数
    
    专门用于转换自然语言构造的令牌。实际上是 {!convert_classical_token} 
    的别名，用于处理更接近现代中文的语法结构。
    
    @param token 需要转换的自然语言令牌
    @return 转换后的令牌
    @raise Unknown_classical_token 当令牌无法识别或转换失败时 *)

val convert_ancient_token :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 古代语言令牌转换函数
    
    专门用于转换古代语言构造的令牌。实际上是 {!convert_classical_token} 
    的别名，用于处理更古老的中文语法形式。
    
    @param token 需要转换的古代语言令牌
    @return 转换后的令牌
    @raise Unknown_classical_token 当令牌无法识别或转换失败时 *)

(** {1 使用说明}
    
    此模块是统一转换系统的兼容性层，为古典语言转换提供简化的接口。
    所有转换功能都通过底层的统一转换系统实现，确保一致性和性能。
    
    典型使用模式：
    {[
      try
        let converted = Classical_converter.convert_classical_token token in
        (* 处理转换结果 *)
        converted
      with
      | Classical_converter.Unknown_classical_token msg ->
          (* 处理转换错误 *)
          failwith ("转换失败: " ^ msg)
    ]}
    
    对于特定类型的古典语言，可以使用相应的专门化函数：
    - {!convert_wenyan_token} 用于文言文
    - {!convert_natural_language_token} 用于自然语言构造  
    - {!convert_ancient_token} 用于古代语言构造 *)