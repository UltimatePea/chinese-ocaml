(** 外化数据加载器兼容性包装层接口 - Phase 2
    
    此模块提供与原始externalized_data_loader完全相同的接口，
    确保100%向后兼容性，无需修改现有调用代码。
    
    @author Beta, 代码审查专员
    @version 2.0 - Phase 2 兼容性包装
    @since 2025-07-29  
    @fix_issue #1732 *)

(** {1 重新导出扩展接口} *)

include module type of Unified_data_loader_extended

(** {1 兼容性数据结构} *)

(** 旧的数据结构定义 - 向后兼容 *)
type old_all_poetry_data = {
  nature_nouns : string list;
  classifiers : string list;
  tools_objects : string list;
  ping_sheng : string list;
  shang_sheng : string list;
  qu_sheng : string list;
  ru_sheng : string list;
}

(** {1 兼容性接口} *)

val load_all_data : unit -> old_all_poetry_data
(** 加载所有数据 - 兼容原始接口
    @return 与原始接口兼容的数据结构 *)