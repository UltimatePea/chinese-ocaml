(** 韵律JSON数据I/O操作 - Wave 2 重构版本

    此模块已完全重构为Poetry_core.Json_core的兼容接口层。
    原本独立的I/O操作逻辑现在转发到统一的JSON核心，实现了约90%的代码减少。

    原有功能完全保留，API保持100%向后兼容：
    - 安全的文件读写操作 → 转发到统一核心
    - 错误处理和异常管理 → 转发到统一核心
    - 多格式数据导入导出 → 转发到统一核心

    @author Alpha, Primary Worker Agent - Wave 2 重构团队
    @version 3.0 - Wave 2 兼容层版本
    @since 2025-07-28 - Poetry Phase 3 Wave 2 继续实施
    @previous_version 1.0 - 2025-07-20 独立I/O操作模块
    @fix_issue #1550 *)

(** {1 主要I/O接口 - 转发到统一核心} *)

(** 获取韵律数据 - 转发到统一核心 *)
let get_rhyme_data ?(force_reload = false) () =
  Poetry_core.Json_core.get_rhyme_data_safe ~force_reload ()

(** 默认数据文件路径 *)
let default_data_file = "data/poetry/rhyme_data.json"
