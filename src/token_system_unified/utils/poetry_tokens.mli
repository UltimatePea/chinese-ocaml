(** 骆言词法分析器 - 古典诗词风格令牌类型定义接口 *)

(** 古典诗词音韵相关关键字 *)
type rhyme_keyword =
  | RhymeKeyword
  | ToneKeyword
  | ToneLevelKeyword
  | ToneFallingKeyword
  | ToneRisingKeyword
  | ToneDepartingKeyword
  | ToneEnteringKeyword
[@@deriving show, eq]

(** 古典诗词对仗关键字 *)
type antithesis_keyword =
  | ParallelKeyword
  | PairedKeyword
  | AntitheticKeyword
  | BalancedKeyword
  | AntithesisKeyword
[@@deriving show, eq]

(** 古典诗词体裁关键字 *)
type poetry_form_keyword =
  | PoetryKeyword
  | FourCharKeyword
  | FiveCharKeyword
  | SevenCharKeyword
  | ParallelStructKeyword
  | RegulatedVerseKeyword
  | QuatrainKeyword
  | CoupletKeyword
[@@deriving show, eq]

(** 古典诗词韵律关键字 *)
type meter_keyword = MeterKeyword | CadenceKeyword [@@deriving show, eq]

(** 统一诗词令牌类型 *)
type poetry_token =
  | Rhyme of rhyme_keyword
  | Antithesis of antithesis_keyword
  | Form of poetry_form_keyword
  | Meter of meter_keyword
[@@deriving show, eq]

val poetry_token_to_string : poetry_token -> string
(** 诗词令牌转换为字符串 *)

val is_rhyme_related : poetry_token -> bool
(** 判断是否为韵律相关 *)

val is_antithesis_related : poetry_token -> bool
(** 判断是否为对仗相关 *)

val is_form_related : poetry_token -> bool
(** 判断是否为诗词体裁相关 *)

val is_meter_related : poetry_token -> bool
(** 判断是否为韵律相关 *)
