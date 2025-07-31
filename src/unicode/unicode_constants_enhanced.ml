(** 骆言编译器Unicode字符处理常量模块 - 增强统一版本
    
    本模块合并了原有的优化版本和统一版本，提供完整的中文编程Unicode支持：
    - 统一的字符定义和类型系统
    - 高性能的哈希表查找优化
    - 完善的中文字符分类功能
    - 准确的位置跟踪和边界检测
    - 向后兼容的Legacy API
    
    Author: Whisky, PR Worker
    Issue: #1847 - Unicode字符处理优化
    
    @version 2.0 - 增强统一版本
    @since 2025-07-31 *)

open Unicode_types
open Unicode_mapping

(** 核心类型定义 *)
type byte_triple = int * int * int
(** 字节三元组类型 - 向后兼容 *)

type char_definition = { 
  name : string; 
  char : string; 
  bytes : byte_triple; 
  category : string;
  unicode_category : string option; (** 扩展Unicode分类信息 *)
}
(** 增强的字符定义记录类型 *)

(** 中文字符类别枚举 *)
type chinese_char_category = 
  | ChineseIdeograph (** 汉字 *)
  | ChinesePunctuation (** 中文标点 *)
  | ChineseSymbol (** 中文符号 *)
  | ChineseNumber (** 中文数字 *)
  | Poetry (** 诗词专用符号 *)
  | Quote (** 引号类 *)
  | Unknown (** 未知类别 *)

(** 字符处理结果类型 *)
type char_processing_result = 
  | ValidChar of char_definition
  | InvalidChar of string * string (** 字符, 错误信息 *)
  | UnsupportedChar of string (** 不支持的字符 *)

(** 位置信息增强 *)
type utf8_position = {
  byte_offset : int; (** 字节偏移 *)
  char_offset : int; (** 字符偏移 *)
  line : int; (** 行号 *)
  column : int; (** 列号 *)
}

(** 助手函数：从字符名称获取字节组合 - 增强版 *)
let get_char_bytes_by_name_enhanced char_name =
  match Legacy.find_char_by_name char_name with
  | Some char_str -> (
      match Legacy.find_triple_by_char char_str with
      | Some triple -> Some (triple.byte1, triple.byte2, triple.byte3)
      | None -> None)
  | None -> None

(** 助手函数：从字符获取字节组合 - 增强版 *)
let get_char_bytes_by_char_enhanced char_str =
  match Legacy.find_triple_by_char char_str with
  | Some triple -> Some (triple.byte1, triple.byte2, triple.byte3)
  | None -> None

(** 向后兼容函数 *)
let get_char_bytes_by_name char_name =
  match get_char_bytes_by_name_enhanced char_name with
  | Some bytes -> bytes
  | None -> (0, 0, 0)

let get_char_bytes_by_char char_str =
  match get_char_bytes_by_char_enhanced char_str with
  | Some bytes -> bytes
  | None -> (0, 0, 0)

(** 中文引号字符常量定义 - 增强版 *)
module ChineseQuotes = struct
  (** 左引号『定义 *)
  let left_quote_def = {
    name = "left_quote";
    char = "『";
    bytes = get_char_bytes_by_name "left_quote";
    category = "quote";
    unicode_category = Some "Ps"; (* Punctuation, Open *)
  }
  
  (** 右引号』定义 *)
  let right_quote_def = {
    name = "right_quote";
    char = "』";
    bytes = get_char_bytes_by_name "right_quote";
    category = "quote";
    unicode_category = Some "Pe"; (* Punctuation, Close *)
  }
  
  (** 字符串开始标记『 *)
  let string_start_def = {
    name = "string_start";
    char = "『";
    bytes = get_char_bytes_by_name "string_start";
    category = "quote";
    unicode_category = Some "Ps";
  }

  (** 字符串结束标记』 *)
  let string_end_def = {
    name = "string_end";
    char = "』";
    bytes = get_char_bytes_by_name "string_end";
    category = "quote";
    unicode_category = Some "Pe";
  }

  (** 向后兼容的字节访问 *)
  let left_quote_bytes = left_quote_def.bytes
  let right_quote_bytes = right_quote_def.bytes
  let string_start_bytes = string_start_def.bytes
  let string_end_bytes = string_end_def.bytes
  
  (** 所有引号字符定义列表 *)
  let all_quote_chars = [left_quote_def; right_quote_def]
  
  (** 引号字符检测函数 *)
  let is_quote_char char_str =
    char_str = "『" || char_str = "』"
    
  (** 获取引号配对 *)
  let get_quote_pair = function
    | "『" -> Some "』"
    | "』" -> Some "『"
    | _ -> None
end

(** 中文标点符号常量定义 - 增强版 *)
module ChinesePunctuation = struct
  (** 创建标点符号定义 *)
  let create_punctuation_def name char category =
    {
      name = name;
      char = char;
      bytes = get_char_bytes_by_name name;
      category = category;
      unicode_category = Some "Po"; (* Punctuation, Other *)
    }

  (** 标点符号定义 *)
  let left_parentheses_def = create_punctuation_def "chinese_left_paren" "（" "punctuation"
  let right_parentheses_def = create_punctuation_def "chinese_right_paren" "）" "punctuation"
  let comma_def = create_punctuation_def "chinese_comma" "，" "punctuation"
  let colon_def = create_punctuation_def "chinese_colon" "：" "punctuation"
  let period_def = create_punctuation_def "chinese_period" "。" "punctuation"
  let semicolon_def = { name = "semicolon"; char = "；"; bytes = (0xEF, 0xBC, 0x9B); category = "punctuation"; unicode_category = Some "Po" }
  let pause_mark_def = { name = "pause_mark"; char = "、"; bytes = (0xE3, 0x80, 0x81); category = "punctuation"; unicode_category = Some "Po" }

  (** 向后兼容的字节访问 *)
  let left_parentheses_bytes = left_parentheses_def.bytes
  let right_parentheses_bytes = right_parentheses_def.bytes
  let comma_bytes = comma_def.bytes
  let colon_bytes = colon_def.bytes
  let period_bytes = period_def.bytes
  let semicolon_bytes = semicolon_def.bytes
  let pause_mark_bytes = pause_mark_def.bytes

  (** 所有中文标点符号列表 *)
  let all_punctuation_chars = [
    left_parentheses_def; right_parentheses_def; comma_def; colon_def;
    period_def; semicolon_def; pause_mark_def
  ]
  
  (** 标点符号分类检测 *)
  let classify_punctuation char_str =
    match char_str with
    | "（" | "）" -> Some "parentheses"
    | "，" | "；" | "、" -> Some "separator"
    | "：" -> Some "colon"
    | "。" -> Some "period"
    | _ -> None
    
  (** 检查是否为配对标点 *)
  let get_punctuation_pair = function
    | "（" -> Some "）"
    | "）" -> Some "（"
    | _ -> None
end

(** 中文符号和箭头常量定义 - 增强版 *)
module ChineseSymbols = struct
  (** 创建符号定义 *)
  let create_symbol_def name char bytes category =
    {
      name = name;
      char = char;
      bytes = bytes;
      category = category;
      unicode_category = Some "Sm"; (* Symbol, Math *)
    }

  (** 符号定义 *)
  let left_square_bracket_def = create_symbol_def "left_square_bracket" "【" (0xE3, 0x80, 0x90) "symbol"
  let right_square_bracket_def = create_symbol_def "right_square_bracket" "】" (0xE3, 0x80, 0x91) "symbol"
  let pipe_def = create_symbol_def "pipe" "｜" (0xEF, 0xBD, 0x9C) "symbol"
  let arrow_def = create_symbol_def "arrow" "→" (0xE2, 0x86, 0x92) "symbol"
  let double_arrow_def = create_symbol_def "double_arrow" "⇒" (0xE2, 0x87, 0x92) "symbol"
  let assign_arrow_def = create_symbol_def "assign_arrow" "←" (0xE2, 0x86, 0x90) "symbol"

  (** 向后兼容的字节访问 *)
  let left_square_bracket_bytes = left_square_bracket_def.bytes
  let right_square_bracket_bytes = right_square_bracket_def.bytes
  let pipe_bytes = pipe_def.bytes
  let arrow_bytes = arrow_def.bytes
  let double_arrow_bytes = double_arrow_def.bytes
  let assign_arrow_bytes = assign_arrow_def.bytes

  (** 所有符号字符列表 *)
  let all_symbol_chars = [
    left_square_bracket_def; right_square_bracket_def; pipe_def;
    arrow_def; double_arrow_def; assign_arrow_def
  ]
  
  (** 符号分类检测 *)
  let classify_symbol char_str =
    match char_str with
    | "【" | "】" -> Some "bracket"
    | "｜" -> Some "pipe"
    | "→" | "⇒" | "←" -> Some "arrow"
    | _ -> None
    
  (** 检查是否为方向符号 *)
  let is_directional_symbol char_str =
    match char_str with
    | "→" | "⇒" | "←" -> true
    | _ -> false
end

(** 诗词特有的Unicode字符定义 - 增强版 *)
module PoetrySymbols = struct
  (** 创建诗词符号定义 *)
  let create_poetry_def name char bytes =
    {
      name = name;
      char = char;
      bytes = bytes;
      category = "poetry";
      unicode_category = Some "So"; (* Symbol, Other *)
    }

  (** 诗词符号定义 *)
  let title_left_def = create_poetry_def "title_left" "《" (0xE3, 0x80, 0x8A)
  let title_right_def = create_poetry_def "title_right" "》" (0xE3, 0x80, 0x8B)
  let exclamation_def = create_poetry_def "exclamation" "！" (0xEF, 0xBC, 0x81)
  let question_def = create_poetry_def "question" "？" (0xEF, 0xBC, 0x9F)
  let rhyme_marker_def = create_poetry_def "rhyme_marker" "◎" (0xE2, 0x97, 0x8E)
  let non_rhyme_marker_def = create_poetry_def "non_rhyme_marker" "○" (0xE2, 0x97, 0x8B)
  let optional_rhyme_def = create_poetry_def "optional_rhyme" "△" (0xE2, 0x96, 0xB3)

  (** 向后兼容的字节访问 *)
  let title_left_bytes = title_left_def.bytes
  let title_right_bytes = title_right_def.bytes
  let exclamation_bytes = exclamation_def.bytes
  let question_bytes = question_def.bytes
  let rhyme_marker_bytes = rhyme_marker_def.bytes
  let non_rhyme_marker_bytes = non_rhyme_marker_def.bytes
  let optional_rhyme_bytes = optional_rhyme_def.bytes

  (** 诗词专用符号列表 *)
  let all_poetry_chars = [
    title_left_def; title_right_def; exclamation_def; question_def;
    rhyme_marker_def; non_rhyme_marker_def; optional_rhyme_def
  ]
  
  (** 诗词符号分类 *)
  let classify_poetry_symbol char_str =
    match char_str with
    | "《" | "》" -> Some "title_mark"
    | "！" | "？" -> Some "emotion_mark"
    | "◎" | "○" | "△" -> Some "rhyme_mark"
    | _ -> None
end

(** 中文数字字符定义 - 新增 *)
module ChineseNumbers = struct
  (** 中文数字定义 *)
  let chinese_digit_chars = [
    ("零", "0"); ("一", "1"); ("二", "2"); ("三", "3"); ("四", "4");
    ("五", "5"); ("六", "6"); ("七", "7"); ("八", "8"); ("九", "9");
    ("十", "10"); ("百", "100"); ("千", "1000"); ("万", "10000");
    ("亿", "100000000"); ("兆", "1000000000000")
  ]
  
  (** 检查是否为中文数字字符 *)
  let is_chinese_number_char char_str =
    List.exists (fun (ch, _) -> ch = char_str) chinese_digit_chars
    
  (** 获取中文数字对应的阿拉伯数字 *)
  let get_arabic_value char_str =
    try Some (List.assoc char_str chinese_digit_chars)
    with Not_found -> None
    
  (** 中文数字单位检测 *)
  let is_unit_char char_str =
    match char_str with
    | "十" | "百" | "千" | "万" | "亿" | "兆" -> true
    | _ -> false
    
  (** 基础数字字符检测 *)
  let is_basic_digit char_str =
    match char_str with
    | "零" | "一" | "二" | "三" | "四" | "五" | "六" | "七" | "八" | "九" -> true
    | _ -> false
end

(** 统一的字符定义集合 - 增强版 *)
module UnifiedCharDefinitions = struct
  (** 所有字符定义的完整列表 *)
  let all_char_definitions =
    ChineseQuotes.all_quote_chars @ 
    ChinesePunctuation.all_punctuation_chars @
    ChineseSymbols.all_symbol_chars @ 
    PoetrySymbols.all_poetry_chars

  (** 按类别分组查找 - 缓存优化 *)
  let category_cache = Hashtbl.create 16
  
  let find_by_category category =
    match Hashtbl.find_opt category_cache category with
    | Some cached -> cached
    | None ->
        let result = List.filter (fun def -> def.category = category) all_char_definitions in
        Hashtbl.replace category_cache category result;
        result

  (** 按字符查找定义 - 哈希表优化 *)
  let char_lookup_table = lazy (
    let tbl = Hashtbl.create 128 in
    List.iter (fun def -> Hashtbl.replace tbl def.char def) all_char_definitions;
    tbl
  )
  
  let find_by_char char_str = 
    Hashtbl.find_opt (Lazy.force char_lookup_table) char_str

  (** 按名称查找定义 - 哈希表优化 *)
  let name_lookup_table = lazy (
    let tbl = Hashtbl.create 128 in
    List.iter (fun def -> Hashtbl.replace tbl def.name def) all_char_definitions;
    tbl
  )
  
  let find_by_name name = 
    Hashtbl.find_opt (Lazy.force name_lookup_table) name
    
  (** 字符分类功能 *)
  let classify_char char_str =
    match find_by_char char_str with
    | Some def -> (
        match def.category with
        | "quote" -> Quote
        | "punctuation" -> ChinesePunctuation
        | "symbol" -> ChineseSymbol
        | "poetry" -> Poetry
        | _ -> Unknown
      )
    | None -> 
        if ChineseNumbers.is_chinese_number_char char_str then ChineseNumber
        else Unknown
        
  (** 批量字符处理 *)
  let process_char_sequence char_list =
    List.map (fun char_str ->
      match find_by_char char_str with
      | Some def -> ValidChar def
      | None -> 
          if ChineseNumbers.is_chinese_number_char char_str then
            ValidChar {
              name = "chinese_number";
              char = char_str;
              bytes = (0, 0, 0); (* 中文数字暂时不提供字节信息 *)
              category = "number";
              unicode_category = Some "Nd";
            }
          else UnsupportedChar char_str
    ) char_list
end

(** 高性能优化查找模块 - 合并原optimized版本功能 *)
module OptimizedLookup = struct
  (** 字符名称到字符的哈希表 *)
  let name_to_char_table = lazy (
    let tbl = Hashtbl.create 128 in
    List.iter (fun def -> Hashtbl.add tbl def.name def.char) UnifiedCharDefinitions.all_char_definitions;
    tbl
  )

  (** 字符到字节三元组的哈希表 *)
  let char_to_bytes_table = lazy (
    let tbl = Hashtbl.create 128 in
    List.iter (fun def -> Hashtbl.add tbl def.char def.bytes) UnifiedCharDefinitions.all_char_definitions;
    tbl
  )

  (** 字符名称到字节三元组的哈希表 *)
  let name_to_bytes_table = lazy (
    let tbl = Hashtbl.create 128 in
    List.iter (fun def -> Hashtbl.add tbl def.name def.bytes) UnifiedCharDefinitions.all_char_definitions;
    tbl
  )

  (** 类别到字符定义列表的哈希表 *)
  let category_to_definitions_table = lazy (
    let tbl = Hashtbl.create 16 in
    let categories = ["punctuation"; "symbol"; "poetry"; "quote"; "number"] in
    List.iter (fun category ->
      let defs = List.filter (fun def -> def.category = category) UnifiedCharDefinitions.all_char_definitions in
      Hashtbl.add tbl category defs
    ) categories;
    tbl
  )

  (** O(1)查找：根据字符名称查找字符 *)
  let find_char_by_name_fast name =
    try Some (Hashtbl.find (Lazy.force name_to_char_table) name) 
    with Not_found -> None

  (** O(1)查找：根据字符查找字节三元组 *)
  let find_bytes_by_char_fast char_str =
    try Some (Hashtbl.find (Lazy.force char_to_bytes_table) char_str) 
    with Not_found -> None

  (** O(1)查找：根据字符名称查找字节三元组 *)
  let find_bytes_by_name_fast name =
    try Some (Hashtbl.find (Lazy.force name_to_bytes_table) name) 
    with Not_found -> None

  (** O(1)查找：根据类别查找字符定义列表 *)
  let find_definitions_by_category_fast category =
    try Some (Hashtbl.find (Lazy.force category_to_definitions_table) category) 
    with Not_found -> None

  (** 获取所有已知字符名称 *)
  let get_all_char_names () = 
    Hashtbl.fold (fun name _ acc -> name :: acc) (Lazy.force name_to_char_table) []

  (** 获取所有已知字符 *)
  let get_all_chars () = 
    Hashtbl.fold (fun _ char acc -> char :: acc) (Lazy.force name_to_char_table) []

  (** 获取所有类别 *)
  let get_all_categories () =
    Hashtbl.fold (fun category _ acc -> category :: acc) (Lazy.force category_to_definitions_table) []
end

(** UTF-8位置跟踪增强模块 *)
module PositionTracking = struct
  (** 计算UTF-8字符串的字符数 *)
  let count_utf8_chars str =
    let len = String.length str in
    let rec count pos char_count =
      if pos >= len then char_count
      else
        let c = Char.code str.[pos] in
        let char_len = 
          if c < 0x80 then 1          (* ASCII *)
          else if c < 0xC0 then 1     (* 继续字节，跳过 *)
          else if c < 0xE0 then 2     (* 2字节字符 *)
          else if c < 0xF0 then 3     (* 3字节字符 *)
          else 4                      (* 4字节字符 *)
        in
        count (pos + char_len) (char_count + 1)
    in
    count 0 0
    
  (** 计算字符在UTF-8字符串中的字节偏移 *)
  let char_offset_to_byte_offset str char_offset =
    let len = String.length str in
    let rec find_offset pos current_char_offset =
      if current_char_offset >= char_offset || pos >= len then pos
      else
        let c = Char.code str.[pos] in
        let char_len = 
          if c < 0x80 then 1
          else if c < 0xC0 then 1
          else if c < 0xE0 then 2
          else if c < 0xF0 then 3
          else 4
        in
        find_offset (pos + char_len) (current_char_offset + 1)
    in
    find_offset 0 0
    
  (** 创建增强的位置信息 *)
  let create_position ~byte_offset ~char_offset ~line ~column = {
    byte_offset; char_offset; line; column
  }
  
  (** 更新位置信息 *)
  let advance_position pos char_str =
    let char_len = String.length char_str in
    let has_newline = String.contains char_str '\n' in
    if has_newline then
      { 
        byte_offset = pos.byte_offset + char_len;
        char_offset = pos.char_offset + 1;
        line = pos.line + 1;
        column = 1 }
    else
      { 
        byte_offset = pos.byte_offset + char_len;
        char_offset = pos.char_offset + 1;
        line = pos.line;
        column = pos.column + 1 }
end

(** 字符验证和错误处理增强 *)
module CharacterValidation = struct
  (** 验证UTF-8字符序列 *)
  let validate_utf8_sequence bytes =
    match bytes with
    | (b1, b2, b3) when b1 >= 0xE0 && b1 <= 0xEF && 
                       b2 >= 0x80 && b2 <= 0xBF && 
                       b3 >= 0x80 && b3 <= 0xBF -> true
    | _ -> false
    
  (** 检查字符是否适合中文编程 *)
  let is_suitable_for_chinese_programming char_str =
    match UnifiedCharDefinitions.classify_char char_str with
    | ChineseIdeograph | ChinesePunctuation | ChineseSymbol | 
      ChineseNumber | Poetry | Quote -> true
    | Unknown -> false
    
  (** 提供字符使用建议 *)
  let suggest_alternative char_str =
    (* 为常见的ASCII字符提供中文替代建议 *)
    match char_str with
    | "(" -> Some "（"
    | ")" -> Some "）"
    | "," -> Some "，"
    | ":" -> Some "："
    | ";" -> Some "；"
    | "." -> Some "。"
    | "!" -> Some "！"
    | "?" -> Some "？"
    | "[" -> Some "【"
    | "]" -> Some "】"
    | "|" -> Some "｜"
    | _ -> None
end

(** 向后兼容性接口 - 保持现有代码正常工作 *)
module LegacyCompatibility = struct
  (** 保持旧模块结构的兼容性导出 *)
  module Quote = struct
    let left_quote_bytes = ChineseQuotes.left_quote_bytes
    let right_quote_bytes = ChineseQuotes.right_quote_bytes
    let string_start_bytes = ChineseQuotes.string_start_bytes
    let string_end_bytes = ChineseQuotes.string_end_bytes
  end

  module ChinesePunctuation = struct
    let chinese_left_paren_bytes = ChinesePunctuation.left_parentheses_bytes
    let chinese_right_paren_bytes = ChinesePunctuation.right_parentheses_bytes
    let chinese_comma_bytes = ChinesePunctuation.comma_bytes
    let chinese_colon_bytes = ChinesePunctuation.colon_bytes
    let chinese_period_bytes = ChinesePunctuation.period_bytes
  end

  module Fullwidth = struct
    let fullwidth_left_paren_bytes = get_char_bytes_by_name "chinese_left_paren"
    let fullwidth_right_paren_bytes = get_char_bytes_by_name "chinese_right_paren"
    let fullwidth_comma_bytes = get_char_bytes_by_name "chinese_comma"
    let fullwidth_colon_bytes = get_char_bytes_by_name "chinese_colon"
    let fullwidth_period_bytes = get_char_bytes_by_name "chinese_period"
    let fullwidth_semicolon_bytes = (0xEF, 0xBC, 0x9B)
    let fullwidth_pipe_bytes = (0xEF, 0xBD, 0x9C)
  end

  module OtherSymbols = struct
    let chinese_minus_bytes = (0, 0, 0)
    let chinese_square_left_bracket_bytes = (0xE3, 0x80, 0x90)
    let chinese_square_right_bracket_bytes = (0xE3, 0x80, 0x91)
    let chinese_arrow_bytes = (0xE2, 0x86, 0x92)
    let chinese_double_arrow_bytes = (0xE2, 0x87, 0x92)
    let chinese_assign_arrow_bytes = (0xE2, 0x86, 0x90)
    let chinese_pipe_bytes = (0xEF, 0xBD, 0x9C)
  end

  (** 原优化模块的向后兼容API *)
  module OptimizedLegacyAPI = struct
    let get_char_bytes_by_name name =
      match OptimizedLookup.find_bytes_by_name_fast name with 
      | Some bytes -> bytes 
      | None -> (0, 0, 0)

    let get_char_bytes_by_char char_str =
      match OptimizedLookup.find_bytes_by_char_fast char_str with
      | Some bytes -> bytes
      | None -> (0, 0, 0)

    let find_definition_by_char char_str = UnifiedCharDefinitions.find_by_char char_str
    let find_definition_by_name name = UnifiedCharDefinitions.find_by_name name
  end
end

(** 字节访问器模块 - 提供统一的字节位访问接口 *)
module ByteAccessors = struct
  (** 获取第一个字节 *)
  let get_byte1 (b1, _, _) = b1

  (** 获取第二个字节 *)
  let get_byte2 (_, b2, _) = b2

  (** 获取第三个字节 *)
  let get_byte3 (_, _, b3) = b3

  (** 获取字节三元组 *)
  let get_bytes_tuple bytes = bytes

  (** 检查字节三元组是否有效（非零） *)
  let is_valid_bytes (b1, b2, b3) = not (b1 = 0 && b2 = 0 && b3 = 0)
  
  (** 将字节三元组转换为十六进制字符串 *)
  let bytes_to_hex_string (b1, b2, b3) =
    Printf.sprintf "0x%02X 0x%02X 0x%02X" b1 b2 b3
    
  (** 从十六进制字符串解析字节三元组 *)
  let hex_string_to_bytes hex_str =
    try
      let parts = String.split_on_char ' ' hex_str in
      match parts with
      | [b1_str; b2_str; b3_str] ->
          let b1 = int_of_string b1_str in
          let b2 = int_of_string b2_str in
          let b3 = int_of_string b3_str in
          Some (b1, b2, b3)
      | _ -> None
    with _ -> None
end

(** 统计和分析模块 - 增强版 *)
module Statistics = struct
  (** 获取字符定义统计信息 *)
  let get_char_statistics () =
    let total = List.length UnifiedCharDefinitions.all_char_definitions in
    let by_category = Hashtbl.create 8 in
    List.iter (fun def ->
      let count = try Hashtbl.find by_category def.category with Not_found -> 0 in
      Hashtbl.replace by_category def.category (count + 1)
    ) UnifiedCharDefinitions.all_char_definitions;
    (total, by_category)

  (** 打印统计信息 *)
  let print_statistics () =
    let total, by_category = get_char_statistics () in
    Printf.printf "=== Unicode字符定义统计 ===\n";
    Printf.printf "总字符数: %d\n" total;
    Printf.printf "按类别分布:\n";
    Hashtbl.iter (fun category count -> 
      Printf.printf "  %s: %d个字符\n" category count
    ) by_category;
    Printf.printf "========================\n"

  (** 获取查找表性能信息 *)
  let get_lookup_performance_info () =
    let name_to_char_size = Hashtbl.length (Lazy.force OptimizedLookup.name_to_char_table) in
    let char_to_bytes_size = Hashtbl.length (Lazy.force OptimizedLookup.char_to_bytes_table) in
    let name_to_bytes_size = Hashtbl.length (Lazy.force OptimizedLookup.name_to_bytes_table) in
    let category_to_defs_size = Hashtbl.length (Lazy.force OptimizedLookup.category_to_definitions_table) in
    (name_to_char_size, char_to_bytes_size, name_to_bytes_size, category_to_defs_size)
    
  (** 分析Unicode使用模式 *)
  let analyze_usage_patterns char_list =
    let category_usage = Hashtbl.create 8 in
    List.iter (fun char_str ->
      let category = match UnifiedCharDefinitions.classify_char char_str with
        | ChineseIdeograph -> "ideograph"
        | ChinesePunctuation -> "punctuation"
        | ChineseSymbol -> "symbol"
        | ChineseNumber -> "number"
        | Poetry -> "poetry"
        | Quote -> "quote"
        | Unknown -> "unknown"
      in
      let count = try Hashtbl.find category_usage category with Not_found -> 0 in
      Hashtbl.replace category_usage category (count + 1)
    ) char_list;
    category_usage
end

(** 模块初始化 - 预热缓存以提升性能 *)
let () =
  (* 强制初始化懒惰值以提升首次访问性能 *)
  ignore (Lazy.force OptimizedLookup.name_to_char_table);
  ignore (Lazy.force OptimizedLookup.char_to_bytes_table);
  ignore (Lazy.force OptimizedLookup.name_to_bytes_table);
  ignore (Lazy.force OptimizedLookup.category_to_definitions_table);
  ignore (Lazy.force UnifiedCharDefinitions.char_lookup_table);
  ignore (Lazy.force UnifiedCharDefinitions.name_lookup_table);
  ()