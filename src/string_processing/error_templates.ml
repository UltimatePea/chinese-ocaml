(** 统一错误消息模板模块
    
    本模块提供了所有错误消息的统一格式化功能，
    用于确保错误消息的一致性和可维护性。
    
    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** 函数参数错误模板 *)
let function_param_error function_name expected_count actual_count =
  Printf.sprintf "%s函数期望%d个参数，但获得%d个参数" function_name expected_count actual_count

let function_param_type_error function_name expected_type =
  Printf.sprintf "%s函数期望%s参数" function_name expected_type

let function_single_param_error function_name =
  Printf.sprintf "%s函数期望一个参数" function_name

let function_double_param_error function_name =
  Printf.sprintf "%s函数期望两个参数" function_name

let function_no_param_error function_name =
  Printf.sprintf "%s函数不需要参数" function_name

(** 类型错误模板 *)
let type_mismatch_error expected_type actual_type =
  Printf.sprintf "类型不匹配: 期望 %s，但得到 %s" expected_type actual_type

let undefined_variable_error var_name = Printf.sprintf "未定义的变量: %s" var_name

let index_out_of_bounds_error index length =
  Printf.sprintf "索引 %d 超出范围，数组长度为 %d" index length

(** 文件操作错误模板 *)
let file_operation_error operation filename =
  Printf.sprintf "无法%s文件: %s" operation filename

(** 通用功能错误模板 *)
let generic_function_error function_name error_desc =
  Printf.sprintf "%s函数：%s" function_name error_desc

(** 编译器错误模板 - 为未来技术债务清理准备的工具函数 *)
[@@@warning "-32"]
let unsupported_feature feature = 
  Printf.sprintf "不支持的功能: %s" feature
  
[@@@warning "-32"]
let unexpected_state state context =
  Printf.sprintf "意外的状态: %s (上下文: %s)" state context
  
[@@@warning "-32"]
let invalid_character char =
  Printf.sprintf "无效字符: %c" char

[@@@warning "-32"]
let syntax_error message position =
  Printf.sprintf "语法错误 %s: %s" position message

[@@@warning "-32"]
let semantic_error message context =
  Printf.sprintf "语义错误在 %s: %s" context message
  
(** 诗词解析错误模板 - 为未来诗词模块重构准备 *)
[@@@warning "-32"]
let poetry_char_count_mismatch expected actual =
  Printf.sprintf "字符数不匹配：期望%d字，实际%d字" expected actual
  
[@@@warning "-32"]
let poetry_verse_count_warning count =
  Printf.sprintf "绝句包含%d句，通常为4句" count
  
[@@@warning "-32"]
let poetry_rhyme_mismatch verse_num expected_rhyme actual_rhyme =
  Printf.sprintf "第%d句韵脚不匹配：期望%s韵，实际%s韵" verse_num expected_rhyme actual_rhyme

[@@@warning "-32"]
let poetry_tone_pattern_error verse_num expected_pattern actual_pattern =
  Printf.sprintf "第%d句平仄不符：期望%s，实际%s" verse_num expected_pattern actual_pattern

(** 数据处理错误模板 - 为未来数据加载重构准备 *)
[@@@warning "-32"]
let data_loading_error data_type filename reason =
  Printf.sprintf "加载%s数据失败 (%s): %s" data_type filename reason

[@@@warning "-32"]
let data_validation_error field_name value reason =
  Printf.sprintf "数据验证失败 - %s: \"%s\" (%s)" field_name value reason

[@@@warning "-32"]
let data_format_error expected_format actual_format =
  Printf.sprintf "数据格式错误：期望%s格式，实际%s格式" expected_format actual_format