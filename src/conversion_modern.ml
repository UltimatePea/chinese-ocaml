(** 现代中文Token转换模块 - Phase 6.2 重构
    
    整合现代中文编程语法的Token转换，包括：
    - 关键字转换 (来自 token_conversion_keywords_refactored.ml)
    - 标识符转换 (来自 token_conversion_identifiers.ml)
    - 字面量转换 (来自 token_conversion_literals.ml)
    - 类型转换 (来自 token_conversion_types.ml)
    
    设计目标：
    - 统一现代中文编程语法转换
    - 支持多种现代中文编程语法
    - 提供高性能转换实现
    - 保持向后兼容性
    
    @author Alpha, 主工作代理 - Phase 6.2 Implementation
    @version 2.0 - 现代语言转换统一
    @since 2025-07-25
    @fixes Issue #1340 *)

open Lexer_tokens

exception Unknown_modern_token of string
(** 现代语言Token转换异常 *)

(** 现代语言转换子类型 *)
type modern_token_category =
  | Identifier (* 标识符 *)
  | Literal (* 字面量 *)
  | BasicKeyword (* 基础关键字 *)
  | TypeKeyword (* 类型关键字 *)
  | Semantic (* 语义关键字 *)
  | ModuleSystem (* 模块系统关键字 *)
  | ErrorRecovery (* 错误恢复关键字 *)

(** 标识符转换器 - 整合自 token_conversion_identifiers.ml *)
module Identifiers = struct
  let convert_identifier_token = function
    | Token_mapping.Token_definitions_unified.QuotedIdentifierToken s ->
        Some (QuotedIdentifierToken s)
    | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial s ->
        Some (IdentifierTokenSpecial s)
    | _ -> None

  let is_identifier_token = function
    | Token_mapping.Token_definitions_unified.QuotedIdentifierToken _
    | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial _ ->
        true
    | _ -> false
end

(** 字面量转换器 - 整合自 token_conversion_literals.ml *)
module Literals = struct
  let convert_literal_token = function
    | Token_mapping.Token_definitions_unified.IntToken i -> Some (IntToken i)
    | Token_mapping.Token_definitions_unified.FloatToken f -> Some (FloatToken f)
    | Token_mapping.Token_definitions_unified.ChineseNumberToken s -> Some (ChineseNumberToken s)
    | Token_mapping.Token_definitions_unified.StringToken s -> Some (StringToken s)
    | Token_mapping.Token_definitions_unified.BoolToken b -> Some (BoolToken b)
    | _ -> None

  let is_literal_token = function
    | Token_mapping.Token_definitions_unified.IntToken _
    | Token_mapping.Token_definitions_unified.FloatToken _
    | Token_mapping.Token_definitions_unified.ChineseNumberToken _
    | Token_mapping.Token_definitions_unified.StringToken _
    | Token_mapping.Token_definitions_unified.BoolToken _ ->
        true
    | _ -> false
end

(** 类型关键字转换器 - 整合自 token_conversion_types.ml *)
module TypeKeywords = struct
  let convert_type_keyword_token = function
    | Token_mapping.Token_definitions_unified.IntTypeKeyword -> Some IntTypeKeyword
    | Token_mapping.Token_definitions_unified.FloatTypeKeyword -> Some FloatTypeKeyword
    | Token_mapping.Token_definitions_unified.StringTypeKeyword -> Some StringTypeKeyword
    | Token_mapping.Token_definitions_unified.BoolTypeKeyword -> Some BoolTypeKeyword
    | Token_mapping.Token_definitions_unified.ListTypeKeyword -> Some ListTypeKeyword
    | Token_mapping.Token_definitions_unified.UnitTypeKeyword -> Some UnitTypeKeyword
    | Token_mapping.Token_definitions_unified.ArrayTypeKeyword -> Some ArrayTypeKeyword
    | _ -> None

  let is_type_keyword_token = function
    | Token_mapping.Token_definitions_unified.IntTypeKeyword
    | Token_mapping.Token_definitions_unified.FloatTypeKeyword
    | Token_mapping.Token_definitions_unified.StringTypeKeyword
    | Token_mapping.Token_definitions_unified.BoolTypeKeyword
    | Token_mapping.Token_definitions_unified.ListTypeKeyword
    | Token_mapping.Token_definitions_unified.UnitTypeKeyword
    | Token_mapping.Token_definitions_unified.ArrayTypeKeyword ->
        true
    | _ -> false
end

(** 基础语言关键字转换器 - 整合自 token_conversion_keywords_refactored.ml *)
module BasicKeywords = struct
  let convert_basic_language_keywords = function
    | Token_mapping.Token_definitions_unified.LetKeyword -> Some LetKeyword
    | Token_mapping.Token_definitions_unified.RecKeyword -> Some RecKeyword
    | Token_mapping.Token_definitions_unified.InKeyword -> Some InKeyword
    | Token_mapping.Token_definitions_unified.FunKeyword -> Some FunKeyword
    | Token_mapping.Token_definitions_unified.IfKeyword -> Some IfKeyword
    | Token_mapping.Token_definitions_unified.ThenKeyword -> Some ThenKeyword
    | Token_mapping.Token_definitions_unified.ElseKeyword -> Some ElseKeyword
    | Token_mapping.Token_definitions_unified.MatchKeyword -> Some MatchKeyword
    | Token_mapping.Token_definitions_unified.WithKeyword -> Some WithKeyword
    | Token_mapping.Token_definitions_unified.OtherKeyword -> Some OtherKeyword
    | Token_mapping.Token_definitions_unified.AndKeyword -> Some AndKeyword
    | Token_mapping.Token_definitions_unified.OrKeyword -> Some OrKeyword
    | Token_mapping.Token_definitions_unified.NotKeyword -> Some NotKeyword
    | Token_mapping.Token_definitions_unified.OfKeyword -> Some OfKeyword
    | _ -> None

  let is_basic_language_keyword = function
    | Token_mapping.Token_definitions_unified.LetKeyword
    | Token_mapping.Token_definitions_unified.RecKeyword
    | Token_mapping.Token_definitions_unified.InKeyword
    | Token_mapping.Token_definitions_unified.FunKeyword
    | Token_mapping.Token_definitions_unified.IfKeyword
    | Token_mapping.Token_definitions_unified.ThenKeyword
    | Token_mapping.Token_definitions_unified.ElseKeyword
    | Token_mapping.Token_definitions_unified.MatchKeyword
    | Token_mapping.Token_definitions_unified.WithKeyword
    | Token_mapping.Token_definitions_unified.OtherKeyword
    | Token_mapping.Token_definitions_unified.AndKeyword
    | Token_mapping.Token_definitions_unified.OrKeyword
    | Token_mapping.Token_definitions_unified.NotKeyword
    | Token_mapping.Token_definitions_unified.OfKeyword ->
        true
    | _ -> false
end

(** 语义关键字转换器 *)
module SemanticKeywords = struct
  let convert_semantic_keywords = function
    | Token_mapping.Token_definitions_unified.AsKeyword -> Some AsKeyword
    | Token_mapping.Token_definitions_unified.CombineKeyword -> Some CombineKeyword
    | Token_mapping.Token_definitions_unified.WithOpKeyword -> Some WithOpKeyword
    | Token_mapping.Token_definitions_unified.WhenKeyword -> Some WhenKeyword
    | _ -> None

  let is_semantic_keyword = function
    | Token_mapping.Token_definitions_unified.AsKeyword
    | Token_mapping.Token_definitions_unified.CombineKeyword
    | Token_mapping.Token_definitions_unified.WithOpKeyword
    | Token_mapping.Token_definitions_unified.WhenKeyword ->
        true
    | _ -> false
end

(** 错误恢复关键字转换器 *)
module ErrorRecoveryKeywords = struct
  let convert_error_recovery_keywords = function
    | Token_mapping.Token_definitions_unified.WithDefaultKeyword -> Some WithDefaultKeyword
    | Token_mapping.Token_definitions_unified.ExceptionKeyword -> Some ExceptionKeyword
    | Token_mapping.Token_definitions_unified.RaiseKeyword -> Some RaiseKeyword
    | Token_mapping.Token_definitions_unified.TryKeyword -> Some TryKeyword
    | Token_mapping.Token_definitions_unified.CatchKeyword -> Some CatchKeyword
    | Token_mapping.Token_definitions_unified.FinallyKeyword -> Some FinallyKeyword
    | _ -> None

  let is_error_recovery_keyword = function
    | Token_mapping.Token_definitions_unified.WithDefaultKeyword
    | Token_mapping.Token_definitions_unified.ExceptionKeyword
    | Token_mapping.Token_definitions_unified.RaiseKeyword
    | Token_mapping.Token_definitions_unified.TryKeyword
    | Token_mapping.Token_definitions_unified.CatchKeyword
    | Token_mapping.Token_definitions_unified.FinallyKeyword ->
        true
    | _ -> false
end

(** 模块系统关键字转换器 *)
module ModuleKeywords = struct
  let convert_module_keywords = function
    | Token_mapping.Token_definitions_unified.ModuleKeyword -> Some ModuleKeyword
    | Token_mapping.Token_definitions_unified.ModuleTypeKeyword -> Some ModuleTypeKeyword
    | Token_mapping.Token_definitions_unified.RefKeyword -> Some RefKeyword
    | Token_mapping.Token_definitions_unified.IncludeKeyword -> Some IncludeKeyword
    | Token_mapping.Token_definitions_unified.FunctorKeyword -> Some FunctorKeyword
    | Token_mapping.Token_definitions_unified.SigKeyword -> Some SigKeyword
    | Token_mapping.Token_definitions_unified.EndKeyword -> Some EndKeyword
    | Token_mapping.Token_definitions_unified.MacroKeyword -> Some MacroKeyword
    | Token_mapping.Token_definitions_unified.ExpandKeyword -> Some ExpandKeyword
    | Token_mapping.Token_definitions_unified.TypeKeyword -> Some TypeKeyword
    | Token_mapping.Token_definitions_unified.PrivateKeyword -> Some PrivateKeyword
    | Token_mapping.Token_definitions_unified.ParamKeyword -> Some ParamKeyword
    | _ -> None

  let is_module_keyword = function
    | Token_mapping.Token_definitions_unified.ModuleKeyword
    | Token_mapping.Token_definitions_unified.ModuleTypeKeyword
    | Token_mapping.Token_definitions_unified.RefKeyword
    | Token_mapping.Token_definitions_unified.IncludeKeyword
    | Token_mapping.Token_definitions_unified.FunctorKeyword
    | Token_mapping.Token_definitions_unified.SigKeyword
    | Token_mapping.Token_definitions_unified.EndKeyword
    | Token_mapping.Token_definitions_unified.MacroKeyword
    | Token_mapping.Token_definitions_unified.ExpandKeyword
    | Token_mapping.Token_definitions_unified.TypeKeyword
    | Token_mapping.Token_definitions_unified.PrivateKeyword
    | Token_mapping.Token_definitions_unified.ParamKeyword ->
        true
    | _ -> false
end

(** 现代语言转换策略 *)
type modern_conversion_strategy =
  | Fast  (** 性能优先：使用直接模式匹配 *)
  | Readable  (** 可读性优先：使用分类函数 *)
  | Balanced  (** 平衡模式：结合性能和可读性 *)

(** 统一的现代语言转换接口 *)
let rec convert_modern_token ?(strategy = Balanced) token =
  match strategy with
  | Fast -> (
      (* 性能优先：直接模式匹配，按使用频率排序 *)
      match token with
      (* 最常用的基础关键字 *)
      | Token_mapping.Token_definitions_unified.LetKeyword -> Some LetKeyword
      | Token_mapping.Token_definitions_unified.FunKeyword -> Some FunKeyword
      | Token_mapping.Token_definitions_unified.IfKeyword -> Some IfKeyword
      | Token_mapping.Token_definitions_unified.ThenKeyword -> Some ThenKeyword
      | Token_mapping.Token_definitions_unified.ElseKeyword -> Some ElseKeyword
      (* 常用字面量 *)
      | Token_mapping.Token_definitions_unified.IntToken i -> Some (IntToken i)
      | Token_mapping.Token_definitions_unified.StringToken s -> Some (StringToken s)
      | Token_mapping.Token_definitions_unified.BoolToken b -> Some (BoolToken b)
      (* 标识符 *)
      | Token_mapping.Token_definitions_unified.QuotedIdentifierToken s ->
          Some (QuotedIdentifierToken s)
      | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial s ->
          Some (IdentifierTokenSpecial s)
      (* 其他情况 *)
      | _ -> None)
  | Readable ->
      (* 可读性优先：使用分类函数，便于维护 *)
      let converters =
        [
          Identifiers.convert_identifier_token;
          Literals.convert_literal_token;
          BasicKeywords.convert_basic_language_keywords;
          TypeKeywords.convert_type_keyword_token;
          SemanticKeywords.convert_semantic_keywords;
          ErrorRecoveryKeywords.convert_error_recovery_keywords;
          ModuleKeywords.convert_module_keywords;
        ]
      in
      let rec try_converters = function
        | [] -> None
        | converter :: rest -> (
            match converter token with Some result -> Some result | None -> try_converters rest)
      in
      try_converters converters
  | Balanced -> (
      (* 平衡模式：先快速路径，后分类转换 *)
      match token with
      (* 快速路径：最常用的token *)
      | Token_mapping.Token_definitions_unified.LetKeyword -> Some LetKeyword
      | Token_mapping.Token_definitions_unified.FunKeyword -> Some FunKeyword
      | Token_mapping.Token_definitions_unified.IfKeyword -> Some IfKeyword
      | Token_mapping.Token_definitions_unified.IntToken i -> Some (IntToken i)
      | Token_mapping.Token_definitions_unified.StringToken s -> Some (StringToken s)
      | _ ->
          (* 其他情况使用分类转换 *)
          convert_modern_token ~strategy:Readable token)

(** 检查是否为现代语言token *)
let is_modern_token token = match convert_modern_token token with Some _ -> true | None -> false

(** 获取现代语言token类别 *)
let get_modern_token_category token =
  if Identifiers.is_identifier_token token then Some Identifier
  else if Literals.is_literal_token token then Some Literal
  else if BasicKeywords.is_basic_language_keyword token then Some BasicKeyword
  else if TypeKeywords.is_type_keyword_token token then Some TypeKeyword
  else if SemanticKeywords.is_semantic_keyword token then Some Semantic
  else if ModuleKeywords.is_module_keyword token then Some ModuleSystem
  else if ErrorRecoveryKeywords.is_error_recovery_keyword token then Some ErrorRecovery
  else None

(** 向后兼容性接口 *)
module BackwardCompatibility = struct
  (* 保持原有的分类转换函数 *)
  let convert_identifier_token token =
    match Identifiers.convert_identifier_token token with
    | Some result -> result
    | None -> raise (Unknown_modern_token "不是标识符token")

  let convert_literal_token token =
    match Literals.convert_literal_token token with
    | Some result -> result
    | None -> raise (Unknown_modern_token "不是字面量token")

  let convert_basic_keyword_token token =
    match BasicKeywords.convert_basic_language_keywords token with
    | Some result -> result
    | None -> raise (Unknown_modern_token "不是基础关键字token")

  let convert_type_keyword_token token =
    match TypeKeywords.convert_type_keyword_token token with
    | Some result -> result
    | None -> raise (Unknown_modern_token "不是类型关键字token")

  (* 主转换函数 *)
  let convert_modern_token_exn token =
    match convert_modern_token token with
    | Some result -> result
    | None -> raise (Unknown_modern_token "未知的现代语言token")
end

(** 性能统计模块 *)
module Statistics = struct
  let get_modern_stats () =
    let category_counts =
      [
        ("标识符类型", 2);
        (* QuotedIdentifierToken, IdentifierTokenSpecial *)
        ("字面量类型", 5);
        (* IntToken, FloatToken, ChineseNumberToken, StringToken, BoolToken *)
        ("基础关键字类型", 14);
        (* LetKeyword, RecKeyword, InKeyword, etc. *)
        ("类型关键字类型", 13);
        (* IntTypeKeyword, FloatTypeKeyword, etc. *)
        ("语义关键字类型", 4);
        (* AsKeyword, CombineKeyword, etc. *)
        ("错误恢复关键字类型", 6);
        (* WithDefaultKeyword, ExceptionKeyword, etc. *)
        ("模块系统关键字类型", 12);
        (* ModuleKeyword, ModuleTypeKeyword, etc. *)
      ]
    in
    let total = List.fold_left (fun acc (_, count) -> acc + count) 0 category_counts in
    let details =
      String.concat "\n"
        (List.map (fun (name, count) -> Printf.sprintf "- %s: %d" name count) category_counts)
    in
    Printf.sprintf {|现代语言转换统计信息:
%s
- 总计: %d|} details total
end
