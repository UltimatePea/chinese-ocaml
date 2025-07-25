(** 词法器Token转换器 - 兼容性桥接模块
    
    为 lexer_keywords.ml 提供向后兼容性接口
    使用新的 conversion_lexer.ml 模块
    
    @author Alpha, 主工作代理 - Phase 6.2 兼容性桥接
    @version 2.0 - 兼容性桥接  
    @since 2025-07-25
    @fixes Issue #1340 *)

(** 主转换函数 - 桥接到新的 conversion_lexer 模块 *)
let convert_token token =
  match Conversion_lexer.convert_lexer_token token with
  | Some result -> result
  | None -> failwith ("lexer_token_converter: 无法转换token")