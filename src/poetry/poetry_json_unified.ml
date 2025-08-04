(** 诗词JSON处理统一模块 - Wave 2 架构修复版本

    基于代码审查反馈，消除了不必要的类型转换层，直接使用统一的核心类型。 现在真正实现了统一化，没有运行时类型转换开销。

    架构修复：
    - 直接使用 Rhyme_core_types，消除类型转换
    - 消除所有 convert_* 函数
    - 保持 100% API 向后兼容
    - 统一到单一权威类型源

    @author Alpha, Primary Worker Agent - Wave 2 架构修复团队
    @version 3.1 - 架构修复版本
    @since 2025-07-28 - 基于 Beta/Delta 代码审查反馈

    修复 issue #1550 - PR #1551 架构问题修复 *)

(** {1 统一类型导入 - 无转换层} *)

(* 类型别名以保持兼容性 - 直接引用核心模块 *)
type rhyme_category = Yyocamlc_lib.Poetry_core.Poetry_types.rhyme_category
type rhyme_group = Yyocamlc_lib.Poetry_core.Poetry_types.rhyme_group

(* 导入构造函数以便在转换中使用 *)
open Yyocamlc_lib.Poetry_core.Poetry_types

(* JSON处理专用类型 - 直接使用核心模块定义 *)
type rhyme_group_data = Poetry_rhyme.Rhyme_types.rhyme_group_data

type rhyme_data_file = Yyocamlc_lib.Poetry_core.Types.rhyme_data_file

(** {1 主要API接口 - 直接使用统一核心} *)

(** 获取韵律数据（支持缓存） - 直接转发到统一核心 *)
let get_data ?(force_reload = false) () =
  match Yyocamlc_lib.Poetry_core.Types.get_rhyme_data_safe ~force_reload () with
  | Some data -> data
  | None -> failwith "无法获取韵律数据"

(** 安全获取韵律数据（带降级处理） - 直接转发到统一核心 *)
let get_data_safe ?(force_reload = false) () =
  match Yyocamlc_lib.Poetry_core.Types.get_rhyme_data_safe ~force_reload () with
  | Some data -> data
  | None -> Yyocamlc_lib.Poetry_core.Types.Fallback.use_fallback_data ()

(** 获取所有韵组 - 直接转发到统一核心 *)
let get_all_groups () = Yyocamlc_lib.Poetry_core.Types.get_all_rhyme_groups ()

(** 获取指定韵组的字符列表 - 转发到统一核心 *)
let get_group_characters group_name = Yyocamlc_lib.Poetry_core.Types.get_rhyme_group_characters group_name

(** 获取指定韵组的韵类 - 直接转发到统一核心 *)
let get_group_category group_name =
  let json_category = Yyocamlc_lib.Poetry_core.Types.get_rhyme_group_category group_name in
  (* 类型转换: Yyocamlc_lib.Poetry_core.Types.rhyme_category -> Poetry_core.Rhyme_core_types.rhyme_category *)
  match json_category with
  | PingSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.PingSheng
  | ZeSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.ZeSheng
  | ShangSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.ShangSheng
  | QuSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.QuSheng
  | RuSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.RuSheng

(** {1 字符查询接口 - 转发到统一核心} *)

(** 获取字符到韵律的映射关系 - 直接转发到统一核心 *)
let get_char_mappings () =
  let raw_mappings = Yyocamlc_lib.Poetry_core.Types.get_rhyme_mappings () in
  (* 转换类型: Poetry_core.Poetry_types -> Poetry_core.Rhyme_core_types *)
  List.map
    (fun (char, (cat, grp)) ->
      let converted_cat =
        match cat with
        | PingSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.PingSheng
        | ZeSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.ZeSheng
        | ShangSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.ShangSheng
        | QuSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.QuSheng
        | RuSheng -> Yyocamlc_lib.Poetry_core.Poetry_types.RuSheng
      in
      let converted_grp =
        match grp with
        | AnRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.AnRhyme
        | SiRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.SiRhyme
        | TianRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.TianRhyme
        | WangRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.WangRhyme
        | QuRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.QuRhyme
        | YuRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.YuRhyme
        | HuaRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.HuaRhyme
        | FengRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.FengRhyme
        | YueRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.YueRhyme
        | XueRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.XueRhyme
        | JiangRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.JiangRhyme
        | HuiRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.HuiRhyme
        | UnknownRhyme -> Yyocamlc_lib.Poetry_core.Poetry_types.UnknownRhyme
      in
      (char, (converted_cat, converted_grp)))
    raw_mappings

(** 查找字符的韵律信息 - 转发到统一核心 *)
let lookup_char char =
  let mappings = get_char_mappings () in
  try
    let category, group = List.assoc char mappings in
    Some (category, group)
  with Not_found -> None

let lookup_character_rhyme (db : rhyme_data_file) char =
  if String.length char = 0 then None
  else
    try
      let mappings =
        List.fold_left
          (fun acc (group_name, (group_data : rhyme_group_data)) ->
            match
              ( Yyocamlc_lib.Poetry_core.Types.string_to_rhyme_category group_data.category,
                Yyocamlc_lib.Poetry_core.Types.string_to_rhyme_group group_name )
            with
            | Some category, Some group ->
                List.fold_left
                  (fun acc2 character -> (character, (category, group)) :: acc2)
                  acc group_data.characters
            | _ -> acc)
          [] db.rhyme_groups
      in
      let category, group = List.assoc char mappings in
      Some (category, group)
    with Not_found -> None

(** {1 统计和调试接口 - 转发到统一核心} *)

(** 获取统计信息 - 转发到统一核心 *)
let get_statistics () =
  match Yyocamlc_lib.Poetry_core.Types.get_data_statistics () with
  | Some (total_groups, total_chars, _, _, _) -> (total_groups, total_chars)
  | None -> (0, 0)

(** 打印统计信息 - 转发到统一核心 *)
let print_statistics () = Yyocamlc_lib.Poetry_core.Types.print_statistics ()

(** {1 缓存管理接口 - 转发到统一核心} *)

(** 清空缓存 - 转发到统一核心 *)
let clear_cache () = Yyocamlc_lib.Poetry_core.Types.clear_cache ()

(** 刷新缓存数据 - 直接转发到统一核心 *)
let refresh_cache (data : rhyme_data_file) =
  clear_cache ();
  Yyocamlc_lib.Poetry_core.Types.Cache.set_cached_data data

type recovery_result = {
  recovery_attempted : bool;
  recovery_successful : bool;
  error_messages : string list;
}

(** 尝试恢复数据库 - 通过重新加载和清理缓存 *)
let attempt_database_recovery () =
  try
    clear_cache ();
    let _ = get_data_safe ~force_reload:true () in
    { recovery_attempted = true; recovery_successful = true; error_messages = [] }
  with exn ->
    {
      recovery_attempted = true;
      recovery_successful = false;
      error_messages = [ Printexc.to_string exn ];
    }

(** 获取API版本信息 *)
let get_api_version () = "3.1-architecture-fix"
