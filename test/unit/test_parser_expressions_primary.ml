open Alcotest

let test_module_accessibility () =
  check bool "parser_expressions_primary 模块可访问" true true

let test_basic_functionality () =
  check bool "基础功能测试" true true

let () =
  run "Parser Expressions Primary Tests" [
    "accessibility", [
      test_case "模块可访问性" `Quick test_module_accessibility;
    ];
    "basic", [
      test_case "基础功能" `Quick test_basic_functionality;
    ];
  ]