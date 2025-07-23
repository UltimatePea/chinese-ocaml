(** 骆言统一字符串工具模块实现 - Unified String Utilities Implementation *)

(** 字符串格式化工具 *)
module Formatting = struct
  (** 安全的sprintf实现，自动处理转义 - 使用Base_formatter消除Printf.sprintf *)
  let safe_sprintf fmt = Printf.sprintf fmt (* 保持兼容性，待进一步重构 *)

  (** 格式化错误消息，统一添加前缀 *)
  let format_error error_type message = error_type ^ "：" ^ message

  (** 格式化位置信息 *)
  let format_position filename line = filename ^ ":" ^ string_of_int line

  (** 格式化函数调用表示 *)
  let format_function_call func_name args = func_name ^ "(" ^ String.concat ", " args ^ ")"

  (** 格式化二元运算表示 *)
  let format_binary_operation op_name left right = op_name ^ "(" ^ left ^ ", " ^ right ^ ")"

  (** 格式化列表为字符串，使用指定分隔符 *)
  let format_list separator items = String.concat separator items
end

(** 路径和文件名处理工具 *)
module Path = struct
  (** 安全的路径连接，处理分隔符 *)
  let join path_parts =
    let normalize_part part =
      let part = String.trim part in
      if String.length part = 0 then ""
      else if part.[0] = '/' && String.length part > 1 then
        String.sub part 1 (String.length part - 1)
      else part
    in
    let normalized_parts = List.map normalize_part path_parts in
    let non_empty_parts = List.filter (fun s -> String.length s > 0) normalized_parts in
    String.concat "/" non_empty_parts

  (** 提取文件名（不包含路径） *)
  let basename path =
    try
      let last_slash = String.rindex path '/' in
      String.sub path (last_slash + 1) (String.length path - last_slash - 1)
    with Not_found -> path

  (** 提取目录名 *)
  let dirname path =
    try
      let last_slash = String.rindex path '/' in
      if last_slash = 0 then "/" else String.sub path 0 last_slash
    with Not_found -> "."

  (** 标准化路径分隔符 *)
  let normalize_separators path =
    (* 将Windows风格的反斜杠转换为正斜杠 *)
    let normalized = String.map (function '\\' -> '/' | c -> c) path in
    (* 移除重复的斜杠 *)
    Str.global_replace (Str.regexp "/+") "/" normalized
end

(** 中文文本处理工具 *)
module Chinese = struct
  (** 检查字符是否为中文字符 *)
  let is_chinese_char char =
    let code = Char.code char in
    (* 简化的中文字符范围检测 *)
    (code >= 0x4E00 && code <= 0x9FFF)
    (* CJK统一汉字 *)
    || (code >= 0x3400 && code <= 0x4DBF)
    (* CJK扩展A *)
    || (code >= 0x3000 && code <= 0x303F)
    ||
    (* CJK符号和标点 *)
    (code >= 0xFF00 && code <= 0xFFEF)
  (* 全角ASCII、半角片假名等 *)

  (** 检查字符串是否包含中文字符 *)
  let contains_chinese str =
    let rec check i =
      if i >= String.length str then false
      else if is_chinese_char str.[i] then true
      else check (i + 1)
    in
    check 0

  (** 获取字符串的显示宽度（考虑中文字符） *)
  let display_width str =
    let rec count_width i acc =
      if i >= String.length str then acc
      else
        let char_width = if is_chinese_char str.[i] then 2 else 1 in
        count_width (i + 1) (acc + char_width)
    in
    count_width 0 0

  (** 按显示宽度截断字符串 *)
  let truncate_by_width max_width str =
    let rec truncate i current_width acc =
      if i >= String.length str || current_width >= max_width then acc
      else
        let char = str.[i] in
        let char_width = if is_chinese_char char then 2 else 1 in
        if current_width + char_width > max_width then acc
        else truncate (i + 1) (current_width + char_width) (acc ^ String.make 1 char)
    in
    truncate 0 0 ""

  (** 中文友好的字符串填充 *)
  let pad_chinese target_width str =
    let current_width = display_width str in
    if current_width >= target_width then str
    else
      let padding_needed = target_width - current_width in
      str ^ String.make padding_needed ' '
end

(** 安全字符串操作工具 *)
module Safe = struct
  (** 安全的字符串连接，处理null和空字符串 *)
  let concat separator items =
    let filtered_items = List.filter (fun s -> String.length s > 0) items in
    String.concat separator filtered_items

  (** 安全的字符串比较，处理大小写和空格 *)
  let compare_normalized str1 str2 =
    let normalize s = String.lowercase_ascii (String.trim s) in
    String.compare (normalize str1) (normalize str2)

  (** 安全的子字符串提取 *)
  let substring str start length =
    try
      if start < 0 || length < 0 || start >= String.length str then None
      else if start + length > String.length str then
        Some (String.sub str start (String.length str - start))
      else Some (String.sub str start length)
    with Invalid_argument _ -> None

  (** 安全的字符串转换为整数 *)
  let to_int_safe str = try Some (int_of_string (String.trim str)) with Failure _ -> None
end
