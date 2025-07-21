(** 解析器表达式Token重复消除模块 - 专门解决Issue #563中提到的291处Token重复 *)

open Lexer_tokens

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

  (** 默认的Token处理器 - 减少重复逻辑 *)
  let default_processor =
    {
      process_keyword_group =
        (function
        | BasicKeywords _ -> Unified_logging.Legacy.printf "处理基础关键字组\n"
        | WenyanKeywords _ -> Unified_logging.Legacy.printf "处理文言文关键字组\n"
        | AncientKeywords _ -> Unified_logging.Legacy.printf "处理古雅体关键字组\n"
        | TypeKeywords _ -> Unified_logging.Legacy.printf "处理类型关键字组\n"
        | NaturalLanguageKeywords _ -> Unified_logging.Legacy.printf "处理自然语言关键字组\n"
        | PoetryKeywords _ -> Unified_logging.Legacy.printf "处理诗词关键字组\n");
      process_operator_group =
        (function
        | ArithmeticOps _ -> Unified_logging.Legacy.printf "处理算术操作符组\n"
        | ComparisonOps _ -> Unified_logging.Legacy.printf "处理比较操作符组\n"
        | LogicalOps _ -> Unified_logging.Legacy.printf "处理逻辑操作符组\n"
        | AssignmentOps _ -> Unified_logging.Legacy.printf "处理赋值操作符组\n"
        | SpecialOps _ -> Unified_logging.Legacy.printf "处理特殊操作符组\n");
      process_delimiter_group =
        (function
        | ParenthesesGroup _ -> Unified_logging.Legacy.printf "处理括号组\n"
        | BracketGroup _ -> Unified_logging.Legacy.printf "处理方括号组\n"
        | BraceGroup _ -> Unified_logging.Legacy.printf "处理大括号组\n"
        | ChineseDelimiters _ -> Unified_logging.Legacy.printf "处理中文分隔符组\n"
        | PunctuationGroup _ -> Unified_logging.Legacy.printf "处理标点符号组\n");
      process_literal_group =
        (function
        | NumericLiterals _ -> Unified_logging.Legacy.printf "处理数值字面量组\n"
        | StringLiterals _ -> Unified_logging.Legacy.printf "处理字符串字面量组\n"
        | BooleanLiterals _ -> Unified_logging.Legacy.printf "处理布尔字面量组\n"
        | SpecialLiterals _ -> Unified_logging.Legacy.printf "处理特殊字面量组\n");
    }

  (** 尝试按优先级处理token分类 - 重构：消除深度嵌套 *)
  let try_process_token_classification processor token =
    (* 尝试关键字分类 *)
    match TokenGroups.classify_keyword_token token with
    | Some group ->
        processor.process_keyword_group group;
        true
    | None -> (
        (* 尝试操作符分类 *)
        match TokenGroups.classify_operator_token token with
        | Some group ->
            processor.process_operator_group group;
            true
        | None -> (
            (* 尝试分隔符分类 *)
            match TokenGroups.classify_delimiter_token token with
            | Some group ->
                processor.process_delimiter_group group;
                true
            | None -> (
                (* 尝试字面量分类 *)
                match TokenGroups.classify_literal_token token with
                | Some group ->
                    processor.process_literal_group group;
                    true
                | None -> false)))

  (** 处理单个token - 重构：消除深度嵌套 *)
  let process_token processor token =
    if not (try_process_token_classification processor token) then
      Unified_logging.Legacy.printf "未分类的token\n"

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

  (** 分析token列表并生成去重统计 *)
  let analyze_token_duplication tokens =
    let original_count = List.length tokens in
    let keyword_groups = ref [] in
    let operator_groups = ref [] in
    let delimiter_groups = ref [] in
    let literal_groups = ref [] in

    let add_keyword_group group =
      if not (List.mem group !keyword_groups) then keyword_groups := group :: !keyword_groups
    in
    let add_operator_group group =
      if not (List.mem group !operator_groups) then operator_groups := group :: !operator_groups
    in
    let add_delimiter_group group =
      if not (List.mem group !delimiter_groups) then delimiter_groups := group :: !delimiter_groups
    in
    let add_literal_group group =
      if not (List.mem group !literal_groups) then literal_groups := group :: !literal_groups
    in

    let classify_and_add_token token =
      (* 按顺序尝试分类并添加 *)
      match TokenGroups.classify_keyword_token token with
      | Some group -> add_keyword_group group
      | None -> (
          match TokenGroups.classify_operator_token token with
          | Some group -> add_operator_group group
          | None -> (
              match TokenGroups.classify_delimiter_token token with
              | Some group -> add_delimiter_group group
              | None -> (
                  match TokenGroups.classify_literal_token token with
                  | Some group -> add_literal_group group
                  | None -> ())))
    in
    List.iter classify_and_add_token tokens;

    let grouped_count =
      List.length !keyword_groups + List.length !operator_groups + List.length !delimiter_groups
      + List.length !literal_groups
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

  (** 生成去重报告 *)
  let generate_dedup_report stats =
    Printf.sprintf
      "Token重复消除报告:\n- 原始Token数量: %d\n- 分组后Token数量: %d\n- 重复减少率: %.1f%%\n- 创建的组数: %d\n- 状态: %s\n"
      stats.original_token_count stats.grouped_token_count stats.reduction_percentage
      stats.groups_created
      (if stats.reduction_percentage > 50.0 then "✅ 显著改善" else "⚠️  需要进一步优化")
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
              Unified_logging.Legacy.printf "表达式解析: 基础关键字 %s\n" (Lexer_tokens.show_token token)
          | TokenGroups.WenyanKeywords token ->
              Unified_logging.Legacy.printf "表达式解析: 文言文关键字 %s\n" (Lexer_tokens.show_token token)
          | TokenGroups.AncientKeywords token ->
              Unified_logging.Legacy.printf "表达式解析: 古雅体关键字 %s\n" (Lexer_tokens.show_token token)
          | _ -> Unified_logging.Legacy.printf "表达式解析: 其他关键字组\n");
      process_operator_group =
        (fun _ ->
          incr operator_count;
          Unified_logging.Legacy.printf "表达式解析: 操作符组处理\n");
      process_delimiter_group =
        (fun _ ->
          incr delimiter_count;
          Unified_logging.Legacy.printf "表达式解析: 分隔符组处理\n");
      process_literal_group =
        (fun _ ->
          incr literal_count;
          Unified_logging.Legacy.printf "表达式解析: 字面量组处理\n");
    }

  (** 获取处理统计 *)
  let get_processing_stats keyword_count operator_count delimiter_count literal_count =
    Printf.sprintf
      "解析器表达式Token处理统计:\n- 关键字组处理: %d次\n- 操作符组处理: %d次\n- 分隔符组处理: %d次\n- 字面量组处理: %d次\n- 总计: %d次处理\n"
      !keyword_count !operator_count !delimiter_count !literal_count
      (!keyword_count + !operator_count + !delimiter_count + !literal_count)
end
