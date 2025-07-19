(** 骆言词法分析器关键字匹配优化模块 *)

open Token_types
open Utf8_utils

type lexer_state = {
  input : string;
  position : int;
  length : int;
  current_line : int;
  current_column : int;
  filename : string;
}
(** 关键字匹配状态 *)

(** 关键字查找表 - 使用高效的哈希表结构 *)
module KeywordTable = struct
  (* 基础关键字组 *)
  let basic_keywords =
    [
      ("让", Keywords.LetKeyword);
      ("递归", Keywords.RecKeyword);
      ("在", Keywords.InKeyword);
      ("函数", Keywords.FunKeyword);
      ("如果", Keywords.IfKeyword);
      ("那么", Keywords.ThenKeyword);
      ("否则", Keywords.ElseKeyword);
      ("匹配", Keywords.MatchKeyword);
      ("与", Keywords.WithKeyword);
      ("其他", Keywords.OtherKeyword);
      ("类型", Keywords.TypeKeyword);
      ("私有", Keywords.PrivateKeyword);
      ("真", Keywords.TrueKeyword);
      ("假", Keywords.FalseKeyword);
      ("并且", Keywords.AndKeyword);
      ("或者", Keywords.OrKeyword);
      ("非", Keywords.NotKeyword);
    ]

  (* 语义类型系统关键字组 *)
  let semantic_keywords =
    [
      ("作为", Keywords.AsKeyword);
      ("组合", Keywords.CombineKeyword);
      ("以及", Keywords.WithOpKeyword);
      ("当", Keywords.WhenKeyword);
    ]

  (* 错误恢复关键字组 *)
  let error_recovery_keywords =
    [ ("否则返回", Keywords.OrElseKeyword); ("默认为", Keywords.WithDefaultKeyword) ]

  (* 异常处理关键字组 *)
  let exception_keywords =
    [
      ("异常", Keywords.ExceptionKeyword);
      ("抛出", Keywords.RaiseKeyword);
      ("尝试", Keywords.TryKeyword);
      ("捕获", Keywords.CatchKeyword);
      ("最终", Keywords.FinallyKeyword);
    ]

  (* 模块系统关键字组 *)
  let module_keywords =
    [
      ("模块", Keywords.ModuleKeyword);
      ("模块类型", Keywords.ModuleTypeKeyword);
      ("打开", Keywords.OpenKeyword);
      ("包含", Keywords.IncludeKeyword);
      ("签名", Keywords.SigKeyword);
      ("结构", Keywords.StructKeyword);
      ("结束", Keywords.EndKeyword);
      ("函子", Keywords.FunctorKeyword);
      ("值", Keywords.ValKeyword);
      ("外部", Keywords.ExternalKeyword);
    ]

  (* 古雅体增强关键字组 *)
  let ancient_keywords =
    [
      (* 古雅体增强关键字 *)
      ("起", Keywords.BeginKeyword);
      ("终", Keywords.FinishKeyword);
      ("定义为", Keywords.DefinedKeyword);
      ("返回", Keywords.ReturnKeyword);
      ("结果", Keywords.ResultKeyword);
      ("调用", Keywords.CallKeyword);
      ("执行", Keywords.InvokeKeyword);
      ("应用", Keywords.ApplyKeyword);
      (* wenyan风格关键字 *)
      ("今", Keywords.WenyanNow);
      ("有", Keywords.WenyanHave);
      ("是", Keywords.WenyanIs);
      ("非", Keywords.WenyanNot);
      ("凡", Keywords.WenyanAll);
      ("或", Keywords.WenyanSome);
      ("为", Keywords.WenyanFor);
      ("若", Keywords.WenyanIf);
      ("则", Keywords.WenyanThen);
      ("不然", Keywords.WenyanElse);
      (* 古文关键字 *)
      ("设", Keywords.ClassicalLet);
      ("于", Keywords.ClassicalIn);
      ("曰", Keywords.ClassicalBe);
      ("行", Keywords.ClassicalDo);
      ("毕", Keywords.ClassicalEnd);
      ("得", Keywords.ClassicalReturn);
      ("用", Keywords.ClassicalCall);
      ("制", Keywords.ClassicalDefine);
      ("造", Keywords.ClassicalCreate);
      ("灭", Keywords.ClassicalDestroy);
      ("化", Keywords.ClassicalTransform);
      ("合", Keywords.ClassicalCombine);
      ("分", Keywords.ClassicalSeparate);
      (* 诗词语法关键字 *)
      ("诗起", Keywords.PoetryStart);
      ("诗终", Keywords.PoetryEnd);
      ("句起", Keywords.VerseStart);
      ("句终", Keywords.VerseEnd);
      ("韵律", Keywords.RhymePattern);
      ("平仄", Keywords.TonePattern);
      ("对起", Keywords.ParallelStart);
      ("对终", Keywords.ParallelEnd);
    ]

  (* 合并所有中文关键字组 *)
  let chinese_keywords =
    List.concat
      [
        basic_keywords;
        semantic_keywords;
        error_recovery_keywords;
        exception_keywords;
        module_keywords;
        ancient_keywords;
      ]

  (* ASCII关键字映射表 *)
  let ascii_keywords =
    [
      (* 基础关键字 *)
      ("let", Keywords.LetKeyword);
      ("rec", Keywords.RecKeyword);
      ("in", Keywords.InKeyword);
      ("fun", Keywords.FunKeyword);
      ("function", Keywords.FunKeyword);
      ("if", Keywords.IfKeyword);
      ("then", Keywords.ThenKeyword);
      ("else", Keywords.ElseKeyword);
      ("match", Keywords.MatchKeyword);
      ("with", Keywords.WithKeyword);
      ("type", Keywords.TypeKeyword);
      ("private", Keywords.PrivateKeyword);
      ("true", Keywords.TrueKeyword);
      ("false", Keywords.FalseKeyword);
      ("and", Keywords.AndKeyword);
      ("or", Keywords.OrKeyword);
      ("not", Keywords.NotKeyword);
      ("of", Keywords.OfKeyword);
      (* 模块系统关键字 *)
      ("module", Keywords.ModuleKeyword);
      ("sig", Keywords.SigKeyword);
      ("struct", Keywords.StructKeyword);
      ("end", Keywords.EndKeyword);
      ("functor", Keywords.FunctorKeyword);
      ("val", Keywords.ValKeyword);
      ("external", Keywords.ExternalKeyword);
      ("open", Keywords.OpenKeyword);
      ("include", Keywords.IncludeKeyword);
      (* 异常处理关键字 *)
      ("exception", Keywords.ExceptionKeyword);
      ("raise", Keywords.RaiseKeyword);
      ("try", Keywords.TryKeyword);
      ("finally", Keywords.FinallyKeyword);
      (* 语义类型系统关键字 *)
      ("as", Keywords.AsKeyword);
      ("when", Keywords.WhenKeyword);
    ]

  (* 构建高效的哈希表 *)
  let chinese_table = Hashtbl.create (List.length chinese_keywords)
  let ascii_table = Hashtbl.create (List.length ascii_keywords)

  (* 初始化哈希表 *)
  let () =
    List.iter (fun (k, v) -> Hashtbl.add chinese_table k v) chinese_keywords;
    List.iter (fun (k, v) -> Hashtbl.add ascii_table k v) ascii_keywords

  (** 查找中文关键字 *)
  let find_chinese_keyword keyword =
    try Some (Hashtbl.find chinese_table keyword) with Not_found -> None

  (** 查找ASCII关键字 *)
  let find_ascii_keyword keyword =
    try Some (Hashtbl.find ascii_table keyword) with Not_found -> None

  (** 检查是否为关键字（优先中文） *)
  let find_keyword keyword =
    match find_chinese_keyword keyword with
    | Some token -> Some token
    | None -> find_ascii_keyword keyword

  (** 获取所有关键字列表（用于调试和测试） *)
  let get_all_chinese_keywords () = chinese_keywords

  let get_all_ascii_keywords () = ascii_keywords
  let get_all_keywords () = List.rev_append chinese_keywords ascii_keywords
end

(** 优化的关键字匹配算法 *)
module OptimizedMatcher = struct
  (** 尝试匹配关键字的优化版本 *)
  let try_match_keyword state =
    let rec try_keywords keywords best_match =
      match keywords with
      | [] -> best_match
      | (keyword, token) :: rest ->
          let keyword_len = String.length keyword in
          if state.position + keyword_len <= state.length then
            let substring = String.sub state.input state.position keyword_len in
            if substring = keyword then
              (* 检查关键字边界 *)
              if BoundaryDetection.is_chinese_keyword_boundary state.input state.position keyword
              then
                (* 找到完整关键字，但继续检查是否有更长的匹配 *)
                let new_match = Some (token, keyword_len) in
                match best_match with
                | None -> try_keywords rest new_match
                | Some (_, best_len) when keyword_len > best_len -> try_keywords rest new_match
                | Some _ -> try_keywords rest best_match
              else try_keywords rest best_match
            else try_keywords rest best_match
          else try_keywords rest best_match
    in
    try_keywords (KeywordTable.get_all_keywords ()) None

  (** 高效的前缀匹配 *)
  let match_by_prefix state =
    let rec try_keywords keywords best_match =
      match keywords with
      | [] -> best_match
      | (keyword, token) :: rest ->
          let keyword_len = String.length keyword in
          if
            state.position + keyword_len <= state.length
            && String.sub state.input state.position keyword_len = keyword
            && BoundaryDetection.is_chinese_keyword_boundary state.input state.position keyword
          then
            let new_match = Some (token, keyword_len) in
            match best_match with
            | None -> try_keywords rest new_match
            | Some (_, best_len) when keyword_len > best_len -> try_keywords rest new_match
            | Some _ -> try_keywords rest best_match
          else try_keywords rest best_match
    in
    if state.position >= state.length then None
    else
      let c = state.input.[state.position] in
      (* 根据首字符快速过滤可能的关键字 *)
      let candidates =
        if Char.code c >= Constants.UTF8.chinese_char_threshold then
          (* 中文字符开头 - 搜索中文关键字 *)
          KeywordTable.get_all_chinese_keywords ()
        else
          (* ASCII字符开头 - 搜索ASCII关键字 *)
          KeywordTable.get_all_ascii_keywords ()
      in
      try_keywords candidates None
end

(** 关键字统计和分析工具 *)
module KeywordAnalytics = struct
  type keyword_stats = {
    total_keywords : int;
    chinese_keywords : int;
    ascii_keywords : int;
    avg_chinese_length : float;
    avg_ascii_length : float;
    max_length : int;
    min_length : int;
  }

  (** 分析关键字统计信息 *)
  let analyze_keywords () =
    let chinese_kws = KeywordTable.get_all_chinese_keywords () in
    let ascii_kws = KeywordTable.get_all_ascii_keywords () in

    let chinese_lengths = List.map (fun (kw, _) -> String.length kw) chinese_kws in
    let ascii_lengths = List.map (fun (kw, _) -> String.length kw) ascii_kws in
    let all_lengths = List.rev_append chinese_lengths ascii_lengths in

    let sum_chinese = List.fold_left ( + ) 0 chinese_lengths in
    let sum_ascii = List.fold_left ( + ) 0 ascii_lengths in

    {
      total_keywords = List.length chinese_kws + List.length ascii_kws;
      chinese_keywords = List.length chinese_kws;
      ascii_keywords = List.length ascii_kws;
      avg_chinese_length =
        (if chinese_lengths = [] then 0.0
         else float_of_int sum_chinese /. float_of_int (List.length chinese_lengths));
      avg_ascii_length =
        (if ascii_lengths = [] then 0.0
         else float_of_int sum_ascii /. float_of_int (List.length ascii_lengths));
      max_length = List.fold_left max 0 all_lengths;
      min_length = (match all_lengths with [] -> 0 | hd :: tl -> List.fold_left min hd tl);
    }

  (** 打印关键字统计信息 *)
  let print_keyword_stats stats =
    Unified_logging.Legacy.printf "=== 关键字统计分析 ===\n";
    Unified_logging.Legacy.printf "总关键字数: %d\n" stats.total_keywords;
    Unified_logging.Legacy.printf "中文关键字: %d\n" stats.chinese_keywords;
    Unified_logging.Legacy.printf "ASCII关键字: %d\n" stats.ascii_keywords;
    Unified_logging.Legacy.printf "中文关键字平均长度: %.2f 字符\n" stats.avg_chinese_length;
    Unified_logging.Legacy.printf "ASCII关键字平均长度: %.2f 字符\n" stats.avg_ascii_length;
    Unified_logging.Legacy.printf "最长关键字: %d 字符\n" stats.max_length;
    Unified_logging.Legacy.printf "最短关键字: %d 字符\n" stats.min_length;
    Unified_logging.Legacy.printf "==================\n"
end

(** 主要匹配函数 - 对外接口 *)
let match_keyword state = OptimizedMatcher.match_by_prefix state

(** 快速关键字查找 - 用于其他模块 *)
let lookup_keyword keyword_string = KeywordTable.find_keyword keyword_string

(** 检查字符串是否为关键字 *)
let is_keyword keyword_string =
  match lookup_keyword keyword_string with Some _ -> true | None -> false
