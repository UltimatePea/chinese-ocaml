(** 错误消息常量模块 - 简化版本 *)

(** 变量和模块相关错误 *)
let undefined_variable var_name = "未定义的变量: " ^ var_name
let module_not_found mod_name = "未找到模块: " ^ mod_name
let member_not_found mod_name member_name = "模块 " ^ mod_name ^ " 中未找到成员: " ^ member_name
let empty_scope_stack = "尝试退出空作用域栈"
let empty_variable_name = "空变量名"

(** 词法分析器错误 *)
let unterminated_comment = "Unterminated comment"
let unterminated_chinese_comment = "Unterminated Chinese comment"
let unterminated_string = "Unterminated string"
let unterminated_quoted_identifier = "未闭合的引用标识符"
let invalid_char_in_quoted_identifier = "引用标识符中的无效字符"

(** 符号和数字相关错误 *)
let ascii_symbols_disabled = "ASCII符号已禁用，请使用中文标点符号"
let fullwidth_numbers_disabled = "只允许半角阿拉伯数字，请勿使用全角数字"
let arabic_numbers_disabled = "阿拉伯数字已禁用"
let unsupported_chinese_symbol = "非支持的中文符号已禁用，只支持「」『』：，。（）"
let identifiers_must_be_quoted = "标识符必须使用「」引用"
let ascii_letters_as_keywords_only = "ASCII字母已禁用，只允许作为关键字使用"

(** 类型相关错误 *)
let type_mismatch expected actual = "类型不匹配: 期望 " ^ expected ^ "，实际 " ^ actual
let unknown_type type_name = "未知类型: " ^ type_name
let invalid_type_operation op_name = "无效的类型操作: " ^ op_name

(** 函数相关错误 *)
let function_not_found func_name = "未找到函数: " ^ func_name
let invalid_argument_count expected actual = 
  "参数个数不匹配: 期望 " ^ string_of_int expected ^ "，实际 " ^ string_of_int actual
let invalid_argument_type expected actual = "参数类型不匹配: 期望 " ^ expected ^ "，实际 " ^ actual

(** 解析器错误 *)
let unexpected_token token = "意外的token: " ^ token
let expected_token expected actual = "期望token " ^ expected ^ "，实际 " ^ actual
let syntax_error message = "语法错误: " ^ message

(** 运行时错误 *)
let division_by_zero = "除零错误"
let stack_overflow = "栈溢出"
let out_of_memory = "内存不足"
let invalid_operation operation = "无效操作: " ^ operation

(** 文件I/O错误 *)
let file_not_found filename = "文件未找到: " ^ filename
let file_read_error filename = "文件读取错误: " ^ filename
let file_write_error filename = "文件写入错误: " ^ filename

(** 配置错误 *)
let config_parse_error message = "配置解析错误: " ^ message
let invalid_config_value key value = "无效配置值 " ^ key ^ ": " ^ value

(** 通用错误模板 *)
let unsupported_char_error char_bytes = "不支持的字符: " ^ char_bytes