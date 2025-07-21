(** 
 * 统一字符串格式化模块
 * 提供项目中常用的字符串格式化功能，减少代码重复
 * 2025年7月21日 - 技术债务改进
 *)

(** 错误消息格式化模块 *)
module Error = struct
  (** 函数参数数量不匹配错误 *)
  let function_param_count_mismatch func_name expected actual =
    Printf.sprintf "%s函数期望%d个参数，但获得%d个参数" func_name expected actual

  (** 类型不匹配错误 *)
  let type_mismatch expected actual =
    Printf.sprintf "类型不匹配: 期望 %s，但得到 %s" expected actual

  (** 运行时错误（带错误类别） *)
  let runtime_error_with_category category detail =
    Printf.sprintf "运行时错误：%s '%s'" category detail

  (** 未定义变量错误 *)
  let undefined_variable var_name =
    Printf.sprintf "未定义的变量: %s" var_name

  (** 数组索引越界错误 *)
  let array_bounds_error index array_length =
    Printf.sprintf "索引 %d 超出范围，数组长度为 %d" index array_length

  (** 解析错误（带位置信息） *)
  let parse_error_with_position line col message =
    Printf.sprintf "解析错误 (%d:%d): %s" line col message

  (** 通用错误模板 *)
  let error_template msg details =
    Printf.sprintf "%s: %s" msg details

  (** 错误类型模板 *)
  let error_type_template error_type specific_error =
    Printf.sprintf "错误类型：%s '%s'" error_type specific_error
end

(** 位置和源码位置格式化模块 *)
module Position = struct
  (** 文件位置格式 filename:line:column *)
  let file_position filename line col =
    Printf.sprintf "%s:%d:%d" filename line col

  (** 行列位置格式 *)
  let line_column line col =
    Printf.sprintf "行%d列%d" line col

  (** 带上下文的位置格式 *)
  let position_with_context message filename line =
    Printf.sprintf "%s (%s:%d)" message filename line
end

(** C代码生成格式化模块 *)
module CCodegen = struct
  (** 环境变量绑定 *)
  let env_bind var_name expr_code =
    Printf.sprintf "luoyan_env_bind(env, \"%s\", %s);" var_name expr_code

  (** 骆言运行时值创建器 *)
  module Value = struct
    let int i = Printf.sprintf "luoyan_int(%dL)" i
    let float f = Printf.sprintf "luoyan_float(%g)" f
    let string s = Printf.sprintf "luoyan_string(\"%s\")" s
    let bool b = Printf.sprintf "luoyan_bool(%s)" (if b then "true" else "false")
  end

  (** 数组操作 *)
  module Array = struct
    let create size elements =
      Printf.sprintf "luoyan_array(%d, %s)" size elements
    let get array_expr index_expr =
      Printf.sprintf "luoyan_array_get(%s, %s)" array_expr index_expr
    let set array_expr index_expr value_expr =
      Printf.sprintf "luoyan_array_set(%s, %s, %s)" array_expr index_expr value_expr
  end

  (** 函数调用格式化 *)
  let function_call func_name args =
    Printf.sprintf "%s(%s)" func_name (String.concat ", " args)

  (** 变量声明 *)
  let variable_declaration type_name var_name =
    Printf.sprintf "%s %s" type_name var_name

  (** 头文件包含 *)
  let include_system header = Printf.sprintf "#include <%s>" header
  let include_local header = Printf.sprintf "#include \"%s\"" header

  (** 注释格式 *)
  let comment text = Printf.sprintf "/* %s */" text
  let line_comment text = Printf.sprintf "// %s" text
end

(** 报告和进度格式化模块 *)
module Report = struct
  (** 带图标的统计信息 *)
  let stats_with_icon icon category count =
    Printf.sprintf "   %s %s: %d 个" icon category count

  (** 操作计时信息 *)
  let operation_timing operation duration =
    Printf.sprintf "完成 %s (耗时: %.3f秒)" operation duration

  (** 分类计数（自动选择图标） *)
  let categorized_count category count =
    let icon = match category with
      | "错误" -> "🚨"
      | "警告" -> "⚠️"
      | "风格" -> "🎨"
      | "信息" -> "ℹ️"
      | _ -> "📊"
    in
    Printf.sprintf "%s %s: %d 个" icon category count

  (** 简单的总数统计 *)
  let total_count category count =
    Printf.sprintf "总%s数: %d" category count

  (** 进度指示器 *)
  let progress_indicator current total message =
    Printf.sprintf "[%d/%d] %s" current total message
end

(** 诗词和语言处理格式化模块 *)
module Poetry = struct
  (** 字符数不匹配错误 *)
  let character_count_mismatch expected actual =
    Printf.sprintf "字符数不匹配：期望%d字，实际%d字" expected actual

  (** 诗句数量提示 *)
  let verse_count_warning actual expected poem_type =
    Printf.sprintf "%s包含%d句，通常为%d句" poem_type actual expected

  (** 韵律分析结果 *)
  let rhyme_analysis result_type content =
    Printf.sprintf "韵律分析（%s）: %s" result_type content

  (** 平仄模式 *)
  let tone_pattern pattern =
    Printf.sprintf "平仄模式: %s" pattern
end

(** Token和解析格式化模块 *)
module Token = struct
  (** 整数Token *)
  let int_token value = Printf.sprintf "IntToken(%d)" value

  (** 字符串Token *)
  let string_token value = Printf.sprintf "StringToken(%s)" value

  (** 布尔Token *)
  let bool_token value = Printf.sprintf "BoolToken(%b)" value

  (** 标识符Token *)
  let identifier_token name = Printf.sprintf "IdentifierToken(%s)" name

  (** 关键字Token *)
  let keyword_token keyword = Printf.sprintf "KeywordToken(%s)" keyword
end

(** 数据加载和验证格式化模块 *)
module Data = struct
  (** 数据加载失败 *)
  let loading_failure data_type filename error_msg =
    Printf.sprintf "加载%s数据失败 (%s): %s" data_type filename error_msg

  (** 数据验证失败 *)
  let validation_failure field_name value error_msg =
    Printf.sprintf "数据验证失败 - %s: \"%s\" (%s)" field_name value error_msg

  (** JSON解析错误 *)
  let json_parse_error filename error_detail =
    Printf.sprintf "JSON解析错误 (%s): %s" filename error_detail

  (** 数据缓存信息 *)
  let cache_status operation data_type =
    Printf.sprintf "缓存%s: %s数据" operation data_type
end

(** 通用格式化工具 *)
module Common = struct
  (** 简单的键值对格式 *)
  let key_value key value =
    Printf.sprintf "%s: %s" key value

  (** 列表格式化 *)
  let list_format items separator =
    String.concat separator items

  (** 带括号的格式 *)
  let parenthesized content =
    Printf.sprintf "(%s)" content

  (** 带方括号的格式 *)
  let bracketed content =
    Printf.sprintf "[%s]" content

  (** 带大括号的格式 *)
  let braced content =
    Printf.sprintf "{%s}" content
end