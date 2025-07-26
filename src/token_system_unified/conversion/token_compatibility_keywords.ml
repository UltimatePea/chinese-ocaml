(** Token兼容性关键字映射模块 - Issue #646 技术债务清理

    此模块负责处理各种类型的关键字映射，从传统语法到文言文、古雅体等的转换。 这是从 token_compatibility.ml 中提取出来的专门模块，提升代码可维护性。

    @author 骆言技术债务清理团队 Issue #646
    @version 1.0
    @since 2025-07-20 *)

open Yyocamlc_lib.Unified_token_core

(** 基础关键字映射 *)
let map_basic_keywords = function
  | "let" -> Some LetKeyword
  | "rec" -> Some RecKeyword
  | "in" -> Some InKeyword
  | "fun" -> Some FunKeyword
  | "if" -> Some IfKeyword
  | "then" -> Some ThenKeyword
  | "else" -> Some ElseKeyword
  | "match" -> Some MatchKeyword
  | "with" -> Some WithKeyword
  | "true" -> Some TrueKeyword
  | "false" -> Some FalseKeyword
  | "and" -> Some AndKeyword
  | "or" -> Some OrKeyword
  | "not" -> Some NotKeyword
  | "type" -> Some TypeKeyword
  | "module" -> Some ModuleKeyword
  | "ref" -> Some RefKeyword
  | "as" -> Some AsKeyword
  | "of" -> Some OfKeyword
  | _ -> None

(** 文言文关键字映射 *)
let map_wenyan_keywords = function
  | "HaveKeyword" -> Some LetKeyword (* 吾有 -> 让 *)
  | "SetKeyword" -> Some LetKeyword (* 设 -> 让 *)
  | "OneKeyword" -> Some OneKeyword
  | "NameKeyword" -> Some AsKeyword (* 名曰 -> 作为 *)
  | "AlsoKeyword" -> Some AndKeyword (* 也 -> 并且 *)
  | "ThenGetKeyword" -> Some ThenKeyword (* 乃 -> 那么 *)
  | "CallKeyword" -> Some FunKeyword (* 曰 -> 函数 *)
  | "ValueKeyword" -> Some ValKeyword
  | "AsForKeyword" -> Some AsKeyword (* 为 -> 作为 *)
  | "NumberKeyword" -> Some (ChineseNumberToken "") (* 特殊处理 *)
  | "IfWenyanKeyword" -> Some WenyanIfKeyword
  | "ThenWenyanKeyword" -> Some WenyanThenKeyword
  | _ -> None

(** 古雅体关键字映射 *)
let map_classical_keywords = function
  | "AncientDefineKeyword" -> Some ClassicalFunctionKeyword
  | "AncientObserveKeyword" -> Some MatchKeyword (* 观 -> 匹配 *)
  | "AncientIfKeyword" -> Some ClassicalIfKeyword
  | "AncientThenKeyword" -> Some ClassicalThenKeyword
  | "AncientListStartKeyword" -> Some LeftBracket
  | "AncientEndKeyword" -> Some EndKeyword
  | "AncientIsKeyword" -> Some EqualOp (* 乃 -> = *)
  | "AncientArrowKeyword" -> Some ArrowOp (* 故 -> -> *)
  | _ -> None

(** 自然语言函数关键字映射 *)
let map_natural_language_keywords = function
  | "DefineKeyword" -> Some FunKeyword
  | "AcceptKeyword" -> Some InKeyword
  | "ReturnWhenKeyword" -> Some ThenKeyword
  | "ElseReturnKeyword" -> Some ElseKeyword
  | "IsKeyword" -> Some EqualOp
  | "EqualToKeyword" -> Some EqualOp
  | "EmptyKeyword" -> Some UnitToken
  | "InputKeyword" -> Some InKeyword
  | "OutputKeyword" -> Some ReturnKeyword
  | _ -> None

(** 类型关键字映射 *)
let map_type_keywords = function
  | "IntTypeKeyword" -> Some IntTypeKeyword
  | "FloatTypeKeyword" -> Some FloatTypeKeyword
  | "StringTypeKeyword" -> Some StringTypeKeyword
  | "BoolTypeKeyword" -> Some BoolTypeKeyword
  | "UnitTypeKeyword" -> Some UnitTypeKeyword
  | "ListTypeKeyword" -> Some ListTypeKeyword
  | "ArrayTypeKeyword" -> Some ArrayTypeKeyword
  | _ -> None

(** 诗词关键字映射 - 暂时不支持专门的诗词Token *)
let map_poetry_keywords = function
  | "RhymeKeyword" -> None (* 暂时不支持 *)
  | "ToneKeyword" -> None (* 暂时不支持 *)
  | "MeterKeyword" -> None (* 暂时不支持 *)
  | "ArtisticKeyword" -> None (* 暂时不支持 *)
  | "StyleKeyword" -> None (* 暂时不支持 *)
  | "FormKeyword" -> None (* 暂时不支持 *)
  | "PoetryKeyword" -> None (* 暂时不支持 *)
  | _ -> None

(** 杂项关键字映射 *)
let map_misc_keywords = function
  | "TryKeyword" -> Some TryKeyword
  | "CatchKeyword" -> None (* 不支持，OCaml使用with *)
  | "FinallyKeyword" -> None (* 不支持 *)
  | "ThrowKeyword" -> Some RaiseKeyword (* throw -> raise *)
  | "EndKeyword" -> Some EndKeyword
  | "WhileKeyword" -> Some WhileKeyword
  | "ForKeyword" -> Some ForKeyword
  | "DoKeyword" -> Some DoKeyword
  | "BreakKeyword" -> Some BreakKeyword
  | "ContinueKeyword" -> Some ContinueKeyword
  | "ReturnKeyword" -> Some ReturnKeyword
  | "ValKeyword" -> Some ValKeyword
  | "OneKeyword" -> Some OneKeyword
  | _ -> None

(** 统一关键字映射接口 *)
let map_legacy_keyword_to_unified keyword_str =
  match map_basic_keywords keyword_str with
  | Some token -> Some token
  | None -> (
      match map_wenyan_keywords keyword_str with
      | Some token -> Some token
      | None -> (
          match map_classical_keywords keyword_str with
          | Some token -> Some token
          | None -> (
              match map_natural_language_keywords keyword_str with
              | Some token -> Some token
              | None -> (
                  match map_type_keywords keyword_str with
                  | Some token -> Some token
                  | None -> (
                      match map_poetry_keywords keyword_str with
                      | Some token -> Some token
                      | None -> map_misc_keywords keyword_str)))))
