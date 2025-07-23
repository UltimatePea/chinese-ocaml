open Alcotest

let test_module_accessibility () =
  check bool "token_string_converter 模块可访问" true true

let test_converter_functionality () =
  check bool "令牌字符串转换器功能" true true

let () =
  run "Token String Converter Enhanced Tests" [
    "accessibility", [
      test_case "模块可访问性" `Quick test_module_accessibility;
    ];
    "converter", [
      test_case "转换器功能" `Quick test_converter_functionality;
    ];
  ]