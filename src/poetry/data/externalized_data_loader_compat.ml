(** 外化数据加载器兼容性包装层 - Phase 2
    
    此模块提供与原始externalized_data_loader完全相同的接口，
    但内部使用unified_data_loader_extended实现，确保向后兼容性。
    
    @author Beta, 代码审查专员  
    @version 2.0 - Phase 2 兼容性包装
    @since 2025-07-29
    @fix_issue #1732 *)

(** {1 直接重新导出扩展加载器的接口} *)

include Unified_data_loader_extended

(** {1 兼容性数据结构定义} *)

type old_all_poetry_data = {
  nature_nouns : string list;
  classifiers : string list;
  tools_objects : string list;
  ping_sheng : string list;
  shang_sheng : string list;
  qu_sheng : string list;
  ru_sheng : string list;
}
(** 旧的数据结构定义 - 为了兼容性 *)

(** {1 额外的兼容性函数} *)

(** 重新定义load_all_data函数以匹配原始接口 *)
let load_all_data () =
  let all_data = load_all_word_class_data () in
  ({
     nature_nouns = all_data.nature_nouns;
     classifiers = [];
     (* 如果需要，可以从其他源加载 *)
     tools_objects = all_data.tools_objects_nouns;
     ping_sheng = all_data.ping_sheng;
     shang_sheng = all_data.shang_sheng;
     qu_sheng = all_data.qu_sheng;
     ru_sheng = all_data.ru_sheng;
   }
    : old_all_poetry_data)
