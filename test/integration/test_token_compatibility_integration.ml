(** 骆言编译器 - Token兼容性集成测试
    
    针对Issue #1357中Delta专员指出的向后兼容性保证不足问题，
    验证legacy Token系统向新统一Token系统的集成工作。
    
    @author Echo, 测试工程师
    @version 1.0
    @since 2025-07-26
    @issue #1357 *)

open Alcotest

(* Token stream utility for potential future use *)

(** {1 Token流兼容性测试} *)

(** 测试简单Token流的兼容性转换 *)
let test_simple_token_stream_compatibility () =
  (* 创建一个简单的Token流 *)
  let tokens = [
    Token_system_compatibility.Legacy_type_bridge.make_literal_token 
      (Token_system_compatibility.Legacy_type_bridge.convert_int_token 1);
    Token_system_compatibility.Legacy_type_bridge.make_operator_token 
      (Token_system_compatibility.Legacy_type_bridge.convert_plus_op ());
    Token_system_compatibility.Legacy_type_bridge.make_literal_token 
      (Token_system_compatibility.Legacy_type_bridge.convert_int_token 2);
  ] in
  
  (* 验证每个Token的兼容性 *)
  check int "token stream length" 3 (List.length tokens);
  
  (* 验证Token类型检查工作正常 *)
  let first_token = List.hd tokens in
  check bool "first token is literal" true 
    (Token_system_compatibility.Legacy_type_bridge.is_literal_token first_token);
  
  let second_token = List.nth tokens 1 in
  check bool "second token is operator" true 
    (Token_system_compatibility.Legacy_type_bridge.is_operator_token second_token)

(** 测试批量Token创建兼容性 *)
let test_batch_token_creation_compatibility () =
  (* 测试批量字面量Token创建 *)
  let literal_values = [
    ("int1", `Int 1);
    ("int2", `Int 2);
    ("str1", `String "hello");
    ("bool1", `Bool true);
  ] in
  
  let literal_tokens = Token_system_compatibility.Legacy_type_bridge.make_literal_tokens literal_values in
  check int "batch literal tokens count" 4 (List.length literal_tokens);
  
  (* 测试批量标识符Token创建 *)
  let identifier_names = ["var1"; "var2"; "function_name"] in
  let identifier_tokens = Token_system_compatibility.Legacy_type_bridge.make_identifier_tokens identifier_names in
  check int "batch identifier tokens count" 3 (List.length identifier_tokens)

(** 测试Token流验证兼容性 *)
let test_token_stream_validation_compatibility () =
  (* 创建有效的Token流 *)
  let valid_tokens = [
    Token_system_compatibility.Legacy_type_bridge.make_literal_token 
      (Token_system_compatibility.Legacy_type_bridge.convert_int_token 42);
    Token_system_compatibility.Legacy_type_bridge.make_special_token 
      (Token_system_compatibility.Legacy_type_bridge.convert_eof ());
  ] in
  
  (* 验证Token流有效性 *)
  check bool "valid token stream" true 
    (Token_system_compatibility.Legacy_type_bridge.validate_token_stream valid_tokens);
  
  (* 测试空Token流 *)
  check bool "empty token stream valid" true 
    (Token_system_compatibility.Legacy_type_bridge.validate_token_stream [])

(** 测试Token类型统计兼容性 *)
let test_token_type_counting_compatibility () =
  let mixed_tokens = [
    Token_system_compatibility.Legacy_type_bridge.make_literal_token 
      (Token_system_compatibility.Legacy_type_bridge.convert_int_token 1);
    Token_system_compatibility.Legacy_type_bridge.make_literal_token 
      (Token_system_compatibility.Legacy_type_bridge.convert_int_token 2);
    Token_system_compatibility.Legacy_type_bridge.make_identifier_token 
      (Token_system_compatibility.Legacy_type_bridge.convert_simple_identifier "x");
    Token_system_compatibility.Legacy_type_bridge.make_operator_token 
      (Token_system_compatibility.Legacy_type_bridge.convert_plus_op ());
  ] in
  
  let counts = Token_system_compatibility.Legacy_type_bridge.count_token_types mixed_tokens in
  
  (* 查找特定类型的计数 *)
  let find_count type_name =
    try List.assoc type_name counts
    with Not_found -> 0
  in
  
  check int "literal count" 2 (find_count "Literal");
  check int "identifier count" 1 (find_count "Identifier");
  check int "operator count" 1 (find_count "Operator")

(** {1 位置信息兼容性测试} *)

(** 测试带位置信息的Token兼容性 *)
let test_positioned_token_compatibility () =
  let token = Token_system_compatibility.Legacy_type_bridge.make_literal_token 
    (Token_system_compatibility.Legacy_type_bridge.convert_int_token 42) in
  let position = Token_system_compatibility.Legacy_type_bridge.make_position 
    ~line:1 ~column:1 ~offset:0 in
  let positioned_token = Token_system_compatibility.Legacy_type_bridge.make_positioned_token 
    ~token ~position ~text:"42" in
  
  check int "positioned token line" 1 positioned_token.Token_system_core.Token_types.position.line;
  check int "positioned token column" 1 positioned_token.Token_system_core.Token_types.position.column;
  check int "positioned token offset" 0 positioned_token.Token_system_core.Token_types.position.offset;
  check string "positioned token text" "42" positioned_token.Token_system_core.Token_types.text

(** {1 实验性功能兼容性测试} *)

(** 测试Token推断功能兼容性 *)
let test_token_inference_compatibility () =
  (* 测试数字推断 *)
  (match Token_system_compatibility.Legacy_type_bridge.infer_token_from_string "123" with
   | Some token -> 
     check bool "inferred number is literal" true 
       (Token_system_compatibility.Legacy_type_bridge.is_literal_token token)
   | None -> fail "Failed to infer integer token");
  
  (* 测试关键字推断 *)
  (match Token_system_compatibility.Legacy_type_bridge.infer_token_from_string "let" with
   | Some token -> 
     check bool "inferred let is keyword" true 
       (Token_system_compatibility.Legacy_type_bridge.is_keyword_token token)
   | None -> fail "Failed to infer keyword token");
   
  (* 测试标识符推断 *)
  (match Token_system_compatibility.Legacy_type_bridge.infer_token_from_string "variable" with
   | Some token -> 
     check bool "inferred variable is identifier" true 
       (Token_system_compatibility.Legacy_type_bridge.is_identifier_token token)
   | None -> fail "Failed to infer identifier token")

(** {1 性能兼容性测试} *)

(** 测试大规模Token处理性能 *)
let test_large_scale_token_processing () =
  let start_time = Sys.time () in
  
  (* 创建大量Token *)
  let large_token_list = 
    List.init 1000 (fun i ->
      Token_system_compatibility.Legacy_type_bridge.make_literal_token 
        (Token_system_compatibility.Legacy_type_bridge.convert_int_token i)
    ) in
  
  (* 验证所有Token *)
  let all_valid = Token_system_compatibility.Legacy_type_bridge.validate_token_stream large_token_list in
  
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  
  check bool "large token stream valid" true all_valid;
  check bool "processing time reasonable" true (duration < 1.0) (* 应该在1秒内完成 *)

(** {1 测试套件定义} *)

let token_stream_tests = [
  test_case "simple_token_stream_compatibility" `Quick test_simple_token_stream_compatibility;
  test_case "batch_token_creation_compatibility" `Quick test_batch_token_creation_compatibility;
  test_case "token_stream_validation_compatibility" `Quick test_token_stream_validation_compatibility;
  test_case "token_type_counting_compatibility" `Quick test_token_type_counting_compatibility;
]

let position_tests = [
  test_case "positioned_token_compatibility" `Quick test_positioned_token_compatibility;
]

let experimental_tests = [
  test_case "token_inference_compatibility" `Quick test_token_inference_compatibility;
]

let performance_tests = [
  test_case "large_scale_token_processing" `Quick test_large_scale_token_processing;
]

(** 运行所有集成测试 *)
let () =
  run "Token Compatibility Integration Tests" [
    ("Token Stream Processing", token_stream_tests);
    ("Position Information", position_tests);
    ("Experimental Features", experimental_tests);
    ("Performance Compatibility", performance_tests);
  ]