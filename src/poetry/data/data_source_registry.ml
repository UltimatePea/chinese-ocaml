(** 诗词数据源注册器 - 自动注册所有可用数据源

    此模块负责将分散在各个模块中的诗词数据自动注册到统一数据加载器中。 通过统一注册，消除数据重复并提供一致的访问接口。

    @author 骆言诗词编程团队 - Phase 15 代码重复消除
    @version 1.0
    @since 2025-07-19 *)

open Poetry_data_loader

(** {1 类型转换函数} *)

(* 导入统一的核心类型 *)
open Data_source_manager
(*open Poetry_core.Poetry_types - removed dependency*)

(** 将韵类字符串转换为统一类型 *)
let convert_rhyme_category category_str = 
  match category_str with
  | "PingSheng" | "平声" -> "平声"
  | "ZeSheng" | "仄声" -> "仄声"  
  | "ShangSheng" | "上声" -> "上声"
  | "QuSheng" | "去声" -> "去声"
  | "RuSheng" | "入声" -> "入声"
  | _ -> "平声"  (* default fallback *)

let convert_rhyme_group group_str = 
  match group_str with
  | "YuRhyme" | "语" -> "语"
  | "HuaRhyme" | "花" -> "花"
  | "FengRhyme" | "风" -> "风"
  | "YueRhyme" | "月" -> "月"
  | "JiangRhyme" | "江" -> "江"
  | "HuiRhyme" | "回" -> "回"
  | "TianRhyme" | "天" -> "天"
  | "SiRhyme" | "四" -> "四"
  | "AnRhyme" | "安" -> "安"
  | "WangRhyme" | "王" -> "王"
  | "QuRhyme" | "曲" -> "曲"
  | "XueRhyme" | "雪" -> "雪"
  | _ -> "安"  (* default fallback *)

(** 转换数据项列表 *)
let _convert_data_list data_list =
  List.map
    (fun (char, cat, grp) -> (char, convert_rhyme_category cat, convert_rhyme_group grp))
    data_list

(** {1 数据源引用} *)

(** 使用统一的韵组模块接口 - Fix #1999 *)
module Yu_rhyme = struct
  let data = Poetry_rhyme.Rhyme_groups.Compat.get_yu_rhyme_chars ()
end

module Hua_rhyme = struct
  let data = Poetry_rhyme.Rhyme_groups.Compat.get_hua_rhyme_chars ()
end
(* 注意：ping_sheng和ze_sheng是独立的库，需要在dune中添加依赖 *)

(** {1 数据源注册函数} *)

(** 注册鱼韵组数据 *)
let register_yu_rhyme () =
  let raw_data = Yu_rhyme.data in
  let converted_data = List.map (fun char -> (char, "平声", "鱼")) raw_data in
  register_data_source "yu_rhyme" (ModuleData converted_data) ~priority:100 "鱼韵组数据 - 平声韵数据"

(** 注册花韵组数据 *)
let register_hua_rhyme () =
  let raw_data = Hua_rhyme.data in
  let converted_data = List.map (fun char -> (char, "平声", "花")) raw_data in
  register_data_source "hua_rhyme" (ModuleData converted_data)
    ~priority:80 "花韵组数据 - 待验证接口"

(** 注册其他韵组数据 - 暂时使用占位符 *)
let register_other_rhymes () =
  (* 风韵组 - 待实现 *)
  register_data_source "feng_rhyme" (LazyData (fun () -> [])) ~priority:50 "风韵组数据 - 待实现";

  (* 月韵组 - 待实现 *)
  register_data_source "yue_rhyme" (LazyData (fun () -> [])) ~priority:50 "月韵组数据 - 待实现";

  (* 江韵组 - 待实现 *)
  register_data_source "jiang_rhyme" (LazyData (fun () -> [])) ~priority:50 "江韵组数据 - 待实现";

  (* 灰韵组 - 待实现 *)
  register_data_source "hui_rhyme" (LazyData (fun () -> [])) ~priority:50 "灰韵组数据 - 待实现"

(** {1 备份数据源注册} *)

(** 注册备份数据源 - 优先级较低，用于填补空缺 *)
let register_backup_data () =
  (* 暂时注册空的备份数据源 *)
  register_data_source "backup_data" (LazyData (fun () -> [])) ~priority:5 "备份韵律数据 - 暂未实现"

(** {1 初始化函数} *)

(** 注册所有可用的数据源 *)
let register_all_data_sources () =
  (* 按优先级顺序注册 *)
  register_yu_rhyme ();
  register_hua_rhyme ();
  register_other_rhymes ();
  register_backup_data ();

  (* 打印注册结果 *)
  Printf.printf "[INFO] 诗词数据源注册完成\n";
  print_registered_sources ()

(** 获取数据统计信息 *)
let get_registration_stats () =
  let source_names = get_registered_source_names () in
  let total_chars, groups, categories = get_database_stats () in
  let is_valid, errors = validate_database () in

  Printf.printf "\n=== 数据注册统计 ===\n";
  Printf.printf "注册数据源: %d 个\n" (List.length source_names);
  Printf.printf "总字符数: %d 个\n" total_chars;
  Printf.printf "韵组数: %d 个\n" groups;
  Printf.printf "韵类数: %d 个\n" categories;
  Printf.printf "数据有效性: %s\n" (if is_valid then "✅ 有效" else "❌ 有错误");

  if not is_valid then (
    Printf.printf "错误列表:\n";
    List.iter (fun error -> Printf.printf "  - %s\n" error) errors);

  (List.length source_names, total_chars, is_valid)

(** {1 模块初始化} *)

(** 自动初始化 - 模块加载时自动注册所有数据源 *)
let () = register_all_data_sources ()
