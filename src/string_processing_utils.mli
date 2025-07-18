(** 字符串处理工具函数模块 - String Processing Utilities Module

    这个模块提供了骆言编程语言中常用的字符串处理工具函数，主要用于 词法分析、语法分析和代码预处理阶段。该模块通过提供通用的字符串 处理功能，减少代码重复，提高代码的可维护性和可复用性。

    该模块的主要职责包括：
    - 提供字符串处理的通用模板和框架
    - 实现各种注释的移除功能
    - 处理不同类型的字符串字面量
    - 支持复杂的字符串扫描和跳过逻辑
    - 优化字符串处理的性能和内存使用

    支持的字符串处理功能：
    - 通用字符串扫描框架
    - 块注释处理 (* ... *)
    - 行注释处理 (// 和 # 风格)
    - 骆言字符串字面量处理 『...』
    - 英文字符串字面量处理 "..." 和 '...'
    - 嵌套结构的正确处理
    - 转义字符的支持

    @author 骆言项目组
    @since 0.1.0 *)

val process_string_with_skip : string -> (int -> string -> int -> bool * int) -> string
(** 字符串处理的通用模板函数，提供灵活的字符串扫描和处理框架

    @param line 待处理的字符串
    @param skip_logic 跳过逻辑函数，接受 (当前位置, 字符串, 字符串长度) 返回 (是否跳过, 跳过长度)
    @return 处理后的字符串

    这是一个通用的字符串处理模板，提供了灵活的字符串扫描框架：

    1. 处理流程：
    - 遍历输入字符串的每个字符
    - 对每个位置调用skip_logic函数
    - 根据skip_logic的返回值决定是否跳过字符
    - 将未跳过的字符加入结果字符串

    2. skip_logic函数说明：
    - 参数1：当前扫描位置（从0开始）
    - 参数2：完整的输入字符串
    - 参数3：字符串的总长度
    - 返回值：(是否跳过, 跳过长度)
    - 如果返回(true, n)，跳过从当前位置开始的n个字符
    - 如果返回(false, _)，保留当前字符

    3. 使用场景：
    - 注释移除：识别注释开始和结束标记
    - 字符串字面量处理：跳过字符串内容
    - 特殊字符处理：处理转义序列
    - 词法分析：忽略特定的语法元素

    4. 性能特性：
    - 单次遍历：只需要一次字符串扫描
    - 内存优化：使用StringBuilder避免频繁的字符串连接
    - 灵活性：支持复杂的跳过逻辑

    示例用法： ```ocaml (* 移除所有空白字符 *) let remove_whitespace s = process_string_with_skip s (fun pos str
    len -> if pos < len && (str.[pos] = ' ' || str.[pos] = '\t') then (true, 1) else (false, 0)) ```
*)

val remove_block_comments : string -> string
(** 移除OCaml风格的块注释 (* ... *)

    @param input 包含块注释的字符串
    @return 移除块注释后的字符串

    该函数移除字符串中的所有块注释，支持：

    1. 基本块注释：(* 注释内容 *)
    - 正确识别注释的开始和结束标记
    - 移除注释内容，保留注释外的代码

    2. 嵌套块注释：(* 外层 (* 内层 *) 注释 *)
    - 支持任意深度的注释嵌套
    - 正确匹配嵌套的开始和结束标记
    - 维护嵌套计数器确保正确解析

    3. 特殊情况处理：
    - 字符串内的假注释标记：let s = "(*not a comment*)"
    - 字符字面量中的标记：let c = '*'
    - 注释中的字符串：(* "this is in comment" *)

    4. 处理逻辑：
    - 扫描字符串寻找 (* 开始标记
    - 维护嵌套深度计数器
    - 遇到 *) 时减少嵌套计数
    - 当计数器归零时结束注释

    该函数常用于：
    - 代码预处理阶段
    - 词法分析前的清理
    - 代码格式化工具
    - 文档生成工具 *)

val remove_luoyan_strings : string -> string
(** 移除骆言风格的字符串字面量 『...』

    @param input 包含骆言字符串的字符串
    @return 移除字符串字面量后的字符串

    该函数移除骆言特有的字符串字面量标记，支持：

    1. 基本字符串：『文本内容』
    - 识别骆言字符串的开始标记『
    - 寻找对应的结束标记』
    - 移除整个字符串字面量

    2. 转义序列支持：
    - 转义的引号：『包含『转义』的字符串』
    - 特殊字符：『换行符\n』
    - Unicode字符：『中文字符』

    3. 多行字符串：
    - 支持跨多行的字符串字面量
    - 正确处理换行符和缩进
    - 保持字符串的完整性

    4. 错误处理：
    - 检测未闭合的字符串
    - 处理转义序列错误
    - 提供有用的错误信息

    处理流程： 1. 扫描寻找『开始标记 2. 进入字符串模式，处理转义序列 3. 寻找对应的』结束标记 4. 移除整个字符串字面量

    该函数用于：
    - 词法分析阶段的字符串处理
    - 代码预处理和清理
    - 语法高亮和代码分析 *)

val remove_english_strings : string -> string
(** 移除英文风格的字符串字面量

    @param input 包含英文字符串的字符串
    @return 移除字符串字面量后的字符串

    该函数移除传统的英文字符串字面量，支持：

    1. 双引号字符串：支持双引号包围的字符串
    - 识别双引号开始和结束标记
    - 处理字符串内的转义序列
    - 支持多行字符串

    2. 单引号字符串：主要用于字符字面量
    - 支持转义字符和特殊字符
    - 处理Unicode字符

    3. 转义序列处理：
    - 反斜杠转义序列处理
    - 控制字符处理
    - 八进制和十六进制字符
    - Unicode字符支持

    4. 字符串嵌套：
    - 正确处理引号的嵌套
    - 支持不同引号类型的混合
    - 正确的优先级处理

    处理算法： 1. 识别引号类型（单引号或双引号） 2. 进入字符串模式 3. 处理转义序列 4. 寻找匹配的结束引号 5. 移除整个字符串字面量

    该函数适用于：
    - 多语言编程环境
    - 代码混合模式处理
    - 兼容性代码分析
    - 语法转换工具 *)

val remove_double_slash_comment : string -> string
(** 移除C++/Java风格的双斜杠注释 //

    @param input 包含双斜杠注释的字符串
    @return 移除注释后的字符串

    该函数移除行注释，支持：

    1. 基本行注释：// 注释内容
    - 识别双斜杠开始标记
    - 移除从//到行尾的所有内容
    - 保留换行符维持代码结构

    2. 行尾注释：let x = 42 // 这是注释
    - 保留代码部分
    - 移除注释部分
    - 正确处理代码和注释的分界

    3. 特殊情况处理：
    - 字符串内的假注释：需要正确识别
    - 字符字面量：需要正确处理
    - 正则表达式：需要正确识别

    4. 多行处理：
    - 每行独立处理//注释
    - 不影响其他行的内容
    - 保持代码的行结构

    处理逻辑： 1. 按行分割输入字符串 2. 对每行寻找//标记 3. 检查//是否在字符串内 4. 移除//之后的内容 5. 重新组合处理后的行

    该函数用于：
    - 多语言项目的注释处理
    - 代码预处理阶段
    - 语法分析器的准备工作
    - 代码清理工具 *)

val remove_hash_comment : string -> string
(** 移除Shell/Python风格的井号注释 #

    @param input 包含井号注释的字符串
    @return 移除注释后的字符串

    该函数移除以#开头的行注释，支持：

    1. 基本井号注释：# 注释内容
    - 识别井号开始标记
    - 移除从#到行尾的所有内容
    - 保留换行符和代码结构

    2. 行尾注释：x = 42 # 这是注释
    - 保留代码部分
    - 移除注释部分
    - 正确处理代码和注释的分界

    3. 特殊情况处理：
    - 字符串内的井号：需要正确识别
    - 字符字面量：需要正确处理
    - 预处理指令：需要正确识别

    4. 脚本文件支持：
    - Shell脚本：shebang处理
    - Python脚本：环境变量支持
    - 其他脚本语言的shebang

    处理特点：
    - 简单高效的单行注释处理
    - 支持多种脚本语言风格
    - 正确区分注释和代码
    - 保持代码格式不变

    处理流程： 1. 按行扫描输入字符串 2. 对每行寻找#字符 3. 检查#是否在字符串字面量内 4. 移除#之后的内容 5. 保留代码部分和行结构

    该函数适用于：
    - 脚本语言的代码处理
    - 配置文件的注释移除
    - 多语言项目的统一处理
    - 代码分析和转换工具 *)

(** 统一字符串格式化工具模块 - 为解决字符串处理重复问题而设计的统一接口

    该模块提供了一系列子模块来统一处理骆言编程语言中常见的字符串格式化需求， 旨在消除代码重复，提高代码的可维护性和一致性。 *)

(** 通用错误消息模板模块 *)
module ErrorMessageTemplates : sig
  val function_param_error : string -> int -> int -> string
  (** 函数参数数量错误消息 *)

  val function_param_type_error : string -> string -> string
  (** 函数参数类型错误消息 *)

  val function_single_param_error : string -> string
  (** 单参数函数错误消息 *)

  val function_double_param_error : string -> string
  (** 双参数函数错误消息 *)

  val function_no_param_error : string -> string
  (** 无参数函数错误消息 *)

  val type_mismatch_error : string -> string -> string
  (** 类型不匹配错误消息 *)

  val undefined_variable_error : string -> string
  (** 未定义变量错误消息 *)

  val index_out_of_bounds_error : int -> int -> string
  (** 索引越界错误消息 *)

  val file_operation_error : string -> string -> string
  (** 文件操作错误消息 *)

  val generic_function_error : string -> string -> string
  (** 通用函数错误消息 *)
end

(** 位置信息格式化模块 *)
module PositionFormatting : sig
  val format_position_with_fields : filename:string -> line:int -> column:int -> string
  (** 通用位置格式化函数，使用命名参数 *)

  val format_position_with_extractor :
    'a -> get_filename:('a -> string) -> get_line:('a -> int) -> get_column:('a -> int) -> string
  (** 使用提取函数的位置格式化，支持任意位置类型 *)

  val format_compiler_error_position_from_fields : string -> int -> int -> string
  (** 格式化编译器错误位置，从独立字段构建 *)

  val format_optional_position_with_extractor :
    'a option ->
    get_filename:('a -> string) ->
    get_line:('a -> int) ->
    get_column:('a -> int) ->
    string
  (** 格式化可选位置信息，使用提取函数 *)

  val error_with_position_extractor :
    'a option ->
    string ->
    string ->
    get_filename:('a -> string) ->
    get_line:('a -> int) ->
    get_column:('a -> int) ->
    string
  (** 带位置信息的错误消息，使用提取函数 *)
end

(** C代码生成格式化模块 *)
module CCodegenFormatting : sig
  val function_call : string -> string list -> string
  (** 函数调用格式化 *)

  val binary_function_call : string -> string -> string -> string
  (** 双参数函数调用格式化 *)

  val string_equality_check : string -> string -> string
  (** 字符串相等性检查格式化 *)

  val type_conversion : string -> string -> string
  (** 类型转换格式化 *)
end

(** 列表和集合格式化模块 *)
module CollectionFormatting : sig
  val join_chinese : string list -> string
  (** 中文顿号分隔 *)

  val join_english : string list -> string
  (** 英文逗号分隔 *)

  val join_semicolon : string list -> string
  (** 分号分隔 *)

  val join_newline : string list -> string
  (** 换行分隔 *)

  val indented_list : string list -> string
  (** 带缩进的项目列表 *)

  val array_format : string list -> string
  (** 数组格式化 *)

  val tuple_format : string list -> string
  (** 元组格式化 *)

  val type_signature_format : string list -> string
  (** 类型签名格式化 *)
end

(** 报告生成格式化模块 *)
module ReportFormatting : sig
  val stats_line : string -> string -> int -> string
  (** 统计信息行格式化 *)

  val analysis_result_line : string -> string -> string
  (** 分析结果行格式化 *)

  val context_line : string -> string
  (** 上下文信息行格式化 *)

  val suggestion_line : string -> string -> string
  (** 建议信息格式化 *)

  val similarity_suggestion : string -> float -> string
  (** 相似度建议格式化 *)
end

(** 颜色和样式格式化模块 *)
module StyleFormatting : sig
  val with_color : string -> string -> string
  (** 通用颜色格式化 *)

  val red_text : string -> string
  (** 红色文本 *)

  val green_text : string -> string
  (** 绿色文本 *)

  val yellow_text : string -> string
  (** 黄色文本 *)

  val blue_text : string -> string
  (** 蓝色文本 *)

  val bold_text : string -> string
  (** 粗体文本 *)
end

(** Buffer累积辅助模块 *)
module BufferHelpers : sig
  val add_formatted_string : Buffer.t -> (unit -> string) -> unit
  (** 安全地向Buffer添加格式化字符串 *)

  val add_stats_batch : Buffer.t -> (string * string * int) list -> unit
  (** 批量添加统计信息 *)

  val add_error_with_context : Buffer.t -> string -> string option -> unit
  (** 添加带上下文的错误信息 *)
end
