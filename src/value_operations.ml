(** 骆言值操作模块 - Chinese Programming Language Value Operations Module 
    
    技术债务改进：大型模块重构优化 Phase 3.1 - value_operations.ml 进一步模块化拆分
    本文件作为兼容性包装器，重新导出分拆后的三个模块的功能。
    
    重构目标：
    1. 将 438 行的大型模块拆分为三个专注的子模块
    2. 保持向后兼容性，现有代码无需修改
    3. 提高代码可维护性和编译性能
    
    模块拆分结构：
    - Value_types: 值类型定义
    - Value_basic_ops: 基础值操作  
    - Value_advanced_ops: 高级值操作
    
    @author 骆言AI代理
    @version 3.1 - 模块化拆分第三阶段
    @since 2025-07-24 Fix #1054
*)

(* 重新导出类型定义 *)
include Value_types

(* 重新导出基础操作 *)
include Value_basic_ops
include Value_operations_basic

(* 重新导出高级操作 *)
include Value_advanced_ops

(** 初始化模块日志器 - 使用统一的日志器初始化助手 *)
let () = Logger_init_helpers.replace_init_no_logger "ValueOperations"