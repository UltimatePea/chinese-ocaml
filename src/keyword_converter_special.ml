(** 骆言词法分析器 - 特殊关键字转换模块 *)

open Lexer_tokens
open Compiler_errors

(** 类型关键字转换表 - 数据与逻辑分离 *)
let type_keyword_mapping =
  [
    (* 基础类型 *)
    (`IntTypeKeyword, IntTypeKeyword);
    (`FloatTypeKeyword, FloatTypeKeyword);
    (`StringTypeKeyword, StringTypeKeyword);
    (`BoolTypeKeyword, BoolTypeKeyword);
    (`UnitTypeKeyword, UnitTypeKeyword);
    (* 复合类型 *)
    (`ListTypeKeyword, ListTypeKeyword);
    (`ArrayTypeKeyword, ArrayTypeKeyword);
    (* 高级类型 *)
    (`VariantKeyword, VariantKeyword);
    (`TagKeyword, TagKeyword);
  ]

(** 类型关键字转换 - 数据驱动实现 *)
let convert_type_keywords pos variant =
  try Ok (List.assoc variant type_keyword_mapping)
  with Not_found -> unsupported_keyword_error "未知的类型关键字" pos

(** 古典诗词关键字转换表 - 数据与逻辑分离 *)
let poetry_keyword_mapping =
  [
    (* 韵律相关 *)
    (`RhymeKeyword, RhymeKeyword);
    (`MeterKeyword, MeterKeyword);
    (`CadenceKeyword, CadenceKeyword);
    (* 声调系统 *)
    (`ToneKeyword, ToneKeyword);
    (`ToneLevelKeyword, ToneLevelKeyword);
    (`ToneFallingKeyword, ToneFallingKeyword);
    (`ToneRisingKeyword, ToneRisingKeyword);
    (`ToneDepartingKeyword, ToneDepartingKeyword);
    (`ToneEnteringKeyword, ToneEnteringKeyword);
    (* 对仗和平行结构 *)
    (`ParallelKeyword, ParallelKeyword);
    (`PairedKeyword, PairedKeyword);
    (`AntitheticKeyword, AntitheticKeyword);
    (`BalancedKeyword, BalancedKeyword);
    (`ParallelStructKeyword, ParallelStructKeyword);
    (`AntithesisKeyword, AntithesisKeyword);
    (* 诗体分类 *)
    (`PoetryKeyword, PoetryKeyword);
    (`RegulatedVerseKeyword, RegulatedVerseKeyword);
    (`QuatrainKeyword, QuatrainKeyword);
    (`CoupletKeyword, CoupletKeyword);
    (* 字数分类 *)
    (`FourCharKeyword, FourCharKeyword);
    (`FiveCharKeyword, FiveCharKeyword);
    (`SevenCharKeyword, SevenCharKeyword);
  ]

(** 古典诗词关键字转换 - 数据驱动实现 *)
let convert_poetry_keywords pos variant =
  try Ok (List.assoc variant poetry_keyword_mapping)
  with Not_found -> unsupported_keyword_error "未知的诗词关键字" pos

(** 特殊标识符转换 *)
let convert_special_identifier pos = function
  | `IdentifierTokenSpecial -> Ok (IdentifierTokenSpecial "数值")
  | _ -> unsupported_keyword_error "未知的特殊标识符" pos