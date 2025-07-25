(** 骆言词法分析器 - 诗词音韵关键字 *)

(** 古典诗词音韵相关关键字，支持中国古典诗词的音韵和格律特性 *)
type poetry_keyword =
  (* 音韵系统 *)
  | RhymeKeyword  (** 韵 - rhyme *)
  | ToneKeyword  (** 调 - tone *)
  | ToneLevelKeyword  (** 平 - level tone *)
  | ToneFallingKeyword  (** 仄 - falling tone *)
  | ToneRisingKeyword  (** 上 - rising tone *)
  | ToneDepartingKeyword  (** 去 - departing tone *)
  | ToneEnteringKeyword  (** 入 - entering tone *)
  (* 对仗和平仄 *)
  | ParallelKeyword  (** 对 - parallel/paired *)
  | PairedKeyword  (** 偶 - paired/even *)
  | AntitheticKeyword  (** 反 - antithetic *)
  | BalancedKeyword  (** 衡 - balanced *)
  (* 诗体分类 *)
  | PoetryKeyword  (** 诗 - poetry *)
  | FourCharKeyword  (** 四言 - four characters *)
  | FiveCharKeyword  (** 五言 - five characters *)
  | SevenCharKeyword  (** 七言 - seven characters *)
  | ParallelStructKeyword  (** 骈体 - parallel structure *)
  | RegulatedVerseKeyword  (** 律诗 - regulated verse *)
  | QuatrainKeyword  (** 绝句 - quatrain *)
  | CoupletKeyword  (** 对联 - couplet *)
  | AntithesisKeyword  (** 对仗 - antithesis *)
  (* 韵律节拍 *)
  | MeterKeyword  (** 韵律 - meter *)
  | CadenceKeyword  (** 音律 - cadence *)
[@@deriving show, eq]

val to_string : poetry_keyword -> string
(** 将诗词关键字转换为字符串表示 *)

val from_string : string -> poetry_keyword option
(** 将字符串转换为诗词关键字（如果匹配） *)

val is_tonal_system : poetry_keyword -> bool
(** 检查是否为音韵系统关键字 *)

val is_parallel_structure : poetry_keyword -> bool
(** 检查是否为对仗相关关键字 *)

val is_poetry_form : poetry_keyword -> bool
(** 检查是否为诗体分类关键字 *)

val is_rhythmic : poetry_keyword -> bool
(** 检查是否为韵律节拍关键字 *)
