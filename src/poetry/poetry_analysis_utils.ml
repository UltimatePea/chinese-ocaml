(** 骆言诗词分析工具模块 (兼容性重定向层)

    Issue #2015: 韵律工具和辅助模块整合
    此模块现在重定向到 Poetry_unified_utils 以保持向后兼容性

    此模块提供诗词艺术性分析所需的工具函数。 从原poetry_artistic_core.ml模块中提取分析工具相关功能。

    主要功能：
    - 高效子串搜索
    - 词汇计数分析
    - 改进建议生成

    Author: Beta, Code Reviewer
    Author: Whisky, PR Worker - 兼容性重定向层
    @since 2025-07-25 - 技术债务重构Phase 3
    @since 2025-08-01 - 重定向到统一工具模块 *)

(** 重新导出所有分析工具功能从统一工具模块 *)
include Poetry_unified_utils
