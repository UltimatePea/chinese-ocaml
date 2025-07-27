(** 骆言词法分析器关键字匹配核心模块 *)

open Token_types

(** 从Lexer_tokens.token转换为Token_types.Keywords.keyword_token *)
let convert_token_to_keyword = function
  | Lexer_tokens.LetKeyword -> Some Keywords.LetKeyword
  | Lexer_tokens.RecKeyword -> Some Keywords.RecKeyword
  | Lexer_tokens.InKeyword -> Some Keywords.InKeyword
  | Lexer_tokens.FunKeyword -> Some Keywords.FunKeyword
  | Lexer_tokens.IfKeyword -> Some Keywords.IfKeyword
  | Lexer_tokens.ThenKeyword -> Some Keywords.ThenKeyword
  | Lexer_tokens.ElseKeyword -> Some Keywords.ElseKeyword
  | Lexer_tokens.MatchKeyword -> Some Keywords.MatchKeyword
  | Lexer_tokens.WithKeyword -> Some Keywords.WithKeyword
  | Lexer_tokens.OtherKeyword -> Some Keywords.OtherKeyword
  | Lexer_tokens.TypeKeyword -> Some Keywords.TypeKeyword
  | Lexer_tokens.PrivateKeyword -> Some Keywords.PrivateKeyword
  | Lexer_tokens.TrueKeyword -> Some Keywords.TrueKeyword
  | Lexer_tokens.FalseKeyword -> Some Keywords.FalseKeyword
  | Lexer_tokens.AndKeyword -> Some Keywords.AndKeyword
  | Lexer_tokens.OrKeyword -> Some Keywords.OrKeyword
  | Lexer_tokens.NotKeyword -> Some Keywords.NotKeyword
  | Lexer_tokens.AsKeyword -> Some Keywords.AsKeyword
  | Lexer_tokens.CombineKeyword -> Some Keywords.CombineKeyword
  | Lexer_tokens.WithOpKeyword -> Some Keywords.WithOpKeyword
  | Lexer_tokens.WhenKeyword -> Some Keywords.WhenKeyword
  | Lexer_tokens.OrElseKeyword -> Some Keywords.OrElseKeyword
  | Lexer_tokens.WithDefaultKeyword -> Some Keywords.WithDefaultKeyword
  | Lexer_tokens.ExceptionKeyword -> Some Keywords.ExceptionKeyword
  | Lexer_tokens.RaiseKeyword -> Some Keywords.RaiseKeyword
  | Lexer_tokens.TryKeyword -> Some Keywords.TryKeyword
  | Lexer_tokens.CatchKeyword -> Some Keywords.CatchKeyword
  | Lexer_tokens.FinallyKeyword -> Some Keywords.FinallyKeyword
  | Lexer_tokens.OfKeyword -> Some Keywords.OfKeyword
  | Lexer_tokens.ModuleKeyword -> Some Keywords.ModuleKeyword
  | Lexer_tokens.ModuleTypeKeyword -> Some Keywords.ModuleTypeKeyword
  | Lexer_tokens.IncludeKeyword -> Some Keywords.IncludeKeyword
  | Lexer_tokens.SigKeyword -> Some Keywords.SigKeyword
  | Lexer_tokens.EndKeyword -> Some Keywords.EndKeyword
  | Lexer_tokens.FunctorKeyword -> Some Keywords.FunctorKeyword
  | _ -> None (* 只处理关键字Token，其他类型返回None *)

(** 关键字查找表模块 *)
module KeywordTable = struct
  (* 转换原始关键字表格，过滤并转换为新的token格式 *)
  let chinese_keywords =
    List.concat
      [
        Keyword_matcher_tables_basic.get_all_basic_keywords ();
        Keyword_matcher_tables_ancient.get_all_ancient_keywords ();
      ]
    |> List.filter_map (fun (str, token) ->
           match convert_token_to_keyword token with
           | Some keyword_token -> Some (str, keyword_token)
           | None -> None)

  let ascii_keywords =
    Keyword_matcher_tables_ascii.get_ascii_keywords ()
    |> List.filter_map (fun (str, token) ->
           match convert_token_to_keyword token with
           | Some keyword_token -> Some (str, keyword_token)
           | None -> None)

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
