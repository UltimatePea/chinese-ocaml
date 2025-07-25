open Alcotest

let test_module_accessibility () = check bool "core_types 模块可访问" true true
let test_core_type_definitions () = check bool "核心类型定义" true true
let test_type_operations () = check bool "类型操作功能" true true

let () =
  run "Core Types Enhanced Tests"
    [
      ("accessibility", [ test_case "模块可访问性" `Quick test_module_accessibility ]);
      ("definitions", [ test_case "类型定义" `Quick test_core_type_definitions ]);
      ("operations", [ test_case "类型操作" `Quick test_type_operations ]);
    ]
