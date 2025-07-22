(** 字符串处理工具模块 - 高效字符串操作和格式化 *)

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

(** 常用字符串模板和格式化 *)
module Templates = struct
  let undefined_variable var_name = Printf.sprintf "未定义的变量: %s" var_name

  let function_param_mismatch func_name expected actual =
    Printf.sprintf "函数「%s」参数数量不匹配: 期望 %d 个参数，但提供了 %d 个参数" func_name expected actual

  let type_mismatch expected actual = Printf.sprintf "类型不匹配: 期望 %s，但得到 %s" expected actual

  let file_not_found filename = Printf.sprintf "文件未找到: %s" filename

  let member_not_found mod_name member_name = Printf.sprintf "模块 %s 中未找到成员: %s" mod_name member_name

  let compiling_file filename = Printf.sprintf "正在编译文件: %s" filename

  let compilation_complete files_count time_taken =
    Printf.sprintf "编译完成: %d 个文件，耗时 %.2f 秒" files_count time_taken

  let analysis_stats total_functions duplicate_functions =
    Printf.sprintf "分析统计: 总函数 %d 个，重复函数 %d 个" total_functions duplicate_functions

  let variable_value var_name value = Printf.sprintf "变量 %s = %s" var_name value

  let function_call func_name args =
    Printf.sprintf "调用函数 %s(%s)" func_name (String.concat ", " args)

  let type_inference expr type_result = Printf.sprintf "类型推断: %s : %s" expr type_result
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

(** 诗词格式化专用工具 *)
module PoetryFormatting = struct
  let format_couplet left_content right_content = Printf.sprintf "%s\n%s" left_content right_content

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

(** C代码生成格式化工具 *)
module CCodeGenFormatting = struct
  let format_function_call func_name args =
    Printf.sprintf "%s(%s)" func_name (String.concat ", " args)

  let format_variable_declaration var_type var_name value =
    Printf.sprintf "%s %s = %s;" var_type var_name value

  let format_if_condition condition = Printf.sprintf "if (%s)" condition
  let format_string_literal content = Printf.sprintf "\"%s\"" content
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
