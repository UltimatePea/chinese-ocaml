(** Unicode字符处理增强功能测试套件
    
    验证Unicode字符处理优化的各项功能：
    - 中文字符分类和识别
    - UTF-8位置跟踪准确性
    - 边界检测功能
    - 性能优化效果
    - 错误处理和恢复
    
    Author: Whisky, PR Worker
    Issue: #1847 - Unicode字符处理优化
    
    @since 2025-07-31 *)

open Unicode.Unicode_constants_enhanced
open Unicode.Utf8_utils_enhanced

(** 测试数据集 *)
module TestData = struct
  (** 中文标点符号测试用例 *)
  let chinese_punctuation_cases = [
    ("，", "comma", "punctuation");
    ("。", "period", "punctuation");
    ("：", "colon", "punctuation");
    ("；", "semicolon", "punctuation");
    ("（", "left_paren", "punctuation");
    ("）", "right_paren", "punctuation");
    ("、", "pause_mark", "punctuation");
  ]

  (** 中文符号测试用例 *)
  let chinese_symbol_cases = [
    ("【", "left_square_bracket", "symbol");
    ("】", "right_square_bracket", "symbol");
    ("｜", "pipe", "symbol");
    ("→", "arrow", "symbol");
    ("⇒", "double_arrow", "symbol");
    ("←", "assign_arrow", "symbol");
  ]

  (** 诗词符号测试用例 *)
  let poetry_symbol_cases = [
    ("《", "title_left", "poetry");
    ("》", "title_right", "poetry");
    ("！", "exclamation", "poetry");
    ("？", "question", "poetry");
    ("◎", "rhyme_marker", "poetry");
    ("○", "non_rhyme_marker", "poetry");
    ("△", "optional_rhyme", "poetry");
  ]

  (** 中文数字测试用例 *)
  let chinese_number_cases = [
    ("零", "0"); ("一", "1"); ("二", "2"); ("三", "3"); ("四", "4");
    ("五", "5"); ("六", "6"); ("七", "7"); ("八", "8"); ("九", "9");
    ("十", "10"); ("百", "100"); ("千", "1000"); ("万", "10000");
  ]

  (** 引号测试用例 *)
  let quote_cases = [
    ("『", "left_quote", "quote");
    ("』", "right_quote", "quote");
  ]

  (** 混合中文编程示例 *)
  let chinese_programming_examples = [
    "让「变量」= 123";
    "假如「条件」那么「执行」";
    "夫「函数」者，算法也。";
    "设「数组」为【一，二，三】";
    "输出『你好，世界！』";
  ]

  (** UTF-8边界测试用例 *)
  let utf8_boundary_cases = [
    ("hello世界", [(0, 5); (5, 8); (8, 11)]);  (* ASCII + 中文 *)
    ("你好world", [(0, 3); (3, 6); (6, 11)]);  (* 中文 + ASCII *)
    ("中文，标点。", [(0, 3); (3, 6); (6, 9); (9, 12); (12, 15)]);
  ]
end

(** 字符分类测试模块 *)
module CharacterClassificationTests = struct
  let test_chinese_punctuation () =
    Printf.printf "=== 测试中文标点符号分类 ===\n";
    List.iter (fun (char, expected_name, expected_category) ->
      match UnifiedCharDefinitions.find_by_char char with
      | Some def ->
          let category_match = def.category = expected_category in
          let name_contains = String.length def.name > 0 in
          Printf.printf "字符 '%s': 类别匹配=%b, 有名称=%b\n" 
            char category_match name_contains
      | None ->
          Printf.printf "字符 '%s': 未找到定义 ❌\n" char
    ) TestData.chinese_punctuation_cases

  let test_chinese_symbols () =
    Printf.printf "\n=== 测试中文符号分类 ===\n";
    List.iter (fun (char, expected_name, expected_category) ->
      match UnifiedCharDefinitions.find_by_char char with
      | Some def ->
          let category_match = def.category = expected_category in
          let symbol_class = ChineseSymbols.classify_symbol char in
          Printf.printf "字符 '%s': 类别匹配=%b, 符号分类=%s\n" 
            char category_match (match symbol_class with Some c -> c | None -> "无")
      | None ->
          Printf.printf "字符 '%s': 未找到定义 ❌\n" char
    ) TestData.chinese_symbol_cases

  let test_poetry_symbols () =
    Printf.printf "\n=== 测试诗词符号分类 ===\n";
    List.iter (fun (char, expected_name, expected_category) ->
      match UnifiedCharDefinitions.find_by_char char with
      | Some def ->
          let category_match = def.category = expected_category in
          let poetry_class = PoetrySymbols.classify_poetry_symbol char in
          Printf.printf "字符 '%s': 类别匹配=%b, 诗词分类=%s\n" 
            char category_match (match poetry_class with Some c -> c | None -> "无")
      | None ->
          Printf.printf "字符 '%s': 未找到定义 ❌\n" char
    ) TestData.poetry_symbol_cases

  let test_chinese_numbers () =
    Printf.printf "\n=== 测试中文数字识别 ===\n";
    List.iter (fun (char, expected_value) ->
      let is_recognized = ChineseNumbers.is_chinese_number_char char in
      let arabic_value = ChineseNumbers.get_arabic_value char in
      let value_match = match arabic_value with 
        | Some v -> v = expected_value 
        | None -> false 
      in
      Printf.printf "字符 '%s': 识别=%b, 值匹配=%b (期望=%s, 实际=%s)\n" 
        char is_recognized value_match expected_value 
        (match arabic_value with Some v -> v | None -> "无")
    ) TestData.chinese_number_cases

  let test_quote_handling () =
    Printf.printf "\n=== 测试引号处理 ===\n";
    List.iter (fun (char, expected_name, expected_category) ->
      let is_quote = ChineseQuotes.is_quote_char char in
      let pair = ChineseQuotes.get_quote_pair char in
      Printf.printf "字符 '%s': 引号识别=%b, 配对=%s\n" 
        char is_quote (match pair with Some p -> p | None -> "无")
    ) TestData.quote_cases
end

(** UTF-8处理测试模块 *)
module UTF8ProcessingTests = struct
  let test_utf8_char_counting () =
    Printf.printf "\n=== 测试UTF-8字符计数 ===\n";
    let test_strings = [
      ("hello", 5);
      ("你好", 2);
      ("hello世界", 7);
      ("中文，标点。", 5);
      ("", 0);
    ] in
    List.iter (fun (input, expected) ->
      let actual = UTF8Processing.count_utf8_chars input in
      let match_result = actual = expected in
      Printf.printf "字符串 '%s': 期望=%d, 实际=%d, 匹配=%b\n"
        input expected actual match_result
    ) test_strings

  let test_utf8_string_validation () =
    Printf.printf "\n=== 测试UTF-8字符串验证 ===\n";
    let test_strings = [
      ("正常中文", true);
      ("Mixed中英文", true);
      ("数字123", true);
      ("\xff\xfe\xfd", false);  (* 无效UTF-8 *)
    ] in
    List.iter (fun (input, should_be_valid) ->
      let errors = UTF8Processing.validate_utf8_string input in
      let is_valid = errors = [] in
      let match_result = is_valid = should_be_valid in
      Printf.printf "字符串 '%s': 期望有效=%b, 实际有效=%b, 匹配=%b\n"
        input should_be_valid is_valid match_result;
      if not is_valid then
        List.iter (fun (pos, msg) ->
          Printf.printf "  错误位置 %d: %s\n" pos msg
        ) errors
    ) test_strings

  let test_char_list_conversion () =
    Printf.printf "\n=== 测试字符列表转换 ===\n";
    let test_strings = ["hello"; "你好"; "中英Mixed"] in
    List.iter (fun input ->
      let char_list = UTF8Processing.utf8_string_to_char_list input in
      let char_count = List.length char_list in
      let expected_count = UTF8Processing.count_utf8_chars input in
      let match_result = char_count = expected_count in
      Printf.printf "字符串 '%s': 字符数=%d, 列表长度=%d, 匹配=%b\n"
        input expected_count char_count match_result;
      Printf.printf "  字符列表: [%s]\n" (String.concat "; " char_list)
    ) test_strings
end

(** 位置跟踪测试模块 *)
module PositionTrackingTests = struct
  let test_position_conversion () =
    Printf.printf "\n=== 测试位置转换 ===\n";
    let test_cases = [
      ("hello", [(0, 0); (1, 1); (5, 5)]);
      ("你好", [(0, 0); (3, 1); (6, 2)]);
      ("a你b", [(0, 0); (1, 1); (4, 2); (5, 3)]);
    ] in
    List.iter (fun (input, test_positions) ->
      Printf.printf "字符串 '%s':\n" input;
      List.iter (fun (byte_offset, expected_char_offset) ->
        let actual_char_offset = PositionTracking.byte_offset_to_char_offset input byte_offset in
        let reverse_byte_offset = PositionTracking.char_offset_to_byte_offset input actual_char_offset in
        Printf.printf "  字节偏移 %d -> 字符偏移 %d (期望 %d), 反向转换 %d\n"
          byte_offset actual_char_offset expected_char_offset reverse_byte_offset
      ) test_positions
    ) test_cases

  let test_position_advancement () =
    Printf.printf "\n=== 测试位置推进 ===\n";
    let initial_pos = PositionTracking.create_initial_position () in
    let test_chars = ["a"; "你"; "\n"; "好"] in
    let rec test_advancement pos chars =
      match chars with
      | [] -> ()
      | char :: rest ->
          Printf.printf "处理字符 '%s': 字节位置 %d -> " char pos.byte_pos;
          let new_pos = PositionTracking.advance_position pos char in
          Printf.printf "%d, 字符位置 %d -> %d, 行号 %d -> %d\n"
            new_pos.byte_pos pos.char_pos new_pos.char_pos pos.line_num new_pos.line_num;
          test_advancement new_pos rest
    in
    test_advancement initial_pos test_chars

  let test_context_extraction () =
    Printf.printf "\n=== 测试上下文提取 ===\n";
    let input = "这是一个测试字符串，包含中文和标点。" in
    let test_positions = [0; 9; 15; 24] in
    List.iter (fun pos ->
      let before, after = PositionTracking.get_context_at_position input pos 3 in
      Printf.printf "位置 %d: 前文='%s', 后文='%s'\n" pos before after
    ) test_positions
end

(** 边界检测测试模块 *)
module BoundaryDetectionTests = struct
  let test_word_boundaries () =
    Printf.printf "\n=== 测试词边界检测 ===\n";
    let test_cases = [
      ("hello world", [0; 5; 6; 11]);
      ("你好世界", [0; 3; 6; 9]);
      ("中文English混合", [0; 6; 13; 16]);
    ] in
    List.iter (fun (input, expected_boundaries) ->
      Printf.printf "字符串 '%s':\n" input;
      List.iter (fun pos ->
        let is_boundary = BoundaryDetection.is_word_boundary input pos in
        Printf.printf "  位置 %d: %s\n" pos (if is_boundary then "边界" else "非边界")
      ) expected_boundaries
    ) test_cases

  let test_chinese_keyword_boundaries () =
    Printf.printf "\n=== 测试中文关键字边界 ===\n";
    let test_cases = [
      ("让变量", "让", 0, true);
      ("让「变量」", "让", 0, true);
      ("设置变量", "设", 0, false);  (* "设"不是完整关键字 *)
      ("假如条件", "假如", 0, true);
    ] in
    List.iter (fun (input, keyword, pos, expected) ->
      let actual = BoundaryDetection.is_chinese_keyword_boundary input pos keyword in
      let match_result = actual = expected in
      Printf.printf "输入 '%s', 关键字 '%s', 位置 %d: 期望=%b, 实际=%b, 匹配=%b\n"
        input keyword pos expected actual match_result
    ) test_cases
end

(** 性能测试模块 *)
module PerformanceTests = struct
  let test_lookup_performance () =
    Printf.printf "\n=== 测试查找性能 ===\n";
    let test_chars = ["，"; "。"; "："; "；"; "（"; "）"; "【"; "】"; "→"; "⇒"] in
    let iterations = 1000 in
    
    (* 测试优化查找 *)
    let start_time = Sys.time () in
    for i = 1 to iterations do
      List.iter (fun char ->
        ignore (OptimizedLookup.find_bytes_by_char_fast char)
      ) test_chars
    done;
    let optimized_time = Sys.time () -. start_time in
    
    Printf.printf "优化查找 (%d次 × %d字符): %.6f秒\n" 
      iterations (List.length test_chars) optimized_time;
    
    (* 获取缓存统计 *)
    let char_cache_size, boundary_cache_size = Performance.get_cache_stats () in
    Printf.printf "缓存统计: 字符缓存=%d, 边界缓存=%d\n" 
      char_cache_size boundary_cache_size

  let test_batch_processing () =
    Printf.printf "\n=== 测试批量处理性能 ===\n";
    let large_text = String.concat "" (List.init 100 (fun _ -> "这是测试文本，包含中文字符。")) in
    
    let start_time = Sys.time () in
    let char_list = UTF8Processing.utf8_string_to_char_list large_text in
    let char_count = List.length char_list in
    let processing_time = Sys.time () -. start_time in
    
    Printf.printf "处理 %d 字符: %.6f秒 (%.0f 字符/秒)\n" 
      char_count processing_time (float char_count /. processing_time)
end

(** 错误处理测试模块 *)
module ErrorHandlingTests = struct
  let test_invalid_utf8_handling () =
    Printf.printf "\n=== 测试无效UTF-8处理 ===\n";
    let invalid_sequences = [
      "\xFF\xFE";  (* 无效起始字节 *)
      "\xE4\x80";  (* 不完整的3字节序列 *)
      "\xE4\xFF\x80";  (* 无效继续字节 *)
    ] in
    List.iter (fun invalid_input ->
      Printf.printf "测试无效序列: ";
      match UTF8Processing.next_utf8_char_safe invalid_input 0 with
      | ValidChar (char, len) -> 
          Printf.printf "意外成功: '%s' (长度 %d)\n" char len
      | InvalidSequence (pos, msg) -> 
          Printf.printf "正确检测到错误位置 %d: %s ✅\n" pos msg
      | EndOfInput -> 
          Printf.printf "输入结束\n"
    ) invalid_sequences

  let test_error_recovery () =
    Printf.printf "\n=== 测试错误恢复 ===\n";
    let mixed_input = "正常\xFF无效\xFE字符" in
    Printf.printf "输入包含无效字节的字符串: '%s'\n" mixed_input;
    
    let errors = UTF8Processing.validate_utf8_string mixed_input in
    Printf.printf "发现 %d 个错误:\n" (List.length errors);
    List.iter (fun (pos, msg) ->
      Printf.printf "  位置 %d: %s\n" pos msg
    ) errors
end

(** 中文编程体验测试模块 *)
module ChineseProgrammingTests = struct
  let test_programming_examples () =
    Printf.printf "\n=== 测试中文编程示例 ===\n";
    List.iter (fun example ->
      Printf.printf "分析示例: '%s'\n" example;
      let char_list = UTF8Processing.utf8_string_to_char_list example in
      let char_count = List.length char_list in
      let categories = List.map (fun char ->
        CharacterDetection.classify_unicode_char char
      ) char_list in
      
      Printf.printf "  字符数: %d\n" char_count;
      Printf.printf "  字符分类: [%s]\n" (String.concat "; " categories);
      
      (* 统计各类别数量 *)
      let category_counts = Hashtbl.create 8 in
      List.iter (fun category ->
        let count = try Hashtbl.find category_counts category with Not_found -> 0 in
        Hashtbl.replace category_counts category (count + 1)
      ) categories;
      
      Printf.printf "  类别统计: ";
      Hashtbl.iter (fun category count ->
        Printf.printf "%s(%d) " category count
      ) category_counts;
      Printf.printf "\n\n"
    ) TestData.chinese_programming_examples

  let test_character_suggestions () =
    Printf.printf "=== 测试字符建议功能 ===\n";
    let ascii_chars = ["("; ")"; ","; ":"; ";"; "."; "!"; "?"; "["; "]"; "|"] in
    List.iter (fun ascii_char ->
      match CharacterValidation.suggest_alternative ascii_char with
      | Some chinese_alt ->
          Printf.printf "ASCII '%s' -> 中文 '%s' ✅\n" ascii_char chinese_alt
      | None ->
          Printf.printf "ASCII '%s' -> 无建议\n" ascii_char
    ) ascii_chars
end

(** 主测试运行器 *)
let run_all_tests () =
  Printf.printf "🧪 骆言Unicode字符处理增强功能测试套件\n";
  Printf.printf "========================================\n\n";
  
  CharacterClassificationTests.test_chinese_punctuation ();
  CharacterClassificationTests.test_chinese_symbols ();
  CharacterClassificationTests.test_poetry_symbols ();
  CharacterClassificationTests.test_chinese_numbers ();
  CharacterClassificationTests.test_quote_handling ();
  
  UTF8ProcessingTests.test_utf8_char_counting ();
  UTF8ProcessingTests.test_utf8_string_validation ();
  UTF8ProcessingTests.test_char_list_conversion ();
  
  PositionTrackingTests.test_position_conversion ();
  PositionTrackingTests.test_position_advancement ();
  PositionTrackingTests.test_context_extraction ();
  
  BoundaryDetectionTests.test_word_boundaries ();
  BoundaryDetectionTests.test_chinese_keyword_boundaries ();
  
  PerformanceTests.test_lookup_performance ();
  PerformanceTests.test_batch_processing ();
  
  ErrorHandlingTests.test_invalid_utf8_handling ();
  ErrorHandlingTests.test_error_recovery ();
  
  ChineseProgrammingTests.test_programming_examples ();
  ChineseProgrammingTests.test_character_suggestions ();
  
  Printf.printf "\n🎉 所有测试完成！\n";
  
  (* 显示统计信息 *)
  Statistics.print_statistics ();
  let name_to_char_size, char_to_bytes_size, name_to_bytes_size, category_to_defs_size = 
    Statistics.get_lookup_performance_info () in
  Printf.printf "\n📊 查找表性能信息:\n";
  Printf.printf "名称->字符表: %d 条目\n" name_to_char_size;
  Printf.printf "字符->字节表: %d 条目\n" char_to_bytes_size;
  Printf.printf "名称->字节表: %d 条目\n" name_to_bytes_size;
  Printf.printf "类别->定义表: %d 条目\n" category_to_defs_size

(** 程序入口点 *)
let () = run_all_tests ()