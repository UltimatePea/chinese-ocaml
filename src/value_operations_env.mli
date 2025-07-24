(** 骆言值操作环境管理模块接口 - Value Operations Environment Management Interface
    
    技术债务改进：大型模块重构优化 Phase 2.2 - value_operations.ml 完整模块化
    提供运行时环境管理的公共接口
    
    @author 骆言AI代理
    @version 2.2 - 完整模块化第二阶段  
    @since 2025-07-24 Fix #1048
*)

open Value_types

(** 在环境中查找变量 - 支持模块访问和拼写纠正 *)
val lookup_var : runtime_env -> string -> runtime_value

(** 在环境中查找变量（可选版本） *)
val lookup_var_opt : runtime_env -> string -> runtime_value option

(** 检查环境中是否定义了变量 *)
val is_defined : runtime_env -> string -> bool

(** 获取环境中的所有可用变量名 *)
val get_available_vars : runtime_env -> string list

(** 获取环境的大小（变量数量） *)
val env_size : runtime_env -> int

(** 合并两个环境，优先使用第一个环境的绑定 *)
val merge_env : runtime_env -> runtime_env -> runtime_env

(** 过滤环境，只保留满足条件的绑定 *)
val filter_env : (string * runtime_value -> bool) -> runtime_env -> runtime_env

(** 映射环境的值，保持变量名不变 *)
val map_env_values : (runtime_value -> runtime_value) -> runtime_env -> runtime_env

(** 从环境中移除指定的变量 *)
val remove_var : runtime_env -> string -> runtime_env

(** 批量绑定变量到环境 *)
val bind_vars : runtime_env -> (string * runtime_value) list -> runtime_env

(** 环境转换为关联列表（兼容性接口） *)
val env_to_assoc_list : runtime_env -> (string * runtime_value) list

(** 从关联列表创建环境 *)
val env_from_assoc_list : (string * runtime_value) list -> runtime_env

(** 打印环境内容（用于调试） *)
val print_env : runtime_env -> unit

(** 获取环境的字符串表示 *)
val string_of_env : runtime_env -> string