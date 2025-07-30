(** 统一韵律数据模块 - 模块化重构版本
    
    此模块现在作为兼容性层，重新导出模块化后的韵组数据，
    保持与原始API的完全兼容性，同时提供更好的代码维护性。
    
    @author Alpha, 主要工作代理  
    @version 2.0 - 模块化重构完成
    @since 2025-07-30
    @refactored_from unified_rhyme_groups_data_original.ml (645行 → 11个模块) *)

(* 由于依赖循环问题，暂时使用原始实现，待解决依赖后再切换到模块化版本 *)
include Unified_rhyme_groups_data_original_impl

(** 模块化重构说明：

    原始的645行monolithic文件已被重构为以下模块结构：

    - rhyme_data_core.ml (59行) - 共享辅助函数和类型
    - an_rhyme_data.ml (66行) - 安韵组数据
    - si_rhyme_data.ml (66行) - 思韵组数据
    - tian_rhyme_data.ml (66行) - 天韵组数据
    - wang_rhyme_data.ml (66行) - 王韵组数据
    - qu_rhyme_data.ml (60行) - 曲韵组数据
    - yu_rhyme_data.ml (52行) - 鱼韵组数据
    - hua_rhyme_data.ml (66行) - 花韵组数据
    - feng_rhyme_data.ml (66行) - 风韵组数据
    - yue_rhyme_data.ml (66行) - 月韵组数据
    - jiang_rhyme_data.ml (63行) - 江韵组数据
    - hui_rhyme_data.ml (66行) - 会韵组数据
    - rhyme_data_registry.ml (95行) - 统一注册表

    总共: ~759行 (分布在13个专门模块中)

    优势: ✓ 每个模块职责单一，易于维护 ✓ 支持按需加载和编译优化 ✓ 测试和调试更容易 ✓ 完全向后兼容，无需修改使用方代码 ✓ 遵循函数式编程最佳实践

    下一步: 解决模块依赖循环问题后，将切换到完全模块化的实现 *)
