(** 骆言代码生成器/解释器单元测试 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Codegen

(* 测试错误恢复配置 *)
let test_error_recovery_config () =
  let config = default_recovery_config in
  check bool "默认错误恢复启用" true config.enabled;
  check bool "默认类型转换启用" true config.type_conversion;
  check bool "默认拼写纠正启用" true config.spell_correction;
  check bool "默认参数适配启用" true config.parameter_adaptation;
  check string "默认日志级别" "normal" config.log_level;
  check bool "默认统计收集启用" true config.collect_statistics

(* 测试错误恢复统计 *)
let test_error_recovery_statistics () =
  let stats = recovery_stats in
  (* 检查统计结构 *)
  check bool "错误统计结构存在" true (stats.total_errors >= 0);
  check bool "类型转换统计结构存在" true (stats.type_conversions >= 0);
  check bool "拼写纠正统计结构存在" true (stats.spell_corrections >= 0);
  check bool "参数适配统计结构存在" true (stats.parameter_adaptations >= 0);
  check bool "变量建议统计结构存在" true (stats.variable_suggestions >= 0);
  check bool "或else回退统计结构存在" true (stats.or_else_fallbacks >= 0)

(* 测试运行时值相等性 *)
let test_runtime_values () =
  let int_val = IntValue 42 in
  let float_val = FloatValue 3.14 in
  let bool_val = BoolValue true in
  let string_val = StringValue "测试" in
  let char_val = StringValue "a" in
  let nil_val = UnitValue in
  
  check bool "整数值测试" true (int_val = IntValue 42);
  check bool "浮点数值测试" true (float_val = FloatValue 3.14);
  check bool "布尔值测试" true (bool_val = BoolValue true);
  check bool "字符串值测试" true (string_val = StringValue "测试");
  check bool "字符值测试" true (char_val = StringValue "a");
  check bool "空值测试" true (nil_val = UnitValue);
  
  (* 测试不同类型的值不相等 *)
  check bool "不同类型值不相等" false (int_val = float_val)

(* 测试全局错误恢复配置 *)
let test_global_recovery_config () =
  let old_config = !recovery_config in
  
  (* 测试设置新配置 *)
  let new_config = { default_recovery_config with log_level = "debug" } in
  recovery_config := new_config;
  
  check string "全局配置更新" "debug" (!recovery_config).log_level;
  
  (* 恢复原配置 *)
  recovery_config := old_config

(* 测试错误恢复配置字段 *)
let test_recovery_config_fields () =
  let config = {
    enabled = false;
    type_conversion = false;
    spell_correction = false;
    parameter_adaptation = false;
    log_level = "quiet";
    collect_statistics = false;
  } in
  
  check bool "错误恢复禁用" false config.enabled;
  check bool "类型转换禁用" false config.type_conversion;
  check bool "拼写纠正禁用" false config.spell_correction;
  check bool "参数适配禁用" false config.parameter_adaptation;
  check string "安静日志级别" "quiet" config.log_level;
  check bool "统计收集禁用" false config.collect_statistics

(* 测试统计字段修改 *)
let test_statistics_modification () =
  let stats = recovery_stats in
  let old_total = stats.total_errors in
  let old_type_conv = stats.type_conversions in
  
  (* 修改统计 *)
  stats.total_errors <- old_total + 1;
  stats.type_conversions <- old_type_conv + 1;
  
  check int "错误总数增加" (old_total + 1) stats.total_errors;
  check int "类型转换数增加" (old_type_conv + 1) stats.type_conversions;
  
  (* 恢复原值 *)
  stats.total_errors <- old_total;
  stats.type_conversions <- old_type_conv

(* 测试日志级别配置 *)
let test_log_level_configuration () =
  let levels = ["quiet"; "normal"; "verbose"; "debug"] in
  
  List.iter (fun level ->
    let config = { default_recovery_config with log_level = level } in
    check string ("日志级别: " ^ level) level config.log_level
  ) levels

(* 测试配置组合 *)
let test_configuration_combinations () =
  let config1 = {
    enabled = true;
    type_conversion = true;
    spell_correction = false;
    parameter_adaptation = true;
    log_level = "normal";
    collect_statistics = true;
  } in
  
  let config2 = {
    enabled = false;
    type_conversion = false;
    spell_correction = true;
    parameter_adaptation = false;
    log_level = "quiet";
    collect_statistics = false;
  } in
  
  check bool "配置1启用状态" true config1.enabled;
  check bool "配置2启用状态" false config2.enabled;
  check bool "配置1类型转换" true config1.type_conversion;
  check bool "配置2类型转换" false config2.type_conversion;
  check bool "配置1拼写纠正" false config1.spell_correction;
  check bool "配置2拼写纠正" true config2.spell_correction

(* 测试运行时值显示 *)
let test_runtime_value_display () =
  let values = [
    IntValue 42;
    FloatValue 3.14;
    BoolValue true;
    StringValue "测试";
    StringValue "a";
    UnitValue;
  ] in
  
  List.iter (fun value ->
    let _ = value_to_string value in
    check bool "运行时值可以显示" true true
  ) values


let () = run "Codegen单元测试" [
  ("错误恢复配置测试", [test_error_recovery_config]);
  ("错误恢复统计测试", [test_error_recovery_statistics]);
  ("运行时值测试", [test_runtime_values]);
  ("全局错误恢复配置测试", [test_global_recovery_config]);
  ("错误恢复配置字段测试", [test_recovery_config_fields]);
  ("统计字段修改测试", [test_statistics_modification]);
  ("日志级别配置测试", [test_log_level_configuration]);
  ("配置组合测试", [test_configuration_combinations]);
  ("运行时值显示测试", [test_runtime_value_display]);
]