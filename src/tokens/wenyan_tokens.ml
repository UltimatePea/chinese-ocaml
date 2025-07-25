(** 骆言词法分析器 - 文言文风格令牌类型定义 *)

(** wenyan风格关键字 *)
type wenyan_keyword =
  | HaveKeyword (* 吾有 - I have *)
  | OneKeyword (* 一 - one *)
  | NameKeyword (* 名曰 - name it *)
  | SetKeyword (* 设 - set *)
  | AlsoKeyword (* 也 - also/end particle *)
  | ThenGetKeyword (* 乃 - then/thus *)
  | CallKeyword (* 曰 - called/said *)
  | ValueKeyword (* 其值 - its value *)
  | AsForKeyword (* 为 - as for/regarding *)
  | NumberKeyword (* 数 - number *)
[@@deriving show, eq]

(** wenyan扩展关键字 *)
type wenyan_extended_keyword =
  | WantExecuteKeyword (* 欲行 - want to execute *)
  | MustFirstGetKeyword (* 必先得 - must first get *)
  | ForThisKeyword (* 為是 - for this *)
  | TimesKeyword (* 遍 - times/iterations *)
  | EndCloudKeyword (* 云云 - end marker *)
  | IfWenyanKeyword (* 若 - if (wenyan style) *)
  | ThenWenyanKeyword (* 者 - then particle *)
  | GreaterThanWenyan (* 大于 - greater than *)
  | LessThanWenyan (* 小于 - less than *)
[@@deriving show, eq]

(** 古雅体关键字 - Ancient Chinese Literary Style *)
type ancient_keyword =
  | AncientDefineKeyword (* 夫...者 - ancient function definition *)
  | AncientEndKeyword (* 也 - ancient end marker *)
  | AncientAlgorithmKeyword (* 算法 - algorithm *)
  | AncientCompleteKeyword (* 竟 - complete/finish *)
  | AncientObserveKeyword (* 观 - observe/examine *)
  | AncientNatureKeyword (* 性 - nature/essence *)
  | AncientIfKeyword (* 若 - if (ancient style) *)
  | AncientThenKeyword (* 则 - then (ancient) *)
  | AncientOtherwiseKeyword (* 余者 - otherwise/others *)
  | AncientAnswerKeyword (* 答 - answer/return *)
  | AncientRecursiveKeyword (* 递归 - recursive (ancient) *)
  | AncientCombineKeyword (* 合 - combine *)
  | AncientAsOneKeyword (* 为一 - as one *)
  | AncientTakeKeyword (* 取 - take/get *)
  | AncientReceiveKeyword (* 受 - receive *)
[@@deriving show, eq]

(** 古雅体语助词 *)
type ancient_particle =
  | AncientParticleOf (* 之 - possessive particle *)
  | AncientParticleFun (* 焉 - function parameter particle *)
  | AncientParticleThe (* 其 - its/the *)
  | AncientCallItKeyword (* 名曰 - call it *)
[@@deriving show, eq]

(** 古雅体列表和数据结构关键字 *)
type ancient_data_keyword =
  | AncientListStartKeyword (* 列开始 - list start *)
  | AncientListEndKeyword (* 列结束 - list end *)
  | AncientItsFirstKeyword (* 其一 - its first *)
  | AncientItsSecondKeyword (* 其二 - its second *)
  | AncientItsThirdKeyword (* 其三 - its third *)
  | AncientEmptyKeyword (* 空空如也 - empty as void *)
  | AncientHasHeadTailKeyword (* 有首有尾 - has head and tail *)
  | AncientHeadNameKeyword (* 首名为 - head named as *)
  | AncientTailNameKeyword (* 尾名为 - tail named as *)
  | AncientThusAnswerKeyword (* 则答 - thus answer *)
  | AncientAddToKeyword (* 并加 - and add *)
  | AncientObserveEndKeyword (* 观察毕 - observation complete *)
  | AncientBeginKeyword (* 始 - begin *)
  | AncientEndCompleteKeyword (* 毕 - complete *)
[@@deriving show, eq]

(** 古雅体记录类型关键词 *)
type ancient_record_keyword =
  | AncientRecordStartKeyword (* 据开始 - record start *)
  | AncientRecordEndKeyword (* 据结束 - record end *)
  | AncientRecordEmptyKeyword (* 据空 - record empty *)
  | AncientRecordUpdateKeyword (* 据更新 - record update *)
  | AncientRecordFinishKeyword (* 据毕 - record finish *)
  | AncientIsKeyword (* 乃 - is/thus *)
  | AncientArrowKeyword (* 故 - therefore/thus *)
  | AncientWhenKeyword (* 当 - when *)
  | AncientCommaKeyword (* 且 - and/also *)
  | AncientPeriodKeyword (* 也 - particle for end of statement *)
  | AfterThatKeyword (* 而后 - after that/then *)
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

(** 文言文令牌转换为字符串 *)
let wenyan_token_to_string = function
  | Wenyan wk -> (
      match wk with
      | HaveKeyword -> "吾有"
      | OneKeyword -> "一"
      | NameKeyword -> "名曰"
      | SetKeyword -> "设"
      | AlsoKeyword -> "也"
      | ThenGetKeyword -> "乃"
      | CallKeyword -> "曰"
      | ValueKeyword -> "其值"
      | AsForKeyword -> "为"
      | NumberKeyword -> "数")
  | WenyanExtended wek -> (
      match wek with
      | WantExecuteKeyword -> "欲行"
      | MustFirstGetKeyword -> "必先得"
      | ForThisKeyword -> "為是"
      | TimesKeyword -> "遍"
      | EndCloudKeyword -> "云云"
      | IfWenyanKeyword -> "若"
      | ThenWenyanKeyword -> "者"
      | GreaterThanWenyan -> "大于"
      | LessThanWenyan -> "小于")
  | Ancient ak -> (
      match ak with
      | AncientDefineKeyword -> "夫...者"
      | AncientEndKeyword -> "也"
      | AncientAlgorithmKeyword -> "算法"
      | AncientCompleteKeyword -> "竟"
      | AncientObserveKeyword -> "观"
      | AncientNatureKeyword -> "性"
      | AncientIfKeyword -> "若"
      | AncientThenKeyword -> "则"
      | AncientOtherwiseKeyword -> "余者"
      | AncientAnswerKeyword -> "答"
      | AncientRecursiveKeyword -> "递归"
      | AncientCombineKeyword -> "合"
      | AncientAsOneKeyword -> "为一"
      | AncientTakeKeyword -> "取"
      | AncientReceiveKeyword -> "受")
  | AncientParticle ap -> (
      match ap with
      | AncientParticleOf -> "之"
      | AncientParticleFun -> "焉"
      | AncientParticleThe -> "其"
      | AncientCallItKeyword -> "名曰")
  | AncientData adk -> (
      match adk with
      | AncientListStartKeyword -> "列开始"
      | AncientListEndKeyword -> "列结束"
      | AncientItsFirstKeyword -> "其一"
      | AncientItsSecondKeyword -> "其二"
      | AncientItsThirdKeyword -> "其三"
      | AncientEmptyKeyword -> "空空如也"
      | AncientHasHeadTailKeyword -> "有首有尾"
      | AncientHeadNameKeyword -> "首名为"
      | AncientTailNameKeyword -> "尾名为"
      | AncientThusAnswerKeyword -> "则答"
      | AncientAddToKeyword -> "并加"
      | AncientObserveEndKeyword -> "观察毕"
      | AncientBeginKeyword -> "始"
      | AncientEndCompleteKeyword -> "毕")
  | AncientRecord ark -> (
      match ark with
      | AncientRecordStartKeyword -> "据开始"
      | AncientRecordEndKeyword -> "据结束"
      | AncientRecordEmptyKeyword -> "据空"
      | AncientRecordUpdateKeyword -> "据更新"
      | AncientRecordFinishKeyword -> "据毕"
      | AncientIsKeyword -> "乃"
      | AncientArrowKeyword -> "故"
      | AncientWhenKeyword -> "当"
      | AncientCommaKeyword -> "且"
      | AncientPeriodKeyword -> "也"
      | AfterThatKeyword -> "而后")

(** 判断是否为古雅体关键字 *)
let is_ancient_style = function
  | Ancient _ | AncientParticle _ | AncientData _ | AncientRecord _ -> true
  | _ -> false

(** 判断是否为文言文风格关键字 *)
let is_wenyan_style = function Wenyan _ | WenyanExtended _ -> true | _ -> false
