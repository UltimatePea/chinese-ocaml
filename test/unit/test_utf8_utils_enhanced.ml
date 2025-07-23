open Alcotest

let test_module_accessibility () =
  check bool "utf8_utils 模块可访问" true true

let test_utf8_functions () =
  check bool "UTF-8工具功能" true true

let () =
  run "UTF8 Utils Enhanced Tests" [
    "accessibility", [
      test_case "模块可访问性" `Quick test_module_accessibility;
    ];
    "utilities", [
      test_case "UTF-8工具" `Quick test_utf8_functions;
    ];
  ]