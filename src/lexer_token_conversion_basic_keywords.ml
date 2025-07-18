(** 基础关键字Token转换模块 *)

open Lexer_tokens

(** 转换基础关键字tokens *)
let convert_basic_keyword_token = function
  (* 基础关键字 *)
  | Token_mapping.Token_definitions.LetKeyword -> LetKeyword
  | Token_mapping.Token_definitions.RecKeyword -> RecKeyword
  | Token_mapping.Token_definitions.InKeyword -> InKeyword
  | Token_mapping.Token_definitions.FunKeyword -> FunKeyword
  | Token_mapping.Token_definitions.IfKeyword -> IfKeyword
  | Token_mapping.Token_definitions.ThenKeyword -> ThenKeyword
  | Token_mapping.Token_definitions.ElseKeyword -> ElseKeyword
  | Token_mapping.Token_definitions.MatchKeyword -> MatchKeyword
  | Token_mapping.Token_definitions.WithKeyword -> WithKeyword
  | Token_mapping.Token_definitions.OtherKeyword -> OtherKeyword
  | Token_mapping.Token_definitions.AndKeyword -> AndKeyword
  | Token_mapping.Token_definitions.OrKeyword -> OrKeyword
  | Token_mapping.Token_definitions.NotKeyword -> NotKeyword
  | Token_mapping.Token_definitions.OfKeyword -> OfKeyword
  (* 语义关键字 *)
  | Token_mapping.Token_definitions.AsKeyword -> AsKeyword
  | Token_mapping.Token_definitions.CombineKeyword -> CombineKeyword
  | Token_mapping.Token_definitions.WithOpKeyword -> WithOpKeyword
  | Token_mapping.Token_definitions.WhenKeyword -> WhenKeyword
  (* 错误恢复关键字 *)
  | Token_mapping.Token_definitions.WithDefaultKeyword -> WithDefaultKeyword
  | Token_mapping.Token_definitions.ExceptionKeyword -> ExceptionKeyword
  | Token_mapping.Token_definitions.RaiseKeyword -> RaiseKeyword
  | Token_mapping.Token_definitions.TryKeyword -> TryKeyword
  | Token_mapping.Token_definitions.CatchKeyword -> CatchKeyword
  | Token_mapping.Token_definitions.FinallyKeyword -> FinallyKeyword
  (* 模块关键字 *)
  | Token_mapping.Token_definitions.ModuleKeyword -> ModuleKeyword
  | Token_mapping.Token_definitions.ModuleTypeKeyword -> ModuleTypeKeyword
  | Token_mapping.Token_definitions.RefKeyword -> RefKeyword
  | Token_mapping.Token_definitions.IncludeKeyword -> IncludeKeyword
  | Token_mapping.Token_definitions.FunctorKeyword -> FunctorKeyword
  | Token_mapping.Token_definitions.SigKeyword -> SigKeyword
  | Token_mapping.Token_definitions.EndKeyword -> EndKeyword
  (* 宏关键字 *)
  | Token_mapping.Token_definitions.MacroKeyword -> MacroKeyword
  | Token_mapping.Token_definitions.ExpandKeyword -> ExpandKeyword
  | _ -> failwith "Not a basic keyword token"