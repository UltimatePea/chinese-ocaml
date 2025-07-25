(** 骆言词法分析器 - 诗词音韵关键字 *)

type poetry_keyword =
  | RhymeKeyword | ToneKeyword | ToneLevelKeyword | ToneFallingKeyword
  | ToneRisingKeyword | ToneDepartingKeyword | ToneEnteringKeyword
  | ParallelKeyword | PairedKeyword | AntitheticKeyword | BalancedKeyword
  | PoetryKeyword | FourCharKeyword | FiveCharKeyword | SevenCharKeyword
  | ParallelStructKeyword | RegulatedVerseKeyword | QuatrainKeyword
  | CoupletKeyword | AntithesisKeyword
  | MeterKeyword | CadenceKeyword
[@@deriving show, eq]

let to_string = function
  | RhymeKeyword -> "韵" | ToneKeyword -> "调"
  | ToneLevelKeyword -> "平" | ToneFallingKeyword -> "仄"
  | ToneRisingKeyword -> "上" | ToneDepartingKeyword -> "去" | ToneEnteringKeyword -> "入"
  | ParallelKeyword -> "对" | PairedKeyword -> "偶" | AntitheticKeyword -> "反" | BalancedKeyword -> "衡"
  | PoetryKeyword -> "诗" | FourCharKeyword -> "四言" | FiveCharKeyword -> "五言" | SevenCharKeyword -> "七言"
  | ParallelStructKeyword -> "骈体" | RegulatedVerseKeyword -> "律诗" | QuatrainKeyword -> "绝句"
  | CoupletKeyword -> "对联" | AntithesisKeyword -> "对仗"
  | MeterKeyword -> "韵律" | CadenceKeyword -> "音律"

let from_string = function
  | "韵" -> Some RhymeKeyword | "调" -> Some ToneKeyword
  | "平" -> Some ToneLevelKeyword | "仄" -> Some ToneFallingKeyword
  | "上" -> Some ToneRisingKeyword | "去" -> Some ToneDepartingKeyword | "入" -> Some ToneEnteringKeyword
  | "对" -> Some ParallelKeyword | "偶" -> Some PairedKeyword | "反" -> Some AntitheticKeyword | "衡" -> Some BalancedKeyword
  | "诗" -> Some PoetryKeyword | "四言" -> Some FourCharKeyword | "五言" -> Some FiveCharKeyword | "七言" -> Some SevenCharKeyword
  | "骈体" -> Some ParallelStructKeyword | "律诗" -> Some RegulatedVerseKeyword | "绝句" -> Some QuatrainKeyword
  | "对联" -> Some CoupletKeyword | "对仗" -> Some AntithesisKeyword
  | "韵律" -> Some MeterKeyword | "音律" -> Some CadenceKeyword
  | _ -> None

let is_tonal_system = function
  | RhymeKeyword | ToneKeyword | ToneLevelKeyword | ToneFallingKeyword
  | ToneRisingKeyword | ToneDepartingKeyword | ToneEnteringKeyword -> true
  | _ -> false

let is_parallel_structure = function
  | ParallelKeyword | PairedKeyword | AntitheticKeyword | BalancedKeyword | AntithesisKeyword -> true
  | _ -> false

let is_poetry_form = function
  | PoetryKeyword | FourCharKeyword | FiveCharKeyword | SevenCharKeyword
  | ParallelStructKeyword | RegulatedVerseKeyword | QuatrainKeyword | CoupletKeyword -> true
  | _ -> false

let is_rhythmic = function
  | MeterKeyword | CadenceKeyword -> true
  | _ -> false