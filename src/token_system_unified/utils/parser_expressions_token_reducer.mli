(** 解析器表达式Token重复消除模块接口 *)

open Yyocamlc_lib.Lexer_tokens

(** Token分组模块 - 将相似token归类减少重复处理 *)
module TokenGroups : sig
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

  val classify_keyword_token : token -> keyword_group option
  (** 将token分类到关键字组 *)

  val classify_operator_token : token -> operator_group option
  (** 将token分类到操作符组 *)

  val classify_delimiter_token : token -> delimiter_group option
  (** 将token分类到分隔符组 *)

  val classify_literal_token : token -> literal_group option
  (** 将token分类到字面量组 *)
end

(** Token处理统一化模块 *)
module UnifiedTokenProcessor : sig
  type token_processor = {
    process_keyword_group : TokenGroups.keyword_group -> unit;
    process_operator_group : TokenGroups.operator_group -> unit;
    process_delimiter_group : TokenGroups.delimiter_group -> unit;
    process_literal_group : TokenGroups.literal_group -> unit;
  }
  (** 统一的Token处理接口 *)

  val default_processor : token_processor
  (** 默认的Token处理器 *)

  val process_token : token_processor -> token -> unit
  (** 处理单个token - 通过分组减少重复逻辑 *)

  val process_token_list : token_processor -> token list -> unit
  (** 批量处理token列表 *)
end

(** Token重复消除的主要接口 *)
module TokenDeduplication : sig
  type dedup_stats = {
    original_token_count : int;
    grouped_token_count : int;
    reduction_percentage : float;
    groups_created : int;
  }
  (** 重复消除统计 *)

  val analyze_token_duplication : token list -> dedup_stats
  (** 分析token列表并生成去重统计 *)

  val generate_dedup_report : dedup_stats -> string
  (** 生成去重报告 *)
end

(** 解析器表达式专用的Token处理器 *)
module ParserExpressionTokenProcessor : sig
  val create_expression_processor : unit -> UnifiedTokenProcessor.token_processor
  (** 为解析器表达式创建专门的Token处理器 *)

  val get_processing_stats : int ref -> int ref -> int ref -> int ref -> string
  (** 获取处理统计 *)
end
