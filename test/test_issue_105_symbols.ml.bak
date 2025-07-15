open Yyocamlc_lib.Lexer

(** 测试问题105：仅支持特定中文符号 *)

let test_supported_chinese_symbols () =
  let test_cases =
    [
      (* 支持的符号 *)
      ("「测试」", [ QuotedIdentifierToken "测试"; EOF ]);
      ("（参数）", [ ChineseLeftParen; IdentifierToken "参数"; ChineseRightParen; EOF ]);
      ("：注释", [ ChineseColon; IdentifierToken "注释"; EOF ]);
      ("，分隔", [ ChineseComma; IdentifierToken "分隔"; EOF ]);
      ("。结束", [ Dot; EndKeyword; EOF ]);
      (* 中文数字 *)
      ("零", [ IdentifierToken "零"; EOF ]);
      ("二", [ IdentifierToken "二"; EOF ]);
      ("三", [ IdentifierToken "三"; EOF ]);
      ("四", [ IdentifierToken "四"; EOF ]);
      ("五", [ IdentifierToken "五"; EOF ]);
      ("六", [ IdentifierToken "六"; EOF ]);
      ("七", [ IdentifierToken "七"; EOF ]);
      ("八", [ IdentifierToken "八"; EOF ]);
      ("九", [ IdentifierToken "九"; EOF ]);
      ("点", [ IdentifierToken "点"; EOF ]);
      (* 组合测试 *)
      ( "「函数名」（参数一，参数二）：返回三。",
        [
          QuotedIdentifierToken "函数名";
          ChineseLeftParen;
          IdentifierToken "参数一";
          ChineseComma;
          IdentifierToken "参数二";
          ChineseRightParen;
          ChineseColon;
          IdentifierToken "返回三";
          Dot;
          EOF;
        ] );
    ]
  in

  List.iter
    (fun (input, expected) ->
      Printf.printf "测试输入: %s\n" input;
      try
        let tokens = tokenize input "test.chinese" in
        let actual = List.map fst tokens in
        if actual = expected then Printf.printf "✓ 通过\n"
        else (
          Printf.printf "✗ 失败\n";
          Printf.printf "期望: %s\n" (String.concat "; " (List.map show_token expected));
          Printf.printf "实际: %s\n" (String.concat "; " (List.map show_token actual)))
      with
      | LexError (msg, pos) -> Printf.printf "✗ 词法错误: %s (行%d 列%d)\n" msg pos.line pos.column
      | e ->
          Printf.printf "✗ 异常: %s\n" (Printexc.to_string e);
          Printf.printf "\n")
    test_cases

let test_forbidden_symbols () =
  let forbidden_cases =
    [
      (* ASCII符号 *)
      ("+", "ASCII符号已禁用");
      ("-", "ASCII符号已禁用");
      ("*", "ASCII符号已禁用");
      ("/", "ASCII符号已禁用");
      ("=", "ASCII符号已禁用");
      ("<", "ASCII符号已禁用");
      (">", "ASCII符号已禁用");
      ("(", "ASCII符号已禁用");
      (")", "ASCII符号已禁用");
      ("[", "ASCII符号已禁用");
      ("]", "ASCII符号已禁用");
      ("{", "ASCII符号已禁用");
      ("}", "ASCII符号已禁用");
      ("|", "ASCII符号已禁用");
      (* 阿拉伯数字 *)
      ("0", "阿拉伯数字已禁用");
      ("1", "阿拉伯数字已禁用");
      ("2", "阿拉伯数字已禁用");
      ("3", "阿拉伯数字已禁用");
      ("123", "阿拉伯数字已禁用");
      ("1.23", "阿拉伯数字已禁用");
      (* 全宽阿拉伯数字 *)
      ("０", "阿拉伯数字已禁用");
      ("１", "阿拉伯数字已禁用");
      ("２", "阿拉伯数字已禁用");
      ("１２３", "阿拉伯数字已禁用");
      (* 不支持的中文符号 *)
      ("；", "非支持的中文符号已禁用");
      ("｜", "非支持的中文符号已禁用");
      ("【", "非支持的中文符号已禁用");
      ("】", "非支持的中文符号已禁用");
      ("→", "非支持的中文符号已禁用");
      ("⇒", "非支持的中文符号已禁用");
      ("←", "非支持的中文符号已禁用");
      ("『", "非支持的中文符号已禁用");
      ("』", "非支持的中文符号已禁用");
      (* 全宽运算符 *)
      ("＋", "非支持的中文符号已禁用");
      ("－", "非支持的中文符号已禁用");
      ("＊", "非支持的中文符号已禁用");
      ("／", "非支持的中文符号已禁用");
      ("＝", "非支持的中文符号已禁用");
      ("＜", "非支持的中文符号已禁用");
      ("＞", "非支持的中文符号已禁用");
      ("％", "非支持的中文符号已禁用");
    ]
  in

  List.iter
    (fun (input, _error_type) ->
      Printf.printf "测试禁用符号: %s\n" input;
      try
        let _ = tokenize input "test.chinese" in
        Printf.printf "✗ 失败：应该抛出错误但没有\n"
      with
      | LexError (msg, _pos) ->
          if Str.string_match (Str.regexp ".*禁.*") msg 0 then Printf.printf "✓ 正确抛出错误: %s\n" msg
          else Printf.printf "✗ 错误消息不正确: %s\n" msg
      | e ->
          Printf.printf "✗ 意外异常: %s\n" (Printexc.to_string e);
          Printf.printf "\n")
    forbidden_cases

let () =
  Printf.printf "=== 测试问题105：仅支持特定中文符号 ===\n\n";
  Printf.printf "--- 测试支持的符号 ---\n";
  test_supported_chinese_symbols ();
  Printf.printf "\n--- 测试禁用的符号 ---\n";
  test_forbidden_symbols ();
  Printf.printf "\n测试完成。\n"
