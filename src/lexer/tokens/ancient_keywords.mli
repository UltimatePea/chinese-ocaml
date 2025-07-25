(** 骆言词法分析器 - 古雅体关键字 *)

(** 古雅体关键字，支持古代汉语文学风格的编程语法 *)
type ancient_keyword =
  (* 古雅体基础关键字 *)
  | AncientDefineKeyword  (** 夫...者 - ancient function definition *)
  | AncientEndKeyword  (** 也 - ancient end marker *)
  | AncientAlgorithmKeyword  (** 算法 - algorithm *)
  | AncientCompleteKeyword  (** 竟 - complete/finish *)
  | AncientObserveKeyword  (** 观 - observe/examine *)
  | AncientNatureKeyword  (** 性 - nature/essence *)
  | AncientIfKeyword  (** 若 - if (ancient style) *)
  | AncientThenKeyword  (** 则 - then (ancient) *)
  | AncientOtherwiseKeyword  (** 余者 - otherwise/others *)
  | AncientAnswerKeyword  (** 答 - answer/return *)
  | AncientRecursiveKeyword  (** 递归 - recursive (ancient) *)
  | AncientCombineKeyword  (** 合 - combine *)
  | AncientAsOneKeyword  (** 为一 - as one *)
  | AncientTakeKeyword  (** 取 - take/get *)
  | AncientReceiveKeyword  (** 受 - receive *)
  (* 古雅体语法助词 *)
  | AncientParticleOf  (** 之 - possessive particle *)
  | AncientParticleFun  (** 焉 - function parameter particle *)
  | AncientParticleThe  (** 其 - its/the *)
  | AncientCallItKeyword  (** 名曰 - call it *)
  (* 古雅体列表处理 *)
  | AncientListStartKeyword  (** 列开始 - list start *)
  | AncientListEndKeyword  (** 列结束 - list end *)
  | AncientItsFirstKeyword  (** 其一 - its first *)
  | AncientItsSecondKeyword  (** 其二 - its second *)
  | AncientItsThirdKeyword  (** 其三 - its third *)
  | AncientEmptyKeyword  (** 空空如也 - empty as void *)
  | AncientHasHeadTailKeyword  (** 有首有尾 - has head and tail *)
  | AncientHeadNameKeyword  (** 首名为 - head named as *)
  | AncientTailNameKeyword  (** 尾名为 - tail named as *)
  | AncientThusAnswerKeyword  (** 则答 - thus answer *)
  | AncientAddToKeyword  (** 并加 - and add *)
  | AncientObserveEndKeyword  (** 观察毕 - observation complete *)
  (* 古雅体程序结构 *)
  | AncientBeginKeyword  (** 始 - begin *)
  | AncientEndCompleteKeyword  (** 毕 - complete *)
  (* 古雅体记录类型关键词 *)
  | AncientRecordStartKeyword  (** 据开始 - record start *)
  | AncientRecordEndKeyword  (** 据结束 - record end *)
  | AncientRecordEmptyKeyword  (** 据空 - record empty *)
  | AncientRecordUpdateKeyword  (** 据更新 - record update *)
  | AncientRecordFinishKeyword  (** 据毕 - record finish *)
  (* 古雅体逻辑连接词 *)
  | AncientIsKeyword  (** 乃 - is/thus *)
  | AncientArrowKeyword  (** 故 - therefore/thus *)
  | AncientWhenKeyword  (** 当 - when *)
  | AncientCommaKeyword  (** 且 - and/also *)
  | AncientPeriodKeyword  (** 也 - particle for end of statement *)
  | AfterThatKeyword  (** 而后 - after that/then *)
[@@deriving show, eq]

val to_string : ancient_keyword -> string
(** 将古雅体关键字转换为字符串表示 *)

val from_string : string -> ancient_keyword option
(** 将字符串转换为古雅体关键字（如果匹配） *)

val is_definition : ancient_keyword -> bool
(** 检查是否为古雅体定义类关键字 *)

val is_control_flow : ancient_keyword -> bool
(** 检查是否为古雅体流程控制关键字 *)

val is_particle : ancient_keyword -> bool
(** 检查是否为古雅体语法助词 *)

val is_list_operation : ancient_keyword -> bool
(** 检查是否为古雅体列表处理关键字 *)
