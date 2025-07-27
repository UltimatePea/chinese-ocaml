(** 骆言词法分析器古雅体和诗词关键字表模块 *)

open Lexer_tokens

(** 古雅体增强关键字组 - 精简版，仅包含Lexer_tokens中存在的tokens *)
let ancient_keywords =
  [
    (* 古雅体关键字 - 仅使用存在的tokens *)
    ("起", AncientBeginKeyword);
    ("调用", CallKeyword);
    ("有", HaveKeyword);
    ("是", IsKeyword);
    ("若", AncientIfKeyword);
    ("观", AncientObserveKeyword);
    ("性", AncientNatureKeyword);
    ("答", AncientAnswerKeyword);
    ("合", AncientCombineKeyword);
    ("为一", AncientAsOneKeyword);
    ("取", AncientTakeKeyword);
    ("受", AncientReceiveKeyword);
    ("之", AncientParticleOf);
    ("焉", AncientParticleFun);
    ("其", AncientParticleThe);
    (* Most other tokens removed - not available in Lexer_tokens *)
  ]

(** 获取所有古雅体和诗词关键字组合 *)
let get_all_ancient_keywords () = ancient_keywords
