(** 错误消息常量模块 - 优化版本使用高效字符串处理 *)

(** 变量和模块相关错误 *)
let undefined_variable var_name = Printf.sprintf "未定义的变量: %s" var_name

let module_not_found mod_name = Printf.sprintf "未找到模块: %s" mod_name

let member_not_found mod_name member_name = Printf.sprintf "模块 %s 中未找到成员: %s" mod_name member_name

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
let type_mismatch expected actual = Printf.sprintf "类型不匹配: 期望 %s，实际 %s" expected actual

let unknown_type type_name = Printf.sprintf "未知类型: %s" type_name
let invalid_type_operation op_name = Printf.sprintf "无效的类型操作: %s" op_name

(** 函数相关错误 *)
let function_not_found func_name = Printf.sprintf "未找到函数: %s" func_name

let invalid_argument_count expected actual =
  Printf.sprintf "参数个数不匹配: 期望 %d，实际 %d" expected actual

let invalid_argument_type expected actual = Printf.sprintf "参数类型不匹配: 期望 %s，实际 %s" expected actual

(** 解析器错误 *)
let unexpected_token token = Printf.sprintf "意外的token: %s" token

let expected_token expected actual = Printf.sprintf "期望token %s，实际 %s" expected actual
let syntax_error message = Printf.sprintf "语法错误: %s" message

(** 古雅体语法相关错误 *)
let ancient_list_syntax_error =
  Printf.sprintf "%s\n%s\n%s\n%s"
    "请使用古雅体列表语法替代 [...]。"
    "空列表：空空如也"
    "有元素的列表：列开始 元素1 其一 元素2 其二 元素3 其三 列结束"
    "模式匹配：有首有尾 首名为「变量名」尾名为「尾部变量名」"

(** 运行时错误 *)
let division_by_zero = "除零错误"

let stack_overflow = "栈溢出"
let out_of_memory = "内存不足"
let invalid_operation operation = Printf.sprintf "无效操作: %s" operation

(** 文件I/O错误 *)
let file_not_found filename = Printf.sprintf "文件未找到: %s" filename

let file_read_error filename = Printf.sprintf "文件读取错误: %s" filename
let file_write_error filename = Printf.sprintf "文件写入错误: %s" filename

(** 配置错误 *)
let config_parse_error message = Printf.sprintf "配置解析错误: %s" message

let invalid_config_value key value = Printf.sprintf "无效配置值 %s: %s" key value

(** 通用错误模板 *)
let unsupported_char_error char_bytes = Printf.sprintf "不支持的字符: %s" char_bytes
