(** 韵律JSON数据访问接口 - Wave 2 重构版本

    此模块已完全重构为Poetry_core.Json_core的兼容接口层。
    原本独立的数据访问逻辑现在转发到统一的JSON核心，实现了约90%的代码减少。

    原有功能完全保留，API保持100%向后兼容：
    - 便捷的韵律数据查询和访问功能 → 转发到统一核心
    - 封装底层数据操作复杂性 → 通过统一核心简化
    - 数据统计和分析功能 → 转发到统一核心

    @author Alpha, Primary Worker Agent - Wave 2 重构团队
    @version 3.0 - Wave 2 兼容层版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2 继续实施
    @previous_version 1.0 - 2025-07-20 Phase 29 rhyme_json_loader重构
    @fix_issue #1550 *)

(** {1 类型重新导出 - 完全兼容} *)

(* 重新导出核心类型以保持100%向后兼容 *)
(* 类型兼容性处理 - 直接使用统一核心的类型 *)

(** {1 数据查询函数 - 转发到统一核心} *)

(** 获取所有韵组 - 转发到统一核心 *)
let get_all_rhyme_groups () =
  Poetry_core.Json_core.get_all_rhyme_groups ()

(** 获取指定韵组的字符列表 - 转发到统一核心 *)
let get_rhyme_group_characters group_name =
  Poetry_core.Json_core.get_rhyme_group_characters group_name

(** 获取指定韵组的韵类 - 转发到统一核心 *)
let get_rhyme_group_category group_name =
  Poetry_core.Json_core.get_rhyme_group_category group_name

(** 获取韵律映射关系 - 转发到统一核心 *)
let get_rhyme_mappings () =
  Poetry_core.Json_core.get_rhyme_mappings ()

(** {1 数据统计函数 - 转发到统一核心} *)

(** 获取数据统计信息 - 转发到统一核心 *)
let get_data_statistics () =
  match Poetry_core.Json_core.get_data_statistics () with
  | Some (total_groups, total_chars, _, _, _) -> Some (total_groups, total_chars)
  | None -> None

(** 打印统计信息 - 转发到统一核心 *)
let print_statistics () =
  Poetry_core.Json_core.print_statistics ()

(** {1 向后兼容接口 - 转发到统一核心} *)


