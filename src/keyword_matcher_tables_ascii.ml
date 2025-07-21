(** 骆言词法分析器ASCII关键字表模块 *)

open Token_types
open Keywords

(** ASCII关键字映射表 *)
let ascii_keywords =
  [
    (* 基础关键字 *)
    ("let", LetKeyword);
    ("rec", RecKeyword);
    ("in", InKeyword);
    ("fun", FunKeyword);
    ("function", FunKeyword);
    ("if", IfKeyword);
    ("then", ThenKeyword);
    ("else", ElseKeyword);
    ("match", MatchKeyword);
    ("with", WithKeyword);
    ("type", TypeKeyword);
    ("private", PrivateKeyword);
    ("true", TrueKeyword);
    ("false", FalseKeyword);
    ("and", AndKeyword);
    ("or", OrKeyword);
    ("not", NotKeyword);
    ("of", OfKeyword);
    (* 模块系统关键字 *)
    ("module", ModuleKeyword);
    ("sig", SigKeyword);
    ("struct", StructKeyword);
    ("end", EndKeyword);
    ("functor", FunctorKeyword);
    ("val", ValKeyword);
    ("external", ExternalKeyword);
    ("open", OpenKeyword);
    ("include", IncludeKeyword);
    (* 异常处理关键字 *)
    ("exception", ExceptionKeyword);
    ("raise", RaiseKeyword);
    ("try", TryKeyword);
    ("finally", FinallyKeyword);
    (* 语义类型系统关键字 *)
    ("as", AsKeyword);
    ("when", WhenKeyword);
  ]

(** 获取ASCII关键字列表 *)
let get_ascii_keywords () = ascii_keywords
