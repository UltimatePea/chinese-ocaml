(** 骆言核心令牌类型系统综合测试套件 - Issue #946 第二阶段令牌核心操作测试补强 *)

open Alcotest
open Yyocamlc_lib.Token_types_core

(** 测试辅助函数 *)
module TestUtils = struct
  (** 检查令牌是否相等 *)
  let check_token_equal desc expected actual =
    check bool desc true (compare expected actual = 0)
  
  (** 检查令牌不相等 *)
  let check_token_not_equal desc left right =
    check bool desc false (compare left right = 0)
  
  (** 检查位置信息是否相等 *)
  let check_position_equal desc expected actual =
    check bool desc true (
      expected.line = actual.line &&
      expected.column = actual.column &&
      expected.offset = actual.offset &&
      String.equal expected.filename actual.filename
    )
  
  (** 检查元数据是否相等 *)
  let check_metadata_equal desc expected actual =
    match expected, actual with
    | None, None -> check bool desc true true
    | Some e, Some a -> 
        check bool desc true (
          e.category = a.category &&
          e.priority = a.priority &&
          String.equal e.description a.description &&
          e.deprecated = a.deprecated
        )
    | _ -> check bool desc false true
end

(** 令牌优先级测试 *)
module TokenPriorityTests = struct
  (** 测试令牌优先级定义 *)
  let test_priority_definitions () =
    let high_priority = HighPriority in
    let medium_priority = MediumPriority in
    let low_priority = LowPriority in
    
    (* 测试优先级自身相等 *)
    check bool "高优先级自身相等" true (high_priority = high_priority);
    check bool "中优先级自身相等" true (medium_priority = medium_priority);
    check bool "低优先级自身相等" true (low_priority = low_priority);
    
    (* 测试不同优先级不等 *)
    check bool "高中优先级不等" false (high_priority = medium_priority);
    check bool "中低优先级不等" false (medium_priority = low_priority);
    check bool "高低优先级不等" false (high_priority = low_priority)
  
  (** 测试优先级在元数据中的使用 *)
  let test_priority_in_metadata () =
    let high_meta = {
      category = Keyword;
      priority = HighPriority;
      description = "高优先级关键字";
      chinese_name = Some "关键字";
      aliases = ["keyword"];
      deprecated = false;
    } in
    
    let low_meta = {
      category = Identifier;
      priority = LowPriority;
      description = "低优先级标识符";
      chinese_name = Some "标识符";
      aliases = ["identifier"];
      deprecated = false;
    } in
    
    check bool "元数据高优先级设置正确" true (high_meta.priority = HighPriority);
    check bool "元数据低优先级设置正确" true (low_meta.priority = LowPriority);
    check bool "不同优先级元数据不等" false (high_meta.priority = low_meta.priority)
end

(** 令牌分类测试 *)
module TokenCategoryTests = struct
  (** 测试令牌分类定义 *)
  let test_category_definitions () =
    let categories = [Literal; Identifier; Keyword; Operator; Delimiter; Special] in
    
    (* 测试分类自身相等 *)
    List.iter (fun cat ->
      check bool (Printf.sprintf "分类%s自身相等" (match cat with
        | Literal -> "字面量"
        | Identifier -> "标识符"
        | Keyword -> "关键字"
        | Operator -> "操作符"
        | Delimiter -> "分隔符"
        | Special -> "特殊")) true (cat = cat)
    ) categories;
    
    (* 测试不同分类不等 *)
    check bool "字面量与标识符分类不等" false (Literal = Identifier);
    check bool "关键字与操作符分类不等" false (Keyword = Operator);
    check bool "分隔符与特殊分类不等" false (Delimiter = Special)
  
  (** 测试分类在元数据中的应用 *)
  let test_category_in_metadata () =
    let test_cases = [
      (Literal, "字面量");
      (Identifier, "标识符");
      (Keyword, "关键字");
      (Operator, "操作符");
      (Delimiter, "分隔符");
      (Special, "特殊");
    ] in
    
    List.iter (fun (category, desc) ->
      let metadata = {
        category = category;
        priority = MediumPriority;
        description = desc ^ "测试";
        chinese_name = Some desc;
        aliases = [];
        deprecated = false;
      } in
      check bool (desc ^ "分类设置正确") true (metadata.category = category)
    ) test_cases
end

(** 位置信息测试 *)
module PositionTests = struct
  (** 测试位置信息创建和字段访问 *)
  let test_position_creation () =
    let pos = {
      filename = "test.ly";
      line = 10;
      column = 25;
      offset = 150;
    } in
    
    (* 测试字段访问 *)
    check string "位置文件名正确" "test.ly" pos.filename;
    check int "位置行号正确" 10 pos.line;
    check int "位置列号正确" 25 pos.column;
    check int "位置偏移量正确" 150 pos.offset;
    
    (* 测试位置相等性 *)
    let same_pos = { filename = "test.ly"; line = 10; column = 25; offset = 150 } in
    let diff_pos = { filename = "test.ly"; line = 11; column = 25; offset = 150 } in
    
    TestUtils.check_position_equal "相同位置信息相等" pos same_pos;
    check bool "不同位置信息不等" false (
      pos.line = diff_pos.line &&
      pos.column = diff_pos.column &&
      pos.offset = diff_pos.offset &&
      String.equal pos.filename diff_pos.filename
    )
  
  (** 测试位置信息的实际应用场景 *)
  let test_position_usage_scenarios () =
    (* 文件开始位置 *)
    let start_pos = { filename = "main.ly"; line = 1; column = 1; offset = 0 } in
    
    (* 文件中间位置 *)
    let middle_pos = { filename = "main.ly"; line = 15; column = 8; offset = 342 } in
    
    (* 文件末尾位置 *)
    let end_pos = { filename = "main.ly"; line = 100; column = 1; offset = 2500 } in
    
    (* 验证位置的合理性 *)
    check bool "开始位置行列号合理" true (start_pos.line >= 1 && start_pos.column >= 1);
    check bool "中间位置行列号合理" true (middle_pos.line >= 1 && middle_pos.column >= 1);
    check bool "末尾位置行列号合理" true (end_pos.line >= 1 && end_pos.column >= 1);
    
    (* 验证偏移量的递增性 *)
    check bool "位置偏移量递增1" true (start_pos.offset <= middle_pos.offset);
    check bool "位置偏移量递增2" true (middle_pos.offset <= end_pos.offset)
end

(** 令牌元数据测试 *)
module TokenMetadataTests = struct
  (** 测试元数据创建和字段访问 *)
  let test_metadata_creation () =
    let metadata = {
      category = Keyword;
      priority = HighPriority;
      description = "让关键字 - 用于变量绑定";
      chinese_name = Some "让";
      aliases = ["let"; "var"; "define"];
      deprecated = false;
    } in
    
    (* 测试字段访问 *)
    check bool "元数据分类正确" true (metadata.category = Keyword);
    check bool "元数据优先级正确" true (metadata.priority = HighPriority);
    check string "元数据描述正确" "让关键字 - 用于变量绑定" metadata.description;
    check (option string) "元数据中文名正确" (Some "让") metadata.chinese_name;
    check (list string) "元数据别名正确" ["let"; "var"; "define"] metadata.aliases;
    check bool "元数据弃用状态正确" false metadata.deprecated
  
  (** 测试不同类型令牌的元数据 *)
  let test_different_token_metadata () =
    let keyword_metadata = {
      category = Keyword;
      priority = HighPriority;
      description = "关键字";
      chinese_name = Some "关键字";
      aliases = [];
      deprecated = false;
    } in
    
    let operator_metadata = {
      category = Operator;
      priority = MediumPriority;
      description = "加法操作符";
      chinese_name = Some "加";
      aliases = ["+"; "plus"];
      deprecated = false;
    } in
    
    let identifier_metadata = {
      category = Identifier;
      priority = LowPriority;
      description = "用户定义标识符";
      chinese_name = Some "标识符";
      aliases = [];
      deprecated = false;
    } in
    
    let deprecated_metadata = {
      category = Special;
      priority = LowPriority;
      description = "已弃用的特殊令牌";
      chinese_name = None;
      aliases = ["old_token"];
      deprecated = true;
    } in
    
    (* 验证不同类型的元数据 *)
    check bool "关键字元数据分类正确" true (keyword_metadata.category = Keyword);
    check bool "操作符元数据分类正确" true (operator_metadata.category = Operator);
    check bool "标识符元数据分类正确" true (identifier_metadata.category = Identifier);
    check bool "弃用令牌标记正确" true deprecated_metadata.deprecated;
    
    (* 验证优先级分配 *)
    check bool "关键字高优先级" true (keyword_metadata.priority = HighPriority);
    check bool "操作符中优先级" true (operator_metadata.priority = MediumPriority);
    check bool "标识符低优先级" true (identifier_metadata.priority = LowPriority)
end

(** 统一令牌定义测试 *)
module UnifiedTokenTests = struct
  (** 测试字面量令牌 *)
  let test_literal_tokens () =
    let tokens = [
      (IntToken 42, "整数令牌");
      (FloatToken 3.14, "浮点数令牌");
      (StringToken "你好", "字符串令牌");
      (BoolToken true, "布尔令牌");
      (ChineseNumberToken "四十二", "中文数字令牌");
      (UnitToken, "空值令牌");
    ] in
    
    List.iter (fun (token, desc) ->
      TestUtils.check_token_equal (desc ^ "自身相等") token token
    ) tokens;
    
    (* 测试不同字面量令牌不等 *)
    let int_token = IntToken 42 in
    let float_token = FloatToken 3.14 in
    let string_token = StringToken "hello" in
    
    TestUtils.check_token_not_equal "整数与浮点数令牌不等" int_token float_token;
    TestUtils.check_token_not_equal "整数与字符串令牌不等" int_token string_token;
    TestUtils.check_token_not_equal "浮点数与字符串令牌不等" float_token string_token
  
  (** 测试标识符令牌 *)
  let test_identifier_tokens () =
    let identifiers = [
      (IdentifierToken "变量", "普通标识符");
      (QuotedIdentifierToken "「引用标识符」", "引用标识符");
      (ConstructorToken "Some", "构造函数");
      (IdentifierTokenSpecial "数值", "特殊标识符");
      (ModuleNameToken "MyModule", "模块名");
      (TypeNameToken "MyType", "类型名");
    ] in
    
    List.iter (fun (token, desc) ->
      TestUtils.check_token_equal (desc ^ "自身相等") token token
    ) identifiers;
    
    (* 测试不同标识符令牌不等 *)
    let normal_id = IdentifierToken "x" in
    let quoted_id = QuotedIdentifierToken "「y」" in
    let constructor = ConstructorToken "Some" in
    
    TestUtils.check_token_not_equal "普通与引用标识符不等" normal_id quoted_id;
    TestUtils.check_token_not_equal "标识符与构造函数不等" normal_id constructor;
    TestUtils.check_token_not_equal "引用标识符与构造函数不等" quoted_id constructor
  
  (** 测试关键字令牌 *)
  let test_keyword_tokens () =
    let keywords = [
      (LetKeyword, "让关键字");
      (FunKeyword, "函数关键字");
      (IfKeyword, "如果关键字");
      (ThenKeyword, "那么关键字");
      (ElseKeyword, "否则关键字");
      (MatchKeyword, "匹配关键字");
      (WithKeyword, "与关键字");
      (TrueKeyword, "真关键字");
      (FalseKeyword, "假关键字");
    ] in
    
    List.iter (fun (token, desc) ->
      TestUtils.check_token_equal (desc ^ "自身相等") token token
    ) keywords;
    
    (* 测试不同关键字令牌不等 *)
    TestUtils.check_token_not_equal "让与函数关键字不等" LetKeyword FunKeyword;
    TestUtils.check_token_not_equal "如果与否则关键字不等" IfKeyword ElseKeyword;
    TestUtils.check_token_not_equal "真与假关键字不等" TrueKeyword FalseKeyword
  
  (** 测试数字关键字令牌 *)
  let test_numeric_keywords () =
    let numeric_keywords = [
      (ZeroKeyword, "零");
      (OneKeyword, "一");
      (TwoKeyword, "二");
      (ThreeKeyword, "三");
      (FourKeyword, "四");
      (FiveKeyword, "五");
      (TenKeyword, "十");
      (HundredKeyword, "百");
      (ThousandKeyword, "千");
      (TenThousandKeyword, "万");
    ] in
    
    List.iter (fun (token, desc) ->
      TestUtils.check_token_equal (desc ^ "关键字自身相等") token token
    ) numeric_keywords;
    
    (* 测试不同数字关键字不等 *)
    TestUtils.check_token_not_equal "零与一关键字不等" ZeroKeyword OneKeyword;
    TestUtils.check_token_not_equal "十与百关键字不等" TenKeyword HundredKeyword
  
  (** 测试类型关键字令牌 *)
  let test_type_keywords () =
    let type_keywords = [
      (IntTypeKeyword, "整数类型");
      (FloatTypeKeyword, "浮点数类型");
      (StringTypeKeyword, "字符串类型");
      (BoolTypeKeyword, "布尔类型");
      (UnitTypeKeyword, "空值类型");
      (ListTypeKeyword, "列表类型");
      (ArrayTypeKeyword, "数组类型");
      (RefTypeKeyword, "引用类型");
    ] in
    
    List.iter (fun (token, desc) ->
      TestUtils.check_token_equal (desc ^ "关键字自身相等") token token
    ) type_keywords;
    
    (* 测试不同类型关键字不等 *)
    TestUtils.check_token_not_equal "整数与字符串类型关键字不等" IntTypeKeyword StringTypeKeyword;
    TestUtils.check_token_not_equal "列表与数组类型关键字不等" ListTypeKeyword ArrayTypeKeyword
  
  (** 测试文言文和古雅体关键字 *)
  let test_classical_keywords () =
    let wenyan_keywords = [
      (WenyanIfKeyword, "文言文如果");
      (WenyanThenKeyword, "文言文那么");
      (WenyanElseKeyword, "文言文否则");
      (WenyanWhileKeyword, "文言文循环");
      (WenyanLetKeyword, "文言文定义");
    ] in
    
    let classical_keywords = [
      (ClassicalIfKeyword, "古雅体如果");
      (ClassicalThenKeyword, "古雅体那么");
      (ClassicalElseKeyword, "古雅体否则");
      (ClassicalWhileKeyword, "古雅体循环");
      (ClassicalLetKeyword, "古雅体定义");
    ] in
    
    List.iter (fun (token, desc) ->
      TestUtils.check_token_equal (desc ^ "关键字自身相等") token token
    ) (wenyan_keywords @ classical_keywords);
    
    (* 测试文言文与古雅体同类关键字不等 *)
    TestUtils.check_token_not_equal "文言文与古雅体如果关键字不等" WenyanIfKeyword ClassicalIfKeyword;
    TestUtils.check_token_not_equal "文言文与古雅体定义关键字不等" WenyanLetKeyword ClassicalLetKeyword
  
  (** 测试运算符令牌 *)
  let test_operator_tokens () =
    let operators = [
      (PlusOp, "加法操作符");
      (MinusOp, "减法操作符");
      (MultiplyOp, "乘法操作符");
      (DivideOp, "除法操作符");
      (EqualOp, "等于操作符");
      (NotEqualOp, "不等于操作符");
      (LessOp, "小于操作符");
      (GreaterOp, "大于操作符");
      (LogicalAndOp, "逻辑与操作符");
      (LogicalOrOp, "逻辑或操作符");
    ] in
    
    List.iter (fun (token, desc) ->
      TestUtils.check_token_equal (desc ^ "自身相等") token token
    ) operators;
    
    (* 测试不同操作符不等 *)
    TestUtils.check_token_not_equal "加法与减法操作符不等" PlusOp MinusOp;
    TestUtils.check_token_not_equal "等于与不等于操作符不等" EqualOp NotEqualOp;
    TestUtils.check_token_not_equal "逻辑与和逻辑或操作符不等" LogicalAndOp LogicalOrOp
  
  (** 测试分隔符令牌 *)
  let test_delimiter_tokens () =
    let delimiters = [
      (LeftParen, "左括号");
      (RightParen, "右括号");
      (LeftBracket, "左方括号");
      (RightBracket, "右方括号");
      (LeftBrace, "左花括号");
      (RightBrace, "右花括号");
      (Comma, "逗号");
      (Semicolon, "分号");
      (Colon, "冒号");
      (DoubleColon, "双冒号");
    ] in
    
    List.iter (fun (token, desc) ->
      TestUtils.check_token_equal (desc ^ "自身相等") token token
    ) delimiters;
    
    (* 测试不同分隔符不等 *)
    TestUtils.check_token_not_equal "左右括号不等" LeftParen RightParen;
    TestUtils.check_token_not_equal "左方括号与左花括号不等" LeftBracket LeftBrace;
    TestUtils.check_token_not_equal "逗号与分号不等" Comma Semicolon
  
  (** 测试特殊令牌 *)
  let test_special_tokens () =
    let special_tokens = [
      (EOF, "文件结束");
      (Newline, "换行");
      (Whitespace, "空白");
      (Comment "注释内容", "注释");
      (LineComment "行注释", "行注释");
      (BlockComment "块注释", "块注释");
      (DocComment "文档注释", "文档注释");
    ] in
    
    List.iter (fun (token, desc) ->
      TestUtils.check_token_equal (desc ^ "自身相等") token token
    ) special_tokens;
    
    (* 测试不同特殊令牌不等 *)
    TestUtils.check_token_not_equal "EOF与换行不等" EOF Newline;
    TestUtils.check_token_not_equal "换行与空白不等" Newline Whitespace;
    
    (* 测试相同类型但内容不同的注释令牌不等 *)
    let comment1 = Comment "内容1" in
    let comment2 = Comment "内容2" in
    TestUtils.check_token_not_equal "不同内容注释不等" comment1 comment2
end

(** 带位置信息的令牌测试 *)
module PositionedTokenTests = struct
  (** 测试带位置信息令牌的创建 *)
  let test_positioned_token_creation () =
    let token = LetKeyword in
    let position = { filename = "test.ly"; line = 5; column = 10; offset = 50 } in
    let metadata = Some {
      category = Keyword;
      priority = HighPriority;
      description = "让关键字";
      chinese_name = Some "让";
      aliases = ["let"];
      deprecated = false;
    } in
    
    let positioned_token = { token; position; metadata } in
    
    (* 测试字段访问 *)
    TestUtils.check_token_equal "令牌字段正确" token positioned_token.token;
    TestUtils.check_position_equal "位置字段正确" position positioned_token.position;
    TestUtils.check_metadata_equal "元数据字段正确" metadata positioned_token.metadata
  
  (** 测试不同位置的相同令牌 *)
  let test_same_token_different_positions () =
    let token = IntToken 42 in
    let pos1 = { filename = "file1.ly"; line = 1; column = 1; offset = 0 } in
    let pos2 = { filename = "file2.ly"; line = 10; column = 5; offset = 100 } in
    
    let positioned1 = { token; position = pos1; metadata = None } in
    let positioned2 = { token; position = pos2; metadata = None } in
    
    (* 相同令牌应相等 *)
    TestUtils.check_token_equal "相同令牌内容相等" positioned1.token positioned2.token;
    
    (* 但位置不同 *)
    check bool "不同位置信息不等" false (
      pos1.line = pos2.line &&
      pos1.column = pos2.column &&
      pos1.offset = pos2.offset &&
      String.equal pos1.filename pos2.filename
    )
  
  (** 测试带元数据的令牌 *)
  let test_tokens_with_metadata () =
    let create_positioned_token token category priority desc =
      let position = { filename = "test.ly"; line = 1; column = 1; offset = 0 } in
      let metadata = Some {
        category;
        priority;
        description = desc;
        chinese_name = None;
        aliases = [];
        deprecated = false;
      } in
      { token; position; metadata }
    in
    
    let keyword_token = create_positioned_token LetKeyword Keyword HighPriority "让关键字" in
    let operator_token = create_positioned_token PlusOp Operator MediumPriority "加法操作符" in
    let literal_token = create_positioned_token (IntToken 42) Literal LowPriority "整数字面量" in
    
    (* 验证元数据设置正确 *)
    match keyword_token.metadata with
    | Some meta -> check bool "关键字元数据分类正确" true (meta.category = Keyword)
    | None -> check bool "关键字应有元数据" false true;
    
    match operator_token.metadata with
    | Some meta -> check bool "操作符元数据分类正确" true (meta.category = Operator)
    | None -> check bool "操作符应有元数据" false true;
    
    match literal_token.metadata with
    | Some meta -> check bool "字面量元数据分类正确" true (meta.category = Literal)
    | None -> check bool "字面量应有元数据" false true
end

(** 错误令牌测试 *)
module ErrorTokenTests = struct
  (** 测试错误令牌创建和处理 *)
  let test_error_token_creation () =
    let error_pos = { filename = "error.ly"; line = 15; column = 8; offset = 200 } in
    let error_token = ErrorToken ("未知字符 '@'", error_pos) in
    
    TestUtils.check_token_equal "错误令牌自身相等" error_token error_token;
    
    (* 测试不同错误令牌不等 *)
    let error_pos2 = { filename = "error.ly"; line = 16; column = 1; offset = 220 } in
    let error_token2 = ErrorToken ("未定义操作符 '#'", error_pos2) in
    
    TestUtils.check_token_not_equal "不同错误令牌不等" error_token error_token2
  
  (** 测试错误令牌在位置令牌中的使用 *)
  let test_error_token_in_positioned () =
    let error_pos = { filename = "syntax_error.ly"; line = 5; column = 12; offset = 85 } in
    let error_token = ErrorToken ("语法错误：意外的令牌", error_pos) in
    
    let positioned_error = {
      token = error_token;
      position = error_pos;
      metadata = Some {
        category = Special;
        priority = HighPriority;
        description = "语法错误令牌";
        chinese_name = Some "错误";
        aliases = ["error"; "syntax_error"];
        deprecated = false;
      }
    } in
    
    TestUtils.check_token_equal "错误位置令牌内容正确" error_token positioned_error.token;
    TestUtils.check_position_equal "错误位置令牌位置正确" error_pos positioned_error.position;
    
    match positioned_error.metadata with
    | Some meta -> check bool "错误令牌元数据高优先级" true (meta.priority = HighPriority)
    | None -> check bool "错误令牌应有元数据" false true
end

(** 主测试套件 *)
let () =
  run "骆言核心令牌类型系统综合测试" [
    "令牌优先级测试", [
      test_case "优先级定义" `Quick TokenPriorityTests.test_priority_definitions;
      test_case "优先级在元数据中的使用" `Quick TokenPriorityTests.test_priority_in_metadata;
    ];
    "令牌分类测试", [
      test_case "分类定义" `Quick TokenCategoryTests.test_category_definitions;
      test_case "分类在元数据中的应用" `Quick TokenCategoryTests.test_category_in_metadata;
    ];
    "位置信息测试", [
      test_case "位置信息创建" `Quick PositionTests.test_position_creation;
      test_case "位置信息使用场景" `Quick PositionTests.test_position_usage_scenarios;
    ];
    "令牌元数据测试", [
      test_case "元数据创建" `Quick TokenMetadataTests.test_metadata_creation;
      test_case "不同类型令牌元数据" `Quick TokenMetadataTests.test_different_token_metadata;
    ];
    "统一令牌定义测试", [
      test_case "字面量令牌" `Quick UnifiedTokenTests.test_literal_tokens;
      test_case "标识符令牌" `Quick UnifiedTokenTests.test_identifier_tokens;
      test_case "关键字令牌" `Quick UnifiedTokenTests.test_keyword_tokens;
      test_case "数字关键字令牌" `Quick UnifiedTokenTests.test_numeric_keywords;
      test_case "类型关键字令牌" `Quick UnifiedTokenTests.test_type_keywords;
      test_case "古典关键字令牌" `Quick UnifiedTokenTests.test_classical_keywords;
      test_case "运算符令牌" `Quick UnifiedTokenTests.test_operator_tokens;
      test_case "分隔符令牌" `Quick UnifiedTokenTests.test_delimiter_tokens;
      test_case "特殊令牌" `Quick UnifiedTokenTests.test_special_tokens;
    ];
    "带位置信息令牌测试", [
      test_case "带位置令牌创建" `Quick PositionedTokenTests.test_positioned_token_creation;
      test_case "相同令牌不同位置" `Quick PositionedTokenTests.test_same_token_different_positions;
      test_case "带元数据的令牌" `Quick PositionedTokenTests.test_tokens_with_metadata;
    ];
    "错误令牌测试", [
      test_case "错误令牌创建" `Quick ErrorTokenTests.test_error_token_creation;
      test_case "错误令牌在位置令牌中的使用" `Quick ErrorTokenTests.test_error_token_in_positioned;
    ];
  ]