(** 骆言词法分析器 - 中文风格关键字转换模块 *)

open Lexer_tokens
open Compiler_errors

(** 文言文关键字转换表 - 数据与逻辑分离 *)
let wenyan_keyword_mapping =
  [
    (* 声明和定义 *)
    (`HaveKeyword, HaveKeyword);
    (`OneKeyword, OneKeyword);
    (`NameKeyword, NameKeyword);
    (`SetKeyword, SetKeyword);
    (* 逻辑连接词 *)
    (`AlsoKeyword, AlsoKeyword);
    (`ThenGetKeyword, ThenGetKeyword);
    (`AsForKeyword, AsForKeyword);
    (* 函数和调用 *)
    (`CallKeyword, CallKeyword);
    (`ValueKeyword, ValueKeyword);
    (`WantExecuteKeyword, WantExecuteKeyword);
    (`MustFirstGetKeyword, MustFirstGetKeyword);
    (* 循环和计数 *)
    (`ForThisKeyword, ForThisKeyword);
    (`TimesKeyword, TimesKeyword);
    (`NumberKeyword, NumberKeyword);
    (* 控制结构 *)
    (`EndCloudKeyword, EndCloudKeyword);
    (`IfWenyanKeyword, IfWenyanKeyword);
    (`ThenWenyanKeyword, ThenWenyanKeyword);
    (* 比较运算符 *)
    (`GreaterThanWenyan, GreaterThanWenyan);
    (`LessThanWenyan, LessThanWenyan);
  ]

(** 文言文风格关键字转换 - 数据驱动实现 *)
let convert_wenyan_keywords pos variant =
  try Ok (List.assoc variant wenyan_keyword_mapping)
  with Not_found -> unsupported_keyword_error "未知的文言文关键字" pos

(** 古文基础语言结构关键词映射表 *)
let ancient_basic_structure_mapping =
  [
    (`AncientDefineKeyword, AncientDefineKeyword);
    (`AncientEndKeyword, AncientEndKeyword);
    (`AncientAlgorithmKeyword, AncientAlgorithmKeyword);
    (`AncientCompleteKeyword, AncientCompleteKeyword);
    (`AncientObserveKeyword, AncientObserveKeyword);
    (`AncientNatureKeyword, AncientNatureKeyword);
    (`AncientThenKeyword, AncientThenKeyword);
    (`AncientOtherwiseKeyword, AncientOtherwiseKeyword);
    (`AncientAnswerKeyword, AncientAnswerKeyword);
    (`AncientCombineKeyword, AncientCombineKeyword);
    (`AncientAsOneKeyword, AncientAsOneKeyword);
    (`AncientTakeKeyword, AncientTakeKeyword);
    (`AncientReceiveKeyword, AncientReceiveKeyword);
  ]

(** 古文语法助词和函数调用映射表 *)
let ancient_particle_function_mapping =
  [
    (`AncientParticleThe, AncientParticleThe);
    (`AncientParticleFun, AncientParticleFun);
    (`AncientParticleOf, AncientParticleOf);
    (`AncientCallItKeyword, AncientCallItKeyword);
  ]

(** 古文列表操作关键词映射表 *)
let ancient_list_operation_mapping =
  [
    (`AncientListStartKeyword, AncientListStartKeyword);
    (`AncientListEndKeyword, AncientListEndKeyword);
    (`AncientItsFirstKeyword, AncientItsFirstKeyword);
    (`AncientItsSecondKeyword, AncientItsSecondKeyword);
    (`AncientItsThirdKeyword, AncientItsThirdKeyword);
    (`AncientEmptyKeyword, AncientEmptyKeyword);
    (`AncientHasHeadTailKeyword, AncientHasHeadTailKeyword);
    (`AncientHeadNameKeyword, AncientHeadNameKeyword);
    (`AncientTailNameKeyword, AncientTailNameKeyword);
    (`AncientThusAnswerKeyword, AncientThusAnswerKeyword);
  ]

(** 古文运算操作和控制流映射表 *)
let ancient_operation_control_mapping =
  [
    (`AncientAddToKeyword, AncientAddToKeyword);
    (`AncientObserveEndKeyword, AncientObserveEndKeyword);
    (`AncientBeginKeyword, AncientBeginKeyword);
    (`AncientEndCompleteKeyword, AncientEndCompleteKeyword);
    (`AncientIsKeyword, AncientIsKeyword);
    (`AncientArrowKeyword, AncientArrowKeyword);
    (`AncientWhenKeyword, AncientWhenKeyword);
    (`AncientIfKeyword, AncientIfKeyword);
    (`AncientRecursiveKeyword, AncientRecursiveKeyword);
    (`AfterThatKeyword, AfterThatKeyword);
  ]

(** 古文标点符号和记录类型映射表 *)
let ancient_punctuation_record_mapping =
  [
    (`AncientCommaKeyword, AncientCommaKeyword);
    (`AncientPeriodKeyword, AncientPeriodKeyword);
    (`AncientRecordStartKeyword, AncientRecordStartKeyword);
    (`AncientRecordEndKeyword, AncientRecordEndKeyword);
    (`AncientRecordEmptyKeyword, AncientRecordEmptyKeyword);
    (`AncientRecordUpdateKeyword, AncientRecordUpdateKeyword);
    (`AncientRecordFinishKeyword, AncientRecordFinishKeyword);
  ]

(** 合并的古文关键字转换表 - 向后兼容性保证 *)
let ancient_keyword_mapping =
  ancient_basic_structure_mapping @ ancient_particle_function_mapping
  @ ancient_list_operation_mapping @ ancient_operation_control_mapping
  @ ancient_punctuation_record_mapping

(** 古文关键字转换 - 数据驱动实现 *)
let convert_ancient_keywords pos variant =
  try Ok (List.assoc variant ancient_keyword_mapping)
  with Not_found -> unsupported_keyword_error "未知的古文关键字" pos

(** 自然语言关键字转换表 - 数据与逻辑分离 *)
let natural_keyword_mapping =
  [
    (* 函数定义和控制 *)
    (`DefineKeyword, DefineKeyword);
    (`AcceptKeyword, AcceptKeyword);
    (`ReturnWhenKeyword, ReturnWhenKeyword);
    (`ElseReturnKeyword, ElseReturnKeyword);
    (* 数学运算 *)
    (`MultiplyKeyword, MultiplyKeyword);
    (`DivideKeyword, DivideKeyword);
    (`AddToKeyword, AddToKeyword);
    (`SubtractKeyword, SubtractKeyword);
    (`PlusKeyword, PlusKeyword);
    (`MinusOneKeyword, MinusOneKeyword);
    (* 比较和逻辑 *)
    (`EqualToKeyword, EqualToKeyword);
    (`LessThanEqualToKeyword, LessThanEqualToKeyword);
    (`IsKeyword, IsKeyword);
    (* 列表和数据结构 *)
    (`FirstElementKeyword, FirstElementKeyword);
    (`RemainingKeyword, RemainingKeyword);
    (`EmptyKeyword, EmptyKeyword);
    (`CharacterCountKeyword, CharacterCountKeyword);
    (* 输入输出 *)
    (`InputKeyword, InputKeyword);
    (`OutputKeyword, OutputKeyword);
    (* 语法助词和修饰符 *)
    (`WhereKeyword, WhereKeyword);
    (`SmallKeyword, SmallKeyword);
    (`ShouldGetKeyword, ShouldGetKeyword);
    (`OfParticle, OfParticle);
    (`TopicMarker, TopicMarker);
  ]

(** 自然语言关键字转换 - 数据驱动实现 *)
let convert_natural_keywords pos variant =
  try Ok (List.assoc variant natural_keyword_mapping)
  with Not_found -> unsupported_keyword_error "未知的自然语言关键字" pos
