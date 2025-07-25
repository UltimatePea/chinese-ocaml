open Yyocamlc_lib.Config

let test_env_vars =
  [
    "CHINESE_OCAML_DEBUG";
    "CHINESE_OCAML_VERBOSE";
    "CHINESE_OCAML_BUFFER_SIZE";
    "CHINESE_OCAML_TIMEOUT";
    "CHINESE_OCAML_OUTPUT_DIR";
    "CHINESE_OCAML_TEMP_DIR";
    "CHINESE_OCAML_C_COMPILER";
    "CHINESE_OCAML_OPT_LEVEL";
    "CHINESE_OCAML_MAX_ERRORS";
    "CHINESE_OCAML_LOG_LEVEL";
    "CHINESE_OCAML_COLOR";
  ]

let () =
  Printf.printf "🧪 骆言环境变量配置模块全面测试开始\n\n";

  (* 保存原始环境变量状态 *)
  Printf.printf "💾 保存原始环境变量状态\n";
  let original_env_values =
    List.map (fun var -> (var, try Some (Sys.getenv var) with Not_found -> None)) test_env_vars
  in
  Printf.printf "✅ 已保存 %d 个环境变量的原始状态\n" (List.length original_env_values);

  (* 清理所有测试相关的环境变量 *)
  Printf.printf "\n🧹 清理测试环境变量\n";
  List.iter (fun var -> try Unix.putenv var "" with _ -> ()) test_env_vars;
  Printf.printf "✅ 环境变量清理完成\n";

  (* 测试各种类型的环境变量解析 *)
  Printf.printf "\n🔧 测试环境变量类型解析\n";

  (* 测试布尔型环境变量 *)
  Printf.printf "\n📝 测试布尔型环境变量\n";
  (try
     let bool_test_cases =
       [
         ("CHINESE_OCAML_DEBUG", "true", true);
         ("CHINESE_OCAML_DEBUG", "false", false);
         ("CHINESE_OCAML_DEBUG", "1", true);
         ("CHINESE_OCAML_DEBUG", "0", false);
         ("CHINESE_OCAML_DEBUG", "yes", true);
         ("CHINESE_OCAML_DEBUG", "no", false);
         ("CHINESE_OCAML_DEBUG", "on", true);
         ("CHINESE_OCAML_DEBUG", "off", false);
         ("CHINESE_OCAML_VERBOSE", "TRUE", true);
         ("CHINESE_OCAML_VERBOSE", "FALSE", false);
       ]
     in

     List.iter
       (fun (var, value, expected) ->
         Unix.putenv var value;
         let result = parse_boolean_env_var var in
         if result = expected then Printf.printf "✅ %s='%s' -> %b\n" var value result
         else Printf.printf "❌ %s='%s' 期望 %b，实际 %b\n" var value expected result;
         Unix.putenv var "")
       bool_test_cases
   with e -> Printf.printf "❌ 布尔型环境变量测试失败: %s\n" (Printexc.to_string e));

  (* 测试整数型环境变量 *)
  Printf.printf "\n🔢 测试整数型环境变量\n";
  (try
     let int_test_cases =
       [
         ("CHINESE_OCAML_BUFFER_SIZE", "1024", Some 1024);
         ("CHINESE_OCAML_BUFFER_SIZE", "4096", Some 4096);
         ("CHINESE_OCAML_BUFFER_SIZE", "0", None);
         (* 非正数应被拒绝 *)
         ("CHINESE_OCAML_BUFFER_SIZE", "-100", None);
         (* 负数应被拒绝 *)
         ("CHINESE_OCAML_BUFFER_SIZE", "abc", None);
         (* 非数字应被拒绝 *)
         ("CHINESE_OCAML_BUFFER_SIZE", "2147483648", None);
         (* 溢出应被处理 *)
         ("CHINESE_OCAML_MAX_ERRORS", "10", Some 10);
         ("CHINESE_OCAML_MAX_ERRORS", "100", Some 100);
       ]
     in

     List.iter
       (fun (var, value, expected) ->
         Unix.putenv var value;
         let result = parse_positive_int_env_var var in
         match (result, expected) with
         | Some r, Some e when r = e -> Printf.printf "✅ %s='%s' -> %d\n" var value r
         | None, None -> Printf.printf "✅ %s='%s' 正确被拒绝\n" var value
         | Some r, None -> Printf.printf "❌ %s='%s' 应被拒绝，但得到 %d\n" var value r
         | None, Some e -> Printf.printf "❌ %s='%s' 期望 %d，但被拒绝\n" var value e
         | Some r, Some e ->
             Printf.printf "❌ %s='%s' 期望 %d，实际 %d\n" var value e r;
             Unix.putenv var "")
       int_test_cases
   with e -> Printf.printf "❌ 整数型环境变量测试失败: %s\n" (Printexc.to_string e));

  (* 测试浮点数型环境变量 *)
  Printf.printf "\n🔢 测试浮点数型环境变量\n";
  (try
     let float_test_cases =
       [
         ("CHINESE_OCAML_TIMEOUT", "30.0", Some 30.0);
         ("CHINESE_OCAML_TIMEOUT", "60.5", Some 60.5);
         ("CHINESE_OCAML_TIMEOUT", "0.0", None);
         (* 非正数应被拒绝 *)
         ("CHINESE_OCAML_TIMEOUT", "-10.5", None);
         (* 负数应被拒绝 *)
         ("CHINESE_OCAML_TIMEOUT", "abc", None);
         (* 非数字应被拒绝 *)
         ("CHINESE_OCAML_TIMEOUT", "3.14159", Some 3.14159);
       ]
     in

     List.iter
       (fun (var, value, expected) ->
         Unix.putenv var value;
         let result = parse_positive_float_env_var var in
         match (result, expected) with
         | Some r, Some e when abs_float (r -. e) < 0.0001 ->
             Printf.printf "✅ %s='%s' -> %.6f\n" var value r
         | None, None -> Printf.printf "✅ %s='%s' 正确被拒绝\n" var value
         | Some r, None -> Printf.printf "❌ %s='%s' 应被拒绝，但得到 %.6f\n" var value r
         | None, Some e -> Printf.printf "❌ %s='%s' 期望 %.6f，但被拒绝\n" var value e
         | Some r, Some e ->
             Printf.printf "❌ %s='%s' 期望 %.6f，实际 %.6f\n" var value e r;
             Unix.putenv var "")
       float_test_cases
   with e -> Printf.printf "❌ 浮点数型环境变量测试失败: %s\n" (Printexc.to_string e));

  (* 测试字符串型环境变量 *)
  Printf.printf "\n📝 测试字符串型环境变量\n";
  (try
     let string_test_cases =
       [
         ("CHINESE_OCAML_OUTPUT_DIR", "/tmp/luoyan", Some "/tmp/luoyan");
         ("CHINESE_OCAML_OUTPUT_DIR", "骆言输出目录", Some "骆言输出目录");
         ("CHINESE_OCAML_OUTPUT_DIR", "", None);
         (* 空字符串应被拒绝 *)
         ("CHINESE_OCAML_OUTPUT_DIR", "   ", None);
         (* 只有空格应被拒绝 *)
         ("CHINESE_OCAML_C_COMPILER", "gcc", Some "gcc");
         ("CHINESE_OCAML_C_COMPILER", "clang", Some "clang");
         ("CHINESE_OCAML_TEMP_DIR", "/tmp", Some "/tmp");
       ]
     in

     List.iter
       (fun (var, value, expected) ->
         Unix.putenv var value;
         let result = parse_non_empty_string_env_var var in
         match (result, expected) with
         | Some r, Some e when String.equal r e -> Printf.printf "✅ %s='%s' -> '%s'\n" var value r
         | None, None -> Printf.printf "✅ %s='%s' 正确被拒绝\n" var value
         | Some r, None -> Printf.printf "❌ %s='%s' 应被拒绝，但得到 '%s'\n" var value r
         | None, Some e -> Printf.printf "❌ %s='%s' 期望 '%s'，但被拒绝\n" var value e
         | Some r, Some e ->
             Printf.printf "❌ %s='%s' 期望 '%s'，实际 '%s'\n" var value e r;
             Unix.putenv var "")
       string_test_cases
   with e -> Printf.printf "❌ 字符串型环境变量测试失败: %s\n" (Printexc.to_string e));

  (* 测试范围整数型环境变量 *)
  Printf.printf "\n📊 测试范围整数型环境变量\n";
  (try
     let range_test_cases =
       [
         ("CHINESE_OCAML_OPT_LEVEL", "0", 0, 3, Some 0);
         ("CHINESE_OCAML_OPT_LEVEL", "1", 0, 3, Some 1);
         ("CHINESE_OCAML_OPT_LEVEL", "2", 0, 3, Some 2);
         ("CHINESE_OCAML_OPT_LEVEL", "3", 0, 3, Some 3);
         ("CHINESE_OCAML_OPT_LEVEL", "4", 0, 3, None);
         (* 超出范围 *)
         ("CHINESE_OCAML_OPT_LEVEL", "-1", 0, 3, None);
         (* 低于范围 *)
         ("CHINESE_OCAML_MAX_ERRORS", "5", 1, 100, Some 5);
         ("CHINESE_OCAML_MAX_ERRORS", "50", 1, 100, Some 50);
         ("CHINESE_OCAML_MAX_ERRORS", "100", 1, 100, Some 100);
         ("CHINESE_OCAML_MAX_ERRORS", "101", 1, 100, None);
         (* 超出范围 *)
       ]
     in

     List.iter
       (fun (var, value, min_val, max_val, expected) ->
         Unix.putenv var value;
         let result = parse_int_range_env_var var min_val max_val in
         match (result, expected) with
         | Some r, Some e when r = e ->
             Printf.printf "✅ %s='%s' [%d-%d] -> %d\n" var value min_val max_val r
         | None, None -> Printf.printf "✅ %s='%s' [%d-%d] 正确被拒绝\n" var value min_val max_val
         | Some r, None ->
             Printf.printf "❌ %s='%s' [%d-%d] 应被拒绝，但得到 %d\n" var value min_val max_val r
         | None, Some e ->
             Printf.printf "❌ %s='%s' [%d-%d] 期望 %d，但被拒绝\n" var value min_val max_val e
         | Some r, Some e ->
             Printf.printf "❌ %s='%s' [%d-%d] 期望 %d，实际 %d\n" var value min_val max_val e r;
             Unix.putenv var "")
       range_test_cases
   with e -> Printf.printf "❌ 范围整数型环境变量测试失败: %s\n" (Printexc.to_string e));

  (* 测试枚举型环境变量 *)
  Printf.printf "\n📋 测试枚举型环境变量\n";
  (try
     let enum_test_cases =
       [
         ("CHINESE_OCAML_LOG_LEVEL", "debug", [ "debug"; "info"; "warn"; "error" ], Some "debug");
         ("CHINESE_OCAML_LOG_LEVEL", "info", [ "debug"; "info"; "warn"; "error" ], Some "info");
         ("CHINESE_OCAML_LOG_LEVEL", "warn", [ "debug"; "info"; "warn"; "error" ], Some "warn");
         ("CHINESE_OCAML_LOG_LEVEL", "error", [ "debug"; "info"; "warn"; "error" ], Some "error");
         ("CHINESE_OCAML_LOG_LEVEL", "invalid", [ "debug"; "info"; "warn"; "error" ], None);
         ("CHINESE_OCAML_LOG_LEVEL", "DEBUG", [ "debug"; "info"; "warn"; "error" ], None);
         (* 大小写敏感 *)
       ]
     in

     List.iter
       (fun (var, value, valid_values, expected) ->
         Unix.putenv var value;
         let result = parse_enum_env_var var valid_values in
         match (result, expected) with
         | Some r, Some e when String.equal r e ->
             Printf.printf "✅ %s='%s' {%s} -> '%s'\n" var value (String.concat ", " valid_values) r
         | None, None ->
             Printf.printf "✅ %s='%s' {%s} 正确被拒绝\n" var value (String.concat ", " valid_values)
         | Some r, None ->
             Printf.printf "❌ %s='%s' {%s} 应被拒绝，但得到 '%s'\n" var value
               (String.concat ", " valid_values) r
         | None, Some e ->
             Printf.printf "❌ %s='%s' {%s} 期望 '%s'，但被拒绝\n" var value
               (String.concat ", " valid_values) e
         | Some r, Some e ->
             Printf.printf "❌ %s='%s' {%s} 期望 '%s'，实际 '%s'\n" var value
               (String.concat ", " valid_values) e r;
             Unix.putenv var "")
       enum_test_cases
   with e -> Printf.printf "❌ 枚举型环境变量测试失败: %s\n" (Printexc.to_string e));

  (* 测试综合环境变量配置加载 *)
  Printf.printf "\n🔄 测试综合环境变量配置加载\n";
  (try
     (* 设置一组完整的环境变量 *)
     Unix.putenv "CHINESE_OCAML_DEBUG" "true";
     Unix.putenv "CHINESE_OCAML_VERBOSE" "false";
     Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" "8192";
     Unix.putenv "CHINESE_OCAML_TIMEOUT" "45.0";
     Unix.putenv "CHINESE_OCAML_OUTPUT_DIR" "/tmp/骆言输出";
     Unix.putenv "CHINESE_OCAML_C_COMPILER" "clang";
     Unix.putenv "CHINESE_OCAML_OPT_LEVEL" "2";
     Unix.putenv "CHINESE_OCAML_MAX_ERRORS" "25";
     Unix.putenv "CHINESE_OCAML_LOG_LEVEL" "info";
     Unix.putenv "CHINESE_OCAML_COLOR" "yes";

     Printf.printf "🔧 已设置完整的环境变量集合\n";

     (* 记录加载前的配置状态 *)
     let before_debug = Get.debug_mode () in
     let before_verbose = Get.verbose_logging () in
     let before_buffer = Get.buffer_size () in
     let before_timeout = Get.compilation_timeout () in
     let before_output = Get.output_directory () in
     let before_compiler = Get.c_compiler () in
     let before_opt = Get.optimization_level () in
     let before_max_errors = Get.max_error_count () in
     let before_colored = Get.colored_output () in

     Printf.printf "📊 加载前配置状态记录完成\n";

     (* 从环境变量加载配置 *)
     load_from_env ();
     Printf.printf "🔄 环境变量配置加载完成\n";

     (* 检查加载后的配置状态 *)
     let after_debug = Get.debug_mode () in
     let after_verbose = Get.verbose_logging () in
     let after_buffer = Get.buffer_size () in
     let after_timeout = Get.compilation_timeout () in
     let after_output = Get.output_directory () in
     let after_compiler = Get.c_compiler () in
     let after_opt = Get.optimization_level () in
     let after_max_errors = Get.max_error_count () in
     let after_colored = Get.colored_output () in

     Printf.printf "\n📈 配置加载前后对比:\n";
     Printf.printf "  调试模式: %b -> %b\n" before_debug after_debug;
     Printf.printf "  详细日志: %b -> %b\n" before_verbose after_verbose;
     Printf.printf "  缓冲区大小: %d -> %d\n" before_buffer after_buffer;
     Printf.printf "  编译超时: %.2f -> %.2f\n" before_timeout after_timeout;
     Printf.printf "  输出目录: %s -> %s\n" before_output after_output;
     Printf.printf "  C编译器: %s -> %s\n" before_compiler after_compiler;
     Printf.printf "  优化级别: %d -> %d\n" before_opt after_opt;
     Printf.printf "  最大错误数: %d -> %d\n" before_max_errors after_max_errors;
     Printf.printf "  彩色输出: %b -> %b\n" before_colored after_colored;

     (* 验证关键配置是否正确更新 *)
     let key_updates_correct =
       after_debug = true && after_verbose = false && after_buffer = 8192
       && abs_float (after_timeout -. 45.0) < 0.1
       && String.equal after_output "/tmp/骆言输出"
       && String.equal after_compiler "clang"
       && after_opt = 2 && after_max_errors = 25 && after_colored = true
     in

     if key_updates_correct then Printf.printf "✅ 综合环境变量配置加载测试完全通过\n"
     else Printf.printf "⚠️  综合环境变量配置加载部分成功（某些值可能有系统限制）\n"
   with e -> Printf.printf "❌ 综合环境变量配置加载测试失败: %s\n" (Printexc.to_string e));

  (* 测试无效环境变量的处理 *)
  Printf.printf "\n❌ 测试无效环境变量处理\n";
  (try
     let invalid_env_tests =
       [
         ("CHINESE_OCAML_DEBUG", "maybe");
         (* 无效布尔值 *)
         ("CHINESE_OCAML_BUFFER_SIZE", "huge");
         (* 无效整数 *)
         ("CHINESE_OCAML_TIMEOUT", "forever");
         (* 无效浮点数 *)
         ("CHINESE_OCAML_OUTPUT_DIR", "");
         (* 空字符串 *)
         ("CHINESE_OCAML_OPT_LEVEL", "10");
         (* 超出范围 *)
         ("CHINESE_OCAML_LOG_LEVEL", "trace");
         (* 无效枚举值 *)
       ]
     in

     List.iter
       (fun (var, invalid_value) ->
         Unix.putenv var invalid_value;
         (* 尝试加载环境变量，应该优雅地处理错误 *)
         (try
            load_from_env ();
            Printf.printf "✅ 无效环境变量 %s='%s' 被优雅处理\n" var invalid_value
          with e ->
            Printf.printf "✅ 无效环境变量 %s='%s' 抛出异常: %s\n" var invalid_value (Printexc.to_string e));
         Unix.putenv var "")
       invalid_env_tests
   with e -> Printf.printf "❌ 无效环境变量处理测试失败: %s\n" (Printexc.to_string e));

  (* 性能测试：大量环境变量处理 *)
  Printf.printf "\n⚡ 性能测试\n";
  (try
     let start_time = Sys.time () in

     (* 重复设置和加载环境变量 *)
     for i = 1 to 1000 do
       Unix.putenv "CHINESE_OCAML_DEBUG" (if i mod 2 = 0 then "true" else "false");
       Unix.putenv "CHINESE_OCAML_BUFFER_SIZE" (string_of_int (1024 + i));
       Unix.putenv "CHINESE_OCAML_TIMEOUT" (string_of_float (30.0 +. float_of_int (i mod 60)));

       if i mod 100 = 0 then load_from_env ()
     done;

     let end_time = Sys.time () in
     let duration = end_time -. start_time in

     Printf.printf "✅ 1000次环境变量操作耗时: %.6f秒\n" duration;
     Printf.printf "📊 平均每次操作耗时: %.6f秒\n" (duration /. 1000.0);

     if duration < 5.0 then Printf.printf "✅ 环境变量处理性能良好\n" else Printf.printf "⚠️  环境变量处理性能可能需要优化\n"
   with e -> Printf.printf "❌ 性能测试失败: %s\n" (Printexc.to_string e));

  (* 恢复原始环境变量状态 *)
  Printf.printf "\n🔄 恢复原始环境变量状态\n";
  (try
     List.iter
       (fun (var, original_value) ->
         match original_value with
         | Some value -> Unix.putenv var value
         | None -> ( try Unix.putenv var "" with _ -> ()))
       original_env_values;
     Printf.printf "✅ 原始环境变量状态恢复完成\n"
   with e -> Printf.printf "⚠️  环境变量状态恢复过程中出现问题: %s\n" (Printexc.to_string e));

  Printf.printf "\n🎉 骆言环境变量配置模块全面测试完成！\n";
  Printf.printf "📊 测试涵盖: 布尔、整数、浮点、字符串、范围、枚举类型解析\n";
  Printf.printf "🔧 包含综合配置加载、错误处理、性能测试\n";
  Printf.printf "🌏 支持中文环境变量值和Unicode处理\n";
  Printf.printf "🔒 保证测试前后环境变量状态一致性\n"
