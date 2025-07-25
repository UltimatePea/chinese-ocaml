(** 骆言Token系统整合重构 - 测试工具模块 
    用于支持Token模块整合测试的公共工具和辅助函数 *)

open Tokens

(** Token测试辅助模块 *)
module TokenTestUtils = struct
  (** 检查两个Token是否相等 *)
  let assert_token_equal ~expected ~actual msg =
    Alcotest.(check bool) msg true (Unified_tokens.equal_token expected actual)

  (** 检查两个Token不相等 *)
  let assert_token_not_equal ~left ~right msg =
    Alcotest.(check bool) msg false (Unified_tokens.equal_token left right)

  (** 检查Token列表相等性 *)
  let assert_token_list_equal ~expected ~actual msg =
    let equal_lists l1 l2 =
      List.length l1 = List.length l2 &&
      List.for_all2 Unified_tokens.equal_token l1 l2
    in
    Alcotest.(check bool) msg true (equal_lists expected actual)

  (** 检查位置信息相等 *)
  let assert_position_equal ~expected ~actual msg =
    let equal_pos p1 p2 =
      p1.Unified_tokens.line = p2.Unified_tokens.line &&
      p1.Unified_tokens.column = p2.Unified_tokens.column &&
      p1.Unified_tokens.filename = p2.Unified_tokens.filename
    in
    Alcotest.(check bool) msg true (equal_pos expected actual)

  (** 性能测试计时器 *)
  let time_function f =
    let start_time = Sys.time () in
    let result = f () in
    let end_time = Sys.time () in
    (end_time -. start_time, result)

  (** 简单内存使用估算 *)
  let measure_memory_usage f =
    Gc.compact ();
    let stat_before = Gc.stat () in
    let result = f () in
    Gc.compact ();
    let stat_after = Gc.stat () in
    let memory_used = stat_after.live_words - stat_before.live_words in
    (memory_used, result)
end

(** Token数据生成器模块 *)
module TokenDataGenerator = struct
  open Unified_tokens

  (** 生成基础关键字Token测试数据 *)
  let generate_keyword_tokens () =
    [
      make_let_keyword ();
      make_if_keyword ();
      make_then_keyword ();
      make_else_keyword ();
    ]

  (** 生成字面量Token测试数据 *)
  let generate_literal_tokens () =
    [
      make_int_token 42;
      make_int_token 0;
      make_int_token (-123);
      make_float_token 3.14159;
      make_float_token 0.0;
      make_float_token (-2.71828);
      make_string_token "你好世界";
      make_string_token "";
      make_string_token "Hello, 骆言!";
      make_bool_token true;
      make_bool_token false;
    ]

  (** 生成操作符Token测试数据 *)
  let generate_operator_tokens () =
    [
      make_plus_op ();
      make_minus_op ();
      make_multiply_op ();
      make_divide_op ();
      make_equal_op ();
      make_assign_op ();
    ]

  (** 生成分隔符Token测试数据 *)
  let generate_delimiter_tokens () =
    [
      make_left_paren ();
      make_right_paren ();
      make_left_bracket ();
      make_right_bracket ();
      make_comma ();
      make_semicolon ();
    ]

  (** 生成标识符Token测试数据 *)
  let generate_identifier_tokens () =
    [
      make_quoted_identifier "变量名";
      make_quoted_identifier "函数名";
      make_special_identifier "求和";
      make_special_identifier "处理数据";
    ]

  (** 生成文言文Token测试数据 - 简化版 *)
  let generate_wenyan_tokens () = []

  (** 生成自然语言Token测试数据 - 简化版 *)
  let generate_natural_language_tokens () = []

  (** 生成诗词Token测试数据 - 简化版 *)
  let generate_poetry_tokens () = []

  (** 生成所有类型的Token测试数据 *)
  let generate_all_tokens () =
    List.concat [
      generate_keyword_tokens ();
      generate_literal_tokens ();
      generate_operator_tokens ();
      generate_delimiter_tokens ();
      generate_identifier_tokens ();
      generate_wenyan_tokens ();
      generate_natural_language_tokens ();
      generate_poetry_tokens ();
    ]

  (** 生成边界情况和特殊Token测试数据 *)
  let generate_edge_case_tokens () =
    [
      (* 空字符串 *)
      make_string_token "";
      (* 超长字符串 *)
      make_string_token (String.make 100 'a');
      (* 极大数字 *)
      make_int_token max_int;
      (* 极小数字 *)
      make_int_token min_int;
      (* 特殊浮点数 *)
      make_float_token nan;
      make_float_token infinity;
      make_float_token neg_infinity;
      (* 包含特殊字符的标识符 *)
      make_quoted_identifier "变量_123";
      make_quoted_identifier "函数名称";
    ]
end

(** Token分类测试辅助模块 *)
module TokenClassificationUtils = struct
  open Unified_tokens

  (** 检查Token是否为关键字 *)
  let is_keyword = function
    | Keyword _ -> true
    | _ -> false

  (** 检查Token是否为字面量 *)
  let is_literal = function
    | Literal _ -> true
    | _ -> false

  (** 检查Token是否为操作符 *)
  let is_operator = function
    | Operator _ -> true
    | _ -> false

  (** 检查Token是否为分隔符 *)
  let is_delimiter = function
    | Delimiter _ -> true
    | _ -> false

  (** 检查Token是否为标识符 *)
  let is_identifier = function
    | Identifier _ -> true
    | _ -> false

  (** 检查Token是否为文言文Token *)
  let is_wenyan = function
    | Wenyan _ -> true
    | _ -> false

  (** 检查Token是否为自然语言Token *)
  let is_natural_language = function
    | NaturalLanguage _ -> true
    | _ -> false

  (** 检查Token是否为诗词Token *)
  let is_poetry = function
    | Poetry _ -> true
    | _ -> false

  (** 获取Token类型名称 *)
  let get_token_type_name = function
    | Keyword _ -> "关键字"
    | Literal _ -> "字面量"
    | Operator _ -> "操作符"
    | Delimiter _ -> "分隔符"
    | Identifier _ -> "标识符"
    | Wenyan _ -> "文言文"
    | NaturalLanguage _ -> "自然语言"
    | Poetry _ -> "诗词"
end

(** Token性能测试辅助模块 *)
module TokenPerformanceUtils = struct
  (** 批量Token创建性能测试 *)
  let benchmark_token_creation count generator =
    let (elapsed_time, tokens) = TokenTestUtils.time_function (fun () ->
      let rec create_tokens n acc =
        if n <= 0 then acc
        else create_tokens (n-1) (generator () @ acc)
      in
      create_tokens count []
    ) in
    (elapsed_time, List.length tokens)

  (** Token序列化性能测试 *)
  let benchmark_token_serialization tokens =
    TokenTestUtils.time_function (fun () ->
      List.map Unified_tokens.token_to_string tokens
    )

  (** Token相等性比较性能测试 *)
  let benchmark_token_equality_comparison tokens =
    let token_pairs = List.map (fun t -> (t, t)) tokens in
    TokenTestUtils.time_function (fun () ->
      List.map (fun (t1, t2) -> Unified_tokens.equal_token t1 t2) token_pairs
    )

  (** 内存使用测试 *)
  let benchmark_token_memory_usage count generator =
    TokenTestUtils.measure_memory_usage (fun () ->
      let rec create_tokens n acc =
        if n <= 0 then acc
        else create_tokens (n-1) (generator () @ acc)
      in
      create_tokens count []
    )
end