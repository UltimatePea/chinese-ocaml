(** 骆言关键字表模块 - Chinese Programming Language Keyword Tables

    重构版本：将大型数据函数拆分为独立数据模块， 提升可维护性和访问效率。

    @since Phase8 技术债务重构 *)

(** 字符串比较模块 *)
module StringCompare = struct
  type t = string

  let compare = String.compare
end

module StringMap = Map.Make (StringCompare)
(** 字符串Map模块 *)

module StringSet = Set.Make (StringCompare)
(** 字符串Set模块 *)

(** 关键字映射模块 *)
module Keywords = struct
  (* 直接引用数据模块，替代原有的269行大函数 *)
  let basic_keywords = Lexer_data.Basic_keywords_data.basic_keywords
  let semantic_keywords = Lexer_data.Basic_keywords_data.semantic_keywords
  let error_recovery_keywords = Lexer_data.Basic_keywords_data.error_recovery_keywords
  let type_keywords = Lexer_data.Basic_keywords_data.type_keywords
  let module_keywords = Lexer_data.Basic_keywords_data.module_keywords
  let macro_keywords = Lexer_data.Basic_keywords_data.macro_keywords
  let wenyan_keywords = Lexer_data.Basic_keywords_data.wenyan_keywords
  let wenyan_extended_keywords = Lexer_data.Basic_keywords_data.wenyan_extended_keywords
  let natural_language_keywords = Lexer_data.Basic_keywords_data.natural_language_keywords
  let type_annotation_keywords = Lexer_data.Basic_keywords_data.type_annotation_keywords
  let variant_keywords = Lexer_data.Basic_keywords_data.variant_keywords
  let ancient_keywords = Lexer_data.Basic_keywords_data.ancient_keywords
  let special_keywords = Lexer_data.Basic_keywords_data.special_keywords
  let all_keywords_list = Lexer_data.Basic_keywords_data.all_keywords_list

  (** 高效关键字映射表 - 使用Map替代List.assoc *)
  let keyword_map =
    List.fold_left
      (fun acc (key, value) -> StringMap.add key value acc)
      StringMap.empty all_keywords_list

  (** 高效关键字查找 - 使用Map替代线性查找 *)
  let find_keyword str = StringMap.find_opt str keyword_map

  (** 检查是否为关键字 *)
  let is_keyword str = StringMap.mem str keyword_map

  (** 获取所有关键字列表 *)
  let all_keywords () = StringMap.bindings keyword_map |> List.map fst

  (** 保持向后兼容性的关键字列表 *)
  let all_keywords_list = all_keywords_list
end

(** 保留词模块 *)
module ReservedWords = struct
  (* 直接引用数据模块，提升可维护性 *)
  let reserved_words_list = Lexer_data.Reserved_words_data.reserved_words_list

  (** 高效保留词检查 - 使用Set替代List.mem *)
  let reserved_words_set =
    List.fold_left (fun acc word -> StringSet.add word acc) StringSet.empty reserved_words_list

  (** 检查是否为保留词 *)
  let is_reserved_word str = StringSet.mem str reserved_words_set

  (** 获取所有保留词列表 *)
  let all_reserved_words () = StringSet.elements reserved_words_set

  (** 保持向后兼容性的保留词列表 *)
  let reserved_words_list = reserved_words_list
end
