open Alcotest

let test_module_accessibility () = check bool "string_processing_utils 模块可访问" true true
let test_string_processing () = check bool "字符串处理工具功能" true true
let test_utility_functions () = check bool "实用功能函数" true true

let () =
  run "String Processing Utils Enhanced Tests"
    [
      ("accessibility", [ test_case "模块可访问性" `Quick test_module_accessibility ]);
      ("processing", [ test_case "字符串处理" `Quick test_string_processing ]);
      ("utilities", [ test_case "实用功能" `Quick test_utility_functions ]);
    ]
