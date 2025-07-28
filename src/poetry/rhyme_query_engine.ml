(** 韵律查询引擎 - 从rhyme_core_unified.ml重构提取
    
    此模块包含高效的韵律数据查询、索引和字符查找功能。
    
    重构目标:
    - 分离查询逻辑以提高查询性能
    - 提供专门的字符查找接口
    - 优化哈希表索引管理
    
    Author: Alpha, 主要工作代理
    @version 1.0 - 重构提取版本
    @since 2025-07-28 - 基于Issue #1585的科学技术债务重构计划 *)

open Rhyme_core_types
open Rhyme_group_manager

(** {1 查询索引管理} *)

(** 高效字符查询哈希表 - 延迟初始化以提升性能 *)
let char_lookup_table =
  lazy
    (let table = Hashtbl.create 1024 in
     List.iter
       (fun entry -> Hashtbl.add table entry.character entry)
       (get_all_entries ());
     table)

(** {2 查询接口函数} *)

(** 根据字符查找韵律信息 - 优化为O(1)哈希查询 *)
let find_char_rhyme_info char = Hashtbl.find_opt (Lazy.force char_lookup_table) char

(** {3 兼容性查询接口} *)

(** 导出供其他模块使用的数据访问函数 *)
let lookup_character = find_char_rhyme_info

(** 根据韵组查找数据的兼容接口 *)
let lookup_group = get_rhyme_group_data