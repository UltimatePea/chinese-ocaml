(** 入声字符数据模块 - 兼容性层
    
    此模块现在是兼容性层，重新导出unified_tone_data的入声功能。
    原有复杂的JSON加载逻辑已整合到unified_tone_data.ml，此文件保持向后兼容性。
    
    Author: Alpha, 主要工作代理 - Poetry模块重构Phase 1
    技术债务清理: 4个声调文件合并为1个统一模块，简化115行复杂JSON加载代码
    Fix #1765 - Poetry韵律数据重复整合优化
    @since 2025-07-30 *)

(* 重新导出统一声调数据的入声功能 *)
include Unified_tone_data


(* 保持原有异常处理兼容性 *)
exception Ru_sheng_data_error of string

(* 保持原有懒加载数据兼容性 *)
let ru_sheng_chars = lazy (get_ru_sheng_chars ())

(* 保持原有API兼容性 *)
let get_ru_sheng_count = count_ru_sheng

(* 简化的验证函数 - 转发到统一验证 *)
let validate_data () =
  if validate_unified_data () then
    Printf.printf "✅ 入声数据验证通过：共 %d 个字符\n" (count_ru_sheng ())
  else
    raise (Ru_sheng_data_error "入声数据验证失败")

(* 简化的元信息函数 - 兼容性保持 *)
let get_metadata () = 
  ("入声数据", "统一声调数据中的入声部分", "3.0", "入声")