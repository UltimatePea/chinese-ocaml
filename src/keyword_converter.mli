(** 关键字转换器接口 - Issue #1684 技术债务清理
 *
 *  提供各种类型关键字转换功能的公共接口，支持基础语言、自然语言、文言文等多种关键字转换
 *
 *  @author Alpha代理 Issue #1684
 *  @version 4.0 - Issue #1684: 创建缺失的接口文件
 *  @since 2025-07-29 *)

(** {1 异常定义} *)

exception Unknown_basic_keyword_token of string
(** 基础关键字转换异常
    
    当遇到无法识别的基础关键字令牌时抛出此异常
    
    @param string 错误描述信息，包含无法转换的关键字详情 *)

exception Unknown_type_keyword_token of string
(** 类型关键字转换异常
    
    当遇到无法识别的类型关键字令牌时抛出此异常
    
    @param string 错误描述信息，包含无法转换的类型关键字详情 *)

(** {1 转换统计} *)

val get_basic_keyword_rule_count : unit -> int
(** 获取基础关键字转换规则数量
    
    返回当前系统支持的基础关键字转换规则总数，用于统计和性能分析
    
    @return 基础关键字转换规则的总数量（约126个） *)

val get_type_keyword_rule_count : unit -> int
(** 获取类型关键字转换规则数量
    
    返回当前系统支持的类型关键字转换规则总数，用于统计和性能分析
    
    @return 类型关键字转换规则的总数量（约13个） *)

(** {1 核心转换功能} *)

val convert_basic_keyword_token :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 基础关键字令牌转换主函数
    
    将输入的基础关键字令牌转换为目标格式。通过统一转换系统提供转换服务，
    支持所有基础语言构造的关键字。
    
    @param token 需要转换的基础关键字令牌
    @return 转换后的关键字令牌
    @raise Unknown_basic_keyword_token 当关键字无法识别或转换失败时
    
    @example
    {[
      let result = convert_basic_keyword_token keyword_token in
      (* 处理转换结果 *)
    ]} *)

val convert_type_keyword_token :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 类型关键字令牌转换主函数
    
    将输入的类型关键字令牌转换为目标格式。专门处理类型定义相关的关键字。
    
    @param token 需要转换的类型关键字令牌
    @return 转换后的类型关键字令牌
    @raise Unknown_type_keyword_token 当类型关键字无法识别或转换失败时 *)

(** {1 专门化转换功能} *)

val convert_basic_language_keywords :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 基础语言关键字转换函数
    
    处理基础程序语言构造的关键字，包括 let、rec、in、fun、if、then、else 等。
    
    @param keyword 统一令牌系统的基础语言关键字
    @return 词法分析器令牌系统的对应关键字
    @raise Unknown_basic_keyword_token 当关键字不是基础语言关键字时 *)

val convert_semantic_keywords :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 语义关键字转换函数
    
    处理语义构造相关的关键字，包括 as、combine、with、when 等。
    
    @param keyword 统一令牌系统的语义关键字
    @return 词法分析器令牌系统的对应关键字
    @raise Unknown_basic_keyword_token 当关键字不是语义关键字时 *)

val convert_error_recovery_keywords :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 错误恢复关键字转换函数
    
    处理错误处理和异常恢复相关的关键字，包括 try、catch、finally、exception 等。
    
    @param keyword 统一令牌系统的错误恢复关键字
    @return 词法分析器令牌系统的对应关键字
    @raise Unknown_basic_keyword_token 当关键字不是错误恢复关键字时 *)

val convert_module_keywords :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 模块关键字转换函数
    
    处理模块系统相关的关键字，包括 module、sig、end、include、functor 等。
    
    @param keyword 统一令牌系统的模块关键字
    @return 词法分析器令牌系统的对应关键字
    @raise Unknown_basic_keyword_token 当关键字不是模块关键字时 *)

val convert_natural_language_keywords :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 自然语言关键字转换函数
    
    处理自然语言风格的关键字，包括各种中文表达的程序构造。
    
    @param keyword 统一令牌系统的自然语言关键字
    @return 词法分析器令牌系统的对应关键字
    @raise Unknown_basic_keyword_token 当关键字不是自然语言关键字时 *)

val convert_wenyan_keywords :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 文言文关键字转换函数
    
    处理文言文风格的关键字，支持古典中文编程语法。
    
    @param keyword 统一令牌系统的文言文关键字
    @return 词法分析器令牌系统的对应关键字
    @raise Unknown_basic_keyword_token 当关键字不是文言文关键字时 *)

val convert_ancient_keywords :
  Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token
(** 古雅体关键字转换函数
    
    处理古雅体风格的关键字，支持最古典的中文编程语法形式。
    
    @param keyword 统一令牌系统的古雅体关键字
    @return 词法分析器令牌系统的对应关键字
    @raise Unknown_basic_keyword_token 当关键字不是古雅体关键字时 *)

(** {1 使用说明}
    
    此模块是统一转换系统的兼容性层，为各种类型的关键字转换提供专门化的接口。
    所有转换功能都通过底层的统一转换系统实现，确保转换的一致性和性能。
    
    关键字转换特点：
    - 支持多种编程语言风格的关键字
    - 从中文关键字到OCaml兼容关键字的转换
    - 保持语法语义的准确性
    - 提供详细的错误信息和类型安全保证
    
    典型使用模式：
    {[
      (* 基础关键字转换 *)
      try
        let result = Keyword_converter.convert_basic_keyword_token token in
        (* 处理转换结果 *)
        result
      with
      | Keyword_converter.Unknown_basic_keyword_token msg ->
          Printf.eprintf "基础关键字转换失败: %s\n" msg;
          raise (Failure "关键字转换错误")
      
      (* 特定类型关键字转换 *)
      match keyword_type with
      | `Natural -> convert_natural_language_keywords keyword
      | `Wenyan -> convert_wenyan_keywords keyword
      | `Ancient -> convert_ancient_keywords keyword
      | `Module -> convert_module_keywords keyword
    ]}
    
    注意事项：
    - 确保输入的令牌类型与转换函数匹配
    - 不同类型的关键字使用相应的专门化转换函数
    - 转换失败时会提供详细的错误信息和上下文
    - 所有转换都保证类型安全和语义正确性 *)