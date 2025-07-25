open Yyocamlc_lib.Compile_options

let () =
  Printf.printf "🧪 骆言编译选项模块全面测试开始\n\n";

  (* 测试默认编译选项 *)
  Printf.printf "📋 测试默认编译选项\n";
  (try
     let default_opts = default_options in

     Printf.printf "📊 默认编译选项详情:\n";
     Printf.printf "  - 显示词法单元: %b\n" default_opts.show_tokens;
     Printf.printf "  - 显示抽象语法树: %b\n" default_opts.show_ast;
     Printf.printf "  - 显示类型信息: %b\n" default_opts.show_types;
     Printf.printf "  - 仅检查模式: %b\n" default_opts.check_only;
     Printf.printf "  - 静默模式: %b\n" default_opts.quiet_mode;
     Printf.printf "  - 文件名: %s\n" (match default_opts.filename with Some f -> f | None -> "无");
     Printf.printf "  - 恢复模式: %b\n" default_opts.recovery_mode;
     Printf.printf "  - 日志级别: %s\n" default_opts.log_level;
     Printf.printf "  - 编译到C: %b\n" default_opts.compile_to_c;
     Printf.printf "  - C输出文件: %s\n"
       (match default_opts.c_output_file with Some f -> f | None -> "无");

     (* 验证默认选项的合理性 *)
     let is_reasonable =
       (not default_opts.show_tokens)
       (* 默认不显示tokens *)
       && (not default_opts.show_ast)
       (* 默认不显示AST *)
       && (not default_opts.check_only)
       (* 默认不是仅检查模式 *)
       && (not default_opts.quiet_mode)
       (* 默认不是静默模式 *)
       && default_opts.filename = None
       (* 默认没有指定文件名 *)
       && default_opts.recovery_mode
       (* 默认启用错误恢复 *)
       && String.length default_opts.log_level > 0
       (* 有有效的日志级别 *)
       && (not default_opts.compile_to_c)
       &&
       (* 默认不编译到C *)
       default_opts.c_output_file = None (* 默认没有C输出文件 *)
     in

     if is_reasonable then Printf.printf "✅ 默认编译选项合理性检查通过\n" else Printf.printf "⚠️  默认编译选项可能需要调整\n"
   with e -> Printf.printf "❌ 默认编译选项测试失败: %s\n" (Printexc.to_string e));

  (* 测试测试模式编译选项 *)
  Printf.printf "\n🧪 测试测试模式编译选项\n";
  (try
     let test_opts = test_options in

     Printf.printf "📊 测试模式编译选项详情:\n";
     Printf.printf "  - 显示词法单元: %b\n" test_opts.show_tokens;
     Printf.printf "  - 显示抽象语法树: %b\n" test_opts.show_ast;
     Printf.printf "  - 显示类型信息: %b\n" test_opts.show_types;
     Printf.printf "  - 仅检查模式: %b\n" test_opts.check_only;
     Printf.printf "  - 静默模式: %b\n" test_opts.quiet_mode;
     Printf.printf "  - 文件名: %s\n" (match test_opts.filename with Some f -> f | None -> "无");
     Printf.printf "  - 恢复模式: %b\n" test_opts.recovery_mode;
     Printf.printf "  - 日志级别: %s\n" test_opts.log_level;
     Printf.printf "  - 编译到C: %b\n" test_opts.compile_to_c;
     Printf.printf "  - C输出文件: %s\n"
       (match test_opts.c_output_file with Some f -> f | None -> "无");

     (* 验证测试选项的特点 *)
     let is_test_appropriate =
       test_opts.show_tokens
       (* 测试时通常显示tokens *)
       && test_opts.show_ast
       (* 测试时通常显示AST *)
       && test_opts.show_types
       (* 测试时通常显示类型 *)
       && (not test_opts.quiet_mode)
       &&
       (* 测试时不应该静默 *)
       test_opts.recovery_mode (* 测试时启用错误恢复 *)
     in

     if is_test_appropriate then Printf.printf "✅ 测试模式编译选项配置合理\n"
     else Printf.printf "⚠️  测试模式编译选项可能需要调整\n"
   with e -> Printf.printf "❌ 测试模式编译选项测试失败: %s\n" (Printexc.to_string e));

  (* 测试静默模式编译选项 *)
  Printf.printf "\n🔇 测试静默模式编译选项\n";
  (try
     let quiet_opts = quiet_options in

     Printf.printf "📊 静默模式编译选项详情:\n";
     Printf.printf "  - 显示词法单元: %b\n" quiet_opts.show_tokens;
     Printf.printf "  - 显示抽象语法树: %b\n" quiet_opts.show_ast;
     Printf.printf "  - 显示类型信息: %b\n" quiet_opts.show_types;
     Printf.printf "  - 仅检查模式: %b\n" quiet_opts.check_only;
     Printf.printf "  - 静默模式: %b\n" quiet_opts.quiet_mode;
     Printf.printf "  - 文件名: %s\n" (match quiet_opts.filename with Some f -> f | None -> "无");
     Printf.printf "  - 恢复模式: %b\n" quiet_opts.recovery_mode;
     Printf.printf "  - 日志级别: %s\n" quiet_opts.log_level;
     Printf.printf "  - 编译到C: %b\n" quiet_opts.compile_to_c;
     Printf.printf "  - C输出文件: %s\n"
       (match quiet_opts.c_output_file with Some f -> f | None -> "无");

     (* 验证静默选项的特点 *)
     let is_quiet_appropriate =
       (not quiet_opts.show_tokens)
       (* 静默时不显示tokens *)
       && (not quiet_opts.show_ast)
       (* 静默时不显示AST *)
       && (not quiet_opts.show_types)
       (* 静默时不显示类型 *)
       && quiet_opts.quiet_mode
       &&
       (* 必须是静默模式 *)
       String.equal quiet_opts.log_level "error"
       || String.equal quiet_opts.log_level "warn" (* 静默时日志级别较高 *)
     in

     if is_quiet_appropriate then Printf.printf "✅ 静默模式编译选项配置合理\n"
     else Printf.printf "⚠️  静默模式编译选项可能需要调整\n"
   with e -> Printf.printf "❌ 静默模式编译选项测试失败: %s\n" (Printexc.to_string e));

  (* 测试编译选项的字段访问 *)
  Printf.printf "\n🔍 测试编译选项字段访问\n";
  (try
     let opts = default_options in

     (* 测试所有字段的读取 *)
     let fields_test =
       [
         ("show_tokens", string_of_bool opts.show_tokens);
         ("show_ast", string_of_bool opts.show_ast);
         ("show_types", string_of_bool opts.show_types);
         ("check_only", string_of_bool opts.check_only);
         ("quiet_mode", string_of_bool opts.quiet_mode);
         ("filename", match opts.filename with Some f -> f | None -> "None");
         ("recovery_mode", string_of_bool opts.recovery_mode);
         ("log_level", opts.log_level);
         ("compile_to_c", string_of_bool opts.compile_to_c);
         ("c_output_file", match opts.c_output_file with Some f -> f | None -> "None");
       ]
     in

     Printf.printf "📋 所有字段访问测试:\n";
     List.iter
       (fun (field_name, field_value) -> Printf.printf "  ✅ %s: %s\n" field_name field_value)
       fields_test;

     Printf.printf "✅ 编译选项字段访问测试完成\n"
   with e -> Printf.printf "❌ 编译选项字段访问测试失败: %s\n" (Printexc.to_string e));

  (* 测试编译选项的修改（创建修改版本） *)
  Printf.printf "\n🔧 测试编译选项修改\n";
  (try
     let base_opts = default_options in

     (* 创建各种修改版本 *)
     let debug_opts =
       {
         base_opts with
         show_tokens = true;
         show_ast = true;
         show_types = true;
         log_level = "debug";
       }
     in

     let production_opts =
       {
         base_opts with
         quiet_mode = true;
         check_only = false;
         recovery_mode = false;
         log_level = "error";
       }
     in

     let c_compile_opts =
       {
         base_opts with
         compile_to_c = true;
         c_output_file = Some "output.c";
         filename = Some "input.ly";
       }
     in

     Printf.printf "📊 修改版本测试:\n";
     Printf.printf "  🐛 调试版本:\n";
     Printf.printf "    - 显示tokens: %b\n" debug_opts.show_tokens;
     Printf.printf "    - 显示AST: %b\n" debug_opts.show_ast;
     Printf.printf "    - 显示类型: %b\n" debug_opts.show_types;
     Printf.printf "    - 日志级别: %s\n" debug_opts.log_level;

     Printf.printf "  🚀 生产版本:\n";
     Printf.printf "    - 静默模式: %b\n" production_opts.quiet_mode;
     Printf.printf "    - 仅检查: %b\n" production_opts.check_only;
     Printf.printf "    - 恢复模式: %b\n" production_opts.recovery_mode;
     Printf.printf "    - 日志级别: %s\n" production_opts.log_level;

     Printf.printf "  🔧 C编译版本:\n";
     Printf.printf "    - 编译到C: %b\n" c_compile_opts.compile_to_c;
     Printf.printf "    - C输出文件: %s\n"
       (match c_compile_opts.c_output_file with Some f -> f | None -> "无");
     Printf.printf "    - 输入文件: %s\n"
       (match c_compile_opts.filename with Some f -> f | None -> "无");

     Printf.printf "✅ 编译选项修改测试完成\n"
   with e -> Printf.printf "❌ 编译选项修改测试失败: %s\n" (Printexc.to_string e));

  (* 测试编译选项的不同使用场景 *)
  Printf.printf "\n🎯 测试编译选项使用场景\n";
  (try
     Printf.printf "🧪 场景1: 语法检查模式\n";
     let syntax_check_opts =
       {
         default_options with
         check_only = true;
         show_ast = true;
         recovery_mode = true;
         log_level = "info";
       }
     in

     Printf.printf "  - 仅检查: %b\n" syntax_check_opts.check_only;
     Printf.printf "  - 显示AST: %b\n" syntax_check_opts.show_ast;
     Printf.printf "  - 恢复模式: %b\n" syntax_check_opts.recovery_mode;
     Printf.printf "  - 日志级别: %s\n" syntax_check_opts.log_level;

     Printf.printf "\n🧪 场景2: 词法分析模式\n";
     let lexer_debug_opts =
       {
         default_options with
         show_tokens = true;
         show_ast = false;
         show_types = false;
         log_level = "debug";
       }
     in

     Printf.printf "  - 显示tokens: %b\n" lexer_debug_opts.show_tokens;
     Printf.printf "  - 显示AST: %b\n" lexer_debug_opts.show_ast;
     Printf.printf "  - 显示类型: %b\n" lexer_debug_opts.show_types;
     Printf.printf "  - 日志级别: %s\n" lexer_debug_opts.log_level;

     Printf.printf "\n🧪 场景3: 类型推断调试\n";
     let type_debug_opts =
       {
         default_options with
         show_types = true;
         show_ast = true;
         check_only = true;
         log_level = "debug";
       }
     in

     Printf.printf "  - 显示类型: %b\n" type_debug_opts.show_types;
     Printf.printf "  - 显示AST: %b\n" type_debug_opts.show_ast;
     Printf.printf "  - 仅检查: %b\n" type_debug_opts.check_only;
     Printf.printf "  - 日志级别: %s\n" type_debug_opts.log_level;

     Printf.printf "\n🧪 场景4: 批量编译模式\n";
     let batch_compile_opts =
       {
         default_options with
         quiet_mode = true;
         recovery_mode = false;
         (* 批量时不恢复，快速失败 *)
         log_level = "warn";
         compile_to_c = true;
       }
     in

     Printf.printf "  - 静默模式: %b\n" batch_compile_opts.quiet_mode;
     Printf.printf "  - 恢复模式: %b\n" batch_compile_opts.recovery_mode;
     Printf.printf "  - 日志级别: %s\n" batch_compile_opts.log_level;
     Printf.printf "  - 编译到C: %b\n" batch_compile_opts.compile_to_c;

     Printf.printf "✅ 编译选项使用场景测试完成\n"
   with e -> Printf.printf "❌ 编译选项使用场景测试失败: %s\n" (Printexc.to_string e));

  (* 测试编译选项的验证逻辑 *)
  Printf.printf "\n🔍 测试编译选项验证逻辑\n";
  (try
     let validate_options opts =
       let errors = ref [] in

       (* 检查互斥选项 *)
       if opts.quiet_mode && (opts.show_tokens || opts.show_ast || opts.show_types) then
         errors := "静默模式与显示选项冲突" :: !errors;

       (* 检查C编译选项的一致性 *)
       if opts.compile_to_c && opts.check_only then errors := "编译到C模式与仅检查模式冲突" :: !errors;

       (* 检查输出文件设置 *)
       if opts.c_output_file <> None && not opts.compile_to_c then
         errors := "设置了C输出文件但未启用C编译" :: !errors;

       (* 检查日志级别 *)
       let valid_log_levels = [ "debug"; "info"; "warn"; "error" ] in
       if not (List.mem opts.log_level valid_log_levels) then
         errors := Printf.sprintf "无效的日志级别: %s" opts.log_level :: !errors;

       !errors
     in

     Printf.printf "🧪 验证合理的选项配置:\n";
     let valid_opts = default_options in
     let valid_errors = validate_options valid_opts in
     if valid_errors = [] then Printf.printf "✅ 默认选项配置验证通过\n"
     else Printf.printf "❌ 默认选项配置存在问题: %s\n" (String.concat "; " valid_errors);

     Printf.printf "\n🧪 验证冲突的选项配置:\n";
     let conflicted_opts =
       {
         default_options with
         quiet_mode = true;
         show_tokens = true;
         (* 与静默模式冲突 *)
         show_ast = true;
         (* 与静默模式冲突 *)
       }
     in
     let conflict_errors = validate_options conflicted_opts in
     if conflict_errors <> [] then
       Printf.printf "✅ 冲突配置正确被检测: %s\n" (String.concat "; " conflict_errors)
     else Printf.printf "⚠️  冲突配置未被检测到\n";

     Printf.printf "\n🧪 验证不一致的C编译配置:\n";
     let inconsistent_c_opts =
       {
         default_options with
         c_output_file = Some "output.c";
         compile_to_c = false;
         (* 不一致：设置了输出文件但未启用C编译 *)
       }
     in
     let inconsistent_errors = validate_options inconsistent_c_opts in
     if inconsistent_errors <> [] then
       Printf.printf "✅ 不一致C配置正确被检测: %s\n" (String.concat "; " inconsistent_errors)
     else Printf.printf "⚠️  不一致C配置未被检测到\n";

     Printf.printf "✅ 编译选项验证逻辑测试完成\n"
   with e -> Printf.printf "❌ 编译选项验证测试失败: %s\n" (Printexc.to_string e));

  (* 测试编译选项的序列化和比较 *)
  Printf.printf "\n📝 测试编译选项序列化和比较\n";
  (try
     let opts1 = default_options in
     let opts2 = default_options in
     let opts3 = { default_options with show_tokens = true } in

     (* 简单的选项比较函数 *)
     let compare_options o1 o2 =
       o1.show_tokens = o2.show_tokens && o1.show_ast = o2.show_ast && o1.show_types = o2.show_types
       && o1.check_only = o2.check_only && o1.quiet_mode = o2.quiet_mode
       && o1.filename = o2.filename
       && o1.recovery_mode = o2.recovery_mode
       && String.equal o1.log_level o2.log_level
       && o1.compile_to_c = o2.compile_to_c
       && o1.c_output_file = o2.c_output_file
     in

     (* 选项序列化函数 *)
     let serialize_options opts =
       Printf.sprintf
         "{show_tokens=%b; show_ast=%b; show_types=%b; check_only=%b; quiet_mode=%b; filename=%s; \
          recovery_mode=%b; log_level=%s; compile_to_c=%b; c_output_file=%s}"
         opts.show_tokens opts.show_ast opts.show_types opts.check_only opts.quiet_mode
         (match opts.filename with Some f -> f | None -> "None")
         opts.recovery_mode opts.log_level opts.compile_to_c
         (match opts.c_output_file with Some f -> f | None -> "None")
     in

     Printf.printf "🧪 选项比较测试:\n";
     Printf.printf "  - opts1 == opts2: %b\n" (compare_options opts1 opts2);
     Printf.printf "  - opts1 == opts3: %b\n" (compare_options opts1 opts3);

     Printf.printf "\n📋 选项序列化测试:\n";
     Printf.printf "  - 默认选项: %s\n" (serialize_options opts1);
     Printf.printf "  - 修改选项: %s\n" (serialize_options opts3);

     if compare_options opts1 opts2 && not (compare_options opts1 opts3) then
       Printf.printf "✅ 编译选项比较和序列化测试通过\n"
     else Printf.printf "❌ 编译选项比较测试失败\n"
   with e -> Printf.printf "❌ 编译选项序列化测试失败: %s\n" (Printexc.to_string e));

  (* 性能测试：编译选项操作 *)
  Printf.printf "\n⚡ 编译选项性能测试\n";
  (try
     let start_time = Sys.time () in

     (* 大量编译选项创建和访问操作 *)
     for i = 1 to 10000 do
       let opts =
         if i mod 3 = 0 then test_options
         else if i mod 3 = 1 then quiet_options
         else default_options
       in

       (* 访问所有字段 *)
       let _ = opts.show_tokens in
       let _ = opts.show_ast in
       let _ = opts.show_types in
       let _ = opts.check_only in
       let _ = opts.quiet_mode in
       let _ = opts.filename in
       let _ = opts.recovery_mode in
       let _ = opts.log_level in
       let _ = opts.compile_to_c in
       let _ = opts.c_output_file in

       (* 创建修改版本 *)
       let _ = { opts with show_tokens = not opts.show_tokens } in
       ()
     done;

     let end_time = Sys.time () in
     let duration = end_time -. start_time in

     Printf.printf "✅ 10000次编译选项操作耗时: %.6f秒\n" duration;
     Printf.printf "📊 平均每次操作耗时: %.6f秒\n" (duration /. 10000.0);

     if duration < 0.5 then Printf.printf "✅ 编译选项操作性能优秀\n" else Printf.printf "⚠️  编译选项操作性能可能需要优化\n"
   with e -> Printf.printf "❌ 编译选项性能测试失败: %s\n" (Printexc.to_string e));

  Printf.printf "\n🎉 骆言编译选项模块全面测试完成！\n";
  Printf.printf "📊 测试涵盖: 默认选项、测试选项、静默选项、字段访问、选项修改\n";
  Printf.printf "🔧 包含使用场景测试、验证逻辑、序列化比较、性能测试\n";
  Printf.printf "🎯 支持多种编译模式: 调试、生产、语法检查、词法分析、类型推断\n";
  Printf.printf "⚖️ 验证选项配置的合理性和一致性\n"
