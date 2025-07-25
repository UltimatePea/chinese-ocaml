(** 骆言词法分析器 - 古典诗词风格令牌类型定义 *)

(** 古典诗词音韵相关关键字 *)
type rhyme_keyword =
  | RhymeKeyword (* 韵 - rhyme *)
  | ToneKeyword (* 调 - tone *)
  | ToneLevelKeyword (* 平 - level tone *)
  | ToneFallingKeyword (* 仄 - falling tone *)
  | ToneRisingKeyword (* 上 - rising tone *)
  | ToneDepartingKeyword (* 去 - departing tone *)
  | ToneEnteringKeyword (* 入 - entering tone *)
[@@deriving show, eq]

(** 古典诗词对仗关键字 *)
type antithesis_keyword =
  | ParallelKeyword (* 对 - parallel/paired *)
  | PairedKeyword (* 偶 - paired/even *)
  | AntitheticKeyword (* 反 - antithetic *)
  | BalancedKeyword (* 衡 - balanced *)
  | AntithesisKeyword (* 对仗 - antithesis *)
[@@deriving show, eq]

(** 古典诗词体裁关键字 *)
type poetry_form_keyword =
  | PoetryKeyword (* 诗 - poetry *)
  | FourCharKeyword (* 四言 - four characters *)
  | FiveCharKeyword (* 五言 - five characters *)
  | SevenCharKeyword (* 七言 - seven characters *)
  | ParallelStructKeyword (* 骈体 - parallel structure *)
  | RegulatedVerseKeyword (* 律诗 - regulated verse *)
  | QuatrainKeyword (* 绝句 - quatrain *)
  | CoupletKeyword (* 对联 - couplet *)
[@@deriving show, eq]

(** 古典诗词韵律关键字 *)
type meter_keyword =
  | MeterKeyword
  (* 韵律 - meter *)
  | CadenceKeyword (* 音律 - cadence *)
[@@deriving show, eq]

(** 统一诗词令牌类型 *)
type poetry_token =
  | Rhyme of rhyme_keyword
  | Antithesis of antithesis_keyword
  | Form of poetry_form_keyword
  | Meter of meter_keyword
[@@deriving show, eq]

(** 诗词令牌转换为字符串 *)
let poetry_token_to_string = function
  | Rhyme rk -> (
      match rk with
      | RhymeKeyword -> "韵"
      | ToneKeyword -> "调"
      | ToneLevelKeyword -> "平"
      | ToneFallingKeyword -> "仄"
      | ToneRisingKeyword -> "上"
      | ToneDepartingKeyword -> "去"
      | ToneEnteringKeyword -> "入")
  | Antithesis ak -> (
      match ak with
      | ParallelKeyword -> "对"
      | PairedKeyword -> "偶"
      | AntitheticKeyword -> "反"
      | BalancedKeyword -> "衡"
      | AntithesisKeyword -> "对仗")
  | Form fk -> (
      match fk with
      | PoetryKeyword -> "诗"
      | FourCharKeyword -> "四言"
      | FiveCharKeyword -> "五言"
      | SevenCharKeyword -> "七言"
      | ParallelStructKeyword -> "骈体"
      | RegulatedVerseKeyword -> "律诗"
      | QuatrainKeyword -> "绝句"
      | CoupletKeyword -> "对联")
  | Meter mk -> ( match mk with MeterKeyword -> "韵律" | CadenceKeyword -> "音律")

(** 判断是否为韵律相关 *)
let is_rhyme_related = function Rhyme _ -> true | _ -> false

(** 判断是否为对仗相关 *)
let is_antithesis_related = function Antithesis _ -> true | _ -> false

(** 判断是否为诗词体裁相关 *)
let is_form_related = function Form _ -> true | _ -> false

(** 判断是否为韵律相关 *)
let is_meter_related = function Meter _ -> true | _ -> false
