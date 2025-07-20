(** 骆言词法分析器基础关键字表模块 *)

open Token_types
open Keywords

(** 基础关键字组 *)
let basic_keywords =
  [
    ("让", LetKeyword);
    ("递归", RecKeyword);
    ("在", InKeyword);
    ("函数", FunKeyword);
    ("如果", IfKeyword);
    ("那么", ThenKeyword);
    ("否则", ElseKeyword);
    ("匹配", MatchKeyword);
    ("与", WithKeyword);
    ("其他", OtherKeyword);
    ("类型", TypeKeyword);
    ("私有", PrivateKeyword);
    ("真", TrueKeyword);
    ("假", FalseKeyword);
    ("并且", AndKeyword);
    ("或者", OrKeyword);
    ("非", NotKeyword);
  ]

(** 语义类型系统关键字组 *)
let semantic_keywords =
  [
    ("作为", AsKeyword);
    ("组合", CombineKeyword);
    ("以及", WithOpKeyword);
    ("当", WhenKeyword);
  ]

(** 错误恢复关键字组 *)
let error_recovery_keywords =
  [ ("否则返回", OrElseKeyword); ("默认为", WithDefaultKeyword) ]

(** 异常处理关键字组 *)
let exception_keywords =
  [
    ("异常", ExceptionKeyword);
    ("抛出", RaiseKeyword);
    ("尝试", TryKeyword);
    ("捕获", CatchKeyword);
    ("最终", FinallyKeyword);
  ]

(** 模块系统关键字组 *)
let module_keywords =
  [
    ("模块", ModuleKeyword);
    ("模块类型", ModuleTypeKeyword);
    ("打开", OpenKeyword);
    ("包含", IncludeKeyword);
    ("签名", SigKeyword);
    ("结构", StructKeyword);
    ("结束", EndKeyword);
    ("函子", FunctorKeyword);
    ("值", ValKeyword);
    ("外部", ExternalKeyword);
  ]

(** 获取所有基础关键字组合 *)
let get_all_basic_keywords () =
  List.concat [
    basic_keywords;
    semantic_keywords;
    error_recovery_keywords;
    exception_keywords;
    module_keywords;
  ]