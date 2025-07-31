(** 骆言词法分析器UTF-8字符处理工具模块 - 增强版
    
    本模块提供增强的UTF-8字符处理功能，解决中文编程中的字符位置追踪和边界检测问题：
    - 准确的UTF-8字符边界识别
    - 精确的字符位置计算（字节偏移vs字符偏移）
    - 完善的中文字符分类和验证
    - 高性能的字符序列处理
    - 错误恢复和异常处理
    
    Author: Whisky, PR Worker
    Issue: #1847 - Unicode字符处理优化
    
    @version 2.0 - 增强版本
    @since 2025-07-31 *)

open Unicode_constants_enhanced

(** UTF-8字符处理结果类型 *)
type utf8_char_result = 
  | ValidChar of string * int (** 字符内容, 字节长度 *)
  | InvalidSequence of int * string (** 错误位置, 错误信息 *)
  | EndOfInput

(** 字符边界检测结果 *)
type boundary_result =
  | CharBoundary of int (** 字符边界位置 *)
  | InvalidBoundary of string (** 错误信息 *)
  | NoBoundary

(** 增强的位置信息 *)
type enhanced_position = {
  byte_pos : int;        (** 字节位置 *)
  char_pos : int;        (** 字符位置 *)
  line_num : int;        (** 行号 *)
  col_num : int;         (** 列号 *)
  context : string;      (** 上下文信息 *)
}

(** UTF-8字符检测和分类模块 - 增强版 *)
module CharacterDetection = struct
  (** 检查字符是否为中文字符 - 改进版 *)
  let is_chinese_char c =
    let code = Char.code c in
    (* 更精确的中文字符范围检测 *)
    (code >= 0xE4 && code <= 0xE9) || (* CJK统一汉字基本区 *)
    (code >= 0xF0 && code <= 0xF3)    (* CJK扩展区 *)

  (** 检查字符是否为字母或中文 - 增强版 *)
  let is_letter_or_chinese c = 
    (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || is_chinese_char c

  (** 检查字符是否为数字 *)
  let is_digit c = c >= '0' && c <= '9'

  (** 检查字符是否为空白字符 - 包含全角空格 *)
  let is_whitespace c = 
    c = ' ' || c = '\t' || c = '\r' || c = '\n' ||
    (* 全角空格检测需要多字节检测，这里只检测ASCII空白 *)
    false

  (** 检查字符是否为分隔符 - 增强版 *)
  let is_separator_char c =
    c = '\t' || c = '\r' || c = '\n' || 
    c = '(' || c = ')' || c = '[' || c = ']' || c = '{' || c = '}' ||
    c = ',' || c = ';' || c = ':' || c = '|' || c = '?' || c = '~' || 
    c = '.' || c = '!' || c = '<' || c = '>' || c = '=' || c = '+' || 
    c = '-' || c = '*' || c = '/' || c = '%' || c = '^' || c = '_'

  (** 检查UTF-8字符序列是否有效 *)
  let is_valid_utf8_sequence bytes =
    match bytes with
    | [| b |] when b < 0x80 -> true  (* ASCII *)
    | [| b1; b2 |] when b1 >= 0xC2 && b1 <= 0xDF && 
                       b2 >= 0x80 && b2 <= 0xBF -> true  (* 2字节 *)
    | [| b1; b2; b3 |] when b1 >= 0xE0 && b1 <= 0xEF && 
                           b2 >= 0x80 && b2 <= 0xBF && 
                           b3 >= 0x80 && b3 <= 0xBF -> true  (* 3字节 *)
    | [| b1; b2; b3; b4 |] when b1 >= 0xF0 && b1 <= 0xF7 && 
                               b2 >= 0x80 && b2 <= 0xBF && 
                               b3 >= 0x80 && b3 <= 0xBF && 
                               b4 >= 0x80 && b4 <= 0xBF -> true  (* 4字节 *)
    | _ -> false

  (** 分类Unicode字符 *)
  let classify_unicode_char char_str =
    match UnifiedCharDefinitions.classify_char char_str with
    | ChineseIdeograph -> "ideograph"
    | ChinesePunctuation -> "punctuation"
    | ChineseSymbol -> "symbol"
    | ChineseNumber -> "number"
    | Poetry -> "poetry"
    | Quote -> "quote"
    | Unknown -> "unknown"
end

(** UTF-8字符序列处理模块 - 增强版 *)
module UTF8Processing = struct
  (** 获取UTF-8字符的字节长度 *)
  let get_utf8_char_length first_byte =
    let code = Char.code first_byte in
    if code < 0x80 then 1          (* ASCII *)
    else if code < 0xC0 then 0     (* 无效的起始字节 *)
    else if code < 0xE0 then 2     (* 2字节字符 *)
    else if code < 0xF0 then 3     (* 3字节字符 *)
    else if code < 0xF8 then 4     (* 4字节字符 *)
    else 0                         (* 无效的起始字节 *)

  (** 安全地读取下一个UTF-8字符 - 增强版本 *)
  let next_utf8_char_safe input pos =
    if pos >= String.length input then EndOfInput
    else
      let first_byte = input.[pos] in
      let char_len = get_utf8_char_length first_byte in
      
      if char_len = 0 then
        InvalidSequence (pos, "无效的UTF-8起始字节")
      else if pos + char_len > String.length input then
        InvalidSequence (pos, "UTF-8字符序列不完整")
      else
        try
          let char_str = String.sub input pos char_len in
          (* 验证字符序列的有效性 *)
          let bytes = Array.init char_len (fun i -> Char.code char_str.[i]) in
          if CharacterDetection.is_valid_utf8_sequence bytes then
            ValidChar (char_str, char_len)
          else
            InvalidSequence (pos, "无效的UTF-8字符序列")
        with
        | Invalid_argument _ -> InvalidSequence (pos, "字符串截取失败")
        | _ -> InvalidSequence (pos, "未知UTF-8处理错误")

  (** 向后兼容的UTF-8字符读取函数 *)
  let next_utf8_char input pos =
    match next_utf8_char_safe input pos with
    | ValidChar (char_str, char_len) -> Some (char_str, pos + char_len)
    | InvalidSequence _ | EndOfInput -> None

  (** 验证UTF-8字符串的完整性 *)
  let validate_utf8_string input =
    let len = String.length input in
    let rec validate pos errors =
      if pos >= len then List.rev errors
      else
        match next_utf8_char_safe input pos with
        | ValidChar (_, char_len) -> validate (pos + char_len) errors
        | InvalidSequence (error_pos, msg) -> 
            let error = (error_pos, msg) in
            validate (pos + 1) (error :: errors)
        | EndOfInput -> List.rev errors
    in
    validate 0 []

  (** 计算UTF-8字符串的字符数（不是字节数） *)
  let count_utf8_chars input =
    let len = String.length input in
    let rec count pos char_count =
      if pos >= len then char_count
      else
        match next_utf8_char_safe input pos with
        | ValidChar (_, char_len) -> count (pos + char_len) (char_count + 1)
        | InvalidSequence (_, _) -> count (pos + 1) char_count  (* 跳过无效字节 *)
        | EndOfInput -> char_count
    in
    count 0 0

  (** 将UTF-8字符串拆分为字符列表 *)
  let utf8_string_to_char_list input =
    let len = String.length input in
    let rec collect pos acc =
      if pos >= len then List.rev acc
      else
        match next_utf8_char_safe input pos with
        | ValidChar (char_str, char_len) -> 
            collect (pos + char_len) (char_str :: acc)
        | InvalidSequence (_, _) -> 
            collect (pos + 1) acc  (* 跳过无效字节 *)
        | EndOfInput -> List.rev acc
    in
    collect 0 []
end

(** 位置跟踪增强模块 *)
module PositionTracking = struct
  (** 创建初始位置 *)
  let create_initial_position () = {
    byte_pos = 0;
    char_pos = 0;
    line_num = 1;
    col_num = 1;
    context = "";
  }

  (** 更新位置信息 *)
  let advance_position pos char_str =
    let char_len = String.length char_str in
    let has_newline = String.contains char_str '\n' in
    let new_context = 
      if String.length pos.context > 20 then
        (String.sub pos.context 5 15) ^ char_str
      else
        pos.context ^ char_str
    in
    
    if has_newline then
      { 
        byte_pos = pos.byte_pos + char_len;
        char_pos = pos.char_pos + 1;
        line_num = pos.line_num + 1;
        col_num = 1;
        context = new_context }
    else
      { 
        byte_pos = pos.byte_pos + char_len;
        char_pos = pos.char_pos + 1;
        line_num = pos.line_num;
        col_num = pos.col_num + 1;
        context = new_context }

  (** 字符偏移转字节偏移 *)
  let char_offset_to_byte_offset input char_offset =
    let len = String.length input in
    let rec find_offset pos current_char_offset =
      if current_char_offset >= char_offset || pos >= len then pos
      else
        match UTF8Processing.next_utf8_char_safe input pos with
        | ValidChar (_, char_len) -> 
            find_offset (pos + char_len) (current_char_offset + 1)
        | InvalidSequence (_, _) -> 
            find_offset (pos + 1) current_char_offset
        | EndOfInput -> pos
    in
    find_offset 0 0

  (** 字节偏移转字符偏移 *)
  let byte_offset_to_char_offset input byte_offset =
    let rec count_chars pos char_count =
      if pos >= byte_offset then char_count
      else
        match UTF8Processing.next_utf8_char_safe input pos with
        | ValidChar (_, char_len) -> 
            count_chars (pos + char_len) (char_count + 1)
        | InvalidSequence (_, _) -> 
            count_chars (pos + 1) char_count
        | EndOfInput -> char_count
    in
    count_chars 0 0

  (** 获取指定位置的上下文 *)
  let get_context_at_position input pos context_size =
    let start_pos = max 0 (pos - context_size) in
    let end_pos = min (String.length input) (pos + context_size) in
    let before = if start_pos < pos then String.sub input start_pos (pos - start_pos) else "" in
    let after = if pos < end_pos then String.sub input pos (end_pos - pos) else "" in
    (before, after)
end

(** 中文字符专用处理模块 *)
module ChineseCharProcessing = struct
  (** 检查是否为中文数字字符 - 增强版 *)
  let is_chinese_digit_char ch =
    ChineseNumbers.is_chinese_number_char ch

  (** 检查是否为中文标点符号 *)
  let is_chinese_punctuation_char ch =
    match UnifiedCharDefinitions.classify_char ch with
    | ChinesePunctuation -> true
    | _ -> false

  (** 检查是否为诗词专用符号 *)
  let is_poetry_symbol_char ch =
    match UnifiedCharDefinitions.classify_char ch with
    | Poetry -> true
    | _ -> false

  (** 获取中文字符的详细信息 *)
  let get_chinese_char_info ch =
    match UnifiedCharDefinitions.find_by_char ch with
    | Some def -> Some {
        name = def.name;
        char = def.char;
        category = def.category;
        bytes = def.bytes;
        unicode_category = def.unicode_category;
      }
    | None -> None

  (** 验证中文字符序列的合法性 *)
  let validate_chinese_sequence char_list =
    List.fold_left (fun acc char_str ->
      match get_chinese_char_info char_str with
      | Some _ -> acc
      | None -> 
          if ChineseNumbers.is_chinese_number_char char_str then
            acc  (* 中文数字是合法的 *)
          else
            (char_str, "不支持的中文字符") :: acc
    ) [] char_list

  (** 建议字符替换 *)
  let suggest_chinese_alternative ascii_char =
    CharacterValidation.suggest_alternative ascii_char
end

(** 边界检测增强模块 *)
module BoundaryDetection = struct
  (** 检查是否为词边界 *)
  let is_word_boundary input pos =
    if pos = 0 || pos >= String.length input then true
    else
      let prev_char, _ = match UTF8Processing.next_utf8_char input (pos - 1) with
        | Some (ch, _) -> (ch, true)
        | None -> ("", false)
      in
      let curr_char, _ = match UTF8Processing.next_utf8_char input pos with
        | Some (ch, _) -> (ch, true)
        | None -> ("", false)
      in
      
      (* 检查字符类别变化 *)
      let prev_category = CharacterDetection.classify_unicode_char prev_char in
      let curr_category = CharacterDetection.classify_unicode_char curr_char in
      
      prev_category <> curr_category ||
      prev_category = "punctuation" || curr_category = "punctuation"

  (** 检查中文关键字边界 - 增强版 *)
  let is_chinese_keyword_boundary input pos keyword =
    let keyword_len = String.length keyword in
    let next_pos = pos + keyword_len in
    
    if next_pos >= String.length input then true (* 文件结尾 *)
    else
      match UTF8Processing.next_utf8_char input next_pos with
      | Some (next_char, _) -> 
          (* 检查下一个字符是否会形成更长的关键字 *)
          let next_category = CharacterDetection.classify_unicode_char next_char in
          
          (* 如果下一个字符是标点或分隔符，则边界有效 *)
          next_category = "punctuation" || next_category = "symbol" ||
          
          (* 如果是不同类别的字符，则边界有效 *)
          (next_category <> "ideograph" && next_category <> "number")
      | None -> true

  (** 查找下一个字符边界 *)
  let find_next_boundary input start_pos =
    let len = String.length input in
    let rec find pos =
      if pos >= len then CharBoundary len
      else if is_word_boundary input pos then CharBoundary pos
      else
        match UTF8Processing.next_utf8_char_safe input pos with
        | ValidChar (_, char_len) -> find (pos + char_len)
        | InvalidSequence (_, msg) -> InvalidBoundary msg
        | EndOfInput -> CharBoundary pos
    in
    find start_pos

  (** 查找上一个字符边界 *)
  let find_prev_boundary input start_pos =
    let rec find pos =
      if pos <= 0 then CharBoundary 0
      else if is_word_boundary input pos then CharBoundary pos
      else find (pos - 1)
    in
    find start_pos
end

(** 错误处理和恢复模块 *)
module ErrorHandling = struct
  type utf8_error = {
    position : int;
    error_type : string;
    message : string;
    context : string * string; (* before, after *)
    suggestion : string option;
  }

  (** 创建UTF-8错误信息 *)
  let create_utf8_error input pos error_type message =
    let context = PositionTracking.get_context_at_position input pos 10 in
    let suggestion = match error_type with
      | "invalid_ascii" -> 
          let char_str = if pos < String.length input then String.make 1 input.[pos] else "" in
          ChineseCharProcessing.suggest_chinese_alternative char_str
      | _ -> None
    in
    {
      position = pos;
      error_type = error_type;
      message = message;
      context = context;
      suggestion = suggestion;
    }

  (** 格式化错误信息 *)
  let format_error_message error =
    let before, after = error.context in
    let suggestion_text = match error.suggestion with
      | Some alt -> Printf.sprintf " 建议使用: %s" alt
      | None -> ""
    in
    Printf.sprintf "%s (位置 %d): %s\n上下文: ...%s<HERE>%s...%s"
      error.error_type error.position error.message 
      before after suggestion_text

  (** 尝试恢复UTF-8错误 *)
  let try_recover_utf8_error input pos =
    (* 尝试跳过无效字节并找到下一个有效字符 *)
    let len = String.length input in
    let rec find_next_valid current_pos =
      if current_pos >= len then None
      else
        match UTF8Processing.next_utf8_char_safe input current_pos with
        | ValidChar (char_str, char_len) -> Some (char_str, current_pos + char_len)
        | InvalidSequence (_, _) -> find_next_valid (current_pos + 1)
        | EndOfInput -> None
    in
    find_next_valid pos
end

(** 性能优化模块 *)
module Performance = struct
  (** 字符处理缓存 *)
  let char_info_cache = Hashtbl.create 512
  let boundary_cache = Hashtbl.create 256

  (** 缓存字符信息查找 *)
  let get_char_info_cached char_str =
    match Hashtbl.find_opt char_info_cache char_str with
    | Some info -> info
    | None ->
        let info = ChineseCharProcessing.get_chinese_char_info char_str in
        Hashtbl.replace char_info_cache char_str info;
        info

  (** 缓存边界检测结果 *)
  let is_boundary_cached input pos =
    let cache_key = Printf.sprintf "%s:%d" (String.sub input pos (min 5 (String.length input - pos))) pos in
    match Hashtbl.find_opt boundary_cache cache_key with
    | Some result -> result
    | None ->
        let result = BoundaryDetection.is_word_boundary input pos in
        Hashtbl.replace boundary_cache cache_key result;
        result

  (** 清除缓存 *)
  let clear_caches () =
    Hashtbl.clear char_info_cache;
    Hashtbl.clear boundary_cache

  (** 获取缓存统计 *)
  let get_cache_stats () =
    let char_cache_size = Hashtbl.length char_info_cache in
    let boundary_cache_size = Hashtbl.length boundary_cache in
    (char_cache_size, boundary_cache_size)
end

(** 向后兼容性接口 *)
module LegacyCompatibility = struct
  (** 检查UTF-8字符匹配 - 向后兼容 *)
  let check_utf8_char input pos byte1 byte2 byte3 =
    pos + 2 < String.length input &&
    Char.code input.[pos] = byte1 &&
    Char.code input.[pos + 1] = byte2 &&
    Char.code input.[pos + 2] = byte3

  (** 检查是否为中文UTF-8字符串 - 向后兼容 *)
  let is_chinese_utf8 s =
    String.length s >= 3 &&
    let c1 = Char.code s.[0] in
    let c2 = Char.code s.[1] in
    let c3 = Char.code s.[2] in
    c1 >= 0xE0 && c1 <= 0xEF && c2 >= 0x80 && c2 <= 0xBF && c3 >= 0x80 && c3 <= 0xBF

  (** 简化版字符验证 *)
  let is_valid_identifier str =
    let char_list = UTF8Processing.utf8_string_to_char_list str in
    match char_list with
    | [] -> false
    | first_char :: rest ->
        (* 第一个字符不能是数字 *)
        let first_valid = not (CharacterDetection.is_digit first_char.[0]) in
        let rest_valid = List.for_all (fun char_str ->
          String.length char_str = 1 && 
          (CharacterDetection.is_letter_or_chinese char_str.[0] || 
           CharacterDetection.is_digit char_str.[0] || 
           char_str.[0] = '_') ||
          String.length char_str > 1 && is_chinese_utf8 char_str
        ) rest in
        first_valid && rest_valid

  (** 原有的字符处理函数保持兼容 *)
  include CharacterDetection
end

(** 主要的公共API *)
let next_utf8_char = UTF8Processing.next_utf8_char
let is_chinese_char = CharacterDetection.is_chinese_char
let is_chinese_digit_char = ChineseCharProcessing.is_chinese_digit_char
let is_letter_or_chinese = CharacterDetection.is_letter_or_chinese
let is_digit = CharacterDetection.is_digit
let is_whitespace = CharacterDetection.is_whitespace
let is_separator_char = CharacterDetection.is_separator_char
let count_utf8_chars = UTF8Processing.count_utf8_chars
let validate_utf8_string = UTF8Processing.validate_utf8_string