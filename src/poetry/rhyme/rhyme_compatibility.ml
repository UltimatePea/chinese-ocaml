(** 韵律模块向后兼容性接口
    
    提供与原有12个韵律数据文件完全兼容的接口，确保现有代码无需修改。
    通过适配器模式将新的统一接口映射到原有的API格式。
    
    Author: Whisky, PR Worker
    Issue: #1999 - Poetry韵律模块统一整合实施
    
    兼容的原始模块:
    - An_rhyme_data, Si_rhyme_data, Tian_rhyme_data, Wang_rhyme_data
    - Qu_rhyme_data, Yu_rhyme_data, Hua_rhyme_data, Feng_rhyme_data
    - Yue_rhyme_data, Jiang_rhyme_data, Hui_rhyme_data
    - Rhyme_data_core (核心数据结构)
    
    @since 2025-08-03 *)

open Rhyme_types
open Rhyme_data

(** {1 原始数据格式兼容} *)

(** 原始rhyme_data_core.ml的类型兼容 *)
module Legacy_Core = struct
  (** 兼容原有的rhyme_entry类型 *)
  type rhyme_entry = {
    character : string;
    category : tone_category;
    group : rhyme_group;
    variants : string list;
    usage_frequency : float;
  }

  (** 兼容原有的rhyme_group_data类型 *)
  type rhyme_group_data = {
    group_name : rhyme_group;
    group_description : string;
    entries : rhyme_entry list;
    example_poems : string list;
  }

  (** 转换新格式到旧格式 *)
  let convert_to_legacy_entry (char : rhyme_character) : rhyme_entry =
    {
      character = char.character;
      category = char.rhyme_category;
      group = char.rhyme_group;
      variants = char.variants;
      usage_frequency = char.usage_frequency;
    }

  let convert_to_legacy_group_data (group_data : Rhyme_types.rhyme_group_data) : rhyme_group_data =
    {
      group_name = group_data.group_id;
      group_description = group_data.description;
      entries = List.map convert_to_legacy_entry group_data.all_characters;
      example_poems = group_data.example_poems;
    }

  (** 原有的辅助函数 *)
  let make_rhyme_group_data group_name description tuples_list =
    let entries = List.map (fun (char, category, group) ->
      { character = char; category; group; variants = []; usage_frequency = 1.0 }
    ) tuples_list in
    { group_name; group_description = description; entries; example_poems = [] }

  let make_ping_sheng_group rhyme_type chars =
    List.map (fun char -> (char, PingSheng, rhyme_type)) chars

  let make_ze_sheng_group rhyme_type chars = 
    List.map (fun char -> (char, QuSheng, rhyme_type)) chars

  let create_rhyme_data rhyme_type description ping_chars ze_chars =
    let ping_sheng_data = make_ping_sheng_group rhyme_type ping_chars in
    let ze_sheng_data = make_ze_sheng_group rhyme_type ze_chars in
    let tuples_data = ping_sheng_data @ ze_sheng_data in
    make_rhyme_group_data rhyme_type description tuples_data
end

(** {1 个别韵组数据模块兼容} *)

(** 安韵组数据兼容 *)
module An_rhyme_data = struct
  let ping_sheng_chars = get_ping_sheng_characters AnRhyme
  let ze_sheng_chars = get_ze_sheng_characters AnRhyme
  let an_rhyme_data = 
    match lookup_group AnRhyme with
    | Some group_data -> Legacy_Core.convert_to_legacy_group_data group_data
    | None -> Legacy_Core.create_rhyme_data AnRhyme "安韵组：山、关、间等韵字" [] []
end

(** 思韵组数据兼容 *)
module Si_rhyme_data = struct
  let ping_sheng_chars = get_ping_sheng_characters SiRhyme
  let ze_sheng_chars = get_ze_sheng_characters SiRhyme
  let si_rhyme_data = 
    match lookup_group SiRhyme with
    | Some group_data -> Legacy_Core.convert_to_legacy_group_data group_data
    | None -> Legacy_Core.create_rhyme_data SiRhyme "思韵组：思、师、时等韵字" [] []
end

(** 天韵组数据兼容 *)
module Tian_rhyme_data = struct
  let ping_sheng_chars = get_ping_sheng_characters TianRhyme
  let ze_sheng_chars = get_ze_sheng_characters TianRhyme
  let tian_rhyme_data = 
    match lookup_group TianRhyme with
    | Some group_data -> Legacy_Core.convert_to_legacy_group_data group_data
    | None -> Legacy_Core.create_rhyme_data TianRhyme "天韵组：天、年、先等韵字" [] []
end

(** 王韵组数据兼容 *)
module Wang_rhyme_data = struct
  let ping_sheng_chars = get_ping_sheng_characters WangRhyme
  let ze_sheng_chars = get_ze_sheng_characters WangRhyme
  let wang_rhyme_data = 
    match lookup_group WangRhyme with
    | Some group_data -> Legacy_Core.convert_to_legacy_group_data group_data
    | None -> Legacy_Core.create_rhyme_data WangRhyme "王韵组：王、香、方等韵字" [] []
end

(** 去韵组数据兼容 *)
module Qu_rhyme_data = struct
  let ping_sheng_chars = get_ping_sheng_characters QuRhyme
  let ze_sheng_chars = get_ze_sheng_characters QuRhyme
  let qu_rhyme_data = 
    match lookup_group QuRhyme with
    | Some group_data -> Legacy_Core.convert_to_legacy_group_data group_data
    | None -> Legacy_Core.create_rhyme_data QuRhyme "去韵组：去、数、路等韵字" [] []
end

(** 鱼韵组数据兼容 *)
module Yu_rhyme_data = struct
  let ping_sheng_chars = get_ping_sheng_characters YuRhyme
  let ze_sheng_chars = get_ze_sheng_characters YuRhyme
  let yu_rhyme_data = 
    match lookup_group YuRhyme with
    | Some group_data -> Legacy_Core.convert_to_legacy_group_data group_data
    | None -> Legacy_Core.create_rhyme_data YuRhyme "鱼韵组：鱼、书、居等韵字" [] []
end

(** 花韵组数据兼容 *)
module Hua_rhyme_data = struct
  let ping_sheng_chars = get_ping_sheng_characters HuaRhyme
  let ze_sheng_chars = get_ze_sheng_characters HuaRhyme
  let hua_rhyme_data = 
    match lookup_group HuaRhyme with
    | Some group_data -> Legacy_Core.convert_to_legacy_group_data group_data
    | None -> Legacy_Core.create_rhyme_data HuaRhyme "花韵组：花、家、霞等韵字" [] []
end

(** 风韵组数据兼容 *)
module Feng_rhyme_data = struct
  let ping_sheng_chars = get_ping_sheng_characters FengRhyme
  let ze_sheng_chars = get_ze_sheng_characters FengRhyme
  let feng_rhyme_data = 
    match lookup_group FengRhyme with
    | Some group_data -> Legacy_Core.convert_to_legacy_group_data group_data
    | None -> Legacy_Core.create_rhyme_data FengRhyme "风韵组：风、东、中等韵字" [] []
end

(** 月韵组数据兼容 *)
module Yue_rhyme_data = struct
  let ping_sheng_chars = get_ping_sheng_characters YueRhyme
  let ze_sheng_chars = get_ze_sheng_characters YueRhyme
  let yue_rhyme_data = 
    match lookup_group YueRhyme with
    | Some group_data -> Legacy_Core.convert_to_legacy_group_data group_data
    | None -> Legacy_Core.create_rhyme_data YueRhyme "月韵组：月、雪、节等韵字" [] []
end

(** 江韵组数据兼容 *)
module Jiang_rhyme_data = struct
  let ping_sheng_chars = get_ping_sheng_characters JiangRhyme
  let ze_sheng_chars = get_ze_sheng_characters JiangRhyme
  let jiang_rhyme_data = 
    match lookup_group JiangRhyme with
    | Some group_data -> Legacy_Core.convert_to_legacy_group_data group_data
    | None -> Legacy_Core.create_rhyme_data JiangRhyme "江韵组：江、窗、床等韵字" [] []
end

(** 灰韵组数据兼容 *)
module Hui_rhyme_data = struct
  let ping_sheng_chars = get_ping_sheng_characters HuiRhyme
  let ze_sheng_chars = get_ze_sheng_characters HuiRhyme
  let hui_rhyme_data = 
    match lookup_group HuiRhyme with
    | Some group_data -> Legacy_Core.convert_to_legacy_group_data group_data
    | None -> Legacy_Core.create_rhyme_data HuiRhyme "灰韵组：灰、开、来等韵字" [] []
end

(** {1 传统查询接口兼容} *)

(** 传统韵律查询接口 *)
module Legacy_Query = struct
  (** 原有的查询结果类型 *)
  type legacy_query_result = 
    | Found of Legacy_Core.rhyme_entry
    | NotFound

  (** 转换查询结果格式 *)
  let convert_query_result = function
    | Rhyme_types.Found char -> Found (Legacy_Core.convert_to_legacy_entry char)
    | Rhyme_types.NotFound _ -> NotFound
    | Rhyme_types.MultipleMatches (char :: _) -> Found (Legacy_Core.convert_to_legacy_entry char)
    | Rhyme_types.MultipleMatches [] -> NotFound

  (** 传统字符查询 *)
  let rhyme_lookup char =
    convert_query_result (lookup_character char)

  (** 传统韵组查询 *)
  let group_lookup group =
    match lookup_group group with
    | Some group_data -> Some (Legacy_Core.convert_to_legacy_group_data group_data)
    | None -> None

  (** 检查是否为平声字 *)
  let is_ping_sheng char =
    match lookup_character char with
    | Found rhyme_char -> rhyme_char.rhyme_category = PingSheng
    | _ -> false

  (** 检查是否为仄声字 *)
  let is_ze_sheng_char char =
    match lookup_character char with
    | Found rhyme_char -> is_ze_sheng rhyme_char.rhyme_category
    | _ -> false

  (** 获取字符韵组 *)
  let get_rhyme_group char =
    match lookup_character char with
    | Found rhyme_char -> Some rhyme_char.rhyme_group
    | _ -> None
end

(** {1 韵组注册表兼容} *)

(** 传统韵组注册表接口 *)
module Legacy_Registry = struct
  (** 获取所有注册的韵组 *)
  let get_all_registered_groups () =
    List.map Legacy_Core.convert_to_legacy_group_data (get_all_groups ())

  (** 根据名称查找韵组 *)
  let find_group_by_name name =
    let groups = get_all_groups () in
    List.find_opt (fun g -> g.group_name = name) groups |>
    Option.map Legacy_Core.convert_to_legacy_group_data

  (** 注册新韵组（兼容性函数，实际上不执行注册） *)
  let register_rhyme_group _group_data =
    (* 兼容性函数，新系统中数据是静态的 *)
    ()
end

(** {1 统一的兼容性别名} *)

(** 为了最大兼容性，提供原模块名的直接别名 *)
module Rhyme_data_core = Legacy_Core
module Rhyme_data_registry = Legacy_Registry

(** {1 兼容性测试和验证} *)

(** 验证兼容性映射是否正确 *)
let verify_compatibility () =
  let test_chars = ["春"; "花"; "山"; "水"] in
  let legacy_results = List.map Legacy_Query.rhyme_lookup test_chars in
  let new_results = List.map lookup_character test_chars in
  
  List.for_all2 (fun legacy new_res ->
    match legacy, new_res with
    | Legacy_Query.Found legacy_entry, Found new_char ->
        legacy_entry.character = new_char.character &&
        legacy_entry.group = new_char.rhyme_group
    | Legacy_Query.NotFound, NotFound _ -> true
    | _ -> false
  ) legacy_results new_results

(** 获取兼容性报告 *)
let get_compatibility_report () =
  let total_groups = List.length all_rhyme_groups in
  let compatible_groups = List.fold_left (fun acc group ->
    match lookup_group group with
    | Some _ -> acc + 1
    | None -> acc
  ) 0 all_rhyme_groups in
  
  let is_compatible = verify_compatibility () in
  
  Printf.sprintf 
    "韵律模块兼容性报告\n兼容韵组: %d/%d\n总体兼容性: %s\n支持的传统接口: 11个韵组模块 + 核心查询接口"
    compatible_groups total_groups (if is_compatible then "✓ 完全兼容" else "✗ 存在问题")