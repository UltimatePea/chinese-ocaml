(** 字符串处理工具模块 - 高效字符串操作和格式化 
    第五阶段Printf.sprintf统一化重构 - 基于Base_formatter *)

(** 高效字符串构建器 *)
module StringBuilder = struct
  type t = { mutable buffer : Buffer.t }

  let create ?(initial_size = 256) () = { buffer = Buffer.create initial_size }
  let add_string builder str = Buffer.add_string builder.buffer str
  let add_char builder ch = Buffer.add_char builder.buffer ch
  let add_strings builder strings = List.iter (Buffer.add_string builder.buffer) strings
  let contents builder = Buffer.contents builder.buffer
  let clear builder = Buffer.clear builder.buffer
end

(** 常用字符串模板和格式化 - 基于Base_formatter统一化 *)
module Templates = struct
  (* 导入Base_formatter模块以使用统一格式化函数 *)
  open Base_formatter
  
  let undefined_variable var_name = undefined_variable_pattern var_name

  let function_param_mismatch func_name expected actual =
    function_param_mismatch_pattern func_name expected actual

  let type_mismatch expected actual = type_mismatch_pattern expected actual

  let file_not_found filename = file_not_found_pattern filename

  let member_not_found mod_name member_name = member_not_found_pattern mod_name member_name

  let compiling_file filename = concat_strings ["正在编译文件: "; filename]

  let compilation_complete files_count time_taken =
    concat_strings ["编译完成: "; int_to_string files_count; " 个文件，耗时 "; float_to_string time_taken; " 秒"]

  let analysis_stats total_functions duplicate_functions =
    concat_strings ["分析统计: 总函数 "; int_to_string total_functions; " 个，重复函数 "; int_to_string duplicate_functions; " 个"]

  let variable_value var_name value = concat_strings ["变量 "; var_name; " = "; value]

  let function_call func_name args =
    concat_strings ["调用函数 "; func_name; "("; String.concat ", " args; ")"]

  let type_inference expr type_result = concat_strings ["类型推断: "; expr; " : "; type_result]
end

(** 高效的多字符串连接 *)
let concat_strings ?(separator = "") strings =
  let builder = StringBuilder.create () in
  let rec add_with_sep = function
    | [] -> ()
    | [ last ] -> StringBuilder.add_string builder last
    | head :: tail ->
        StringBuilder.add_string builder head;
        StringBuilder.add_string builder separator;
        add_with_sep tail
  in
  add_with_sep strings;
  StringBuilder.contents builder

(** 诗词格式化专用工具 - 基于Base_formatter统一化 *)
module PoetryFormatting = struct
  open Base_formatter
  
  let format_couplet left_content right_content = concat_strings [left_content; "\n"; right_content]

  let format_poem_with_title title lines =
    let builder = StringBuilder.create () in
    StringBuilder.add_string builder title;
    StringBuilder.add_char builder '\n';
    List.iter
      (fun line ->
        StringBuilder.add_string builder line;
        StringBuilder.add_char builder '\n')
      lines;
    StringBuilder.contents builder
end

(** C代码生成格式化工具 - 基于Base_formatter统一化 *)
module CCodeGenFormatting = struct
  open Base_formatter
  
  let format_function_call func_name args =
    function_call_format func_name args

  let format_variable_declaration var_type var_name value =
    concat_strings [var_type; " "; var_name; " = "; value; ";"]

  let format_if_condition condition = concat_strings ["if ("; condition; ")"]
  let format_string_literal content = concat_strings ["\""; content; "\""]
end

(** Unicode安全的字符串处理 *)
module UnicodeUtils = struct
  let is_chinese_char ch =
    let code = Char.code ch in
    (* 简化的中文字符检测 - 基本汉字Unicode范围 *)
    (code >= 0x4E00 && code <= 0x9FFF)
    || (code >= 0x3400 && code <= 0x4DBF)
    || (code >= 0x20000 && code <= 0x2A6DF)

  let count_chinese_chars str =
    let count = ref 0 in
    String.iter (fun ch -> if is_chinese_char ch then incr count) str;
    !count
end
