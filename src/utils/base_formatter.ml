(** 骆言编译器底层格式化基础设施 - 模块化重构版本

    此模块作为统一入口点，重新导出所有专门格式化模块的功能，保持向后兼容性。

    模块化设计:
    - base_string_ops.ml：基础字符串操作和类型转换
    - error_formatters.ml：错误消息格式化模式
    - position_formatters.ml：位置信息和调试格式化
    - syntax_formatters.ml：语法元素和C代码生成格式化
    - analysis_formatters.ml：分析报告和性能统计格式化

    设计原则:
    - 零Printf.sprintf依赖：底层模块不使用Printf.sprintf
    - 高性能字符串操作：使用最优化的字符串拼接
    - 模块化分离：按功能领域分离不同格式化需求
    - 向后兼容：现有代码无需修改即可使用

    用途：作为所有上层格式化模块的统一基础设施 *)

(** 重新导出所有专门格式化模块的功能 *)

include Base_string_ops
(** 基础字符串操作模块 - 提供基础字符串拼接和类型转换 *)

include Error_formatters
(** 错误消息格式化模块 - 提供各类错误信息的标准化格式 *)

include Position_formatters
(** 位置信息格式化模块 - 提供源码位置和调试信息格式化 *)

include Syntax_formatters
(** 语法元素格式化模块 - 提供Token、函数调用、C代码生成格式化 *)

include Analysis_formatters
(** 分析报告格式化模块 - 提供性能分析和统计报告格式化 *)

(** 为向后兼容性，将原Base_formatter模块的功能通过别名保持可用 *)
module Base_formatter = struct
  (* 基础字符串操作 *)
  include Base_string_ops

  (* 错误格式化 *)
  include Error_formatters

  (* 位置格式化 *)
  include Position_formatters

  (* 语法格式化 *)
  include Syntax_formatters

  (* 分析格式化 *)
  include Analysis_formatters
end
