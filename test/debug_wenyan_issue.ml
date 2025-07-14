(** 调试文言文解析问题 *)

open Yyocamlc_lib.Lexer

let debug_reserved_word word =
  let result = is_reserved_word word in
  Printf.printf "检查保留词 '%s': %b\n" word result

let debug_tokenize input =
  let tokens = tokenize input "debug" in
  Printf.printf "词法分析 '%s':\n" input;
  List.iteri (fun i (token, pos) ->
    Printf.printf "  %d: %s (行:%d, 列:%d)\n" i (show_token token) pos.line pos.column
  ) tokens;
  Printf.printf "\n"

let debug_prefix_check prefix =
  let has_prefix = List.exists (fun word ->
    String.length word > String.length prefix &&
    String.sub word 0 (String.length prefix) = prefix
  ) reserved_words in
  Printf.printf "'%s' 是保留词前缀: %b\n" prefix has_prefix

let debug_utf8_bytes str =
  Printf.printf "字符串 '%s' 的UTF-8字节: " str;
  for i = 0 to String.length str - 1 do
    Printf.printf "%d " (Char.code str.[i])
  done;
  Printf.printf "\n"

let () =
  Printf.printf "=== 调试保留词检查 ===\n\n";

  (* 测试各种情况 *)
  debug_reserved_word "数值";
  debug_reserved_word "数组长度";

  Printf.printf "\n=== 调试词法分析 ===\n\n";
  debug_tokenize "数组长度";
  debug_tokenize "数组长度 数组";

  Printf.printf "\n=== 前缀检查测试 ===\n\n";
  debug_prefix_check "数";
  debug_prefix_check "数组";
  debug_reserved_word "数";
  debug_reserved_word "数组";
  debug_reserved_word "数据";

  Printf.printf "\n=== UTF-8编码检查 ===\n\n";
  debug_utf8_bytes "数值";
  debug_utf8_bytes "数";
  debug_utf8_bytes "值";

  Printf.printf "\n=== 词法分析测试 ===\n\n";

  (* 测试单独的词 *)
  let test_single word =
    Printf.printf "测试: '%s'\n" word;
    let tokens = tokenize word "debug.luo" in
    List.iteri (fun i (token, _pos) ->
      Printf.printf "  %d: %s\n" i (show_token token)
    ) tokens;
    Printf.printf "\n"
  in

  test_single "数值";
  test_single "数";
  test_single "数组";

  Printf.printf "\n=== 组合测试 ===\n\n";
  test_single "数值为";
  test_single "数值为42";

  Printf.printf "\n=== 前缀检查测试 ===\n\n";
  let check_prefix prefix =
    let is_prefix = List.exists (fun word ->
      String.length word > String.length prefix &&
      String.sub word 0 (String.length prefix) = prefix
    ) reserved_words in
    Printf.printf "'%s' 是保留词前缀: %b\n" prefix is_prefix
  in
  check_prefix "数";
  check_prefix "数值";