(** Token转换 - 关键字专门模块
    
    从token_conversion_core.ml中提取的关键字转换逻辑，
    使用统一的模式匹配优化性能，避免异常开销。
    
    @author 骆言技术债务清理团队 Issue #1256
    @version 1.0
    @since 2025-07-25 *)

open Lexer_tokens

(** 异常定义 *)
exception Unknown_keyword_token of string

(** 转换基础关键字tokens - 使用统一模式匹配优化性能 *)
let convert_basic_keyword_token = function
  (* 基础语言关键字 *)
  | Token_mapping.Token_definitions_unified.LetKeyword -> LetKeyword
  | Token_mapping.Token_definitions_unified.RecKeyword -> RecKeyword
  | Token_mapping.Token_definitions_unified.InKeyword -> InKeyword
  | Token_mapping.Token_definitions_unified.FunKeyword -> FunKeyword
  | Token_mapping.Token_definitions_unified.IfKeyword -> IfKeyword
  | Token_mapping.Token_definitions_unified.ThenKeyword -> ThenKeyword
  | Token_mapping.Token_definitions_unified.ElseKeyword -> ElseKeyword
  | Token_mapping.Token_definitions_unified.MatchKeyword -> MatchKeyword
  | Token_mapping.Token_definitions_unified.WithKeyword -> WithKeyword
  | Token_mapping.Token_definitions_unified.OtherKeyword -> OtherKeyword
  | Token_mapping.Token_definitions_unified.AndKeyword -> AndKeyword
  | Token_mapping.Token_definitions_unified.OrKeyword -> OrKeyword
  | Token_mapping.Token_definitions_unified.NotKeyword -> NotKeyword
  | Token_mapping.Token_definitions_unified.OfKeyword -> OfKeyword
  
  (* 语义关键字 *)
  | Token_mapping.Token_definitions_unified.AsKeyword -> AsKeyword
  | Token_mapping.Token_definitions_unified.CombineKeyword -> CombineKeyword
  | Token_mapping.Token_definitions_unified.WithOpKeyword -> WithOpKeyword
  | Token_mapping.Token_definitions_unified.WhenKeyword -> WhenKeyword
  
  (* 错误恢复关键字 *)
  | Token_mapping.Token_definitions_unified.WithDefaultKeyword -> WithDefaultKeyword
  | Token_mapping.Token_definitions_unified.ExceptionKeyword -> ExceptionKeyword
  | Token_mapping.Token_definitions_unified.RaiseKeyword -> RaiseKeyword
  | Token_mapping.Token_definitions_unified.TryKeyword -> TryKeyword
  | Token_mapping.Token_definitions_unified.CatchKeyword -> CatchKeyword
  | Token_mapping.Token_definitions_unified.FinallyKeyword -> FinallyKeyword
  
  (* 模块系统关键字 *)
  | Token_mapping.Token_definitions_unified.ModuleKeyword -> ModuleKeyword
  | Token_mapping.Token_definitions_unified.ModuleTypeKeyword -> ModuleTypeKeyword
  | Token_mapping.Token_definitions_unified.RefKeyword -> RefKeyword
  | Token_mapping.Token_definitions_unified.IncludeKeyword -> IncludeKeyword
  | Token_mapping.Token_definitions_unified.FunctorKeyword -> FunctorKeyword
  | Token_mapping.Token_definitions_unified.SigKeyword -> SigKeyword
  | Token_mapping.Token_definitions_unified.EndKeyword -> EndKeyword
  | Token_mapping.Token_definitions_unified.MacroKeyword -> MacroKeyword
  | Token_mapping.Token_definitions_unified.ExpandKeyword -> ExpandKeyword
  | Token_mapping.Token_definitions_unified.TypeKeyword -> TypeKeyword
  | Token_mapping.Token_definitions_unified.PrivateKeyword -> PrivateKeyword
  | Token_mapping.Token_definitions_unified.ParamKeyword -> ParamKeyword
  
  (* 自然语言关键字 *)
  | Token_mapping.Token_definitions_unified.NaturalConditionalKeyword -> NaturalConditionalKeyword
  | Token_mapping.Token_definitions_unified.NaturalLoopKeyword -> NaturalLoopKeyword
  | Token_mapping.Token_definitions_unified.NaturalDeclarationKeyword -> NaturalDeclarationKeyword
  | Token_mapping.Token_definitions_unified.NaturalAssignmentKeyword -> NaturalAssignmentKeyword
  | Token_mapping.Token_definitions_unified.NaturalOperationKeyword -> NaturalOperationKeyword
  | Token_mapping.Token_definitions_unified.NaturalLogicalKeyword -> NaturalLogicalKeyword
  | Token_mapping.Token_definitions_unified.NaturalControlKeyword -> NaturalControlKeyword
  | Token_mapping.Token_definitions_unified.NaturalFunctionKeyword -> NaturalFunctionKeyword
  | Token_mapping.Token_definitions_unified.NaturalDataKeyword -> NaturalDataKeyword
  | Token_mapping.Token_definitions_unified.NaturalComparisionKeyword -> NaturalComparisionKeyword
  | Token_mapping.Token_definitions_unified.NaturalFileKeyword -> NaturalFileKeyword
  | Token_mapping.Token_definitions_unified.NaturalStringKeyword -> NaturalStringKeyword
  | Token_mapping.Token_definitions_unified.NaturalNumberKeyword -> NaturalNumberKeyword
  | Token_mapping.Token_definitions_unified.NaturalBooleanKeyword -> NaturalBooleanKeyword
  | Token_mapping.Token_definitions_unified.NaturalListKeyword -> NaturalListKeyword
  | Token_mapping.Token_definitions_unified.NaturalRecordKeyword -> NaturalRecordKeyword
  | Token_mapping.Token_definitions_unified.NaturalTupleKeyword -> NaturalTupleKeyword
  | Token_mapping.Token_definitions_unified.NaturalVariantKeyword -> NaturalVariantKeyword
  | Token_mapping.Token_definitions_unified.NaturalModuleKeyword -> NaturalModuleKeyword
  | Token_mapping.Token_definitions_unified.NaturalTypeKeyword -> NaturalTypeKeyword
  
  (* 文言文关键字 *)
  | Token_mapping.Token_definitions_unified.WenyanConditionalKeyword -> WenyanConditionalKeyword
  | Token_mapping.Token_definitions_unified.WenyanLoopKeyword -> WenyanLoopKeyword
  | Token_mapping.Token_definitions_unified.WenyanDeclarationKeyword -> WenyanDeclarationKeyword
  | Token_mapping.Token_definitions_unified.WenyanAssignmentKeyword -> WenyanAssignmentKeyword
  | Token_mapping.Token_definitions_unified.WenyanOperationKeyword -> WenyanOperationKeyword
  | Token_mapping.Token_definitions_unified.WenyanLogicalKeyword -> WenyanLogicalKeyword
  | Token_mapping.Token_definitions_unified.WenyanControlKeyword -> WenyanControlKeyword
  | Token_mapping.Token_definitions_unified.WenyanFunctionKeyword -> WenyanFunctionKeyword
  | Token_mapping.Token_definitions_unified.WenyanDataKeyword -> WenyanDataKeyword
  | Token_mapping.Token_definitions_unified.WenyanComparisionKeyword -> WenyanComparisionKeyword
  | Token_mapping.Token_definitions_unified.WenyanFileKeyword -> WenyanFileKeyword
  | Token_mapping.Token_definitions_unified.WenyanStringKeyword -> WenyanStringKeyword
  | Token_mapping.Token_definitions_unified.WenyanNumberKeyword -> WenyanNumberKeyword
  | Token_mapping.Token_definitions_unified.WenyanBooleanKeyword -> WenyanBooleanKeyword
  | Token_mapping.Token_definitions_unified.WenyanListKeyword -> WenyanListKeyword
  | Token_mapping.Token_definitions_unified.WenyanRecordKeyword -> WenyanRecordKeyword
  | Token_mapping.Token_definitions_unified.WenyanTupleKeyword -> WenyanTupleKeyword
  | Token_mapping.Token_definitions_unified.WenyanVariantKeyword -> WenyanVariantKeyword
  | Token_mapping.Token_definitions_unified.WenyanModuleKeyword -> WenyanModuleKeyword
  | Token_mapping.Token_definitions_unified.WenyanTypeKeyword -> WenyanTypeKeyword
  
  (* 古雅体关键字 - 第一部分 *)
  | Token_mapping.Token_definitions_unified.AncientConditionalKeyword -> AncientConditionalKeyword
  | Token_mapping.Token_definitions_unified.AncientLoopKeyword -> AncientLoopKeyword
  | Token_mapping.Token_definitions_unified.AncientDeclarationKeyword -> AncientDeclarationKeyword
  | Token_mapping.Token_definitions_unified.AncientAssignmentKeyword -> AncientAssignmentKeyword
  | Token_mapping.Token_definitions_unified.AncientOperationKeyword -> AncientOperationKeyword
  | Token_mapping.Token_definitions_unified.AncientLogicalKeyword -> AncientLogicalKeyword
  | Token_mapping.Token_definitions_unified.AncientControlKeyword -> AncientControlKeyword
  | Token_mapping.Token_definitions_unified.AncientFunctionKeyword -> AncientFunctionKeyword
  | Token_mapping.Token_definitions_unified.AncientDataKeyword -> AncientDataKeyword
  | Token_mapping.Token_definitions_unified.AncientComparisionKeyword -> AncientComparisionKeyword
  | Token_mapping.Token_definitions_unified.AncientFileKeyword -> AncientFileKeyword
  | Token_mapping.Token_definitions_unified.AncientStringKeyword -> AncientStringKeyword
  | Token_mapping.Token_definitions_unified.AncientNumberKeyword -> AncientNumberKeyword
  | Token_mapping.Token_definitions_unified.AncientBooleanKeyword -> AncientBooleanKeyword
  | Token_mapping.Token_definitions_unified.AncientListKeyword -> AncientListKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordKeyword -> AncientRecordKeyword
  | Token_mapping.Token_definitions_unified.AncientTupleKeyword -> AncientTupleKeyword
  | Token_mapping.Token_definitions_unified.AncientVariantKeyword -> AncientVariantKeyword
  | Token_mapping.Token_definitions_unified.AncientModuleKeyword -> AncientModuleKeyword
  | Token_mapping.Token_definitions_unified.AncientTypeKeyword -> AncientTypeKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordStartKeyword -> AncientRecordStartKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordMiddleKeyword -> AncientRecordMiddleKeyword
  | Token_mapping.Token_definitions_unified.AncientRecordFinishKeyword -> AncientRecordFinishKeyword
  | Token_mapping.Token_definitions_unified.AncientVariantStartKeyword -> AncientVariantStartKeyword
  | Token_mapping.Token_definitions_unified.AncientVariantMiddleKeyword -> AncientVariantMiddleKeyword
  | Token_mapping.Token_definitions_unified.AncientVariantFinishKeyword -> AncientVariantFinishKeyword
  | Token_mapping.Token_definitions_unified.AncientTupleStartKeyword -> AncientTupleStartKeyword
  | Token_mapping.Token_definitions_unified.AncientTupleMiddleKeyword -> AncientTupleMiddleKeyword
  | Token_mapping.Token_definitions_unified.AncientTupleFinishKeyword -> AncientTupleFinishKeyword
  | Token_mapping.Token_definitions_unified.AncientListStartKeyword -> AncientListStartKeyword
  | Token_mapping.Token_definitions_unified.AncientListMiddleKeyword -> AncientListMiddleKeyword
  | Token_mapping.Token_definitions_unified.AncientListFinishKeyword -> AncientListFinishKeyword
  | Token_mapping.Token_definitions_unified.AncientFunctionStartKeyword -> AncientFunctionStartKeyword
  | Token_mapping.Token_definitions_unified.AncientFunctionFinishKeyword -> AncientFunctionFinishKeyword
  
  | token -> 
      let error_msg = "不是基础关键字token: " ^ (Obj.tag (Obj.repr token) |> string_of_int) in
      raise (Unknown_keyword_token error_msg)

(** 检查是否为基础关键字token *)
let is_basic_keyword_token token =
  try 
    let _ = convert_basic_keyword_token token in 
    true
  with Unknown_keyword_token _ -> false

(** 安全转换基础关键字token（返回Option类型） *)
let convert_basic_keyword_token_safe token =
  try Some (convert_basic_keyword_token token)
  with Unknown_keyword_token _ -> None