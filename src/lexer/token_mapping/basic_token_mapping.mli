(** 基础关键字Token映射模块 *)

open Token_definitions

(** 映射基础关键字变体到Token
    @param variant 基础关键字变体
    @return 对应的Token
    @raise Failure 如果遇到未知的基础关键字变体 *)
val map_basic_variant : [> `LetKeyword | `RecKeyword | `InKeyword | `FunKeyword | `IfKeyword | `ThenKeyword | `ElseKeyword 
                        | `MatchKeyword | `WithKeyword | `OtherKeyword | `AndKeyword | `OrKeyword | `NotKeyword | `OfKeyword 
                        | `TrueKeyword | `FalseKeyword | `AsKeyword | `CombineKeyword | `WithOpKeyword | `WhenKeyword
                        | `WithDefaultKeyword | `ExceptionKeyword | `RaiseKeyword | `TryKeyword | `CatchKeyword | `FinallyKeyword
                        | `ModuleKeyword | `ModuleTypeKeyword | `RefKeyword | `IncludeKeyword | `FunctorKeyword | `SigKeyword 
                        | `EndKeyword | `MacroKeyword | `ExpandKeyword ] -> token