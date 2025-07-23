(** 骆言编译器核心格式化模块测试 - 测试各个格式化子模块的功能 *)

open Alcotest
open Yyocamlc_lib.Formatter_core

(** 帮助函数：检查字符串是否包含子字符串 *)
let contains_substring s sub = 
  try 
    let _ = Str.search_forward (Str.regexp_string sub) s 0 in 
    true
  with Not_found -> false

(** 测试通用格式化工具模块 *)
module Test_General = struct
  (** 测试标识符格式化 *)
  let test_format_identifier () =
    let result = General.format_identifier "变量名" in
    check string "标识符格式化" "「变量名」" result;
    
    let empty_result = General.format_identifier "" in
    check string "空标识符格式化" "「」" empty_result;
    
    let special_chars = General.format_identifier "测试_123" in
    check string "特殊字符标识符格式化" "「测试_123」" special_chars

  (** 测试函数签名格式化 *)
  let test_format_function_signature () =
    let result = General.format_function_signature "测试函数" ["参数1"; "参数2"] in
    check bool "函数签名包含函数名" true (contains_substring result "测试函数");
    check bool "函数签名包含参数1" true (contains_substring result "参数1");
    check bool "函数签名包含参数2" true (contains_substring result "参数2");
    
    let no_params = General.format_function_signature "无参函数" [] in
    check bool "无参函数签名包含函数名" true (contains_substring no_params "无参函数")

  (** 测试类型签名格式化 *)
  let test_format_type_signature () =
    let result = General.format_type_signature "List" ["int"; "string"] in
    check string "类型签名格式化" "List<int, string>" result;
    
    let single_param = General.format_type_signature "Option" ["int"] in
    check string "单参数类型签名" "Option<int>" single_param;
    
    let no_params = General.format_type_signature "Unit" [] in
    check string "无参数类型签名" "Unit<>" no_params

  (** 测试模块路径格式化 *)
  let test_format_module_path () =
    let result = General.format_module_path ["A"; "B"; "C"] in
    check string "模块路径格式化" "A.B.C" result;
    
    let single_module = General.format_module_path ["单模块"] in
    check string "单模块路径" "单模块" single_module;
    
    let empty_path = General.format_module_path [] in
    check string "空模块路径" "" empty_path

  (** 测试列表格式化 *)
  let test_format_list () =
    let result = General.format_list ["a"; "b"; "c"] ", " in
    check string "逗号分隔列表" "a, b, c" result;
    
    let chinese_list = General.format_list ["甲"; "乙"; "丙"] "、" in
    check string "中文分隔列表" "甲、乙、丙" chinese_list;
    
    let single_item = General.format_list ["单项"] ", " in
    check string "单项列表" "单项" single_item;
    
    let empty_list = General.format_list [] ", " in
    check string "空列表" "" empty_list

  (** 测试键值对格式化 *)
  let test_format_key_value () =
    let result = General.format_key_value "键" "值" in
    check bool "键值对包含键" true (contains_substring result "键");
    check bool "键值对包含值" true (contains_substring result "值")

  (** 测试中文列表格式化 *)
  let test_format_chinese_list () =
    let result = General.format_chinese_list ["第一"; "第二"; "第三"] in
    check string "中文列表格式化" "第一、第二、第三" result;
    
    let single_chinese = General.format_chinese_list ["唯一"] in
    check string "单项中文列表" "唯一" single_chinese

  (** 测试变量定义格式化 *)
  let test_format_variable_definition () =
    let result = General.format_variable_definition "计数器" in
    check string "变量定义格式化" "让 「计数器」 = 值" result;
    
    let empty_var = General.format_variable_definition "" in
    check string "空变量名定义" "让 「」 = 值" empty_var

  (** 测试上下文信息格式化 *)
  let test_format_context_info () =
    let result = General.format_context_info 5 "变量" in
    check string "上下文信息格式化" "当前作用域中有 5 个可用变量" result;
    
    let zero_count = General.format_context_info 0 "函数" in
    check string "零数量上下文信息" "当前作用域中有 0 个可用函数" zero_count

  (** 测试扩展格式化功能 *)
  let test_extended_formatting () =
    let range_result = General.format_range 1 10 in
    check string "范围格式化" "1..10" range_result;
    
    let percentage_result = General.format_percentage 75.5 in
    check string "百分比格式化" "75.5%" percentage_result;
    
    let size_result = General.format_size_info 1024 in
    check string "大小信息格式化" "1024 字节" size_result;
    
    let duration_ms_result = General.format_duration_ms 500 in
    check string "毫秒时长格式化" "500ms" duration_ms_result;
    
    let duration_sec_result = General.format_duration_sec 2.5 in
    check string "秒时长格式化" "2.5秒" duration_sec_result
end

(** 测试集合操作格式化模块 *)
module Test_Collections = struct
  (** 测试数组索引越界 *)
  let test_index_out_of_bounds () =
    let result = Collections.index_out_of_bounds 5 3 in
    check bool "索引越界包含索引值" true (contains_substring result "5");
    check bool "索引越界包含长度值" true (contains_substring result "3")

  (** 测试数组访问错误 *)
  let test_array_access_error () =
    let result = Collections.array_access_error "测试数组" 10 in
    check bool "数组访问错误包含数组名" true (contains_substring result "测试数组");
    check bool "数组访问错误包含索引" true (contains_substring result "10")

  (** 测试数组边界错误 *)
  let test_array_bounds_error () =
    let result = Collections.array_bounds_error 8 5 in
    check bool "数组边界错误包含索引" true (contains_substring result "8");
    check bool "数组边界错误包含长度" true (contains_substring result "5")

  (** 测试列表操作错误 *)
  let test_list_operation_error () =
    let result = Collections.list_operation_error "头部访问" in
    check bool "列表操作错误包含操作名" true (contains_substring result "头部访问")

  (** 测试扩展集合错误处理 *)
  let test_extended_collection_errors () =
    let empty_error = Collections.empty_collection_error "列表" "获取首元素" in
    check bool "空集合错误包含集合类型" true (contains_substring empty_error "列表");
    check bool "空集合错误包含操作" true (contains_substring empty_error "获取首元素");
    
    let mismatch_error = Collections.collection_size_mismatch 5 8 in
    check bool "大小不匹配错误包含期望值" true (contains_substring mismatch_error "5");
    check bool "大小不匹配错误包含实际值" true (contains_substring mismatch_error "8");
    
    let info_result = Collections.format_collection_info "数组" 10 100 in
    check bool "集合信息包含类型" true (contains_substring info_result "数组");
    check bool "集合信息包含当前数量" true (contains_substring info_result "10");
    check bool "集合信息包含总容量" true (contains_substring info_result "100")
end

(** 测试转换格式化模块 *)
module Test_Conversions = struct
  (** 测试类型转换表达式 *)
  let test_type_conversion () =
    let result = Conversions.type_conversion "int" "string" in
    check bool "类型转换包含源类型" true (contains_substring result "int");
    check bool "类型转换包含目标类型" true (contains_substring result "string")

  (** 测试类型转换错误 *)
  let test_casting_error () =
    let result = Conversions.casting_error "float" "boolean" in
    check bool "转换错误包含源类型" true (contains_substring result "float");
    check bool "转换错误包含目标类型" true (contains_substring result "boolean")

  (** 测试扩展转换功能 *)
  let test_extended_conversions () =
    let attempt_result = Conversions.format_conversion_attempt "123" "int" in
    check bool "转换尝试包含值" true (contains_substring attempt_result "123");
    check bool "转换尝试包含类型" true (contains_substring attempt_result "int");
    
    let success_result = Conversions.format_conversion_success "123" "string" "int" in
    check bool "转换成功包含原值" true (contains_substring success_result "123");
    check bool "转换成功包含源类型" true (contains_substring success_result "string");
    check bool "转换成功包含目标类型" true (contains_substring success_result "int");
    
    let failure_result = Conversions.format_conversion_failure "abc" "string" "int" in
    check bool "转换失败包含原值" true (contains_substring failure_result "abc");
    check bool "转换失败包含源类型" true (contains_substring failure_result "string");
    check bool "转换失败包含目标类型" true (contains_substring failure_result "int")
end

let () =
  
  (* 测试套件 *)
  run "骆言核心格式化模块测试"
    [
      ( "通用格式化工具",
        [
          test_case "标识符格式化" `Quick Test_General.test_format_identifier;
          test_case "函数签名格式化" `Quick Test_General.test_format_function_signature;
          test_case "类型签名格式化" `Quick Test_General.test_format_type_signature;
          test_case "模块路径格式化" `Quick Test_General.test_format_module_path;
          test_case "列表格式化" `Quick Test_General.test_format_list;
          test_case "键值对格式化" `Quick Test_General.test_format_key_value;
          test_case "中文列表格式化" `Quick Test_General.test_format_chinese_list;
          test_case "变量定义格式化" `Quick Test_General.test_format_variable_definition;
          test_case "上下文信息格式化" `Quick Test_General.test_format_context_info;
          test_case "扩展格式化功能" `Quick Test_General.test_extended_formatting;
        ] );
      ( "集合操作格式化",
        [
          test_case "数组索引越界" `Quick Test_Collections.test_index_out_of_bounds;
          test_case "数组访问错误" `Quick Test_Collections.test_array_access_error;
          test_case "数组边界错误" `Quick Test_Collections.test_array_bounds_error;
          test_case "列表操作错误" `Quick Test_Collections.test_list_operation_error;
          test_case "扩展集合错误处理" `Quick Test_Collections.test_extended_collection_errors;
        ] );
      ( "转换格式化",
        [
          test_case "类型转换表达式" `Quick Test_Conversions.test_type_conversion;
          test_case "类型转换错误" `Quick Test_Conversions.test_casting_error;
          test_case "扩展转换功能" `Quick Test_Conversions.test_extended_conversions;
        ] );
    ]