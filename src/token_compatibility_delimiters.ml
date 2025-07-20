(** Token兼容性分隔符映射模块 - Issue #646 技术债务清理
    
    此模块负责处理各种分隔符的映射转换，包括括号、标点符号、中文标点等。
    这是从 token_compatibility.ml 中提取出来的专门模块，提升代码可维护性。
    
    @author 骆言技术债务清理团队 Issue #646
    @version 1.0
    @since 2025-07-20 *)

open Unified_token_core

(** 分隔符映射 *)
let map_legacy_delimiter_to_unified = function
  (* 括号类 *)
  | "LeftParen" -> Some LeftParen
  | "RightParen" -> Some RightParen
  | "LeftBracket" -> Some LeftBracket
  | "RightBracket" -> Some RightBracket
  | "LeftBrace" -> Some LeftBrace
  | "RightBrace" -> Some RightBrace
  
  (* 基础标点符号 *)
  | "Comma" -> Some Comma
  | "Semicolon" -> Some Semicolon
  | "Colon" -> Some Colon
  | "Dot" -> Some Dot
  | "QuestionMark" -> Some Question
  | "ExclamationMark" -> Some Exclamation
  
  (* 中文标点符号 - 暂时映射到对应的英文标点 *)
  | "ChineseComma" -> Some Comma (* ， -> , *)
  | "ChinesePause" -> Some Comma (* 、 -> , *)
  | "ChineseSemicolon" -> Some Semicolon (* ； -> ; *)
  | "ChineseColon" -> Some Colon (* ： -> : *)
  | "ChinesePeriod" -> Some Dot (* 。 -> . *)
  | "ChineseQuestion" -> Some Question (* ？ -> ? *)
  | "ChineseExclamation" -> Some Exclamation (* ！ -> ! *)
  
  (* 特殊符号 *)
  | "Pipe" -> Some VerticalBar (* | *)
  | "Underscore" -> Some Underscore (* _ *)
  | "At" -> Some AtSymbol (* @ *)
  | "Hash" -> Some SharpSymbol (* # *)
  
  (* 不支持的分隔符 *)
  | _ -> None