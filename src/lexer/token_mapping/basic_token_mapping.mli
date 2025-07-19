(** 基础关键字Token映射模块 - 使用统一token定义 *)

open Token_definitions_unified

(** {1 基础关键字映射} *)

val map_basic_variant :
  [> `LetKeyword
  | `RecKeyword
  | `InKeyword
  | `FunKeyword
  | `IfKeyword
  | `ThenKeyword
  | `ElseKeyword
  | `MatchKeyword
  | `WithKeyword
  | `OtherKeyword
  | `AndKeyword
  | `OrKeyword
  | `NotKeyword
  | `OfKeyword
  | `TrueKeyword
  | `FalseKeyword
  | `AsKeyword
  | `CombineKeyword
  | `WithOpKeyword
  | `WhenKeyword
  | `WithDefaultKeyword
  | `ExceptionKeyword
  | `RaiseKeyword
  | `TryKeyword
  | `CatchKeyword
  | `FinallyKeyword
  | `ModuleKeyword
  | `ModuleTypeKeyword
  | `RefKeyword
  | `IncludeKeyword
  | `FunctorKeyword
  | `SigKeyword
  | `EndKeyword
  | `MacroKeyword
  | `ExpandKeyword ] ->
  token
(** 映射基础关键字变体到Token *)
