(** Token转换 - 关键字专门模块 - 重构版本 v3.0
    
    最新重构目标：
    1. 消除Fast策略中的大量代码重复
    2. 将古雅体关键字进一步模块化，按功能分组
    3. 添加Result类型支持，提供更安全的错误处理
    4. 保持向后兼容性和性能优化
    
    @author Charlie, 规划代理 - v3.0 重构
    @author Alpha, 主要工作代理 - v2.0 重构
    @version 3.0
    @since 2025-07-26
    @refactors Issue #1406 (v3.0), Issue #1333 (v2.0) *)

open Lexer_tokens

exception Unknown_keyword_token of string
(** 异常定义 *)

(** Result类型定义，用于更好的错误处理 *)
type 'a keyword_result = 
  | Success of 'a
  | Keyword_Error of string

(** 转换基础语言关键字 (let, fun, if等) *)
let convert_basic_language_keywords = function
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
  | _token -> raise (Unknown_keyword_token "不是基础语言关键字")

(** 转换语义关键字 (as, combine等) *)
let convert_semantic_keywords = function
  | Token_mapping.Token_definitions_unified.AsKeyword -> AsKeyword
  | Token_mapping.Token_definitions_unified.CombineKeyword -> CombineKeyword
  | Token_mapping.Token_definitions_unified.WithOpKeyword -> WithOpKeyword
  | Token_mapping.Token_definitions_unified.WhenKeyword -> WhenKeyword
  | _token -> raise (Unknown_keyword_token "不是语义关键字")

(** 转换错误恢复关键字 (try, catch等) *)
let convert_error_recovery_keywords = function
  | Token_mapping.Token_definitions_unified.WithDefaultKeyword -> WithDefaultKeyword
  | Token_mapping.Token_definitions_unified.ExceptionKeyword -> ExceptionKeyword
  | Token_mapping.Token_definitions_unified.RaiseKeyword -> RaiseKeyword
  | Token_mapping.Token_definitions_unified.TryKeyword -> TryKeyword
  | Token_mapping.Token_definitions_unified.CatchKeyword -> CatchKeyword
  | Token_mapping.Token_definitions_unified.FinallyKeyword -> FinallyKeyword
  | _token -> raise (Unknown_keyword_token "不是错误恢复关键字")

(** 转换模块系统关键字 (module, include等) *)
let convert_module_keywords = function
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
  | _token -> raise (Unknown_keyword_token "不是模块系统关键字")

(** 转换自然语言关键字 *)
let convert_natural_language_keywords = function
  | Token_mapping.Token_definitions_unified.DefineKeyword -> DefineKeyword
  | Token_mapping.Token_definitions_unified.AcceptKeyword -> AcceptKeyword
  | Token_mapping.Token_definitions_unified.ReturnWhenKeyword -> ReturnWhenKeyword
  | Token_mapping.Token_definitions_unified.ElseReturnKeyword -> ElseReturnKeyword
  | Token_mapping.Token_definitions_unified.MultiplyKeyword -> MultiplyKeyword
  | Token_mapping.Token_definitions_unified.DivideKeyword -> DivideKeyword
  | Token_mapping.Token_definitions_unified.AddToKeyword -> AddToKeyword
  | Token_mapping.Token_definitions_unified.SubtractKeyword -> SubtractKeyword
  | Token_mapping.Token_definitions_unified.EqualToKeyword -> EqualToKeyword
  | Token_mapping.Token_definitions_unified.LessThanEqualToKeyword -> LessThanEqualToKeyword
  | Token_mapping.Token_definitions_unified.FirstElementKeyword -> FirstElementKeyword
  | Token_mapping.Token_definitions_unified.RemainingKeyword -> RemainingKeyword
  | Token_mapping.Token_definitions_unified.EmptyKeyword -> EmptyKeyword
  | Token_mapping.Token_definitions_unified.CharacterCountKeyword -> CharacterCountKeyword
  | Token_mapping.Token_definitions_unified.OfParticle -> OfParticle
  | Token_mapping.Token_definitions_unified.MinusOneKeyword -> MinusOneKeyword
  | Token_mapping.Token_definitions_unified.PlusKeyword -> PlusKeyword
  | Token_mapping.Token_definitions_unified.WhereKeyword -> WhereKeyword
  | Token_mapping.Token_definitions_unified.SmallKeyword -> SmallKeyword
  | Token_mapping.Token_definitions_unified.ShouldGetKeyword -> ShouldGetKeyword
  | _token -> raise (Unknown_keyword_token "不是自然语言关键字")

(** 转换文言文关键字 *)
let convert_wenyan_keywords = function
  | Token_mapping.Token_definitions_unified.HaveKeyword -> HaveKeyword
  | Token_mapping.Token_definitions_unified.OneKeyword -> OneKeyword
  | Token_mapping.Token_definitions_unified.NameKeyword -> NameKeyword
  | Token_mapping.Token_definitions_unified.SetKeyword -> SetKeyword
  | Token_mapping.Token_definitions_unified.AlsoKeyword -> AlsoKeyword
  | Token_mapping.Token_definitions_unified.ThenGetKeyword -> ThenGetKeyword
  | Token_mapping.Token_definitions_unified.CallKeyword -> CallKeyword
  | Token_mapping.Token_definitions_unified.ValueKeyword -> ValueKeyword
  | Token_mapping.Token_definitions_unified.AsForKeyword -> AsForKeyword
  | Token_mapping.Token_definitions_unified.NumberKeyword -> NumberKeyword
  | Token_mapping.Token_definitions_unified.WantExecuteKeyword -> WantExecuteKeyword
  | Token_mapping.Token_definitions_unified.MustFirstGetKeyword -> MustFirstGetKeyword
  | Token_mapping.Token_definitions_unified.ForThisKeyword -> ForThisKeyword
  | Token_mapping.Token_definitions_unified.TimesKeyword -> TimesKeyword
  | Token_mapping.Token_definitions_unified.EndCloudKeyword -> EndCloudKeyword
  | _token -> raise (Unknown_keyword_token "不是文言文关键字")

(** 转换古雅体条件关键字 *)
let convert_ancient_conditional_keywords = function
  | Token_mapping.Token_definitions_unified.IfWenyanKeyword -> IfWenyanKeyword
  | Token_mapping.Token_definitions_unified.ThenWenyanKeyword -> ThenWenyanKeyword
  | Token_mapping.Token_definitions_unified.GreaterThanWenyan -> GreaterThanWenyan
  | Token_mapping.Token_definitions_unified.LessThanWenyan -> LessThanWenyan
  | Token_mapping.Token_definitions_unified.AncientThenKeyword -> AncientThenKeyword
  | Token_mapping.Token_definitions_unified.AncientOtherwiseKeyword -> AncientOtherwiseKeyword
  | _token -> raise (Unknown_keyword_token "不是古雅体条件关键字")

(** 转换古雅体定义关键字 *)
let convert_ancient_definition_keywords = function
  | Token_mapping.Token_definitions_unified.AncientDefineKeyword -> AncientDefineKeyword
  | Token_mapping.Token_definitions_unified.AncientEndKeyword -> AncientEndKeyword
  | Token_mapping.Token_definitions_unified.AncientAlgorithmKeyword -> AncientAlgorithmKeyword
  | Token_mapping.Token_definitions_unified.AncientCompleteKeyword -> AncientCompleteKeyword
  | Token_mapping.Token_definitions_unified.AncientAnswerKeyword -> AncientAnswerKeyword
  | Token_mapping.Token_definitions_unified.AncientBeginKeyword -> AncientBeginKeyword
  | Token_mapping.Token_definitions_unified.AncientEndCompleteKeyword -> AncientEndCompleteKeyword
  | _token -> raise (Unknown_keyword_token "不是古雅体定义关键字")

(** 转换古雅体观察关键字 *)
let convert_ancient_observation_keywords = function
  | Token_mapping.Token_definitions_unified.AncientObserveKeyword -> AncientObserveKeyword
  | Token_mapping.Token_definitions_unified.AncientNatureKeyword -> AncientNatureKeyword
  | Token_mapping.Token_definitions_unified.AncientObserveEndKeyword -> AncientObserveEndKeyword
  | _token -> raise (Unknown_keyword_token "不是古雅体观察关键字")

(** 转换古雅体操作关键字 *)
let convert_ancient_operation_keywords = function
  | Token_mapping.Token_definitions_unified.AncientCombineKeyword -> AncientCombineKeyword
  | Token_mapping.Token_definitions_unified.AncientAsOneKeyword -> AncientAsOneKeyword
  | Token_mapping.Token_definitions_unified.AncientTakeKeyword -> AncientTakeKeyword
  | Token_mapping.Token_definitions_unified.AncientReceiveKeyword -> AncientReceiveKeyword
  | Token_mapping.Token_definitions_unified.AncientCallItKeyword -> AncientCallItKeyword
  | Token_mapping.Token_definitions_unified.AncientThusAnswerKeyword -> AncientThusAnswerKeyword
  | Token_mapping.Token_definitions_unified.AncientAddToKeyword -> AncientAddToKeyword
  | _token -> raise (Unknown_keyword_token "不是古雅体操作关键字")

(** 转换古雅体列表关键字 *)
let convert_ancient_list_keywords = function
  | Token_mapping.Token_definitions_unified.AncientListStartKeyword -> AncientListStartKeyword
  | Token_mapping.Token_definitions_unified.AncientListEndKeyword -> AncientListEndKeyword
  | Token_mapping.Token_definitions_unified.AncientItsFirstKeyword -> AncientItsFirstKeyword
  | Token_mapping.Token_definitions_unified.AncientItsSecondKeyword -> AncientItsSecondKeyword
  | Token_mapping.Token_definitions_unified.AncientItsThirdKeyword -> AncientItsThirdKeyword
  | Token_mapping.Token_definitions_unified.AncientEmptyKeyword -> AncientEmptyKeyword
  | Token_mapping.Token_definitions_unified.AncientHasHeadTailKeyword -> AncientHasHeadTailKeyword
  | Token_mapping.Token_definitions_unified.AncientHeadNameKeyword -> AncientHeadNameKeyword
  | Token_mapping.Token_definitions_unified.AncientTailNameKeyword -> AncientTailNameKeyword
  | _token -> raise (Unknown_keyword_token "不是古雅体列表关键字")

(** 转换古雅体助词关键字 *)
let convert_ancient_particle_keywords = function
  | Token_mapping.Token_definitions_unified.AncientParticleThe -> AncientParticleThe
  | Token_mapping.Token_definitions_unified.AncientParticleFun -> AncientParticleFun
  | _token -> raise (Unknown_keyword_token "不是古雅体助词关键字")

(** 转换古雅体关键字（统一入口） *)
let convert_ancient_keywords token =
  try convert_ancient_conditional_keywords token
  with Unknown_keyword_token _ -> (
    try convert_ancient_definition_keywords token
    with Unknown_keyword_token _ -> (
      try convert_ancient_observation_keywords token
      with Unknown_keyword_token _ -> (
        try convert_ancient_operation_keywords token
        with Unknown_keyword_token _ -> (
          try convert_ancient_list_keywords token
          with Unknown_keyword_token _ -> (
            try convert_ancient_particle_keywords token
            with Unknown_keyword_token _ -> raise (Unknown_keyword_token "不是古雅体关键字"))))))

(** 转换策略类型定义 *)
type conversion_strategy =
  | Readable  (** 可读性优先：使用分类函数，便于维护和调试 *)
  | Fast  (** 性能优先：按使用频率优化调用顺序，减少异常处理开销 *)

(** 统一的转换函数 - 使用策略模式消除代码重复，优化性能 *)
let convert_with_strategy strategy token =
  match strategy with
  | Readable -> (
      (* 可读性优先实现：按类别依次尝试转换器，依次处理异常 *)
      try convert_basic_language_keywords token
      with Unknown_keyword_token _ -> (
        try convert_semantic_keywords token
        with Unknown_keyword_token _ -> (
          try convert_error_recovery_keywords token
          with Unknown_keyword_token _ -> (
            try convert_module_keywords token
            with Unknown_keyword_token _ -> (
              try convert_natural_language_keywords token
              with Unknown_keyword_token _ -> (
                try convert_wenyan_keywords token
                with Unknown_keyword_token _ -> (
                  try convert_ancient_keywords token
                  with Unknown_keyword_token _ -> raise (Unknown_keyword_token "未知的关键字token"))))))))
  | Fast -> (
      (* 性能优先实现：按使用频率优化的转换器顺序，避免重复代码 *)
      (* 首先尝试最常用的基础语言关键字 *)
      try convert_basic_language_keywords token
      with Unknown_keyword_token _ -> (
        try convert_semantic_keywords token
        with Unknown_keyword_token _ -> (
          try convert_natural_language_keywords token
          with Unknown_keyword_token _ -> (
            try convert_module_keywords token
            with Unknown_keyword_token _ -> (
              try convert_wenyan_keywords token
              with Unknown_keyword_token _ -> (
                try convert_error_recovery_keywords token
                with Unknown_keyword_token _ -> (
                  try convert_ancient_keywords token
                  with Unknown_keyword_token _ -> raise (Unknown_keyword_token "未知的关键字token"))))))))

(** 向后兼容的主转换函数 - 使用可读性策略 *)
let convert_basic_keyword_token token = convert_with_strategy Readable token

(** 性能优化版本 - 使用性能策略 *)
let convert_basic_keyword_token_optimized token = convert_with_strategy Fast token

(** Result类型版本 - 不抛出异常，返回Result类型 *)
let convert_keyword_token_safe token =
  try Success (convert_with_strategy Readable token)
  with Unknown_keyword_token msg -> Keyword_Error msg
