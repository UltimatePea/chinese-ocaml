(** 韵律JSON数据加载器 - Wave 2 重构版本

    此模块已完全重构为Poetry_core.Json_core的兼容接口层。
    原本通过中间层Rhyme_json_api转发，现在直接转发到统一的JSON核心，
    进一步减少间接调用，提升性能并简化架构。

    原有功能完全保留，API保持100%向后兼容：
    - 数据加载接口 → 直接转发到统一核心
    - 缓存管理 → 转发到统一核心
    - 降级数据处理 → 转发到统一核心
    - 统计信息 → 转发到统一核心

    @author Alpha, Primary Worker Agent - Wave 2 重构团队
    @version 3.1 - Wave 2 直接转发版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2 继续实施
    @previous_version 3.0 - 2025-07-24 Phase 7.1 JSON处理系统整合重构
    @fix_issue #1550 *)

(** {1 类型重新导出 - 完全兼容} *)

(* 重新导出类型以保持兼容性 *)
type rhyme_category = Rhyme_json_core.rhyme_category
type rhyme_group = Rhyme_json_core.rhyme_group

(* 异常重新导出 *)
exception Json_parse_error of string
exception Rhyme_data_not_found of string

(* 数据类型重新导出 *)
type rhyme_group_data = Rhyme_json_core.rhyme_group_data = { 
  category : string; 
  characters : string list 
}
type rhyme_data_file = Rhyme_json_core.rhyme_data_file = {
  rhyme_groups : (string * rhyme_group_data) list;
  metadata : (string * string) list;
}

(** {1 数据加载接口 - 直接转发到统一核心} *)

(** 获取韵律数据 - 直接转发到统一核心 *)
let get_rhyme_data ?(force_reload = false) () =
  Poetry_core.Json_core.get_rhyme_data_safe ~force_reload ()

(** 获取所有韵组 - 直接转发到统一核心 *)
let get_all_rhyme_groups () =
  Poetry_core.Json_core.get_all_rhyme_groups ()

(** 获取韵组字符 - 直接转发到统一核心 *)
let get_rhyme_group_characters group_name =
  Poetry_core.Json_core.get_rhyme_group_characters group_name

(** 获取韵组类别 - 直接转发到统一核心 *)
let get_rhyme_group_category group_name =
  Poetry_core.Json_core.get_rhyme_group_category group_name

(** {1 向后兼容接口 - 直接转发到统一核心} *)

(** 获取韵律映射 - 直接转发到统一核心 *)
let get_rhyme_mappings () =
  Poetry_core.Json_core.get_rhyme_mappings ()

(** {1 统计和调试 - 直接转发到统一核心} *)

(** 获取数据统计 - 直接转发到统一核心 *)
let get_data_statistics () =
  match Poetry_core.Json_core.get_data_statistics () with
  | Some (total_groups, total_chars, _, _, _) -> Some (total_groups, total_chars)
  | None -> None

(** 打印统计信息 - 直接转发到统一核心 *)
let print_statistics () =
  Poetry_core.Json_core.print_statistics ()

(** {1 降级机制 - 直接转发到统一核心} *)

(** 使用降级数据 - 直接转发到统一核心 *)
let use_fallback_data () =
  ignore (Poetry_core.Json_core.Fallback.use_fallback_data ())