(** 骆言词法分析器关键字匹配核心模块 *)

open Token_types
open Keywords

(** 关键字查找表模块 *)
module KeywordTable = struct
  (* 合并所有中文关键字组 *)
  let chinese_keywords =
    List.concat [
      Keyword_matcher_tables_basic.get_all_basic_keywords ();
      Keyword_matcher_tables_ancient.get_all_ancient_keywords ();
    ]

  (* 构建高效的哈希表 *)
  let chinese_table = Hashtbl.create (List.length chinese_keywords)
  let ascii_table = Hashtbl.create (List.length (Keyword_matcher_tables_ascii.get_ascii_keywords ()))

  (* 初始化哈希表 *)
  let () =
    List.iter (fun (k, v) -> Hashtbl.add chinese_table k v) chinese_keywords;
    List.iter (fun (k, v) -> Hashtbl.add ascii_table k v) (Keyword_matcher_tables_ascii.get_ascii_keywords ())

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

  let get_all_ascii_keywords () = Keyword_matcher_tables_ascii.get_ascii_keywords ()
  let get_all_keywords () = List.rev_append chinese_keywords (Keyword_matcher_tables_ascii.get_ascii_keywords ())
end