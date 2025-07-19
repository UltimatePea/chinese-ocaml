(** 基础关键字Token映射模块 - 使用统一token定义 *)

open Token_definitions_unified

(** 映射基础关键字变体到Token - 消除重复后的简化版本 *)
let map_basic_variant = function
  (* Basic keywords *)
  | `LetKeyword -> LetKeyword
  | `RecKeyword -> RecKeyword
  | `InKeyword -> InKeyword
  | `FunKeyword -> FunKeyword
  | `IfKeyword -> IfKeyword
  | `ThenKeyword -> ThenKeyword
  | `ElseKeyword -> ElseKeyword
  | `MatchKeyword -> MatchKeyword
  | `WithKeyword -> WithKeyword
  | `OtherKeyword -> OtherKeyword
  | `AndKeyword -> AndKeyword
  | `OrKeyword -> OrKeyword
  | `NotKeyword -> NotKeyword
  | `OfKeyword -> OfKeyword
  | `TrueKeyword -> BoolToken true
  | `FalseKeyword -> BoolToken false
  (* Semantic keywords *)
  | `AsKeyword -> AsKeyword
  | `CombineKeyword -> CombineKeyword
  | `WithOpKeyword -> WithOpKeyword
  | `WhenKeyword -> WhenKeyword
  (* Error recovery keywords *)
  | `WithDefaultKeyword -> WithDefaultKeyword
  | `ExceptionKeyword -> ExceptionKeyword
  | `RaiseKeyword -> RaiseKeyword
  | `TryKeyword -> TryKeyword
  | `CatchKeyword -> CatchKeyword
  | `FinallyKeyword -> FinallyKeyword
  (* Module keywords *)
  | `ModuleKeyword -> ModuleKeyword
  | `ModuleTypeKeyword -> ModuleTypeKeyword
  | `RefKeyword -> RefKeyword
  | `IncludeKeyword -> IncludeKeyword
  | `FunctorKeyword -> FunctorKeyword
  | `SigKeyword -> SigKeyword
  | `EndKeyword -> EndKeyword
  (* Macro keywords *)
  | `MacroKeyword -> MacroKeyword
  | `ExpandKeyword -> ExpandKeyword
  | _ -> failwith "Unknown basic keyword variant"
