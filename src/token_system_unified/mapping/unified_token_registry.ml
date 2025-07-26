(** 统一Token注册系统 - 重构后的轻量级注册器 *)

open Yyocamlc_lib.Unified_token_core

type mapping_entry = {
  source : string;  (** 源字符串 *)
  target : unified_token;  (** 目标token *)
  priority : int;  (** 优先级 (1=高, 2=中, 3=低) *)
  category : string;  (** 分类信息 *)
  enabled : bool;  (** 是否启用 *)
}
(** 映射条目类型 - 简化设计 *)

(** 重构后的Token注册表 - 使用Builder模式和工具函数 *)
module TokenRegistry = struct
  (** 映射表：字符串 -> 映射条目列表 *)
  let mapping_table : (string, mapping_entry list) Hashtbl.t = Hashtbl.create 128

  (** 反向映射表：token -> 字符串列表 *)
  let reverse_table : (unified_token, string list) Hashtbl.t = Hashtbl.create 128

  (** 注册单个映射 *)
  let register_mapping entry =
    let { source; target; _ } = entry in
    (* 添加到正向映射表 *)
    let existing_entries = try Hashtbl.find mapping_table source with Not_found -> [] in
    let updated_entries = entry :: existing_entries in
    Hashtbl.replace mapping_table source updated_entries;

    (* 添加到反向映射表 *)
    let existing_sources = try Hashtbl.find reverse_table target with Not_found -> [] in
    let updated_sources = source :: existing_sources in
    Hashtbl.replace reverse_table target updated_sources

  (** 批量注册映射 *)
  let register_batch entries = List.iter register_mapping entries

  (** 查找映射 - 优化的优先级排序 *)
  let find_mapping source =
    try
      let entries = Hashtbl.find mapping_table source in
      let enabled_entries = List.filter (fun e -> e.enabled) entries in
      let sorted_entries =
        List.sort (fun e1 e2 -> compare e1.priority e2.priority) enabled_entries
      in
      match sorted_entries with [] -> None | entry :: _ -> Some entry
    with Not_found -> None

  (** 查找所有映射 *)
  let find_all_mappings source = try Hashtbl.find mapping_table source with Not_found -> []

  (** 反向查找 *)
  let reverse_lookup token = try Hashtbl.find reverse_table token with Not_found -> []

  (** 检查映射冲突 - 优化实现 *)
  let check_conflicts () =
    Hashtbl.fold
      (fun source entries acc ->
        let enabled_entries = List.filter (fun e -> e.enabled) entries in
        let high_priority = List.filter (fun e -> e.priority = 1) enabled_entries in
        if List.length high_priority > 1 then (source, enabled_entries) :: acc else acc)
      mapping_table []

  (** 获取统计信息 - 优化实现 *)
  let get_stats () =
    let total_mappings = Hashtbl.length mapping_table in
    let total_tokens = Hashtbl.length reverse_table in
    let enabled_count, disabled_count =
      Hashtbl.fold
        (fun _ entries (en, dis) ->
          List.fold_left
            (fun (e, d) entry -> if entry.enabled then (e + 1, d) else (e, d + 1))
            (en, dis) entries)
        mapping_table (0, 0)
    in
    (total_mappings, total_tokens, enabled_count, disabled_count)

  (** 清空注册表 *)
  let clear () =
    Hashtbl.clear mapping_table;
    Hashtbl.clear reverse_table
end

(** 映射Builder - 提供便捷的映射创建 API *)
module MappingBuilder = struct
  (** 创建映射条目 *)
  let make_mapping source target ?(priority = 2) ?(category = "general") ?(enabled = true) () =
    { source; target; priority; category; enabled }

  (** 高优先级映射 *)
  let high_priority source target = make_mapping source target ~priority:1 ()

  (** 中优先级映射 *)
  let medium_priority source target = make_mapping source target ~priority:2 ()

  (** 低优先级映射 *)
  let low_priority source target = make_mapping source target ~priority:3 ()

  (** 带分类的映射 *)
  let with_category source target category = make_mapping source target ~category ()

  (** 禁用的映射 *)
  let disabled source target = make_mapping source target ~enabled:false ()

  (** 批量创建器 *)
  let batch_mappings mappings_spec =
    List.map (fun (s, t, p, c) -> make_mapping s t ~priority:p ~category:c ()) mappings_spec
end

(** 数据驱动的映射注册器 - 替代硬编码方案 *)
module DataDrivenMappings = struct
  open MappingBuilder

  (** 从内置数据注册映射 - 简化实现 *)
  let register_core_mappings () =
    let basic_mappings =
      [
        (* 中文关键字 *)
        high_priority "让" LetKeyword;
        high_priority "设" LetKeyword;
        high_priority "函数" FunKeyword;
        high_priority "如果" IfKeyword;
        high_priority "那么" ThenKeyword;
        high_priority "否则" ElseKeyword;
        high_priority "匹配" MatchKeyword;
        high_priority "与" WithKeyword;
        high_priority "且" AndKeyword;
        high_priority "或" OrKeyword;
        high_priority "非" NotKeyword;
        high_priority "真" TrueKeyword;
        high_priority "假" FalseKeyword;
        high_priority "在" InKeyword;
        high_priority "递归" RecKeyword;
        (* 英文关键字 *)
        high_priority "let" LetKeyword;
        high_priority "fun" FunKeyword;
        high_priority "function" FunKeyword;
        high_priority "if" IfKeyword;
        high_priority "then" ThenKeyword;
        high_priority "else" ElseKeyword;
        high_priority "match" MatchKeyword;
        high_priority "with" WithKeyword;
        high_priority "and" AndKeyword;
        high_priority "or" OrKeyword;
        high_priority "not" NotKeyword;
        high_priority "true" TrueKeyword;
        high_priority "false" FalseKeyword;
        high_priority "in" InKeyword;
        high_priority "rec" RecKeyword;
        (* 运算符 *)
        high_priority "+" PlusOp;
        high_priority "-" MinusOp;
        high_priority "*" MultiplyOp;
        high_priority "/" DivideOp;
        high_priority "=" EqualOp;
        high_priority "<>" NotEqualOp;
        high_priority "<" LessOp;
        high_priority ">" GreaterOp;
        high_priority "->" ArrowOp;
      ]
    in
    TokenRegistry.register_batch basic_mappings;
    Printf.printf "✅ 成功注册 %d 个核心映射\n" (List.length basic_mappings)

  (** 注册扩展映射（运行时添加的映射） *)
  let register_runtime_extensions () =
    let extensions = [ (* 可以在这里添加运行时生成的映射 *) with_category "动态" LetKeyword "runtime_generated" ] in
    TokenRegistry.register_batch extensions

  (** 验证映射完整性 *)
  let validate_mappings () =
    let conflicts = TokenRegistry.check_conflicts () in
    let total_mappings, total_tokens, enabled_count, disabled_count = TokenRegistry.get_stats () in

    Printf.printf {|
=== Token映射验证报告 ===
总映射数: %d
总token类型: %d  
启用映射: %d
禁用映射: %d
冲突数: %d
|}
      total_mappings total_tokens enabled_count disabled_count (List.length conflicts);

    if List.length conflicts > 0 then (
      Printf.printf "\n⚠️  发现以下映射冲突:\n";
      List.iter
        (fun (source, entries) ->
          Printf.printf "- 源 '%s' 有 %d 个高优先级映射\n" source (List.length entries))
        conflicts)

  (** 统一初始化函数 *)
  let initialize_all () =
    Printf.printf "🚀 初始化统一Token注册系统...\n";
    register_core_mappings ();
    register_runtime_extensions ();
    validate_mappings ();
    Printf.printf "✅ Token注册系统初始化完成\n"
end

(** 初始化注册表 - 重构后的简化实现 *)
let initialize () =
  TokenRegistry.clear ();
  DataDrivenMappings.initialize_all ()
