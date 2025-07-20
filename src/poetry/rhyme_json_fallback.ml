(** 韵律JSON降级数据
    
    提供韵律数据的降级方案，确保在文件读取失败时系统仍能正常运行。
    
    @author 骆言诗词编程团队 
    @version 1.0
    @since 2025-07-20 - Phase 29 rhyme_json_loader重构 *)

open Rhyme_json_types
open Rhyme_json_cache

(** {1 降级数据定义} *)

(** 降级韵律数据 *)
let fallback_rhyme_data = [
  ("安韵", { category = "平声"; characters = ["安"; "看"; "山"] });
  ("思韵", { category = "仄声"; characters = ["思"; "之"; "子"] });
]

(** {1 降级操作函数} *)

(** 使用降级数据 *)
let use_fallback_data () =
  Printf.eprintf "警告: 使用降级韵律数据\n%!";
  let data = { rhyme_groups = fallback_rhyme_data; metadata = [] } in
  set_cached_data data;
  data