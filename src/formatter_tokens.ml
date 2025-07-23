(** 骆言编译器Token和位置格式化模块
    
    本模块专注于Token格式化和位置信息处理，从unified_formatter.ml中拆分出来。
    提供统一的Token格式化接口，消除Printf.sprintf依赖。
    
    重构目的：大型模块细化 - Fix #893
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-22 *)

(* 引入基础格式化器，实现零Printf.sprintf依赖 *)
open Utils.Base_formatter

(** 位置信息格式化 *)
module Position = struct
  let format_position filename line column = file_position_pattern filename line column

  let format_error_with_position position error_type message =
    concat_strings [ error_type; " "; position; ": "; message ]

  let format_optional_position = function
    | Some (filename, line, column) ->
        concat_strings [ " ("; format_position filename line column; ")" ]
    | None -> ""

  (** 扩展位置格式化 *)
  let format_range_position filename start_line start_col end_line end_col =
    if start_line = end_line then
      concat_strings [ filename; ":"; int_to_string start_line; ":"; int_to_string start_col; "-"; int_to_string end_col ]
    else
      concat_strings [ 
        filename; ":"; int_to_string start_line; ":"; int_to_string start_col; 
        "-"; int_to_string end_line; ":"; int_to_string end_col 
      ]

  let format_source_context filename line column context_lines =
    let line_str = int_to_string line in
    let col_str = int_to_string column in
    let position = concat_strings [ filename; ":"; line_str; ":"; col_str ] in
    if List.length context_lines > 0 then
      concat_strings [ position; "\n"; join_with_separator "\n" context_lines ]
    else position

  let format_error_indicator column_pos =
    let spaces = String.make (column_pos - 1) ' ' in
    concat_strings [ spaces; "^" ]
end

(** Token格式化 - 第二阶段扩展 *)
module TokenFormatting = struct
  (** 基础Token类型格式化 *)
  let format_int_token i = concat_strings [ "IntToken("; int_to_string i; ")" ]
  let format_float_token f = concat_strings [ "FloatToken("; float_to_string f; ")" ]
  let format_string_token s = concat_strings [ "StringToken(\""; s; "\")" ]
  let format_identifier_token name = concat_strings [ "IdentifierToken("; name; ")" ]
  let format_quoted_identifier_token name = concat_strings [ "QuotedIdentifierToken(\""; name; "\")" ]

  (** Token错误消息 *)
  let token_expectation expected actual = concat_strings [ "期望token "; expected; "，实际 "; actual ]
  let unexpected_token token = concat_strings [ "意外的token: "; token ]

  (** 复合Token格式化 *)
  let format_keyword_token keyword = token_pattern "KeywordToken" keyword
  let format_operator_token op = token_pattern "OperatorToken" op
  let format_delimiter_token delim = token_pattern "DelimiterToken" delim
  let format_boolean_token b = token_pattern "BooleanToken" (bool_to_string b)

  (** 特殊Token格式化 *)
  let format_eof_token () = "EOFToken"
  let format_newline_token () = "NewlineToken"
  let format_whitespace_token () = "WhitespaceToken"
  let format_comment_token content = token_pattern "CommentToken" content

  (** Token位置信息结合格式化 *)
  let format_token_with_position token line col = 
    token_position_pattern token line col

  (** 中文特定Token格式化 *)
  let format_chinese_number_token num_str = token_pattern "ChineseNumberToken" num_str
  let format_ancient_style_token content = token_pattern "AncientStyleToken" content
  let format_poetry_token verse = token_pattern "PoetryToken" verse

  (** Token序列格式化 *)
  let format_token_sequence tokens =
    let formatted_tokens = List.map (fun token -> concat_strings [ "  "; token ]) tokens in
    concat_strings [ "Token序列:\n"; join_with_separator "\n" formatted_tokens ]

  let format_token_stream tokens_with_positions =
    let formatted = List.map (fun (token, line, col) ->
      concat_strings [ int_to_string line; ":"; int_to_string col; " "; token ]) tokens_with_positions in
    join_with_separator "\n" formatted
end

(** 增强位置格式化 *)
module EnhancedPosition = struct
  (** 基础位置格式化变体 *)
  let simple_line_col line col = 
    concat_strings [ "行:"; int_to_string line; " 列:"; int_to_string col ]
  let parenthesized_line_col line col = 
    concat_strings [ "(行:"; int_to_string line; ", 列:"; int_to_string col; ")" ]
  
  (** 范围位置格式化 *)
  let range_position start_line start_col end_line end_col = 
    concat_strings [ 
      "第"; int_to_string start_line; "行第"; int_to_string start_col; "列 至 ";
      "第"; int_to_string end_line; "行第"; int_to_string end_col; "列"
    ]
  
  (** 错误位置标记 *)
  let error_position_marker line col = 
    concat_strings [ ">>> 错误位置: 行:"; int_to_string line; " 列:"; int_to_string col ]
  
  (** 与现有格式兼容的包装函数 *)
  let format_position_enhanced filename line column = 
    file_position_pattern filename line column
  
  let format_error_with_enhanced_position position error_type message =
    concat_strings [ error_type; " "; position; ": "; message ]

  (** 详细位置信息 *)
  let format_detailed_position filename line column byte_offset =
    concat_strings [ 
      filename; ":"; int_to_string line; ":"; int_to_string column; 
      " (字节偏移: "; int_to_string byte_offset; ")"
    ]

  (** 相对位置格式化 *)
  let format_relative_position base_line base_col target_line target_col =
    let line_diff = target_line - base_line in
    let col_diff = target_col - base_col in
    if line_diff = 0 then
      concat_strings [ "同行偏移 "; int_to_string col_diff; " 列" ]
    else if line_diff > 0 then
      concat_strings [ "向下 "; int_to_string line_diff; " 行，第 "; int_to_string target_col; " 列" ]
    else
      concat_strings [ "向上 "; int_to_string (-line_diff); " 行，第 "; int_to_string target_col; " 列" ]

  (** 位置范围格式化 *)
  let format_span_info start_pos end_pos =
    match (start_pos, end_pos) with
    | ((start_file, start_line, start_col), (end_file, end_line, end_col)) ->
        if start_file = end_file then
          if start_line = end_line then
            concat_strings [ 
              start_file; ":"; int_to_string start_line; ":"; 
              int_to_string start_col; "-"; int_to_string end_col 
            ]
          else
            concat_strings [ 
              start_file; ":"; int_to_string start_line; ":"; int_to_string start_col; 
              " 到 "; int_to_string end_line; ":"; int_to_string end_col 
            ]
        else
          concat_strings [ 
            start_file; ":"; int_to_string start_line; ":"; int_to_string start_col; 
            " 到 "; end_file; ":"; int_to_string end_line; ":"; int_to_string end_col 
          ]

  (** 源码上下文显示 *)
  let format_source_excerpt filename line_num source_line error_col =
    let line_prefix = concat_strings [ int_to_string line_num; " | " ] in
    let pointer_line = String.make (String.length line_prefix + error_col - 1) ' ' ^ "^" in
    concat_strings [ 
      filename; ":"; int_to_string line_num; "\n";
      line_prefix; source_line; "\n";
      pointer_line
    ]

  (** 多行错误显示 *)
  let format_multiline_error filename start_line end_line source_lines error_msg =
    let header = concat_strings [ filename; ":"; int_to_string start_line; "-"; int_to_string end_line ] in
    let numbered_lines = List.mapi (fun i line ->
      let line_num = start_line + i in
      concat_strings [ int_to_string line_num; " | "; line ]) source_lines in
    let footer = concat_strings [ "错误: "; error_msg ] in
    join_with_separator "\n" (header :: numbered_lines @ [footer])
end

(** Token工具模块 *)
module TokenUtilities = struct
  (** Token类型分类 *)
  let is_literal_token token_type =
    List.mem token_type ["IntToken"; "FloatToken"; "StringToken"; "BooleanToken"; "ChineseNumberToken"]

  let is_identifier_token token_type =
    List.mem token_type ["IdentifierToken"; "QuotedIdentifierToken"]

  let is_keyword_token token_type = token_type = "KeywordToken"
  let is_operator_token token_type = token_type = "OperatorToken"
  let is_delimiter_token token_type = token_type = "DelimiterToken"

  (** Token验证消息 *)
  let validate_token_type expected actual =
    if expected = actual then ""
    else concat_strings [ "Token类型不匹配: 期望 "; expected; ", 实际 "; actual ]

  let validate_token_value expected actual =
    if expected = actual then ""
    else concat_strings [ "Token值不匹配: 期望 '"; expected; "', 实际 '"; actual; "'" ]

  (** Token统计信息 *)
  let format_token_statistics total_tokens literal_count identifier_count keyword_count =
    concat_strings [ 
      "Token统计: 总计 "; int_to_string total_tokens; 
      " (字面量: "; int_to_string literal_count;
      ", 标识符: "; int_to_string identifier_count;
      ", 关键字: "; int_to_string keyword_count; ")"
    ]

  (** Token转换助手 *)
  let token_to_string token_type token_value =
    concat_strings [ token_type; "("; token_value; ")" ]

  let token_list_to_string tokens =
    let formatted_tokens = List.map (fun (typ, val_) -> token_to_string typ val_) tokens in
    concat_strings [ "["; join_with_separator "; " formatted_tokens; "]" ]

  (** 词法分析辅助 *)
  let format_lexer_state current_pos current_char buffer_content =
    concat_strings [ 
      "词法分析器状态 - 位置: "; int_to_string current_pos; 
      ", 当前字符: '"; current_char; 
      "', 缓冲区: '"; buffer_content; "'"
    ]

  let format_tokenization_progress processed_chars total_chars current_token =
    concat_strings [ 
      "词法分析进度: "; int_to_string processed_chars; "/"; int_to_string total_chars; 
      " ("; int_to_string (processed_chars * 100 / max total_chars 1); "%), 当前Token: "; current_token
    ]
end