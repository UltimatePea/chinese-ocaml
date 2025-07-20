(** 骆言词法分析器古雅体和诗词关键字表模块 *)

open Token_types
open Keywords

(** 古雅体增强关键字组 *)
let ancient_keywords =
  [
    (* 古雅体增强关键字 *)
    ("起", BeginKeyword);
    ("终", FinishKeyword);
    ("定义为", DefinedKeyword);
    ("返回", ReturnKeyword);
    ("结果", ResultKeyword);
    ("调用", CallKeyword);
    ("执行", InvokeKeyword);
    ("应用", ApplyKeyword);
    (* wenyan风格关键字 *)
    ("今", WenyanNow);
    ("有", WenyanHave);
    ("是", WenyanIs);
    ("非", WenyanNot);
    ("凡", WenyanAll);
    ("或", WenyanSome);
    ("为", WenyanFor);
    ("若", WenyanIf);
    ("则", WenyanThen);
    ("不然", WenyanElse);
    (* 古文关键字 *)
    ("设", ClassicalLet);
    ("于", ClassicalIn);
    ("曰", ClassicalBe);
    ("行", ClassicalDo);
    ("毕", ClassicalEnd);
    ("得", ClassicalReturn);
    ("用", ClassicalCall);
    ("制", ClassicalDefine);
    ("造", ClassicalCreate);
    ("灭", ClassicalDestroy);
    ("化", ClassicalTransform);
    ("合", ClassicalCombine);
    ("分", ClassicalSeparate);
    (* 诗词语法关键字 *)
    ("诗起", PoetryStart);
    ("诗终", PoetryEnd);
    ("句起", VerseStart);
    ("句终", VerseEnd);
    ("韵律", RhymePattern);
    ("平仄", TonePattern);
    ("对起", ParallelStart);
    ("对终", ParallelEnd);
  ]

(** 获取所有古雅体和诗词关键字组合 *)
let get_all_ancient_keywords () = ancient_keywords