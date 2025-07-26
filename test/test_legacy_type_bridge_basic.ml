(** 骆言编译器 - Legacy Type Bridge 基础测试
    
    针对PR #1356引入的Legacy Type Bridge模块进行基础测试，
    确保核心Token转换功能的正确性。
    
    @author Echo, 测试工程师专员
    @version 1.0
    @since 2025-07-26
    @issue #1355 Phase 2 Token系统整合 *)

open Alcotest

(** {1 基础Token转换测试} *)

(** 测试基础字面量转换函数 *)
let test_literal_conversions () =
  (* 测试整数Token转换 *)
  let int_token = Token_system_unified_conversion.Legacy_type_bridge.convert_int_token 42 in
  check bool "整数Token转换正确性" true 
    (match int_token with Token_system_unified_core.Token_types.IntToken 42 -> true | _ -> false);
  
  (* 测试浮点数Token转换 *)
  let float_token = Token_system_unified_conversion.Legacy_type_bridge.convert_float_token 3.14 in
  check bool "浮点数Token转换正确性" true
    (match float_token with Token_system_unified_core.Token_types.FloatToken 3.14 -> true | _ -> false);
  
  (* 测试字符串Token转换 *)
  let string_token = Token_system_unified_conversion.Legacy_type_bridge.convert_string_token "骆言" in
  check bool "字符串Token转换正确性" true
    (match string_token with Token_system_unified_core.Token_types.StringToken "骆言" -> true | _ -> false);
  
  (* 测试布尔Token转换 *)
  let bool_token = Token_system_unified_conversion.Legacy_type_bridge.convert_bool_token true in
  check bool "布尔Token转换正确性" true
    (match bool_token with Token_system_unified_core.Token_types.BoolToken true -> true | _ -> false)

(** 测试标识符转换函数 *)
let test_identifier_conversions () =
  (* 测试简单标识符转换 *)
  let simple_id = Token_system_unified_conversion.Legacy_type_bridge.convert_simple_identifier "测试变量" in
  check bool "简单标识符转换正确性" true
    (match simple_id with Token_system_unified_core.Token_types.SimpleIdentifier "测试变量" -> true | _ -> false);
  
  (* 测试引用标识符转换 *)
  let quoted_id = Token_system_unified_conversion.Legacy_type_bridge.convert_quoted_identifier "引用变量" in
  check bool "引用标识符转换正确性" true
    (match quoted_id with Token_system_unified_core.Token_types.QuotedIdentifierToken "引用变量" -> true | _ -> false)

(** 测试关键字转换函数 *)
let test_keyword_conversions () =
  (* 测试let关键字 *)
  let let_token = Token_system_unified_conversion.Legacy_type_bridge.convert_let_keyword () in
  check bool "let关键字转换正确性" true
    (match let_token with Token_system_unified_core.Token_types.LetKeyword -> true | _ -> false);
  
  (* 测试fun关键字 *)
  let fun_token = Token_system_unified_conversion.Legacy_type_bridge.convert_fun_keyword () in
  check bool "fun关键字转换正确性" true
    (match fun_token with Token_system_unified_core.Token_types.FunKeyword -> true | _ -> false);
  
  (* 测试if关键字 *)
  let if_token = Token_system_unified_conversion.Legacy_type_bridge.convert_if_keyword () in
  check bool "if关键字转换正确性" true
    (match if_token with Token_system_unified_core.Token_types.IfKeyword -> true | _ -> false)

(** 测试操作符转换函数 *)
let test_operator_conversions () =
  (* 测试加法操作符 *)
  let plus_op = Token_system_unified_conversion.Legacy_type_bridge.convert_plus_op () in
  check bool "加法操作符转换正确性" true
    (match plus_op with Token_system_unified_core.Token_types.Plus -> true | _ -> false);
  
  (* 测试减法操作符 *)
  let minus_op = Token_system_unified_conversion.Legacy_type_bridge.convert_minus_op () in
  check bool "减法操作符转换正确性" true
    (match minus_op with Token_system_unified_core.Token_types.Minus -> true | _ -> false)

(** 测试分隔符转换函数 *)
let test_delimiter_conversions () =
  (* 测试左括号 *)
  let left_paren = Token_system_unified_conversion.Legacy_type_bridge.convert_left_paren () in
  check bool "左括号转换正确性" true
    (match left_paren with Token_system_unified_core.Token_types.LeftParen -> true | _ -> false);
  
  (* 测试右括号 *)
  let right_paren = Token_system_unified_conversion.Legacy_type_bridge.convert_right_paren () in
  check bool "右括号转换正确性" true
    (match right_paren with Token_system_unified_core.Token_types.RightParen -> true | _ -> false);
  
  (* 测试逗号 *)
  let comma = Token_system_unified_conversion.Legacy_type_bridge.convert_comma () in
  check bool "逗号转换正确性" true
    (match comma with Token_system_unified_core.Token_types.Comma -> true | _ -> false)

(** 测试Token构造函数 *)
let test_token_construction () =
  (* 测试字面量Token构造 *)
  let int_literal = Token_system_unified_conversion.Legacy_type_bridge.convert_int_token 123 in
  let literal_token = Token_system_unified_conversion.Legacy_type_bridge.make_literal_token int_literal in
  check bool "字面量Token构造成功" true
    (Token_system_unified_conversion.Legacy_type_bridge.is_literal_token literal_token);
  
  (* 测试标识符Token构造 *)
  let simple_id = Token_system_unified_conversion.Legacy_type_bridge.convert_simple_identifier "test_var" in
  let identifier_token = Token_system_unified_conversion.Legacy_type_bridge.make_identifier_token simple_id in
  check bool "标识符Token构造成功" true
    (Token_system_unified_conversion.Legacy_type_bridge.is_identifier_token identifier_token);
  
  (* 测试操作符Token构造 *)
  let plus_op = Token_system_unified_conversion.Legacy_type_bridge.convert_plus_op () in
  let operator_token = Token_system_unified_conversion.Legacy_type_bridge.make_operator_token plus_op in
  check bool "操作符Token构造成功" true
    (Token_system_unified_conversion.Legacy_type_bridge.is_operator_token operator_token)

(** {1 测试套件定义} *)

let basic_conversion_tests = [
  test_case "字面量转换测试" `Quick test_literal_conversions;
  test_case "标识符转换测试" `Quick test_identifier_conversions;
  test_case "关键字转换测试" `Quick test_keyword_conversions;
  test_case "操作符转换测试" `Quick test_operator_conversions;
  test_case "分隔符转换测试" `Quick test_delimiter_conversions;
  test_case "Token构造测试" `Quick test_token_construction;
]

(** 运行所有基础测试 *)
let () =
  run "Legacy Type Bridge 基础测试套件 - PR #1356" [
    ("基础转换功能", basic_conversion_tests);
  ]