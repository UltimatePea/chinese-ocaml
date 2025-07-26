(** 骆言词法分析器 - 文言文风格令牌类型定义接口 *)

(** wenyan风格关键字 *)
type wenyan_keyword =
  | HaveKeyword
  | OneKeyword
  | NameKeyword
  | SetKeyword
  | AlsoKeyword
  | ThenGetKeyword
  | CallKeyword
  | ValueKeyword
  | AsForKeyword
  | NumberKeyword
[@@deriving show, eq]

(** wenyan扩展关键字 *)
type wenyan_extended_keyword =
  | WantExecuteKeyword
  | MustFirstGetKeyword
  | ForThisKeyword
  | TimesKeyword
  | EndCloudKeyword
  | IfWenyanKeyword
  | ThenWenyanKeyword
  | GreaterThanWenyan
  | LessThanWenyan
[@@deriving show, eq]

(** 古雅体关键字 *)
type ancient_keyword =
  | AncientDefineKeyword
  | AncientEndKeyword
  | AncientAlgorithmKeyword
  | AncientCompleteKeyword
  | AncientObserveKeyword
  | AncientNatureKeyword
  | AncientIfKeyword
  | AncientThenKeyword
  | AncientOtherwiseKeyword
  | AncientAnswerKeyword
  | AncientRecursiveKeyword
  | AncientCombineKeyword
  | AncientAsOneKeyword
  | AncientTakeKeyword
  | AncientReceiveKeyword
[@@deriving show, eq]

(** 古雅体语助词 *)
type ancient_particle =
  | AncientParticleOf
  | AncientParticleFun
  | AncientParticleThe
  | AncientCallItKeyword
[@@deriving show, eq]

(** 古雅体列表和数据结构关键字 *)
type ancient_data_keyword =
  | AncientListStartKeyword
  | AncientListEndKeyword
  | AncientItsFirstKeyword
  | AncientItsSecondKeyword
  | AncientItsThirdKeyword
  | AncientEmptyKeyword
  | AncientHasHeadTailKeyword
  | AncientHeadNameKeyword
  | AncientTailNameKeyword
  | AncientThusAnswerKeyword
  | AncientAddToKeyword
  | AncientObserveEndKeyword
  | AncientBeginKeyword
  | AncientEndCompleteKeyword
[@@deriving show, eq]

(** 古雅体记录类型关键词 *)
type ancient_record_keyword =
  | AncientRecordStartKeyword
  | AncientRecordEndKeyword
  | AncientRecordEmptyKeyword
  | AncientRecordUpdateKeyword
  | AncientRecordFinishKeyword
  | AncientIsKeyword
  | AncientArrowKeyword
  | AncientWhenKeyword
  | AncientCommaKeyword
  | AncientPeriodKeyword
  | AfterThatKeyword
[@@deriving show, eq]

(** 统一文言文令牌类型 *)
type wenyan_token =
  | Wenyan of wenyan_keyword
  | WenyanExtended of wenyan_extended_keyword
  | Ancient of ancient_keyword
  | AncientParticle of ancient_particle
  | AncientData of ancient_data_keyword
  | AncientRecord of ancient_record_keyword
[@@deriving show, eq]

val wenyan_token_to_string : wenyan_token -> string
(** 文言文令牌转换为字符串 *)

val is_ancient_style : wenyan_token -> bool
(** 判断是否为古雅体关键字 *)

val is_wenyan_style : wenyan_token -> bool
(** 判断是否为文言文风格关键字 *)
