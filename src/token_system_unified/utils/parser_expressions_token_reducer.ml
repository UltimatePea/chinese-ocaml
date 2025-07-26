(** 解析器表达式Token重复消除模块 - 专门解决Issue #563中提到的291处Token重复 版本 2.1 - Issue #759 大型模块重构优化：消除深层嵌套和重复代码 *)

open Yyocamlc_lib.Lexer_tokens
open Utils

(** 统一的列表添加函数，消除重复的添加逻辑 *)
let add_unique_to_ref item_ref item =
  if not (List.mem item !item_ref) then item_ref := item :: !item_ref

(** Token分组 - 将相似的token归类以减少重复处理 *)
module TokenGroups = struct
  (** 关键字Token组 *)
  type keyword_group =
    | BasicKeywords of token
    | WenyanKeywords of token
    | AncientKeywords of token
    | TypeKeywords of token
    | NaturalLanguageKeywords of token
    | PoetryKeywords of token

  (** 操作符Token组 *)
  type operator_group =
    | ArithmeticOps of token
    | ComparisonOps of token
    | LogicalOps of token
    | AssignmentOps of token
    | SpecialOps of token

  (** 分隔符Token组 *)
  type delimiter_group =
    | ParenthesesGroup of token
    | BracketGroup of token
    | BraceGroup of token
    | ChineseDelimiters of token
    | PunctuationGroup of token

  (** 字面量Token组 *)
  type literal_group =
    | NumericLiterals of token
    | StringLiterals of token
    | BooleanLiterals of token
    | SpecialLiterals of token

  (** 将token分类到关键字组 *)
  let classify_keyword_token = function
    | LetKeyword | RecKeyword | InKeyword | FunKeyword | IfKeyword | ThenKeyword | ElseKeyword
    | MatchKeyword | WithKeyword | TypeKeyword | TrueKeyword | FalseKeyword | AndKeyword | OrKeyword
    | NotKeyword | AsKeyword | OfKeyword | ModuleKeyword | RefKeyword | ExceptionKeyword
    | TryKeyword | RaiseKeyword | PrivateKeyword | EndKeyword ->
        Some (BasicKeywords LetKeyword) (* 用代表性token *)
    | HaveKeyword | OneKeyword | NameKeyword | SetKeyword | AlsoKeyword | ThenGetKeyword
    | CallKeyword | ValueKeyword | AsForKeyword | NumberKeyword | IfWenyanKeyword
    | ThenWenyanKeyword ->
        Some (WenyanKeywords HaveKeyword)
    | AncientDefineKeyword | AncientEndKeyword | AncientObserveKeyword | AncientIfKeyword
    | AncientThenKeyword | AncientListStartKeyword | AncientIsKeyword | AncientArrowKeyword ->
        Some (AncientKeywords AncientDefineKeyword)
    | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword | UnitTypeKeyword
    | ListTypeKeyword | ArrayTypeKeyword ->
        Some (TypeKeywords IntTypeKeyword)
    | DefineKeyword | AcceptKeyword | ReturnWhenKeyword | ElseReturnKeyword | IsKeyword
    | EqualToKeyword | EmptyKeyword | InputKeyword | OutputKeyword ->
        Some (NaturalLanguageKeywords DefineKeyword)
    | PoetryKeyword | FiveCharKeyword | SevenCharKeyword | ParallelStructKeyword | RhymeKeyword
    | ToneKeyword ->
        Some (PoetryKeywords PoetryKeyword)
    | _ -> None

  (** 将token分类到操作符组 *)
  let classify_operator_token = function
    | Plus | Minus | Multiply | Star | Divide | Slash | Modulo -> Some (ArithmeticOps Plus)
    | Equal | NotEqual | Less | LessEqual | Greater | GreaterEqual | GreaterThanWenyan
    | LessThanWenyan | EqualToKeyword ->
        Some (ComparisonOps Equal)
    | OrElseKeyword | WithDefaultKeyword | AndKeyword | OrKeyword | NotKeyword ->
        Some (LogicalOps AndKeyword)
    | Assign | RefAssign | AssignArrow | ChineseAssignArrow -> Some (AssignmentOps Assign)
    | Arrow | DoubleArrow | ChineseArrow | ChineseDoubleArrow | Dot | DoubleDot | TripleDot | Bang
      ->
        Some (SpecialOps Arrow)
    | _ -> None

  (** 将token分类到分隔符组 *)
  let classify_delimiter_token = function
    | LeftParen | RightParen | ChineseLeftParen | ChineseRightParen ->
        Some (ParenthesesGroup LeftParen)
    | LeftBracket | RightBracket | ChineseLeftBracket | ChineseRightBracket | LeftArray | RightArray
    | ChineseLeftArray | ChineseRightArray ->
        Some (BracketGroup LeftBracket)
    | LeftBrace | RightBrace -> Some (BraceGroup LeftBrace)
    | LeftQuote | RightQuote -> Some (ChineseDelimiters LeftQuote)
    | Comma | Semicolon | Colon | ChineseComma | ChineseSemicolon | ChineseColon
    | ChineseDoubleColon | QuestionMark | Tilde | Pipe | ChinesePipe | Underscore ->
        Some (PunctuationGroup Comma)
    | _ -> None

  (** 将token分类到字面量组 *)
  let classify_literal_token = function
    | IntToken _ | ChineseNumberToken _ | FloatToken _ -> Some (NumericLiterals (IntToken 0))
    | StringToken _ -> Some (StringLiterals (StringToken ""))
    | BoolToken _ | TrueKeyword | FalseKeyword -> Some (BooleanLiterals (BoolToken true))
    | QuotedIdentifierToken _ | IdentifierTokenSpecial _ ->
        Some (SpecialLiterals (QuotedIdentifierToken ""))
    | _ -> None
end

(** Token处理统一化模块 *)
module UnifiedTokenProcessor = struct
  type token_processor = {
    process_keyword_group : TokenGroups.keyword_group -> unit;
    process_operator_group : TokenGroups.operator_group -> unit;
    process_delimiter_group : TokenGroups.delimiter_group -> unit;
    process_literal_group : TokenGroups.literal_group -> unit;
  }
  (** 统一的Token处理接口 *)

  (** 统一的日志输出函数 - 消除重复的printf模式 *)
  let log_processing_info message = Printf.printf "%s\n" message

  (** 默认的Token处理器 - 减少重复逻辑，使用统一日志函数 *)
  let default_processor =
    {
      process_keyword_group =
        (function
        | BasicKeywords _ -> log_processing_info "处理基础关键字组"
        | WenyanKeywords _ -> log_processing_info "处理文言文关键字组"
        | AncientKeywords _ -> log_processing_info "处理古雅体关键字组"
        | TypeKeywords _ -> log_processing_info "处理类型关键字组"
        | NaturalLanguageKeywords _ -> log_processing_info "处理自然语言关键字组"
        | PoetryKeywords _ -> log_processing_info "处理诗词关键字组");
      process_operator_group =
        (function
        | ArithmeticOps _ -> log_processing_info "处理算术操作符组"
        | ComparisonOps _ -> log_processing_info "处理比较操作符组"
        | LogicalOps _ -> log_processing_info "处理逻辑操作符组"
        | AssignmentOps _ -> log_processing_info "处理赋值操作符组"
        | SpecialOps _ -> log_processing_info "处理特殊操作符组");
      process_delimiter_group =
        (function
        | ParenthesesGroup _ -> log_processing_info "处理括号组"
        | BracketGroup _ -> log_processing_info "处理方括号组"
        | BraceGroup _ -> log_processing_info "处理大括号组"
        | ChineseDelimiters _ -> log_processing_info "处理中文分隔符组"
        | PunctuationGroup _ -> log_processing_info "处理标点符号组");
      process_literal_group =
        (function
        | NumericLiterals _ -> log_processing_info "处理数值字面量组"
        | StringLiterals _ -> log_processing_info "处理字符串字面量组"
        | BooleanLiterals _ -> log_processing_info "处理布尔字面量组"
        | SpecialLiterals _ -> log_processing_info "处理特殊字面量组");
    }

  (** 尝试按优先级处理token分类 - 重构：消除深度嵌套，分别处理不同类型 *)
  let try_process_token_classification processor token =
    let try_keyword () =
      match TokenGroups.classify_keyword_token token with
      | Some group ->
          processor.process_keyword_group group;
          true
      | None -> false
    in
    let try_operator () =
      match TokenGroups.classify_operator_token token with
      | Some group ->
          processor.process_operator_group group;
          true
      | None -> false
    in
    let try_delimiter () =
      match TokenGroups.classify_delimiter_token token with
      | Some group ->
          processor.process_delimiter_group group;
          true
      | None -> false
    in
    let try_literal () =
      match TokenGroups.classify_literal_token token with
      | Some group ->
          processor.process_literal_group group;
          true
      | None -> false
    in
    try_keyword () || try_operator () || try_delimiter () || try_literal ()

  (** 处理单个token - 重构：消除深度嵌套 *)
  let process_token processor token =
    if not (try_process_token_classification processor token) then log_processing_info "未分类的token"

  (** 批量处理token列表 - 避免重复的循环逻辑 *)
  let process_token_list processor tokens = List.iter (process_token processor) tokens
end

(** Token重复消除的主要接口 *)
module TokenDeduplication = struct
  type dedup_stats = {
    original_token_count : int;
    grouped_token_count : int;
    reduction_percentage : float;
    groups_created : int;
  }
  (** 重复消除统计 *)

  type group_collections = {
    keyword_groups : TokenGroups.keyword_group list ref;
    operator_groups : TokenGroups.operator_group list ref;
    delimiter_groups : TokenGroups.delimiter_group list ref;
    literal_groups : TokenGroups.literal_group list ref;
  }
  (** 分组集合 - 提取为单独类型以提高可读性 *)

  (** 创建新的分组集合 *)
  let create_group_collections () =
    {
      keyword_groups = ref [];
      operator_groups = ref [];
      delimiter_groups = ref [];
      literal_groups = ref [];
    }

  (** 统一的分类器 - 重构：简化逻辑，分别处理不同类型 *)
  let classify_and_add_token collections token =
    let try_classify_keyword () =
      match TokenGroups.classify_keyword_token token with
      | Some group -> add_unique_to_ref collections.keyword_groups group
      | None -> ()
    in
    let try_classify_operator () =
      match TokenGroups.classify_operator_token token with
      | Some group -> add_unique_to_ref collections.operator_groups group
      | None -> ()
    in
    let try_classify_delimiter () =
      match TokenGroups.classify_delimiter_token token with
      | Some group -> add_unique_to_ref collections.delimiter_groups group
      | None -> ()
    in
    let try_classify_literal () =
      match TokenGroups.classify_literal_token token with
      | Some group -> add_unique_to_ref collections.literal_groups group
      | None -> ()
    in
    try_classify_keyword ();
    try_classify_operator ();
    try_classify_delimiter ();
    try_classify_literal ()

  (** 计算统计数据 - 提取为独立函数 *)
  let calculate_dedup_stats original_count collections =
    let grouped_count =
      List.length !(collections.keyword_groups)
      + List.length !(collections.operator_groups)
      + List.length !(collections.delimiter_groups)
      + List.length !(collections.literal_groups)
    in
    let reduction =
      if original_count > 0 then
        float_of_int (original_count - grouped_count) /. float_of_int original_count *. 100.0
      else 0.0
    in
    {
      original_token_count = original_count;
      grouped_token_count = grouped_count;
      reduction_percentage = reduction;
      groups_created = grouped_count;
    }

  (** 分析token列表并生成去重统计 - 重构：主函数简化 *)
  let analyze_token_duplication tokens =
    let original_count = List.length tokens in
    let collections = create_group_collections () in
    List.iter (classify_and_add_token collections) tokens;
    calculate_dedup_stats original_count collections

  (** 生成去重报告 - 使用Base_formatter消除Printf.sprintf *)
  let generate_dedup_report stats =
    let status = if stats.reduction_percentage > 50.0 then "✅ 显著改善" else "⚠️  需要进一步优化" in
    let report_lines =
      [
        "Token重复消除报告:";
        Base_formatter.concat_strings
          [ "- 原始Token数量: "; Base_formatter.int_to_string stats.original_token_count ];
        Base_formatter.concat_strings
          [ "- 分组后Token数量: "; Base_formatter.int_to_string stats.grouped_token_count ];
        Base_formatter.concat_strings
          [ "- 重复减少率: "; Base_formatter.float_to_string stats.reduction_percentage; "%%" ];
        Base_formatter.concat_strings
          [ "- 创建的组数: "; Base_formatter.int_to_string stats.groups_created ];
        Base_formatter.concat_strings [ "- 状态: "; status ];
        "";
      ]
    in
    Base_formatter.join_with_separator "\n" report_lines
end

(** 解析器表达式专用的Token处理器 *)
module ParserExpressionTokenProcessor = struct
  (** 为解析器表达式创建专门的Token处理器 *)
  let create_expression_processor () =
    let keyword_count = ref 0 in
    let operator_count = ref 0 in
    let delimiter_count = ref 0 in
    let literal_count = ref 0 in

    {
      UnifiedTokenProcessor.process_keyword_group =
        (fun group ->
          incr keyword_count;
          match group with
          | TokenGroups.BasicKeywords token ->
              UnifiedTokenProcessor.log_processing_info
                (Base_formatter.concat_strings [ "表达式解析: 基础关键字 "; Yyocamlc_lib.Lexer_tokens.show_token token ])
          | TokenGroups.WenyanKeywords token ->
              UnifiedTokenProcessor.log_processing_info
                (Base_formatter.concat_strings [ "表达式解析: 文言文关键字 "; Yyocamlc_lib.Lexer_tokens.show_token token ])
          | TokenGroups.AncientKeywords token ->
              UnifiedTokenProcessor.log_processing_info
                (Base_formatter.concat_strings [ "表达式解析: 古雅体关键字 "; Yyocamlc_lib.Lexer_tokens.show_token token ])
          | _ -> UnifiedTokenProcessor.log_processing_info "表达式解析: 其他关键字组");
      process_operator_group =
        (fun _ ->
          incr operator_count;
          UnifiedTokenProcessor.log_processing_info "表达式解析: 操作符组处理");
      process_delimiter_group =
        (fun _ ->
          incr delimiter_count;
          UnifiedTokenProcessor.log_processing_info "表达式解析: 分隔符组处理");
      process_literal_group =
        (fun _ ->
          incr literal_count;
          UnifiedTokenProcessor.log_processing_info "表达式解析: 字面量组处理");
    }

  (** 获取处理统计 - 使用Base_formatter消除Printf.sprintf *)
  let get_processing_stats keyword_count operator_count delimiter_count literal_count =
    let total_count = !keyword_count + !operator_count + !delimiter_count + !literal_count in
    let stats_lines =
      [
        "解析器表达式Token处理统计:";
        Base_formatter.concat_strings
          [ "- 关键字组处理: "; Base_formatter.int_to_string !keyword_count; "次" ];
        Base_formatter.concat_strings
          [ "- 操作符组处理: "; Base_formatter.int_to_string !operator_count; "次" ];
        Base_formatter.concat_strings
          [ "- 分隔符组处理: "; Base_formatter.int_to_string !delimiter_count; "次" ];
        Base_formatter.concat_strings
          [ "- 字面量组处理: "; Base_formatter.int_to_string !literal_count; "次" ];
        Base_formatter.concat_strings [ "- 总计: "; Base_formatter.int_to_string total_count; "次处理" ];
        "";
      ]
    in
    Base_formatter.join_with_separator "\n" stats_lines
end
