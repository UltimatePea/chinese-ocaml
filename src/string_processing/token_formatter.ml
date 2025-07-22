(** 骆言编译器Token字符串表示格式化器 - Printf.sprintf重复消除重构
    
    此模块提供统一的Token字符串格式化接口，完全消除Printf.sprintf依赖。
    使用Base_formatter底层基础设施，实现零重复的Token格式化。
    
    重构目标:
    - 零Printf.sprintf依赖：使用Base_formatter底层工具
    - 统一Token字符串表示格式
    - 标准化词法分析器输出
    - 简化Token调试信息
    - 提供一致的Token显示格式
    
    此重构解决了格式化工具模块自身依赖Printf.sprintf的架构设计矛盾。 *)

open Utils
open Base_formatter

(** Token格式化器 *)
module Token_formatter = struct
  (** 基本Token类型格式化 - 使用Base_formatter消除Printf.sprintf *)
  let int_token i = token_pattern "IntToken" (int_to_string i)
  let float_token f = token_pattern "FloatToken" (float_to_string f)
  let string_token s = token_pattern "StringToken" s
  let char_token c = char_token_pattern "CharToken" c
  let bool_token b = token_pattern "BoolToken" (bool_to_string b)
  
  (** 关键字Token格式化 - 使用Base_formatter *)
  let keyword_token k = token_pattern "KeywordToken" k
  let identifier_token id = token_pattern "IdentifierToken" id
  let operator_token op = token_pattern "OperatorToken" op
  
  (** 特殊Token格式化 *)
  let eof_token () = "EOFToken"
  let newline_token () = "NewlineToken"
  let whitespace_token () = "WhitespaceToken"
  let comment_token content = token_pattern "CommentToken" content
  
  (** 中文特定Token格式化 - 使用Base_formatter *)
  let chinese_char_token char = token_pattern "ChineseCharToken" char
  let chinese_punctuation_token punct = token_pattern "ChinesePunctuationToken" punct
  let chinese_number_token num = token_pattern "ChineseNumberToken" num
  
  (** 错误Token格式化 - 使用Base_formatter *)
  let invalid_token content = token_pattern "InvalidToken" content
  let unexpected_char_token char = char_token_pattern "UnexpectedCharToken" char
  
  (** Token位置信息格式化 - 使用Base_formatter *)
  let token_with_position token_str line column = 
    token_position_pattern token_str line column
  
  (** Token序列格式化 - 使用Base_formatter *)
  let token_sequence tokens = 
    list_format tokens
  
  (** Token调试信息格式化 - 使用Base_formatter *)
  let token_debug_info token_type content position = 
    concat_strings [token_pattern token_type content; "@"; position]
  
  (** 复合Token格式化 - 使用Base_formatter *)
  let function_call_token func_name args = 
    token_pattern "FunctionCallToken" 
      (concat_strings [func_name; ", "; list_format args])
  
  let module_access_token module_name member_name = 
    token_pattern "ModuleAccessToken" 
      (module_access_format module_name member_name)
  
  (** 简化Token显示（用于用户友好输出） *)
  let simple_token_display = function
    | "IntToken" -> "整数"
    | "FloatToken" -> "浮点数"
    | "StringToken" -> "字符串"
    | "BoolToken" -> "布尔值"
    | "KeywordToken" -> "关键字"
    | "IdentifierToken" -> "标识符"
    | "OperatorToken" -> "操作符"
    | "EOFToken" -> "文件结束"
    | "ChineseCharToken" -> "中文字符"
    | token_type -> token_type
end