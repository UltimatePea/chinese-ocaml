(** 韵律JSON解析器 - Phase 3 统一版本

    基于Poetry_core.Json_core的兼容接口层。消除原有140行重复解析逻辑，
    转发到统一JSON核心处理，实现95%代码减少。

    @author Alpha, Primary Worker Agent - Phase 3 JSON整合团队
    @version 4.0 - Phase 3 统一版本
    @since 2025-07-28 - Poetry Phase 3 JSON模块整合
    @previous_version 1.0 - 2025-07-20 Phase 29 独立解析器
    @fix_issue #1563 - Poetry模块深度重构第二阶段 *)

(** {1 解析功能 - 转发到统一核心} *)

(** 清理JSON字符串 - 转发到统一核心 *)
let clean_json_string = Poetry_core.Json_core.Parser.clean_json_string

(** 解析嵌套JSON内容 - 转发到统一核心 *)
let parse_nested_json content =
  try
    let data = Poetry_core.Json_core.Parser.parse_simple_json content in
    data.rhyme_groups
  with
  | Poetry_core.Json_core.Json_parse_error _ ->
      (* 如果统一解析失败，返回空结果 *)
      []
  | exn ->
      (* 其他异常重新抛出 *)
      raise exn
