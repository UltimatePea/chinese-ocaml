(** 骆言Token系统整合重构 - 关键字映射管理 提供关键字的双向映射和管理功能 *)

open Yyocamlc_lib.Token_types

(** 关键字映射模块 *)
module KeywordMapping = struct
  (** 中文到关键字类型的映射 *)
  let chinese_to_keyword =
    [
      (* 基础关键字 *)
      ("让", Keywords.LetKeyword);
      ("如果", Keywords.IfKeyword);
      ("那么", Keywords.ThenKeyword);
      ("否则", Keywords.ElseKeyword);
      ("函数", Keywords.FunKeyword);
      ("递归", Keywords.RecKeyword);
      (* 类型关键字 *)
      (* 整数, 小数, 字符串, 布尔, 列表 - 这些不是关键字，是类型名 *)
      ("类型", Keywords.TypeKeyword);
      (* 控制流关键字 *)
      ("匹配", Keywords.MatchKeyword);
      ("与", Keywords.WithKeyword);
      ("当", Keywords.WhenKeyword);
      ("尝试", Keywords.TryKeyword);
      (* 循环, 遍历 - 这些关键字在当前版本中不支持 *)
      (* 模块关键字 *)
      ("模块", Keywords.ModuleKeyword);
      ("打开", Keywords.OpenKeyword);
      ("包含", Keywords.IncludeKeyword);
      ("结构", Keywords.StructKeyword);
      ("签名", Keywords.SigKeyword);
    ]

  (** 英文到关键字类型的映射 *)
  let english_to_keyword =
    [
      (* 基础关键字 *)
      ("let", Keywords.LetKeyword);
      ("if", Keywords.IfKeyword);
      ("then", Keywords.ThenKeyword);
      ("else", Keywords.ElseKeyword);
      ("function", Keywords.FunKeyword);
      ("rec", Keywords.RecKeyword);
      (* 类型关键字 *)
      (* int, float, string, bool, list - these are type names, not keywords *)
      ("type", Keywords.TypeKeyword);
      (* 控制流关键字 *)
      ("match", Keywords.MatchKeyword);
      ("with", Keywords.WithKeyword);
      ("when", Keywords.WhenKeyword);
      ("try", Keywords.TryKeyword);
      (* while, for - these keywords are not supported in current version *)
      (* 模块关键字 *)
      ("module", Keywords.ModuleKeyword);
      ("open", Keywords.OpenKeyword);
      ("include", Keywords.IncludeKeyword);
      ("struct", Keywords.StructKeyword);
      ("sig", Keywords.SigKeyword);
    ]

  (** 创建查找表 *)
  let chinese_keyword_table =
    let tbl = Hashtbl.create 32 in
    List.iter (fun (k, v) -> Hashtbl.add tbl k v) chinese_to_keyword;
    tbl

  let english_keyword_table =
    let tbl = Hashtbl.create 32 in
    List.iter (fun (k, v) -> Hashtbl.add tbl k v) english_to_keyword;
    tbl

  (** 反向映射：关键字类型到中文 *)
  let keyword_to_chinese_table =
    let tbl = Hashtbl.create 32 in
    List.iter (fun (k, v) -> Hashtbl.add tbl v k) chinese_to_keyword;
    tbl

  (** 反向映射：关键字类型到英文 *)
  let keyword_to_english_table =
    let tbl = Hashtbl.create 32 in
    List.iter (fun (k, v) -> Hashtbl.add tbl v k) english_to_keyword;
    tbl

  (** 查找中文关键字 *)
  let lookup_chinese_keyword text = Hashtbl.find_opt chinese_keyword_table text

  (** 查找英文关键字 *)
  let lookup_english_keyword text = Hashtbl.find_opt english_keyword_table text

  (** 通用关键字查找 *)
  let lookup_keyword text =
    match lookup_chinese_keyword text with
    | Some kw -> Some kw
    | None -> lookup_english_keyword text

  (** 关键字转换为中文 *)
  let keyword_to_chinese kw = Hashtbl.find_opt keyword_to_chinese_table kw

  (** 关键字转换为英文 *)
  let keyword_to_english kw = Hashtbl.find_opt keyword_to_english_table kw

  (** 检查是否为关键字 *)
  let is_keyword text = match lookup_keyword text with Some _ -> true | None -> false

  (** 获取所有中文关键字 *)
  let get_all_chinese_keywords () = List.map fst chinese_to_keyword

  (** 获取所有英文关键字 *)
  let get_all_english_keywords () = List.map fst english_to_keyword

  (** 获取所有关键字 *)
  let get_all_keywords () = get_all_chinese_keywords () @ get_all_english_keywords ()

  (** 按类别获取关键字 *)
  let get_keywords_by_category category =
    let filter_by_category (_, kw) =
      match (category, kw) with
      | ( "basic",
          Keywords.(
            LetKeyword | RecKeyword | InKeyword | FunKeyword | IfKeyword | ThenKeyword | ElseKeyword)
        ) ->
          true
      | "type", Keywords.TypeKeyword -> true
      | "control", Keywords.(MatchKeyword | WithKeyword | WhenKeyword | TryKeyword) -> true
      | ( "module",
          Keywords.(ModuleKeyword | OpenKeyword | IncludeKeyword | StructKeyword | SigKeyword) ) ->
          true
      | _ -> false
    in
    chinese_to_keyword |> List.filter filter_by_category |> List.map fst

  (** 关键字统计信息 *)
  let get_keyword_stats () =
    {|
中文关键字数量: |}
    ^ string_of_int (List.length chinese_to_keyword)
    ^ {|
英文关键字数量: |}
    ^ string_of_int (List.length english_to_keyword)
    ^ {|
基础关键字: |}
    ^ string_of_int (List.length (get_keywords_by_category "basic"))
    ^ {|
类型关键字: |}
    ^ string_of_int (List.length (get_keywords_by_category "type"))
    ^ {|
控制流关键字: |}
    ^ string_of_int (List.length (get_keywords_by_category "control"))
    ^ {|
模块关键字: |}
    ^ string_of_int (List.length (get_keywords_by_category "module"))
end

(** 关键字映射工厂 *)
module KeywordMappingFactory = struct
  type mapping_config = {
    include_chinese : bool;
    include_english : bool;
    case_sensitive : bool;
    custom_mappings : (string * Keywords.keyword_token) list;
  }

  let default_config =
    { include_chinese = true; include_english = true; case_sensitive = true; custom_mappings = [] }

  (** 根据配置创建映射表 *)
  let create_mapping config =
    let tbl = Hashtbl.create 64 in

    (* 添加中文映射 *)
    if config.include_chinese then
      List.iter (fun (k, v) -> Hashtbl.add tbl k v) KeywordMapping.chinese_to_keyword;

    (* 添加英文映射 *)
    if config.include_english then
      List.iter (fun (k, v) -> Hashtbl.add tbl k v) KeywordMapping.english_to_keyword;

    (* 添加自定义映射 *)
    List.iter (fun (k, v) -> Hashtbl.add tbl k v) config.custom_mappings;

    tbl

  (** 创建查找函数 *)
  let create_lookup_function config =
    let mapping = create_mapping config in
    fun text ->
      let search_text = if config.case_sensitive then text else String.lowercase_ascii text in
      Hashtbl.find_opt mapping search_text
end
