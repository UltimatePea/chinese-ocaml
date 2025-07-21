(** 骆言编译器Token字符串表示格式化器 - 第九阶段代码重复消除
    
    此模块提供统一的Token字符串格式化接口，消除项目中分散的Printf.sprintf Token表示模式。
    
    设计目标:
    - 统一Token字符串表示格式
    - 标准化词法分析器输出
    - 简化Token调试信息
    - 提供一致的Token显示格式 *)

(** Token格式化器 *)
module Token_formatter = struct
  (** 基本Token类型格式化 *)
  let int_token i = Printf.sprintf "IntToken(%d)" i
  let float_token f = Printf.sprintf "FloatToken(%g)" f
  let string_token s = Printf.sprintf "StringToken(%s)" s
  let char_token c = Printf.sprintf "CharToken('%c')" c
  let bool_token b = Printf.sprintf "BoolToken(%b)" b
  
  (** 关键字Token格式化 *)
  let keyword_token k = Printf.sprintf "KeywordToken(%s)" k
  let identifier_token id = Printf.sprintf "IdentifierToken(%s)" id
  let operator_token op = Printf.sprintf "OperatorToken(%s)" op
  
  (** 特殊Token格式化 *)
  let eof_token () = "EOFToken"
  let newline_token () = "NewlineToken"
  let whitespace_token () = "WhitespaceToken"
  let comment_token content = Printf.sprintf "CommentToken(%s)" content
  
  (** 中文特定Token格式化 *)
  let chinese_char_token char = Printf.sprintf "ChineseCharToken(%s)" char
  let chinese_punctuation_token punct = Printf.sprintf "ChinesePunctuationToken(%s)" punct
  let chinese_number_token num = Printf.sprintf "ChineseNumberToken(%s)" num
  
  (** 错误Token格式化 *)
  let invalid_token content = Printf.sprintf "InvalidToken(%s)" content
  let unexpected_char_token char = Printf.sprintf "UnexpectedCharToken('%c')" char
  
  (** Token位置信息格式化 *)
  let token_with_position token_str line column = 
    Printf.sprintf "%s@%d:%d" token_str line column
  
  (** Token序列格式化 *)
  let token_sequence tokens = 
    "[" ^ String.concat "; " tokens ^ "]"
  
  (** Token调试信息格式化 *)
  let token_debug_info token_type content position = 
    Printf.sprintf "%s(%s)@%s" token_type content position
  
  (** 复合Token格式化 *)
  let function_call_token func_name args = 
    Printf.sprintf "FunctionCallToken(%s, [%s])" func_name (String.concat "; " args)
  
  let module_access_token module_name member_name = 
    Printf.sprintf "ModuleAccessToken(%s.%s)" module_name member_name
  
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