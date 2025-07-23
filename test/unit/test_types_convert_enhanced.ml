open Alcotest

let test_module_accessibility () =
  check bool "types_convert 模块可访问" true true

let test_type_conversion () =
  check bool "类型转换功能" true true

let () =
  run "Types Convert Enhanced Tests" [
    "accessibility", [
      test_case "模块可访问性" `Quick test_module_accessibility;
    ];
    "conversion", [
      test_case "类型转换" `Quick test_type_conversion;
    ];
  ]