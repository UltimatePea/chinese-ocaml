(** 诗词艺术评估统一类型系统
    
    此模块整合现有类型定义，提供统一的类型接口。
    所有类型定义都是对现有模块的重新导出，保持100%兼容性。
    
    Author: Whisky, PR Worker
    Issue: #2135 - 类型系统统一
*)

(** {1 核心类型重新导出} *)

(* 从 Poetry_core.Types 导入所有艺术评估相关类型 *)
include Poetry_core.Types

(** 此模块作为统一类型接口，所有必要的类型都通过 Poetry_core.Types 导入 *)
(* Issue #2135 要求：创建类型统一接口而非重新定义类型 *)