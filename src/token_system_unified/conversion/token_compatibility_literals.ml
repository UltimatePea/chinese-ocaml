(** Token兼容性字面量映射模块 - Issue #646 技术债务清理

    此模块负责处理各种字面量和标识符的映射转换，包括数字、字符串、中文数字等。 这是从 token_compatibility.ml 中提取出来的专门模块，提升代码可维护性。

    @author 骆言技术债务清理团队 Issue #646
    @version 1.0
    @since 2025-07-20 *)

open Unified_token_core

(** 字面量映射 *)
let map_legacy_literal_to_unified = function
  (* 数字字面量 *)
  | s
    when try
           let _ = int_of_string s in
           true
         with _ -> false ->
      Some (IntToken (int_of_string s))
  | s
    when try
           let _ = float_of_string s in
           true
         with _ -> false ->
      Some (FloatToken (float_of_string s))
  (* 布尔字面量 *)
  | "true" -> Some (BoolToken true)
  | "false" -> Some (BoolToken false)
  (* 单位字面量 *)
  | "()" -> Some UnitToken
  | "unit" -> Some UnitToken
  (* 字符串字面量（带引号） *)
  | s when String.length s >= 2 && s.[0] = '"' && s.[String.length s - 1] = '"' ->
      let content = String.sub s 1 (String.length s - 2) in
      Some (StringToken content)
  (* 中文数字 *)
  | "零" -> Some (ChineseNumberToken "零")
  | "一" -> Some (ChineseNumberToken "一")
  | "二" -> Some (ChineseNumberToken "二")
  | "三" -> Some (ChineseNumberToken "三")
  | "四" -> Some (ChineseNumberToken "四")
  | "五" -> Some (ChineseNumberToken "五")
  | "六" -> Some (ChineseNumberToken "六")
  | "七" -> Some (ChineseNumberToken "七")
  | "八" -> Some (ChineseNumberToken "八")
  | "九" -> Some (ChineseNumberToken "九")
  | "十" -> Some (ChineseNumberToken "十")
  | "百" -> Some (ChineseNumberToken "百")
  | "千" -> Some (ChineseNumberToken "千")
  | "万" -> Some (ChineseNumberToken "万")
  (* 不支持的字面量 *)
  | _ -> None

(** 标识符映射 *)
let map_legacy_identifier_to_unified = function
  (* 排除特殊保留词，这些应该由特殊Token映射处理 *)
  | "EOF" -> None
  | "Whitespace" -> None
  | "Newline" -> None
  | "Tab" -> None
  (* 以下划线开头的标识符 *)
  | s when String.length s > 0 && s.[0] = '_' -> Some (IdentifierToken s)
  (* 变量标识符（小写字母开头） *)
  | s when String.length s > 0 && Char.code s.[0] >= 97 && Char.code s.[0] <= 122 ->
      (* a-z *)
      Some (IdentifierToken s)
  (* 标识符（大写字母开头）- 统一映射为IdentifierToken以符合测试预期 *)
  | s when String.length s > 0 && Char.code s.[0] >= 65 && Char.code s.[0] <= 90 ->
      (* A-Z *)
      Some (IdentifierToken s)
  (* 中文标识符 *)
  | s
    when String.length s > 0
         &&
         let code = Char.code s.[0] in
         code > 127 ->
      Some (IdentifierToken s)
  (* 引用标识符（带引号） *)
  | s when String.length s >= 3 && s.[0] = '\'' && s.[String.length s - 1] = '\'' ->
      let content = String.sub s 1 (String.length s - 2) in
      Some (QuotedIdentifierToken content)
  (* 不支持的标识符 *)
  | _ -> None

(** 特殊Token映射 *)
let map_legacy_special_to_unified = function
  (* 文件结束 *)
  | "EOF" -> Some EOF
  (* 空白符 - 仅支持转义字符串形式，单独空格不作为有效token *)
  | "\n" -> Some Newline
  | "\t" -> Some Whitespace
  | "\\n" -> Some Newline (* 转义字符串形式 *)
  | "\\t" -> Some Whitespace (* 转义字符串形式 *)
  (* 注释 - 支持OCaml风格的块注释 *)
  | s
    when String.length s >= 4
         && String.sub s 0 2 = "(*"
         && String.sub s (String.length s - 2) 2 = "*)" ->
      let content = String.sub s 2 (String.length s - 4) in
      Some (Comment content)
  | s when String.length s >= 2 && String.sub s 0 2 = "//" ->
      let content = String.sub s 2 (String.length s - 2) in
      Some (Comment content)
  (* 不支持的特殊Token *)
  | _ -> None
